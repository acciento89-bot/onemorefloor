extends "res://scripts/world3d_actor_factory.gd"

# ONE MORE FLOOR v1.41 — production-oriented presentation layer for the native
# low-poly actors. This keeps the repo self-contained while adding secondary
# motion, combat readability and silhouette detail before external rigs arrive.

func create_player(materials: Dictionary) -> Node3D:
	var root := super.create_player(materials)
	var motion := root.get_node_or_null("Motion") as Node3D
	if motion == null:
		return root

	# Extra armor language that catches the key light from the isometric camera.
	_add_box(motion, "Belt", Vector3(0.54, 0.09, 0.34), Vector3(0.0, 0.72, -0.05), materials["leather"])
	_add_box(motion, "BeltClasp", Vector3(0.12, 0.11, 0.045), Vector3(0.0, 0.72, -0.235), materials["gold"])
	for side in [-1.0, 1.0]:
		_add_box(motion, "Bracer", Vector3(0.17, 0.21, 0.18), Vector3(side * 0.43, 0.67, -0.055), materials["steel_dark"])
		_add_box(motion, "ShoulderTrim", Vector3(0.31, 0.055, 0.22), Vector3(side * 0.39, 1.12, -0.05), materials["gold"])

	var cape_trim := _add_box(motion, "CapeTrim", Vector3(0.48, 0.055, 0.30), Vector3(0.0, 0.40, 0.29), materials["gold"])
	cape_trim.rotation.x = -0.10

	var weapon := root.get_node_or_null("WeaponPivot") as Node3D
	if weapon != null:
		_add_sphere(weapon, "PommelGlow", 0.075, Vector3(0.0, 0.0, 0.27), materials["glow_purple"], 8, 4)

	root.set_meta("production_actor", true)
	return root

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	var visual := root.get_node_or_null("Motion/Visual") as Node3D
	if visual == null:
		return

	# Every enemy gets real 3D combat tells instead of relying on UI-only cues.
	if visual.get_node_or_null("TellRing") == null:
		var tell_mesh := CylinderMesh.new()
		tell_mesh.top_radius = 0.52
		tell_mesh.bottom_radius = 0.52
		tell_mesh.height = 0.018
		tell_mesh.radial_segments = 28
		var tell := MeshInstance3D.new()
		tell.name = "TellRing"
		tell.mesh = tell_mesh
		tell.position = Vector3(0.0, 0.018, 0.0)
		tell.material_override = materials["glow_red"] if kind == "warden" else materials["glow_purple"]
		tell.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		tell.visible = false
		visual.add_child(tell)

	if visual.get_node_or_null("HitSpark") == null:
		var hit := _add_sphere(visual, "HitSpark", 0.15, Vector3(0.0, 0.84, -0.34), materials["glow_gold"], 8, 4)
		hit.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		hit.visible = false

	# Small rank crest gives the boss/warden a stronger top-down read.
	if kind == "warden" and visual.get_node_or_null("RankCrest") == null:
		var crest := _add_cylinder(visual, "RankCrest", 0.0, 0.16, 0.38, Vector3(0.0, 1.92, 0.02), materials["glow_red"], 6)
		crest.rotation.z = PI

	root.set_meta("production_actor", true)

func animate_player(root: Node3D, elapsed: float, move_amount: float, attack_amount: float, skill_amount: float) -> void:
	super.animate_player(root, elapsed, move_amount, attack_amount, skill_amount)
	var motion := root.get_node_or_null("Motion") as Node3D
	if motion != null:
		var locomotion := clampf(move_amount, 0.0, 1.0)
		motion.rotation.x = sin(elapsed * 4.1) * 0.008 + locomotion * 0.018
		var trim := motion.get_node_or_null("CapeTrim") as Node3D
		if trim != null:
			trim.position.y = 0.40 + sin(elapsed * 5.2) * 0.012 * (0.35 + locomotion)
	var weapon := root.get_node_or_null("WeaponPivot") as Node3D
	if weapon != null:
		# Adds a small forward bite to the existing slash instead of only rotating.
		weapon.position.z = -0.22 - attack_amount * 0.18
		weapon.position.y = 0.98 + attack_amount * 0.08

func animate_enemy(root: Node3D, elapsed: float, phase: float, tell: float, hit: float, index: int) -> void:
	super.animate_enemy(root, elapsed, phase, tell, hit, index)
	var visual := root.get_node_or_null("Motion/Visual") as Node3D
	if visual == null:
		return
	var tell_ring := visual.get_node_or_null("TellRing") as MeshInstance3D
	if tell_ring != null:
		tell_ring.visible = tell > 0.02
		if tell_ring.visible:
			var tell_scale := 0.72 + tell * 0.58
			tell_ring.scale = Vector3(tell_scale, 1.0, tell_scale)
			tell_ring.rotation.y = elapsed * 2.4 + float(index) * 0.2
	var spark := visual.get_node_or_null("HitSpark") as MeshInstance3D
	if spark != null:
		spark.visible = hit > 0.02
		if spark.visible:
			var spark_scale := 0.55 + hit * 1.10
			spark.scale = Vector3.ONE * spark_scale
			spark.rotation.y = elapsed * 8.0

func production_actor_ready(root: Node3D) -> bool:
	return root != null and bool(root.get_meta("production_actor", false))
