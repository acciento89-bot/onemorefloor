extends "res://scripts/world3d_actor_factory_v160_character_quality_r6.gd"

# ONE MORE FLOOR v1.60 — Wanderer silhouette lock candidate r7.
# Presentation-only finalization based on r6 runtime/close-up captures.
# Keeps imported v1.55 glTF animation authority, hierarchy, pivots, sockets,
# hitboxes, targeting, combat, saves and input unchanged.

const WANDERER_R7_VERSION := "1.60-wanderer-silhouette-r7"

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if root != null and imported_model_active(root):
		_apply_wanderer_r7(root)
	root.set_meta("wanderer_character_quality_r7", WANDERER_R7_VERSION)
	root.set_meta("character_quality_v160", character_quality_player_ready(root))
	return root

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	var data: Dictionary = super.character_quality_snapshot(root)
	data["wanderer_r7"] = root != null \
		and String(root.get_meta("wanderer_character_quality_r7", "")) == WANDERER_R7_VERSION
	data["wanderer_r7_version"] = WANDERER_R7_VERSION
	data["silhouette_profile"] = "authored-tailored-humanoid-r7-lock-candidate"
	data["material_profile"] = "cool-steel-dark-cloth-restrained-arcane-r7"
	return data

func _apply_wanderer_r7(root: Node3D) -> void:
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		return

	# r6 runtime close-ups still read slightly helmet-like. Narrow the hood shell,
	# expose more of the faceted mask and reduce the smooth cap silhouette.
	_tune_named_mesh(imported, "V160AuthoredHood", Vector3(0.63, 0.75, 0.67), Vector3(0.0, -0.046, -0.018))
	_tune_named_mesh(imported, "V160AuthoredMask", Vector3(0.65, 0.75, 0.62), Vector3(0.0, -0.038, -0.040))

	# Pull presentation meshes inward on their existing shoulder/arm pivots.
	# No pivot or animation hierarchy is changed.
	_tune_named_mesh(imported, "V160AuthoredPauldronL", Vector3(0.27, 0.37, 0.42), Vector3(0.018, -0.052, 0.022))
	_tune_named_mesh(imported, "V160AuthoredPauldronR", Vector3(0.34, 0.44, 0.48), Vector3(-0.018, -0.030, -0.004))
	_tune_named_mesh(imported, "V160AuthoredArmL", Vector3(0.49, 1.10, 0.58), Vector3(0.032, 0.0, -0.010))
	_tune_named_mesh(imported, "V160AuthoredArmR", Vector3(0.49, 1.10, 0.58), Vector3(-0.032, 0.0, -0.010))
	_tune_named_mesh(imported, "V160AuthoredGauntletL", Vector3(0.46, 0.68, 0.56), Vector3(0.028, -0.360, -0.020))
	_tune_named_mesh(imported, "V160AuthoredGauntletR", Vector3(0.46, 0.68, 0.56), Vector3(-0.028, -0.360, -0.020))

	# Keep the already improved r6 footwear compact and less saturated.
	for suffix in ["L", "R"]:
		_tune_named_mesh(imported, "V160AuthoredBoot%s" % suffix, Vector3(0.41, 0.52, 0.54), Vector3(0.0, -0.408, -0.056))

	# The animated carrier remains present, but now reads as a small magical core
	# instead of a large UI-like diamond glued onto the chest.
	var arcane_core := _find_named_mesh(imported, "ArcaneCore")
	if arcane_core != null:
		arcane_core.scale = Vector3(0.18, 0.18, 0.18)
	var chest_sigil := _find_named_mesh(imported, "V160ChestSigil")
	if chest_sigil != null:
		chest_sigil.scale = Vector3(0.12, 0.15, 0.06)
	var buckle := _find_named_mesh(imported, "V160Buckle")
	if buckle != null:
		buckle.scale = Vector3(0.46, 0.46, 0.46)
	var clasp := _find_named_mesh(imported, "V160CapeClasp")
	if clasp != null:
		clasp.scale = Vector3(0.44, 0.28, 0.30)

	# Restore material hierarchy under the warm tower light: dark cloth first,
	# cool steel second, leather/gold as restrained accents, arcane only tertiary.
	_tune_wanderer_shader("cloth", Color("1d2a3b"), Color("60748b"), 0.86, 0.20)
	_tune_wanderer_shader("cape", Color("211927"), Color("5d4965"), 0.90, 0.16)
	_tune_wanderer_shader("steel_dark", Color("354457"), Color("8ea3b8"), 0.54, 0.28)
	_tune_wanderer_shader("leather", Color("2c211c"), Color("624738"), 0.92, 0.14)
	_tune_wanderer_shader("gold", Color("5f482c"), Color("a98554"), 0.58, 0.20)
	_tune_wanderer_shader("blade", Color("64768c"), Color("c8d6e4"), 0.28, 0.40)

	var arcane := wanderer_materials.get("arcane") as ShaderMaterial
	if arcane != null:
		arcane.set_shader_parameter("base_color", Color("35224f"))
		arcane.set_shader_parameter("edge_color", Color("795a9a"))
		arcane.set_shader_parameter("emission_color", Color("604080"))
		arcane.set_shader_parameter("emission_strength", 0.12)

	root.set_meta("wanderer_character_quality_r7", WANDERER_R7_VERSION)
