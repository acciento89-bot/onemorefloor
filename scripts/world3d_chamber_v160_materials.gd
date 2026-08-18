extends "res://scripts/world3d_chamber_v160_focals.gd"

# ONE MORE FLOOR v1.60 — authored surface/material depth pass.
# Presentation only. Applies the lightweight GL-compatible surface shader to
# imported production meshes while floor geometry, inherited VFX, gameplay,
# collisions, real-model combat and HUD remain untouched.

const MATERIAL_DEPTH_VERSION := "1.60-authored-surface-depth"
const SURFACE_DEPTH_SHADER: Shader = preload("res://assets/shaders/v160_surface_depth.gdshader")

var material_depth_instances := 0
var material_depth_target := 0
var surface_materials: Dictionary = {}

func _ready() -> void:
	super._ready()
	_build_surface_material_library()
	_apply_authored_surface_depth()

func production_material_depth_ready() -> bool:
	return production_focal_ready() \
		and SURFACE_DEPTH_SHADER != null \
		and surface_materials.size() == 7 \
		and material_depth_target > 0 \
		and material_depth_instances >= material_depth_target

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_material_depth_ready"] = production_material_depth_ready()
	data["production_material_depth_version"] = MATERIAL_DEPTH_VERSION
	data["production_material_depth_instances"] = material_depth_instances
	data["production_material_depth_target"] = material_depth_target
	data["production_material_depth_classes"] = surface_materials.keys()
	return data

func _build_surface_material_library() -> void:
	surface_materials["stone"] = _make_surface_material(
		Color("252b39"), Color("64708b"), 0.06, 0.80, 0.27, 0.20, 0.045, 0.020
	)
	surface_materials["bone"] = _make_surface_material(
		Color("68645a"), Color("b8b09a"), 0.00, 0.90, 0.20, 0.20, 0.050, 0.030
	)
	surface_materials["iron"] = _make_surface_material(
		Color("252a31"), Color("745844"), 0.86, 0.36, 0.52, 0.22, 0.028, 0.015
	)
	surface_materials["brass"] = _make_surface_material(
		Color("70491f"), Color("c5914c"), 0.92, 0.31, 0.56, 0.28, 0.025, 0.014
	)
	surface_materials["rift_crystal"] = _make_surface_material(
		Color("392052"), Color("b76eff"), 0.05, 0.30, 0.46, 0.36, 0.035, 0.018,
		Color("7a39b7"), 0.24
	)
	surface_materials["rift_anchor"] = _make_surface_material(
		Color("21182d"), Color("73578c"), 0.28, 0.62, 0.34, 0.25, 0.030, 0.016,
		Color("4e2772"), 0.07
	)
	surface_materials["obsidian"] = _make_surface_material(
		Color("101724"), Color("49658f"), 0.46, 0.47, 0.44, 0.28, 0.028, 0.012
	)

func _make_surface_material(
	base_color: Color,
	edge_color: Color,
	metallic_value: float,
	roughness_value: float,
	specular_value: float,
	edge_value: float,
	height_value: float,
	variation_value: float,
	emission_color_value: Color = Color.BLACK,
	emission_value: float = 0.0
) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = SURFACE_DEPTH_SHADER
	material.set_shader_parameter("base_color", base_color)
	material.set_shader_parameter("edge_color", edge_color)
	material.set_shader_parameter("metallic", metallic_value)
	material.set_shader_parameter("roughness", roughness_value)
	material.set_shader_parameter("specular_level", specular_value)
	material.set_shader_parameter("edge_strength", edge_value)
	material.set_shader_parameter("height_strength", height_value)
	material.set_shader_parameter("variation_strength", variation_value)
	material.set_shader_parameter("emission_color", emission_color_value)
	material.set_shader_parameter("emission_strength", emission_value)
	return material

func _apply_authored_surface_depth() -> void:
	material_depth_instances = 0
	material_depth_target = tower_asset_instances + focal_asset_instances
	for realm_value in authored_realm_roots.values():
		var realm_root := realm_value as Node3D
		if realm_root != null:
			_apply_surface_depth_recursive(realm_root)

func _apply_surface_depth_recursive(node: Node) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D
		var surface_material := _surface_material_for_instance(mesh_instance)
		if surface_material != null:
			mesh_instance.material_override = surface_material
			material_depth_instances += 1
	for child in node.get_children():
		_apply_surface_depth_recursive(child)

func _surface_material_for_instance(instance: MeshInstance3D) -> Material:
	if instance == null or instance.mesh == null:
		return null
	var path := String(instance.mesh.resource_path)
	var node_name := String(instance.name)

	if path.ends_with("tower_arch.obj") or path.ends_with("gothic_pillar.obj"):
		return surface_materials["stone"] as Material
	if path.ends_with("wall_brazier.obj"):
		return surface_materials["brass"] as Material
	if path.ends_with("ossuary_totem.obj") or path.ends_with("ossuary_altar.obj") or node_name == "OssuaryReliquaryAltarV160":
		return surface_materials["bone"] as Material
	if path.ends_with("iron_buttress.obj") or path.ends_with("forge_engine.obj") or node_name == "IronForgeEngineV160":
		return surface_materials["iron"] as Material
	if path.ends_with("rift_crystal.obj"):
		return surface_materials["rift_crystal"] as Material
	if path.ends_with("rift_anchor.obj") or node_name == "RiftAnchorGateV160":
		return surface_materials["rift_anchor"] as Material
	if path.ends_with("spire_column.obj") or path.ends_with("starwell_dais.obj") or node_name == "StarwellDaisV160":
		return surface_materials["obsidian"] as Material
	return null
