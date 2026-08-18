extends "res://scripts/world3d_actor_factory_v160.gd"

# ONE MORE FLOOR v1.60 — Wanderer silhouette refinement.
# Keeps the proven animated v1.60 presentation but removes the remaining
# rounded/astronaut read: slimmer limbs, flatter armor, smaller hood and one
# coherent tapered cape with thickness instead of three capsule strips.

const WANDERER_POLISH_VERSION := "1.60-production-wanderer-polish"

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if imported_model_active(root):
		_refine_wanderer(root)
	root.set_meta("wanderer_polish_v160", v160_wanderer_polish_ready(root))
	return root

func v160_wanderer_polish_ready(root: Node3D) -> bool:
	if not v160_wanderer_presentation_ready(root):
		return false
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	var cape := _find_named_mesh(imported, "V160ProductionCape")
	var hood := _find_named_mesh(imported, "V160Hood")
	return cape != null and cape.visible and hood != null and hood.visible \
		and String(root.get_meta("wanderer_silhouette_v160", "")) == WANDERER_POLISH_VERSION

func v160_wanderer_polish_snapshot(root: Node3D) -> Dictionary:
	return {
		"ready": v160_wanderer_polish_ready(root),
		"version": WANDERER_POLISH_VERSION,
		"cape": "coherent-tapered-prism",
		"hood_scale": "reduced",
		"armor_profile": "flattened-layered",
		"limb_profile": "slender",
	}

func _refine_wanderer(root: Node3D) -> void:
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		return
	var hips := _find_named_node3d(imported, "Hips")
	if hips == null:
		return

	# Retire the three temporary rounded cape strips from the first v1.60 pass.
	for index in range(3):
		var old_cape := _find_named_mesh(imported, "V160Cape%d" % index)
		if old_cape != null:
			old_cape.visible = false

	var torso := _find_named_mesh(imported, "V160Torso")
	if torso != null:
		torso.scale = Vector3(0.94, 1.0, 0.78)
	var chest := _find_named_mesh(imported, "V160ChestArmor")
	if chest != null:
		chest.scale = Vector3(1.04, 0.62, 0.52)
	var lower_chest := _find_named_mesh(imported, "V160LowerArmor")
	if lower_chest != null:
		lower_chest.scale = Vector3(1.04, 0.42, 0.54)

	var hood := _find_named_mesh(imported, "V160Hood")
	if hood != null:
		hood.scale = Vector3(0.90, 0.98, 0.84)
	var face := _find_named_mesh(imported, "V160FaceShadow")
	if face != null:
		face.scale = Vector3(0.82, 0.83, 0.56)
	var hood_rim := _find_named_mesh(imported, "V160HoodRim")
	if hood_rim != null:
		hood_rim.scale = Vector3(0.86, 0.78, 0.86)

	for side_name in ["LeftShoulder", "RightShoulder"]:
		var shoulder_root := _find_named_node3d(imported, side_name)
		if shoulder_root != null:
			var pauldron := _find_named_mesh(shoulder_root, "V160Pauldron")
			if pauldron != null:
				pauldron.scale = Vector3(1.18, 0.48, 0.90)
			var cap := _find_named_mesh(shoulder_root, "V160PauldronCap")
			if cap != null:
				cap.scale = Vector3(1.05, 0.34, 0.66)

	for arm_name in ["LeftArm", "RightArm"]:
		var arm_root := _find_named_node3d(imported, arm_name)
		if arm_root != null:
			var arm := _find_named_mesh(arm_root, "V160Arm")
			if arm != null:
				arm.scale = Vector3(0.82, 1.0, 0.84)
			var gauntlet := _find_named_mesh(arm_root, "V160Gauntlet")
			if gauntlet != null:
				gauntlet.scale = Vector3(0.86, 0.96, 0.92)

	for leg_name in ["LeftLeg", "RightLeg"]:
		var leg_root := _find_named_node3d(imported, leg_name)
		if leg_root != null:
			var leg := _find_named_mesh(leg_root, "V160Leg")
			if leg != null:
				leg.scale = Vector3(0.80, 1.0, 0.86)
			var boot := _find_named_mesh(leg_root, "V160Boot")
			if boot != null:
				boot.scale = Vector3(0.84, 0.94, 1.10)
			var toe := _find_named_mesh(leg_root, "V160Toe")
			if toe != null:
				toe.scale = Vector3(0.84, 0.47, 1.18)

	var production_cape := MeshInstance3D.new()
	production_cape.name = "V160ProductionCape"
	production_cape.mesh = _build_tapered_cape_mesh()
	production_cape.material_override = wanderer_materials["cape"]
	production_cape.position = Vector3(0.0, 0.02, 0.30)
	production_cape.rotation.x = -0.08
	production_cape.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	production_cape.set_meta("wanderer_v160_piece", true)
	hips.add_child(production_cape)

	var hem := _box(hips, "V160CapeHem", Vector3(0.78, 0.055, 0.06), Vector3(0.0, -0.45, 0.39), wanderer_materials["gold"])
	hem.rotation.x = -0.05
	var clasp := _sphere(hips, "V160CapeClasp", 0.075, Vector3(0.0, 0.39, 0.27), wanderer_materials["gold"])
	clasp.scale = Vector3(1.2, 0.70, 0.65)

	root.set_meta("wanderer_silhouette_v160", WANDERER_POLISH_VERSION)

func _build_tapered_cape_mesh() -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var front := [
		Vector3(-0.27, 0.38, -0.035),
		Vector3(0.27, 0.38, -0.035),
		Vector3(0.46, -0.48, 0.055),
		Vector3(-0.46, -0.48, 0.055),
	]
	var back := [
		Vector3(-0.27, 0.38, 0.045),
		Vector3(0.27, 0.38, 0.045),
		Vector3(0.46, -0.48, 0.135),
		Vector3(-0.46, -0.48, 0.135),
	]
	_add_quad(tool, front[0], front[3], front[2], front[1])
	_add_quad(tool, back[0], back[1], back[2], back[3])
	_add_quad(tool, front[0], back[0], back[3], front[3])
	_add_quad(tool, front[1], front[2], back[2], back[1])
	_add_quad(tool, front[0], front[1], back[1], back[0])
	_add_quad(tool, front[3], back[3], back[2], front[2])
	tool.generate_normals()
	return tool.commit()

func _add_quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	tool.add_vertex(a)
	tool.add_vertex(b)
	tool.add_vertex(c)
	tool.add_vertex(a)
	tool.add_vertex(c)
	tool.add_vertex(d)
