extends "res://scripts/main_v64.gd"

# ONE MORE FLOOR v1.52 - 3D Combat Core Phase 3.
# Floors 1-50 now route auto-target range, NOVA volume selection and Warden cast
# geometry through real 3D world-space sensors/queries. Damage formulas, HP,
# cooldowns, AI decisions, rewards, progression and UI remain in the tested stack.

const CombatCoreWorld3DChamber = preload("res://scripts/world3d_chamber_v152.gd")
const V65_VERSION := "1.52.0-3d-combat-core"
const V65_BUILD := "38-dev"
const V65_3D_MIN_FLOOR := 1
const V65_3D_MAX_FLOOR := 50

var v65_target_queries := 0
var v65_target_acquisitions := 0
var v65_nova_queries := 0
var v65_nova_enemy_hits := 0
var v65_nova_projectiles_purged := 0
var v65_warden_cast_plans := 0
var v65_warden_fan_plans := 0
var v65_warden_ring_plans := 0
var v65_last_target_report: Dictionary = {}
var v65_last_nova_report: Dictionary = {}
var v65_last_warden_report: Dictionary = {}

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V65_VERSION, V65_BUILD)
		telemetry.event("combat_core_3d_authority_ready", {
			"world_ready": _v65_3d_combat_core_ready(),
			"mode": "hybrid_3d_combat_core_authority",
			"floor_min": V65_3D_MIN_FLOOR,
			"floor_max": V65_3D_MAX_FLOOR,
			"targeting": "3d_world_range",
			"nova": "3d_nova_volume",
			"warden_cast": "3d_warden_cast_geometry",
		})

func _v52_create_world_viewport() -> void:
	v52_world_viewport = SubViewport.new()
	v52_world_viewport.name = "Combat3DViewport"
	v52_world_viewport.size = Vector2i(int(ARENA.size.x), int(ARENA.size.y))
	v52_world_viewport.own_world_3d = true
	v52_world_viewport.transparent_bg = false
	v52_world_viewport.disable_3d = false
	v52_world_viewport.msaa_3d = Viewport.MSAA_2X
	v52_world_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(v52_world_viewport)

	v52_world_root = CombatCoreWorld3DChamber.new()
	v52_world_root.name = "Tower3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v52_3d_active() -> bool:
	if state != State.RUNNING or run == null:
		return false
	var floor_no: int = int(run.floor_no)
	return floor_no >= V65_3D_MIN_FLOOR and floor_no <= V65_3D_MAX_FLOOR

# Dynamic dispatch from fire_auto_attack() lands here. The chosen index now comes
# from world-space range/distance rather than the historical 2D distance helper.
func nearest_enemy(ignore: Array[int]) -> int:
	if not _v65_floor_uses_combat_core() or not _v65_3d_combat_core_ready():
		return super.nearest_enemy(ignore)
	var value: Variant = v52_world_root.call(
		"query_targets_3d", player_pos, enemies, float(run.attack_range), ignore, 1
	)
	if not (value is Dictionary):
		return super.nearest_enemy(ignore)
	var report: Dictionary = value
	if not bool(report.get("ready", false)):
		return super.nearest_enemy(ignore)
	v65_target_queries += 1
	v65_last_target_report = _v65_trim_target_report(report)
	var indices_value: Variant = report.get("indices", [])
	if not (indices_value is Array) or (indices_value as Array).is_empty():
		return -1
	v65_target_acquisitions += 1
	return int((indices_value as Array)[0])

# NOVA now asks a real 3D spherical combat volume which enemies and hostile
# projectiles are inside. Existing damage/cooldown/effects stay unchanged.
func use_skill() -> void:
	if state != State.RUNNING or run == null or run.skill_cd > 0.0:
		return
	if not _v65_floor_uses_combat_core() or not _v65_3d_combat_core_ready():
		super.use_skill()
		return
	var value: Variant = v52_world_root.call(
		"query_nova_3d", player_pos, enemies, enemy_shots, float(run.nova_radius)
	)
	if not (value is Dictionary):
		super.use_skill()
		return
	var report: Dictionary = value
	if not bool(report.get("ready", false)):
		super.use_skill()
		return

	run.skill_cd = 7.0
	skill_flash = 0.36
	screen_shake = 8.0
	haptic(38)
	effects.append({"type":"nova","pos":player_pos,"age":0.0,"dur":0.38,"color":C_BLUE,"kind":""})

	var enemy_indices_value: Variant = report.get("enemy_indices", [])
	if enemy_indices_value is Array:
		for index_value in enemy_indices_value:
			var enemy_index: int = int(index_value)
			if enemy_index >= 0 and enemy_index < enemies.size():
				apply_damage_to_enemy(enemy_index, run.damage * run.nova_mult, false, enemies[enemy_index]["pos"])
				v65_nova_enemy_hits += 1

	var projectile_indices_value: Variant = report.get("projectile_indices", [])
	if projectile_indices_value is Array:
		var projectile_indices: Array = (projectile_indices_value as Array).duplicate()
		projectile_indices.sort()
		for reverse_index in range(projectile_indices.size() - 1, -1, -1):
			var projectile_index: int = int(projectile_indices[reverse_index])
			if projectile_index >= 0 and projectile_index < enemy_shots.size():
				enemy_shots.remove_at(projectile_index)
				v65_nova_projectiles_purged += 1

	v65_nova_queries += 1
	v65_last_nova_report = _v65_trim_nova_report(report)

