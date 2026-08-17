extends "res://scripts/world3d_actor_factory_v149.gd"

# ONE MORE FLOOR v1.53 — visible 3D presentation pass.
# Replaces the box-heavy native fallback surface with smoother, shadow-casting
# silhouettes while keeping the imported-GLB contract and all gameplay authority.

const PRESENTATION_NODE := "PresentationV153"
const PRESENTATION_VERSION := "1.53.0-3d-visual-presentation"

var presentation_materials: Dictionary = {}

func _init() -> void:
	super._init()
	_build_presentation_materials()

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if not imported_model_active(root):
		_replace_player_native_surface(root)
	root.set_meta("visual_presentation_v153", true)
	root.set_meta("asset_quality_report", production_asset_report(root))
	return root

func create_enemy_shell(index: int) -> Node3D:
	var root: Node3D = super.create_enemy_shell(index)
	root.set_meta("visual_presentation_v153", true)
	return root

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	if not imported_model_active(root):
		_replace_enemy_native_surface(root, kind)
	root.set_meta("visual_presentation_v153", true)
	root.set_meta("asset_quality_report", production_asset_report(root))

func visual_presentation_ready(root: Node3D) -> bool:
	if root == null or not bool(root.get_meta("visual_presentation_v153", false)):
		return false
	if imported_model_active(root):
		return model_pipeline_ready(root)
	var layer := _presentation_layer(root)
	return layer != null and _mesh_count(layer) >= 6 and _shadow_mesh_count(layer) >= 4

func visual_presentation_snapshot(root: Node3D) -> Dictionary:
	var layer := _presentation_layer(root)
	return {
		"ready": visual_presentation_ready(root),
		"version": PRESENTATION_VERSION,
		"model_source": String(root.get_meta("model_source", "")) if root != null else "",
		"layer": String(layer.name) if layer != null else "",
		"mesh_count": _mesh_count(layer),
		"shadow_mesh_count": _shadow_mesh_count(layer),
		"shared_material_count": presentation_materials.size(),
	}

func presentation_quality_snapshot() -> Dictionary:
	return {
		"version": PRESENTATION_VERSION,
		"shared_material_count": presentation_materials.size(),
		"smooth_native_fallback": true,
		"imported_glb_preferred": true,
		"shadow_casting": true,
	}

