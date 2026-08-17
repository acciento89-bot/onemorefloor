extends Node3D

# ONE MORE FLOOR v1.51 — pooled 3D projectile authority.
# Existing runtime dictionaries still carry damage/crit/lifetime data, but shot
# travel and hit selection are resolved as world-space 3D sphere sweeps. Pooled
# Area3D nodes make every active projectile a real 3D collision object without
# spawning nodes during combat.

const DESIGN_ARENA := Rect2(36.0, 160.0, 648.0, 840.0)
const WORLD_HALF_WIDTH := 4.65
const WORLD_HALF_DEPTH := 6.05
const MAX_PLAYER_SHOTS := 28
const MAX_ENEMY_SHOTS := 36
const PROJECTILE_HEIGHT := 0.72
const PLAYER_SHOT_RADIUS_DESIGN := 10.0
const ENEMY_SHOT_RADIUS_DESIGN := 9.0
const PLAYER_HIT_RADIUS_DESIGN := 28.0
const OUTSIDE_MARGIN_WORLD := 1.25

const LAYER_PLAYER_PROJECTILE := 8
const LAYER_ENEMY_PROJECTILE := 16

var player_projectile_areas: Array = []
var enemy_projectile_areas: Array = []
var resolve_frames := 0
var player_hits_total := 0
var enemy_hits_total := 0
var expired_total := 0
var overflow_total := 0
var last_player_result: Dictionary = {}
var last_enemy_result: Dictionary = {}

func _ready() -> void:
	_build_projectile_pool(player_projectile_areas, MAX_PLAYER_SHOTS, "PlayerProjectileAuthority", LAYER_PLAYER_PROJECTILE, PLAYER_SHOT_RADIUS_DESIGN)
	_build_projectile_pool(enemy_projectile_areas, MAX_ENEMY_SHOTS, "EnemyProjectileAuthority", LAYER_ENEMY_PROJECTILE, ENEMY_SHOT_RADIUS_DESIGN)

func projectile_authority_ready() -> bool:
	return player_projectile_areas.size() == MAX_PLAYER_SHOTS \
		and enemy_projectile_areas.size() == MAX_ENEMY_SHOTS \
		and _pool_has_collision_shape(player_projectile_areas) \
		and _pool_has_collision_shape(enemy_projectile_areas)

func design_to_world(pos: Vector2) -> Vector3:
	var nx: float = (pos.x - DESIGN_ARENA.get_center().x) / (DESIGN_ARENA.size.x * 0.5)
	var nz: float = (pos.y - DESIGN_ARENA.get_center().y) / (DESIGN_ARENA.size.y * 0.5)
	return Vector3(nx * WORLD_HALF_WIDTH, PROJECTILE_HEIGHT, nz * WORLD_HALF_DEPTH)

func world_to_design(pos: Vector3) -> Vector2:
	var nx: float = pos.x / WORLD_HALF_WIDTH
	var nz: float = pos.z / WORLD_HALF_DEPTH
	return DESIGN_ARENA.get_center() + Vector2(nx * DESIGN_ARENA.size.x * 0.5, nz * DESIGN_ARENA.size.y * 0.5)

func design_velocity_to_world(velocity: Vector2) -> Vector3:
	return Vector3(
		velocity.x / (DESIGN_ARENA.size.x * 0.5) * WORLD_HALF_WIDTH,
		0.0,
		velocity.y / (DESIGN_ARENA.size.y * 0.5) * WORLD_HALF_DEPTH
	)

func design_radius_to_world(radius_design: float) -> float:
	return maxf(0.05, radius_design / (DESIGN_ARENA.size.x * 0.5) * WORLD_HALF_WIDTH)

