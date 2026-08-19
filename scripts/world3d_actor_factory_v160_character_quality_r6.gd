extends "res://scripts/world3d_actor_factory_v160_character_quality_r4.gd"

# ONE MORE FLOOR v1.60 — focused silhouette cleanup r6.
# Presentation-only refinement after the fully validated r4/r5 geometry line.
# Keeps the imported v1.55 glTF hierarchy, animation clips, pivots, sockets,
# hitboxes, targeting, combat authority, saves and input flow unchanged.

const WANDERER_R6_VERSION := "1.60-wanderer-silhouette-r6"

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if root != null and imported_model_active(root):
		_apply_wanderer_r6(root)
	root.set_meta("wanderer_character_quality_r6", WANDERER_R6_VERSION)
	root.set_meta("character_quality_v160", character_quality_player_ready(root))
	return root

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	var data: Dictionary = super.character_quality_snapshot(root)
	data["wanderer_r6"] = root != null \
		and String(root.get_meta("wanderer_character_quality_r6", "")) == WANDERER_R6_VERSION
	data["wanderer_r6_version"] = WANDERER_R6_VERSION
	data["silhouette_profile"] = "authored-tailored-humanoid-r6"
	return data

func _apply_wanderer_r6(root: Node3D) -> void:
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		return

	# New r6 hood geometry has a flatter crown and broader cowl; keep the head
	# compact so the gameplay silhouette does not drift back toward chibi scale.
	_tune_named_mesh(imported, "V160AuthoredHood", Vector3(0.68, 0.79, 0.72), Vector3(0.0, -0.034, -0.030))

	# r6 boot geometry is intentionally lower and more layered. Pull the overall
	# boot mass down further so it reads as footwear rather than oversized feet.
	for suffix in ["L", "R"]:
		_tune_named_mesh(imported, "V160AuthoredBoot%s" % suffix, Vector3(0.44, 0.54, 0.58), Vector3(0.0, -0.405, -0.060))

	# The large purple chest diamond visible in r5 is the preserved animated
	# ArcaneCore from the glTF carrier, not merely the small authored chest sigil.
	# Keep it visible/animated for the production contract but make it an accent.
	var arcane_core := _find_named_mesh(imported, "ArcaneCore")
	if arcane_core != null:
		arcane_core.scale = Vector3(0.30, 0.30, 0.30)
	var chest_sigil := _find_named_mesh(imported, "V160ChestSigil")
	if chest_sigil != null:
		chest_sigil.scale = Vector3(0.16, 0.20, 0.08)
	var buckle := _find_named_mesh(imported, "V160Buckle")
	if buckle != null:
		buckle.scale = Vector3(0.55, 0.55, 0.55)
	var clasp := _find_named_mesh(imported, "V160CapeClasp")
	if clasp != null:
		clasp.scale = Vector3(0.50, 0.32, 0.36)

	root.set_meta("wanderer_character_quality_r6", WANDERER_R6_VERSION)
