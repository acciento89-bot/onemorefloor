class_name Menu3DStageV159
extends "res://scripts/menu3d_stage_v158.gd"

# ONE MORE FLOOR v1.59 — authored environment asset foundation.
# Home/Hero/Forge stop building their focal architecture from runtime BoxMesh /
# CylinderMesh primitives. The large readable forms are imported OBJ assets that
# can be iterated independently from gameplay and UI code.

const ENVIRONMENT_VERSION := "1.59"
const ENV_ROOT := "res://assets/environment/v159/"
const ENV_ASSETS := {
	"pillar": ENV_ROOT + "gothic_pillar.obj",
	"portal": ENV_ROOT + "gothic_portal.obj",
	"pedestal": ENV_ROOT + "hero_pedestal.obj",
	"brazier": ENV_ROOT + "wall_brazier.obj",
	"hearth": ENV_ROOT + "forge_hearth.obj",
	"anvil": ENV_ROOT + "blacksmith_anvil.obj",
	"rack": ENV_ROOT + "weapon_rack.obj",
	"banner": ENV_ROOT + "royal_banner.obj",
}

var v159_mesh_cache: Dictionary = {}
var v159_asset_instances := 0
var v159_asset_paths: Array[String] = []

func _rebuild_stage() -> void:
	v159_asset_instances = 0
	v159_asset_paths.clear()
	super._rebuild_stage()

func environment_assets_ready() -> bool:
	if not composition_ready():
		return false
	for path in ENV_ASSETS.values():
		if not ResourceLoader.exists(String(path)):
			return false
	return v159_asset_instances > 0

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["environment_version"] = ENVIRONMENT_VERSION
	data["environment_asset_instances"] = v159_asset_instances
	data["environment_asset_paths"] = v159_asset_paths.duplicate()
	data["environment_asset_mode"] = "authored-obj"
	return data

func _load_environment_mesh(path: String) -> Mesh:
	if v159_mesh_cache.has(path):
		return v159_mesh_cache[path] as Mesh
	var mesh := load(path) as Mesh
	if mesh != null:
		v159_mesh_cache[path] = mesh
	return mesh

