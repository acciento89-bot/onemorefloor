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
var v160_ossuary_ring_material: StandardMaterial3D
var v160_rift_core_material: StandardMaterial3D
var v160_star_core_material: StandardMaterial3D
var v160_star_ring_blue: StandardMaterial3D
var v160_star_ring_gold: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_build_authored_tower_materials()
	_build_authored_tower_environment()
	_tune_inherited_realm_presentation()

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
	data["v160_starless_lookdev"] = v160_star_core_material != null
	data["v160_true_ring_geometry"] = true
	return data

func _apply_floor_identity(floor_no: int) -> void:
	super._apply_floor_identity(floor_no)
	_sync_authored_realm(floor_no)

func _animate_rift_descent(delta: float) -> void:
	super._animate_rift_descent(delta)
	if rift_core != null:
		var pulse := 1.0 + sin(runtime_elapsed * 4.5) * 0.07
		rift_core.scale = Vector3(0.76, 0.92, 0.58) * pulse

func _animate_starless_spire(delta: float) -> void:
	super._animate_starless_spire(delta)
	# The inherited v1.45 StarCore was intentionally spectacular at the time,
	# but in portrait it clips into a huge white blob. v1.60 keeps the motion
	# while reducing the silhouette to a readable focal jewel.
	if starless_core != null:
		var pulse := 0.55 + sin(runtime_elapsed * 3.2) * 0.030
		starless_core.scale = Vector3.ONE * pulse

func _build_authored_tower_materials() -> void:
	tower_lower_mat = _material(Color("2a3040"), 0.20, 0.72)
	tower_bone_mat = _material(Color("6b665b"), 0.03, 0.97)
	tower_iron_mat = _material(Color("323741"), 0.76, 0.34)
	tower_rift_mat = _emissive_material(Color("7740b8"), 0.82)
	tower_spire_mat = _material(Color("1a2030"), 0.38, 0.64)
	tower_brass_mat = _material(Color("82592a"), 0.70, 0.34)
	v160_ossuary_ring_material = _emissive_material(Color("7045a8"), 0.52)
	v160_rift_core_material = _emissive_material(Color("8a54c8"), 0.64)
	v160_star_core_material = _emissive_material(Color("7693c9"), 0.50)
	v160_star_ring_blue = _emissive_material(Color("536db2"), 0.40)
	v160_star_ring_gold = _emissive_material(Color("9f8046"), 0.36)

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
			_place_tower_asset(root_node, "LowerPillarAsset", "gothic_pillar", tower_lower_mat, Vector3(side * 4.48, 0.02, z), Vector3(0.62, 0.78, 0.62), Vector3.ZERO)
		_place_tower_asset(root_node, "LowerBrazierAsset", "wall_brazier", tower_brass_mat, Vector3(side * 4.12, 1.88, -3.0), Vector3(0.52, 0.52, 0.52))
	_place_tower_asset(root_node, "LowerForegroundPillarL", "gothic_pillar", tower_lower_mat, Vector3(-4.72, 0.02, 5.0), Vector3(0.70, 0.92, 0.70), Vector3(0.0, 0.08, 0.0))
	_place_tower_asset(root_node, "LowerForegroundPillarR", "gothic_pillar", tower_lower_mat, Vector3(4.58, 0.02, 4.35), Vector3(0.58, 0.78, 0.58), Vector3(0.0, -0.06, 0.0))

func _build_ossuary_authored(root_node: Node3D) -> void:
	for side in [-1.0, 1.0]:
		for index in range(3):
			var z := -4.8 + float(index) * 3.7
			var scale_y := 0.60 + float(index % 2) * 0.08
			var totem := _place_tower_asset(root_node, "OssuaryTotemAsset", "ossuary_totem", tower_bone_mat, Vector3(side * (4.18 + 0.12 * float(index % 2)), 0.02, z), Vector3(0.50, scale_y, 0.50))
			if totem != null:
				totem.rotation.y = -side * (0.10 + float(index) * 0.025)
	_place_tower_asset(root_node, "OssuaryRearTotemL", "ossuary_totem", tower_bone_mat, Vector3(-2.25, 0.02, -6.35), Vector3(0.60, 0.68, 0.60), Vector3(0.0, 0.12, 0.0))
	_place_tower_asset(root_node, "OssuaryRearTotemR", "ossuary_totem", tower_bone_mat, Vector3(2.25, 0.02, -6.35), Vector3(0.56, 0.64, 0.56), Vector3(0.0, -0.10, 0.0))

