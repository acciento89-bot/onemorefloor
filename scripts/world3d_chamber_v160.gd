extends "res://scripts/world3d_chamber_v154.gd"

# ONE MORE FLOOR v1.60 — authored tower environment layer.
# Keeps the proven v1.54 real-model combat authority and all v1.45-v1.53 realm
# logic intact, while adding imported OBJ silhouettes to every ten-floor realm.

const TOWER_ENV_VERSION := "1.60"
const TOWER_ENV_ROOT := "res://assets/environment/v160/"
const TOWER_ASSETS := {
	"lower_arch": TOWER_ENV_ROOT + "tower_arch.obj",
	"ossuary_totem": TOWER_ENV_ROOT + "ossuary_totem.obj",
	"iron_buttress": TOWER_ENV_ROOT + "iron_buttress.obj",
	"rift_crystal": TOWER_ENV_ROOT + "rift_crystal.obj",
	"spire_column": TOWER_ENV_ROOT + "spire_column.obj",
	"gothic_pillar": "res://assets/environment/v159/gothic_pillar.obj",
	"wall_brazier": "res://assets/environment/v159/wall_brazier.obj",
}

var authored_tower_root: Node3D
var authored_realm_roots: Dictionary = {}
var tower_mesh_cache: Dictionary = {}
var tower_asset_instances := 0
var tower_asset_paths: Array[String] = []
var authored_realm := ""

var tower_lower_mat: StandardMaterial3D
var tower_bone_mat: StandardMaterial3D
var tower_iron_mat: StandardMaterial3D
var tower_rift_mat: StandardMaterial3D
var tower_spire_mat: StandardMaterial3D
var tower_brass_mat: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_build_authored_tower_materials()
	_build_authored_tower_environment()

func authored_tower_environment_ready() -> bool:
	if not real_model_intake_ready() or authored_tower_root == null:
		return false
	for path in TOWER_ASSETS.values():
		if not ResourceLoader.exists(String(path)):
			return false
	for key in ["lower_halls", "ossuary", "iron_bastion", "rift_descent", "starless_spire"]:
		var root_node := authored_realm_roots.get(key) as Node3D
		if root_node == null or root_node.get_child_count() <= 0:
			return false
	return tower_asset_instances >= 20

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["authored_tower_environment_ready"] = authored_tower_environment_ready()
	data["authored_tower_environment_version"] = TOWER_ENV_VERSION
	data["authored_tower_realm"] = authored_realm
	data["authored_tower_asset_instances"] = tower_asset_instances
	data["authored_tower_asset_paths"] = tower_asset_paths.duplicate()
	return data

func _apply_floor_identity(floor_no: int) -> void:
	super._apply_floor_identity(floor_no)
	_sync_authored_realm(floor_no)

func _build_authored_tower_materials() -> void:
	tower_lower_mat = _material(Color("34384a"), 0.18, 0.66)
	tower_bone_mat = _material(Color("b9b29d"), 0.04, 0.84)
	tower_iron_mat = _material(Color("3c414c"), 0.72, 0.32)
	tower_rift_mat = _emissive_material(Color("8d4bd6"), 1.25)
	tower_spire_mat = _material(Color("252a38"), 0.34, 0.54)
	tower_brass_mat = _material(Color("9d6b2f"), 0.68, 0.30)

func _build_authored_tower_environment() -> void:
	authored_tower_root = Node3D.new()
	authored_tower_root.name = "AuthoredTowerEnvironmentV160"
	add_child(authored_tower_root)

	for key in ["lower_halls", "ossuary", "iron_bastion", "rift_descent", "starless_spire"]:
		var root_node := Node3D.new()
		root_node.name = "Authored_%s" % key
		root_node.visible = false
		authored_tower_root.add_child(root_node)
		authored_realm_roots[key] = root_node

	_build_lower_authored(authored_realm_roots["lower_halls"] as Node3D)
	_build_ossuary_authored(authored_realm_roots["ossuary"] as Node3D)
	_build_iron_authored(authored_realm_roots["iron_bastion"] as Node3D)
	_build_rift_authored(authored_realm_roots["rift_descent"] as Node3D)
	_build_spire_authored(authored_realm_roots["starless_spire"] as Node3D)

func _build_lower_authored(root_node: Node3D) -> void:
	_place_tower_asset(root_node, "LowerArchAsset", "lower_arch", tower_lower_mat, Vector3(0.0, 0.02, -6.62), Vector3(0.86, 0.86, 0.86))
	for side in [-1.0, 1.0]:
		for z in [-4.6, -0.9, 2.8]:
			_place_tower_asset(root_node, "LowerPillarAsset", "gothic_pillar", tower_lower_mat, Vector3(side * 4.48, 0.02, z), Vector3(0.62, 0.78, 0.62), Vector3(0.0, 0.0, 0.0))
		_place_tower_asset(root_node, "LowerBrazierAsset", "wall_brazier", tower_brass_mat, Vector3(side * 4.12, 1.88, -3.0), Vector3(0.52, 0.52, 0.52))

