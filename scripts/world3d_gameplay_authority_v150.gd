extends Node3D

# ONE MORE FLOOR v1.50 — hybrid 3D gameplay authority.
# Legacy runtime still owns combat rules, AI intent, damage and rewards. This
# bridge becomes the final locomotion/collision resolver for floors 1-50 by
# carrying the player and up to 18 enemies through real CharacterBody3D nodes.

const DESIGN_ARENA := Rect2(36.0, 160.0, 648.0, 840.0)
const WORLD_HALF_WIDTH := 4.65
const WORLD_HALF_DEPTH := 6.05
const MAX_ENEMIES := 18
const PLAYER_RADIUS_DESIGN := 26.0
const WALL_THICKNESS := 0.52
const BODY_HEIGHT := 1.6
const TELEPORT_DISTANCE := 3.8
const ENEMY_SEPARATION_STRENGTH := 0.58
const MAX_PAIR_PASSES := 2

const LAYER_PLAYER := 1
const LAYER_ENEMY := 2
const LAYER_WORLD := 4

var player_body: CharacterBody3D
var player_shape: CollisionShape3D
var enemy_bodies: Array = []
var enemy_shapes: Array = []
var wall_bodies: Array = []
var frame_index := 0
var last_report: Dictionary = {}
var player_initialized := false
var enemy_initialized: Array = []

func _ready() -> void:
	_build_static_bounds()
	_build_player_body()
	_build_enemy_bodies()
	last_report = _empty_report()

func authority_ready() -> bool:
	return player_body != null \
		and player_shape != null \
		and enemy_bodies.size() == MAX_ENEMIES \
		and enemy_shapes.size() == MAX_ENEMIES \
		and wall_bodies.size() == 4

func design_to_world(pos: Vector2) -> Vector3:
	var nx: float = (pos.x - DESIGN_ARENA.get_center().x) / (DESIGN_ARENA.size.x * 0.5)
	var nz: float = (pos.y - DESIGN_ARENA.get_center().y) / (DESIGN_ARENA.size.y * 0.5)
	return Vector3(nx * WORLD_HALF_WIDTH, 0.0, nz * WORLD_HALF_DEPTH)

func world_to_design(pos: Vector3) -> Vector2:
	var nx: float = pos.x / WORLD_HALF_WIDTH
	var nz: float = pos.z / WORLD_HALF_DEPTH
	return DESIGN_ARENA.get_center() + Vector2(nx * DESIGN_ARENA.size.x * 0.5, nz * DESIGN_ARENA.size.y * 0.5)

func design_radius_to_world(radius_design: float) -> float:
	return maxf(0.12, radius_design / (DESIGN_ARENA.size.x * 0.5) * WORLD_HALF_WIDTH)

