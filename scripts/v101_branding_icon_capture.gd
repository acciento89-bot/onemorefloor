extends SceneTree

# ONE MORE FLOOR v1.74 r1.3 — Product Identity candidate.
# Uses the accepted Hero frontend stage as the source of truth for the shipping
# icon. This keeps the exact v1.68 gameplay Wanderer, its accepted frontend
# materials and the deliberate forward-facing Hero presentation.
# r1: rejected — chamber dominated the icon.
# r1.1: rejected — isolated gameplay pose still read too small/side-on.
# r1.2: rejected — correct Hero source, but crop was too tight and lost Hood/head.

const HeroStage = preload("res://scripts/menu3d_stage_v168_character_completion.gd")
const OUTPUT_DIR := "res://artifacts/v174_branding"
const ICON_SIZE := Vector2i(1024, 1024)

var viewport: SubViewport
var stage

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

	stage = HeroStage.new()
	viewport.add_child(stage)
	for _i in range(10):
		await process_frame
	stage.set_screen("hero")
	for _i in range(8):
		await process_frame

	if not stage.has_method("frontend_completion_ready") or not bool(stage.frontend_completion_ready()):
		_fail("accepted Hero frontend stage not ready")
		return
	if stage.actor_model == null or stage.actor_anchor == null:
		_fail("accepted Hero Wanderer missing")
		return
	if String(stage.actor_model.get_meta("wanderer_completion_v168", "")) != "1.68-wanderer-visual-completion-r1.1":
		_fail("Hero is not using accepted v1.68 Wanderer")
		return

	_hide_non_actor_geometry(stage.stage_root, stage.actor_model)

	stage.set_process(false)
	stage.actor_anchor.rotation = Vector3(0.0, PI, 0.0)
	stage.actor_anchor.position = Vector3(0.0, 2.96, 0.04)
	# r1.3 calibration: about 64% of the r1.2 projected size so the full Hood,
	# torso, boots and blade fit while the Wanderer still owns the square.
	stage.actor_model.scale = Vector3.ONE * 1.45
	stage.gameplay_actor_factory.animate_player(stage.actor_model, 7.5, 0.0, 0.0, 0.0)

	stage.camera.projection = Camera3D.PROJECTION_PERSPECTIVE
	stage.camera.fov = 34.0
	stage.camera.position = Vector3(0.0, 3.80, 5.55)
	stage.camera.look_at(Vector3(0.0, 3.75, 0.02), Vector3.UP)
	stage.camera.current = true

	_build_branding_backdrop()
	_build_branding_lights()

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

	image.convert(Image.FORMAT_RGB8)
	if not _save(image, "app_icon_v174_1024.png"):
		return

	var preview180 := image.duplicate()
	preview180.resize(180, 180, Image.INTERPOLATE_LANCZOS)
	if not _save(preview180, "app_icon_v174_180.png"):
		return
	var preview60 := image.duplicate()
	preview60.resize(60, 60, Image.INTERPOLATE_LANCZOS)
	if not _save(preview60, "app_icon_v174_60.png"):
		return

	print("V174_BRANDING_ICON:accepted-hero-wanderer-r1.3:1024x1024:opaque")
	print("v1.74 branding icon visual capture passed")
	stage.queue_free()
	viewport.queue_free()
	await process_frame
	quit(0)

func _hide_non_actor_geometry(node: Node, actor: Node3D) -> void:
	for child in node.get_children():
		if child == actor or actor.is_ancestor_of(child) or child.is_ancestor_of(actor):
			_hide_non_actor_geometry(child, actor)
			continue
		if child is MeshInstance3D:
			(child as MeshInstance3D).visible = false
		_hide_non_actor_geometry(child, actor)

func _build_branding_backdrop() -> void:
	var back_mat := StandardMaterial3D.new()
	back_mat.albedo_color = Color("070914")
	back_mat.metallic = 0.05
	back_mat.roughness = 0.82

	var back_mesh := BoxMesh.new()
	back_mesh.size = Vector3(5.8, 5.8, 0.10)
	var back := MeshInstance3D.new()
	back.name = "V174BrandingBackdrop"
	back.mesh = back_mesh
	back.material_override = back_mat
	back.position = Vector3(0.0, 3.75, -1.15)
	back.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	stage.add_child(back)

	var halo_mat := StandardMaterial3D.new()
	halo_mat.albedo_color = Color("21143d")
	halo_mat.emission_enabled = true
	halo_mat.emission = Color("6d46c8")
	halo_mat.emission_energy_multiplier = 1.10
	halo_mat.roughness = 0.70

	var halo_mesh := SphereMesh.new()
	halo_mesh.radius = 0.95
	halo_mesh.height = 1.90
	halo_mesh.radial_segments = 36
	halo_mesh.rings = 18
	var halo := MeshInstance3D.new()
	halo.name = "V174BrandingHalo"
	halo.mesh = halo_mesh
	halo.material_override = halo_mat
	halo.position = Vector3(0.0, 3.78, -0.96)
	halo.scale = Vector3(1.25, 1.25, 0.08)
	halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	stage.add_child(halo)

	var base_mat := StandardMaterial3D.new()
	base_mat.albedo_color = Color("161b29")
	base_mat.metallic = 0.38
	base_mat.roughness = 0.48
	var base_mesh := CylinderMesh.new()
	base_mesh.top_radius = 0.88
	base_mesh.bottom_radius = 1.02
	base_mesh.height = 0.12
	base_mesh.radial_segments = 36
	var base := MeshInstance3D.new()
	base.name = "V174BrandingBase"
	base.mesh = base_mesh
	base.material_override = base_mat
	base.position = Vector3(0.0, 2.82, 0.02)
	base.scale = Vector3(1.0, 1.0, 0.68)
	stage.add_child(base)

func _build_branding_lights() -> void:
	var key := OmniLight3D.new()
	key.name = "V174HeroKey"
	key.position = Vector3(-1.25, 4.35, 1.85)
	key.light_color = Color("e0d8ff")
	key.light_energy = 2.25
	key.omni_range = 4.6
	key.shadow_enabled = false
	stage.add_child(key)

	var rim := OmniLight3D.new()
	rim.name = "V174HeroRim"
	rim.position = Vector3(1.65, 3.70, 0.65)
	rim.light_color = Color("9c78dc")
	rim.light_energy = 1.55
	rim.omni_range = 3.5
	rim.shadow_enabled = false
	stage.add_child(rim)

	var warm := OmniLight3D.new()
	warm.name = "V174BladeWarmRim"
	warm.position = Vector3(1.20, 3.25, 2.10)
	warm.light_color = Color("e1ad66")
	warm.light_energy = 0.85
	warm.omni_range = 3.2
	warm.shadow_enabled = false
	stage.add_child(warm)

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
