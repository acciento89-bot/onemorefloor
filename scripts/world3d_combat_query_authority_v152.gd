extends Node3D

# ONE MORE FLOOR v1.52 — 3D combat-query authority.
# Target acquisition, NOVA radius selection and Warden cast geometry now resolve
# in tower world-space. Runtime dictionaries still own damage, cooldowns, HP and
# rewards; this node decides who/what lies inside combat geometry.

const DESIGN_ARENA := Rect2(36.0, 160.0, 648.0, 840.0)
const WORLD_HALF_WIDTH := 4.65
const WORLD_HALF_DEPTH := 6.05
const SENSOR_HEIGHT := 0.72
const MAX_TARGETS := 18
const WARDEN_LANE_COUNT := 7
const WARDEN_LANE_LENGTH_DESIGN := 470.0
const WARDEN_LANE_HALF_WIDTH_DESIGN := 20.0

var attack_sensor: Area3D
var attack_shape: CollisionShape3D
var nova_sensor: Area3D
var nova_shape: CollisionShape3D
var warden_focus_sensor: Area3D
var warden_focus_shape: CollisionShape3D
var warden_lane_areas: Array = []
var warden_lane_shapes: Array = []

var target_queries := 0
var nova_queries := 0
var warden_plans := 0
var targets_selected_total := 0
var nova_enemy_hits_total := 0
var nova_projectiles_purged_total := 0
var last_target_report: Dictionary = {}
var last_nova_report: Dictionary = {}
var last_warden_report: Dictionary = {}

func _ready() -> void:
	_build_sensors()

func combat_query_ready() -> bool:
	return attack_sensor != null \
		and nova_sensor != null \
		and warden_focus_sensor != null \
		and attack_shape != null \
		and nova_shape != null \
		and warden_focus_shape != null \
		and warden_lane_areas.size() == WARDEN_LANE_COUNT \
		and warden_lane_shapes.size() == WARDEN_LANE_COUNT

func design_to_world(pos: Vector2, y: float = SENSOR_HEIGHT) -> Vector3:
	var nx: float = (pos.x - DESIGN_ARENA.get_center().x) / (DESIGN_ARENA.size.x * 0.5)
	var nz: float = (pos.y - DESIGN_ARENA.get_center().y) / (DESIGN_ARENA.size.y * 0.5)
	return Vector3(nx * WORLD_HALF_WIDTH, y, nz * WORLD_HALF_DEPTH)

func world_to_design(pos: Vector3) -> Vector2:
	var nx: float = pos.x / WORLD_HALF_WIDTH
	var nz: float = pos.z / WORLD_HALF_DEPTH
	return DESIGN_ARENA.get_center() + Vector2(nx * DESIGN_ARENA.size.x * 0.5, nz * DESIGN_ARENA.size.y * 0.5)

func design_radius_to_world(radius_design: float) -> float:
	var sx: float = WORLD_HALF_WIDTH / (DESIGN_ARENA.size.x * 0.5)
	var sz: float = WORLD_HALF_DEPTH / (DESIGN_ARENA.size.y * 0.5)
	return maxf(0.06, radius_design * (sx + sz) * 0.5)

func query_targets(
	player_design: Vector2,
	enemies: Array,
	range_design: float,
	ignore: Array[int] = [],
	max_count: int = 1
) -> Dictionary:
	if not combat_query_ready():
		return {"ready": false, "indices": [], "mode": "3d_world_range"}
	target_queries += 1
	var center: Vector3 = design_to_world(player_design)
	var radius_world: float = design_radius_to_world(range_design)
	_configure_sphere_sensor(attack_sensor, attack_shape, center, radius_world)

	var candidates: Array = []
	var ignored: Dictionary = {}
	for value in ignore:
		ignored[int(value)] = true
	for index in range(mini(enemies.size(), MAX_TARGETS)):
		if ignored.has(index):
			continue
		var enemy_value: Variant = enemies[index]
		if not (enemy_value is Dictionary):
			continue
		var enemy: Dictionary = enemy_value
		var enemy_world: Vector3 = design_to_world(enemy.get("pos", DESIGN_ARENA.get_center()))
		var distance_world: float = _planar_distance(center, enemy_world)
		if distance_world > radius_world:
			continue
		candidates.append({"index": index, "distance": distance_world, "world_pos": enemy_world})
	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a["distance"]) < float(b["distance"]))

	var indices: Array = []
	var world_points: Array = []
	var wanted: int = clampi(max_count, 0, MAX_TARGETS)
	for candidate_value in candidates:
		if indices.size() >= wanted:
			break
		var candidate: Dictionary = candidate_value
		indices.append(int(candidate["index"]))
		world_points.append(candidate["world_pos"])
	targets_selected_total += indices.size()
	last_target_report = {
		"ready": true,
		"mode": "3d_world_range",
		"indices": indices,
		"world_points": world_points,
		"center_world": center,
		"radius_world": radius_world,
		"candidate_count": candidates.size(),
	}
	return last_target_report