func _build_iron_authored(root_node: Node3D) -> void:
	for side in [-1.0, 1.0]:
		for index in range(3):
			var z := -4.7 + float(index) * 3.7
			var buttress := _place_tower_asset(root_node, "IronButtressAsset", "iron_buttress", tower_iron_mat, Vector3(side * 4.35, 0.02, z), Vector3(0.60, 0.72 + float(index % 2) * 0.06, 0.60))
			if buttress != null:
				buttress.rotation.y = side * 0.035 * float(index - 1)
	_place_tower_asset(root_node, "IronRearButtressL", "iron_buttress", tower_iron_mat, Vector3(-2.35, 0.02, -6.42), Vector3(0.72, 0.84, 0.72))
	_place_tower_asset(root_node, "IronRearButtressR", "iron_buttress", tower_iron_mat, Vector3(2.35, 0.02, -6.42), Vector3(0.72, 0.84, 0.72))
	_place_tower_asset(root_node, "IronForwardButtress", "iron_buttress", tower_iron_mat, Vector3(3.75, 0.02, 4.65), Vector3(0.68, 0.82, 0.68), Vector3(0.0, -0.10, 0.0))

func _build_rift_authored(root_node: Node3D) -> void:
	for side in [-1.0, 1.0]:
		for index in range(3):
			var z := -4.5 + float(index) * 3.6
			var crystal := _place_tower_asset(root_node, "RiftCrystalAsset", "rift_crystal", tower_rift_mat, Vector3(side * (4.0 + 0.18 * float(index % 2)), 0.04, z), Vector3(0.42, 0.52 + 0.05 * float(index), 0.42))
			if crystal != null:
				crystal.rotation.z = -side * (0.12 + float(index) * 0.025)
	_place_tower_asset(root_node, "RiftRearCrystal", "rift_crystal", tower_rift_mat, Vector3(0.0, 0.04, -6.48), Vector3(0.56, 0.64, 0.56))
	_place_tower_asset(root_node, "RiftForegroundCrystal", "rift_crystal", tower_rift_mat, Vector3(-3.62, 0.04, 4.72), Vector3(0.48, 0.70, 0.48), Vector3(0.0, 0.0, -0.16))

func _build_spire_authored(root_node: Node3D) -> void:
	for side in [-1.0, 1.0]:
		for index in range(3):
			var z := -4.7 + float(index) * 3.7
			var column := _place_tower_asset(root_node, "SpireColumnAsset", "spire_column", tower_spire_mat, Vector3(side * 4.18, 0.02, z), Vector3(0.50, 0.64 + float(index) * 0.035, 0.50))
			if column != null:
				column.rotation.z = -side * 0.035
	_place_tower_asset(root_node, "SpireRearColumnL", "spire_column", tower_spire_mat, Vector3(-2.30, 0.02, -6.48), Vector3(0.58, 0.68, 0.58), Vector3(0.0, 0.10, 0.0))
	_place_tower_asset(root_node, "SpireRearColumnR", "spire_column", tower_spire_mat, Vector3(2.30, 0.02, -6.48), Vector3(0.58, 0.68, 0.58), Vector3(0.0, -0.10, 0.0))
	_place_tower_asset(root_node, "SpireForegroundColumn", "spire_column", tower_spire_mat, Vector3(3.78, 0.02, 4.62), Vector3(0.62, 0.78, 0.62), Vector3(0.0, -0.12, 0.0))

func _tune_inherited_realm_presentation() -> void:
	_tune_ossuary_presentation()
	_tune_rift_presentation()
	_tune_starless_presentation()

