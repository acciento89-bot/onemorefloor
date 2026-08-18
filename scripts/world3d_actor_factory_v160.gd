extends "res://scripts/world3d_actor_factory_v154.gd"

# ONE MORE FLOOR v1.60 — production Wanderer presentation.
# The v1.55 glTF remains the proven articulated animation/pivot carrier. This
# layer hides its prototype prism/octagon body pieces and mounts smoother,
# layered production geometry directly on the same animated pivots. Gameplay,
# sockets, actor roots, hitboxes and animation state selection remain inherited.

const WANDERER_PRESENTATION_VERSION := "1.60-production-wanderer"
const WANDERER_PRESENTATION_MARKER := "WandererPresentationV160"
const SurfaceDepthShader: Shader = preload("res://assets/shaders/v160_surface_depth.gdshader")

var wanderer_materials: Dictionary = {}

func _init() -> void:
	super._init()
	_build_wanderer_materials()

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if imported_model_active(root):
		_upgrade_imported_wanderer(root)
	root.set_meta("wanderer_presentation_v160", v160_wanderer_presentation_ready(root))
	return root

func v160_wanderer_presentation_ready(root: Node3D) -> bool:
	if root == null or not imported_model_active(root):
		return false
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		return false
	var marker := imported.get_node_or_null(WANDERER_PRESENTATION_MARKER) as Node3D
	return marker != null \
		and bool(marker.get_meta("ready", false)) \
		and int(marker.get_meta("mesh_count", 0)) >= 22 \
		and _find_named_node3d(imported, "Hips") != null \
		and _find_named_node3d(imported, "SwordPivot") != null

func v160_wanderer_presentation_snapshot(root: Node3D) -> Dictionary:
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D if root != null else null
	var marker := imported.get_node_or_null(WANDERER_PRESENTATION_MARKER) as Node3D if imported != null else null
	return {
		"ready": v160_wanderer_presentation_ready(root),
		"version": WANDERER_PRESENTATION_VERSION,
		"mesh_count": int(marker.get_meta("mesh_count", 0)) if marker != null else 0,
		"material_classes": wanderer_materials.keys(),
		"animation_carrier": "v1.55-articulated-gltf",
		"prototype_geometry_hidden": bool(marker.get_meta("prototype_geometry_hidden", false)) if marker != null else false,
	}

func _upgrade_imported_wanderer(root: Node3D) -> void:
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null or imported.get_node_or_null(WANDERER_PRESENTATION_MARKER) != null:
		return

	# Keep the articulated glTF hierarchy and its animated ArcaneCore. Everything
	# else from the pilot mesh is presentation-only and can be replaced safely.
	_set_geometry_recursive(imported, false, ["ArcaneCore"])
	var arcane_core := _find_named_mesh(imported, "ArcaneCore")
	if arcane_core != null:
		arcane_core.material_override = wanderer_materials["arcane"]
		arcane_core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var marker := Node3D.new()
	marker.name = WANDERER_PRESENTATION_MARKER
	marker.set_meta("ready", false)
	imported.add_child(marker)

	var hips := _find_named_node3d(imported, "Hips")
	var head := _find_named_node3d(imported, "HeadPivot")
	var left_shoulder := _find_named_node3d(imported, "LeftShoulder")
	var right_shoulder := _find_named_node3d(imported, "RightShoulder")
	var left_arm := _find_named_node3d(imported, "LeftArm")
	var right_arm := _find_named_node3d(imported, "RightArm")
	var left_leg := _find_named_node3d(imported, "LeftLeg")
	var right_leg := _find_named_node3d(imported, "RightLeg")
	var sword := _find_named_node3d(imported, "SwordPivot")
	if hips == null or head == null or left_shoulder == null or right_shoulder == null \
		or left_arm == null or right_arm == null or left_leg == null or right_leg == null or sword == null:
		return

	var count := 0
	count += _build_hips(hips)
	count += _build_head(head)
	count += _build_shoulder(left_shoulder, -1.0)
	count += _build_shoulder(right_shoulder, 1.0)
	count += _build_arm(left_arm, -1.0)
	count += _build_arm(right_arm, 1.0)
	count += _build_leg(left_leg, -1.0)
	count += _build_leg(right_leg, 1.0)
	count += _build_sword(sword)

	# Purely visual scale; gameplay stays on the unchanged actor root.
	imported.scale = Vector3.ONE * 1.06
	imported.position.y = -0.015
	marker.set_meta("mesh_count", count)
	marker.set_meta("prototype_geometry_hidden", true)
	marker.set_meta("ready", count >= 22)
	root.set_meta("wanderer_v160_mesh_count", count)

