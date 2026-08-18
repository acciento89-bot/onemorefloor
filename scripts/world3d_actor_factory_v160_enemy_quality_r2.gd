extends "res://scripts/world3d_actor_factory_v160_character_quality_r8.gd"

# ONE MORE FLOOR v1.60 — enemy quality pass r2.
# Replaces the rejected r1 overlay approach with authored anatomy in the OBJ
# body cores themselves. Existing weapons, eyes and runes stay as readable
# archetype accents. Combat roots, hitboxes, tells, timing, movement and saves
# remain inherited and unchanged.

const ENEMY_QUALITY_R2_VERSION := "1.60-enemy-quality-r2"

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	if root == null or imported_model_active(root):
		return
	_apply_enemy_quality_r2(root, kind)
	root.set_meta("enemy_quality_r2", ENEMY_QUALITY_R2_VERSION)

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	var data: Dictionary = super.character_quality_snapshot(root)
	data["enemy_quality_r2_version"] = ENEMY_QUALITY_R2_VERSION
	data["enemy_quality_r2_focus"] = ["goblin", "ghoul", "warden"]
	data["enemy_quality_profile"] = "authored-anatomy-core-r2"
	return data

func _apply_enemy_quality_r2(root: Node3D, kind: String) -> void:
	var layer := root.get_node_or_null("Motion/Visual/EnemyPresentationV160") as Node3D
	if layer == null:
		return
	var authored := layer.get_node_or_null("AuthoredBodyV160") as MeshInstance3D
	if authored == null:
		return

	match kind:
		"goblin":
			# r2 OBJ owns the smaller head, jaw/snout, ear silhouette, bent arms,
			# hands, articulated-looking legs and feet. Keep only proven accents.
			authored.scale = Vector3(0.96, 1.00, 0.96)
			authored.position = Vector3(0.0, 0.0, 0.0)
			authored.rotation = Vector3.ZERO
			_scale_visible_prefix(layer, "GoblinShoulderScrapV160", Vector3(0.68, 0.68, 0.70))
			_scale_visible_prefix(layer, "GoblinDaggerV160", Vector3(0.78, 0.92, 0.72))
			_scale_visible_prefix(layer, "GoblinEyeV160", Vector3(0.68, 0.68, 0.72))
			_tune_enemy_surface("goblin", Color("344833"), Color("71886a"), 0.94, 0.20, 0.02)

		"ghoul":
			# r2 OBJ includes the hunched back, tucked head/jaw, bent long arms,
			# low hands and crouched legs. Do not restore the old block jaw/spines.
			authored.scale = Vector3(0.94, 1.00, 0.95)
			authored.position = Vector3(0.0, 0.0, 0.0)
			authored.rotation = Vector3.ZERO
			_scale_visible_prefix(layer, "GhoulClawV160", Vector3(0.72, 0.82, 0.68))
			_scale_visible_prefix(layer, "GhoulEyeV160", Vector3(0.64, 0.64, 0.68))
			_tune_enemy_surface("ghoul", Color("293a33"), Color("5c7264"), 0.97, 0.18, 0.01)

		"warden":
			# r2 OBJ is a taller humanoid armored core with long legs, compact
			# helmet and built-in chest/shoulder planes. Keep shield/blade/horns
			# as accents; do not stack the rejected procedural chest/helm overlay.
			authored.scale = Vector3(0.92, 1.00, 0.92)
			authored.position = Vector3(0.0, 0.0, 0.0)
			authored.rotation = Vector3.ZERO
			_scale_visible_prefix(layer, "WardenShieldV160", Vector3(0.82, 0.88, 0.82))
			_scale_visible_prefix(layer, "WardenBladeV160", Vector3(0.76, 0.90, 0.74))
			_scale_visible_prefix(layer, "WardenChestRuneV160", Vector3(0.46, 0.46, 0.44))
			_scale_visible_prefix(layer, "WardenEyeV160", Vector3(0.64, 0.64, 0.68))
			_scale_visible_prefix(layer, "WardenHornV160", Vector3(0.70, 0.76, 0.70))
			_tune_enemy_surface("warden", Color("26313f"), Color("748aa1"), 0.56, 0.28, 0.62)

	root.set_meta("enemy_quality_r2", ENEMY_QUALITY_R2_VERSION)

func _scale_visible_prefix(layer: Node3D, prefix: String, scale_value: Vector3) -> void:
	for child_value in layer.get_children():
		var mesh := child_value as MeshInstance3D
		if mesh == null or not mesh.visible or not String(mesh.name).begins_with(prefix):
			continue
		mesh.scale = scale_value

func _tune_enemy_surface(kind: String, base_color: Color, edge_color: Color, roughness_value: float, edge_strength_value: float, metallic_value: float) -> void:
	var material := character_enemy_materials.get(kind) as ShaderMaterial
	if material == null:
		return
	material.set_shader_parameter("base_color", base_color)
	material.set_shader_parameter("edge_color", edge_color)
	material.set_shader_parameter("roughness", roughness_value)
	material.set_shader_parameter("edge_strength", edge_strength_value)
	material.set_shader_parameter("metallic", metallic_value)
