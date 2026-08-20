extends SceneTree

# ONE MORE FLOOR v1.74 r1.1 — Product Identity candidate.
# Renders the shipping icon from the accepted production 3D Wanderer rather
# than maintaining a separate illustrated/cartoon character identity.
# r1 was rejected because the gameplay chamber dominated at small icon sizes;
# r1.1 keeps the exact actor but isolates and crops it as the product mark.

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

	# Use the real gameplay actor and its real authored pose authority.
	var player_pos := Vector2(360.0, 585.0)
	world.call("_capture_signature_state", [])
	world.previous_enemy_positions.clear()
	world.sync_runtime(player_pos, [], [], [], [], Vector2(0.24, -0.12), 28.20, 1.0, 0.0, 71)
	world.sync_runtime(player_pos, [], [], [], [], Vector2.ZERO, 28.24, 0.0, 0.0, 71)

	# r1 review: the chamber read well but the actor became a dot at 180/60 px.
	# Hide only non-player geometry in this capture scene; production world files
	# remain untouched. Lights, camera and WorldEnvironment remain active.
	_hide_non_player_geometry(world, world.player_root)
	_build_branding_backdrop()

	# Capture-only scale and crop. This never touches the production asset data.
	world.player_root.scale = Vector3.ONE * 3.0
	world.camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	world.camera.size = 2.10
	world.camera.position = Vector3(0.0, 2.55, 4.80)
	world.camera.look_at(Vector3(0.0, 0.68, 0.0), Vector3.UP)
	world.camera.current = true

	# Controlled portrait key/rim lights make Hood, chest plate and blade separate
	# at home-screen size while preserving the accepted actor materials.
	var rim := OmniLight3D.new()
	rim.name = "V174IconRim"
	rim.position = Vector3(1.55, 2.10, 1.30)
	rim.light_color = Color("8a63ff")
	rim.light_energy = 4.25
	rim.omni_range = 5.2
	rim.shadow_enabled = false
	rim.set_meta("branding_capture_only", true)
	world.add_child(rim)

	var face_key := OmniLight3D.new()
	face_key.name = "V174IconKey"
	face_key.position = Vector3(-1.35, 2.35, 2.45)
	face_key.light_color = Color("e2e8ff")
	face_key.light_energy = 3.35
	face_key.omni_range = 5.0
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

	print("V174_BRANDING_ICON:production-wanderer-r1.1:1024x1024:opaque")
	print("v1.74 branding icon visual capture passed")
	world.queue_free()
	viewport.queue_free()
	await process_frame
	quit(0)

func _hide_non_player_geometry(node: Node, player: Node3D) -> void:
	for child in node.get_children():
		if child == player or player.is_ancestor_of(child):
			continue
		if child is MeshInstance3D:
			(child as MeshInstance3D).visible = false
		_hide_non_player_geometry(child, player)

func _build_branding_backdrop() -> void:
	var backdrop_mat := StandardMaterial3D.new()
	backdrop_mat.albedo_color = Color("090b16")
	backdrop_mat.metallic = 0.10
	backdrop_mat.roughness = 0.78

	var backdrop_mesh := BoxMesh.new()
	backdrop_mesh.size = Vector3(3.20, 3.20, 0.12)
	var backdrop := MeshInstance3D.new()
	backdrop.name = "V174IconBackdrop"
	backdrop.mesh = backdrop_mesh
	backdrop.material_override = backdrop_mat
	backdrop.position = Vector3(0.0, 0.72, -1.10)
	backdrop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	backdrop.set_meta("branding_capture_only", true)
	world.add_child(backdrop)

	var halo_mat := StandardMaterial3D.new()
	halo_mat.albedo_color = Color("251944")
	halo_mat.emission_enabled = true
	halo_mat.emission = Color("6745be")
	halo_mat.emission_energy_multiplier = 1.35
	halo_mat.metallic = 0.0
	halo_mat.roughness = 0.66

	var halo_mesh := SphereMesh.new()
	halo_mesh.radius = 0.52
	halo_mesh.height = 1.04
	halo_mesh.radial_segments = 32
	halo_mesh.rings = 16
	var halo := MeshInstance3D.new()
	halo.name = "V174IconHalo"
	halo.mesh = halo_mesh
	halo.material_override = halo_mat
	halo.position = Vector3(0.0, 0.88, -0.91)
	halo.scale = Vector3(1.30, 1.30, 0.10)
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	halo.set_meta("branding_capture_only", true)
	world.add_child(halo)

	var base_mat := StandardMaterial3D.new()
	base_mat.albedo_color = Color("171b2c")
	base_mat.metallic = 0.34
	base_mat.roughness = 0.54
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.72
	base_mesh.bottom_radius = 0.84
	base_mesh.height = 0.10
	base_mesh.radial_segments = 32
	var base := MeshInstance3D.new()
	base.name = "V174IconBase"
	base.mesh = base_mesh
	base.material_override = base_mat
	base.position = Vector3(0.0, -0.11, 0.0)
	base.scale = Vector3(1.0, 1.0, 0.66)
	base.set_meta("branding_capture_only", true)
	world.add_child(base)

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
