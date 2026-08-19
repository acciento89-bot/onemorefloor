extends "res://scripts/world3d_actor_factory_v160_wanderer_hood_r11.gd"

# ONE MORE FLOOR v1.66 r1.1 — Character Form & Readability.
# Presentation-only top layer over the accepted v1.60 authored actor stack.
# r1.1 rejects the r1 SphereMesh/blob direction and uses restrained faceted
# secondary planes/plates plus existing-material tuning instead. Animation pivots,
# hitboxes, sockets, attack timing and combat authority remain inherited unchanged.

const CHARACTER_FORM_V166_VERSION := "1.66-character-form-r1.1"
const CHARACTER_FORM_V166_NODE := "CharacterFormV166"

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if root != null and imported_model_active(root):
		_refine_wanderer_form_v166(root)
	if root != null:
		root.set_meta("character_form_v166", CHARACTER_FORM_V166_VERSION)
	return root

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	if root == null or imported_model_active(root):
		return
	_apply_enemy_form_v166(root, kind)
	root.set_meta("enemy_character_form_v166", CHARACTER_FORM_V166_VERSION)

func character_form_pipeline_ready() -> bool:
	return character_quality_pipeline_ready()

func v166_character_form_player_ready(root: Node3D) -> bool:
	if root == null or String(root.get_meta("character_form_v166", "")) != CHARACTER_FORM_V166_VERSION:
		return false
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		return false
	return _find_named_mesh(imported, "V160AuthoredChestplate") != null \
		and _find_named_mesh(imported, "V160AuthoredCape") != null \
		and _find_named_mesh(imported, "V160AuthoredBlade") != null \
		and String(root.get_meta("wanderer_hood_r11", "")) == WANDERER_HOOD_R11_VERSION

func v166_character_form_enemy_ready(root: Node3D) -> bool:
	if root == null or String(root.get_meta("enemy_character_form_v166", "")) != CHARACTER_FORM_V166_VERSION:
		return false
	var kind := String(root.get_meta("enemy_presentation_v160_kind", ""))
	if kind == "skeleton":
		return true
	var layer := root.get_node_or_null("Motion/Visual/EnemyPresentationV160") as Node3D
	if layer == null:
		return false
	var form := layer.get_node_or_null(CHARACTER_FORM_V166_NODE) as Node3D
	if form == null:
		return false
	var targets := {
		"goblin": 3,
		"bat": 3,
		"ghoul": 4,
		"necromancer": 4,
		"warden": 5,
	}
	return form.get_child_count() >= int(targets.get(kind, 0))

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	var data: Dictionary = super.character_quality_snapshot(root)
	data["character_form_v166_version"] = CHARACTER_FORM_V166_VERSION
	data["character_form_v166_player_ready"] = v166_character_form_player_ready(root) if root != null else false
	data["character_form_v166_profile"] = "faceted-secondary-plate-and-material-hierarchy"
	data["character_form_v166_skeleton_geometry_locked"] = true
	data["character_form_v166_sphere_meshes_rejected"] = true
	return data

func _refine_wanderer_form_v166(root: Node3D) -> void:
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		return

	# Keep the accepted hood/rig and rebalance the visible body around it. The
	# cape narrows slightly, armor gains width/contrast and the blade becomes a
	# stronger side-readable shape without changing sockets or attack authority.
	_scale_named(imported, "V160AuthoredChestplate", Vector3(1.08, 1.04, 1.05))
	_scale_named(imported, "V160AuthoredCape", Vector3(0.90, 1.04, 0.92))
	_scale_named(imported, "V160AuthoredPauldronL", Vector3(1.18, 1.08, 1.10))
	_scale_named(imported, "V160AuthoredPauldronR", Vector3(1.12, 1.05, 1.08))
	_scale_named(imported, "V160Belt", Vector3(1.10, 1.10, 1.04))
	_scale_named(imported, "V160AuthoredBlade", Vector3(1.16, 1.10, 1.12))
	_scale_named(imported, "V160AuthoredBootL", Vector3(1.04, 1.06, 1.05))
	_scale_named(imported, "V160AuthoredBootR", Vector3(1.04, 1.06, 1.05))

	_refine_mesh_material(imported, "V160AuthoredChestplate", Color("414d5b"), Color("a8b8c8"), 0.43, 0.34, 0.25)
	_refine_mesh_material(imported, "V160AuthoredPauldronL", Color("394553"), Color("98aabc"), 0.47, 0.30, 0.22)
	_refine_mesh_material(imported, "V160AuthoredPauldronR", Color("394553"), Color("98aabc"), 0.47, 0.30, 0.22)
	_refine_mesh_material(imported, "V160AuthoredBlade", Color("73859a"), Color("e2ebf2"), 0.24, 0.52, 0.34)

