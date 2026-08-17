extends "res://scripts/world3d_chamber_v143.gd"

# ONE MORE FLOOR v1.44 - Iron Bastion 3D realm kit for floors 21-30.
# Gameplay, collisions and progression remain owned by the existing runtime;
# this layer only changes production presentation for the third tower realm.

const IRON_BASTION_MIN_FLOOR := 21
const IRON_BASTION_MAX_FLOOR := 30

var iron_bastion_root: Node3D
var iron_bastion_active := false
var iron_forge_core: MeshInstance3D
var iron_gear_left: Node3D
var iron_gear_right: Node3D
var iron_piston_left: Node3D
var iron_piston_right: Node3D

func _ready() -> void:
	super._ready()
	_build_iron_bastion_kit()

func _process(delta: float) -> void:
	super._process(delta)
	if iron_bastion_active:
		_animate_iron_bastion(delta)

func iron_bastion_ready() -> bool:
	return ossuary_ready() \
		and iron_bastion_root != null \
		and iron_bastion_root.get_node_or_null("ForgeHeart") != null \
		and iron_bastion_root.get_node_or_null("BastionKeyLight") != null

func is_iron_bastion_floor(floor_no: int) -> bool:
	return floor_no >= IRON_BASTION_MIN_FLOOR and floor_no <= IRON_BASTION_MAX_FLOOR

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["iron_bastion_ready"] = iron_bastion_ready()
	data["iron_bastion_active"] = iron_bastion_active
	if iron_bastion_active:
		data["realm"] = "iron_bastion"
	return data

func _apply_floor_identity(floor_no: int) -> void:
	super._apply_floor_identity(floor_no)
	_set_iron_bastion_active(is_iron_bastion_floor(floor_no))
	if iron_bastion_active:
		var depth: float = clampf(float(floor_no - IRON_BASTION_MIN_FLOOR) / 9.0, 0.0, 1.0)
		mat_floor.albedo_color = Color("17191c").lerp(Color("211717"), depth * 0.48)
		mat_wall.albedo_color = Color("292b2e").lerp(Color("382425"), depth * 0.42)
		mat_trim.albedo_color = Color("70594a").lerp(Color("8a5143"), depth * 0.38)

func _set_iron_bastion_active(value: bool) -> void:
	iron_bastion_active = value
	if iron_bastion_root != null:
		iron_bastion_root.visible = value
	if ossuary_root != null:
		ossuary_root.visible = ossuary_active and not value
	if production_details_root != null:
		production_details_root.visible = not value and not ossuary_active
	for light_name_value in ["WarmTorchLight", "ArcaneLight", "ProductionRim", "GateGoldPool"]:
		var light_name: String = String(light_name_value)
		var node: Node3D = get_node_or_null(light_name) as Node3D
		if node != null:
			node.visible = not value and not ossuary_active

