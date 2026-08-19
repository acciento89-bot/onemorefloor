extends "res://scripts/world3d_actor_factory_v160_authored.gd"

# ONE MORE FLOOR v1.60 — production enemy silhouette pass.
# Six native enemy archetypes receive distinct authored/procedural silhouettes
# while the proven enemy roots, hitboxes, tell rings, rank crests and combat
# state timing remain inherited. Imported actors would still keep priority.

const ENEMY_PRESENTATION_NODE := "EnemyPresentationV160"
const ENEMY_PRESENTATION_VERSION := "1.60-production-enemy-silhouettes"
const ENEMY_KINDS := ["goblin", "bat", "skeleton", "ghoul", "necromancer", "warden"]

var enemy_v160_materials: Dictionary = {}
var _enemy_build_mesh_count := 0

func _init() -> void:
	super._init()
	_build_enemy_v160_materials()

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	if root == null or imported_model_active(root):
		return
	_build_enemy_presentation_v160(root, kind)
	root.set_meta("enemy_presentation_v160", true)
	root.set_meta("enemy_presentation_v160_kind", kind)

func animate_enemy(root: Node3D, elapsed: float, phase: float, tell: float, hit: float, index: int) -> void:
	super.animate_enemy(root, elapsed, phase, tell, hit, index)
	if root == null or imported_model_active(root):
		return
	var layer := root.get_node_or_null("Motion/Visual/%s" % ENEMY_PRESENTATION_NODE) as Node3D
	if layer == null:
		return
	var kind := String(root.get_meta("enemy_presentation_v160_kind", ""))
	var wave := sin(elapsed * 4.0 + phase + float(index) * 0.37)
	var tell_drive := clampf(tell, 0.0, 1.0)
	var hit_drive := clampf(hit, 0.0, 1.0)
	layer.position = Vector3.ZERO
	layer.rotation = Vector3.ZERO
	layer.scale = Vector3.ONE
	match kind:
		"goblin":
			layer.rotation.y = wave * 0.025 + tell_drive * 0.10
			layer.rotation.z = -0.025 + hit_drive * wave * 0.05
		"bat":
			layer.position.y = wave * 0.055
			layer.rotation.z = wave * 0.09
		"skeleton":
			layer.rotation.x = -tell_drive * 0.045
			layer.rotation.z = hit_drive * wave * 0.035
		"ghoul":
			layer.position.z = -tell_drive * 0.07
			layer.rotation.x = 0.03 + tell_drive * 0.035
		"necromancer":
			layer.position.y = wave * 0.025
			layer.rotation.y = sin(elapsed * 1.2 + phase) * 0.035
		"warden":
			layer.scale = Vector3.ONE * (1.0 + tell_drive * 0.025)
			layer.rotation.z = hit_drive * wave * 0.018

func enemy_presentation_pipeline_ready() -> bool:
	return enemy_v160_materials.size() >= 12 and ENEMY_KINDS.size() == 6

func v160_enemy_presentation_ready(root: Node3D) -> bool:
	if root == null or not bool(root.get_meta("enemy_presentation_v160", false)):
		return false
	var kind := String(root.get_meta("enemy_presentation_v160_kind", ""))
	if kind not in ENEMY_KINDS:
		return false
	var layer := root.get_node_or_null("Motion/Visual/%s" % ENEMY_PRESENTATION_NODE) as Node3D
	return layer != null \
		and layer.visible \
		and int(layer.get_meta("mesh_count", 0)) >= 7 \
		and String(layer.get_meta("kind", "")) == kind

func v160_enemy_presentation_snapshot(root: Node3D) -> Dictionary:
	var layer := root.get_node_or_null("Motion/Visual/%s" % ENEMY_PRESENTATION_NODE) as Node3D if root != null else null
	return {
		"ready": v160_enemy_presentation_ready(root),
		"version": ENEMY_PRESENTATION_VERSION,
		"kind": String(root.get_meta("enemy_presentation_v160_kind", "")) if root != null else "",
		"mesh_count": int(layer.get_meta("mesh_count", 0)) if layer != null else 0,
		"material_classes": enemy_v160_materials.keys(),
		"native_silhouette": true,
	}