func query_nova(
	player_design: Vector2,
	enemies: Array,
	enemy_shots: Array,
	radius_design: float
) -> Dictionary:
	if not combat_query_ready():
		return {"ready": false, "enemy_indices": [], "projectile_indices": [], "mode": "3d_nova_volume"}
	nova_queries += 1
	var center: Vector3 = design_to_world(player_design)
	var radius_world: float = design_radius_to_world(radius_design)
	_configure_sphere_sensor(nova_sensor, nova_shape, center, radius_world)

	var enemy_indices: Array = []
	var enemy_world_points: Array = []
	for index in range(mini(enemies.size(), MAX_TARGETS)):
		var enemy_value: Variant = enemies[index]
		if not (enemy_value is Dictionary):
			continue
		var enemy: Dictionary = enemy_value
		var enemy_world: Vector3 = design_to_world(enemy.get("pos", DESIGN_ARENA.get_center()))
		var enemy_radius: float = design_radius_to_world(maxf(12.0, float(enemy.get("radius", 24.0))))
		if _planar_distance(center, enemy_world) <= radius_world + enemy_radius * 0.28:
			enemy_indices.append(index)
			enemy_world_points.append(enemy_world)

	var projectile_indices: Array = []
	var projectile_world_points: Array = []
	for index in range(enemy_shots.size()):
		var shot_value: Variant = enemy_shots[index]
		if not (shot_value is Dictionary):
			continue
		var shot: Dictionary = shot_value
		var shot_world: Vector3 = design_to_world(shot.get("pos", DESIGN_ARENA.get_center()))
		if _planar_distance(center, shot_world) <= radius_world:
			projectile_indices.append(index)
			projectile_world_points.append(shot_world)

	nova_enemy_hits_total += enemy_indices.size()
	nova_projectiles_purged_total += projectile_indices.size()
	last_nova_report = {
		"ready": true,
		"mode": "3d_nova_volume",
		"enemy_indices": enemy_indices,
		"projectile_indices": projectile_indices,
		"enemy_world_points": enemy_world_points,
		"projectile_world_points": projectile_world_points,
		"center_world": center,
		"radius_world": radius_world,
	}
	return last_nova_report

func plan_warden_cast(
	origin_design: Vector2,
	target_design: Vector2,
	phase2: bool,
	cast_kind: String,
	attack_index: int
) -> Dictionary:
	if not combat_query_ready():
		return {"ready": false, "directions": [], "mode": "3d_warden_cast_geometry"}
	warden_plans += 1
	var origin_world: Vector3 = design_to_world(origin_design)
	var target_world: Vector3 = design_to_world(target_design)
	var aim_world: Vector3 = target_world - origin_world
	aim_world.y = 0.0
	if aim_world.length_squared() <= 0.000001:
		aim_world = Vector3(0.0, 0.0, 1.0)
	else:
		aim_world = aim_world.normalized()
	_configure_sphere_sensor(warden_focus_sensor, warden_focus_shape, origin_world, design_radius_to_world(52.0))

	var directions: Array = []
	var world_directions: Array = []
	var lane_points: Array = []
	var player_in_lane := false
	if cast_kind == "fan":
		var base_angle: float = atan2(aim_world.x, aim_world.z)
		for index in range(WARDEN_LANE_COUNT):
			var spread: float = (float(index) - 3.0) * 0.16
			var angle: float = base_angle + spread
			var dir_world := Vector3(sin(angle), 0.0, cos(angle)).normalized()
			world_directions.append(dir_world)
			directions.append(_world_direction_to_design(dir_world))
			var lane_end: Vector3 = origin_world + dir_world * design_radius_to_world(WARDEN_LANE_LENGTH_DESIGN)
			lane_points.append(lane_end)
			_configure_lane(index, origin_world, dir_world, design_radius_to_world(WARDEN_LANE_LENGTH_DESIGN), design_radius_to_world(WARDEN_LANE_HALF_WIDTH_DESIGN))
			if _point_segment_distance_xz(target_world, origin_world, lane_end) <= design_radius_to_world(WARDEN_LANE_HALF_WIDTH_DESIGN + 18.0):
				player_in_lane = true
	else:
		_hide_warden_lanes()
		var count: int = 14 if phase2 else 10
		var offset: float = float(attack_index) * 0.21
		for index in range(count):
			var angle: float = offset + TAU * float(index) / float(count)
			var dir_world := Vector3(cos(angle), 0.0, sin(angle)).normalized()
			world_directions.append(dir_world)
			directions.append(_world_direction_to_design(dir_world))

	last_warden_report = {
		"ready": true,
		"mode": "3d_warden_cast_geometry",
		"cast_kind": cast_kind,
		"phase2": phase2,
		"origin_world": origin_world,
		"target_world": target_world,
		"directions": directions,
		"world_directions": world_directions,
		"lane_endpoints": lane_points,
		"player_in_lane": player_in_lane,
	}
	return last_warden_report