func _apply_enemy_form_v166(root: Node3D, kind: String) -> void:
	var layer := root.get_node_or_null("Motion/Visual/EnemyPresentationV160") as Node3D
	if layer == null:
		return
	var previous := layer.get_node_or_null(CHARACTER_FORM_V166_NODE)
	if previous != null:
		layer.remove_child(previous)
		previous.queue_free()

	# Skeleton remains the geometric readability benchmark.
	if kind == "skeleton":
		return

	var form := Node3D.new()
	form.name = CHARACTER_FORM_V166_NODE
	form.set_meta("version", CHARACTER_FORM_V166_VERSION)
	form.set_meta("kind", kind)
	form.set_meta("profile", "faceted-r1.1")
	layer.add_child(form)

	var authored := layer.get_node_or_null("AuthoredBodyV160") as MeshInstance3D
	match kind:
		"goblin":
			if authored != null:
				authored.scale *= Vector3(1.025, 1.035, 1.015)
			_v166_plate(form, "GoblinShoulderPlateV166", Vector3(0.24, 0.085, 0.16), Vector3(-0.30, 0.91, -0.045), enemy_v160_materials["scrap_iron"], Vector3(0.05, 0.10, -0.22))
			_v166_plate(form, "GoblinBeltBuckleV166", Vector3(0.08, 0.055, 0.035), Vector3(0.05, 0.56, -0.245), enemy_v160_materials["aged_iron"], Vector3(0.02, 0.04, 0.08))
			_v166_plate(form, "GoblinHipPouchV166", Vector3(0.14, 0.09, 0.055), Vector3(-0.20, 0.53, -0.10), enemy_v160_materials["leather"], Vector3(0.04, -0.08, 0.20))
			_scale_layer_mesh(layer, "GoblinDaggerV160", Vector3(1.12, 1.12, 1.10))
		"bat":
			if authored != null:
				authored.scale *= Vector3(1.025, 1.015, 1.015)
			_v166_plate(form, "BatThoraxPlateV166", Vector3(0.16, 0.24, 0.085), Vector3(0.0, 0.86, -0.07), enemy_v160_materials["bat_body"], Vector3(-0.10, 0.05, 0.0))
			_v166_plate(form, "BatWingRootLV166", Vector3(0.13, 0.075, 0.065), Vector3(-0.23, 1.00, 0.00), enemy_v160_materials["bat_body"], Vector3(0.0, 0.18, -0.24))
			_v166_plate(form, "BatWingRootRV166", Vector3(0.13, 0.075, 0.065), Vector3(0.23, 1.00, 0.00), enemy_v160_materials["bat_body"], Vector3(0.0, -0.18, 0.24))
		"ghoul":
			if authored != null:
				authored.scale *= Vector3(1.025, 1.015, 1.02)
			_v166_plate(form, "GhoulShoulderLV166", Vector3(0.21, 0.085, 0.145), Vector3(-0.31, 0.97, -0.035), enemy_v160_materials["ghoul_flesh"], Vector3(0.03, 0.08, -0.20))
			_v166_plate(form, "GhoulShoulderRV166", Vector3(0.18, 0.075, 0.13), Vector3(0.30, 0.93, -0.025), enemy_v160_materials["ghoul_dark"], Vector3(-0.02, -0.08, 0.16))
			_v166_plate(form, "GhoulSternumV166", Vector3(0.10, 0.19, 0.045), Vector3(0.0, 0.89, -0.26), enemy_v160_materials["bone_dark"], Vector3(0.0, 0.0, 0.03))
			_v166_plate(form, "GhoulHipPlateV166", Vector3(0.22, 0.085, 0.12), Vector3(-0.04, 0.49, 0.03), enemy_v160_materials["ghoul_dark"], Vector3(0.10, 0.06, 0.0))
		"necromancer":
			if authored != null:
				authored.scale *= Vector3(1.03, 1.02, 1.02)
			_v166_plate(form, "NecroMantleLV166", Vector3(0.25, 0.075, 0.16), Vector3(-0.22, 1.22, -0.055), enemy_v160_materials["necro_hood"], Vector3(0.03, 0.10, -0.12))
			_v166_plate(form, "NecroMantleRV166", Vector3(0.25, 0.075, 0.16), Vector3(0.22, 1.22, -0.055), enemy_v160_materials["necro_hood"], Vector3(-0.03, -0.10, 0.12))
			_v166_plate(form, "NecroCollarV166", Vector3(0.14, 0.075, 0.055), Vector3(0.0, 1.18, -0.24), enemy_v160_materials["aged_iron"], Vector3(0.05, 0.0, 0.0))
			_v166_plate(form, "NecroWaistPlateV166", Vector3(0.24, 0.07, 0.095), Vector3(0.0, 0.76, -0.04), enemy_v160_materials["necro_robe"], Vector3(0.0, 0.0, 0.04))
			_scale_layer_mesh(layer, "NecroStaffV160", Vector3(1.08, 1.08, 1.08))
		"warden":
			if authored != null:
				authored.scale *= Vector3(1.04, 1.015, 1.025)
			_v166_plate(form, "WardenShoulderLV166", Vector3(0.28, 0.095, 0.20), Vector3(-0.30, 1.34, -0.035), enemy_v160_materials["warden_iron"], Vector3(0.02, 0.10, -0.12))
			_v166_plate(form, "WardenShoulderRV166", Vector3(0.28, 0.095, 0.20), Vector3(0.30, 1.34, -0.035), enemy_v160_materials["warden_iron"], Vector3(-0.02, -0.10, 0.12))
			_v166_plate(form, "WardenChestBossV166", Vector3(0.16, 0.10, 0.05), Vector3(0.0, 1.17, -0.27), enemy_v160_materials["warden_armor"], Vector3(0.08, 0.0, 0.0))
			_v166_plate(form, "WardenHipPlateLV166", Vector3(0.17, 0.08, 0.10), Vector3(-0.20, 0.75, -0.03), enemy_v160_materials["warden_armor"], Vector3(0.03, 0.08, -0.10))
			_v166_plate(form, "WardenHipPlateRV166", Vector3(0.17, 0.08, 0.10), Vector3(0.20, 0.75, -0.03), enemy_v160_materials["warden_armor"], Vector3(-0.03, -0.08, 0.10))
			_scale_layer_mesh(layer, "WardenShieldV160", Vector3(1.08, 1.08, 1.08))
			_scale_layer_mesh(layer, "WardenBladeV160", Vector3(1.10, 1.10, 1.08))

	form.set_meta("mesh_count", form.get_child_count())