func _replace_player_native_surface(root: Node3D) -> void:
	if root == null:
		return
	var motion := root.get_node_or_null("Motion") as Node3D
	if motion == null:
		return
	_remove_old_presentation(motion)
	# Hide only native geometry. RigMount remains untouched so a later imported
	# model can still become authoritative without changing this presentation pass.
	_set_geometry_recursive(motion, false, ["RigMount"])

	var weapon := root.get_node_or_null("WeaponPivot") as Node3D
	if weapon != null:
		_remove_old_presentation(weapon)
		_set_geometry_recursive(weapon, false, [])

	var layer := Node3D.new()
	layer.name = PRESENTATION_NODE
	motion.add_child(layer)
	root.set_meta("v153_presentation_path", NodePath("Motion/%s" % PRESENTATION_NODE))

	# Hero silhouette: rounded armored core, readable shoulders/limbs and a smooth
	# hood/head mass. The old stacked cuboids stay hidden underneath as fallback data.
	_add_capsule(layer, "HeroTorso", 0.31, 0.92, Vector3(0.0, 0.88, 0.0), presentation_materials["hero_cloth"])
	var chest := _add_sphere(layer, "HeroChestArmor", 0.34, Vector3(0.0, 1.02, -0.12), presentation_materials["hero_steel"])
	chest.scale = Vector3(1.08, 0.76, 0.52)
	var hood := _add_sphere(layer, "HeroHood", 0.31, Vector3(0.0, 1.52, -0.02), presentation_materials["hero_cloth"])
	hood.scale = Vector3(1.02, 1.08, 0.94)
	var face := _add_sphere(layer, "HeroFaceShadow", 0.225, Vector3(0.0, 1.49, -0.18), presentation_materials["face_shadow"])
	face.scale = Vector3(0.93, 0.90, 0.70)

	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		var shoulder := _add_sphere(layer, "HeroPauldron", 0.205, Vector3(side * 0.37, 1.15, -0.02), presentation_materials["hero_steel"])
		shoulder.scale = Vector3(1.20, 0.75, 1.08)
		var arm := _add_capsule(layer, "HeroArm", 0.105, 0.52, Vector3(side * 0.41, 0.87, -0.01), presentation_materials["hero_cloth"])
		arm.rotation.z = side * -0.08
		var boot := _add_capsule(layer, "HeroBoot", 0.13, 0.48, Vector3(side * 0.16, 0.28, 0.0), presentation_materials["hero_steel_dark"])
		boot.scale = Vector3(0.90, 1.0, 1.08)

	# Rounded cape strips preserve the moving silhouette without a flat billboard.
	for index in range(3):
		var cape_x: float = (float(index) - 1.0) * 0.18
		var cape := _add_capsule(layer, "HeroCape%d" % index, 0.09, 0.74, Vector3(cape_x, 0.72, 0.25), presentation_materials["cape"])
		cape.rotation.x = -0.12
		cape.rotation.z = (float(index) - 1.0) * 0.045

	var emblem := _add_sphere(layer, "HeroEmblemV153", 0.105, Vector3(0.0, 1.05, -0.38), presentation_materials["arcane"])
	emblem.scale = Vector3(1.0, 1.12, 0.44)

	if weapon != null:
		var weapon_layer := Node3D.new()
		weapon_layer.name = PRESENTATION_NODE
		weapon.add_child(weapon_layer)
		var blade := _add_cylinder(weapon_layer, "HeroBlade", 0.042, 0.018, 0.98, Vector3(0.0, 0.0, -0.66), presentation_materials["blade"], 10)
		blade.rotation.x = PI * 0.5
		var grip := _add_cylinder(weapon_layer, "HeroGrip", 0.052, 0.052, 0.31, Vector3(0.0, 0.0, -0.06), presentation_materials["leather"], 12)
		grip.rotation.x = PI * 0.5
		var guard := _add_cylinder(weapon_layer, "HeroGuard", 0.19, 0.19, 0.055, Vector3(0.0, 0.0, -0.22), presentation_materials["gold"], 14)
		guard.rotation.z = PI * 0.5
	root.set_meta("v153_native_surface", "smooth_hero")

func _replace_enemy_native_surface(root: Node3D, kind: String) -> void:
	if root == null:
		return
	var visual := root.get_node_or_null("Motion/Visual") as Node3D
	if visual == null:
		return
	_remove_old_presentation(visual)
	_set_geometry_recursive(visual, false, ["TellRing", "HitSpark", "RankCrest"])

	var layer := Node3D.new()
	layer.name = PRESENTATION_NODE
	visual.add_child(layer)
	root.set_meta("v153_presentation_path", NodePath("Motion/Visual/%s" % PRESENTATION_NODE))
	root.set_meta("v153_enemy_kind", kind)

	match kind:
		"goblin":
			_build_goblin(layer)
		"bat":
			_build_bat(layer)
		"skeleton":
			_build_skeleton(layer)
		"ghoul":
			_build_ghoul(layer)
		"necromancer":
			_build_necromancer(layer)
		"warden":
			_build_warden(layer)
		_:
			_build_generic_enemy(layer)

func _build_goblin(layer: Node3D) -> void:
	_add_capsule(layer, "GoblinTorso", 0.28, 0.72, Vector3(0.0, 0.67, 0.0), presentation_materials["goblin_skin"])
	var head := _add_sphere(layer, "GoblinHead", 0.29, Vector3(0.0, 1.08, -0.05), presentation_materials["goblin_skin"])
	head.scale = Vector3(1.12, 0.88, 0.95)
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var ear := _add_capsule(layer, "GoblinEar", 0.065, 0.34, Vector3(side * 0.31, 1.10, -0.02), presentation_materials["goblin_skin"])
		ear.rotation.z = side * PI * 0.42
		var arm := _add_capsule(layer, "GoblinArm", 0.09, 0.48, Vector3(side * 0.31, 0.66, 0.0), presentation_materials["goblin_skin"])
		arm.rotation.z = side * -0.16
	var chest := _add_sphere(layer, "GoblinScrapArmor", 0.27, Vector3(0.0, 0.74, -0.17), presentation_materials["enemy_steel"])
	chest.scale = Vector3(1.02, 0.72, 0.44)
	_add_sphere(layer, "GoblinEye", 0.055, Vector3(0.08, 1.10, -0.285), presentation_materials["enemy_glow"])