# Warden still decides WHEN and WHICH cast to use in the tested AI. v1.52 moves
# the cast's aim/ring/fan geometry into world-space and converts the resulting
# directions back into the existing projectile payloads.
func execute_warden_cast(e: Dictionary) -> void:
	if not _v65_floor_uses_combat_core() or not _v65_3d_combat_core_ready():
		super.execute_warden_cast(e)
		return
	var cast_kind: String = String(e.get("cast_kind", "ring"))
	var phase2: bool = bool(e.get("phase2", false))
	var origin: Vector2 = e.get("pos", player_pos)
	var attack_index: int = int(e.get("attack_index", 0))
	var value: Variant = v52_world_root.call(
		"plan_warden_cast_3d", origin, player_pos, phase2, cast_kind, attack_index
	)
	if not (value is Dictionary):
		super.execute_warden_cast(e)
		return
	var report: Dictionary = value
	if not bool(report.get("ready", false)):
		super.execute_warden_cast(e)
		return
	var directions_value: Variant = report.get("directions", [])
	if not (directions_value is Array) or (directions_value as Array).is_empty():
		super.execute_warden_cast(e)
		return

	var directions: Array = directions_value
	for direction_value in directions:
		var dir: Vector2 = direction_value
		if dir.length_squared() <= 0.000001:
			continue
		dir = dir.normalized()
		var speed: float = 330.0 if cast_kind == "fan" else (245.0 if phase2 else 195.0)
		var damage: float = (15.0 if cast_kind == "fan" else 14.0) + run.floor_no * 0.8
		var life: float = 2.7 if cast_kind == "fan" else 3.3
		var color: Color = C_RED if cast_kind == "fan" or phase2 else C_PURPLE
		enemy_shots.append({
			"pos": origin + dir * 44.0,
			"vel": dir * speed,
			"damage": damage,
			"life": life,
			"color": color,
		})

	screen_shake = maxf(screen_shake, 5.0 if phase2 else 3.0)
	haptic(24)
	v65_warden_cast_plans += 1
	if cast_kind == "fan":
		v65_warden_fan_plans += 1
	else:
		v65_warden_ring_plans += 1
	v65_last_warden_report = _v65_trim_warden_report(report)

func _v65_floor_uses_combat_core() -> bool:
	if run == null:
		return false
	var floor_no: int = int(run.floor_no)
	return floor_no >= V65_3D_MIN_FLOOR and floor_no <= V65_3D_MAX_FLOOR

func _v65_3d_combat_core_ready() -> bool:
	return _v64_3d_combat_authority_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("combat_core_authority_ready") \
		and bool(v52_world_root.call("combat_core_authority_ready"))

func _v65_trim_target_report(report: Dictionary) -> Dictionary:
	var indices: Array = report.get("indices", [])
	return {
		"ready": bool(report.get("ready", false)),
		"mode": String(report.get("mode", "")),
		"indices": indices.duplicate(),
		"candidate_count": int(report.get("candidate_count", 0)),
		"radius_world": float(report.get("radius_world", 0.0)),
	}

func _v65_trim_nova_report(report: Dictionary) -> Dictionary:
	var enemies_value: Variant = report.get("enemy_indices", [])
	var projectiles_value: Variant = report.get("projectile_indices", [])
	return {
		"ready": bool(report.get("ready", false)),
		"mode": String(report.get("mode", "")),
		"enemy_count": (enemies_value as Array).size() if enemies_value is Array else 0,
		"projectile_count": (projectiles_value as Array).size() if projectiles_value is Array else 0,
		"radius_world": float(report.get("radius_world", 0.0)),
	}

func _v65_trim_warden_report(report: Dictionary) -> Dictionary:
	var directions_value: Variant = report.get("directions", [])
	return {
		"ready": bool(report.get("ready", false)),
		"mode": String(report.get("mode", "")),
		"cast_kind": String(report.get("cast_kind", "")),
		"phase2": bool(report.get("phase2", false)),
		"direction_count": (directions_value as Array).size() if directions_value is Array else 0,
		"player_in_lane": bool(report.get("player_in_lane", false)),
	}

func _v65_combat_core_snapshot() -> Dictionary:
	var world_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("debug_snapshot"):
		world_snapshot = v52_world_root.call("debug_snapshot")
	return {
		"ready": _v65_3d_combat_core_ready(),
		"mode": "hybrid_3d_combat_core_authority",
		"targeting": "3d_world_range",
		"nova": "3d_nova_volume",
		"warden_cast": "3d_warden_cast_geometry",
		"target_queries": v65_target_queries,
		"target_acquisitions": v65_target_acquisitions,
		"nova_queries": v65_nova_queries,
		"nova_enemy_hits": v65_nova_enemy_hits,
		"nova_projectiles_purged": v65_nova_projectiles_purged,
		"warden_cast_plans": v65_warden_cast_plans,
		"warden_fan_plans": v65_warden_fan_plans,
		"warden_ring_plans": v65_warden_ring_plans,
		"last_target": v65_last_target_report.duplicate(true),
		"last_nova": v65_last_nova_report.duplicate(true),
		"last_warden": v65_last_warden_report.duplicate(true),
		"world": world_snapshot,
	}