func _tune_ossuary_presentation() -> void:
	if ossuary_root == null:
		return
	if ossuary_sigil_material != null:
		ossuary_sigil_material.emission = Color("684297")
		ossuary_sigil_material.emission_energy_multiplier = 0.48
	_set_realm_light_energy(ossuary_root, "OssuaryColdLight", 1.30)
	_set_realm_light_energy(ossuary_root, "NecroAltarLight", 1.45)
	_set_realm_light_energy(ossuary_root, "CryptFill", 0.62)
	_override_named_mesh_material(ossuary_root, ["Skull", "SkullCap", "Table", "BoneSpire", "BoneMark"], tower_bone_mat)

	# v1.43 used filled CylinderMesh discs as floor sigils. Preserve the legacy
	# nodes for compatibility, but render true torus ritual rings in v1.60.
	for child in ossuary_root.get_children():
		if child is MeshInstance3D and String(child.name) == "OssuarySigil":
			(child as MeshInstance3D).visible = false
	var ritual_root := Node3D.new()
	ritual_root.name = "V160OssuaryRitualRings"
	ossuary_root.add_child(ritual_root)
	for z in [-3.8, 0.0, 3.8]:
		var ring := _add_true_ring(ritual_root, "V160OssuaryRing", 0.57, 0.74, v160_ossuary_ring_material)
		ring.position = Vector3(0.0, 0.055, z)
		ring.scale = Vector3(1.0, 0.72, 0.48)

func _tune_rift_presentation() -> void:
	if rift_root == null:
		return
	if rift_core != null:
		rift_core.material_override = v160_rift_core_material
	_set_realm_light_energy(rift_root, "RiftKeyLight", 1.72)
	_set_realm_light_energy(rift_root, "RiftColdFill", 0.95)
	_set_realm_light_energy(rift_root, "RiftAnchorLight", 1.25)

func _tune_starless_presentation() -> void:
	if starless_root == null:
		return
	if starless_core != null:
		starless_core.material_override = v160_star_core_material
	_override_named_mesh_material(starless_root, ["StarMote", "ObservatoryStar", "CrownStar", "CrownConstellation"], v160_star_core_material)

	var starwell := starless_root.get_node_or_null("Starwell") as Node3D
	if starwell != null:
		# Hide the old filled cylinders that visually merged into a white egg.
		for child in starwell.get_children():
			if child is MeshInstance3D and String(child.name) == "CelestialRing":
				(child as MeshInstance3D).visible = false
		var celestial_root := Node3D.new()
		celestial_root.name = "V160CelestialRings"
		starwell.add_child(celestial_root)
		var radii := [[0.66, 0.78], [0.86, 0.99], [1.06, 1.18]]
		for ring_index in range(3):
			var pair: Array = radii[ring_index]
			var material := v160_star_ring_gold if ring_index == 1 else v160_star_ring_blue
			var ring := _add_true_ring(celestial_root, "V160CelestialRing%d" % ring_index, float(pair[0]), float(pair[1]), material)
			ring.position = Vector3(0.0, 1.16, 0.0)
			ring.rotation = Vector3(0.46 + float(ring_index) * 0.34, 0.0, 0.24 + float(ring_index) * 0.26)
	_set_realm_light_energy(starless_root, "StarlessKeyLight", 1.08)
	_set_realm_light_energy(starless_root, "StarwellLight", 0.74)
	_set_realm_light_energy(starless_root, "ApexGoldFill", 0.64)

func _add_true_ring(parent: Node3D, node_name: String, inner_radius: float, outer_radius: float, material: Material) -> MeshInstance3D:
	var mesh := TorusMesh.new()
	mesh.inner_radius = inner_radius
	mesh.outer_radius = outer_radius
	mesh.rings = 32
	mesh.ring_segments = 12
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)
	return instance

func _override_named_mesh_material(node: Node, names: Array, material: Material) -> void:
	if node == null:
		return
	if node is MeshInstance3D and names.has(String(node.name)):
		(node as MeshInstance3D).material_override = material
	for child in node.get_children():
		_override_named_mesh_material(child, names, material)

func _set_realm_light_energy(root_node: Node3D, node_name: String, energy: float) -> void:
	if root_node == null:
		return
	var light := root_node.get_node_or_null(node_name) as Light3D
	if light != null:
		light.light_energy = energy

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
