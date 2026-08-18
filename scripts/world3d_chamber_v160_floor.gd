extends "res://scripts/world3d_chamber_v160.gd"

# ONE MORE FLOOR v1.60 — production floor/material composition pass.
# Presentation only: hides the legacy prototype grid strips and adds low-profile
# realm-specific floor dressing below all gameplay actors and telegraphs.

const FLOOR_POLISH_VERSION := "1.60-floor-production"

var floor_polish_root: Node3D
var floor_polish_tiles := 0
var floor_grid_hidden := 0

var lower_floor_a: StandardMaterial3D
var lower_floor_b: StandardMaterial3D
var ossuary_floor_a: StandardMaterial3D
var ossuary_floor_b: StandardMaterial3D
var iron_floor_a: StandardMaterial3D
var iron_floor_b: StandardMaterial3D
var rift_floor_a: StandardMaterial3D
var rift_floor_b: StandardMaterial3D
var spire_floor_a: StandardMaterial3D
var spire_floor_b: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_build_floor_polish_materials()
	floor_grid_hidden = _hide_legacy_prototype_grid()
	_build_realm_floor_dressing()

func production_floor_ready() -> bool:
	return authored_tower_environment_ready() \
		and floor_polish_root != null \
		and floor_grid_hidden >= 9 \
		and floor_polish_tiles >= 45

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_floor_ready"] = production_floor_ready()
	data["production_floor_version"] = FLOOR_POLISH_VERSION
	data["prototype_grid_hidden"] = floor_grid_hidden
	data["production_floor_tiles"] = floor_polish_tiles
	return data

func _build_floor_polish_materials() -> void:
	lower_floor_a = _material(Color("191b24"), 0.10, 0.90)
	lower_floor_b = _material(Color("232530"), 0.13, 0.82)
	ossuary_floor_a = _material(Color("171b1d"), 0.06, 0.94)
	ossuary_floor_b = _material(Color("25282a"), 0.08, 0.90)
	iron_floor_a = _material(Color("191b1f"), 0.76, 0.42)
	iron_floor_b = _material(Color("2b2724"), 0.66, 0.50)
	rift_floor_a = _material(Color("0c0b14"), 0.12, 0.92)
	rift_floor_b = _material(Color("171021"), 0.16, 0.84)
	spire_floor_a = _material(Color("090c13"), 0.34, 0.74)
	spire_floor_b = _material(Color("111522"), 0.38, 0.66)

func _hide_legacy_prototype_grid() -> int:
	var hidden: int = 0
	for child in get_children():
		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null or not (mesh_instance.mesh is BoxMesh):
			continue
		var box := mesh_instance.mesh as BoxMesh
		var size: Vector3 = box.size
		var is_long_floor_strip: bool = size.y <= 0.055 and (size.x >= 7.0 or size.z >= 10.0)
		if is_long_floor_strip:
			mesh_instance.visible = false
			hidden += 1
	return hidden

func _build_realm_floor_dressing() -> void:
	floor_polish_root = Node3D.new()
	floor_polish_root.name = "ProductionFloorDressingV160"
	add_child(floor_polish_root)

	_build_lower_floor(authored_realm_roots["lower_halls"] as Node3D)
	_build_ossuary_floor(authored_realm_roots["ossuary"] as Node3D)
	_build_iron_floor(authored_realm_roots["iron_bastion"] as Node3D)
	_build_rift_floor(authored_realm_roots["rift_descent"] as Node3D)
	_build_spire_floor(authored_realm_roots["starless_spire"] as Node3D)

func _build_lower_floor(root_node: Node3D) -> void:
	# Broad, staggered flagstones replace the perfectly uniform debug grid.
	for row in range(5):
		var z: float = -5.15 + float(row) * 2.58
		var offset: float = 0.16 if row % 2 == 0 else -0.12
		for col in range(3):
			var x: float = -3.02 + float(col) * 3.02 + offset
			var mat: StandardMaterial3D = lower_floor_a if (row + col) % 2 == 0 else lower_floor_b
			_add_floor_slab(root_node, "LowerFlagstone", Vector2(2.72, 2.26), Vector2(x, z), mat, 0.010 * float((row + col) % 3 - 1))