func _build_enemy_presentation_v160(root: Node3D, kind: String) -> void:
	var visual := root.get_node_or_null("Motion/Visual") as Node3D
	if visual == null:
		return
	var old := visual.get_node_or_null(ENEMY_PRESENTATION_NODE)
	if old != null:
		visual.remove_child(old)
		old.queue_free()
	var v153_layer := visual.get_node_or_null(PRESENTATION_NODE) as Node3D
	if v153_layer != null:
		v153_layer.visible = false
	var v149_layer := visual.get_node_or_null("ProductionArtV149") as Node3D
	if v149_layer != null:
		v149_layer.visible = false

	var layer := Node3D.new()
	layer.name = ENEMY_PRESENTATION_NODE
	layer.set_meta("kind", kind)
	visual.add_child(layer)
	_enemy_build_mesh_count = 0
	match kind:
		"goblin": _enemy_goblin(layer)
		"bat": _enemy_bat(layer)
		"skeleton": _enemy_skeleton(layer)
		"ghoul": _enemy_ghoul(layer)
		"necromancer": _enemy_necromancer(layer)
		"warden": _enemy_warden(layer)
		_: _enemy_goblin(layer)
	layer.set_meta("mesh_count", _enemy_build_mesh_count)
	root.set_meta("enemy_presentation_v160_mesh_count", _enemy_build_mesh_count)

func _enemy_goblin(layer: Node3D) -> void:
	var skin: Material = enemy_v160_materials["goblin_skin"]
	var leather: Material = enemy_v160_materials["leather"]
	var iron: Material = enemy_v160_materials["scrap_iron"]
	var glow: Material = enemy_v160_materials["amber_glow"]
	var torso := _e_frustum(layer, "GoblinTorsoV160", Vector2(0.25, 0.18), Vector2(0.32, 0.21), 0.56, Vector3(0.0, 0.66, 0.03), leather)
	torso.rotation.x = 0.05
	_e_frustum(layer, "GoblinHeadV160", Vector2(0.23, 0.19), Vector2(0.28, 0.21), 0.30, Vector3(0.0, 1.08, -0.04), skin)
	_e_wedge(layer, "GoblinSnoutV160", 0.26, 0.17, 0.22, Vector3(0.0, 1.02, -0.24), skin)
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var ear := _e_wedge(layer, "GoblinEarV160", 0.13, 0.34, 0.08, Vector3(side * 0.30, 1.12, -0.02), skin)
		ear.rotation.z = side * -1.05
		var arm := _e_frustum(layer, "GoblinArmV160", Vector2(0.07, 0.07), Vector2(0.095, 0.085), 0.47, Vector3(side * 0.32, 0.67, -0.01), skin)
		arm.rotation.z = side * -0.16
		_e_frustum(layer, "GoblinLegV160", Vector2(0.09, 0.10), Vector2(0.11, 0.11), 0.38, Vector3(side * 0.14, 0.24, 0.02), skin)
	_e_box(layer, "GoblinShoulderScrapV160", Vector3(0.28, 0.12, 0.25), Vector3(-0.28, 0.89, -0.02), iron).rotation.z = -0.18
	var dagger := _e_wedge(layer, "GoblinDaggerV160", 0.12, 0.48, 0.055, Vector3(0.43, 0.47, -0.16), iron)
	dagger.rotation.z = -0.28
	for x in [-0.09, 0.09]:
		_e_box(layer, "GoblinEyeV160", Vector3(0.045, 0.025, 0.018), Vector3(x, 1.13, -0.255), glow, false)

func _enemy_bat(layer: Node3D) -> void:
	var body: Material = enemy_v160_materials["bat_body"]
	var membrane: Material = enemy_v160_materials["bat_wing"]
	var glow: Material = enemy_v160_materials["violet_glow"]
	var torso := _e_frustum(layer, "BatBodyV160", Vector2(0.14, 0.12), Vector2(0.24, 0.18), 0.50, Vector3(0.0, 0.82, 0.04), body)
	torso.rotation.x = -0.10
	_e_wedge(layer, "BatHeadV160", 0.32, 0.28, 0.28, Vector3(0.0, 1.12, -0.10), body)
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		_e_wing(layer, "BatWingV160", side, Vector3(0.0, 0.88, 0.05), membrane)
		var ear := _e_wedge(layer, "BatEarV160", 0.10, 0.29, 0.07, Vector3(side * 0.12, 1.33, -0.06), body)
		ear.rotation.z = side * -0.18
	for x in [-0.07, 0.07]:
		_e_box(layer, "BatEyeV160", Vector3(0.036, 0.020, 0.014), Vector3(x, 1.15, -0.255), glow, false)
	_e_wedge(layer, "BatTailV160", 0.16, 0.32, 0.10, Vector3(0.0, 0.51, 0.12), membrane).rotation.x = PI