func _build_bat(layer: Node3D) -> void:
	var body := _add_sphere(layer, "BatBody", 0.29, Vector3(0.0, 0.78, 0.0), presentation_materials["bat"])
	body.scale = Vector3(0.78, 1.22, 0.76)
	_add_sphere(layer, "BatHead", 0.22, Vector3(0.0, 1.08, -0.08), presentation_materials["bat_dark"])
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var wing := _add_sphere(layer, "BatWing", 0.43, Vector3(side * 0.47, 0.87, 0.04), presentation_materials["bat"])
		wing.scale = Vector3(1.45, 0.26, 0.76)
		wing.rotation.z = side * -0.20
		var tip := _add_capsule(layer, "BatWingTip", 0.055, 0.50, Vector3(side * 0.75, 0.86, 0.03), presentation_materials["bat_dark"])
		tip.rotation.z = side * PI * 0.40
	_add_sphere(layer, "BatCore", 0.085, Vector3(0.0, 0.84, -0.24), presentation_materials["arcane"])

func _build_skeleton(layer: Node3D) -> void:
	_add_capsule(layer, "SkeletonSpine", 0.085, 0.72, Vector3(0.0, 0.78, 0.02), presentation_materials["bone"])
	var skull := _add_sphere(layer, "SkeletonSkull", 0.25, Vector3(0.0, 1.30, -0.04), presentation_materials["bone"])
	skull.scale = Vector3(0.92, 1.0, 0.84)
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var arm := _add_capsule(layer, "SkeletonArm", 0.065, 0.58, Vector3(side * 0.28, 0.79, 0.0), presentation_materials["bone"])
		arm.rotation.z = side * -0.11
		_add_capsule(layer, "SkeletonLeg", 0.075, 0.58, Vector3(side * 0.12, 0.31, 0.0), presentation_materials["bone"])
	for rib_index in range(3):
		var rib := _add_cylinder(layer, "SkeletonRib", 0.22 - float(rib_index) * 0.025, 0.22 - float(rib_index) * 0.025, 0.045, Vector3(0.0, 0.91 - float(rib_index) * 0.13, -0.03), presentation_materials["bone"], 12)
		rib.rotation.x = PI * 0.5
	_add_sphere(layer, "SkeletonEye", 0.052, Vector3(0.08, 1.32, -0.245), presentation_materials["enemy_glow"])

func _build_ghoul(layer: Node3D) -> void:
	var torso := _add_capsule(layer, "GhoulTorso", 0.34, 0.90, Vector3(0.0, 0.72, 0.06), presentation_materials["ghoul"])
	torso.rotation.x = 0.16
	_add_sphere(layer, "GhoulHead", 0.27, Vector3(0.0, 1.16, -0.14), presentation_materials["ghoul_dark"])
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var arm := _add_capsule(layer, "GhoulArm", 0.105, 0.76, Vector3(side * 0.38, 0.67, -0.10), presentation_materials["ghoul"])
		arm.rotation.z = side * -0.22
		var claw := _add_capsule(layer, "GhoulClaw", 0.050, 0.34, Vector3(side * 0.48, 0.35, -0.21), presentation_materials["enemy_glow"])
		claw.rotation.z = side * -0.20
	_add_sphere(layer, "GhoulCore", 0.095, Vector3(0.0, 0.82, -0.31), presentation_materials["arcane"])