func resolve_player_projectiles(delta: float, shots: Array, enemies: Array) -> Dictionary:
	if not projectile_authority_ready():
		return {"ready": false, "shots": shots.duplicate(true), "hits": [], "mode": "3d_sphere_sweep"}
	resolve_frames += 1
	var safe_delta: float = maxf(delta, 1.0 / 240.0)
	var survivors: Array = []
	var hits: Array = []
	var expired := 0
	var active_slots := 0

	for index in range(shots.size()):
		var shot_value: Variant = shots[index]
		if not (shot_value is Dictionary):
			continue
		var shot: Dictionary = (shot_value as Dictionary).duplicate(true)
		var start_design: Vector2 = shot.get("pos", DESIGN_ARENA.get_center())
		var velocity_design: Vector2 = shot.get("vel", Vector2.ZERO)
		var start_world: Vector3 = design_to_world(start_design)
		var end_world: Vector3 = start_world + design_velocity_to_world(velocity_design) * safe_delta
		var life: float = float(shot.get("life", 0.0)) - safe_delta
		var area: Area3D = _area_for_index(player_projectile_areas, index)
		if area != null:
			_set_area_active(area, true, end_world)
			active_slots += 1
		else:
			overflow_total += 1

		var best_t := 2.0
		var best_enemy := -1
		var shot_radius_world: float = design_radius_to_world(PLAYER_SHOT_RADIUS_DESIGN)
		for enemy_index in range(enemies.size()):
			var enemy_value: Variant = enemies[enemy_index]
			if not (enemy_value is Dictionary):
				continue
			var enemy: Dictionary = enemy_value
			var enemy_pos: Vector2 = enemy.get("pos", DESIGN_ARENA.get_center())
			var enemy_center: Vector3 = design_to_world(enemy_pos)
			var enemy_radius: float = design_radius_to_world(maxf(12.0, float(enemy.get("radius", 24.0))))
			var hit_t: float = _segment_sphere_hit_t(start_world, end_world, enemy_center, shot_radius_world + enemy_radius)
			if hit_t >= 0.0 and hit_t < best_t:
				best_t = hit_t
				best_enemy = enemy_index

		if best_enemy >= 0:
			var hit_world: Vector3 = start_world.lerp(end_world, best_t)
			hits.append({
				"enemy_index": best_enemy,
				"damage": float(shot.get("damage", 0.0)),
				"crit": bool(shot.get("crit", false)),
				"hit_pos": world_to_design(hit_world),
				"world_pos": hit_world,
			})
			player_hits_total += 1
			if area != null:
				_set_area_active(area, false, hit_world)
			continue

		if life <= 0.0 or _outside_world(end_world):
			expired += 1
			expired_total += 1
			if area != null:
				_set_area_active(area, false, end_world)
			continue

		shot["pos"] = world_to_design(end_world)
		shot["life"] = life
		survivors.append(shot)

	_deactivate_unused(player_projectile_areas, shots.size())
	last_player_result = {
		"ready": true,
		"mode": "3d_sphere_sweep",
		"shots": survivors,
		"hits": hits,
		"active_slots": active_slots,
		"expired": expired,
	}
	return last_player_result

func resolve_enemy_projectiles(delta: float, shots: Array, player_design: Vector2) -> Dictionary:
	if not projectile_authority_ready():
		return {"ready": false, "shots": shots.duplicate(true), "hits": [], "mode": "3d_sphere_sweep"}
	resolve_frames += 1
	var safe_delta: float = maxf(delta, 1.0 / 240.0)
	var survivors: Array = []
	var hits: Array = []
	var expired := 0
	var active_slots := 0
	var player_center: Vector3 = design_to_world(player_design)
	var combined_radius: float = design_radius_to_world(PLAYER_HIT_RADIUS_DESIGN + ENEMY_SHOT_RADIUS_DESIGN)

	for index in range(shots.size()):
		var shot_value: Variant = shots[index]
		if not (shot_value is Dictionary):
			continue
		var shot: Dictionary = (shot_value as Dictionary).duplicate(true)
		var start_design: Vector2 = shot.get("pos", DESIGN_ARENA.get_center())
		var velocity_design: Vector2 = shot.get("vel", Vector2.ZERO)
		var start_world: Vector3 = design_to_world(start_design)
		var end_world: Vector3 = start_world + design_velocity_to_world(velocity_design) * safe_delta
		var life: float = float(shot.get("life", 0.0)) - safe_delta
		var area: Area3D = _area_for_index(enemy_projectile_areas, index)
		if area != null:
			_set_area_active(area, true, end_world)
			active_slots += 1
		else:
			overflow_total += 1

		var hit_t: float = _segment_sphere_hit_t(start_world, end_world, player_center, combined_radius)
		if hit_t >= 0.0:
			var hit_world: Vector3 = start_world.lerp(end_world, hit_t)
			hits.append({
				"damage": float(shot.get("damage", 0.0)),
				"hit_pos": world_to_design(hit_world),
				"world_pos": hit_world,
			})
			enemy_hits_total += 1
			if area != null:
				_set_area_active(area, false, hit_world)
			continue

		if life <= 0.0 or _outside_world(end_world):
			expired += 1
			expired_total += 1
			if area != null:
				_set_area_active(area, false, end_world)
			continue

		shot["pos"] = world_to_design(end_world)
		shot["life"] = life
		survivors.append(shot)

	_deactivate_unused(enemy_projectile_areas, shots.size())
	last_enemy_result = {
		"ready": true,
		"mode": "3d_sphere_sweep",
		"shots": survivors,
		"hits": hits,
		"active_slots": active_slots,
		"expired": expired,
	}
	return last_enemy_result