func _enemy_skeleton(layer: Node3D) -> void:
	var bone: Material = enemy_v160_materials["bone"]
	var iron: Material = enemy_v160_materials["aged_iron"]
	var glow: Material = enemy_v160_materials["amber_glow"]
	_e_frustum(layer, "SkeletonPelvisV160", Vector2(0.18, 0.14), Vector2(0.24, 0.16), 0.20, Vector3(0.0, 0.53, 0.03), bone)
	_e_frustum(layer, "SkeletonSpineV160", Vector2(0.055, 0.055), Vector2(0.075, 0.060), 0.55, Vector3(0.0, 0.83, 0.04), bone)
	_e_frustum(layer, "SkeletonSkullV160", Vector2(0.19, 0.16), Vector2(0.24, 0.18), 0.30, Vector3(0.0, 1.29, -0.05), bone)
	_e_box(layer, "SkeletonJawV160", Vector3(0.26, 0.09, 0.13), Vector3(0.0, 1.16, -0.13), bone)
	for rib_index in range(3):
		var rib_width := 0.46 - float(rib_index) * 0.07
		_e_box(layer, "SkeletonRibV160", Vector3(rib_width, 0.055, 0.08), Vector3(0.0, 1.02 - float(rib_index) * 0.13, -0.08), bone)
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var arm := _e_frustum(layer, "SkeletonArmV160", Vector2(0.045, 0.045), Vector2(0.065, 0.055), 0.58, Vector3(side * 0.31, 0.80, 0.0), bone)
		arm.rotation.z = side * -0.08
		_e_frustum(layer, "SkeletonLegV160", Vector2(0.055, 0.060), Vector2(0.075, 0.070), 0.52, Vector3(side * 0.13, 0.25, 0.02), bone)
	_e_box(layer, "SkeletonHelmBrowV160", Vector3(0.43, 0.08, 0.15), Vector3(0.0, 1.36, -0.10), iron)
	for x in [-0.08, 0.08]:
		_e_box(layer, "SkeletonEyeV160", Vector3(0.042, 0.030, 0.018), Vector3(x, 1.31, -0.225), glow, false)
	var sword := _e_wedge(layer, "SkeletonSwordV160", 0.10, 0.74, 0.055, Vector3(0.43, 0.62, -0.15), iron)
	sword.rotation.z = -0.18
	_e_shield(layer, "SkeletonShieldV160", Vector3(-0.43, 0.73, -0.05), iron, 0.76)

func _enemy_ghoul(layer: Node3D) -> void:
	var flesh: Material = enemy_v160_materials["ghoul_flesh"]
	var dark: Material = enemy_v160_materials["ghoul_dark"]
	var bone: Material = enemy_v160_materials["bone_dark"]
	var glow: Material = enemy_v160_materials["red_glow"]
	var torso := _e_frustum(layer, "GhoulTorsoV160", Vector2(0.31, 0.23), Vector2(0.37, 0.25), 0.72, Vector3(0.0, 0.72, 0.10), flesh)
	torso.rotation.x = 0.22
	var head := _e_wedge(layer, "GhoulHeadV160", 0.42, 0.34, 0.35, Vector3(0.0, 1.15, -0.18), dark)
	head.rotation.x = -0.08
	_e_box(layer, "GhoulJawV160", Vector3(0.31, 0.10, 0.17), Vector3(0.0, 1.02, -0.30), flesh)
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var arm := _e_frustum(layer, "GhoulArmV160", Vector2(0.075, 0.075), Vector2(0.12, 0.10), 0.78, Vector3(side * 0.40, 0.63, -0.10), flesh)
		arm.rotation.z = side * -0.22
		for claw_index in range(2):
			var claw := _e_wedge(layer, "GhoulClawV160", 0.055, 0.34, 0.045, Vector3(side * (0.46 + float(claw_index) * 0.05), 0.24, -0.27 - float(claw_index) * 0.04), bone)
			claw.rotation.z = side * -0.10
	for index in range(3):
		var spike := _e_wedge(layer, "GhoulSpineV160", 0.09, 0.29, 0.08, Vector3(0.0, 0.96 - float(index) * 0.19, 0.34), bone)
		spike.rotation.x = -PI * 0.50
	for x in [-0.075, 0.075]:
		_e_box(layer, "GhoulEyeV160", Vector3(0.040, 0.023, 0.016), Vector3(x, 1.18, -0.365), glow, false)

