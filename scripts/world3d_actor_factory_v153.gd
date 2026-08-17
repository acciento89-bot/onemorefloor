extends "res://scripts/world3d_actor_factory_v149.gd"

# ONE MORE FLOOR v1.53 — visible 3D presentation pass.
# Replaces the box-heavy native fallback surface with smoother shadow-casting
# silhouettes. Imported GLB actors keep priority and gameplay is untouched.

const PRESENTATION_NODE := "PresentationV153"
const PRESENTATION_VERSION := "1.53.0-3d-visual-presentation"

var presentation_materials: Dictionary = {}

func _init() -> void:
	super._init()
	_v153_build_materials()

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if not imported_model_active(root):
		_v153_replace_player(root)
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
		_v153_replace_enemy(root, kind)
	root.set_meta("visual_presentation_v153", true)
	root.set_meta("asset_quality_report", production_asset_report(root))

func visual_presentation_ready(root: Node3D) -> bool:
	if root == null or not bool(root.get_meta("visual_presentation_v153", false)):
		return false
	if imported_model_active(root):
		return model_pipeline_ready(root)
	var layer := _v153_presentation_layer(root)
	return layer != null and _v153_mesh_count(layer) >= 6 and _v153_shadow_mesh_count(layer) >= 4

func visual_presentation_snapshot(root: Node3D) -> Dictionary:
	var layer := _v153_presentation_layer(root)
	return {
		"ready": visual_presentation_ready(root),
		"version": PRESENTATION_VERSION,
		"model_source": String(root.get_meta("model_source", "")) if root != null else "",
		"layer": String(layer.name) if layer != null else "",
		"mesh_count": _v153_mesh_count(layer),
		"shadow_mesh_count": _v153_shadow_mesh_count(layer),
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

func _v153_replace_player(root: Node3D) -> void:
	var motion := root.get_node_or_null("Motion") as Node3D
	if motion == null:
		return
	_v153_remove_layer(motion)
	_set_geometry_recursive(motion, false, ["RigMount"])

	var weapon := root.get_node_or_null("WeaponPivot") as Node3D
	if weapon != null:
		_v153_remove_layer(weapon)
		_set_geometry_recursive(weapon, false, [])

	var layer := Node3D.new()
	layer.name = PRESENTATION_NODE
	motion.add_child(layer)
	root.set_meta("v153_presentation_path", NodePath("Motion/%s" % PRESENTATION_NODE))

	_v153_capsule(layer, "HeroTorso", 0.31, 0.92, Vector3(0.0, 0.88, 0.0), presentation_materials["hero_cloth"])
	var chest := _v153_sphere(layer, "HeroChestArmor", 0.34, Vector3(0.0, 1.02, -0.12), presentation_materials["hero_steel"])
	chest.scale = Vector3(1.08, 0.76, 0.52)
	var hood := _v153_sphere(layer, "HeroHood", 0.31, Vector3(0.0, 1.52, -0.02), presentation_materials["hero_cloth"])
	hood.scale = Vector3(1.02, 1.08, 0.94)
	var face := _v153_sphere(layer, "HeroFaceShadow", 0.225, Vector3(0.0, 1.49, -0.18), presentation_materials["face_shadow"])
	face.scale = Vector3(0.93, 0.90, 0.70)

	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		var shoulder := _v153_sphere(layer, "HeroPauldron", 0.205, Vector3(side * 0.37, 1.15, -0.02), presentation_materials["hero_steel"])
		shoulder.scale = Vector3(1.20, 0.75, 1.08)
		var arm := _v153_capsule(layer, "HeroArm", 0.105, 0.52, Vector3(side * 0.41, 0.87, -0.01), presentation_materials["hero_cloth"])
		arm.rotation.z = side * -0.08
		var boot := _v153_capsule(layer, "HeroBoot", 0.13, 0.48, Vector3(side * 0.16, 0.28, 0.0), presentation_materials["hero_steel_dark"])
		boot.scale = Vector3(0.90, 1.0, 1.08)

	for index in range(3):
		var cape_x: float = (float(index) - 1.0) * 0.18
		var cape := _v153_capsule(layer, "HeroCape%d" % index, 0.09, 0.74, Vector3(cape_x, 0.72, 0.25), presentation_materials["cape"])
		cape.rotation.x = -0.12
		cape.rotation.z = (float(index) - 1.0) * 0.045

	var emblem := _v153_sphere(layer, "HeroEmblemV153", 0.105, Vector3(0.0, 1.05, -0.38), presentation_materials["arcane"])
	emblem.scale = Vector3(1.0, 1.12, 0.44)

	if weapon != null:
		var weapon_layer := Node3D.new()
		weapon_layer.name = PRESENTATION_NODE
		weapon.add_child(weapon_layer)
		var blade := _v153_cylinder(weapon_layer, "HeroBlade", 0.042, 0.018, 0.98, Vector3(0.0, 0.0, -0.66), presentation_materials["blade"], 10)
		blade.rotation.x = PI * 0.5
		var grip := _v153_cylinder(weapon_layer, "HeroGrip", 0.052, 0.052, 0.31, Vector3(0.0, 0.0, -0.06), presentation_materials["leather"], 12)
		grip.rotation.x = PI * 0.5
		var guard := _v153_cylinder(weapon_layer, "HeroGuard", 0.19, 0.19, 0.055, Vector3(0.0, 0.0, -0.22), presentation_materials["gold"], 14)
		guard.rotation.z = PI * 0.5
	root.set_meta("v153_native_surface", "smooth_hero")

func _v153_replace_enemy(root: Node3D, kind: String) -> void:
	var visual := root.get_node_or_null("Motion/Visual") as Node3D
	if visual == null:
		return
	_v153_remove_layer(visual)
	_set_geometry_recursive(visual, false, ["TellRing", "HitSpark", "RankCrest"])
	var layer := Node3D.new()
	layer.name = PRESENTATION_NODE
	visual.add_child(layer)
	root.set_meta("v153_presentation_path", NodePath("Motion/Visual/%s" % PRESENTATION_NODE))
	root.set_meta("v153_enemy_kind", kind)
	_v153_build_enemy(layer, kind)

func _v153_build_enemy(layer: Node3D, kind: String) -> void:
	var body_material: Material = presentation_materials["enemy_cloth"]
	var head_material: Material = presentation_materials["enemy_dark"]
	var armor_material: Material = presentation_materials["enemy_steel"]
	var body_radius := 0.30
	var body_height := 0.82
	var head_radius := 0.26
	var body_y := 0.72
	var head_y := 1.22

	match kind:
		"goblin":
			body_material = presentation_materials["goblin_skin"]
			head_material = presentation_materials["goblin_skin"]
			body_radius = 0.28
			body_height = 0.72
			head_radius = 0.29
			head_y = 1.08
		"bat":
			body_material = presentation_materials["bat"]
			head_material = presentation_materials["bat_dark"]
			body_radius = 0.25
			body_height = 0.58
			head_radius = 0.22
			body_y = 0.80
			head_y = 1.08
		"skeleton":
			body_material = presentation_materials["bone"]
			head_material = presentation_materials["bone"]
			armor_material = presentation_materials["bone"]
			body_radius = 0.15
			body_height = 0.76
			head_radius = 0.25
			head_y = 1.30
		"ghoul":
			body_material = presentation_materials["ghoul"]
			head_material = presentation_materials["ghoul_dark"]
			body_radius = 0.34
			body_height = 0.90
			head_radius = 0.27
			head_y = 1.16
		"necromancer":
			body_material = presentation_materials["necro"]
			head_material = presentation_materials["necro_dark"]
			body_radius = 0.33
			body_height = 1.02
			head_radius = 0.34
			body_y = 0.65
			head_y = 1.35
		"warden":
			body_material = presentation_materials["warden"]
			head_material = presentation_materials["warden_steel"]
			armor_material = presentation_materials["warden_steel"]
			body_radius = 0.46
			body_height = 1.20
			head_radius = 0.36
			body_y = 0.92
			head_y = 1.67

	var torso := _v153_capsule(layer, "%sTorso" % kind.capitalize(), body_radius, body_height, Vector3(0.0, body_y, 0.02), body_material)
	if kind == "ghoul":
		torso.rotation.x = 0.16
	var head := _v153_sphere(layer, "%sHead" % kind.capitalize(), head_radius, Vector3(0.0, head_y, -0.05), head_material)
	if kind == "goblin":
		head.scale = Vector3(1.12, 0.88, 0.95)
	elif kind == "necromancer":
		head.scale = Vector3(1.04, 1.10, 0.96)

	var shoulder_x := 0.32 if kind != "warden" else 0.55
	var shoulder_y := 0.96 if kind != "warden" else 1.28
	var shoulder_radius := 0.16 if kind != "warden" else 0.28
	var arm_radius := 0.09 if kind != "warden" else 0.14
	var arm_height := 0.52 if kind != "warden" else 0.72
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		var shoulder := _v153_sphere(layer, "%sShoulder" % kind.capitalize(), shoulder_radius, Vector3(side * shoulder_x, shoulder_y, 0.0), armor_material)
		shoulder.scale = Vector3(1.16, 0.74, 1.04)
		var arm := _v153_capsule(layer, "%sArm" % kind.capitalize(), arm_radius, arm_height, Vector3(side * shoulder_x, shoulder_y - 0.28, -0.02), body_material)
		arm.rotation.z = side * -0.12

	var core_material: Material = presentation_materials["warden_glow"] if kind == "warden" else presentation_materials["enemy_glow"]
	_v153_sphere(layer, "%sCore" % kind.capitalize(), 0.085 if kind != "warden" else 0.13, Vector3(0.0, body_y + 0.10, -body_radius - 0.10), core_material)

	match kind:
		"goblin":
			for side_value in [-1.0, 1.0]:
				var side: float = float(side_value)
				var ear := _v153_capsule(layer, "GoblinEar", 0.06, 0.32, Vector3(side * 0.31, 1.10, -0.02), body_material)
				ear.rotation.z = side * PI * 0.42
		"bat":
			for side_value in [-1.0, 1.0]:
				var side: float = float(side_value)
				var wing := _v153_sphere(layer, "BatWing", 0.43, Vector3(side * 0.48, 0.88, 0.04), body_material)
				wing.scale = Vector3(1.45, 0.25, 0.74)
				wing.rotation.z = side * -0.20
		"skeleton":
			for rib_index in range(3):
				var rib := _v153_cylinder(layer, "SkeletonRib", 0.22 - float(rib_index) * 0.025, 0.22 - float(rib_index) * 0.025, 0.045, Vector3(0.0, 0.93 - float(rib_index) * 0.13, -0.04), presentation_materials["bone"], 12)
				rib.rotation.x = PI * 0.5
		"necromancer":
			for side_value in [-1.0, 1.0]:
				var side: float = float(side_value)
				var crown := _v153_capsule(layer, "NecroCrown", 0.045, 0.34, Vector3(side * 0.16, 1.67, 0.0), presentation_materials["gold"])
				crown.rotation.z = side * -0.16
		"warden":
			for side_value in [-1.0, 1.0]:
				var side: float = float(side_value)
				var horn := _v153_capsule(layer, "WardenHorn", 0.055, 0.43, Vector3(side * 0.20, 1.96, 0.0), presentation_materials["gold"])
				horn.rotation.z = side * -0.20

func _v153_build_materials() -> void:
	if not presentation_materials.is_empty():
		return
	presentation_materials = {
		"hero_cloth": _v153_pbr("Hero Cloth", Color(0.09, 0.095, 0.16), 0.05, 0.66),
		"hero_steel": _v153_pbr("Hero Steel", Color(0.40, 0.44, 0.51), 0.72, 0.25),
		"hero_steel_dark": _v153_pbr("Hero Steel Dark", Color(0.17, 0.20, 0.25), 0.68, 0.30),
		"cape": _v153_pbr("Cape", Color(0.14, 0.09, 0.18), 0.0, 0.76),
		"face_shadow": _v153_pbr("Face Shadow", Color(0.025, 0.03, 0.06), 0.0, 0.92),
		"arcane": _v153_pbr("Arcane", Color(0.48, 0.36, 1.0), 0.15, 0.24, Color(0.55, 0.41, 1.0), 2.2),
		"blade": _v153_pbr("Blade", Color(0.78, 0.84, 0.90), 0.90, 0.16),
		"gold": _v153_pbr("Gold", Color(0.82, 0.65, 0.29), 0.82, 0.23),
		"leather": _v153_pbr("Leather", Color(0.29, 0.19, 0.15), 0.0, 0.82),
		"enemy_steel": _v153_pbr("Enemy Steel", Color(0.31, 0.35, 0.40), 0.63, 0.34),
		"enemy_cloth": _v153_pbr("Enemy Cloth", Color(0.19, 0.17, 0.22), 0.0, 0.78),
		"enemy_dark": _v153_pbr("Enemy Dark", Color(0.09, 0.095, 0.13), 0.05, 0.76),
		"enemy_glow": _v153_pbr("Enemy Glow", Color(1.0, 0.45, 0.37), 0.08, 0.30, Color(1.0, 0.34, 0.29), 1.8),
		"goblin_skin": _v153_pbr("Goblin Skin", Color(0.40, 0.47, 0.30), 0.0, 0.70),
		"bat": _v153_pbr("Bat", Color(0.25, 0.19, 0.35), 0.02, 0.78),
		"bat_dark": _v153_pbr("Bat Dark", Color(0.11, 0.10, 0.16), 0.0, 0.84),
		"bone": _v153_pbr("Bone", Color(0.79, 0.75, 0.64), 0.0, 0.68),
		"ghoul": _v153_pbr("Ghoul", Color(0.33, 0.39, 0.34), 0.0, 0.78),
		"ghoul_dark": _v153_pbr("Ghoul Dark", Color(0.16, 0.21, 0.18), 0.0, 0.86),
		"necro": _v153_pbr("Necromancer Robe", Color(0.15, 0.11, 0.22), 0.02, 0.74),
		"necro_dark": _v153_pbr("Necromancer Hood", Color(0.07, 0.06, 0.11), 0.0, 0.86),
		"warden": _v153_pbr("Warden Armor", Color(0.23, 0.15, 0.19), 0.34, 0.48),
		"warden_steel": _v153_pbr("Warden Steel", Color(0.36, 0.33, 0.38), 0.76, 0.25),
		"warden_glow": _v153_pbr("Warden Sigil", Color(0.87, 0.27, 0.25), 0.10, 0.25, Color(1.0, 0.25, 0.22), 2.5),
	}

func _v153_pbr(resource_name: String, color: Color, metallic: float, roughness: float, emission: Color = Color(0, 0, 0, 0), emission_energy: float = 0.0) -> StandardMaterial3D:
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

func _v153_capsule(parent: Node3D, node_name: String, radius: float, height: float, position: Vector3, material: Material) -> MeshInstance3D:
	var shape := CapsuleMesh.new()
	shape.radius = radius
	shape.height = maxf(height, radius * 2.0)
	return _v153_mesh(parent, node_name, shape, position, material)

func _v153_sphere(parent: Node3D, node_name: String, radius: float, position: Vector3, material: Material) -> MeshInstance3D:
	var shape := SphereMesh.new()
	shape.radius = radius
	shape.height = radius * 2.0
	shape.radial_segments = 20
	shape.rings = 10
	return _v153_mesh(parent, node_name, shape, position, material)

func _v153_cylinder(parent: Node3D, node_name: String, top_radius: float, bottom_radius: float, height: float, position: Vector3, material: Material, radial_segments: int = 16) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.top_radius = top_radius
	shape.bottom_radius = bottom_radius
	shape.height = height
	shape.radial_segments = radial_segments
	shape.rings = 2
	return _v153_mesh(parent, node_name, shape, position, material)

func _v153_mesh(parent: Node3D, node_name: String, shape: PrimitiveMesh, position: Vector3, material: Material) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.mesh = shape
	mesh_instance.material_override = material
	mesh_instance.position = position
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(mesh_instance)
	return mesh_instance

func _v153_remove_layer(parent: Node3D) -> void:
	var old := parent.get_node_or_null(PRESENTATION_NODE)
	if old != null:
		parent.remove_child(old)
		old.queue_free()

func _v153_presentation_layer(root: Node3D) -> Node3D:
	if root == null:
		return null
	var path_value: Variant = root.get_meta("v153_presentation_path", NodePath(""))
	if path_value is NodePath:
		var path: NodePath = path_value
		if not path.is_empty():
			return root.get_node_or_null(path) as Node3D
	return null

func _v153_mesh_count(node: Node) -> int:
	if node == null:
		return 0
	var count := 1 if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _v153_mesh_count(child)
	return count

func _v153_shadow_mesh_count(node: Node) -> int:
	if node == null:
		return 0
	var count := 0
	if node is MeshInstance3D:
		var geometry := node as MeshInstance3D
		if geometry.cast_shadow != GeometryInstance3D.SHADOW_CASTING_SETTING_OFF:
			count = 1
	for child in node.get_children():
		count += _v153_shadow_mesh_count(child)
	return count
