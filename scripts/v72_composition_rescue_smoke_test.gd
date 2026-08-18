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
	if not game.has_method("_v72_composition_snapshot") or not bool(game.call("_v72_composition_ready")):
		_fail("main scene is not running the v1.58 composition contract")
		return
	var stage = game.v70_menu_stage
	if stage == null or not stage.has_method("composition_ready"):
		_fail("v1.58 composition-capable menu stage is missing")
		return
	var authored_environment: bool = stage.has_method("environment_assets_ready")

	_stage("all-menu-stages")
	for screen in SCREENS:
		stage.call("set_screen", screen)
		await process_frame
		var snapshot: Dictionary = stage.call("debug_snapshot")
		print("V72_STAGE:%s:%s" % [screen, JSON.stringify(snapshot)])
		if not bool(snapshot.get("ready", false)):
			_fail("3D stage not ready for %s" % screen)
			return
		if String(snapshot.get("composition_version", "")) != "1.58":
			_fail("composition marker missing on %s" % screen)
			return
		if absf(float(snapshot.get("camera_fov", 0.0)) - 46.0) > 0.01:
			_fail("v1.58 camera FOV regressed on %s" % screen)
			return

	_stage("home-clear-frame")
	stage.call("set_screen", "home")
	await process_frame
	var home: Dictionary = stage.call("debug_snapshot")
	if not bool(home.get("actor_present", false)) or String(home.get("actor_animation", "")) != "Idle":
		_fail("Home Wanderer is missing or not idling")
		return
	if float(home.get("actor_scale", 99.0)) > 0.75 or float(home.get("actor_y", -99.0)) < 1.55:
		_fail("Home Wanderer framing is still too large/low")
		return
	for blocker in ["SideWall", "Forecourt", "ForecourtStep", "GateRecess"]:
		if stage.stage_root.get_node_or_null(blocker) != null:
			_fail("legacy Home foreground blocker survived: %s" % blocker)
			return

	_stage("hero-clear-frame")
	stage.call("set_screen", "hero")
	await process_frame
	var hero: Dictionary = stage.call("debug_snapshot")
	if not bool(hero.get("actor_present", false)) or String(hero.get("actor_animation", "")) != "Idle":
		_fail("Hero Wanderer is missing or not idling")
		return
	if float(hero.get("actor_scale", 99.0)) > 0.90 or float(hero.get("actor_y", -99.0)) < 3.20:
		_fail("Hero Wanderer framing is still too large/low")
		return
	for blocker in ["HeroAlcove", "HeroColumn", "HeroColumnBase"]:
		if stage.stage_root.get_node_or_null(blocker) != null:
			_fail("legacy Hero foreground blocker survived: %s" % blocker)
			return

	_stage("forge-background-only")
	stage.call("set_screen", "forge")
	await process_frame
	# v1.58 used procedural Forge nodes; v1.59 intentionally replaces those with
	# imported authored meshes. Preserve the composition contract while accepting
	# the new implementation instead of forcing deleted blockout node names back.
	var forge_required: Array[String] = ["ForgeHearthAsset", "ForgeRackAsset", "ForgeAnvilAsset"] if authored_environment else ["ForgeHearth", "ForgeMouth", "ForgeRack", "ForgeAnvilTop"]
	for required in forge_required:
		if stage.stage_root.get_node_or_null(required) == null:
			_fail("Forge composition prop missing: %s" % required)
			return
	for blocker in ["ForgeBody", "ForgeChimney", "WeaponRack", "AnvilHornB"]:
		if stage.stage_root.get_node_or_null(blocker) != null:
			_fail("legacy Forge blocker survived: %s" % blocker)
			return

	_stage("regressions")
	if not bool(game.call("_v71_lookdev_ready")):
		_fail("v1.57 material/lookdev contract regression")
		return
	if not bool(game.call("_v70_full_3d_presentation_ready")):
		_fail("v1.56 presentation regression")
		return
	if not bool(game.call("_v69_wanderer_production_ready")):
		_fail("v1.55 Wanderer regression")
		return

	_stage("complete")
	print("v1.58 composition rescue smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _stage(name: String) -> void:
	_stage_name = name
	print("V72_TEST_STAGE:%s" % name)

func _fail(message: String) -> void:
	push_error("V72_COMPOSITION_FAIL:%s:%s" % [_stage_name, message])
	quit(1)
