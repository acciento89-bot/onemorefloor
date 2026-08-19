extends SceneTree

const CAPTURE_DIR := "res://artifacts/v162_runtime"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	for _i in range(12):
		await process_frame

	game.tutorial_active = false
	game.settings_open = false
	game.release_paused = false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))

	# SETTINGS — actual Home modal state and existing settings values.
	game.call("_v51_route_home", false)
	game.settings_open = true
	game.settings_return_to_pause = false
	await _capture(game, "settings")
	game.settings_open = false

	# Initialize the real run model once; runtime-only states below reuse it.
	game.start_run()
	for _i in range(8):
		await process_frame

	# PAUSE — actual run pause overlay.
	game.state = 1 # State.RUNNING
	game.release_paused = true
	await _capture(game, "pause")
	game.release_paused = false

	# UPGRADE — real rolled choices through the current run-upgrade renderer.
	game.call("roll_upgrade_options")
	game.state = 2 # State.UPGRADE
	await _capture(game, "upgrade")

	# DECISION — post-upgrade risk/cash-out screen with the current run model.
	game.room_event_active = false
	game.state = 3 # State.DECISION
	await _capture(game, "decision")

	# GAME OVER — current result screen. Keep a deterministic deep-enough run
	# context so checkpoint/setback presentation is visible when that layer exists.
	if game.run != null:
		game.run.floor_no = maxi(12, int(game.run.floor_no))
		game.run.run_coins = maxi(145, int(game.run.run_coins))
	game.set("v27_last_setback", 5)
	game.set("v27_resume_floor", 7)
	game.state = 4 # State.GAME_OVER
	await _capture(game, "game_over")

	print("v1.62 runtime-state UI diagnostic capture passed")
	game.queue_free()
	await process_frame
	quit(0)

func _capture(game: Node, label: String) -> void:
	if game.has_method("_v70_sync_menu_3d"):
		game.call("_v70_sync_menu_3d", true)
	game.queue_redraw()
	for _i in range(14):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty runtime-state image: %s" % label)
		return
	var output := "%s/%s.png" % [CAPTURE_DIR, label]
	var result := image.save_png(ProjectSettings.globalize_path(output))
	if result != OK:
		_fail("could not save %s (%s)" % [output, result])
		return
	print("V80_UI_CAPTURE:%s:%s:%dx%d" % [label, output, image.get_width(), image.get_height()])

func _fail(message: String) -> void:
	push_error("V80_UI_CAPTURE_FAIL:%s" % message)
	quit(1)
