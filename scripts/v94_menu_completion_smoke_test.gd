extends SceneTree

const FRONTEND_SCREENS := ["home", "hero", "forge", "talents", "vault", "missions", "pass"]
const ACTOR_SCREENS := ["home", "hero"]

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
	for _i in range(5):
		await process_frame

	_stage("completion-stack")
	if not game.has_method("_v89_frontend_completion_ready"):
		_fail("v1.67 frontend completion main layer is not active")
		return
	var stage = game.v70_menu_stage
	if stage == null or not stage.has_method("frontend_completion_ready"):
		_fail("frontend completion menu stage is missing")
		return
	if String(stage.debug_snapshot().get("frontend_completion_version", "")) != "1.67-frontend-completion-r1":
		_fail("frontend completion version marker missing")
		return

	for screen in FRONTEND_SCREENS:
		_stage("screen-%s" % screen)
		stage.set_screen(screen)
		await process_frame
		var snapshot: Dictionary = stage.debug_snapshot()
		if String(snapshot.get("screen", "")) != screen:
			_fail("menu stage failed to switch to %s" % screen)
			return
		if int(snapshot.get("stage_children", 0)) < 5:
			_fail("menu stage is visually underbuilt on %s" % screen)
			return
		if not bool(snapshot.get("frontend_completion_ready", false)):
			_fail("frontend readiness failed on %s" % screen)
			return
		if screen in ACTOR_SCREENS:
			if stage.actor_model == null:
				_fail("shared Wanderer missing on %s" % screen)
				return
			if String(stage.actor_model.get_meta("character_form_v166", "")) != "1.66-character-form-r1.1":
				_fail("menu Wanderer is not the v1.66 gameplay actor on %s" % screen)
				return
			if not bool(stage.gameplay_actor_factory.call("v166_character_form_player_ready", stage.actor_model)):
				_fail("menu Wanderer gameplay character-form contract failed on %s" % screen)
				return

	_stage("regressions")
	stage.set_screen("home")
	await process_frame
	if not bool(game.call("_v89_frontend_completion_ready")):
		_fail("frontend completion main readiness failed")
		return
	if not bool(game.call("_v87_character_form_ready")):
		_fail("v1.66 gameplay character-form regression")
		return
	if not bool(game.call("_v86_environment_depth_ready")):
		_fail("v1.65 environment regression")
		return
	if not bool(game.call("_v80_runtime_cta_ready")):
		_fail("v1.62 runtime UI regression")
		return

	_stage("complete")
	print("v1.67 frontend completion smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _stage(name: String) -> void:
	_stage_name = name
	print("V94_TEST_STAGE:%s" % name)

func _fail(message: String) -> void:
	push_error("V94_FRONTEND_COMPLETION_FAIL:%s:%s" % [_stage_name, message])
	quit(1)