func _place_environment_asset(
	parent: Node3D,
	node_name: String,
	asset_key: String,
	material: Material,
	pos: Vector3,
	scale_value: Vector3 = Vector3.ONE,
	rot: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var path := String(ENV_ASSETS.get(asset_key, ""))
	var mesh := _load_environment_mesh(path)
	if mesh == null:
		push_warning("v1.59 environment asset failed to load: %s" % path)
		return null
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.scale = scale_value
	instance.rotation = rot
	parent.add_child(instance)
	v159_asset_instances += 1
	if path not in v159_asset_paths:
		v159_asset_paths.append(path)
	return instance

func _add_environment_light(node_name: String, pos: Vector3, color: Color, energy: float, range_value: float) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.name = node_name
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = range_value
	light.shadow_enabled = false
	stage_root.add_child(light)
	return light

func _build_home_stage() -> void:
	# A real authored gateway kit now owns the focal silhouette. The common rear
	# wall remains only as a distant backdrop and never blocks the character/UI.
	_place_environment_asset(stage_root, "HomePortalAsset", "portal", mat_stone_hi, Vector3(0.0, 0.10, -3.02), Vector3(1.12, 1.12, 1.12))
	_place_environment_asset(stage_root, "HomePillarLAsset", "pillar", mat_stone_mid, Vector3(-2.72, 0.04, -3.00), Vector3(0.92, 1.04, 0.92))
	_place_environment_asset(stage_root, "HomePillarRAsset", "pillar", mat_stone_mid, Vector3(2.72, 0.04, -3.00), Vector3(0.92, 1.04, 0.92))
	_place_environment_asset(stage_root, "HomeBannerLAsset", "banner", mat_cloth, Vector3(-2.10, 2.25, -2.66), Vector3(0.72, 0.72, 0.72))
	_place_environment_asset(stage_root, "HomeBannerRAsset", "banner", mat_cloth, Vector3(2.10, 2.25, -2.66), Vector3(0.72, 0.72, 0.72))
	_place_environment_asset(stage_root, "HomeBrazierLAsset", "brazier", mat_dark_metal, Vector3(-2.55, 1.72, -2.50), Vector3(0.72, 0.72, 0.72))
	_place_environment_asset(stage_root, "HomeBrazierRAsset", "brazier", mat_dark_metal, Vector3(2.55, 1.72, -2.50), Vector3(0.72, 0.72, 0.72))
	_add_environment_light("HomeFireL", Vector3(-2.55, 1.86, -2.35), Color("f1a060"), 0.62, 3.2)
	_add_environment_light("HomeFireR", Vector3(2.55, 1.86, -2.35), Color("f1a060"), 0.62, 3.2)
	_place_environment_asset(stage_root, "HomePedestalAsset", "pedestal", mat_dark_metal, Vector3(0.0, 0.22, -0.08), Vector3(0.68, 0.68, 0.68))
	_add_actor(Vector3(0.0, 1.58, -0.04), 0.72)
	_add_character_key(Vector3(0.0, 2.82, 2.25), Color("d5ccff"), 0.90, 4.8)

func _build_hero_stage() -> void:
	# The Hero screen is now a small authored shrine instead of a wall of cubes.
	_place_environment_asset(stage_root, "HeroPortalAsset", "portal", mat_stone_mid, Vector3(0.0, 0.16, -3.06), Vector3(1.16, 1.16, 1.16))
	_place_environment_asset(stage_root, "HeroPillarLAsset", "pillar", mat_stone_hi, Vector3(-2.50, 0.04, -2.96), Vector3(0.84, 1.02, 0.84))
	_place_environment_asset(stage_root, "HeroPillarRAsset", "pillar", mat_stone_hi, Vector3(2.50, 0.04, -2.96), Vector3(0.84, 1.02, 0.84))
	_place_environment_asset(stage_root, "HeroBrazierLAsset", "brazier", mat_dark_metal, Vector3(-2.18, 2.62, -2.52), Vector3(0.62, 0.62, 0.62))
	_place_environment_asset(stage_root, "HeroBrazierRAsset", "brazier", mat_dark_metal, Vector3(2.18, 2.62, -2.52), Vector3(0.62, 0.62, 0.62))
	_add_environment_light("HeroRuneL", Vector3(-2.18, 2.78, -2.34), Color("8559da"), 0.50, 3.0)
	_add_environment_light("HeroRuneR", Vector3(2.18, 2.78, -2.34), Color("8559da"), 0.50, 3.0)
	_place_environment_asset(stage_root, "HeroPedestalAsset", "pedestal", mat_dark_metal, Vector3(0.0, 0.76, -0.06), Vector3(0.90, 0.90, 0.90))
	_add_actor(Vector3(0.0, 2.06, -0.02), 0.70)
	_add_character_key(Vector3(0.0, 3.10, 2.35), Color("e1d8ff"), 1.15, 5.0)

func _build_forge_stage() -> void:
	# Forge is the first prop-dense authored environment: imported hearth, anvil,
	# rack, supporting columns and wall braziers. Only the inner ember surface is a
	# tiny procedural VFX card; the readable environment silhouettes are assets.
	_place_environment_asset(stage_root, "ForgePillarLAsset", "pillar", mat_stone_mid, Vector3(-3.04, 0.04, -3.02), Vector3(0.72, 0.94, 0.72))
	_place_environment_asset(stage_root, "ForgePillarRAsset", "pillar", mat_stone_mid, Vector3(3.04, 0.04, -3.02), Vector3(0.72, 0.94, 0.72))
	_place_environment_asset(stage_root, "ForgeHearthAsset", "hearth", mat_stone_hi, Vector3(-1.58, 0.42, -2.78), Vector3(0.76, 0.76, 0.76))
	_make_box(stage_root, "ForgeEmberVFX", Vector3(1.12, 0.72, 0.035), mat_ember, Vector3(-1.58, 1.45, -2.31))
	_add_environment_light("ForgeFire", Vector3(-1.58, 1.55, -2.12), Color("ff7435"), 0.92, 3.8)
	_place_environment_asset(stage_root, "ForgeAnvilAsset", "anvil", mat_dark_metal, Vector3(0.18, 0.92, -1.98), Vector3(0.72, 0.72, 0.72))
	_place_environment_asset(stage_root, "ForgeRackAsset", "rack", mat_dark_metal, Vector3(1.92, 0.52, -2.72), Vector3(0.64, 0.64, 0.64))
	_place_environment_asset(stage_root, "ForgeBrazierAsset", "brazier", mat_brass, Vector3(2.72, 2.64, -2.48), Vector3(0.58, 0.58, 0.58))
	_add_environment_light("ForgeWarmRim", Vector3(2.72, 2.78, -2.28), Color("e7a05b"), 0.42, 2.8)

func _camera_position_for(screen: String) -> Vector3:
	match screen:
		"home": return Vector3(0.0, 2.84, 10.55)
		"hero": return Vector3(0.0, 2.92, 9.95)
		"forge": return Vector3(0.0, 2.86, 10.75)
		_: return super._camera_position_for(screen)

func _camera_target_for(screen: String) -> Vector3:
	match screen:
		"home": return Vector3(0.0, 2.42, -0.72)
		"hero": return Vector3(0.0, 2.78, -0.22)
		"forge": return Vector3(0.0, 2.20, -1.78)
		_: return super._camera_target_for(screen)
