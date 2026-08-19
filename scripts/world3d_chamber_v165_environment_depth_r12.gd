extends "res://scripts/world3d_chamber_v165_environment_depth_r11.gd"

# ONE MORE FLOOR v1.65 r1.2 — material-first environment correction.
# r1.1 removed the rejected long neon/debug bars, but remained too subtle.
# r1.2 makes the surface itself visibly richer and replaces line-centric floor
# dressing with low-profile faceted wear/patina patches and compact chips.
# Presentation only: no collision, navigation, camera or gameplay authority.

const ENVIRONMENT_DEPTH_R12_VERSION := "1.65-environment-depth-r1.2"

var v165_lower_wear: ShaderMaterial
var v165_ossuary_dust: ShaderMaterial
var v165_iron_rust: ShaderMaterial
var v165_rift_scorch: ShaderMaterial
var v165_spire_wear: ShaderMaterial

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_environment_depth_version"] = ENVIRONMENT_DEPTH_R12_VERSION
	data["production_environment_r11"] = true
	data["production_environment_r12"] = true
	return data

func _build_v165_materials() -> void:
	v165_lower_stone = _v165_surface(Color("171a22"), Color("505c70"), 0.10, 0.88, 1.58, 0.38, 0.050, 0.11)
	v165_lower_brass = _v165_surface(Color("51351b"), Color("936432"), 0.70, 0.44, 2.45, 0.22, 0.042, 0.08)
	v165_ossuary_stone = _v165_surface(Color("13191a"), Color("4b5b5e"), 0.04, 0.94, 1.78, 0.37, 0.042, 0.14)
	v165_ossuary_bone = _v165_surface(Color("504e48"), Color("8c8576"), 0.02, 0.97, 2.65, 0.20, 0.026, 0.08)
	v165_iron_plate = _v165_surface(Color("1d2229"), Color("6b7788"), 0.78, 0.40, 1.95, 0.36, 0.052, 0.12)
	v165_iron_oxidized = _v165_surface(Color("322821"), Color("8a5b40"), 0.56, 0.58, 2.65, 0.34, 0.040, 0.12)
	v165_rift_stone = _v165_surface(Color("090a11"), Color("4b305d"), 0.10, 0.92, 2.08, 0.38, 0.042, 0.10)
	v165_rift_crystal = _v165_surface(Color("302046"), Color("8053aa"), 0.20, 0.38, 2.85, 0.24, 0.050, 0.05, Color("5e3d8a"), 0.12)
	v165_spire_stone = _v165_surface(Color("080c15"), Color("40577d"), 0.32, 0.70, 1.78, 0.38, 0.050, 0.10)
	v165_spire_inlay = _v165_surface(Color("151e34"), Color("506b9e"), 0.42, 0.44, 3.05, 0.22, 0.046, 0.04, Color("405f95"), 0.08)

	v165_lower_wear = _v165_surface(Color("11141b"), Color("323b49"), 0.04, 0.96, 2.90, 0.24, 0.022, 0.16)
	v165_ossuary_dust = _v165_surface(Color("343835"), Color("62685f"), 0.01, 0.99, 3.20, 0.18, 0.018, 0.10)
	v165_iron_rust = _v165_surface(Color("33231d"), Color("744732"), 0.36, 0.78, 3.15, 0.30, 0.025, 0.14)
	v165_rift_scorch = _v165_surface(Color("08070d"), Color("25182e"), 0.02, 0.98, 2.75, 0.26, 0.020, 0.16)
	v165_spire_wear = _v165_surface(Color("080b12"), Color("27364f"), 0.16, 0.88, 2.85, 0.26, 0.022, 0.14)