func _enemy_necromancer(layer: Node3D) -> void:
	var robe: Material = enemy_v160_materials["necro_robe"]
	var hood: Material = enemy_v160_materials["necro_hood"]
	var gold: Material = enemy_v160_materials["old_gold"]
	var glow: Material = enemy_v160_materials["violet_glow"]
	_e_frustum(layer, "NecroRobeV160", Vector2(0.40, 0.31), Vector2(0.23, 0.20), 1.03, Vector3(0.0, 0.61, 0.07), robe)
	var hood_mesh := _load_authored_mesh("hood")
	if hood_mesh != null:
		_e_mesh(layer, "NecroHoodV160", hood_mesh, Vector3(0.0, 1.38, -0.02), hood, Vector3(1.08, 1.10, 1.08))
	else:
		_e_wedge(layer, "NecroHoodV160", 0.52, 0.52, 0.45, Vector3(0.0, 1.40, -0.07), hood)
	_e_box(layer, "NecroFaceV160", Vector3(0.26, 0.25, 0.045), Vector3(0.0, 1.34, -0.27), enemy_v160_materials["void"])
	for x in [-0.07, 0.07]:
		_e_box(layer, "NecroEyeV160", Vector3(0.038, 0.022, 0.014), Vector3(x, 1.38, -0.300), glow, false)
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var sleeve := _e_frustum(layer, "NecroSleeveV160", Vector2(0.11, 0.11), Vector2(0.17, 0.14), 0.58, Vector3(side * 0.34, 0.80, -0.02), robe)
		sleeve.rotation.z = side * -0.16
	var staff := _e_cylinder(layer, "NecroStaffV160", 0.045, 0.045, 1.40, Vector3(0.55, 0.72, -0.08), gold, 8)
	staff.rotation.z = -0.08
	_e_sphere(layer, "NecroStaffCoreV160", 0.14, Vector3(0.61, 1.42, -0.08), glow, 10, 5, false)
	for index in range(3):
		var spike := _e_wedge(layer, "NecroCrownV160", 0.075, 0.30, 0.065, Vector3((float(index) - 1.0) * 0.14, 1.72, 0.0), gold)
		spike.rotation.z = (float(index) - 1.0) * -0.13
	_e_box(layer, "NecroRobeRuneV160", Vector3(0.07, 0.36, 0.025), Vector3(0.0, 0.73, -0.255), gold)

func _enemy_warden(layer: Node3D) -> void:
	var armor: Material = enemy_v160_materials["warden_armor"]
	var iron: Material = enemy_v160_materials["warden_iron"]
	var gold: Material = enemy_v160_materials["old_gold"]
	var glow: Material = enemy_v160_materials["red_glow"]
	_e_frustum(layer, "WardenTorsoV160", Vector2(0.43, 0.31), Vector2(0.54, 0.36), 0.98, Vector3(0.0, 0.92, 0.04), armor)
	_e_frustum(layer, "WardenChestV160", Vector2(0.47, 0.18), Vector2(0.38, 0.15), 0.46, Vector3(0.0, 1.16, -0.24), iron)
	_e_frustum(layer, "WardenHelmV160", Vector2(0.30, 0.24), Vector2(0.38, 0.27), 0.38, Vector3(0.0, 1.70, -0.04), iron)
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var shoulder := _e_wedge(layer, "WardenPauldronV160", 0.42, 0.32, 0.35, Vector3(side * 0.55, 1.30, -0.02), iron)
		shoulder.rotation.z = side * -0.30
		var arm := _e_frustum(layer, "WardenArmV160", Vector2(0.12, 0.12), Vector2(0.17, 0.14), 0.72, Vector3(side * 0.52, 0.88, 0.0), armor)
		arm.rotation.z = side * -0.08
		var horn := _e_wedge(layer, "WardenHornV160", 0.10, 0.46, 0.09, Vector3(side * 0.20, 2.02, 0.0), gold)
		horn.rotation.z = side * -0.24
	_e_shield(layer, "WardenShieldV160", Vector3(-0.62, 0.94, -0.10), iron, 1.22)
	var blade := _e_wedge(layer, "WardenBladeV160", 0.18, 1.05, 0.08, Vector3(0.69, 0.82, -0.15), iron)
	blade.rotation.z = -0.16
	_e_box(layer, "WardenChestRuneV160", Vector3(0.18, 0.24, 0.035), Vector3(0.0, 1.15, -0.405), glow, false)
	for x in [-0.10, 0.10]:
		_e_box(layer, "WardenEyeV160", Vector3(0.052, 0.025, 0.016), Vector3(x, 1.74, -0.292), glow, false)