func resolve_frame(delta: float, player_design: Vector2, enemies: Array) -> Dictionary:
	if not authority_ready():
		last_report = _empty_report()
		return last_report

	frame_index += 1
	var safe_delta: float = maxf(delta, 1.0 / 240.0)
	var collision_points: Array = []
	var wall_hits := 0
	var separation_hits := 0
	var contact_pairs := 0
	var corrected_bodies := 0
	var max_correction_design := 0.0

	var player_radius_world: float = design_radius_to_world(PLAYER_RADIUS_DESIGN)
	_set_capsule_radius(player_shape, player_radius_world)
	var player_target: Vector3 = design_to_world(player_design)
	var player_before: Vector3 = player_body.position
	var player_result: Dictionary = _move_body_to_target(
		player_body, player_target, player_radius_world, safe_delta, player_initialized
	)
	player_initialized = true
	wall_hits += int(player_result.get("wall_hits", 0))
	if bool(player_result.get("corrected", false)):
		corrected_bodies += 1
		collision_points.append(player_body.position)
	var player_correction: float = world_to_design(player_body.position).distance_to(player_design)
	max_correction_design = maxf(max_correction_design, player_correction)

	var active_count: int = mini(enemies.size(), MAX_ENEMIES)
	for index in range(MAX_ENEMIES):
		var body: CharacterBody3D = enemy_bodies[index] as CharacterBody3D
		var shape_node: CollisionShape3D = enemy_shapes[index] as CollisionShape3D
		if index >= active_count:
			_set_enemy_active(index, false)
			continue
		_set_enemy_active(index, true)
		var enemy: Dictionary = enemies[index]
		var radius_design: float = maxf(12.0, float(enemy.get("radius", 24.0)))
		var radius_world: float = design_radius_to_world(radius_design)
		_set_capsule_radius(shape_node, radius_world)
		body.set_meta("authority_radius", radius_world)
		body.set_meta("authority_kind", String(enemy.get("type", "enemy")))
		var target_design: Vector2 = enemy.get("pos", DESIGN_ARENA.get_center())
		var target_world: Vector3 = design_to_world(target_design)
		var before: Vector3 = body.position
		var result: Dictionary = _move_body_to_target(
			body, target_world, radius_world, safe_delta, bool(enemy_initialized[index])
		)
		enemy_initialized[index] = true
		wall_hits += int(result.get("wall_hits", 0))
		if bool(result.get("corrected", false)):
			corrected_bodies += 1
			collision_points.append(body.position)
		var correction_design: float = world_to_design(body.position).distance_to(target_design)
		max_correction_design = maxf(max_correction_design, correction_design)

	# Enemy-enemy separation is now finalized in world-space. AI still chooses the
	# desired target, but the authoritative endpoint cannot stack bodies freely.
	for pass_index in range(MAX_PAIR_PASSES):
		for a in range(active_count):
			var body_a: CharacterBody3D = enemy_bodies[a] as CharacterBody3D
			var radius_a: float = float(body_a.get_meta("authority_radius", 0.32))
			for b in range(a + 1, active_count):
				var body_b: CharacterBody3D = enemy_bodies[b] as CharacterBody3D
				var radius_b: float = float(body_b.get_meta("authority_radius", 0.32))
				var delta_xz := Vector2(body_b.position.x - body_a.position.x, body_b.position.z - body_a.position.z)
				var distance: float = delta_xz.length()
				var minimum: float = (radius_a + radius_b) * 0.88
				if distance >= minimum:
					continue
				var direction := Vector2.RIGHT
				if distance > 0.0001:
					direction = delta_xz / distance
				else:
					var seed_angle: float = float((a * 17 + b * 31 + pass_index * 13) % 360) * PI / 180.0
					direction = Vector2.from_angle(seed_angle)
				var penetration: float = minimum - distance
				var push: float = penetration * 0.5 * ENEMY_SEPARATION_STRENGTH
				body_a.position.x -= direction.x * push
				body_a.position.z -= direction.y * push
				body_b.position.x += direction.x * push
				body_b.position.z += direction.y * push
				_clamp_body_to_world(body_a, radius_a)
				_clamp_body_to_world(body_b, radius_b)
				separation_hits += 1
				collision_points.append((body_a.position + body_b.position) * 0.5)

	# Keep player/enemy overlap behavior compatible for now, but report real 3D
	# contact pressure so later releases can move touch damage onto Area3D safely.
	for index in range(active_count):
		var enemy_body: CharacterBody3D = enemy_bodies[index] as CharacterBody3D
		var enemy_radius: float = float(enemy_body.get_meta("authority_radius", 0.32))
		var planar_distance := Vector2(
			enemy_body.position.x - player_body.position.x,
			enemy_body.position.z - player_body.position.z
		).length()
		if planar_distance <= (player_radius_world + enemy_radius) * 1.12:
			contact_pairs += 1

	var enemy_positions: Array = []
	for index in range(active_count):
		var body: CharacterBody3D = enemy_bodies[index] as CharacterBody3D
		enemy_positions.append(world_to_design(body.position))

	last_report = {
		"ready": true,
		"mode": "hybrid_3d_collision_authority",
		"frame": frame_index,
		"player_pos": world_to_design(player_body.position),
		"enemy_positions": enemy_positions,
		"active_enemy_bodies": active_count,
		"wall_hits": wall_hits,
		"separation_hits": separation_hits,
		"contact_pairs": contact_pairs,
		"corrected_bodies": corrected_bodies,
		"max_correction_design": max_correction_design,
		"collision_points": _dedupe_points(collision_points, 10),
		"player_motion_world": player_body.position.distance_to(player_before),
	}
	return last_report

