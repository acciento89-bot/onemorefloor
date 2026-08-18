extends "res://scripts/world3d_chamber_v160.gd"

# ONE MORE FLOOR v1.60 — production floor/material composition pass.
# Presentation only: replaces inherited prototype floor/shell geometry with
# lower-profile realm-specific surfaces while gameplay/runtime stays inherited.

const FLOOR_POLISH_VERSION := "1.60-floor-production"

var floor_polish_root: Node3D
var floor_polish_tiles := 0
var floor_grid_hidden := 0
var legacy_shell_hidden := 0
var legacy_realm_blockouts_hidden := 0

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
	legacy_shell_hidden = _hide_legacy_chamber_shell()
	legacy_realm_blockouts_hidden = _hide_legacy_realm_blockouts()
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
	data["legacy_shell_hidden"] = legacy_shell_hidden
	data["legacy_realm_blockouts_hidden"] = legacy_realm_blockouts_hidden
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
		if is_long_floor_strip and mesh_instance.visible:
			mesh_instance.visible = false
			hidden += 1
	return hidden

func _hide_legacy_chamber_shell() -> int:
	# Keep the base floor/back wall and all runtime nodes. Only retire the generic
	# rectangular gate/pillar blockout that sat underneath every authored realm.
	var hidden: int = 0
	for node_name_value in ["BackTrim", "GateLeft", "GateRight", "GateHeader", "GateInset", "Threshold"]:
		var node_name: String = String(node_name_value)
		var node := get_node_or_null(node_name) as Node3D
		if node != null and node.visible:
			node.visible = false
			hidden += 1

	for child in get_children():
		var mesh_instance := child as MeshInstance3D
		if mesh_instance != null and mesh_instance.mesh is BoxMesh:
			var box := mesh_instance.mesh as BoxMesh
			var size: Vector3 = box.size
			# Catch every auto-renamed vertical gate bar.
			var gate_bar: bool = size.x <= 0.12 and size.y >= 2.0 and size.z <= 0.16 and mesh_instance.position.z <= -6.0
			if gate_bar and mesh_instance.visible:
				mesh_instance.visible = false
				hidden += 1
			continue
		var child_3d := child as Node3D
		if child_3d != null and child_3d.visible and _has_direct_child_signature(child_3d, ["Base", "Column", "Cap", "Rune"]):
			# Eight original generic Pillar groups; authored v1.60 realm dressing now
			# owns those silhouettes and their lighting instead.
			child_3d.visible = false
			hidden += 1
	return hidden

func _hide_legacy_realm_blockouts() -> int:
	var hidden: int = 0
	hidden += _cleanup_ossuary_blockouts()
	hidden += _cleanup_iron_blockouts()
	hidden += _cleanup_rift_blockouts()
	hidden += _cleanup_starless_blockouts()
	return hidden

func _cleanup_ossuary_blockouts() -> int:
	if ossuary_root == null:
		return 0
	var hidden: int = 0
	for child in ossuary_root.get_children():
		var mesh_instance := child as MeshInstance3D
		if mesh_instance != null and mesh_instance.mesh is BoxMesh:
			var box := mesh_instance.mesh as BoxMesh
			var size: Vector3 = box.size
			var old_channel: bool = size.y <= 0.040 and size.x <= 0.26 and size.z >= 10.0
			var old_grate: bool = size.y <= 0.050 and size.x >= 0.62 and size.x <= 0.78 and size.z <= 0.12
			if (old_channel or old_grate) and mesh_instance.visible:
				mesh_instance.visible = false
				hidden += 1
			continue
		var child_3d := child as Node3D
		if child_3d != null and child_3d.visible and _has_direct_child_signature(child_3d, ["Column", "SkullCap", "Rune"]):
			# The old cone pylons are replaced by the richer reliquary-totem OBJ set.
			child_3d.visible = false
			hidden += 1
	return hidden

func _cleanup_iron_blockouts() -> int:
	if iron_bastion_root == null:
		return 0
	var hidden: int = 0
	for child in iron_bastion_root.get_children():
		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null:
			continue
		if mesh_instance.mesh is BoxMesh:
			var box := mesh_instance.mesh as BoxMesh
			var size: Vector3 = box.size
			var old_channel: bool = size.y <= 0.060 and size.x <= 0.34 and size.z >= 10.0
			var old_crossbar: bool = size.y <= 0.075 and size.x >= 0.74 and size.x <= 0.90 and size.z <= 0.16
			if (old_channel or old_crossbar) and mesh_instance.visible:
				mesh_instance.visible = false
				hidden += 1
		elif mesh_instance.mesh is SphereMesh:
			# Flat ash-heap spheres read as placeholder ellipses in portrait.
			var old_ash_heap: bool = mesh_instance.position.y <= 0.15 and mesh_instance.scale.y <= 0.50 and mesh_instance.scale.x >= 1.20
			if old_ash_heap and mesh_instance.visible:
				mesh_instance.visible = false
				hidden += 1
	return hidden

