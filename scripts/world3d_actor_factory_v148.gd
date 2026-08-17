extends "res://scripts/world3d_actor_factory_v147.gd"

# ONE MORE FLOOR v1.48 — character combat animation presentation.
# Keeps the v1.47 production socket/import contract and adds stronger archetype
# motion language for both native fallbacks and future imported rigs. Gameplay
# timing and collision authority remain outside this presentation layer.

const V148_HIT_ONE_SHOT := 0.18

func animate_player(root: Node3D, elapsed: float, move_amount: float, attack_amount: float, skill_amount: float) -> void:
	super.animate_player(root, elapsed, move_amount, attack_amount, skill_amount)
	if root == null:
		return
	var motion := root.get_node_or_null("Motion") as Node3D
	if motion != null:
		var attack_drive: float = clampf(attack_amount, 0.0, 1.0)
		var skill_drive: float = clampf(skill_amount, 0.0, 1.0)
		motion.rotation.y = sin(elapsed * 6.2) * 0.018 * clampf(move_amount, 0.0, 1.0)
		motion.scale = Vector3.ONE * (1.0 + skill_drive * 0.035)
		if attack_drive > 0.02:
			motion.rotation.x += attack_drive * 0.035
	var weapon := actor_socket(root, "weapon")
	if weapon != null:
		weapon.set_meta("v148_attack_energy", clampf(attack_amount + skill_amount * 1.35, 0.0, 1.4))

func animate_enemy(root: Node3D, elapsed: float, phase: float, tell: float, hit: float, index: int) -> void:
	super.animate_enemy(root, elapsed, phase, tell, hit, index)
	if root == null:
		return

	var was_hit: bool = bool(root.get_meta("v148_hit_active", false))
	var hit_active: bool = hit > 0.05
	if hit_active and not was_hit:
		queue_one_shot(root, "hit", elapsed, V148_HIT_ONE_SHOT)
	root.set_meta("v148_hit_active", hit_active)

	var kind: String = String(root.get_meta("actor_kind", "enemy"))
	var motion := root.get_node_or_null("Motion") as Node3D
	if motion == null:
		return
	var pulse: float = sin(elapsed * 4.0 + phase + float(index) * 0.37)
	var tell_drive: float = clampf(tell, 0.0, 1.0)
	var hit_drive: float = clampf(hit, 0.0, 1.0)

	match kind:
		"goblin":
			motion.rotation.y += pulse * 0.035 + tell_drive * 0.08
			motion.position.y += absf(pulse) * 0.012
		"bat":
			motion.rotation.y += pulse * 0.12
			motion.rotation.x += tell_drive * 0.10
			motion.position.y += sin(elapsed * 7.6 + phase) * 0.035
		"skeleton":
			motion.rotation.y += sin(elapsed * 2.4 + phase) * 0.022
			motion.rotation.x -= tell_drive * 0.055
		"ghoul":
			motion.rotation.x += tell_drive * 0.13
			motion.position.z -= tell_drive * 0.06
		"necromancer":
			motion.position.y += sin(elapsed * 3.2 + phase) * 0.025
			motion.rotation.y += tell_drive * 0.12
		"warden":
			motion.scale *= Vector3.ONE * (1.0 + tell_drive * 0.025)
			motion.rotation.x -= tell_drive * 0.045
		_:
			motion.rotation.y += pulse * 0.018

	if hit_drive > 0.01:
		motion.rotation.z += sin(elapsed * 42.0 + float(index)) * 0.035 * hit_drive

	root.set_meta("v148_combat_archetype", kind)
	root.set_meta("v148_tell_strength", tell_drive)
	root.set_meta("v148_hit_strength", hit_drive)

func combat_animation_ready(root: Node3D) -> bool:
	return actor_production_ready(root) \
		and root.has_meta("actor_pipeline_v147")

func combat_archetype(root: Node3D) -> String:
	if root == null:
		return ""
	return String(root.get_meta("v148_combat_archetype", root.get_meta("actor_kind", "")))