func _build_enemy_v160_materials() -> void:
	if not enemy_v160_materials.is_empty():
		return
	enemy_v160_materials = {
		"goblin_skin": _e_material("Goblin Skin V160", Color("596947"), 0.0, 0.83),
		"leather": _e_material("Enemy Leather V160", Color("4b2f22"), 0.0, 0.88),
		"scrap_iron": _e_material("Scrap Iron V160", Color("4b5158"), 0.62, 0.48),
		"bat_body": _e_material("Bat Body V160", Color("231d35"), 0.0, 0.90),
		"bat_wing": _e_material("Bat Wing V160", Color("38284b"), 0.0, 0.94),
		"bone": _e_material("Bone V160", Color("aaa38c"), 0.0, 0.87),
		"bone_dark": _e_material("Dark Bone V160", Color("756f60"), 0.0, 0.92),
		"aged_iron": _e_material("Aged Iron V160", Color("383d44"), 0.72, 0.50),
		"ghoul_flesh": _e_material("Ghoul Flesh V160", Color("4b594d"), 0.0, 0.92),
		"ghoul_dark": _e_material("Ghoul Dark V160", Color("202b26"), 0.0, 0.96),
		"necro_robe": _e_material("Necro Robe V160", Color("251b35"), 0.0, 0.88),
		"necro_hood": _e_material("Necro Hood V160", Color("100d18"), 0.0, 0.96),
		"warden_armor": _e_material("Warden Armor V160", Color("37292e"), 0.52, 0.54),
		"warden_iron": _e_material("Warden Iron V160", Color("4a4b52"), 0.82, 0.36),
		"old_gold": _e_material("Old Gold V160", Color("8b682f"), 0.78, 0.42),
		"void": _e_material("Enemy Void V160", Color("05070b"), 0.0, 1.0),
		"amber_glow": _e_material("Amber Glow V160", Color("8d4c22"), 0.0, 0.50, Color("ff8e38"), 1.30),
		"violet_glow": _e_material("Violet Glow V160", Color("57358f"), 0.0, 0.45, Color("9c64ef"), 1.20),
		"red_glow": _e_material("Red Glow V160", Color("782c2c"), 0.0, 0.46, Color("ef4f48"), 1.25),
	}

func _e_material(name_value: String, color: Color, metallic_value: float, roughness_value: float, emission_value: Color = Color.BLACK, emission_energy: float = 0.0) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = name_value
	material.albedo_color = color
	material.metallic = metallic_value
	material.roughness = roughness_value
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission_value
		material.emission_energy_multiplier = emission_energy
	return material

func _e_mesh(parent: Node3D, node_name: String, mesh: Mesh, pos: Vector3, material: Material, scale_value: Vector3 = Vector3.ONE, cast_shadow: bool = true) -> MeshInstance3D:
	# v1.53's helper is intentionally typed to PrimitiveMesh. v1.60 also uses
	# SurfaceTool ArrayMesh geometry for frustums/wedges/wings/shields, so create
	# the MeshInstance3D directly here instead of narrowing the mesh type.
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh
	node.material_override = material
	node.position = pos
	node.scale = scale_value
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if cast_shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	node.set_meta("enemy_v160_piece", true)
	parent.add_child(node)
	_enemy_build_mesh_count += 1
	return node

func _e_box(parent: Node3D, node_name: String, size: Vector3, pos: Vector3, material: Material, cast_shadow: bool = true) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _e_mesh(parent, node_name, mesh, pos, material, Vector3.ONE, cast_shadow)

func _e_sphere(parent: Node3D, node_name: String, radius: float, pos: Vector3, material: Material, radial: int = 10, rings: int = 5, cast_shadow: bool = true) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = radial
	mesh.rings = rings
	return _e_mesh(parent, node_name, mesh, pos, material, Vector3.ONE, cast_shadow)

func _e_cylinder(parent: Node3D, node_name: String, top_radius: float, bottom_radius: float, height: float, pos: Vector3, material: Material, radial: int = 8) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = height
	mesh.radial_segments = radial
	return _e_mesh(parent, node_name, mesh, pos, material)

func _e_frustum(parent: Node3D, node_name: String, bottom_half: Vector2, top_half: Vector2, height: float, pos: Vector3, material: Material) -> MeshInstance3D:
	return _e_mesh(parent, node_name, _e_frustum_mesh(bottom_half, top_half, height), pos, material)