func _build_v165_lower_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	_add_v165_box(root_node, "V165LowerCurbL", Vector3(0.18, 0.10, 10.9), Vector3(-4.28, 0.015, 0.05), v165_lower_stone)
	_add_v165_box(root_node, "V165LowerCurbR", Vector3(0.18, 0.10, 10.9), Vector3(4.28, 0.015, 0.05), v165_lower_stone)
	for index in range(8):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.70 + float(index) * 1.35
		var x := side * (3.05 + 0.22 * float(index % 3))
		_add_v165_box(root_node, "V165LowerChipR12_%02d" % index, Vector3(0.20 + 0.04 * float(index % 3), 0.055, 0.16 + 0.03 * float(index % 2)), Vector3(x, 0.014, z), v165_lower_stone, side * (0.22 + 0.11 * float(index)))
	for index in range(7):
		var x := -2.65 + float(index % 4) * 1.70 + 0.18 * float(index % 2)
		var z := -4.15 + float(index / 4) * 5.35 + 0.55 * float(index % 3)
		_add_v165_patch(root_node, "V165LowerWearR12_%02d" % index, 0.46 + 0.08 * float(index % 3), Vector3(x, 0.008, z), v165_lower_wear, Vector2(1.45 + 0.18 * float(index % 2), 0.58 + 0.10 * float(index % 3)), 0.22 * float(index - 3))
	for index in range(5):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -3.75 + float(index) * 1.75
		_add_v165_patch(root_node, "V165LowerBrassChipR12_%02d" % index, 0.14 + 0.02 * float(index % 2), Vector3(side * (1.70 + 0.30 * float(index % 3)), 0.010, z), v165_lower_brass, Vector2(1.30, 0.62), side * (0.20 + 0.08 * float(index)))

func _build_v165_ossuary_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	_add_v165_box(root_node, "V165OssuaryCurbL", Vector3(0.16, 0.085, 10.7), Vector3(-4.05, 0.012, 0.0), v165_ossuary_stone)
	_add_v165_box(root_node, "V165OssuaryCurbR", Vector3(0.16, 0.085, 10.7), Vector3(4.05, 0.012, 0.0), v165_ossuary_stone)
	for index in range(10):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.75 + float(index / 2) * 2.25 + 0.18 * float(index % 3)
		_add_v165_box(root_node, "V165BoneFragmentR12_%02d" % index, Vector3(0.20 + 0.035 * float(index % 3), 0.048, 0.075), Vector3(side * (3.02 + 0.19 * float(index % 2)), 0.014, z), v165_ossuary_bone, side * (0.32 + 0.10 * float(index)))
	for index in range(7):
		var x := -2.55 + float(index % 4) * 1.62
		var z := -4.10 + float(index / 4) * 5.05 + 0.42 * float(index % 3)
		_add_v165_patch(root_node, "V165OssuaryDustR12_%02d" % index, 0.44 + 0.07 * float(index % 3), Vector3(x, 0.008, z), v165_ossuary_dust, Vector2(1.55 + 0.14 * float(index % 2), 0.48 + 0.08 * float(index % 3)), 0.27 * float(index - 2))
	for index in range(5):
		var side := -1.0 if index % 2 == 0 else 1.0
		_add_v165_patch(root_node, "V165OssuaryDarkWearR12_%02d" % index, 0.34, Vector3(side * (1.05 + 0.35 * float(index % 2)), 0.009, -3.25 + float(index) * 1.72), v165_ossuary_stone, Vector2(1.35, 0.50), side * 0.24)

func _build_v165_iron_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	_add_v165_box(root_node, "V165IronRailL", Vector3(0.16, 0.09, 10.8), Vector3(-4.18, 0.015, 0.05), v165_iron_oxidized)
	_add_v165_box(root_node, "V165IronRailR", Vector3(0.16, 0.09, 10.8), Vector3(4.18, 0.015, 0.05), v165_iron_oxidized)
	for row in range(4):
		var z := -4.55 + float(row) * 3.02
		for side_value in [-1.0, 1.0]:
			var side := float(side_value)
			for rivet in range(2):
				var x := side * (2.50 + float(rivet) * 0.62)
				_add_v165_box(root_node, "V165IronRivetR12_%d_%d_%d" % [row, int(side), rivet], Vector3(0.10, 0.060, 0.10), Vector3(x, 0.018, z), v165_iron_plate, 0.785)
	for index in range(7):
		var x := -2.60 + float(index % 4) * 1.70
		var z := -4.05 + float(index / 4) * 5.15 + 0.47 * float(index % 3)
		_add_v165_patch(root_node, "V165IronRustR12_%02d" % index, 0.42 + 0.08 * float(index % 3), Vector3(x, 0.009, z), v165_iron_rust, Vector2(1.55 + 0.16 * float(index % 2), 0.50 + 0.08 * float(index % 3)), 0.31 * float(index - 2))
	for index in range(6):
		var side := -1.0 if index % 2 == 0 else 1.0
		_add_v165_box(root_node, "V165IronScrapR12_%02d" % index, Vector3(0.33 + 0.05 * float(index % 3), 0.050, 0.15 + 0.03 * float(index % 2)), Vector3(side * 3.30, 0.014, -3.60 + float(index) * 1.42), v165_iron_oxidized, side * (0.18 + 0.09 * float(index)))