func _build_iron_bastion_kit() -> void:
	iron_bastion_root = Node3D.new()
	iron_bastion_root.name = "IronBastionRealm"
	iron_bastion_root.visible = false
	add_child(iron_bastion_root)

	var iron_dark: StandardMaterial3D = _material(Color("17191d"), 0.78, 0.34)
	var iron_mid: StandardMaterial3D = _material(Color("34373b"), 0.72, 0.39)
	var iron_edge: StandardMaterial3D = _material(Color("666268"), 0.58, 0.43)
	var bronze: StandardMaterial3D = _material(Color("8c6849"), 0.66, 0.38)
	var ember: StandardMaterial3D = _emissive_material(Color("ff7b32"), 2.35)
	var forge_gold: StandardMaterial3D = _emissive_material(Color("ffc15a"), 2.75)
	var warning_red: StandardMaterial3D = _emissive_material(Color("d8453e"), 1.65)
	var ash: StandardMaterial3D = _material(Color("4a4140"), 0.18, 0.91)

	# Heavy side fortifications: plated walls, buttresses and riveted armor bands.
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		for z_value in [-4.8, -2.4, 0.0, 2.4, 4.8]:
			var z: float = float(z_value)
			var bastion: Node3D = Node3D.new()
			bastion.name = "ArmorBay"
			bastion.position = Vector3(side * 4.72, 0.0, z)
			iron_bastion_root.add_child(bastion)
			_add_box(bastion, "Plate", Vector3(0.42, 2.15, 1.78), Vector3(0.0, 1.08, 0.0), iron_mid)
			_add_box(bastion, "ButtressA", Vector3(0.58, 2.58, 0.28), Vector3(-side * 0.12, 1.29, -0.80), iron_dark)
			_add_box(bastion, "ButtressB", Vector3(0.58, 2.58, 0.28), Vector3(-side * 0.12, 1.29, 0.80), iron_dark)
			_add_box(bastion, "ArmorBand", Vector3(0.50, 0.20, 1.92), Vector3(-side * 0.06, 1.28, 0.0), bronze)
			for rivet_z_value in [-0.67, -0.22, 0.22, 0.67]:
				var rivet_z: float = float(rivet_z_value)
				_add_sphere_local(bastion, "Rivet", 0.07, Vector3(-side * 0.26, 1.28, rivet_z), iron_edge, 8, 4)

	# Floor grates and armored channels create an industrial combat lane.
	for x_value in [-2.65, 0.0, 2.65]:
		var x: float = float(x_value)
		_add_box(iron_bastion_root, "RailChannel", Vector3(0.30, 0.055, 11.25), Vector3(x, 0.025, 0.15), iron_dark)
		for z_value in [-4.6, -3.45, -2.3, -1.15, 0.0, 1.15, 2.3, 3.45, 4.6]:
			var z: float = float(z_value)
			_add_box(iron_bastion_root, "GrateCrossbar", Vector3(0.82, 0.065, 0.11), Vector3(x, 0.045, z), iron_edge)

	# Forge heart at the rear establishes the realm silhouette and warm focal point.
	var forge: Node3D = Node3D.new()
	forge.name = "ForgeHeart"
	forge.position = Vector3(0.0, 0.0, -5.25)
	iron_bastion_root.add_child(forge)
	_add_box(forge, "ForgeBase", Vector3(2.72, 0.42, 1.34), Vector3(0.0, 0.21, 0.0), iron_dark)
	_add_box(forge, "ForgeBody", Vector3(2.18, 1.18, 1.05), Vector3(0.0, 0.86, 0.0), iron_mid)
	_add_box(forge, "ForgeMouth", Vector3(1.42, 0.66, 0.08), Vector3(0.0, 0.86, 0.57), ember)
	_add_box(forge, "ForgeLintel", Vector3(1.86, 0.20, 0.22), Vector3(0.0, 1.52, 0.54), bronze)
	iron_forge_core = _add_sphere_local(forge, "ForgeCore", 0.28, Vector3(0.0, 0.88, 0.67), forge_gold, 14, 7)
	iron_forge_core.scale = Vector3(1.35, 0.82, 0.56)
	iron_forge_core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		_add_cylinder_local(forge, "ExhaustStack", 0.20, 0.26, 1.85, Vector3(side * 0.88, 1.72, -0.18), iron_dark, 10)
		_add_box(forge, "StackBand", Vector3(0.50, 0.14, 0.50), Vector3(side * 0.88, 1.36, -0.18), bronze)

	# Two mechanical gear towers read clearly from the fixed angled camera.
	iron_gear_left = _build_gear_tower(Vector3(-3.35, 0.0, -1.65), iron_dark, iron_edge, bronze)
	iron_gear_right = _build_gear_tower(Vector3(3.35, 0.0, -1.65), iron_dark, iron_edge, bronze)

	# Piston towers frame the foreground and animate subtly without affecting gameplay.
	iron_piston_left = _build_piston_tower(Vector3(-3.45, 0.0, 4.15), iron_dark, iron_mid, bronze, warning_red)
	iron_piston_right = _build_piston_tower(Vector3(3.45, 0.0, 4.15), iron_dark, iron_mid, bronze, warning_red)

	# Hanging chain silhouettes and warning lamps finish the militarized fortress language.
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		for z_value in [-3.7, 0.3, 3.4]:
			var z: float = float(z_value)
			var chain: Node3D = Node3D.new()
			chain.name = "ChainDrop"
			chain.position = Vector3(side * 4.15, 2.35, z)
			iron_bastion_root.add_child(chain)
			for link_index in range(7):
				var y: float = -float(link_index) * 0.26
				var link: MeshInstance3D = _add_cylinder_local(chain, "ChainLink", 0.105, 0.105, 0.055, Vector3(0.0, y, 0.0), iron_edge, 8)
				link.rotation.x = PI * 0.5
				link.rotation.y = PI * 0.5 if link_index % 2 == 0 else 0.0
		_add_sphere_local(iron_bastion_root, "WarningLamp", 0.12, Vector3(side * 3.92, 1.68, 1.25), warning_red, 10, 5)

	# Ash piles soften the otherwise hard industrial floor and add depth cues.
	for ash_pos_value in [Vector3(-3.1, 0.0, 1.8), Vector3(3.05, 0.0, -3.4), Vector3(-1.7, 0.0, -4.2), Vector3(2.0, 0.0, 4.7)]:
		var ash_pos: Vector3 = ash_pos_value
		var ash_heap: MeshInstance3D = _add_sphere_local(iron_bastion_root, "AshHeap", 0.34, ash_pos + Vector3(0.0, 0.08, 0.0), ash, 10, 5)
		ash_heap.scale = Vector3(1.55, 0.34, 1.05)

	_add_omni_to(iron_bastion_root, "BastionKeyLight", Vector3(-2.8, 2.55, 0.35), Color("f09a52"), 2.35, 7.0)
	_add_omni_to(iron_bastion_root, "ForgeGlowLight", Vector3(0.0, 1.85, -4.75), Color("ff6c2d"), 3.25, 6.7)
	_add_omni_to(iron_bastion_root, "BastionRimLight", Vector3(3.15, 2.10, 3.85), Color("bd4b45"), 1.45, 5.8)