func _build_necromancer(layer: Node3D) -> void:
	_add_cylinder(layer, "NecroRobe", 0.24, 0.43, 1.05, Vector3(0.0, 0.58, 0.05), presentation_materials["necro"], 18)
	var hood := _add_sphere(layer, "NecroHood", 0.34, Vector3(0.0, 1.35, -0.01), presentation_materials["necro_dark"])
	hood.scale = Vector3(1.04, 1.10, 0.96)
	var void_face := _add_sphere(layer, "NecroVoidFace", 0.22, Vector3(0.0, 1.32, -0.19), presentation_materials["face_shadow"])
	void_face.scale = Vector3(0.92, 0.88, 0.66)
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var shoulder := _add_sphere(layer, "NecroShoulder", 0.17, Vector3(side * 0.34, 1.04, 0.0), presentation_materials["enemy_steel"])
		shoulder.scale = Vector3(1.15, 0.72, 1.0)
		var crown := _add_capsule(layer, "NecroCrown", 0.045, 0.34, Vector3(side * 0.16, 1.67, 0.0), presentation_materials["gold"])
		crown.rotation.z = side * -0.16
	_add_sphere(layer, "NecroEye", 0.060, Vector3(0.07, 1.34, -0.385), presentation_materials["arcane"])

func _build_warden(layer: Node3D) -> void:
	_add_capsule(layer, "WardenTorso", 0.46, 1.20, Vector3(0.0, 0.92, 0.02), presentation_materials["warden"])
	var chest := _add_sphere(layer, "WardenBreastplate", 0.47, Vector3(0.0, 1.13, -0.20), presentation_materials["warden_steel"])
	chest.scale = Vector3(1.12, 0.78, 0.52)
	var helm := _add_sphere(layer, "WardenHelm", 0.36, Vector3(0.0, 1.67, -0.02), presentation_materials["warden_steel"])
	helm.scale = Vector3(1.0, 1.06, 0.94)
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var shoulder := _add_sphere(layer, "WardenPauldron", 0.28, Vector3(side * 0.55, 1.28, -0.02), presentation_materials["warden_steel"])
		shoulder.scale = Vector3(1.25, 0.72, 1.08)
		var arm := _add_capsule(layer, "WardenArm", 0.14, 0.72, Vector3(side * 0.56, 0.90, 0.0), presentation_materials["warden"])
		arm.rotation.z = side * -0.08
		var horn := _add_capsule(layer, "WardenHorn", 0.055, 0.43, Vector3(side * 0.20, 1.96, 0.0), presentation_materials["gold"])
		horn.rotation.z = side * -0.20
	_add_sphere(layer, "WardenSigil", 0.13, Vector3(0.0, 1.16, -0.47), presentation_materials["warden_glow"])

func _build_generic_enemy(layer: Node3D) -> void:
	_add_capsule(layer, "EnemyTorso", 0.30, 0.82, Vector3(0.0, 0.72, 0.0), presentation_materials["enemy_cloth"])
	_add_sphere(layer, "EnemyHead", 0.26, Vector3(0.0, 1.22, -0.04), presentation_materials["enemy_dark"])
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var shoulder := _add_sphere(layer, "EnemyShoulder", 0.16, Vector3(side * 0.32, 0.95, 0.0), presentation_materials["enemy_steel"])
		shoulder.scale = Vector3(1.12, 0.78, 1.0)
		_add_capsule(layer, "EnemyArm", 0.09, 0.50, Vector3(side * 0.34, 0.68, 0.0), presentation_materials["enemy_cloth"])
	_add_sphere(layer, "EnemyCore", 0.075, Vector3(0.0, 0.80, -0.28), presentation_materials["enemy_glow"])

