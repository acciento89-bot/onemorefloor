extends "res://scripts/world3d_chamber_v142.gd"

# ONE MORE FLOOR v1.43 - Ossuary 3D realm kit for floors 11-20.
# The same gameplay bridge, rig pipeline and production VFX stay authoritative;
# only realm presentation changes when the run crosses floor 10.

const OSSUARY_MIN_FLOOR := 11
const OSSUARY_MAX_FLOOR := 20

var ossuary_root: Node3D
var ossuary_active := false
var ossuary_sigil_material: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_build_ossuary_kit()

func _process(delta: float) -> void:
	super._process(delta)
	if ossuary_active:
		_animate_ossuary(delta)

func ossuary_ready() -> bool:
	return rig_pipeline_ready() \
		and ossuary_root != null \
		and ossuary_root.get_node_or_null("BoneAltar") != null \
		and ossuary_root.get_node_or_null("OssuaryColdLight") != null

func is_ossuary_floor(floor_no: int) -> bool:
	return floor_no >= OSSUARY_MIN_FLOOR and floor_no <= OSSUARY_MAX_FLOOR

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["ossuary_ready"] = ossuary_ready()
	data["ossuary_active"] = ossuary_active
	data["realm"] = "ossuary" if ossuary_active else "lower_halls"
	return data

func _apply_floor_identity(floor_no: int) -> void:
	super._apply_floor_identity(floor_no)
	_set_ossuary_active(is_ossuary_floor(floor_no))
	if ossuary_active:
		var depth := clampf(float(floor_no - OSSUARY_MIN_FLOOR) / 9.0, 0.0, 1.0)
		mat_floor.albedo_color = Color("101719").lerp(Color("15111b"), depth * 0.55)
		mat_wall.albedo_color = Color("202a2b").lerp(Color("2b2231"), depth * 0.42)
		mat_trim.albedo_color = Color("545d5b").lerp(Color("665270"), depth * 0.34)
	else:
		mat_trim.albedo_color = Color("66596b")

func _set_ossuary_active(value: bool) -> void:
	ossuary_active = value
	if ossuary_root != null:
		ossuary_root.visible = value
	if production_details_root != null:
		production_details_root.visible = not value
	for light_name in ["WarmTorchLight", "ArcaneLight", "ProductionRim", "GateGoldPool"]:
		var node := get_node_or_null(light_name) as Node3D
		if node != null:
			node.visible = not value

