class_name Menu3DStageV157
extends "res://scripts/menu3d_stage_v156.gd"

# ONE MORE FLOOR v1.57 — production lookdev pass.
# v1.56 proved the shared 3D menu architecture. This layer replaces the first
# blockout look with tighter composition, segmented architecture, restrained
# practical lights and a readable imported Wanderer showcase.

const LOOKDEV_VERSION := "1.57"

var mat_stone_mid: StandardMaterial3D
var mat_brass: StandardMaterial3D
var mat_cloth: StandardMaterial3D
var mat_floor_trim: StandardMaterial3D
var mat_ember: StandardMaterial3D

func _build_materials() -> void:
	super._build_materials()
	# Pull the base palette away from neon/blockout values.
	mat_void.albedo_color = Color("03050b")
	mat_stone.albedo_color = Color("121722")
	mat_stone.roughness = 0.90
	mat_stone_hi.albedo_color = Color("283044")
	mat_stone_hi.metallic = 0.08
	mat_stone_hi.roughness = 0.72
	mat_gold.albedo_color = Color("8f6728")
	mat_gold.metallic = 0.68
	mat_gold.roughness = 0.36
	mat_gold.emission_enabled = false
	mat_purple.albedo_color = Color("35205f")
	mat_purple.emission_energy_multiplier = 0.28
	mat_blue.emission_energy_multiplier = 0.22
	mat_green.emission_energy_multiplier = 0.20
	mat_orange.albedo_color = Color("612c18")
	mat_orange.emission_energy_multiplier = 0.52
	mat_red.albedo_color = Color("4a1628")
	mat_red.emission_energy_multiplier = 0.16

	mat_stone_mid = _material(Color("1c2231"), 0.06, 0.82)
	mat_brass = _material(Color("8d5e22"), 0.76, 0.31)
	mat_cloth = _material(Color("611a32"), 0.02, 0.78)
	mat_floor_trim = _material(Color("292445"), 0.18, 0.48, Color("6f42b7"), 0.08)
	mat_ember = _material(Color("a7431f"), 0.0, 0.42, Color("ff6f2c"), 0.65)

func _build_world() -> void:
	super._build_world()
	camera.fov = 36.0
	if environment_node != null and environment_node.environment != null:
		var env := environment_node.environment
		env.background_color = Color("040611")
		env.ambient_light_color = Color("3c3652")
		env.ambient_light_energy = 0.31
	var moon := get_node_or_null("MoonKey") as DirectionalLight3D
	if moon != null:
		moon.light_color = Color("8e92c8")
		moon.light_energy = 0.78
	var rim := get_node_or_null("WarmRim") as DirectionalLight3D
	if rim != null:
		rim.light_color = Color("dca95c")
		rim.light_energy = 0.34

func lookdev_ready() -> bool:
	return stage_ready() and mat_stone_mid != null and mat_brass != null and camera != null and is_equal_approx(camera.fov, 36.0)

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["lookdev_version"] = LOOKDEV_VERSION
	data["lighting_profile"] = "restrained-practicals"
	data["geometry_profile"] = "segmented-architectural"
	data["camera_fov"] = camera.fov if camera != null else 0.0
	data["actor_scale"] = actor_model.scale.x if actor_model != null else 0.0
	return data

func _build_common_floor() -> void:
	# Layered floor + segmented walls give the stage depth instead of one giant slab.
	_make_box(stage_root, "FloorBase", Vector3(10.6, 0.18, 9.2), mat_stone, Vector3(0.0, -0.12, 0.25))
	_make_box(stage_root, "FloorInset", Vector3(7.3, 0.035, 6.4), mat_stone_mid, Vector3(0.0, -0.01, -0.05))
	_make_box(stage_root, "FloorTrimL", Vector3(0.055, 0.025, 6.0), mat_floor_trim, Vector3(-2.65, 0.025, 0.0))
	_make_box(stage_root, "FloorTrimR", Vector3(0.055, 0.025, 6.0), mat_floor_trim, Vector3(2.65, 0.025, 0.0))
	_make_box(stage_root, "FloorTrimC", Vector3(5.3, 0.025, 0.055), mat_brass, Vector3(0.0, 0.03, -1.85))

	for i in range(5):
		var x := -3.6 + float(i) * 1.8
		_make_box(stage_root, "BackPanel%02d" % i, Vector3(1.55, 5.6, 0.28), mat_stone if i % 2 == 0 else mat_stone_mid, Vector3(x, 2.75, -3.15))
		_make_box(stage_root, "BackPilaster%02d" % i, Vector3(0.18, 5.9, 0.42), mat_stone_hi, Vector3(x - 0.82, 2.88, -3.02))

	for side in [-1.0, 1.0]:
		_make_box(stage_root, "SideWall", Vector3(2.0, 5.7, 0.28), mat_stone, Vector3(side * 4.05, 2.75, -0.70), Vector3(0.0, deg_to_rad(side * 19.0), 0.0))
		_make_box(stage_root, "SidePier", Vector3(0.46, 5.9, 0.52), mat_stone_hi, Vector3(side * 3.78, 2.88, -2.45))

	_make_box(stage_root, "CeilingBeam", Vector3(8.0, 0.28, 0.45), mat_dark_metal, Vector3(0.0, 5.70, -2.70))