func _build_ossuary_authored(root_node: Node3D) -> void:
	for side in [-1.0, 1.0]:
		for z in [-4.8, -1.2, 2.6]:
			var totem := _place_tower_asset(root_node, "OssuaryTotemAsset", "ossuary_totem", tower_bone_mat, Vector3(side * 4.28, 0.02, z), Vector3(0.58, 0.72, 0.58))
			if totem != null:
				totem.rotation.y = -side * 0.10
	_place_tower_asset(root_node, "OssuaryRearTotemL", "ossuary_totem", tower_bone_mat, Vector3(-2.25, 0.02, -6.35), Vector3(0.72, 0.82, 0.72))
	_place_tower_asset(root_node, "OssuaryRearTotemR", "ossuary_totem", tower_bone_mat, Vector3(2.25, 0.02, -6.35), Vector3(0.72, 0.82, 0.72))

func _build_iron_authored(root_node: Node3D) -> void:
	for side in [-1.0, 1.0]:
		for z in [-4.7, -1.0, 2.7]:
			_place_tower_asset(root_node, "IronButtressAsset", "iron_buttress", tower_iron_mat, Vector3(side * 4.35, 0.02, z), Vector3(0.62, 0.78, 0.62))
	_place_tower_asset(root_node, "IronRearButtressL", "iron_buttress", tower_iron_mat, Vector3(-2.35, 0.02, -6.42), Vector3(0.72, 0.84, 0.72))
	_place_tower_asset(root_node, "IronRearButtressR", "iron_buttress", tower_iron_mat, Vector3(2.35, 0.02, -6.42), Vector3(0.72, 0.84, 0.72))

func _build_rift_authored(root_node: Node3D) -> void:
	for side in [-1.0, 1.0]:
		for index in range(3):
			var z := -4.5 + float(index) * 3.6
			var crystal := _place_tower_asset(root_node, "RiftCrystalAsset", "rift_crystal", tower_rift_mat, Vector3(side * (4.0 + 0.18 * float(index % 2)), 0.04, z), Vector3(0.46, 0.58 + 0.05 * float(index), 0.46))
			if crystal != null:
				crystal.rotation.z = -side * (0.12 + float(index) * 0.025)
	_place_tower_asset(root_node, "RiftRearCrystal", "rift_crystal", tower_rift_mat, Vector3(0.0, 0.04, -6.48), Vector3(0.72, 0.82, 0.72))

func _build_spire_authored(root_node: Node3D) -> void:
	for side in [-1.0, 1.0]:
		for index in range(3):
			var z := -4.7 + float(index) * 3.7
			var column := _place_tower_asset(root_node, "SpireColumnAsset", "spire_column", tower_spire_mat, Vector3(side * 4.18, 0.02, z), Vector3(0.54, 0.72 + float(index) * 0.04, 0.54))
			if column != null:
				column.rotation.z = -side * 0.035
	_place_tower_asset(root_node, "SpireRearColumnL", "spire_column", tower_spire_mat, Vector3(-2.15, 0.02, -6.48), Vector3(0.68, 0.82, 0.68))
	_place_tower_asset(root_node, "SpireRearColumnR", "spire_column", tower_spire_mat, Vector3(2.15, 0.02, -6.48), Vector3(0.68, 0.82, 0.68))

func _sync_authored_realm(floor_no: int) -> void:
	var key := "lower_halls"
	if floor_no >= 41:
		key = "starless_spire"
	elif floor_no >= 31:
		key = "rift_descent"
	elif floor_no >= 21:
		key = "iron_bastion"
	elif floor_no >= 11:
		key = "ossuary"
	authored_realm = key
	for realm_key in authored_realm_roots.keys():
		var root_node := authored_realm_roots[realm_key] as Node3D
		if root_node != null:
			root_node.visible = String(realm_key) == key

func _load_tower_mesh(path: String) -> Mesh:
	if tower_mesh_cache.has(path):
		return tower_mesh_cache[path] as Mesh
	var mesh := load(path) as Mesh
	if mesh != null:
		tower_mesh_cache[path] = mesh
	return mesh

func _place_tower_asset(
	parent: Node3D,
	node_name: String,
	asset_key: String,
	material: Material,
	pos: Vector3,
	scale_value: Vector3 = Vector3.ONE,
	rot: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var path := String(TOWER_ASSETS.get(asset_key, ""))
	var mesh := _load_tower_mesh(path)
	if mesh == null:
		push_warning("v1.60 tower environment asset failed to load: %s" % path)
		return null
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.scale = scale_value
	instance.rotation = rot
	parent.add_child(instance)
	tower_asset_instances += 1
	if path not in tower_asset_paths:
		tower_asset_paths.append(path)
	return instance
