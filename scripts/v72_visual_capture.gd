extends SceneTree

const CAPTURE_SCREENS := ["home", "hero", "forge"]
const CAPTURE_DIR := "res://artifacts/v158"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		push_error("V72_CAPTURE_FAIL: main scene did not load")
		quit(1)
		return

	var game = packed.instantiate()
	root.add_child(game)
	for _i in range(6):
		await process_frame

	# Visual QA must capture the actual menu composition, not the fresh-install
	# tutorial modal. This mutates only the ephemeral CI instance.
	game.set("tutorial_active", false)
	game.set("settings_open", false)
	game.set("release_paused", false)
	game.queue_redraw()
	await process_frame

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))

	for screen in CAPTURE_SCREENS:
		if not bool(game.call("_v51_route_to", screen, false)):
			push_error("V72_CAPTURE_FAIL: could not route to %s" % screen)
			quit(1)
			return
		game.call("_v70_sync_menu_3d", true)
		game.queue_redraw()
		for _i in range(8):
			await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		if image == null or image.is_empty():
			push_error("V72_CAPTURE_FAIL: empty viewport image for %s" % screen)
			quit(1)
			return
		var output := "%s/%s.png" % [CAPTURE_DIR, screen]
		var result := image.save_png(ProjectSettings.globalize_path(output))
		if result != OK:
			push_error("V72_CAPTURE_FAIL: could not save %s (%s)" % [output, result])
			quit(1)
			return
		print("V72_CAPTURE:%s:%s:%dx%d" % [screen, output, image.get_width(), image.get_height()])

	print("v1.58 portrait visual capture passed")
	game.queue_free()
	await process_frame
	quit(0)
