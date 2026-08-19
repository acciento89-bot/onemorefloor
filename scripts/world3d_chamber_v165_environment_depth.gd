extends "res://scripts/world3d_chamber_v164_character_lighting.gd"

# ONE MORE FLOOR v1.65 r1 — Environment Surface & Depth.
# Presentation only: adds mobile-safe material variation and low-profile realm
# dressing on top of the accepted v1.64 character-lighting stack.
# No camera, collision, navigation, combat, actor geometry, UI or input changes.

const ENVIRONMENT_DEPTH_VERSION := "1.65-environment-depth-r1"
const ENVIRONMENT_SURFACE_SHADER := preload("res://assets/shaders/v165_environment_surface.gdshader")
const SURFACE_TARGET := 50
const DETAIL_TARGET := 50

var v165_surface_instances := 0
var v165_depth_details := 0
var v165_depth_root: Node3D

var v165_lower_stone: ShaderMaterial
var v165_lower_brass: ShaderMaterial
var v165_ossuary_stone: ShaderMaterial
var v165_ossuary_bone: ShaderMaterial
var v165_iron_plate: ShaderMaterial
var v165_iron_oxidized: ShaderMaterial
var v165_rift_stone: ShaderMaterial
var v165_rift_crystal: ShaderMaterial
var v165_spire_stone: ShaderMaterial
var v165_spire_inlay: ShaderMaterial

func _ready() -> void:
	super._ready()
	_build_v165_materials()
	_apply_v165_environment_surfaces()
	_build_v165_depth_dressing()

