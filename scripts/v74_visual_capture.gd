extends SceneTree

const CAPTURE_SCREENS := ["talents", "vault", "missions", "pass", "store"]
const CAPTURE_DIR := "res://artifacts/v160"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		push_error("V74_CAPTURE_FAIL: main scene did not load")
		quit(1)
		return
	var game = packed.instantiate()
	root.add_child(game)
	for _i in range(8):
		await process_frame
	game.tutorial_active = false
	game.settings_open = false
	game.release_paused = false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))

	for screen in CAPTURE_SCREENS:
		if not bool(game.call("_v51_route_to", screen, false)):
			push_error("V74_CAPTURE_FAIL: could not route to %s" % screen)
			quit(1)
			return
		game.call("_v70_sync_menu_3d", true)
		game.queue_redraw()
		for _i in range(12):
			await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		if image == null or image.is_empty():
			push_error("V74_CAPTURE_FAIL: empty image for %s" % screen)
			quit(1)
			return
		var output := "%s/%s.png" % [CAPTURE_DIR, screen]
		if image.save_png(ProjectSettings.globalize_path(output)) != OK:
			push_error("V74_CAPTURE_FAIL: could not save %s" % output)
			quit(1)
			return
		print("V74_CAPTURE:%s:%s:%dx%d" % [screen, output, image.get_width(), image.get_height()])

	print("v1.60 portrait meta environment visual capture passed")
	game.queue_free()
	await process_frame
	quit(0)
