class_name Menu3DStageV158
extends "res://scripts/menu3d_stage_v157.gd"

# ONE MORE FLOOR v1.58 — composition rescue.
# v1.57 proved that adding more procedural architecture made the portrait UI
# harder to read. This pass removes foreground blockers and keeps all large
# geometry behind the presentation plane.

const COMPOSITION_VERSION := "1.58"

func _build_world() -> void:
	super._build_world()
	camera.fov = 46.0
	if environment_node != null and environment_node.environment != null:
		var env := environment_node.environment
		env.ambient_light_energy = 0.42
		env.background_color = Color("050713")
	var moon := get_node_or_null("MoonKey") as DirectionalLight3D
	if moon != null:
		moon.light_energy = 0.92
	var rim := get_node_or_null("WarmRim") as DirectionalLight3D
	if rim != null:
		rim.light_energy = 0.24

func composition_ready() -> bool:
	return lookdev_ready() and camera != null and is_equal_approx(camera.fov, 46.0)

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["composition_version"] = COMPOSITION_VERSION
	data["composition_profile"] = "background-only-large-forms"
	data["camera_fov"] = camera.fov if camera != null else 0.0
	data["actor_y"] = actor_anchor.position.y if actor_anchor != null else -99.0
	return data

func _build_common_floor() -> void:
	# No angled side walls or near-camera slabs: all architecture sits behind z=-2.8.
	_make_box(stage_root, "FloorBase", Vector3(8.4, 0.16, 7.2), mat_stone, Vector3(0.0, -0.10, -0.35))
	_make_box(stage_root, "BackWall", Vector3(7.7, 5.5, 0.24), mat_stone, Vector3(0.0, 2.70, -3.45))
	_make_box(stage_root, "BackInset", Vector3(5.8, 4.4, 0.08), mat_stone_mid, Vector3(0.0, 2.50, -3.30))
	for x in [-3.15, 3.15]:
		_make_box(stage_root, "BackPier", Vector3(0.34, 5.1, 0.34), mat_stone_hi, Vector3(x, 2.52, -3.12))
		_make_box(stage_root, "BackPierCap", Vector3(0.62, 0.24, 0.48), mat_brass, Vector3(x, 5.04, -3.10))
	_make_box(stage_root, "FloorGuide", Vector3(4.8, 0.025, 0.055), mat_floor_trim, Vector3(0.0, 0.01, -1.65))

func _build_home_stage() -> void:
	# Distant gate facade. Nothing sits between camera and Wanderer.
	_make_box(stage_root, "HomeGateRecess", Vector3(4.7, 4.3, 0.20), mat_dark_metal, Vector3(0.0, 2.38, -3.12))
	_make_box(stage_root, "HomeGateVoid", Vector3(1.65, 2.85, 0.10), mat_void, Vector3(0.0, 1.72, -2.98))
	for x in [-1.42, 1.42]:
		_make_box(stage_root, "HomeGatePier", Vector3(0.46, 3.72, 0.30), mat_stone_hi, Vector3(x, 2.02, -2.90))
	_make_arch("HomeArch", Vector3(0.0, 3.08, -2.90), 1.42, mat_stone_hi, 9, 0.30, 0.28)
	for x in [-2.35, 2.35]:
		_make_box(stage_root, "HomeBanner", Vector3(0.48, 1.48, 0.04), mat_cloth, Vector3(x, 2.85, -2.88))
		_make_box(stage_root, "HomeSigil", Vector3(0.18, 0.30, 0.06), mat_brass, Vector3(x, 2.88, -2.82), Vector3(0.0, 0.0, deg_to_rad(45.0)))
		_add_torch(Vector3(x, 1.72, -2.65), Color("e99352"), 0.65)
	_make_cylinder(stage_root, "HomeDais", 0.82, 0.16, mat_dark_metal, Vector3(0.0, 0.08, -0.05))
	_add_actor(Vector3(0.0, 0.78, -0.05), 0.78)
	_add_character_key(Vector3(0.0, 2.15, 2.25), Color("cec4ff"), 0.82, 4.5)

