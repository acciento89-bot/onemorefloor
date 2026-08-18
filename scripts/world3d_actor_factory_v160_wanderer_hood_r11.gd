extends "res://scripts/world3d_actor_factory_v160_enemy_quality_r5.gd"

# ONE MORE FLOOR v1.60 — Wanderer hood r11.
# Presentation-only candidate on top of the accepted r8.1 + Enemy r5.1 stack.
# The existing r9 OBJ remains in place as rollback; r11 swaps only the visible
# hood mesh at runtime to a separate smooth cloth-volume OBJ.

const WANDERER_HOOD_R11_VERSION := "1.60-wanderer-hood-r11"
const WandererHoodR11: Mesh = preload("res://assets/models/actors/v160/wanderer_hood_r11.obj")

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if root != null and imported_model_active(root):
		_apply_wanderer_hood_r11(root)
	root.set_meta("wanderer_hood_r11", WANDERER_HOOD_R11_VERSION)
	return root

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	var data: Dictionary = super.character_quality_snapshot(root)
	data["wanderer_hood_r11"] = root != null \
		and String(root.get_meta("wanderer_hood_r11", "")) == WANDERER_HOOD_R11_VERSION
	data["wanderer_hood_r11_version"] = WANDERER_HOOD_R11_VERSION
	data["wanderer_hood_profile"] = "smooth-closed-cloth-cowl-r11"
	return data

func _apply_wanderer_hood_r11(root: Node3D) -> void:
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		return

	var hood := _find_named_mesh(imported, "V160AuthoredHood")
	if hood == null:
		return

	# Preserve the authored-r9 node/pivot/material contract but replace only its
	# mesh resource with the r11 candidate. This makes rollback trivial.
	hood.mesh = WandererHoodR11
	_tune_named_mesh(imported, "V160AuthoredHood", Vector3(0.66, 0.78, 0.69), Vector3(0.0, -0.038, -0.010))
	hood.rotation = Vector3(-0.018, 0.0, 0.0)

	# Dedicated softer hood cloth response: less metallic-looking edge/specular
	# than torso cloth, while retaining the same lightweight surface-depth shader.
	var source_material := hood.material_override as ShaderMaterial
	if source_material != null:
		var hood_material := source_material.duplicate() as ShaderMaterial
		hood_material.set_shader_parameter("base_color", Color("172230"))
		hood_material.set_shader_parameter("edge_color", Color("45566a"))
		hood_material.set_shader_parameter("roughness", 0.94)
		hood_material.set_shader_parameter("specular_level", 0.14)
		hood_material.set_shader_parameter("edge_strength", 0.12)
		hood.material_override = hood_material

	root.set_meta("wanderer_hood_r11", WANDERER_HOOD_R11_VERSION)
