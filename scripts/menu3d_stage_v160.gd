class_name Menu3DStageV160
extends "res://scripts/menu3d_stage_v159.gd"

# ONE MORE FLOOR v1.60 — authored meta-environment expansion.
# Completes the menu environment asset takeover for Talents, Vault, Missions,
# Tower Pass and Store while retaining the v1.59 Home/Hero/Forge scenes.

const META_ENVIRONMENT_VERSION := "1.60"
const META_ROOT := "res://assets/environment/v160/"
const META_ASSETS := {
	"obelisk": META_ROOT + "arcane_obelisk.obj",
	"vault_door": META_ROOT + "vault_door.obj",
	"chest": META_ROOT + "treasure_chest.obj",
	"mission_table": META_ROOT + "mission_table.obj",
	"mission_board": META_ROOT + "mission_board.obj",
	"pass_shrine": META_ROOT + "pass_shrine.obj",
	"store_counter": META_ROOT + "store_counter.obj",
}

var v160_mesh_cache: Dictionary = {}
var v160_asset_instances := 0
var v160_asset_paths: Array[String] = []

func _rebuild_stage() -> void:
	v160_asset_instances = 0
	v160_asset_paths.clear()
	super._rebuild_stage()

func meta_environment_assets_ready() -> bool:
	if not environment_assets_ready():
		return false
	for path in META_ASSETS.values():
		if not ResourceLoader.exists(String(path)):
			return false
	return v160_asset_instances > 0 or current_screen in ["home", "hero", "forge"]

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["meta_environment_version"] = META_ENVIRONMENT_VERSION
	data["meta_environment_asset_instances"] = v160_asset_instances
	data["meta_environment_asset_paths"] = v160_asset_paths.duplicate()
	data["meta_environment_asset_mode"] = "authored-obj-expanded"
	return data

func _load_meta_mesh(path: String) -> Mesh:
	if v160_mesh_cache.has(path):
		return v160_mesh_cache[path] as Mesh
	var mesh := load(path) as Mesh
	if mesh != null:
		v160_mesh_cache[path] = mesh
	return mesh