func debug_snapshot() -> Dictionary:
	return {
		"ready": projectile_authority_ready(),
		"mode": "3d_sphere_sweep",
		"player_area_pool": player_projectile_areas.size(),
		"enemy_area_pool": enemy_projectile_areas.size(),
		"area3d_total": player_projectile_areas.size() + enemy_projectile_areas.size(),
		"resolve_frames": resolve_frames,
		"player_hits": player_hits_total,
		"enemy_hits": enemy_hits_total,
		"expired": expired_total,
		"overflow": overflow_total,
		"last_player_hits": (last_player_result.get("hits", []) as Array).size() if last_player_result.has("hits") else 0,
		"last_enemy_hits": (last_enemy_result.get("hits", []) as Array).size() if last_enemy_result.has("hits") else 0,
	}

func reset_authority() -> void:
	for area_value in player_projectile_areas:
		var area: Area3D = area_value as Area3D
		if area != null:
			_set_area_active(area, false, Vector3.ZERO)
	for area_value in enemy_projectile_areas:
		var area: Area3D = area_value as Area3D
		if area != null:
			_set_area_active(area, false, Vector3.ZERO)
	last_player_result = {}
	last_enemy_result = {}

func _build_projectile_pool(pool: Array, count: int, prefix: String, layer: int, radius_design: float) -> void:
	var radius_world: float = design_radius_to_world(radius_design)
	for index in range(count):
		var area := Area3D.new()
		area.name = "%s%02d" % [prefix, index]
		area.collision_layer = 0
		area.collision_mask = 0
		area.monitoring = false
		area.monitorable = false
		area.set_meta("authority_active", false)
		add_child(area)
		var collision := CollisionShape3D.new()
		collision.name = "ProjectileSphere"
		var sphere := SphereShape3D.new()
		sphere.radius = radius_world
		collision.shape = sphere
		area.add_child(collision)
		area.set_meta("authority_layer", layer)
		pool.append(area)

func _pool_has_collision_shape(pool: Array) -> bool:
	if pool.is_empty():
		return false
	var area: Area3D = pool[0] as Area3D
	if area == null:
		return false
	var shape_node := area.get_node_or_null("ProjectileSphere") as CollisionShape3D
	return shape_node != null and shape_node.shape is SphereShape3D

func _area_for_index(pool: Array, index: int) -> Area3D:
	if index < 0 or index >= pool.size():
		return null
	return pool[index] as Area3D

func _set_area_active(area: Area3D, value: bool, position_value: Vector3) -> void:
	area.position = position_value
	area.set_meta("authority_active", value)
	area.collision_layer = int(area.get_meta("authority_layer", 0)) if value else 0

func _deactivate_unused(pool: Array, used_count: int) -> void:
	for index in range(maxi(0, used_count), pool.size()):
		var area: Area3D = pool[index] as Area3D
		if area != null and bool(area.get_meta("authority_active", false)):
			_set_area_active(area, false, area.position)

func _outside_world(position_value: Vector3) -> bool:
	return absf(position_value.x) > WORLD_HALF_WIDTH + OUTSIDE_MARGIN_WORLD \
		or absf(position_value.z) > WORLD_HALF_DEPTH + OUTSIDE_MARGIN_WORLD

func _segment_sphere_hit_t(start: Vector3, end: Vector3, center: Vector3, radius: float) -> float:
	var segment: Vector3 = end - start
	var offset: Vector3 = start - center
	var radius_sq: float = radius * radius
	if offset.length_squared() <= radius_sq:
		return 0.0
	var a: float = segment.dot(segment)
	if a <= 0.00000001:
		return -1.0
	var b: float = offset.dot(segment)
	var c: float = offset.dot(offset) - radius_sq
	var discriminant: float = b * b - a * c
	if discriminant < 0.0:
		return -1.0
	var t: float = (-b - sqrt(discriminant)) / a
	if t < 0.0 or t > 1.0:
		return -1.0
	return t