func _build_v165_rift_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	for index in range(8):
		var x := -2.55 + float(index % 4) * 1.68 + 0.14 * float(index % 2)
		var z := -4.25 + float(index / 4) * 5.10 + 0.48 * float(index % 3)
		_add_v165_patch(root_node, "V165RiftScorchR12_%02d" % index, 0.46 + 0.08 * float(index % 3), Vector3(x, 0.008, z), v165_rift_scorch, Vector2(1.55 + 0.20 * float(index % 2), 0.50 + 0.09 * float(index % 3)), 0.29 * float(index - 3))
	for index in range(10):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.50 + float(index) * 0.98
		_add_v165_box(root_node, "V165RiftShardR12_%02d" % index, Vector3(0.15 + 0.035 * float(index % 3), 0.075, 0.22 + 0.04 * float(index % 2)), Vector3(side * (2.75 + 0.20 * float(index % 3)), 0.016, z), v165_rift_stone, side * (0.34 + 0.12 * float(index)))
	for index in range(6):
		var side := -1.0 if index % 2 == 0 else 1.0
		_add_v165_patch(root_node, "V165RiftCrystalChipR12_%02d" % index, 0.13 + 0.02 * float(index % 2), Vector3(side * (1.10 + 0.44 * float(index % 3)), 0.010, -3.55 + float(index) * 1.48), v165_rift_crystal, Vector2(1.50, 0.58), side * (0.24 + 0.08 * float(index)))

func _build_v165_spire_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	_add_v165_box(root_node, "V165SpireRailL", Vector3(0.11, 0.070, 10.6), Vector3(-3.63, 0.011, 0.10), v165_spire_stone)
	_add_v165_box(root_node, "V165SpireRailR", Vector3(0.11, 0.070, 10.6), Vector3(3.63, 0.011, 0.10), v165_spire_stone)
	for index in range(8):
		var x := -2.45 + float(index % 4) * 1.62 + 0.12 * float(index % 2)
		var z := -4.15 + float(index / 4) * 5.00 + 0.45 * float(index % 3)
		_add_v165_patch(root_node, "V165SpireWearR12_%02d" % index, 0.43 + 0.07 * float(index % 3), Vector3(x, 0.008, z), v165_spire_wear, Vector2(1.48 + 0.18 * float(index % 2), 0.48 + 0.08 * float(index % 3)), 0.28 * float(index - 3))
	for index in range(8):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.35 + float(index) * 1.16
		_add_v165_patch(root_node, "V165SpireInlayChipR12_%02d" % index, 0.13 + 0.02 * float(index % 3), Vector3(side * (1.20 + 0.42 * float(index % 3)), 0.010, z), v165_spire_inlay, Vector2(1.45, 0.56), side * (0.20 + 0.09 * float(index)))
	for index in range(8):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.65 + float(index / 2) * 2.82 + 0.14 * float(index % 3)
		_add_v165_box(root_node, "V165SpireGlyphR12_%02d" % index, Vector3(0.12, 0.036, 0.12), Vector3(side * 3.25, 0.016, z), v165_spire_inlay, 0.785 + side * 0.10)

func _add_v165_patch(
	parent: Node3D,
	node_name: String,
	radius: float,
	position_value: Vector3,
	material: Material,
	xz_scale: Vector2,
	rotation_y: float
) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius * 1.03
	mesh.height = 0.012
	mesh.radial_segments = 5
	mesh.rings = 1
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.material_override = material
	node.position = position_value
	node.rotation.y = rotation_y
	node.scale = Vector3(xz_scale.x, 1.0, xz_scale.y)
	parent.add_child(node)
	v165_depth_details += 1
	return node
