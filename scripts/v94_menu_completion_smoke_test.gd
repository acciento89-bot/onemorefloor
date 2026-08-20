extends SceneTree

const FRONTEND_SCREENS := ["home", "hero", "forge", "talents", "vault", "missions", "pass"]
const ACTOR_SCREENS := ["home", "hero"]
const R12_ASSETS := [
	"res://assets/environment/v167/forge_workshop_structure.obj",
	"res://assets/environment/v167/forge_workshop_trim.obj",
	"res://assets/environment/v167/forge_workshop_ember.obj",
]

var _stage_name := "boot"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_stage("asset-imports")
	for path in R12_ASSETS:
		if not ResourceLoader.exists(path):
			_fail("missing r1.2 authored menu asset: %s" % path)
			return
		var mesh := load(path) as Mesh
		if mesh == null or mesh.get_surface_count() <= 0:
			_fail("r1.2 authored asset did not import as Mesh: %s" % path)
			return

	_stage("load-main")
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	for _i in range(6):
		await process_frame

	_stage("completion-stack")
	if not game.has_method("_v91_frontend_finish_ready"):
		_fail("v1.67 r1.2 frontend finish layer is not active")
		return
	var stage = game.v70_menu_stage
	if stage == null or not stage.has_method("frontend_completion_ready"):
		_fail("frontend completion menu stage is missing")
		return

	for screen in FRONTEND_SCREENS:
		_stage("screen-%s" % screen)
		stage.set_screen(screen)
		await process_frame
		var snapshot: Dictionary = stage.debug_snapshot()
		if String(snapshot.get("screen", "")) != screen:
			_fail("menu stage failed to switch to %s" % screen)
			return
		if String(snapshot.get("frontend_completion_version", "")) != "1.67-frontend-completion-r1.2":
			_fail("r1.2 frontend version marker missing on %s" % screen)
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
		if screen == "forge":
			if int(snapshot.get("r12_asset_instances", 0)) < 3:
				_fail("r1.2 authored Forge workshop kit is incomplete")
				return
			for node_name in ["ForgeWorkshopR12", "ForgeWorkshopTrimR12", "ForgeWorkshopEmberR12"]:
				if stage.stage_root.get_node_or_null(node_name) == null:
					_fail("missing r1.2 Forge node %s" % node_name)
					return

	_stage("regressions")
	stage.set_screen("home")
	await process_frame
	if not bool(game.call("_v91_frontend_finish_ready")):
		_fail("r1.2 frontend finish readiness failed")
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