func _build_ossuary_kit() -> void:
	ossuary_root = Node3D.new()
	ossuary_root.name = "OssuaryRealm"
	ossuary_root.visible = false
	add_child(ossuary_root)

	var crypt_stone := _material(Color("1b2425"), 0.10, 0.92)
	var crypt_edge := _material(Color("475152"), 0.24, 0.67)
	var bone := _material(Color("c5c0aa"), 0.02, 0.88)
	var old_bone := _material(Color("817c69"), 0.03, 0.92)
	var black_iron := _material(Color("17191e"), 0.68, 0.38)
	var sickly := _emissive_material(Color("72d6b0"), 1.75)
	var necro := _emissive_material(Color("9e68ff"), 2.10)
	ossuary_sigil_material = necro

	# Side crypt bays: recessed dark cells, stone frames and bone shelves.
	for side in [-1.0, 1.0]:
		for z in [-5.0, -2.0, 1.0, 4.0]:
			var x: float = float(side) * 4.78
			var bay := Node3D.new()
			bay.name = "CryptBay"
			bay.position = Vector3(x, 0.0, z)
			ossuary_root.add_child(bay)
			_add_box(bay, "CryptBack", Vector3(0.28, 1.72, 1.78), Vector3(0.0, 0.92, 0.0), crypt_stone)
			_add_box(bay, "CryptPillarA", Vector3(0.42, 2.18, 0.26), Vector3(0.0, 1.08, -0.86), crypt_edge)
			_add_box(bay, "CryptPillarB", Vector3(0.42, 2.18, 0.26), Vector3(0.0, 1.08, 0.86), crypt_edge)
			_add_box(bay, "CryptLintel", Vector3(0.44, 0.24, 1.96), Vector3(0.0, 2.08, 0.0), crypt_edge)
			for shelf_y in [0.52, 1.18]:
				_add_box(bay, "BoneShelf", Vector3(0.50, 0.09, 1.42), Vector3(-side * 0.08, shelf_y, 0.0), black_iron)
				for bone_z in [-0.48, 0.0, 0.48]:
					var skull := _add_sphere_local(bay, "Skull", 0.13, Vector3(-side * 0.20, shelf_y + 0.16, bone_z), bone, 8, 4)
					skull.scale = Vector3(0.95, 0.82, 1.02)

	# Sarcophagi create chunky occluders around the combat lane.
	for pos in [Vector3(-3.45,0.0,-3.2), Vector3(3.45,0.0,-3.2), Vector3(-3.45,0.0,3.1), Vector3(3.45,0.0,3.1)]:
		var tomb := Node3D.new()
		tomb.name = "Sarcophagus"
		tomb.position = pos
		ossuary_root.add_child(tomb)
		_add_box(tomb, "Body", Vector3(1.10, 0.44, 1.85), Vector3(0.0, 0.22, 0.0), crypt_stone)
		var lid := _add_box(tomb, "Lid", Vector3(1.22, 0.16, 1.98), Vector3(0.0, 0.50, 0.0), crypt_edge)
		lid.rotation.y = pos.x * 0.025
		_add_box(tomb, "BoneMark", Vector3(0.14, 0.035, 1.12), Vector3(0.0, 0.60, 0.0), old_bone)

	# Central bone altar and necromantic focus near the back gate.
	var altar := Node3D.new()
	altar.name = "BoneAltar"
	altar.position = Vector3(0.0, 0.0, -5.25)
	ossuary_root.add_child(altar)
	_add_box(altar, "Plinth", Vector3(2.20, 0.36, 1.20), Vector3(0.0, 0.18, 0.0), crypt_edge)
	_add_box(altar, "Table", Vector3(1.72, 0.24, 0.82), Vector3(0.0, 0.54, 0.0), bone)
	for x in [-0.58, 0.0, 0.58]:
		var spike := _add_cylinder_local(altar, "BoneSpire", 0.0, 0.10, 0.86, Vector3(x, 1.05, 0.0), old_bone, 7)
		spike.rotation.z = x * 0.18
	var focus := _add_sphere_local(altar, "NecroFocus", 0.24, Vector3(0.0, 1.10, -0.04), necro, 12, 6)
	focus.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Iron drainage channels and ritual sigils give the floor its own read.
	for x in [-2.15, 2.15]:
		_add_box(ossuary_root, "IronChannel", Vector3(0.22, 0.035, 10.8), Vector3(x, 0.018, 0.1), black_iron)
		for z in [-4.0, -2.0, 0.0, 2.0, 4.0]:
			_add_box(ossuary_root, "Grate", Vector3(0.70, 0.045, 0.08), Vector3(x, 0.035, z), crypt_edge)
	for z in [-3.8, 0.0, 3.8]:
		var sigil := _add_cylinder_local(ossuary_root, "OssuarySigil", 0.74, 0.74, 0.014, Vector3(0.0, 0.022, z), necro, 30)
		sigil.scale = Vector3(1.0, 1.0, 0.38)

	# Bone pylons frame the forward lane without spending shadow-casting lights.
	for pos in [Vector3(-2.85,0.0,-0.9), Vector3(2.85,0.0,-0.9), Vector3(-2.85,0.0,4.8), Vector3(2.85,0.0,4.8)]:
		var pylon := Node3D.new()
		pylon.name = "BonePylon"
		pylon.position = pos
		ossuary_root.add_child(pylon)
		_add_cylinder_local(pylon, "Column", 0.20, 0.32, 1.65, Vector3(0.0, 0.82, 0.0), old_bone, 9)
		_add_sphere_local(pylon, "SkullCap", 0.25, Vector3(0.0, 1.73, 0.0), bone, 9, 5)
		_add_box(pylon, "Rune", Vector3(0.07, 0.42, 0.04), Vector3(0.0, 0.95, -0.28), sickly)

	_add_omni_to(ossuary_root, "OssuaryColdLight", Vector3(-2.6, 2.5, 0.4), Color("8adbc9"), 2.6, 7.2)
	_add_omni_to(ossuary_root, "NecroAltarLight", Vector3(0.0, 2.0, -4.9), Color("9e68ff"), 3.0, 6.5)
	_add_omni_to(ossuary_root, "CryptFill", Vector3(3.0, 1.8, 3.6), Color("607d86"), 1.4, 5.8)

func _animate_ossuary(_delta: float) -> void:
	if ossuary_root == null:
		return
	var altar := ossuary_root.get_node_or_null("BoneAltar") as Node3D
	if altar != null:
		var focus := altar.get_node_or_null("NecroFocus") as MeshInstance3D
		if focus != null:
			var pulse := 1.0 + sin(runtime_elapsed * 3.8) * 0.10
			focus.scale = Vector3.ONE * pulse
			focus.rotation.y = runtime_elapsed * 1.6
	var index := 0
	for child in ossuary_root.get_children():
		if child.name != "OssuarySigil":
			continue
		var sigil := child as MeshInstance3D
		var p := 0.88 + sin(runtime_elapsed * 2.4 + float(index) * 1.3) * 0.08
		sigil.scale = Vector3(p, 1.0, 0.38 * p)
		index += 1
