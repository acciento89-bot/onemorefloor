extends "res://scripts/world3d_actor_factory_v160_character_quality.gd"

# ONE MORE FLOOR v1.60 — Wanderer proportion/material refinement r4.
# This layer is intentionally presentation-only. It runs after the established
# character-quality takeover and preserves glTF animation authority, pivots,
# hitboxes, sockets, targeting, combat logic, saves and input flow.

const WANDERER_R4_VERSION := "1.60-wanderer-proportions-r4"

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if root != null and imported_model_active(root):
		_apply_wanderer_r4(root)
	root.set_meta("wanderer_character_quality_r4", WANDERER_R4_VERSION)
	root.set_meta("character_quality_v160", character_quality_player_ready(root))
	return root

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	var data: Dictionary = super.character_quality_snapshot(root)
	data["wanderer_r4"] = root != null \
		and String(root.get_meta("wanderer_character_quality_r4", "")) == WANDERER_R4_VERSION
	data["wanderer_r4_version"] = WANDERER_R4_VERSION
	data["silhouette_profile"] = "authored-tailored-humanoid-r4"
	data["material_profile"] = "surface-depth-character-r4"
	return data

func _apply_wanderer_r4(root: Node3D) -> void:
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		return

	# Reduce the remaining chibi / armor-mannequin read without touching any
	# articulated pivot. The head gets smaller, limbs become slimmer and longer,
	# and the shoulder mass is pulled back toward a human silhouette.
	_tune_named_mesh(imported, "V160AuthoredTorso", Vector3(0.74, 1.10, 0.72), Vector3(0.0, 0.110, 0.018))
	_tune_named_mesh(imported, "V160AuthoredChestplate", Vector3(0.64, 0.78, 0.62), Vector3(0.0, -0.060, -0.020))
	_tune_named_mesh(imported, "V160AuthoredCape", Vector3(0.72, 1.15, 0.82), Vector3(0.0, 0.018, 0.300))
	_tune_named_mesh(imported, "V160AuthoredHood", Vector3(0.69, 0.78, 0.73), Vector3(0.0, -0.032, -0.030))
	_tune_named_mesh(imported, "V160AuthoredMask", Vector3(0.67, 0.74, 0.62), Vector3(0.0, -0.045, -0.028))
	_tune_named_mesh(imported, "V160AuthoredPauldronL", Vector3(0.30, 0.40, 0.45), Vector3(-0.010, -0.050, 0.030))
	_tune_named_mesh(imported, "V160AuthoredPauldronR", Vector3(0.38, 0.48, 0.52), Vector3(0.018, -0.025, -0.010))

	for suffix in ["L", "R"]:
		_tune_named_mesh(imported, "V160AuthoredArm%s" % suffix, Vector3(0.54, 1.08, 0.62))
		_tune_named_mesh(imported, "V160AuthoredGauntlet%s" % suffix, Vector3(0.52, 0.70, 0.60), Vector3(0.0, -0.355, -0.018))
		_tune_named_mesh(imported, "V160AuthoredLeg%s" % suffix, Vector3(0.58, 1.18, 0.66))
		_tune_named_mesh(imported, "V160AuthoredBoot%s" % suffix, Vector3(0.52, 0.69, 0.68), Vector3(0.0, -0.392, -0.065))

	var eye_l := _find_named_mesh(imported, "V160EyeSlitL")
	var eye_r := _find_named_mesh(imported, "V160EyeSlitR")
	if eye_l != null:
		eye_l.scale = Vector3(0.56, 0.56, 0.64)
		eye_l.position = Vector3(-0.052, -0.012, -0.238)
	if eye_r != null:
		eye_r.scale = Vector3(0.56, 0.56, 0.64)
		eye_r.position = Vector3(0.052, -0.012, -0.238)

	var belt := _find_named_mesh(imported, "V160Belt")
	if belt != null:
		belt.scale = Vector3(0.68, 0.36, 0.58)
	var chest_sigil := _find_named_mesh(imported, "V160ChestSigil")
	if chest_sigil != null:
		chest_sigil.scale = Vector3(0.26, 0.34, 0.14)
	var arcane_core := _find_named_mesh(imported, "ArcaneCore")
	if arcane_core != null:
		arcane_core.scale = Vector3(0.62, 0.62, 0.62)
	var clasp := _find_named_mesh(imported, "V160CapeClasp")
	if clasp != null:
		clasp.scale = Vector3(0.62, 0.40, 0.42)

	# More separation between cloth, steel and cape under the warm tower lights.
	_tune_wanderer_shader("cloth", Color("2b3a4e"), Color("8297b1"), 0.78, 0.32)
	_tune_wanderer_shader("cape", Color("261a32"), Color("775a83"), 0.86, 0.24)
	_tune_wanderer_shader("steel_dark", Color("46566b"), Color("b7cadc"), 0.44, 0.40)
	_tune_wanderer_shader("leather", Color("3a2920"), Color("83604b"), 0.88, 0.20)
	_tune_wanderer_shader("gold", Color("71522f"), Color("d0ab6e"), 0.50, 0.32)
	_tune_wanderer_shader("blade", Color("708198"), Color("dce8f2"), 0.24, 0.48)

	var arcane := wanderer_materials.get("arcane") as ShaderMaterial
	if arcane != null:
		arcane.set_shader_parameter("base_color", Color("432965"))
		arcane.set_shader_parameter("edge_color", Color("9c76c4"))
		arcane.set_shader_parameter("emission_color", Color("7547a5"))
		arcane.set_shader_parameter("emission_strength", 0.20)

	root.set_meta("wanderer_character_quality_r4", WANDERER_R4_VERSION)