func _build_ossuary_floor(root_node: Node3D) -> void:
	# Large crypt plates create a solemn central nave instead of tile-grid noise.
	for row in range(4):
		var z: float = -4.85 + float(row) * 3.12
		for side_value in [-1.0, 1.0]:
			var side: float = float(side_value)
			var x: float = side * (2.18 + (0.10 if row % 2 == 0 else -0.08))
			var side_index: int = 0 if side < 0.0 else 1
			var mat: StandardMaterial3D = ossuary_floor_a if (row + side_index) % 2 == 0 else ossuary_floor_b
			_add_floor_slab(root_node, "OssuaryCryptSlab", Vector2(3.70, 2.72), Vector2(x, z), mat, side * 0.012)
	# Narrow, offset grave markers break the central axis without becoming a grid.
	for z_value in [-3.35, 0.15, 3.65]:
		var z: float = float(z_value)
		_add_floor_slab(root_node, "OssuaryGraveMarker", Vector2(1.28, 1.95), Vector2(0.18, z), ossuary_floor_b, -0.025)

func _build_iron_floor(root_node: Node3D) -> void:
	# Heavy staggered steel deck plates with occasional oxidized replacements.
	for row in range(4):
		var z: float = -4.75 + float(row) * 3.10
		var offset: float = 0.18 if row % 2 == 1 else -0.12
		for col in range(3):
			var x: float = -3.0 + float(col) * 3.0 + offset
			var use_oxidized: bool = (row == 1 and col == 2) or (row == 3 and col == 0)
			var mat: StandardMaterial3D = iron_floor_b if use_oxidized else iron_floor_a
			_add_floor_slab(root_node, "IronDeckPlate", Vector2(2.72, 2.66), Vector2(x, z), mat, 0.006 * float(col - 1))
	# Short transverse brace plates read as fabrication detail, not editor graph paper.
	for z_value in [-3.15, 2.95]:
		var z: float = float(z_value)
		_add_floor_slab(root_node, "IronBracePlate", Vector2(6.25, 0.34), Vector2(0.0, z), iron_floor_b, 0.0, 0.058)

func _build_rift_floor(root_node: Node3D) -> void:
	# Broken central slabs with uneven width/offset let the void identity breathe.
	for index in range(7):
		var z: float = -5.15 + float(index) * 1.70
		var x: float = sin(float(index) * 1.55) * 0.28
		var width: float = 5.75 - float(index % 3) * 0.42
		var mat: StandardMaterial3D = rift_floor_a if index % 2 == 0 else rift_floor_b
		_add_floor_slab(root_node, "RiftBrokenSlab", Vector2(width, 1.36), Vector2(x, z), mat, sin(float(index)) * 0.028)

func _build_spire_floor(root_node: Node3D) -> void:
	# Narrow obsidian causeway: darker side void and larger uninterrupted shapes.
	for index in range(6):
		var z: float = -4.85 + float(index) * 2.05
		var x: float = 0.10 if index % 2 == 0 else -0.08
		var mat: StandardMaterial3D = spire_floor_a if index % 2 == 0 else spire_floor_b
		_add_floor_slab(root_node, "SpireCausewayPanel", Vector2(5.70, 1.72), Vector2(x, z), mat, 0.008 * float(index % 3 - 1))
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		_add_floor_slab(root_node, "SpireEdgeRun", Vector2(0.72, 10.8), Vector2(side * 3.22, 0.15), spire_floor_b, side * 0.012, 0.052)

func _add_floor_slab(
	parent: Node3D,
	node_name: String,
	size_xz: Vector2,
	pos_xz: Vector2,
	material: Material,
	rotation_y: float = 0.0,
	height: float = 0.045
) -> MeshInstance3D:
	var slab: MeshInstance3D = _add_box(
		parent,
		node_name,
		Vector3(size_xz.x, height, size_xz.y),
		Vector3(pos_xz.x, -0.027, pos_xz.y),
		material
	)
	slab.rotation.y = rotation_y
	floor_polish_tiles += 1
	return slab
