extends SceneTree

const SCREENS := ["home", "hero", "forge", "talents", "vault", "missions", "pass", "store"]

var _stage_name := "boot"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_stage("load-main")
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	_stage("version-gate")
	if not game.has_method("_v71_lookdev_snapshot"):
		_fail("main scene is not running v1.57 production 3D lookdev")
		return
	if not bool(game.call("_v71_lookdev_ready")):
		_fail("v1.57 lookdev gate is not ready")
		return

	var stage = game.v70_menu_stage
	if stage == null or not stage.has_method("lookdev_ready"):
		_fail("v1.57 menu stage is missing")
		return

	_stage("all-menu-stages")
	for screen in SCREENS:
		stage.call("set_screen", screen)
		await process_frame
		var snapshot: Dictionary = stage.call("debug_snapshot")
		print("V71_STAGE:%s:%s" % [screen, JSON.stringify(snapshot)])
		if not bool(snapshot.get("ready", false)):
			_fail("3D stage not ready for %s" % screen)
			return
		if String(snapshot.get("lookdev_version", "")) != "1.57":
			_fail("lookdev marker missing on %s" % screen)
			return
		if absf(float(snapshot.get("camera_fov", 0.0)) - 36.0) > 0.01:
			_fail("production camera FOV regressed on %s" % screen)
			return

	_stage("home-composition")
	stage.call("set_screen", "home")
	await process_frame
	if stage.stage_root.get_node_or_null("GateArch05") == null or stage.stage_root.get_node_or_null("ForecourtStep") == null:
		_fail("Home production gate composition is incomplete")
		return
	var home_snapshot: Dictionary = stage.call("debug_snapshot")
	if not bool(home_snapshot.get("actor_present", false)) or float(home_snapshot.get("actor_scale", 0.0)) > 1.0:
		_fail("Home Wanderer is missing or still oversized")
		return

	_stage("hero-composition")
	stage.call("set_screen", "hero")
	await process_frame
	if stage.stage_root.get_node_or_null("HeroArch06") == null or stage.stage_root.get_node_or_null("HeroDais") == null:
		_fail("Hero production alcove is incomplete")
		return
	var hero_snapshot: Dictionary = stage.call("debug_snapshot")
	if not bool(hero_snapshot.get("actor_present", false)) or String(hero_snapshot.get("actor_animation", "")) != "Idle":
		_fail("Hero imported Wanderer is not idling")
		return
	if float(hero_snapshot.get("actor_scale", 0.0)) > 1.10:
		_fail("Hero Wanderer composition is still oversized")
		return

	_stage("forge-composition")
	stage.call("set_screen", "forge")
	await process_frame
	for node_name in ["FurnaceMouth", "AnvilTop", "WeaponRack"]:
		if stage.stage_root.get_node_or_null(node_name) == null:
			_fail("Forge production prop missing: %s" % node_name)
			return

	_stage("practical-lighting")
	if _count_exact_name(stage.stage_root, "Flame") > 0:
		_fail("legacy oversized v1.56 Flame spheres are still present")
		return
	if _count_exact_name(stage.stage_root, "FlameCore") < 1 or _count_exact_name(stage.stage_root, "FlameTip") < 1:
		_fail("compact v1.57 practical flame profile is missing")
		return

	_stage("regressions")
	if not bool(game.call("_v70_full_3d_presentation_ready")):
		_fail("v1.56 full 3D presentation regressed")
		return
	if not bool(game.call("_v69_wanderer_production_ready")):
		_fail("v1.55 production Wanderer regressed")
		return
	if not bool(game.call("_v68_real_model_intake_ready")):
		_fail("v1.54 real-model intake regressed")
		return

	_stage("snapshot")
	var final_snapshot: Dictionary = game.call("_v71_lookdev_snapshot")
	print("V71_SNAPSHOT:%s" % JSON.stringify(final_snapshot))
	if String(final_snapshot.get("version", "")) != "1.57.0-production-3d-lookdev":
		_fail("v1.57 version marker is wrong")
		return

	_stage("complete")
	print("v1.57 production 3D lookdev smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _count_exact_name(node: Node, wanted: String) -> int:
	var count := 1 if node.name == wanted else 0
	for child in node.get_children():
		count += _count_exact_name(child, wanted)
	return count

func _stage(name: String) -> void:
	_stage_name = name
	print("V71_TEST_STAGE:%s" % name)

func _fail(message: String) -> void:
	push_error("V71_LOOKDEV_FAIL:%s:%s" % [_stage_name, message])
	quit(1)
