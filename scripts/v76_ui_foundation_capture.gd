extends SceneTree

const CAPTURE_SCREENS := ["home", "hero", "forge", "talents"]
const CAPTURE_DIR := "res://artifacts/v162"

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
	for _i in range(10):
		await process_frame

	game.tutorial_active = false
	game.settings_open = false
	game.release_paused = false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))

	for screen in CAPTURE_SCREENS:
		if screen == "home":
			if not bool(game.call("_v51_route_home", false)):
				_fail("could not route home")
				return
		else:
			if not bool(game.call("_v51_route_to", screen, false)):
				_fail("could not route to %s" % screen)
				return
		if game.has_method("_v70_sync_menu_3d"):
			game.call("_v70_sync_menu_3d", true)
		game.queue_redraw()
		for _i in range(14):
			await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		if image == null or image.is_empty():
			_fail("empty image for %s" % screen)
			return
		var output := "%s/%s.png" % [CAPTURE_DIR, screen]
		var result := image.save_png(ProjectSettings.globalize_path(output))
		if result != OK:
			_fail("could not save %s (%s)" % [output, result])
			return
		print("V76_UI_CAPTURE:%s:%s:%dx%d" % [screen, output, image.get_width(), image.get_height()])

	print("v1.62 UI foundation visual capture passed")
	game.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V76_UI_CAPTURE_FAIL:%s" % message)
	quit(1)