func _build_home_stage() -> void:
	# Grand gate hall instead of an oversized flat castle silhouette.
	_make_box(stage_root, "GateRecess", Vector3(5.7, 4.8, 0.58), mat_stone_mid, Vector3(0.0, 2.55, -2.62))
	_make_box(stage_root, "GateVoid", Vector3(2.10, 3.25, 0.18), mat_void, Vector3(0.0, 1.72, -2.29))
	for x in [-1.55, 1.55]:
		_make_box(stage_root, "GatePier", Vector3(0.78, 4.25, 0.72), mat_stone_hi, Vector3(x, 2.05, -2.12))
		_make_box(stage_root, "GatePierFoot", Vector3(1.02, 0.34, 0.96), mat_brass, Vector3(x, 0.17, -2.00))
	_make_arch("GateArch", Vector3(0.0, 3.30, -2.12), 1.55, mat_stone_hi, 11, 0.42, 0.58)

	for x in [-2.55, 2.55]:
		_make_box(stage_root, "BannerRail", Vector3(0.95, 0.10, 0.12), mat_brass, Vector3(x, 4.05, -2.00))
		_make_box(stage_root, "Banner", Vector3(0.70, 1.85, 0.06), mat_cloth, Vector3(x, 3.05, -1.94))
		_make_box(stage_root, "BannerSigil", Vector3(0.25, 0.42, 0.08), mat_brass, Vector3(x, 3.08, -1.88), Vector3(0.0, 0.0, deg_to_rad(45.0)))

	_make_box(stage_root, "Forecourt", Vector3(4.9, 0.26, 4.9), mat_stone_mid, Vector3(0.0, 0.05, 0.25))
	_make_box(stage_root, "ForecourtStep", Vector3(3.5, 0.24, 1.10), mat_stone_hi, Vector3(0.0, 0.18, -0.72))
	for x in [-2.72, 2.72]:
		_add_torch(Vector3(x, 1.70, -1.68), Color("ff9a47"), 1.25)

	_add_actor(Vector3(0.0, 0.30, 0.72), 0.92)
	_add_character_key(Vector3(0.0, 2.15, 2.25), Color("c8b7ff"), 0.72, 4.2)

func _build_hero_stage() -> void:
	# Character-first alcove: the actor stays above the stats card and does not fill the screen.
	_make_box(stage_root, "HeroAlcove", Vector3(4.9, 4.8, 0.52), mat_stone_mid, Vector3(0.0, 2.58, -2.64))
	_make_arch("HeroArch", Vector3(0.0, 3.08, -2.22), 1.72, mat_stone_hi, 13, 0.36, 0.52)
	for x in [-2.05, 2.05]:
		_make_box(stage_root, "HeroColumn", Vector3(0.55, 4.35, 0.62), mat_stone_hi, Vector3(x, 2.10, -2.12))
		_make_box(stage_root, "HeroColumnBase", Vector3(0.78, 0.32, 0.82), mat_brass, Vector3(x, 0.16, -2.05))

	_make_cylinder(stage_root, "HeroDais", 1.18, 0.28, mat_dark_metal, Vector3(0.0, 0.14, 0.30))
	_make_cylinder(stage_root, "HeroDaisTrim", 1.02, 0.055, mat_brass, Vector3(0.0, 0.31, 0.30))
	_make_rune_ring(Vector3(0.0, 2.30, -2.20), 1.22, 16, mat_purple)
	_add_torch(Vector3(-2.05, 3.18, -1.70), Color("8e60d9"), 0.82)
	_add_torch(Vector3(2.05, 3.18, -1.70), Color("8e60d9"), 0.82)
	_add_actor(Vector3(0.0, 0.38, 0.30), 1.04)
	_add_character_key(Vector3(0.0, 2.35, 2.05), Color("d6c7ff"), 0.92, 4.0)

