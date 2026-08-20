extends SceneTree

# Fixed portrait evidence for the v1.73 run-flow presentation surfaces.

const CAPTURE_DIR := "res://artifacts/v173_run_flow"
const STATE_RUNNING := 5
const STATE_DECISION := 7
const STATE_GAME_OVER := 8

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene failed to load")
		return
	var app = packed.instantiate()
	root.add_child(app)
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
	if not await _capture(app, "decision_v173"):
		return

	# Game Over — deep-run setback visible without mutating progression data.
	app.run.floor_no = 63
	app.run.run_coins = 812
	app.current_room = {"area":"VOID CITADEL", "type":"COMBAT", "reward_bonus":0, "hazard":"void_crossfire"}
	app.set("v27_last_setback", 5)
	app.set("v27_resume_floor", 58)
	app.state = STATE_GAME_OVER
	if not await _capture(app, "game_over_v173"):
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
	if not await _capture(app, "floor_transition_v173"):
		return

	# Real Floor-30 boss spawn with the Hollow King intro timer.
	app.call("start_run")
	for _i in range(4):
		await process_frame
	app.run.floor_no = 30
	app.call("spawn_floor")
	app.state = STATE_RUNNING
	app.set("hollow_intro", 2.0)
	if not await _capture(app, "boss_intro_v173"):
		return

	print("v1.73 run flow visual capture passed")
	app.queue_free()
	await process_frame
	quit(0)

func _capture(app: Node, label: String) -> bool:
	if app.has_method("_v70_sync_menu_3d"):
		app.call("_v70_sync_menu_3d", true)
	app.queue_redraw()
	for _i in range(12):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty capture: %s" % label)
		return false
	if image.get_width() != 720 or image.get_height() != 1280:
		_fail("invalid capture size for %s: %dx%d" % [label, image.get_width(), image.get_height()])
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, label]
	var result := image.save_png(ProjectSettings.globalize_path(output))
	if result != OK:
		_fail("could not save %s (%s)" % [output, result])
		return false
	print("V173_RUN_FLOW_CAPTURE:%s:%s" % [label, output])
	return true

func _fail(message: String) -> void:
	push_error("V173_RUN_FLOW_CAPTURE_FAIL:%s" % message)
	quit(1)