func _e_wedge(parent: Node3D, node_name: String, width: float, height: float, depth: float, pos: Vector3, material: Material) -> MeshInstance3D:
	return _e_mesh(parent, node_name, _e_wedge_mesh(width, height, depth), pos, material)

func _e_wing(parent: Node3D, node_name: String, side: float, pos: Vector3, material: Material) -> MeshInstance3D:
	var points: Array[Vector2] = [
		Vector2(0.00 * side, 0.16),
		Vector2(0.42 * side, 0.38),
		Vector2(0.95 * side, 0.10),
		Vector2(0.76 * side, -0.32),
		Vector2(0.32 * side, -0.18),
	]
	return _e_mesh(parent, node_name, _e_extruded_polygon_mesh(points, 0.075), pos, material)

func _e_shield(parent: Node3D, node_name: String, pos: Vector3, material: Material, scale_value: float) -> MeshInstance3D:
	var points: Array[Vector2] = [
		Vector2(-0.30, 0.42), Vector2(0.30, 0.42), Vector2(0.38, 0.05),
		Vector2(0.22, -0.40), Vector2(0.0, -0.54), Vector2(-0.22, -0.40), Vector2(-0.38, 0.05),
	]
	var shield := _e_mesh(parent, node_name, _e_extruded_polygon_mesh(points, 0.10), pos, material, Vector3.ONE * scale_value)
	shield.rotation.y = -0.14
	return shield

func _e_frustum_mesh(bottom_half: Vector2, top_half: Vector2, height: float) -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var y0 := -height * 0.5
	var y1 := height * 0.5
	var b0 := Vector3(-bottom_half.x, y0, -bottom_half.y)
	var b1 := Vector3(bottom_half.x, y0, -bottom_half.y)
	var b2 := Vector3(bottom_half.x, y0, bottom_half.y)
	var b3 := Vector3(-bottom_half.x, y0, bottom_half.y)
	var t0 := Vector3(-top_half.x, y1, -top_half.y)
	var t1 := Vector3(top_half.x, y1, -top_half.y)
	var t2 := Vector3(top_half.x, y1, top_half.y)
	var t3 := Vector3(-top_half.x, y1, top_half.y)
	_e_quad(tool, b0, b3, b2, b1)
	_e_quad(tool, t0, t1, t2, t3)
	_e_quad(tool, b0, b1, t1, t0)
	_e_quad(tool, b1, b2, t2, t1)
	_e_quad(tool, b2, b3, t3, t2)
	_e_quad(tool, b3, b0, t0, t3)
	tool.generate_normals()
	return tool.commit()

func _e_wedge_mesh(width: float, height: float, depth: float) -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var x := width * 0.5
	var y := height * 0.5
	var z := depth * 0.5
	var a := Vector3(-x, -y, -z)
	var b := Vector3(x, -y, -z)
	var c := Vector3(0.0, y, -z)
	var d := Vector3(-x, -y, z)
	var e := Vector3(x, -y, z)
	var f := Vector3(0.0, y, z)
	_e_tri(tool, a, b, c)
	_e_tri(tool, f, e, d)
	_e_quad(tool, a, d, e, b)
	_e_quad(tool, b, e, f, c)
	_e_quad(tool, c, f, d, a)
	tool.generate_normals()
	return tool.commit()

func _e_extruded_polygon_mesh(points: Array[Vector2], depth: float) -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var zf := -depth * 0.5
	var zb := depth * 0.5
	for index in range(1, points.size() - 1):
		_e_tri(tool, Vector3(points[0].x, points[0].y, zf), Vector3(points[index + 1].x, points[index + 1].y, zf), Vector3(points[index].x, points[index].y, zf))
		_e_tri(tool, Vector3(points[0].x, points[0].y, zb), Vector3(points[index].x, points[index].y, zb), Vector3(points[index + 1].x, points[index + 1].y, zb))
	for index in range(points.size()):
		var next := (index + 1) % points.size()
		var a := Vector3(points[index].x, points[index].y, zf)
		var b := Vector3(points[next].x, points[next].y, zf)
		var c := Vector3(points[next].x, points[next].y, zb)
		var d := Vector3(points[index].x, points[index].y, zb)
		_e_quad(tool, a, b, c, d)
	tool.generate_normals()
	return tool.commit()

func _e_quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	_e_tri(tool, a, b, c)
	_e_tri(tool, a, c, d)

func _e_tri(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	tool.add_vertex(a)
	tool.add_vertex(b)
	tool.add_vertex(c)
