extends "res://scripts/world3d_chamber_v144.gd"

# ONE MORE FLOOR v1.45 - Full Tower 3D completion.
# Adds production realm presentation for Rift Descent (31-40) and
# Starless Spire (41-50) while the proven gameplay/runtime remains authoritative.

const RIFT_MIN_FLOOR := 31
const RIFT_MAX_FLOOR := 40
const STARLESS_MIN_FLOOR := 41
const STARLESS_MAX_FLOOR := 50

var rift_root: Node3D
var starless_root: Node3D
var rift_active := false
var starless_active := false
var rift_core: MeshInstance3D
var starless_core: MeshInstance3D
var rift_floaters: Array = []
var starless_rings: Array = []
var rift_variant_roots: Array = []
var starless_variant_roots: Array = []
var rift_variant := 0
var starless_variant := 0

func _ready() -> void:
	super._ready()
	_build_rift_descent_kit()
	_build_starless_spire_kit()
	_refresh_realm_visibility()

func _process(delta: float) -> void:
	super._process(delta)
	if rift_active:
		_animate_rift_descent(delta)
	if starless_active:
		_animate_starless_spire(delta)

func full_tower_ready() -> bool:
	return iron_bastion_ready() \
		and rift_root != null \
		and starless_root != null \
		and rift_root.get_node_or_null("RiftAnchor") != null \
		and rift_root.get_node_or_null("RiftKeyLight") != null \
		and starless_root.get_node_or_null("Starwell") != null \
		and starless_root.get_node_or_null("StarlessKeyLight") != null

func is_rift_floor(floor_no: int) -> bool:
	return floor_no >= RIFT_MIN_FLOOR and floor_no <= RIFT_MAX_FLOOR

func is_starless_floor(floor_no: int) -> bool:
	return floor_no >= STARLESS_MIN_FLOOR and floor_no <= STARLESS_MAX_FLOOR

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["full_tower_ready"] = full_tower_ready()
	data["rift_active"] = rift_active
	data["starless_active"] = starless_active
	data["rift_variant"] = rift_variant
	data["starless_variant"] = starless_variant
	if rift_active:
		data["realm"] = "rift_descent"
	elif starless_active:
		data["realm"] = "starless_spire"
	return data

func _apply_floor_identity(floor_no: int) -> void:
	super._apply_floor_identity(floor_no)
	_set_rift_active(is_rift_floor(floor_no))
	_set_starless_active(is_starless_floor(floor_no))
	_refresh_realm_visibility()

	if rift_active:
		var depth: float = clampf(float(floor_no - RIFT_MIN_FLOOR) / 9.0, 0.0, 1.0)
		mat_floor.albedo_color = Color("0b0b16").lerp(Color("10091a"), depth * 0.65)
		mat_wall.albedo_color = Color("171526").lerp(Color("22142f"), depth * 0.58)
		mat_trim.albedo_color = Color("62507d").lerp(Color("8c4eb2"), depth * 0.52)
		_apply_rift_variant(floor_no)
	elif starless_active:
		var depth: float = clampf(float(floor_no - STARLESS_MIN_FLOOR) / 9.0, 0.0, 1.0)
		mat_floor.albedo_color = Color("080a10").lerp(Color("090812"), depth * 0.72)
		mat_wall.albedo_color = Color("121722").lerp(Color("181326"), depth * 0.54)
		mat_trim.albedo_color = Color("6e6b7b").lerp(Color("a68b52"), depth * 0.48)
		_apply_starless_variant(floor_no)

func _set_rift_active(value: bool) -> void:
	rift_active = value
	if rift_root != null:
		rift_root.visible = value

func _set_starless_active(value: bool) -> void:
	starless_active = value
	if starless_root != null:
		starless_root.visible = value

