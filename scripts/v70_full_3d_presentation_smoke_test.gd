extends SceneTree

const MENU_SCREENS := ["home", "hero", "forge", "talents", "vault", "missions", "pass", "store"]
var _stage := "boot"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_mark("load-main")
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame

	_mark("version")
	if not game.has_method("_v70_presentation_snapshot"):
		_fail("main scene is not running v1.56")
		return
	if not bool(game.call("_v70_full_3d_presentation_ready")):
		_fail("v1.56 presentation readiness gate failed: %s" % JSON.stringify(game.call("_v70_presentation_snapshot")))
		return

	_mark("viewport")
	if game.v70_menu_viewport == null:
		_fail("Menu3DViewport missing")
		return
	if game.v70_menu_viewport.size != Vector2i(720, 1280):
		_fail("unexpected menu viewport size: %s" % str(game.v70_menu_viewport.size))
		return
	if game.v70_menu_stage == null:
		_fail("Full3DMenuStage missing")
		return

	_mark("menu-stages")
	for screen in MENU_SCREENS:
		game.v70_menu_stage.call("set_screen", screen)
		await process_frame
		var snapshot: Dictionary = game.v70_menu_stage.call("debug_snapshot")
		print("V70_STAGE:%s:%s" % [screen, JSON.stringify(snapshot)])
		if not bool(snapshot.get("ready", false)):
			_fail("3D stage not ready for %s" % screen)
			return
		if String(snapshot.get("screen", "")) != screen:
			_fail("3D stage route mismatch for %s" % screen)
			return
		if int(snapshot.get("stage_children", 0)) < 5:
			_fail("3D stage composition too small for %s" % screen)
			return
		if screen in ["home", "hero"] and not bool(snapshot.get("actor_present", false)):
			_fail("imported Wanderer missing from %s 3D stage" % screen)
			return

	_mark("wanderer-regression")
	if not bool(game.call("_v69_wanderer_production_ready")):
		_fail("v1.55 production Wanderer gameplay model regressed")
		return

	_mark("combat-regression")
	if not bool(game.call("_v65_3d_combat_core_ready")):
		_fail("v1.52 3D combat core regressed")
		return

	_mark("snapshot")
	var final_snapshot: Dictionary = game.call("_v70_presentation_snapshot")
	print("V70_SNAPSHOT:%s" % JSON.stringify(final_snapshot))
	if String(final_snapshot.get("version", "")) != "1.56.0-full-3d-presentation":
		_fail("v1.56 version marker wrong")
		return

	_mark("complete")
	print("v1.56 full 3D presentation smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _mark(name: String) -> void:
	_stage = name
	print("V70_TEST_STAGE:%s" % name)

func _fail(message: String) -> void:
	push_error("V70_PRESENTATION_FAIL:%s:%s" % [_stage, message])
	quit(1)
