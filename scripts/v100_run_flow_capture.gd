extends SceneTree

# Fixed portrait evidence for the v1.73 run-flow presentation surfaces.
# Uses deterministic headless redraws; no frame_post_draw signal dependency.

const MainScene = preload("res://scenes/main.tscn")
const CAPTURE_SIZE := Vector2i(720, 1280)
const CAPTURE_DIR := "res://artifacts/v173_run_flow"
const STATE_RUNNING := 5
const STATE_DECISION := 7
const STATE_GAME_OVER := 8

var viewport: SubViewport
var app

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	viewport = SubViewport.new()
	viewport.name = "V173RunFlowCaptureViewport"
	viewport.size = CAPTURE_SIZE
	viewport.own_world_3d = true
	viewport.transparent_bg = false
	viewport.disable_3d = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)

	app = MainScene.instantiate()
	viewport.add_child(app)
	for _i in range(14):
		await process_frame

	app.set("tutorial_active", false)
	app.set("settings_open", false)
	app.set("release_paused", false)
	app.call("start_run")
	for _i in range(6):
		await process_frame

	# Decision — deterministic mid-run risk/reward state.
	app.run.floor_no = 18
	app.run.run_coins = 385
	app.run.hp = minf(app.run.max_hp, app.run.max_hp * 0.63)
	app.current_room = {"area":"CRYPT", "type":"COMBAT", "reward_bonus":0, "hazard":"none"}
	app.state = STATE_DECISION
	app.queue_redraw()
	if not await _save_frame("decision_v173"):
		return

	# Game Over — deep-run setback visible without mutating progression data.
	app.run.floor_no = 63
	app.run.run_coins = 812
	app.current_room = {"area":"VOID CITADEL", "type":"COMBAT", "reward_bonus":0, "hazard":"void_crossfire"}
	app.set("v27_last_setback", 5)
	app.set("v27_resume_floor", 58)
	app.state = STATE_GAME_OVER
	app.queue_redraw()
	if not await _save_frame("game_over_v173"):
		return

	# Normal floor/realm transition over the accepted 3D world.
	app.state = STATE_RUNNING
	app.run.floor_no = 21
	app.current_room = {"area":"FORGOTTEN CASTLE", "type":"COMBAT", "reward_bonus":0, "hazard":"falling_masonry"}
	app.set("room_transition", 0.72)
	app.set("floor_banner", 1.20)
	app.set("boss_intro", 0.0)
	app.set("keeper_intro", 0.0)
	app.set("hollow_intro", 0.0)
	app.set("v23_miniboss_intro", 0.0)
	app.set("null_intro", 0.0)
	app.set("v28_boss_intro", 0.0)
	app.set("v28_realm_flash", 0.0)
	app.queue_redraw()
	if not await _save_frame("floor_transition_v173"):
		return

	# Real Floor-30 boss spawn with the Hollow King intro timer.
	app.call("start_run")
	for _i in range(4):
		await process_frame
	app.run.floor_no = 30
	app.call("spawn_floor")
	app.state = STATE_RUNNING
	app.set("hollow_intro", 2.0)
	app.queue_redraw()
	if not await _save_frame("boss_intro_v173"):
		return

	print("v1.73 run flow visual capture passed")
	app.queue_free()
	viewport.queue_free()
	await process_frame
	quit(0)

func _save_frame(stem: String) -> bool:
	print("V173_RUN_FLOW_CAPTURE_BEGIN:%s" % stem)
	for _i in range(3):
		await process_frame
	print("V173_RUN_FLOW_CAPTURE_FRAMES_READY:%s" % stem)
	RenderingServer.force_draw(false, 0.0)
	print("V173_RUN_FLOW_CAPTURE_FORCE_DRAWN:%s" % stem)
	var image := viewport.get_texture().get_image()
	print("V173_RUN_FLOW_CAPTURE_TEXTURE_READ:%s" % stem)
	if image == null or image.is_empty():
		_fail("empty capture: %s" % stem)
		return false
	if image.get_width() != CAPTURE_SIZE.x or image.get_height() != CAPTURE_SIZE.y:
		_fail("invalid capture size for %s: %dx%d" % [stem, image.get_width(), image.get_height()])
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save %s" % stem)
		return false
	print("V173_RUN_FLOW_CAPTURE:%s:%s" % [stem, output])
	return true

func _fail(message: String) -> void:
	push_error("V173_RUN_FLOW_CAPTURE_FAIL:%s" % message)
	quit(1)