func debug_snapshot() -> Dictionary:
	var data: Dictionary = last_report.duplicate(true)
	data["authority_ready"] = authority_ready()
	data["character_bodies"] = enemy_bodies.size() + (1 if player_body != null else 0)
	data["static_bounds"] = wall_bodies.size()
	data["enemy_capacity"] = MAX_ENEMIES
	data["player_body_type"] = player_body.get_class() if player_body != null else ""
	return data

func reset_authority() -> void:
	player_initialized = false
	for index in range(enemy_initialized.size()):
		enemy_initialized[index] = false
	last_report = _empty_report()

func _build_player_body() -> void:
	player_body = CharacterBody3D.new()
	player_body.name = "PlayerAuthorityBody"
	player_body.collision_layer = LAYER_PLAYER
	player_body.collision_mask = LAYER_WORLD
	player_body.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	add_child(player_body)
	player_shape = _add_capsule_shape(player_body, "PlayerAuthorityShape", design_radius_to_world(PLAYER_RADIUS_DESIGN))

func _build_enemy_bodies() -> void:
	for index in range(MAX_ENEMIES):
		var body := CharacterBody3D.new()
		body.name = "EnemyAuthorityBody%02d" % index
		body.collision_layer = LAYER_ENEMY
		body.collision_mask = LAYER_WORLD
		body.motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
		body.visible = false
		add_child(body)
		var shape_node: CollisionShape3D = _add_capsule_shape(body, "EnemyAuthorityShape", design_radius_to_world(24.0))
		shape_node.disabled = true
		enemy_bodies.append(body)
		enemy_shapes.append(shape_node)
		enemy_initialized.append(false)

func _build_static_bounds() -> void:
	_add_wall("AuthorityWallLeft", Vector3(-WORLD_HALF_WIDTH - WALL_THICKNESS * 0.5, 0.75, 0.0), Vector3(WALL_THICKNESS, 2.6, WORLD_HALF_DEPTH * 2.0 + 1.8))
	_add_wall("AuthorityWallRight", Vector3(WORLD_HALF_WIDTH + WALL_THICKNESS * 0.5, 0.75, 0.0), Vector3(WALL_THICKNESS, 2.6, WORLD_HALF_DEPTH * 2.0 + 1.8))
	_add_wall("AuthorityWallBack", Vector3(0.0, 0.75, -WORLD_HALF_DEPTH - WALL_THICKNESS * 0.5), Vector3(WORLD_HALF_WIDTH * 2.0 + 1.8, 2.6, WALL_THICKNESS))
	_add_wall("AuthorityWallFront", Vector3(0.0, 0.75, WORLD_HALF_DEPTH + WALL_THICKNESS * 0.5), Vector3(WORLD_HALF_WIDTH * 2.0 + 1.8, 2.6, WALL_THICKNESS))