func _build_presentation_materials() -> void:
	if not presentation_materials.is_empty():
		return
	presentation_materials = {
		"hero_cloth": _pbr("Hero Cloth", Color("#171828"), 0.05, 0.66),
		"hero_steel": _pbr("Hero Steel", Color("#667083"), 0.72, 0.25),
		"hero_steel_dark": _pbr("Hero Steel Dark", Color("#2c3240"), 0.68, 0.30),
		"cape": _pbr("Cape", Color("#24182f"), 0.0, 0.76),
		"face_shadow": _pbr("Face Shadow", Color("#070810"), 0.0, 0.92),
		"arcane": _pbr("Arcane", Color("#7a5cff"), 0.15, 0.24, Color("#8b69ff"), 2.2),
		"blade": _pbr("Blade", Color("#c8d6e5"), 0.90, 0.16),
		"gold": _pbr("Gold", Color("#d1a64b"), 0.82, 0.23),
		"leather": _pbr("Leather", Color("#493126"), 0.0, 0.82),
		"enemy_steel": _pbr("Enemy Steel", Color("#505866"), 0.63, 0.34),
		"enemy_cloth": _pbr("Enemy Cloth", Color("#302c39"), 0.0, 0.78),
		"enemy_dark": _pbr("Enemy Dark", Color("#171820"), 0.05, 0.76),
		"enemy_glow": _pbr("Enemy Glow", Color("#ff735f"), 0.08, 0.30, Color("#ff564a"), 1.8),
		"goblin_skin": _pbr("Goblin Skin", Color("#65784c"), 0.0, 0.70),
		"bat": _pbr("Bat", Color("#3f3158"), 0.02, 0.78),
		"bat_dark": _pbr("Bat Dark", Color("#1c1928"), 0.0, 0.84),
		"bone": _pbr("Bone", Color("#c9c0a4"), 0.0, 0.68),
		"ghoul": _pbr("Ghoul", Color("#536357"), 0.0, 0.78),
		"ghoul_dark": _pbr("Ghoul Dark", Color("#28352f"), 0.0, 0.86),
		"necro": _pbr("Necromancer Robe", Color("#261d38"), 0.02, 0.74),
		"necro_dark": _pbr("Necromancer Hood", Color("#120f1c"), 0.0, 0.86),
		"warden": _pbr("Warden Armor", Color("#3a2530"), 0.34, 0.48),
		"warden_steel": _pbr("Warden Steel", Color("#5c5362"), 0.76, 0.25),
		"warden_glow": _pbr("Warden Sigil", Color("#df443f"), 0.10, 0.25, Color("#ff4138"), 2.5),
	}

func _pbr(resource_name: String, color: Color, metallic: float, roughness: float, emission: Color = Color(0, 0, 0, 0), emission_energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = resource_name
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material

func _add_capsule(parent: Node3D, node_name: String, radius: float, height: float, position: Vector3, material: Material) -> MeshInstance3D:
	var shape := CapsuleMesh.new()
	shape.radius = radius
	shape.height = maxf(height, radius * 2.0)
	return _add_mesh(parent, node_name, shape, position, material)

func _add_sphere(parent: Node3D, node_name: String, radius: float, position: Vector3, material: Material) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radius = radius
	shape.height = radius * 2.0
	shape.radial_segments = 20
	shape.rings = 10
	return _add_mesh(parent, node_name, shape, position, material)

func _add_cylinder(parent: Node3D, node_name: String, top_radius: float, bottom_radius: float, height: float, position: Vector3, material: Material, radial_segments: int = 16) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.top_radius = top_radius
	shape.bottom_radius = bottom_radius
	shape.height = height
	shape.radial_segments = radial_segments
	shape.rings = 2
	return _add_mesh(parent, node_name, shape, position, material)

func _add_mesh(parent: Node3D, node_name: String, shape: PrimitiveMesh, position: Vector3, material: Material) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.mesh = shape
	mesh_instance.material_override = material
	mesh_instance.position = position
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mesh_instance)
	return mesh_instance

func _remove_old_presentation(parent: Node3D) -> void:
	var old := parent.get_node_or_null(PRESENTATION_NODE)
	if old != null:
		parent.remove_child(old)
		old.queue_free()

func _presentation_layer(root: Node3D) -> Node3D:
	if root == null:
		return null
	var path_value: Variant = root.get_meta("v153_presentation_path", NodePath(""))
	if path_value is NodePath and not (path_value as NodePath).is_empty():
		return root.get_node_or_null(path_value as NodePath) as Node3D
	return null

func _mesh_count(node: Node) -> int:
	if node == null:
		return 0
	var count := 1 if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _mesh_count(child)
	return count

func _shadow_mesh_count(node: Node) -> int:
	if node == null:
		return 0
	var count := 0
	if node is MeshInstance3D:
		var geometry := node as MeshInstance3D
		if geometry.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
			count = 1
	for child in node.get_children():
		count += _shadow_mesh_count(child)
	return count