func _build_gear_tower(pos: Vector3, iron_dark: StandardMaterial3D, iron_edge: StandardMaterial3D, bronze: StandardMaterial3D) -> Node3D:
	var tower: Node3D = Node3D.new()
	tower.name = "GearTower"
	tower.position = pos
	iron_bastion_root.add_child(tower)
	_add_box(tower, "Pedestal", Vector3(1.08, 0.34, 1.08), Vector3(0.0, 0.17, 0.0), iron_dark)
	_add_cylinder_local(tower, "Axle", 0.17, 0.17, 1.62, Vector3(0.0, 0.98, 0.0), bronze, 10)
	var gear: MeshInstance3D = _add_cylinder_local(tower, "MainGear", 0.72, 0.72, 0.18, Vector3(0.0, 1.17, -0.08), iron_edge, 18)
	gear.rotation.x = PI * 0.5
	for tooth_index in range(12):
		var angle: float = TAU * float(tooth_index) / 12.0
		var tooth: MeshInstance3D = _add_box(tower, "GearTooth", Vector3(0.18, 0.16, 0.34), Vector3(cos(angle) * 0.78, 1.17 + sin(angle) * 0.78, -0.08), bronze)
		tooth.rotation.z = angle
	return tower

func _build_piston_tower(pos: Vector3, iron_dark: StandardMaterial3D, iron_mid: StandardMaterial3D, bronze: StandardMaterial3D, warning_red: StandardMaterial3D) -> Node3D:
	var tower: Node3D = Node3D.new()
	tower.name = "PistonTower"
	tower.position = pos
	iron_bastion_root.add_child(tower)
	_add_box(tower, "Base", Vector3(1.22, 0.40, 1.22), Vector3(0.0, 0.20, 0.0), iron_dark)
	_add_cylinder_local(tower, "Housing", 0.38, 0.46, 1.34, Vector3(0.0, 0.93, 0.0), iron_mid, 12)
	_add_cylinder_local(tower, "PistonRod", 0.12, 0.12, 1.52, Vector3(0.0, 1.55, 0.0), bronze, 10)
	_add_box(tower, "RamHead", Vector3(0.82, 0.22, 0.82), Vector3(0.0, 2.22, 0.0), iron_dark)
	_add_box(tower, "WarningRune", Vector3(0.34, 0.08, 0.06), Vector3(0.0, 1.06, -0.47), warning_red)
	return tower

func _animate_iron_bastion(_delta: float) -> void:
	if iron_bastion_root == null:
		return
	if iron_forge_core != null:
		var pulse: float = 1.0 + sin(runtime_elapsed * 5.2) * 0.13
		iron_forge_core.scale = Vector3(1.35 * pulse, 0.82 * pulse, 0.56 * pulse)
	if iron_gear_left != null:
		iron_gear_left.rotation.z = runtime_elapsed * 0.32
	if iron_gear_right != null:
		iron_gear_right.rotation.z = -runtime_elapsed * 0.28
	var piston_phase: float = sin(runtime_elapsed * 1.85) * 0.14
	if iron_piston_left != null:
		iron_piston_left.position.y = maxf(0.0, piston_phase)
	if iron_piston_right != null:
		iron_piston_right.position.y = maxf(0.0, -piston_phase)