func production_environment_depth_ready() -> bool:
	return production_character_lighting_ready() \
		and v165_depth_root != null \
		and v165_surface_instances >= SURFACE_TARGET \
		and v165_depth_details >= DETAIL_TARGET \
		and String(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")) == "gl_compatibility"

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_environment_depth_ready"] = production_environment_depth_ready()
	data["production_environment_depth_version"] = ENVIRONMENT_DEPTH_VERSION
	data["production_environment_surface_instances"] = v165_surface_instances
	data["production_environment_surface_target"] = SURFACE_TARGET
	data["production_environment_depth_details"] = v165_depth_details
	data["production_environment_depth_target"] = DETAIL_TARGET
	return data

func _build_v165_materials() -> void:
	v165_lower_stone = _v165_surface(Color("181b23"), Color("394252"), 0.10, 0.88, 1.55, 0.22, 0.042, 0.11)
	v165_lower_brass = _v165_surface(Color("60401f"), Color("a4773a"), 0.72, 0.40, 2.25, 0.16, 0.050, 0.08)
	v165_ossuary_stone = _v165_surface(Color("151a1b"), Color("354044"), 0.04, 0.94, 1.85, 0.24, 0.035, 0.14)
	v165_ossuary_bone = _v165_surface(Color("5e5b52"), Color("9a927f"), 0.02, 0.97, 2.60, 0.14, 0.028, 0.08)
	v165_iron_plate = _v165_surface(Color("20242b"), Color("59616d"), 0.78, 0.38, 2.05, 0.19, 0.052, 0.12)
	v165_iron_oxidized = _v165_surface(Color("352a24"), Color("79513b"), 0.58, 0.55, 2.75, 0.21, 0.040, 0.12)
	v165_rift_stone = _v165_surface(Color("0b0a12"), Color("33213f"), 0.10, 0.91, 2.20, 0.25, 0.040, 0.10)
	v165_rift_crystal = _v165_surface(Color("3b2156"), Color("9562c8"), 0.20, 0.34, 2.90, 0.21, 0.060, 0.05, Color("6f43a8"), 0.52)
	v165_spire_stone = _v165_surface(Color("090d16"), Color("2c3a55"), 0.32, 0.68, 1.80, 0.21, 0.050, 0.10)
	v165_spire_inlay = _v165_surface(Color("18223a"), Color("6b83bd"), 0.44, 0.38, 3.10, 0.17, 0.055, 0.04, Color("5574b6"), 0.30)

func _v165_surface(
	base: Color,
	detail: Color,
	metallic: float,
	roughness: float,
	variation_scale: float,
	variation_strength: float,
	edge_response: float,
	ground_ao: float,
	emission: Color = Color.BLACK,
	emission_strength: float = 0.0
) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = ENVIRONMENT_SURFACE_SHADER
	material.set_shader_parameter("base_color", base)
	material.set_shader_parameter("detail_color", detail)
	material.set_shader_parameter("metallic_level", metallic)
	material.set_shader_parameter("roughness_level", roughness)
	material.set_shader_parameter("variation_scale", variation_scale)
	material.set_shader_parameter("variation_strength", variation_strength)
	material.set_shader_parameter("edge_response", edge_response)
	material.set_shader_parameter("ground_ao_strength", ground_ao)
	material.set_shader_parameter("emission_color", emission)
	material.set_shader_parameter("emission_strength", emission_strength)
	return material

func _apply_v165_environment_surfaces() -> void:
	v165_surface_instances = 0
	_apply_v165_realm_surfaces(
		authored_realm_roots.get("lower_halls") as Node3D,
		v165_lower_stone,
		{
			"LowerFlagstone": v165_lower_stone,
			"LowerBrazierAsset": v165_lower_brass,
		}
	)
	_apply_v165_realm_surfaces(
		authored_realm_roots.get("ossuary") as Node3D,
		v165_ossuary_bone,
		{
			"OssuaryCryptSlab": v165_ossuary_stone,
			"OssuaryGraveMarker": v165_ossuary_stone,
		}
	)
	_apply_v165_realm_surfaces(
		authored_realm_roots.get("iron_bastion") as Node3D,
		v165_iron_plate,
		{
			"IronDeckPlate": v165_iron_plate,
			"IronBracePlate": v165_iron_oxidized,
		}
	)
	_apply_v165_realm_surfaces(
		authored_realm_roots.get("rift_descent") as Node3D,
		v165_rift_crystal,
		{
			"RiftBrokenSlab": v165_rift_stone,
		}
	)
	_apply_v165_realm_surfaces(
		authored_realm_roots.get("starless_spire") as Node3D,
		v165_spire_stone,
		{
			"SpireCausewayPanel": v165_spire_stone,
			"SpireEdgeRun": v165_spire_inlay,
		}
	)

func _apply_v165_realm_surfaces(root_node: Node3D, imported_default: Material, named_materials: Dictionary) -> void:
	if root_node == null:
		return
	for child_value in root_node.get_children():
		var child := child_value as Node
		if child == null:
			continue
		_apply_v165_surface_recursive(child, imported_default, named_materials)

func _apply_v165_surface_recursive(node: Node, imported_default: Material, named_materials: Dictionary) -> void:
	var mesh_instance := node as MeshInstance3D
	if mesh_instance != null and mesh_instance.mesh != null:
		var selected: Material = null
		var node_name := String(mesh_instance.name)
		for key_value in named_materials.keys():
			var key := String(key_value)
			if node_name.begins_with(key):
				selected = named_materials[key] as Material
				break
		if selected == null and not (mesh_instance.mesh is PrimitiveMesh):
			selected = imported_default
		if selected != null:
			mesh_instance.material_override = selected
			v165_surface_instances += 1
	for child_value in node.get_children():
		var child := child_value as Node
		if child != null:
			_apply_v165_surface_recursive(child, imported_default, named_materials)

func _build_v165_depth_dressing() -> void:
	v165_depth_root = Node3D.new()
	v165_depth_root.name = "EnvironmentDepthV165"
	add_child(v165_depth_root)
	v165_depth_details = 0
	_build_v165_lower_depth(authored_realm_roots.get("lower_halls") as Node3D)
	_build_v165_ossuary_depth(authored_realm_roots.get("ossuary") as Node3D)
	_build_v165_iron_depth(authored_realm_roots.get("iron_bastion") as Node3D)
	_build_v165_rift_depth(authored_realm_roots.get("rift_descent") as Node3D)
	_build_v165_spire_depth(authored_realm_roots.get("starless_spire") as Node3D)

func _build_v165_lower_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	_add_v165_box(root_node, "V165LowerCurbL", Vector3(0.18, 0.10, 10.9), Vector3(-4.28, 0.015, 0.05), v165_lower_stone)
	_add_v165_box(root_node, "V165LowerCurbR", Vector3(0.18, 0.10, 10.9), Vector3(4.28, 0.015, 0.05), v165_lower_stone)
	for index in range(5):
		var z := -4.55 + float(index) * 2.25
		var x := -3.45 if index % 2 == 0 else 3.30
		_add_v165_box(root_node, "V165LowerRubble_%02d" % index, Vector3(0.32 + 0.05 * float(index % 3), 0.075, 0.24), Vector3(x, 0.018, z), v165_lower_stone, 0.17 * float(index - 2))
	for index in range(4):
		var z := -4.0 + float(index) * 2.65
		_add_v165_box(root_node, "V165LowerInset_%02d" % index, Vector3(5.8, 0.018, 0.055), Vector3(0.0, 0.004, z), v165_lower_brass, 0.015 * float(index % 2))

func _build_v165_ossuary_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	_add_v165_box(root_node, "V165OssuaryCurbL", Vector3(0.16, 0.085, 10.7), Vector3(-4.05, 0.012, 0.0), v165_ossuary_stone)
	_add_v165_box(root_node, "V165OssuaryCurbR", Vector3(0.16, 0.085, 10.7), Vector3(4.05, 0.012, 0.0), v165_ossuary_stone)
	for index in range(8):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.75 + float(index / 2) * 3.0 + 0.22 * float(index % 3)
		_add_v165_box(root_node, "V165BoneFragment_%02d" % index, Vector3(0.28, 0.055, 0.10), Vector3(side * (3.15 + 0.18 * float(index % 2)), 0.016, z), v165_ossuary_bone, side * (0.35 + 0.08 * float(index)))
	for index in range(3):
		var z := -3.35 + float(index) * 3.50
		_add_v165_box(root_node, "V165GraveSeam_%02d" % index, Vector3(1.55, 0.020, 0.06), Vector3(0.18, 0.006, z), v165_ossuary_bone, -0.025)

func _build_v165_iron_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	_add_v165_box(root_node, "V165IronRailL", Vector3(0.18, 0.11, 10.8), Vector3(-4.18, 0.018, 0.05), v165_iron_oxidized)
	_add_v165_box(root_node, "V165IronRailR", Vector3(0.18, 0.11, 10.8), Vector3(4.18, 0.018, 0.05), v165_iron_oxidized)
	for row in range(4):
		var z := -4.55 + float(row) * 3.02
		for side_value in [-1.0, 1.0]:
			var side := float(side_value)
			for rivet in range(2):
				var x := side * (2.50 + float(rivet) * 0.62)
				_add_v165_box(root_node, "V165IronRivet_%d_%d_%d" % [row, int(side), rivet], Vector3(0.11, 0.065, 0.11), Vector3(x, 0.020, z), v165_iron_plate, 0.785)
	for index in range(4):
		var side := -1.0 if index < 2 else 1.0
		var z := -2.4 + float(index) * 1.75
		_add_v165_box(root_node, "V165IronScrap_%02d" % index, Vector3(0.46, 0.055, 0.22), Vector3(side * 3.38, 0.015, z), v165_iron_oxidized, side * (0.20 + 0.07 * float(index)))

func _build_v165_rift_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	for index in range(7):
		var z := -4.85 + float(index) * 1.62
		var x := sin(float(index) * 1.37) * 1.45
		_add_v165_box(root_node, "V165RiftFracture_%02d" % index, Vector3(1.70 + 0.18 * float(index % 3), 0.016, 0.045), Vector3(x, 0.007, z), v165_rift_crystal, 0.24 * sin(float(index) * 0.91))
	for index in range(6):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.10 + float(index) * 1.62
		_add_v165_box(root_node, "V165RiftShard_%02d" % index, Vector3(0.22, 0.085, 0.31), Vector3(side * (3.05 + 0.15 * float(index % 3)), 0.018, z), v165_rift_stone, side * (0.38 + 0.11 * float(index)))

func _build_v165_spire_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	for index in range(5):
		var z := -4.4 + float(index) * 2.12
		_add_v165_box(root_node, "V165SpireInlay_%02d" % index, Vector3(4.55, 0.014, 0.045), Vector3(0.0, 0.008, z), v165_spire_inlay, 0.018 * float((index % 3) - 1))
	for index in range(8):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.7 + float(index / 2) * 2.85 + 0.16 * float(index % 3)
		_add_v165_box(root_node, "V165SpireGlyph_%02d" % index, Vector3(0.16, 0.045, 0.16), Vector3(side * 3.30, 0.020, z), v165_spire_inlay, 0.785)
	_add_v165_box(root_node, "V165SpireRailL", Vector3(0.12, 0.075, 10.6), Vector3(-3.63, 0.012, 0.10), v165_spire_stone)
	_add_v165_box(root_node, "V165SpireRailR", Vector3(0.12, 0.075, 10.6), Vector3(3.63, 0.012, 0.10), v165_spire_stone)

func _add_v165_box(
	parent: Node3D,
	node_name: String,
	size: Vector3,
	position_value: Vector3,
	material: Material,
	rotation_y: float = 0.0
) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.material_override = material
	node.position = position_value
	node.rotation.y = rotation_y
	parent.add_child(node)
	v165_depth_details += 1
	return node
