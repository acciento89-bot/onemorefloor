extends "res://scripts/world3d_chamber_v160_floor.gd"

# ONE MORE FLOOR v1.60 — authored focal-point replacement layer.
# Replaces/frames the last obvious center-stage blockouts while preserving the
# inherited lights, animated cores, combat authority and realm switching.

const FOCAL_VERSION := "1.60-authored-focals"
const FOCAL_ROOT := "res://assets/environment/v160/"
const FOCAL_ASSETS := {
	"ossuary_altar": FOCAL_ROOT + "ossuary_altar.obj",
	"forge_engine": FOCAL_ROOT + "forge_engine.obj",
	"rift_anchor": FOCAL_ROOT + "rift_anchor.obj",
	"starwell_dais": FOCAL_ROOT + "starwell_dais.obj",
}

var focal_asset_instances := 0
var focal_asset_paths: Array[String] = []
var focal_mesh_cache: Dictionary = {}

var focal_bone_mat: StandardMaterial3D
var focal_iron_mat: StandardMaterial3D
var focal_rift_mat: StandardMaterial3D
var focal_spire_mat: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_build_focal_materials()
	_build_authored_focal_points()

func production_focal_ready() -> bool:
	if not production_floor_ready():
		return false
	for path in FOCAL_ASSETS.values():
		if not ResourceLoader.exists(String(path)):
			return false
	return focal_asset_instances == 4

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_focal_ready"] = production_focal_ready()
	data["production_focal_version"] = FOCAL_VERSION
	data["production_focal_instances"] = focal_asset_instances
	data["production_focal_paths"] = focal_asset_paths.duplicate()
	return data

func _build_focal_materials() -> void:
	focal_bone_mat = _material(Color("625f58"), 0.05, 0.91)
	focal_iron_mat = _material(Color("252a31"), 0.78, 0.34)
	focal_rift_mat = _material(Color("21182d"), 0.18, 0.76)
	focal_spire_mat = _material(Color("111725"), 0.42, 0.62)

func _build_authored_focal_points() -> void:
	# Ossuary: retire the old altar block if present; its realm lighting is kept.
	var old_altar := ossuary_root.get_node_or_null("Altar") as Node3D if ossuary_root != null else null
	if old_altar != null:
		old_altar.visible = false
	_place_focal_asset(
		authored_realm_roots["ossuary"] as Node3D,
		"OssuaryReliquaryAltarV160",
		"ossuary_altar",
		focal_bone_mat,
		Vector3(0.0, 0.02, -5.28),
		Vector3(0.72, 0.72, 0.72)
	)

	# Iron Bastion: the new engine frames the inherited molten/core presentation.
	_place_focal_asset(
		authored_realm_roots["iron_bastion"] as Node3D,
		"IronForgeEngineV160",
		"forge_engine",
		focal_iron_mat,
		Vector3(0.0, 0.02, -5.16),
		Vector3(0.66, 0.66, 0.66)
	)

	# Rift: leave the animated inherited rift core alive inside a real anchor gate.
	_place_focal_asset(
		authored_realm_roots["rift_descent"] as Node3D,
		"RiftAnchorGateV160",
		"rift_anchor",
		focal_rift_mat,
		Vector3(0.0, 0.02, -5.18),
		Vector3(0.76, 0.76, 0.76)
	)

	# Starless: the existing animated star core + true torus rings sit on a new dais.
	_place_focal_asset(
		authored_realm_roots["starless_spire"] as Node3D,
		"StarwellDaisV160",
		"starwell_dais",
		focal_spire_mat,
		Vector3(0.0, 0.02, -5.48),
		Vector3(0.72, 0.72, 0.72)
	)

func _load_focal_mesh(path: String) -> Mesh:
	if focal_mesh_cache.has(path):
		return focal_mesh_cache[path] as Mesh
	var mesh := load(path) as Mesh
	if mesh != null:
		focal_mesh_cache[path] = mesh
	return mesh

func _place_focal_asset(
	parent: Node3D,
	node_name: String,
	asset_key: String,
	material: Material,
	pos: Vector3,
	scale_value: Vector3
) -> MeshInstance3D:
	var path := String(FOCAL_ASSETS.get(asset_key, ""))
	var mesh := _load_focal_mesh(path)
	if mesh == null:
		push_warning("v1.60 focal asset failed to load: %s" % path)
		return null
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.scale = scale_value
	parent.add_child(instance)
	focal_asset_instances += 1
	if path not in focal_asset_paths:
		focal_asset_paths.append(path)
	return instance