func _v166_plate(parent: Node3D, name_value: String, scale_value: Vector3, position_value: Vector3, material: Material, rotation_value: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var box := BoxMesh.new()
	box.size = Vector3.ONE
	var node := MeshInstance3D.new()
	node.name = name_value
	node.mesh = box
	node.scale = scale_value
	node.position = position_value
	node.rotation = rotation_value
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	node.set_meta("character_form_v166", CHARACTER_FORM_V166_VERSION)
	node.set_meta("character_form_profile", "faceted-plate")
	parent.add_child(node)
	return node

func _scale_named(root: Node, node_name: String, multiplier: Vector3) -> void:
	var mesh := _find_named_mesh(root, node_name)
	if mesh != null:
		mesh.scale *= multiplier
		mesh.set_meta("character_form_v166", CHARACTER_FORM_V166_VERSION)

func _scale_layer_mesh(root: Node, node_name: String, multiplier: Vector3) -> void:
	var mesh := _find_named_mesh(root, node_name)
	if mesh != null:
		mesh.scale *= multiplier
		mesh.set_meta("character_form_v166", CHARACTER_FORM_V166_VERSION)

func _refine_mesh_material(root: Node, node_name: String, base: Color, edge: Color, roughness_value: float, specular_value: float, edge_strength_value: float) -> void:
	var mesh := _find_named_mesh(root, node_name)
	if mesh == null:
		return
	var source := mesh.material_override as ShaderMaterial
	if source == null:
		return
	var material := source.duplicate() as ShaderMaterial
	material.set_shader_parameter("base_color", base)
	material.set_shader_parameter("edge_color", edge)
	material.set_shader_parameter("roughness", roughness_value)
	material.set_shader_parameter("specular_level", specular_value)
	material.set_shader_parameter("edge_strength", edge_strength_value)
	mesh.material_override = material