func _build_hero_stage() -> void:
	# One clean showcase bay with the actor lifted into the open area above the stats card.
	_make_box(stage_root, "HeroBay", Vector3(4.8, 4.25, 0.16), mat_dark_metal, Vector3(0.0, 2.38, -3.08))
	_make_rune_ring(Vector3(0.0, 2.58, -2.88), 1.36, 14, mat_purple)
	for x in [-2.20, 2.20]:
		_make_box(stage_root, "HeroRearColumn", Vector3(0.38, 3.65, 0.30), mat_stone_hi, Vector3(x, 2.05, -2.90))
		_add_torch(Vector3(x, 3.18, -2.62), Color("8a63d4"), 0.52)
	_make_cylinder(stage_root, "HeroDais", 0.94, 0.18, mat_dark_metal, Vector3(0.0, 0.10, -0.02))
	_make_cylinder(stage_root, "HeroDaisTrim", 0.80, 0.035, mat_brass, Vector3(0.0, 0.21, -0.02))
	_add_actor(Vector3(0.0, 0.98, -0.02), 0.82)
	_add_character_key(Vector3(0.0, 2.55, 2.35), Color("ddd3ff"), 1.08, 4.8)

func _build_forge_stage() -> void:
	# Forge props live on the back wall because the lower half is intentionally UI territory.
	_make_box(stage_root, "ForgeRearBay", Vector3(5.9, 4.3, 0.18), mat_stone_mid, Vector3(0.0, 2.40, -3.08))
	_make_box(stage_root, "ForgeHearth", Vector3(1.72, 1.82, 0.36), mat_stone_hi, Vector3(-1.30, 2.02, -2.82))
	_make_box(stage_root, "ForgeMouth", Vector3(1.04, 0.92, 0.08), mat_ember, Vector3(-1.30, 1.80, -2.56))
	_make_box(stage_root, "ForgeHood", Vector3(1.94, 0.54, 0.42), mat_dark_metal, Vector3(-1.30, 3.24, -2.80))
	_add_torch(Vector3(-1.30, 2.00, -2.40), Color("ff7433"), 0.72)

	_make_box(stage_root, "ForgeRack", Vector3(2.08, 2.42, 0.14), mat_dark_metal, Vector3(1.70, 2.22, -2.90))
	for i in range(4):
		var x := 1.18 + float(i) * 0.34
		_make_box(stage_root, "ForgeWeapon%02d" % i, Vector3(0.06, 1.36, 0.06), mat_brass if i % 2 == 0 else mat_stone_hi, Vector3(x, 2.28, -2.68), Vector3(0.0, 0.0, -0.16 + float(i) * 0.10))
	_make_box(stage_root, "ForgeAnvilTop", Vector3(1.08, 0.20, 0.42), mat_stone_hi, Vector3(0.10, 1.28, -2.54))
	_make_box(stage_root, "ForgeAnvilStem", Vector3(0.42, 0.76, 0.34), mat_dark_metal, Vector3(0.10, 0.86, -2.62))
	_add_torch(Vector3(2.55, 3.05, -2.52), Color("e8a05a"), 0.42)

func _camera_position_for(screen: String) -> Vector3:
	match screen:
		"home": return Vector3(0.0, 2.80, 10.40)
		"hero": return Vector3(0.0, 2.85, 9.75)
		"forge": return Vector3(0.0, 2.80, 10.60)
		"vault": return Vector3(0.0, 2.90, 9.60)
		_: return Vector3(0.0, 3.00, 9.80)

func _camera_target_for(screen: String) -> Vector3:
	match screen:
		"home": return Vector3(0.0, 2.08, -0.70)
		"hero": return Vector3(0.0, 2.18, -0.20)
		"forge": return Vector3(0.0, 2.18, -1.80)
		_: return Vector3(0.0, 2.00, -0.80)
