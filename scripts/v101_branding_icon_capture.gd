extends SceneTree

# ONE MORE FLOOR v1.74 — Product Identity candidate.
# Renders the shipping icon from the accepted production 3D Wanderer rather
# than maintaining a separate illustrated/cartoon character identity.

const ProductionWorld = preload("res://scripts/world3d_chamber_v170_realm_completion.gd")
const OUTPUT_DIR := "res://artifacts/v174_branding"
const ICON_SIZE := Vector2i(1024, 1024)

var viewport: SubViewport
var world

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))

	viewport = SubViewport.new()
	viewport.name = "V174BrandingIconViewport"
	viewport.size = ICON_SIZE
	viewport.own_world_3d = true
	viewport.transparent_bg = false
	viewport.disable_3d = false
	viewport.msaa_3d = Viewport.MSAA_2X
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_v_flip = false
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_LINEAR
	root.add_child(viewport)

	world = ProductionWorld.new()
	viewport.add_child(world)
	world.set_active(true)
	for _i in range(12):
		await process_frame

	if not world.has_method("production_realm_completion_ready") or not bool(world.call("production_realm_completion_ready")):
		_fail("production v1.70+ world not ready")
		return
	if world.player_root == null or not bool(world.actor_factory.wanderer_completion_v168_ready(world.player_root)):
		_fail("accepted v1.68 Wanderer not ready")
		return

	# Keep the actual gameplay actor at the real design center and use a restrained
	# combat pose so the blade remains a readable secondary silhouette.
	var player_pos := Vector2(360.0, 585.0)
	world.call("_capture_signature_state", [])
	world.previous_enemy_positions.clear()
	world.sync_runtime(player_pos, [], [], [], [], Vector2(0.22, -0.10), 28.20, 1.0, 0.0, 71)
	world.sync_runtime(player_pos, [], [], [], [], Vector2.ZERO, 28.24, 0.0, 0.0, 71)

	# The normal gameplay camera is deliberately wide. The icon uses that same
	# camera authority but crops it tightly for a recognisable Hood + armour + blade
	# product mark at App Store / home-screen sizes.
	world.camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	world.camera.size = 4.65
	world.camera.position = Vector3(0.0, 4.15, 4.55)
	world.camera.look_at(Vector3(0.0, 1.02, 0.0), Vector3.UP)
	world.camera.current = true

	# Additional portrait-only lighting; actor materials/geometry remain untouched.
	var rim := OmniLight3D.new()
	rim.name = "V174IconRim"
	rim.position = Vector3(1.75, 2.45, 1.20)
	rim.light_color = Color("8a63ff")
	rim.light_energy = 3.0
	rim.omni_range = 5.4
	rim.shadow_enabled = false
	rim.set_meta("branding_capture_only", true)
	world.add_child(rim)

	var face_key := OmniLight3D.new()
	face_key.name = "V174IconKey"
	face_key.position = Vector3(-1.55, 2.65, 2.15)
	face_key.light_color = Color("d9e2ff")
	face_key.light_energy = 2.35
	face_key.omni_range = 5.2
	face_key.shadow_enabled = false
	face_key.set_meta("branding_capture_only", true)
	world.add_child(face_key)

	for _i in range(8):
		await process_frame
	RenderingServer.force_draw(false)
	await process_frame

	var image := viewport.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty icon render")
		return
	if image.get_width() != ICON_SIZE.x or image.get_height() != ICON_SIZE.y:
		_fail("invalid icon render size: %dx%d" % [image.get_width(), image.get_height()])
		return

	# Shipping master: fully opaque square PNG, no text, no transparency.
	image.convert(Image.FORMAT_RGB8)
	if not _save(image, "app_icon_v174_1024.png"):
		return

	# Small-size proofs catch silhouettes that only work when viewed large.
	var preview180 := image.duplicate()
	preview180.resize(180, 180, Image.INTERPOLATE_LANCZOS)
	if not _save(preview180, "app_icon_v174_180.png"):
		return
	var preview60 := image.duplicate()
	preview60.resize(60, 60, Image.INTERPOLATE_LANCZOS)
	if not _save(preview60, "app_icon_v174_60.png"):
		return

	print("V174_BRANDING_ICON:production-wanderer:1024x1024:opaque")
	print("v1.74 branding icon visual capture passed")
	world.queue_free()
	viewport.queue_free()
	await process_frame
	quit(0)

func _save(image: Image, filename: String) -> bool:
	var path := "%s/%s" % [OUTPUT_DIR, filename]
	var result := image.save_png(ProjectSettings.globalize_path(path))
	if result != OK:
		_fail("could not save %s (%s)" % [path, result])
		return false
	print("V174_BRANDING_CAPTURE:%s:%dx%d" % [path, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V174_BRANDING_CAPTURE_FAIL:%s" % message)
	quit(1)