func _build_forge_stage() -> void:
	# Compact, centered workshop so the furnace/anvil stay inside the portrait frame.
	_make_box(stage_root, "ForgeBack", Vector3(6.8, 4.8, 0.52), mat_stone_mid, Vector3(0.0, 2.52, -2.66))
	_make_box(stage_root, "ForgeChimney", Vector3(1.55, 3.55, 0.82), mat_dark_metal, Vector3(-2.10, 3.28, -2.00))
	_make_box(stage_root, "ForgeBody", Vector3(2.05, 2.35, 1.10), mat_stone_hi, Vector3(-2.10, 1.25, -1.75))
	_make_arch("FurnaceArch", Vector3(-2.10, 1.55, -1.10), 0.58, mat_dark_metal, 7, 0.24, 0.24)
	_make_box(stage_root, "FurnaceMouth", Vector3(0.92, 0.90, 0.12), mat_ember, Vector3(-2.10, 0.86, -1.05))
	_add_torch(Vector3(-2.10, 1.02, -0.88), Color("ff6f32"), 1.05)

	# Readable anvil silhouette: base, waist, top and stepped horn.
	_make_box(stage_root, "AnvilBase", Vector3(1.12, 0.22, 0.72), mat_dark_metal, Vector3(0.45, 0.12, -0.10))
	_make_box(stage_root, "AnvilWaist", Vector3(0.55, 0.78, 0.50), mat_dark_metal, Vector3(0.45, 0.56, -0.10))
	_make_box(stage_root, "AnvilTop", Vector3(1.35, 0.30, 0.62), mat_stone_hi, Vector3(0.55, 1.05, -0.10))
	_make_box(stage_root, "AnvilHornA", Vector3(0.72, 0.22, 0.46), mat_stone_hi, Vector3(1.40, 1.05, -0.10))
	_make_box(stage_root, "AnvilHornB", Vector3(0.42, 0.16, 0.30), mat_stone_hi, Vector3(1.90, 1.05, -0.10))

	_make_box(stage_root, "WeaponRack", Vector3(2.05, 2.25, 0.25), mat_dark_metal, Vector3(2.55, 1.62, -2.05))
	for i in range(4):
		var x := 2.05 + float(i) * 0.34
		_make_box(stage_root, "Weapon%02d" % i, Vector3(0.07, 1.28, 0.07), mat_brass if i % 2 == 0 else mat_stone_hi, Vector3(x, 1.72, -1.84), Vector3(0.0, 0.0, -0.14 + float(i) * 0.08))
	_add_torch(Vector3(2.95, 3.20, -1.72), Color("e99445"), 0.85)

func _add_torch(pos: Vector3, color: Color, energy: float) -> void:
	# v1.56's 0.16m emissive balls read as white lamps. Use a compact two-part flame.
	_make_box(stage_root, "TorchBracket", Vector3(0.09, 0.34, 0.09), mat_dark_metal, pos + Vector3(0.0, -0.18, 0.0))
	var core_mat := _material(Color("ffb45a"), 0.0, 0.42, Color("ff7b2e"), 1.05)
	var tip_mat := _material(Color(color, 1.0), 0.0, 0.48, color, 0.72)
	_make_sphere(stage_root, "FlameCore", 0.065, core_mat, pos)
	_make_sphere(stage_root, "FlameTip", 0.045, tip_mat, pos + Vector3(0.0, 0.085, 0.0))
	var light := OmniLight3D.new()
	light.name = "TorchLight"
	light.position = pos + Vector3(0.0, 0.04, 0.0)
	light.light_color = color
	light.light_energy = energy
	light.omni_range = 2.75
	light.shadow_enabled = false
	stage_root.add_child(light)

func _add_character_key(pos: Vector3, color: Color, energy: float, light_range: float) -> void:
	var light := OmniLight3D.new()
	light.name = "CharacterKey"
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = light_range
	light.shadow_enabled = false
	stage_root.add_child(light)

func _make_arch(prefix: String, center: Vector3, radius: float, material: Material, blocks: int, block_width: float, depth: float) -> void:
	for i in range(blocks):
		var t := float(i) / float(maxi(blocks - 1, 1))
		var angle := PI * t
		var p := center + Vector3(cos(angle) * radius, sin(angle) * radius, 0.0)
		_make_box(stage_root, "%s%02d" % [prefix, i], Vector3(block_width, 0.34, depth), material, p, Vector3(0.0, 0.0, angle - PI * 0.5))

func _make_rune_ring(center: Vector3, radius: float, count: int, material: Material) -> void:
	for i in range(count):
		var angle := TAU * float(i) / float(count)
		var p := center + Vector3(cos(angle) * radius, sin(angle) * radius, 0.0)
		_make_box(stage_root, "RuneRing%02d" % i, Vector3(0.18, 0.045, 0.05), material, p, Vector3(0.0, 0.0, angle + PI * 0.5))

func _camera_position_for(screen: String) -> Vector3:
	match screen:
		"home": return Vector3(0.0, 2.75, 8.85)
		"hero": return Vector3(0.0, 2.55, 7.95)
		"forge": return Vector3(0.0, 2.65, 8.95)
		"vault": return Vector3(0.0, 2.80, 8.55)
		_: return Vector3(0.0, 3.00, 9.25)

func _camera_target_for(screen: String) -> Vector3:
	match screen:
		"home": return Vector3(0.0, 2.12, -0.72)
		"hero": return Vector3(0.0, 1.72, -0.05)
		"forge": return Vector3(0.0, 1.62, -0.65)
		_: return Vector3(0.0, 1.95, -0.72)
