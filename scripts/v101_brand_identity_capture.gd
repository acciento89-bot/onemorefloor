extends SceneTree

# Fixed real-GL evidence for v1.74 product identity.
# Run under Xvfb/OpenGL3: Godot --headless uses a dummy renderer and cannot
# provide reliable SubViewport texture evidence.

const MainScene = preload("res://scenes/main.tscn")
const APP_ICON = preload("res://assets/art/app_icon_v174.svg")
const PORTRAIT_SIZE := Vector2i(720, 1280)
const ICON_SIZE := Vector2i(720, 720)
const CAPTURE_DIR := "res://artifacts/v174_brand_identity"

var viewport: SubViewport
var app

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	viewport = SubViewport.new()
	viewport.name = "V174BrandIdentityCaptureViewport"
	viewport.size = PORTRAIT_SIZE
	viewport.own_world_3d = true
	viewport.transparent_bg = false
	viewport.disable_3d = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)

	app = MainScene.instantiate()
	viewport.add_child(app)
	for _i in range(16):
		await process_frame
	if bool(app.get("tutorial_active")):
		app.call("_complete_tutorial")
		await process_frame
	app.call("_v51_route_home", false)
	app.set("home_overlay", "")
	app.set("settings_open", false)
	app.set("release_paused", false)
	app.set("tutorial_active", false)
	app.queue_redraw()
	if not await _save_frame("home_brand_v174"):
		return

	# Standalone icon proof at a square evaluation size.
	app.queue_free()
	await process_frame
	app = null
	viewport.size = ICON_SIZE
	var background := ColorRect.new()
	background.position = Vector2.ZERO
	background.size = Vector2(ICON_SIZE)
	background.color = Color("02040a")
	viewport.add_child(background)
	var icon_rect := TextureRect.new()
	icon_rect.position = Vector2.ZERO
	icon_rect.size = Vector2(ICON_SIZE)
	icon_rect.texture = APP_ICON
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	viewport.add_child(icon_rect)
	if not await _save_frame("app_icon_v174"):
		return

	print("v1.74 branding product identity visual capture passed")
	viewport.queue_free()
	await process_frame
	quit(0)

func _save_frame(stem: String) -> bool:
	print("V174_BRAND_CAPTURE_BEGIN:%s" % stem)
	for _i in range(4):
		await process_frame
	RenderingServer.force_draw(false, 0.0)
	var image := viewport.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty capture: %s" % stem)
		return false
	if image.get_width() != viewport.size.x or image.get_height() != viewport.size.y:
		_fail("invalid capture size for %s: %dx%d" % [stem, image.get_width(), image.get_height()])
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save %s" % stem)
		return false
	print("V174_BRAND_CAPTURE:%s:%s" % [stem, output])
	return true

func _fail(message: String) -> void:
	push_error("V174_BRAND_CAPTURE_FAIL:%s" % message)
	quit(1)
