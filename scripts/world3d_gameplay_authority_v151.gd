extends "res://scripts/world3d_gameplay_authority_v150.gd"

# ONE MORE FLOOR v1.51 — 3D combat-contact authority.
# Locomotion still resolves through v1.50 CharacterBody3D nodes. This layer adds
# explicit authoritative player/enemy contact indices and contact points so the
# runtime can retire the legacy 2D touch-distance trigger without moving damage
# math, HP, armor or haptics out of the tested gameplay stack yet.

const CONTACT_RADIUS_SCALE := 1.12
const CONTACT_POINT_LIMIT := 10

func combat_contact_ready() -> bool:
	return authority_ready() and player_body != null and enemy_bodies.size() == MAX_ENEMIES

func resolve_frame(delta: float, player_design: Vector2, enemies: Array) -> Dictionary:
	var report: Dictionary = super.resolve_frame(delta, player_design, enemies)
	if not bool(report.get("ready", false)) or not combat_contact_ready():
		return report

	var contact_indices: Array = []
	var contact_points: Array = []
	var player_radius_world: float = design_radius_to_world(PLAYER_RADIUS_DESIGN)
	var active_count: int = mini(enemies.size(), MAX_ENEMIES)

	for index in range(active_count):
		var enemy_body: CharacterBody3D = enemy_bodies[index] as CharacterBody3D
		if enemy_body == null:
			continue
		var enemy_radius: float = float(enemy_body.get_meta("authority_radius", design_radius_to_world(24.0)))
		var planar_delta := Vector2(
			enemy_body.position.x - player_body.position.x,
			enemy_body.position.z - player_body.position.z
		)
		var threshold: float = (player_radius_world + enemy_radius) * CONTACT_RADIUS_SCALE
		if planar_delta.length() > threshold:
			continue
		contact_indices.append(index)
		contact_points.append((enemy_body.position + player_body.position) * 0.5)

	var merged_collision_points: Array = report.get("collision_points", []).duplicate()
	for point_value in contact_points:
		merged_collision_points.append(point_value)

	report["mode"] = "hybrid_3d_combat_authority"
	report["contact_pairs"] = contact_indices.size()
	report["contact_indices"] = contact_indices
	report["contact_points"] = _dedupe_points(contact_points, CONTACT_POINT_LIMIT)
	report["collision_points"] = _dedupe_points(merged_collision_points, CONTACT_POINT_LIMIT)
	report["touch_trigger_authority"] = "3d_contact"
	last_report = report
	return report

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["combat_contact_ready"] = combat_contact_ready()
	data["touch_trigger_authority"] = "3d_contact"
	data["contact_indices"] = last_report.get("contact_indices", []).duplicate()
	data["contact_points"] = last_report.get("contact_points", []).duplicate()
	return data