func _refresh_realm_visibility() -> void:
	var lower_active: bool = not ossuary_active and not iron_bastion_active and not rift_active and not starless_active
	if production_details_root != null:
		production_details_root.visible = lower_active
	if ossuary_root != null:
		ossuary_root.visible = ossuary_active and not iron_bastion_active and not rift_active and not starless_active
	if iron_bastion_root != null:
		iron_bastion_root.visible = iron_bastion_active and not rift_active and not starless_active
	if rift_root != null:
		rift_root.visible = rift_active and not starless_active
	if starless_root != null:
		starless_root.visible = starless_active
	for light_name_value in ["WarmTorchLight", "ArcaneLight", "ProductionRim", "GateGoldPool"]:
		var light_name: String = String(light_name_value)
		var node: Node3D = get_node_or_null(light_name) as Node3D
		if node != null:
			node.visible = lower_active

func _build_rift_descent_kit() -> void:
	rift_root = Node3D.new()
	rift_root.name = "RiftDescentRealm"
	rift_root.visible = false
	add_child(rift_root)

	var void_stone: StandardMaterial3D = _material(Color("11111b"), 0.08, 0.93)
	var fracture_stone: StandardMaterial3D = _material(Color("28223a"), 0.12, 0.82)
	var dark_metal: StandardMaterial3D = _material(Color("24222c"), 0.66, 0.38)
	var rift_violet: StandardMaterial3D = _emissive_material(Color("a657ff"), 2.55)
	var rift_cyan: StandardMaterial3D = _emissive_material(Color("5de1ff"), 1.95)
	var rift_magenta: StandardMaterial3D = _emissive_material(Color("ff4fc8"), 1.55)

	# A broken central path keeps the combat lane readable while the sides fall into void.
	for z_value in [-4.75, -3.15, -1.55, 0.05, 1.65, 3.25, 4.85]:
		var z: float = float(z_value)
		var slab: MeshInstance3D = _add_box(rift_root, "FracturedSlab", Vector3(4.75, 0.10, 1.18), Vector3(0.0, 0.035, z), void_stone)
		slab.rotation.y = sin(z * 1.4) * 0.035
		_add_box(rift_root, "RiftSeam", Vector3(3.85, 0.018, 0.045), Vector3(sin(z) * 0.26, 0.095, z + 0.42), rift_violet)

	# Floating side shards create depth without adding collision complexity.
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		for index in range(5):
			var shard: Node3D = Node3D.new()
			shard.name = "FloatingShard"
			var z: float = -4.2 + float(index) * 2.1
			var base_y: float = 0.72 + float(index % 2) * 0.38
			shard.position = Vector3(side * (3.65 + float(index % 2) * 0.42), base_y, z)
			shard.rotation = Vector3(0.18 * side, 0.25 * float(index), 0.16 * side)
			shard.set_meta("base_y", base_y)
			shard.set_meta("phase", float(index) * 0.83 + side)
			rift_root.add_child(shard)
			_add_box(shard, "ShardBody", Vector3(0.48, 1.55, 0.62), Vector3.ZERO, fracture_stone)
			_add_box(shard, "ShardRune", Vector3(0.07, 0.92, 0.05), Vector3(0.0, 0.02, -0.34), rift_cyan if index % 2 == 0 else rift_magenta)
			rift_floaters.append(shard)

	# Rear anchor: the destination point of the descent.
	var anchor: Node3D = Node3D.new()
	anchor.name = "RiftAnchor"
	anchor.position = Vector3(0.0, 0.0, -5.15)
	rift_root.add_child(anchor)
	_add_box(anchor, "AnchorBase", Vector3(2.55, 0.28, 1.12), Vector3(0.0, 0.14, 0.0), dark_metal)
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		var fang: MeshInstance3D = _add_box(anchor, "AnchorFang", Vector3(0.34, 2.35, 0.48), Vector3(side * 0.92, 1.24, 0.0), fracture_stone)
		fang.rotation.z = -side * 0.18
		_add_box(anchor, "AnchorRune", Vector3(0.08, 1.26, 0.05), Vector3(side * 0.92, 1.28, -0.27), rift_violet)
	rift_core = _add_sphere_local(anchor, "RiftCore", 0.43, Vector3(0.0, 1.25, 0.0), rift_violet, 16, 8)
	rift_core.scale = Vector3(1.05, 1.32, 0.72)
	rift_core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	_build_rift_variants(void_stone, fracture_stone, dark_metal, rift_violet, rift_cyan)
	_add_omni_to(rift_root, "RiftKeyLight", Vector3(-2.7, 2.35, 0.35), Color("9a58ff"), 2.6, 7.1)
	_add_omni_to(rift_root, "RiftColdFill", Vector3(3.2, 1.95, 3.55), Color("54d8ff"), 1.55, 5.9)
	_add_omni_to(rift_root, "RiftAnchorLight", Vector3(0.0, 2.0, -4.8), Color("d14dff"), 2.25, 6.3)