func _build_hips(hips: Node3D) -> int:
	var count := 0
	var torso := _capsule(hips, "V160Torso", 0.30, 0.72, Vector3(0.0, 0.20, 0.0), wanderer_materials["cloth"])
	torso.scale = Vector3(1.06, 1.0, 0.86)
	count += 1
	var chest := _sphere(hips, "V160ChestArmor", 0.34, Vector3(0.0, 0.30, -0.15), wanderer_materials["steel"])
	chest.scale = Vector3(1.12, 0.76, 0.58)
	count += 1
	var lower_chest := _sphere(hips, "V160LowerArmor", 0.26, Vector3(0.0, 0.08, -0.12), wanderer_materials["steel_dark"])
	lower_chest.scale = Vector3(1.18, 0.50, 0.62)
	count += 1
	var belt := _cylinder(hips, "V160Belt", 0.34, 0.34, 0.12, Vector3(0.0, -0.12, 0.0), wanderer_materials["leather"], 20)
	belt.scale = Vector3(1.05, 1.0, 0.82)
	count += 1
	var buckle := _box(hips, "V160Buckle", Vector3(0.15, 0.13, 0.07), Vector3(0.0, -0.12, -0.31), wanderer_materials["gold"])
	count += 1
	var sigil := _sphere(hips, "V160ChestSigil", 0.095, Vector3(0.0, 0.30, -0.355), wanderer_materials["arcane"])
	sigil.scale = Vector3(0.88, 1.15, 0.36)
	sigil.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	count += 1

	# Three overlapping rounded strips read as a draped cape from the fixed
	# isometric camera without introducing expensive cloth simulation.
	for index in range(3):
		var x := (float(index) - 1.0) * 0.19
		var cape := _capsule(hips, "V160Cape%d" % index, 0.105, 0.74, Vector3(x, 0.03, 0.27), wanderer_materials["cape"])
		cape.rotation.x = -0.13
		cape.rotation.z = (float(index) - 1.0) * 0.055
		cape.scale = Vector3(1.05, 1.0, 0.74)
		count += 1
	return count

func _build_head(head: Node3D) -> int:
	var count := 0
	var hood := _sphere(head, "V160Hood", 0.31, Vector3.ZERO, wanderer_materials["cloth"])
	hood.scale = Vector3(1.02, 1.08, 0.94)
	count += 1
	var face := _sphere(head, "V160FaceShadow", 0.225, Vector3(0.0, -0.035, -0.205), wanderer_materials["void"])
	face.scale = Vector3(0.90, 0.88, 0.62)
	face.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	count += 1
	var rim := _torus(head, "V160HoodRim", 0.22, 0.285, Vector3(0.0, -0.02, -0.285), wanderer_materials["gold"])
	rim.rotation.x = PI * 0.5
	rim.scale = Vector3(1.0, 0.88, 1.0)
	count += 1
	var brow := _box(head, "V160Brow", Vector3(0.35, 0.055, 0.06), Vector3(0.0, 0.09, -0.29), wanderer_materials["steel_dark"])
	brow.rotation.z = 0.02
	count += 1
	return count

func _build_shoulder(pivot: Node3D, side: float) -> int:
	var shoulder := _sphere(pivot, "V160Pauldron", 0.205, Vector3.ZERO, wanderer_materials["steel"])
	shoulder.scale = Vector3(1.22, 0.76, 1.10)
	shoulder.rotation.z = -side * 0.08
	var cap := _sphere(pivot, "V160PauldronCap", 0.145, Vector3(side * 0.045, 0.045, -0.085), wanderer_materials["gold"])
	cap.scale = Vector3(1.15, 0.55, 0.82)
	return 2

func _build_arm(pivot: Node3D, side: float) -> int:
	var arm := _capsule(pivot, "V160Arm", 0.105, 0.50, Vector3.ZERO, wanderer_materials["cloth"])
	arm.rotation.z = side * -0.035
	var gauntlet := _capsule(pivot, "V160Gauntlet", 0.12, 0.25, Vector3(0.0, -0.34, -0.015), wanderer_materials["steel"])
	gauntlet.scale = Vector3(1.0, 1.0, 1.06)
	return 2

func _build_leg(pivot: Node3D, _side: float) -> int:
	var leg := _capsule(pivot, "V160Leg", 0.115, 0.53, Vector3.ZERO, wanderer_materials["cloth"])
	leg.scale = Vector3(1.0, 1.0, 1.04)
	var knee := _sphere(pivot, "V160Knee", 0.125, Vector3(0.0, -0.17, -0.10), wanderer_materials["steel_dark"])
	knee.scale = Vector3(1.0, 0.72, 0.76)
	var boot := _capsule(pivot, "V160Boot", 0.135, 0.28, Vector3(0.0, -0.38, -0.055), wanderer_materials["leather"])
	boot.scale = Vector3(0.95, 1.0, 1.22)
	var toe := _sphere(pivot, "V160Toe", 0.135, Vector3(0.0, -0.46, -0.20), wanderer_materials["steel_dark"])
	toe.scale = Vector3(0.92, 0.55, 1.32)
	return 4