func _cleanup_rift_blockouts() -> int:
	if rift_root == null:
		return 0
	var hidden: int = 0
	for child in rift_root.get_children():
		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null or not (mesh_instance.mesh is BoxMesh):
			continue
		var box := mesh_instance.mesh as BoxMesh
		var size: Vector3 = box.size
		var old_slab: bool = size.y <= 0.12 and size.x >= 4.40 and size.z >= 1.0 and size.z <= 1.35
		var old_seam: bool = size.y <= 0.025 and size.x >= 3.50 and size.z <= 0.08
		if (old_slab or old_seam) and mesh_instance.visible:
			mesh_instance.visible = false
			hidden += 1
	return hidden

func _cleanup_starless_blockouts() -> int:
	if starless_root == null:
		return 0
	var hidden: int = 0
	for child in starless_root.get_children():
		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null or not (mesh_instance.mesh is BoxMesh):
			continue
		var box := mesh_instance.mesh as BoxMesh
		var size: Vector3 = box.size
		var old_causeway: bool = size.y <= 0.12 and size.x >= 4.40 and size.z >= 10.0
		var old_spire: bool = size.x >= 0.55 and size.x <= 0.70 and size.y >= 2.20 and size.z >= 0.65 and size.z <= 0.80 and abs(mesh_instance.position.x) >= 4.0
		var old_spire_edge: bool = size.x <= 0.09 and size.y >= 1.50 and size.z <= 0.08 and abs(mesh_instance.position.x) >= 3.70
		if (old_causeway or old_spire or old_spire_edge) and mesh_instance.visible:
			mesh_instance.visible = false
			hidden += 1
	return hidden

func _has_direct_child_signature(parent: Node, required_names: Array) -> bool:
	for required_value in required_names:
		var required_name: String = String(required_value)
		if parent.get_node_or_null(required_name) == null:
			return false
	return true

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
	for row in range(5):
		var z: float = -5.15 + float(row) * 2.58
		var offset: float = 0.16 if row % 2 == 0 else -0.12
		for col in range(3):
			var x: float = -3.02 + float(col) * 3.02 + offset
			var mat: StandardMaterial3D = lower_floor_a if (row + col) % 2 == 0 else lower_floor_b
			_add_floor_slab(root_node, "LowerFlagstone", Vector2(2.72, 2.26), Vector2(x, z), mat, 0.010 * float((row + col) % 3 - 1))

func _build_ossuary_floor(root_node: Node3D) -> void:
	for row in range(4):
		var z: float = -4.85 + float(row) * 3.12
		for side_value in [-1.0, 1.0]:
			var side: float = float(side_value)
			var x: float = side * (2.18 + (0.10 if row % 2 == 0 else -0.08))
			var side_index: int = 0 if side < 0.0 else 1
			var mat: StandardMaterial3D = ossuary_floor_a if (row + side_index) % 2 == 0 else ossuary_floor_b
			_add_floor_slab(root_node, "OssuaryCryptSlab", Vector2(3.70, 2.72), Vector2(x, z), mat, side * 0.012)
	for z_value in [-3.35, 0.15, 3.65]:
		var z: float = float(z_value)
		_add_floor_slab(root_node, "OssuaryGraveMarker", Vector2(1.28, 1.95), Vector2(0.18, z), ossuary_floor_b, -0.025)

func _build_iron_floor(root_node: Node3D) -> void:
	for row in range(4):
		var z: float = -4.75 + float(row) * 3.10
		var offset: float = 0.18 if row % 2 == 1 else -0.12
		for col in range(3):
			var x: float = -3.0 + float(col) * 3.0 + offset
			var use_oxidized: bool = (row == 1 and col == 2) or (row == 3 and col == 0)
			var mat: StandardMaterial3D = iron_floor_b if use_oxidized else iron_floor_a
			_add_floor_slab(root_node, "IronDeckPlate", Vector2(2.72, 2.66), Vector2(x, z), mat, 0.006 * float(col - 1))
	for z_value in [-3.15, 2.95]:
		var z: float = float(z_value)
		_add_floor_slab(root_node, "IronBracePlate", Vector2(6.25, 0.34), Vector2(0.0, z), iron_floor_b, 0.0, 0.058)

func _build_rift_floor(root_node: Node3D) -> void:
	for index in range(7):
		var z: float = -5.15 + float(index) * 1.70
		var x: float = sin(float(index) * 1.55) * 0.28
		var width: float = 5.75 - float(index % 3) * 0.42
		var mat: StandardMaterial3D = rift_floor_a if index % 2 == 0 else rift_floor_b
		_add_floor_slab(root_node, "RiftBrokenSlab", Vector2(width, 1.36), Vector2(x, z), mat, sin(float(index)) * 0.028)

func _build_spire_floor(root_node: Node3D) -> void:
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