func _build_rift_variants(void_stone: StandardMaterial3D, fracture_stone: StandardMaterial3D, dark_metal: StandardMaterial3D, rift_violet: StandardMaterial3D, rift_cyan: StandardMaterial3D) -> void:
	for variant_index in range(3):
		var root_variant: Node3D = Node3D.new()
		root_variant.name = "RiftVariant%d" % variant_index
		rift_root.add_child(root_variant)
		rift_variant_roots.append(root_variant)

	var fracture_walk: Node3D = rift_variant_roots[0] as Node3D
	for x_value in [-2.45, 2.45]:
		var x: float = float(x_value)
		for z_value in [-2.6, 1.2, 4.2]:
			var z: float = float(z_value)
			var spike: MeshInstance3D = _add_box(fracture_walk, "FractureMarker", Vector3(0.24, 1.22, 0.28), Vector3(x, 0.64, z), fracture_stone)
			spike.rotation.z = sign(x) * 0.13

	var void_bridge: Node3D = rift_variant_roots[1] as Node3D
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		_add_box(void_bridge, "BridgeRail", Vector3(0.22, 0.20, 6.1), Vector3(side * 2.72, 0.18, 0.7), dark_metal)
		for z_value in [-1.8, 0.5, 2.8]:
			var z: float = float(z_value)
			_add_sphere_local(void_bridge, "BridgeNode", 0.12, Vector3(side * 2.72, 0.38, z), rift_cyan, 10, 5)

	var rift_maw: Node3D = rift_variant_roots[2] as Node3D
	for tooth_index in range(10):
		var angle: float = TAU * float(tooth_index) / 10.0
		var x: float = cos(angle) * 2.05
		var z: float = 0.8 + sin(angle) * 1.55
		var tooth: MeshInstance3D = _add_box(rift_maw, "MawTooth", Vector3(0.18, 0.76, 0.24), Vector3(x, 0.42, z), fracture_stone)
		tooth.rotation.z = -angle * 0.34
	_add_cylinder_local(rift_maw, "MawSigil", 1.15, 1.15, 0.018, Vector3(0.0, 0.055, 0.8), rift_violet, 32)

func _apply_rift_variant(floor_no: int) -> void:
	if floor_no >= 37:
		rift_variant = 2
	elif floor_no >= 34:
		rift_variant = 1
	else:
		rift_variant = 0
	for index in range(rift_variant_roots.size()):
		var root_variant: Node3D = rift_variant_roots[index] as Node3D
		if root_variant != null:
			root_variant.visible = index == rift_variant

