extends "res://scripts/world3d_actor_factory_v160_character_quality_r7.gd"

# ONE MORE FLOOR v1.60 — Wanderer silhouette correction r8.1.
# Capture-driven presentation-only pass after r7/r8. The imported v1.55 glTF
# hierarchy, animation clips, pivots, sockets, hitboxes, combat, saves and input
# remain authoritative and unchanged. r8.1 constrains only the presentation
# amplitude of the animated ArcaneCore scale track.

const WANDERER_R8_VERSION := "1.60-wanderer-silhouette-r8.1"
const ARCANE_CORE_ANIMATION_SCALE := 0.27
const ARCANE_CORE_TRACK_MARKER := "v160_arcane_core_scale_r81"

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if root != null and imported_model_active(root):
		_apply_wanderer_r8(root)
	root.set_meta("wanderer_character_quality_r8", WANDERER_R8_VERSION)
	root.set_meta("character_quality_v160", character_quality_player_ready(root))
	return root

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	var data: Dictionary = super.character_quality_snapshot(root)
	data["wanderer_r8"] = root != null \
		and String(root.get_meta("wanderer_character_quality_r8", "")) == WANDERER_R8_VERSION
	data["wanderer_r8_version"] = WANDERER_R8_VERSION
	data["silhouette_profile"] = "authored-tailored-humanoid-r8.1-capture-corrected"
	data["material_profile"] = "dark-cloth-cool-steel-minimal-arcane-r8.1"
	data["arcane_core_animation_scale"] = ARCANE_CORE_ANIMATION_SCALE
	return data

func _apply_wanderer_r8(root: Node3D) -> void:
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		return

	# r7/r8 close-up evidence: the hood still reads as a smooth cap. Flatten it
	# and expose the authored faceted mask as the dominant face read.
	_tune_named_mesh(imported, "V160AuthoredHood", Vector3(0.61, 0.63, 0.65), Vector3(0.0, -0.066, -0.010))
	_tune_named_mesh(imported, "V160AuthoredMask", Vector3(0.70, 0.78, 0.64), Vector3(0.0, -0.045, -0.050))
	var hood := _find_named_mesh(imported, "V160AuthoredHood")
	if hood != null:
		hood.rotation.x = -0.035

	# Shorten the visible authored shells and bring them inward on the same
	# animated pivots. A small local angle breaks the two-vertical-bars read
	# without changing any shoulder/arm animation authority.
	_tune_named_mesh(imported, "V160AuthoredPauldronL", Vector3(0.25, 0.34, 0.39), Vector3(0.028, -0.050, 0.018))
	_tune_named_mesh(imported, "V160AuthoredPauldronR", Vector3(0.31, 0.40, 0.45), Vector3(-0.028, -0.028, -0.006))
	_tune_named_mesh(imported, "V160AuthoredArmL", Vector3(0.50, 0.82, 0.58), Vector3(0.060, 0.035, -0.008))
	_tune_named_mesh(imported, "V160AuthoredArmR", Vector3(0.50, 0.82, 0.58), Vector3(-0.060, 0.035, -0.008))
	_tune_named_mesh(imported, "V160AuthoredGauntletL", Vector3(0.47, 0.60, 0.54), Vector3(0.052, -0.292, -0.018))
	_tune_named_mesh(imported, "V160AuthoredGauntletR", Vector3(0.47, 0.60, 0.54), Vector3(-0.052, -0.292, -0.018))
	var arm_l := _find_named_mesh(imported, "V160AuthoredArmL")
	var arm_r := _find_named_mesh(imported, "V160AuthoredArmR")
	var gauntlet_l := _find_named_mesh(imported, "V160AuthoredGauntletL")
	var gauntlet_r := _find_named_mesh(imported, "V160AuthoredGauntletR")
	if arm_l != null:
		arm_l.rotation.z = 0.105
	if arm_r != null:
		arm_r.rotation.z = -0.105
	if gauntlet_l != null:
		gauntlet_l.rotation.z = 0.085
	if gauntlet_r != null:
		gauntlet_r.rotation.z = -0.085

	# The glTF Skill clip contains an explicit ArcaneCore scale animation. Godot's
	# imported RESET/animation state can therefore restore the original large
	# carrier scale after a factory-level node scale is applied. Constrain every
	# ArcaneCore TYPE_SCALE_3D track at runtime instead: the animation remains the
	# authority and still pulses, only at tertiary-accent amplitude.
	_limit_arcane_core_animation(imported)
	var arcane_core := _find_named_mesh(imported, "ArcaneCore")
	if arcane_core != null:
		arcane_core.scale = Vector3(0.0594, 0.0648, 0.0324)
	var chest_sigil := _find_named_mesh(imported, "V160ChestSigil")
	if chest_sigil != null:
		chest_sigil.scale = Vector3(0.070, 0.085, 0.035)
	var buckle := _find_named_mesh(imported, "V160Buckle")
	if buckle != null:
		buckle.scale = Vector3(0.40, 0.40, 0.40)
	var clasp := _find_named_mesh(imported, "V160CapeClasp")
	if clasp != null:
		clasp.scale = Vector3(0.38, 0.24, 0.27)

	# Reduce warm highlight contamination so cloth/steel separation survives the
	# tower lighting rather than turning the entire figure brown-gold.
	_tune_wanderer_shader("cloth", Color("182536"), Color("52677e"), 0.90, 0.16)
	_tune_wanderer_shader("cape", Color("1d1722"), Color("514158"), 0.93, 0.13)
	_tune_wanderer_shader("steel_dark", Color("304055"), Color("849ab0"), 0.59, 0.24)
	_tune_wanderer_shader("leather", Color("271d19"), Color("564034"), 0.94, 0.12)
	_tune_wanderer_shader("gold", Color("57452f"), Color("927650"), 0.64, 0.16)
	_tune_wanderer_shader("blade", Color("5d7188"), Color("b8c9da"), 0.32, 0.34)

	var arcane := wanderer_materials.get("arcane") as ShaderMaterial
	if arcane != null:
		arcane.set_shader_parameter("base_color", Color("291b3b"))
		arcane.set_shader_parameter("edge_color", Color("674d7d"))
		arcane.set_shader_parameter("emission_color", Color("4f3763"))
		arcane.set_shader_parameter("emission_strength", 0.060)

	root.set_meta("wanderer_character_quality_r8", WANDERER_R8_VERSION)

func _limit_arcane_core_animation(imported: Node3D) -> void:
	var player := _v154_find_animation_player(imported)
	if player == null:
		return
	for animation_name_value in player.get_animation_list():
		var animation := player.get_animation(StringName(animation_name_value))
		if animation == null or bool(animation.get_meta(ARCANE_CORE_TRACK_MARKER, false)):
			continue
		var changed := false
		for track_index in range(animation.get_track_count()):
			if animation.track_get_type(track_index) != Animation.TYPE_SCALE_3D:
				continue
			var track_path := String(animation.track_get_path(track_index))
			if not track_path.contains("ArcaneCore"):
				continue
			for key_index in range(animation.track_get_key_count(track_index)):
				var key_value: Variant = animation.track_get_key_value(track_index, key_index)
				if key_value is Vector3:
					animation.track_set_key_value(track_index, key_index, (key_value as Vector3) * ARCANE_CORE_ANIMATION_SCALE)
					changed = true
		if changed:
			animation.set_meta(ARCANE_CORE_TRACK_MARKER, true)