func _place_meta_asset(
	parent: Node3D,
	node_name: String,
	asset_key: String,
	material: Material,
	pos: Vector3,
	scale_value: Vector3 = Vector3.ONE,
	rot: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var path := String(META_ASSETS.get(asset_key, ""))
	var mesh := _load_meta_mesh(path)
	if mesh == null:
		push_warning("v1.60 meta environment asset failed to load: %s" % path)
		return null
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.scale = scale_value
	instance.rotation = rot
	parent.add_child(instance)
	v160_asset_instances += 1
	v159_asset_instances += 1
	if path not in v160_asset_paths:
		v160_asset_paths.append(path)
	if path not in v159_asset_paths:
		v159_asset_paths.append(path)
	return instance

func _build_talents_stage() -> void:
	_place_environment_asset(stage_root, "TalentPedestalAsset", "pedestal", mat_dark_metal, Vector3(0.0, 0.30, -0.25), Vector3(0.84, 0.84, 0.84))
	for i in range(4):
		var x := -2.65 + float(i) * 1.77
		var depth := -2.65 if i % 2 == 0 else -2.30
		_place_meta_asset(stage_root, "TalentObelisk%dAsset" % i, "obelisk", mat_stone_hi, Vector3(x, 0.02, depth), Vector3(0.62, 0.78, 0.62))
	_place_environment_asset(stage_root, "TalentPortalAsset", "portal", mat_stone_mid, Vector3(0.0, 0.12, -3.08), Vector3(1.14, 1.10, 1.14))
	_add_environment_light("TalentPurpleKey", Vector3(-2.2, 2.55, -1.55), Color("8d58ff"), 0.78, 4.2)
	_add_environment_light("TalentBlueFill", Vector3(2.2, 2.25, -1.20), Color("43a0ff"), 0.62, 4.0)

func _build_vault_stage() -> void:
	# Portrait gate pass 2: the first door read as a featureless black monolith.
	# Pull it back, use lighter authored-stone treatment and give the chamber two
	# warm side braziers so the lock silhouette remains readable behind the UI.
	_place_meta_asset(stage_root, "VaultDoorAsset", "vault_door", mat_stone_hi, Vector3(0.0, 0.22, -3.08), Vector3(0.82, 0.82, 0.82))
	for i in range(4):
		var x := -2.45 + float(i) * 1.63
		var z := -0.85 if i % 2 == 0 else -1.18
		_place_meta_asset(stage_root, "VaultChest%dAsset" % i, "chest", mat_gold if i in [1, 2] else mat_stone_hi, Vector3(x, 0.18, z), Vector3(0.74, 0.74, 0.74))
	_place_environment_asset(stage_root, "VaultPillarLAsset", "pillar", mat_stone_mid, Vector3(-3.20, 0.04, -3.00), Vector3(0.72, 0.94, 0.72))
	_place_environment_asset(stage_root, "VaultPillarRAsset", "pillar", mat_stone_mid, Vector3(3.20, 0.04, -3.00), Vector3(0.72, 0.94, 0.72))
	_place_environment_asset(stage_root, "VaultBrazierLAsset", "brazier", mat_brass, Vector3(-2.82, 2.46, -2.48), Vector3(0.56, 0.56, 0.56))
	_place_environment_asset(stage_root, "VaultBrazierRAsset", "brazier", mat_brass, Vector3(2.82, 2.46, -2.48), Vector3(0.56, 0.56, 0.56))
	_add_environment_light("VaultGoldKey", Vector3(0.0, 2.35, -1.55), Color("ffc85d"), 0.72, 4.3)
	_add_environment_light("VaultWarmL", Vector3(-2.65, 2.55, -2.05), Color("ff9f4c"), 0.48, 3.0)
	_add_environment_light("VaultWarmR", Vector3(2.65, 2.55, -2.05), Color("ff9f4c"), 0.48, 3.0)

func _build_missions_stage() -> void:
	_place_meta_asset(stage_root, "MissionTableAsset", "mission_table", mat_stone_hi, Vector3(0.0, 0.04, -0.55), Vector3(0.82, 0.82, 0.82))
	_place_meta_asset(stage_root, "MissionBoardLAsset", "mission_board", mat_green, Vector3(-2.45, 0.10, -2.83), Vector3(0.72, 0.72, 0.72))
	_place_meta_asset(stage_root, "MissionBoardRAsset", "mission_board", mat_green, Vector3(2.45, 0.10, -2.83), Vector3(0.72, 0.72, 0.72))
	_place_environment_asset(stage_root, "MissionPortalAsset", "portal", mat_stone_mid, Vector3(0.0, 0.12, -3.12), Vector3(1.10, 1.06, 1.10))
	_add_environment_light("MissionGreenKey", Vector3(-2.4, 2.35, -1.35), Color("56d99d"), 0.58, 3.8)
	_add_environment_light("MissionWarmFill", Vector3(2.5, 2.10, -1.20), Color("e3b06a"), 0.40, 3.2)

func _build_pass_stage() -> void:
	_place_meta_asset(stage_root, "PassShrineAsset", "pass_shrine", mat_stone_hi, Vector3(0.0, 0.08, -2.72), Vector3(0.92, 0.92, 0.92))
	_place_environment_asset(stage_root, "PassBannerLAsset", "banner", mat_cloth, Vector3(-2.35, 2.12, -2.48), Vector3(0.78, 0.78, 0.78))
	_place_environment_asset(stage_root, "PassBannerRAsset", "banner", mat_cloth, Vector3(2.35, 2.12, -2.48), Vector3(0.78, 0.78, 0.78))
	_place_environment_asset(stage_root, "PassPedestalAsset", "pedestal", mat_dark_metal, Vector3(0.0, 0.18, -0.10), Vector3(0.70, 0.70, 0.70))
	_add_environment_light("PassPurpleKey", Vector3(0.0, 2.65, -1.10), Color("a765ff"), 0.78, 4.2)
	_add_environment_light("PassGoldRim", Vector3(2.1, 2.10, 0.55), Color("ffd26e"), 0.44, 3.2)

func _build_store_stage() -> void:
	_place_meta_asset(stage_root, "StoreCounterAsset", "store_counter", mat_dark_metal, Vector3(0.0, 0.02, -2.12), Vector3(0.84, 0.84, 0.84))
	_place_environment_asset(stage_root, "StorePedestalLAsset", "pedestal", mat_brass, Vector3(-2.45, 0.10, -0.30), Vector3(0.54, 0.54, 0.54))
	_place_environment_asset(stage_root, "StorePedestalRAsset", "pedestal", mat_brass, Vector3(2.45, 0.10, -0.30), Vector3(0.54, 0.54, 0.54))
	_place_environment_asset(stage_root, "StoreBrazierLAsset", "brazier", mat_dark_metal, Vector3(-2.75, 2.55, -2.36), Vector3(0.56, 0.56, 0.56))
	_place_environment_asset(stage_root, "StoreBrazierRAsset", "brazier", mat_dark_metal, Vector3(2.75, 2.55, -2.36), Vector3(0.56, 0.56, 0.56))
	_add_environment_light("StoreWarmKey", Vector3(-1.8, 2.60, -1.20), Color("ffb257"), 0.66, 4.0)
	_add_environment_light("StorePurpleFill", Vector3(2.2, 2.20, -1.00), Color("8e65d6"), 0.42, 3.5)

func _camera_position_for(screen: String) -> Vector3:
	match screen:
		"talents": return Vector3(0.0, 2.95, 10.30)
		"vault": return Vector3(0.0, 2.88, 10.35)
		"missions": return Vector3(0.0, 3.05, 10.65)
		"pass": return Vector3(0.0, 2.98, 10.20)
		"store": return Vector3(0.0, 2.88, 10.45)
		_: return super._camera_position_for(screen)

func _camera_target_for(screen: String) -> Vector3:
	match screen:
		"talents": return Vector3(0.0, 2.18, -1.15)
		"vault": return Vector3(0.0, 2.22, -1.65)
		"missions": return Vector3(0.0, 2.08, -1.20)
		"pass": return Vector3(0.0, 2.28, -1.35)
		"store": return Vector3(0.0, 2.05, -1.35)
		_: return super._camera_target_for(screen)