func _build_starless_spire_kit() -> void:
	starless_root = Node3D.new()
	starless_root.name = "StarlessSpireRealm"
	starless_root.visible = false
	add_child(starless_root)

	var obsidian: StandardMaterial3D = _material(Color("0c0e15"), 0.22, 0.76)
	var obsidian_edge: StandardMaterial3D = _material(Color("2d3342"), 0.32, 0.58)
	var pale_gold: StandardMaterial3D = _material(Color("8f7a52"), 0.54, 0.42)
	var star_white: StandardMaterial3D = _emissive_material(Color("dbe8ff"), 2.10)
	var star_gold: StandardMaterial3D = _emissive_material(Color("ffd77a"), 2.45)
	var abyss_blue: StandardMaterial3D = _emissive_material(Color("6888ff"), 1.70)

	# Narrow obsidian causeway and towering side spires create the final-zone silhouette.
	_add_box(starless_root, "SpireCauseway", Vector3(4.65, 0.10, 11.25), Vector3(0.0, 0.035, 0.15), obsidian)
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		for index in range(4):
			var z: float = -4.15 + float(index) * 2.75
			var height: float = 2.4 + float(index % 3) * 0.55
			var spire: MeshInstance3D = _add_box(starless_root, "ObsidianSpire", Vector3(0.62, height, 0.72), Vector3(side * 4.25, height * 0.5, z), obsidian)
			spire.rotation.z = -side * (0.06 + float(index) * 0.012)
			_add_box(starless_root, "SpireEdge", Vector3(0.07, height * 0.72, 0.05), Vector3(side * 3.91, height * 0.54, z - 0.38), pale_gold)

	# Star motes provide depth at minimal cost.
	for mote_index in range(18):
		var side: float = -1.0 if mote_index % 2 == 0 else 1.0
		var x: float = side * (2.9 + float(mote_index % 4) * 0.38)
		var z: float = -4.8 + float(mote_index % 9) * 1.18
		var y: float = 1.0 + float((mote_index * 3) % 7) * 0.31
		var mote: MeshInstance3D = _add_sphere_local(starless_root, "StarMote", 0.055 + float(mote_index % 3) * 0.012, Vector3(x, y, z), star_white if mote_index % 3 else star_gold, 8, 4)
		mote.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# Starwell marks the apex objective.
	var starwell: Node3D = Node3D.new()
	starwell.name = "Starwell"
	starwell.position = Vector3(0.0, 0.0, -5.10)
	starless_root.add_child(starwell)
	_add_cylinder_local(starwell, "WellBase", 1.45, 1.70, 0.34, Vector3(0.0, 0.17, 0.0), obsidian_edge, 24)
	_add_cylinder_local(starwell, "WellRim", 1.22, 1.22, 0.12, Vector3(0.0, 0.40, 0.0), pale_gold, 28)
	starless_core = _add_sphere_local(starwell, "StarCore", 0.38, Vector3(0.0, 1.16, 0.0), star_white, 16, 8)
	starless_core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for ring_index in range(3):
		var ring: MeshInstance3D = _add_cylinder_local(starwell, "CelestialRing", 0.88 + float(ring_index) * 0.28, 0.88 + float(ring_index) * 0.28, 0.035, Vector3(0.0, 1.16, 0.0), star_gold if ring_index == 1 else abyss_blue, 32)
		ring.rotation = Vector3(0.45 + float(ring_index) * 0.35, 0.0, 0.22 + float(ring_index) * 0.28)
		starless_rings.append(ring)

	_build_starless_variants(obsidian, obsidian_edge, pale_gold, star_white, star_gold, abyss_blue)
	_add_omni_to(starless_root, "StarlessKeyLight", Vector3(-2.55, 2.65, 0.25), Color("9aaeff"), 2.15, 7.0)
	_add_omni_to(starless_root, "StarwellLight", Vector3(0.0, 2.15, -4.75), Color("e7eaff"), 2.55, 6.2)
	_add_omni_to(starless_root, "ApexGoldFill", Vector3(3.05, 1.9, 3.65), Color("e1b765"), 1.35, 5.6)

