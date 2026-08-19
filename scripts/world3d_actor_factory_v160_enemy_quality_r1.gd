extends "res://scripts/world3d_actor_factory_v160_character_quality_r8.gd"

# ONE MORE FLOOR v1.60 — enemy quality pass r1.
# Capture-driven presentation refinement for Goblin, Ghoul and Warden.
# Authored OBJ body cores remain authoritative; combat roots, hitboxes, tells,
# timing, targeting and movement remain inherited and unchanged.

const ENEMY_QUALITY_R1_VERSION := "1.60-enemy-quality-r1"

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	if root == null or imported_model_active(root):
		return
	_apply_enemy_quality_r1(root, kind)
	root.set_meta("enemy_quality_r1", ENEMY_QUALITY_R1_VERSION)

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	var data: Dictionary = super.character_quality_snapshot(root)
	data["enemy_quality_r1_version"] = ENEMY_QUALITY_R1_VERSION
	data["enemy_quality_r1_focus"] = ["goblin", "ghoul", "warden"]
	data["enemy_quality_profile"] = "authored-core-layered-archetype-r1"
	return data

func _apply_enemy_quality_r1(root: Node3D, kind: String) -> void:
	var layer := root.get_node_or_null("Motion/Visual/EnemyPresentationV160") as Node3D
	if layer == null:
		return
	var authored := layer.get_node_or_null("AuthoredBodyV160") as MeshInstance3D
	if authored == null:
		return

	match kind:
		"goblin":
			# Pull the authored body out of the round/chibi read while preserving
			# the existing scrap shoulder, dagger and eye accents.
			authored.scale = Vector3(0.80, 0.99, 0.84)
			authored.position = Vector3(0.0, 0.012, 0.0)
			authored.rotation.z = -0.040
			_scale_visible_prefix(layer, "GoblinShoulderScrapV160", Vector3(0.78, 0.74, 0.78))
			_scale_visible_prefix(layer, "GoblinDaggerV160", Vector3(0.82, 1.04, 0.76))
			_scale_visible_prefix(layer, "GoblinEyeV160", Vector3(0.78, 0.78, 0.82))
			_tune_enemy_surface("goblin", Color("374a34"), Color("7d9470"), 0.92, 0.22)

		"ghoul":
			# The current authored core is mechanically sound but visually reads
			# as disconnected capsules. A narrower/deeper hunch plus restored back
			# spikes and jaw creates one predatory silhouette at gameplay scale.
			authored.scale = Vector3(0.84, 1.02, 0.86)
			authored.position = Vector3(0.0, -0.010, 0.015)
			authored.rotation.x = 0.085
			_show_prefix(layer, "GhoulSpineV160", Vector3(0.72, 0.82, 0.72))
			_show_prefix(layer, "GhoulJawV160", Vector3(0.82, 0.76, 0.80))
			_scale_visible_prefix(layer, "GhoulClawV160", Vector3(0.82, 0.94, 0.78))
			_scale_visible_prefix(layer, "GhoulEyeV160", Vector3(0.72, 0.72, 0.76))
			_tune_enemy_surface("ghoul", Color("2d3e35"), Color("657b6b"), 0.96, 0.20)

		"warden":
			# Treat the authored OBJ as the dark under-armor body and restore the
			# proven metal chest/helm/pauldron pieces as an outer armor layer.
			# This keeps the readable shield/blade/horns while removing toy bulk.
			authored.scale = Vector3(0.74, 0.96, 0.82)
			authored.position = Vector3(0.0, 0.020, 0.0)
			_show_prefix(layer, "WardenChestV160", Vector3(0.84, 0.92, 0.82))
			_show_prefix(layer, "WardenHelmV160", Vector3(0.82, 0.88, 0.84))
			_show_prefix(layer, "WardenPauldronV160", Vector3(0.72, 0.72, 0.74))
			_scale_visible_prefix(layer, "WardenShieldV160", Vector3(0.88, 0.92, 0.86))
			_scale_visible_prefix(layer, "WardenBladeV160", Vector3(0.82, 0.94, 0.78))
			_scale_visible_prefix(layer, "WardenChestRuneV160", Vector3(0.62, 0.62, 0.58))
			_scale_visible_prefix(layer, "WardenEyeV160", Vector3(0.72, 0.72, 0.76))
			_scale_visible_prefix(layer, "WardenHornV160", Vector3(0.78, 0.84, 0.78))
			_tune_enemy_surface("warden", Color("242a33"), Color("71849a"), 0.66, 0.26)

	root.set_meta("enemy_quality_r1", ENEMY_QUALITY_R1_VERSION)

func _show_prefix(layer: Node3D, prefix: String, scale_value: Vector3) -> void:
	for child_value in layer.get_children():
		var mesh := child_value as MeshInstance3D
		if mesh == null or not String(mesh.name).begins_with(prefix):
			continue
		mesh.visible = true
		mesh.scale = scale_value

func _scale_visible_prefix(layer: Node3D, prefix: String, scale_value: Vector3) -> void:
	for child_value in layer.get_children():
		var mesh := child_value as MeshInstance3D
		if mesh == null or not mesh.visible or not String(mesh.name).begins_with(prefix):
			continue
		mesh.scale = scale_value

func _tune_enemy_surface(kind: String, base_color: Color, edge_color: Color, roughness_value: float, edge_strength_value: float) -> void:
	var material := character_enemy_materials.get(kind) as ShaderMaterial
	if material == null:
		return
	material.set_shader_parameter("base_color", base_color)
	material.set_shader_parameter("edge_color", edge_color)
	material.set_shader_parameter("roughness", roughness_value)
	material.set_shader_parameter("edge_strength", edge_strength_value)
