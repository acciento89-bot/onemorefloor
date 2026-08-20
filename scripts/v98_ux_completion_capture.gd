extends SceneTree

# Fixed portrait evidence for the four UX surfaces changed by v1.71.

const MainScene = preload("res://scenes/main.tscn")
const CAPTURE_SIZE := Vector2i(720, 1280)
const CAPTURE_DIR := "res://artifacts/v171_ux_completion"

var viewport: SubViewport
var app

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	viewport = SubViewport.new()
	viewport.name = "V171UXCaptureViewport"
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
	if bool(app.get("tutorial_active")):
		app.call("_complete_tutorial")
		await process_frame

	# Settings from Home.
	app.call("_v51_route_home", false)
	app.set("settings_open", true)
	app.set("settings_return_to_pause", false)
	app.queue_redraw()
	if not await _save_frame("settings_v171"):
		return

	# Pause from a real run.
	app.set("settings_open", false)
	app.call("start_run")
	for _i in range(5):
		await process_frame
	app.set("release_paused", true)
	app.set("v95_abandon_confirm", false)
	app.queue_redraw()
	if not await _save_frame("pause_v171"):
		return

	# Destructive action confirmation.
	app.set("v95_abandon_confirm", true)
	app.queue_redraw()
	if not await _save_frame("abandon_confirm_v171"):
		return

	# Pre-run tutorial with explicit skip affordance.
	app.set("v95_abandon_confirm", false)
	app.set("release_paused", false)
	app.call("_v51_route_home", false)
	app.set("tutorial_active", true)
	app.set("tutorial_step", 0)
	app.queue_redraw()
	if not await _save_frame("tutorial_v171"):
		return

	print("v1.71 UX completion visual capture passed")
	app.queue_free()
	viewport.queue_free()
	await process_frame
	quit(0)

func _save_frame(stem: String) -> bool:
	for _i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := viewport.get_texture().get_image()
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
	print("V171_UX_CAPTURE:%s:%s" % [stem, output])
	return true

func _fail(message: String) -> void:
	push_error("V171_UX_CAPTURE_FAIL:%s" % message)
	quit(1)