func debug_snapshot() -> Dictionary:
	return {
		"ready": combat_query_ready(),
		"mode": "3d_combat_query_authority",
		"attack_sensor": attack_sensor != null and attack_shape != null,
		"nova_sensor": nova_sensor != null and nova_shape != null,
		"warden_focus_sensor": warden_focus_sensor != null and warden_focus_shape != null,
		"warden_lane_areas": warden_lane_areas.size(),
		"target_queries": target_queries,
		"nova_queries": nova_queries,
		"warden_plans": warden_plans,
		"targets_selected": targets_selected_total,
		"nova_enemy_hits": nova_enemy_hits_total,
		"nova_projectiles_purged": nova_projectiles_purged_total,
		"last_targets": last_target_report.duplicate(true),
		"last_nova": last_nova_report.duplicate(true),
		"last_warden": last_warden_report.duplicate(true),
	}

func reset_authority() -> void:
	last_target_report = {}
	last_nova_report = {}
	last_warden_report = {}
	_hide_warden_lanes()

func _build_sensors() -> void:
	attack_sensor = _make_sphere_area("AttackRangeAuthority3D")
	attack_shape = attack_sensor.get_node("Sphere") as CollisionShape3D
	nova_sensor = _make_sphere_area("NovaAuthority3D")
	nova_shape = nova_sensor.get_node("Sphere") as CollisionShape3D
	warden_focus_sensor = _make_sphere_area("WardenFocusAuthority3D")
	warden_focus_shape = warden_focus_sensor.get_node("Sphere") as CollisionShape3D
	for index in range(WARDEN_LANE_COUNT):
		var area := Area3D.new()
		area.name = "WardenThreatLane%02d" % index
		area.collision_layer = 0
		area.collision_mask = 0
		area.monitoring = false
		area.monitorable = false
		area.visible = false
		add_child(area)
		var collision := CollisionShape3D.new()
		collision.name = "LaneBox"
		var box := BoxShape3D.new()
		box.size = Vector3(0.3, 1.2, 1.0)
		collision.shape = box
		area.add_child(collision)
		warden_lane_areas.append(area)
		warden_lane_shapes.append(collision)

func _make_sphere_area(name_value: String) -> Area3D:
	var area := Area3D.new()
	area.name = name_value
	area.collision_layer = 0
	area.collision_mask = 0
	area.monitoring = false
	area.monitorable = false
	add_child(area)
	var collision := CollisionShape3D.new()
	collision.name = "Sphere"
	var sphere := SphereShape3D.new()
	sphere.radius = 0.1
	collision.shape = sphere
	area.add_child(collision)
	return area

func _configure_sphere_sensor(area: Area3D, shape_node: CollisionShape3D, center: Vector3, radius: float) -> void:
	area.position = center
	if shape_node.shape is SphereShape3D:
		(shape_node.shape as SphereShape3D).radius = radius

func _configure_lane(index: int, origin: Vector3, direction: Vector3, length: float, half_width: float) -> void:
	if index < 0 or index >= warden_lane_areas.size():
		return
	var area: Area3D = warden_lane_areas[index] as Area3D
	var shape_node: CollisionShape3D = warden_lane_shapes[index] as CollisionShape3D
	if area == null or shape_node == null or not (shape_node.shape is BoxShape3D):
		return
	area.visible = true
	area.position = origin + direction * length * 0.5
	area.rotation = Vector3(0.0, atan2(direction.x, direction.z), 0.0)
	var box := shape_node.shape as BoxShape3D
	box.size = Vector3(half_width * 2.0, 1.25, length)

func _hide_warden_lanes() -> void:
	for area_value in warden_lane_areas:
		var area: Area3D = area_value as Area3D
		if area != null:
			area.visible = false

func _world_direction_to_design(direction: Vector3) -> Vector2:
	var dx: float = direction.x / WORLD_HALF_WIDTH * (DESIGN_ARENA.size.x * 0.5)
	var dy: float = direction.z / WORLD_HALF_DEPTH * (DESIGN_ARENA.size.y * 0.5)
	var result := Vector2(dx, dy)
	return result.normalized() if result.length_squared() > 0.000001 else Vector2.RIGHT

func _planar_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()

func _point_segment_distance_xz(point: Vector3, start: Vector3, end: Vector3) -> float:
	var p := Vector2(point.x, point.z)
	var a := Vector2(start.x, start.z)
	var b := Vector2(end.x, end.z)
	var segment := b - a
	var length_sq: float = segment.length_squared()
	if length_sq <= 0.000001:
		return p.distance_to(a)
	var t: float = clampf((p - a).dot(segment) / length_sq, 0.0, 1.0)
	return p.distance_to(a + segment * t)
