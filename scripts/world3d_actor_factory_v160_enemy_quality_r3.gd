extends "res://scripts/world3d_actor_factory_v160_enemy_quality_r2.gd"

# ONE MORE FLOOR v1.60 — enemy quality r3.
# Keeps the accepted r8.1 Wanderer fix and r2 Goblin/Ghoul/Warden anatomy.
# Adds authored Bat/Necromancer body cores only. Gameplay authority stays
# inherited: roots, hitboxes, tells, timing, movement, input and saves unchanged.

const ENEMY_QUALITY_R3_VERSION := "1.60-enemy-quality-r3"

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	if root == null or imported_model_active(root):
		return
	_apply_enemy_quality_r3(root, kind)
	root.set_meta("enemy_quality_r3", ENEMY_QUALITY_R3_VERSION)

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	var data: Dictionary = super.character_quality_snapshot(root)
	data["enemy_quality_r3_version"] = ENEMY_QUALITY_R3_VERSION
	data["enemy_quality_r3_focus"] = ["bat", "necromancer"]
	data["enemy_quality_profile"] = "authored-anatomy-core-r3"
	return data

func _apply_enemy_quality_r3(root: Node3D, kind: String) -> void:
	var layer := root.get_node_or_null("Motion/Visual/EnemyPresentationV160") as Node3D
	if layer == null:
		return
	var authored := layer.get_node_or_null("AuthoredBodyV160") as MeshInstance3D
	if authored == null:
		return

	match kind:
		"bat":
			authored.scale = Vector3(0.90, 0.90, 0.92)
			authored.position = Vector3(0.0, -0.030, 0.0)
			authored.rotation = Vector3(0.02, 0.0, 0.0)
			_scale_visible_prefix(layer, "BatEyeV160", Vector3(0.62, 0.62, 0.66))
			_tune_enemy_surface("bat", Color("171321"), Color("5f4d72"), 0.96, 0.20, 0.00)

		"necromancer":
			authored.scale = Vector3(0.94, 0.98, 0.94)
			authored.position = Vector3.ZERO
			authored.rotation = Vector3.ZERO
			_scale_visible_prefix(layer, "NecroFaceV160", Vector3(0.72, 0.72, 0.72))
			_scale_visible_prefix(layer, "NecroEyeV160", Vector3(0.62, 0.62, 0.66))
			_scale_visible_prefix(layer, "NecroStaffV160", Vector3(0.88, 0.94, 0.88))
			_scale_visible_prefix(layer, "NecroStaffCoreV160", Vector3(0.66, 0.66, 0.66))
			_scale_visible_prefix(layer, "NecroCrownV160", Vector3(0.70, 0.72, 0.70))
			_scale_visible_prefix(layer, "NecroRobeRuneV160", Vector3(0.52, 0.52, 0.48))
			_tune_enemy_surface("necromancer", Color("181222"), Color("6a557f"), 0.94, 0.22, 0.00)

	root.set_meta("enemy_quality_r3", ENEMY_QUALITY_R3_VERSION)