func _build_starless_variants(obsidian: StandardMaterial3D, obsidian_edge: StandardMaterial3D, pale_gold: StandardMaterial3D, star_white: StandardMaterial3D, star_gold: StandardMaterial3D, abyss_blue: StandardMaterial3D) -> void:
	for variant_index in range(3):
		var root_variant: Node3D = Node3D.new()
		root_variant.name = "StarlessVariant%d" % variant_index
		starless_root.add_child(root_variant)
		starless_variant_roots.append(root_variant)

	var observatory: Node3D = starless_variant_roots[0] as Node3D
	for z_value in [-2.8, 0.2, 3.2]:
		var z: float = float(z_value)
		_add_cylinder_local(observatory, "ObservatoryDisc", 0.62, 0.62, 0.08, Vector3(-2.65, 0.08, z), obsidian_edge, 20)
		_add_sphere_local(observatory, "ObservatoryStar", 0.10, Vector3(-2.65, 0.42, z), star_white, 10, 5)

	var crown_path: Node3D = starless_variant_roots[1] as Node3D
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		for z_value in [-1.9, 1.1, 4.0]:
			var z: float = float(z_value)
			var crown_pillar: MeshInstance3D = _add_box(crown_path, "CrownPillar", Vector3(0.38, 1.55, 0.38), Vector3(side * 2.65, 0.80, z), obsidian)
			crown_pillar.rotation.z = -side * 0.08
			_add_sphere_local(crown_path, "CrownStar", 0.09, Vector3(side * 2.65, 1.68, z), star_gold, 9, 5)

	var throne_approach: Node3D = starless_variant_roots[2] as Node3D
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		var sentinel: MeshInstance3D = _add_box(throne_approach, "ApexSentinel", Vector3(0.72, 2.85, 0.72), Vector3(side * 2.85, 1.43, -2.35), obsidian_edge)
		sentinel.rotation.z = -side * 0.10
		_add_box(throne_approach, "ApexGlyph", Vector3(0.09, 1.48, 0.05), Vector3(side * 2.48, 1.55, -2.72), abyss_blue)
	for x_value in [-1.5, 0.0, 1.5]:
		var x: float = float(x_value)
		_add_sphere_local(throne_approach, "CrownConstellation", 0.13, Vector3(x, 1.28 + abs(x) * 0.22, 2.35), star_white if x == 0.0 else star_gold, 10, 5)

func _apply_starless_variant(floor_no: int) -> void:
	if floor_no >= 47:
		starless_variant = 2
	elif floor_no >= 44:
		starless_variant = 1
	else:
		starless_variant = 0
	for index in range(starless_variant_roots.size()):
		var root_variant: Node3D = starless_variant_roots[index] as Node3D
		if root_variant != null:
			root_variant.visible = index == starless_variant

func _animate_rift_descent(_delta: float) -> void:
	if rift_core != null:
		var pulse: float = 1.0 + sin(runtime_elapsed * 4.5) * 0.12
		rift_core.scale = Vector3(1.05 * pulse, 1.32 * pulse, 0.72 * pulse)
		rift_core.rotation.y = runtime_elapsed * 1.45
	for floater_value in rift_floaters:
		var floater: Node3D = floater_value as Node3D
		if floater == null:
			continue
		var base_y: float = float(floater.get_meta("base_y", 0.8))
		var phase: float = float(floater.get_meta("phase", 0.0))
		floater.position.y = base_y + sin(runtime_elapsed * 1.65 + phase) * 0.16
		floater.rotation.y += 0.0035

func _animate_starless_spire(_delta: float) -> void:
	if starless_core != null:
		var pulse: float = 1.0 + sin(runtime_elapsed * 3.2) * 0.09
		starless_core.scale = Vector3.ONE * pulse
	for index in range(starless_rings.size()):
		var ring: Node3D = starless_rings[index] as Node3D
		if ring == null:
			continue
		var direction: float = -1.0 if index % 2 == 0 else 1.0
		ring.rotation.y += direction * (0.004 + float(index) * 0.0015)