func _add_wall(name_value: String, position_value: Vector3, size_value: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = name_value
	body.position = position_value
	body.collision_layer = LAYER_WORLD
	body.collision_mask = LAYER_PLAYER | LAYER_ENEMY
	add_child(body)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size_value
	collision.shape = shape
	body.add_child(collision)
	wall_bodies.append(body)

func _add_capsule_shape(parent: CollisionObject3D, name_value: String, radius: float) -> CollisionShape3D:
	var shape_node := CollisionShape3D.new()
	shape_node.name = name_value
	var capsule := CapsuleShape3D.new()
	capsule.radius = radius
	capsule.height = maxf(BODY_HEIGHT, radius * 2.0 + 0.15)
	shape_node.shape = capsule
	shape_node.position.y = capsule.height * 0.5
	parent.add_child(shape_node)
	return shape_node

func _set_capsule_radius(shape_node: CollisionShape3D, radius: float) -> void:
	if shape_node == null or not (shape_node.shape is CapsuleShape3D):
		return
	var capsule := shape_node.shape as CapsuleShape3D
	capsule.radius = radius
	capsule.height = maxf(BODY_HEIGHT, radius * 2.0 + 0.15)
	shape_node.position.y = capsule.height * 0.5

func _set_enemy_active(index: int, value: bool) -> void:
	var body: CharacterBody3D = enemy_bodies[index] as CharacterBody3D
	var shape_node: CollisionShape3D = enemy_shapes[index] as CollisionShape3D
	body.visible = value
	shape_node.disabled = not value
	body.collision_layer = LAYER_ENEMY if value else 0
	body.collision_mask = LAYER_WORLD if value else 0
	if not value:
		enemy_initialized[index] = false

func _move_body_to_target(body: CharacterBody3D, target: Vector3, radius: float, delta: float, initialized: bool) -> Dictionary:
	var corrected := false
	var wall_hits := 0
	var bounded_target: Vector3 = target
	bounded_target.x = clampf(bounded_target.x, -WORLD_HALF_WIDTH + radius, WORLD_HALF_WIDTH - radius)
	bounded_target.z = clampf(bounded_target.z, -WORLD_HALF_DEPTH + radius, WORLD_HALF_DEPTH - radius)
	bounded_target.y = 0.0
	if bounded_target.distance_to(target) > 0.0001:
		corrected = true
		wall_hits += 1

	if not initialized or body.position.distance_to(bounded_target) > TELEPORT_DISTANCE:
		body.position = bounded_target
		body.velocity = Vector3.ZERO
		return {"corrected": corrected, "wall_hits": wall_hits}

	var motion: Vector3 = bounded_target - body.position
	motion.y = 0.0
	body.velocity = motion / delta
	if motion.length_squared() > 0.0000001:
		var collision: KinematicCollision3D = body.move_and_collide(motion)
		if collision != null:
			wall_hits += 1
			corrected = true
	_clamp_body_to_world(body, radius)
	if body.position.distance_to(bounded_target) > 0.001:
		corrected = true
	return {"corrected": corrected, "wall_hits": wall_hits}

func _clamp_body_to_world(body: CharacterBody3D, radius: float) -> void:
	body.position.x = clampf(body.position.x, -WORLD_HALF_WIDTH + radius, WORLD_HALF_WIDTH - radius)
	body.position.z = clampf(body.position.z, -WORLD_HALF_DEPTH + radius, WORLD_HALF_DEPTH - radius)
	body.position.y = 0.0

func _dedupe_points(points: Array, limit: int) -> Array:
	var result: Array = []
	for point_value in points:
		var point: Vector3 = point_value
		var duplicate := false
		for existing_value in result:
			var existing: Vector3 = existing_value
			if point.distance_squared_to(existing) < 0.18 * 0.18:
				duplicate = true
				break
		if not duplicate:
			result.append(point)
		if result.size() >= limit:
			break
	return result

func _empty_report() -> Dictionary:
	return {
		"ready": false,
		"mode": "hybrid_3d_collision_authority",
		"frame": frame_index,
		"player_pos": DESIGN_ARENA.get_center(),
		"enemy_positions": [],
		"active_enemy_bodies": 0,
		"wall_hits": 0,
		"separation_hits": 0,
		"contact_pairs": 0,
		"corrected_bodies": 0,
		"max_correction_design": 0.0,
		"collision_points": [],
		"player_motion_world": 0.0,
	}