func _build_sword(pivot: Node3D) -> int:
	var blade := _cylinder(pivot, "V160Blade", 0.018, 0.055, 0.98, Vector3(0.0, -0.47, 0.0), wanderer_materials["blade"], 6)
	blade.scale = Vector3(1.0, 1.0, 0.56)
	var guard := _box(pivot, "V160Guard", Vector3(0.38, 0.065, 0.10), Vector3(0.0, -0.02, 0.0), wanderer_materials["gold"])
	guard.rotation.y = 0.08
	var grip := _cylinder(pivot, "V160Grip", 0.052, 0.052, 0.28, Vector3(0.0, 0.14, 0.0), wanderer_materials["leather"], 12)
	var pommel := _sphere(pivot, "V160Pommel", 0.075, Vector3(0.0, 0.31, 0.0), wanderer_materials["gold"])
	pommel.scale = Vector3(0.82, 1.0, 0.82)
	var rune := _box(pivot, "V160BladeRune", Vector3(0.026, 0.42, 0.014), Vector3(0.0, -0.46, -0.032), wanderer_materials["arcane"])
	rune.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return 5

func _build_wanderer_materials() -> void:
	wanderer_materials = {
		"cloth": _surface_material(Color("1b243a"), Color("7188bd"), 0.04, 0.70, 0.26, 0.32),
		"cape": _surface_material(Color("251934"), Color("79558f"), 0.02, 0.78, 0.20, 0.24),
		"steel": _surface_material(Color("465365"), Color("b5cae4"), 0.82, 0.29, 0.55, 0.43),
		"steel_dark": _surface_material(Color("242d3b"), Color("687b96"), 0.72, 0.38, 0.42, 0.28),
		"leather": _surface_material(Color("40261a"), Color("956144"), 0.02, 0.84, 0.20, 0.22),
		"gold": _surface_material(Color("815b24"), Color("e7bd63"), 0.88, 0.30, 0.58, 0.40),
		"void": _surface_material(Color("070a12"), Color("252d47"), 0.0, 0.96, 0.12, 0.14),
		"arcane": _surface_material(Color("4d2b91"), Color("b38aff"), 0.08, 0.32, 0.42, 0.40, Color("7c4ed0"), 0.34),
		"blade": _surface_material(Color("71809a"), Color("d7e4f4"), 0.94, 0.20, 0.70, 0.52),
	}

func _surface_material(base: Color, edge: Color, metallic: float, roughness: float, specular: float, edge_strength: float, emission: Color = Color.BLACK, emission_strength: float = 0.0) -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = SurfaceDepthShader
	material.set_shader_parameter("base_color", base)
	material.set_shader_parameter("edge_color", edge)
	material.set_shader_parameter("metallic", metallic)
	material.set_shader_parameter("roughness", roughness)
	material.set_shader_parameter("specular_level", specular)
	material.set_shader_parameter("edge_strength", edge_strength)
	material.set_shader_parameter("height_strength", 0.025)
	material.set_shader_parameter("variation_strength", 0.010)
	material.set_shader_parameter("emission_color", emission)
	material.set_shader_parameter("emission_strength", emission_strength)
	return material

func _capsule(parent: Node3D, node_name: String, radius: float, height: float, pos: Vector3, material: Material) -> MeshInstance3D:
	var node := _v153_capsule(parent, node_name, radius, height, pos, material)
	node.set_meta("wanderer_v160_piece", true)
	return node

func _sphere(parent: Node3D, node_name: String, radius: float, pos: Vector3, material: Material) -> MeshInstance3D:
	var node := _v153_sphere(parent, node_name, radius, pos, material)
	node.set_meta("wanderer_v160_piece", true)
	return node

func _cylinder(parent: Node3D, node_name: String, top_radius: float, bottom_radius: float, height: float, pos: Vector3, material: Material, radial: int) -> MeshInstance3D:
	var node := _v153_cylinder(parent, node_name, top_radius, bottom_radius, height, pos, material, radial)
	node.set_meta("wanderer_v160_piece", true)
	return node

func _box(parent: Node3D, node_name: String, size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	var node := _v153_mesh(parent, node_name, shape, pos, material)
	node.set_meta("wanderer_v160_piece", true)
	return node

func _torus(parent: Node3D, node_name: String, inner_radius: float, outer_radius: float, pos: Vector3, material: Material) -> MeshInstance3D:
	var shape := TorusMesh.new()
	shape.inner_radius = inner_radius
	shape.outer_radius = outer_radius
	shape.rings = 24
	shape.ring_segments = 10
	var node := _v153_mesh(parent, node_name, shape, pos, material)
	node.set_meta("wanderer_v160_piece", true)
	return node

func _find_named_node3d(node: Node, target_name: String) -> Node3D:
	if node == null:
		return null
	if String(node.name) == target_name and node is Node3D:
		return node as Node3D
	for child in node.get_children():
		var found := _find_named_node3d(child, target_name)
		if found != null:
			return found
	return null

func _find_named_mesh(node: Node, target_name: String) -> MeshInstance3D:
	if node == null:
		return null
	if String(node.name) == target_name and node is MeshInstance3D:
		return node as MeshInstance3D
	for child in node.get_children():
		var found := _find_named_mesh(child, target_name)
		if found != null:
			return found
	return null
