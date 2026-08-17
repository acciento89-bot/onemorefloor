extends "res://scripts/main_v63.gd"

# ONE MORE FLOOR v1.51 - 3D Combat Authority Phase 2.
# Floors 1-50 keep v1.50 CharacterBody3D locomotion authority and now move the
# touch trigger plus projectile travel/hit selection into the real 3D world.
# Damage math, HP, armor, AI, rewards and progression remain in the proven runtime.

const CombatAuthorityWorld3DChamber = preload("res://scripts/world3d_chamber_v151.gd")
const V64_VERSION := "1.51.0-3d-combat-authority"
const V64_BUILD := "37-dev"
const V64_3D_MIN_FLOOR := 1
const V64_3D_MAX_FLOOR := 50
const V64_MAX_CONTACT_SLOTS := 18
const V64_TOUCH_COOLDOWN := 0.62

var v64_contact_cooldowns: Array[float] = []
var v64_contact_floor := -1
var v64_touch_hits := 0
var v64_player_projectile_hits := 0
var v64_enemy_projectile_hits := 0
var v64_projectile_frames := 0
var v64_legacy_touch_suppressed_frames := 0
var v64_last_player_projectile_report: Dictionary = {}
var v64_last_enemy_projectile_report: Dictionary = {}

func _ready() -> void:
	for _index in range(V64_MAX_CONTACT_SLOTS):
		v64_contact_cooldowns.append(0.0)
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V64_VERSION, V64_BUILD)
		telemetry.event("combat_3d_authority_ready", {
			"world_ready": _v64_3d_combat_authority_ready(),
			"mode": "hybrid_3d_combat_authority",
			"floor_min": V64_3D_MIN_FLOOR,
			"floor_max": V64_3D_MAX_FLOOR,
			"touch_trigger": "3d_contact",
			"projectile_mode": "3d_sphere_sweep",
			"projectile_area_pool": 64,
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

	v52_world_root = CombatAuthorityWorld3DChamber.new()
	v52_world_root.name = "Tower3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v52_3d_active() -> bool:
	if state != State.RUNNING or run == null:
		return false
	var floor_no: int = int(run.floor_no)
	return floor_no >= V64_3D_MIN_FLOOR and floor_no <= V64_3D_MAX_FLOOR

# The old enemy movement/AI still runs, but its 2D distance-based touch trigger
# is held closed. v1.51 applies the same touch damage/cooldown only after the
# CharacterBody3D authority reports an actual world-space contact.
func update_enemies(delta: float) -> void:
	if _v64_floor_uses_combat_authority() and _v64_3d_combat_authority_ready():
		for index in range(enemies.size()):
			var enemy: Dictionary = enemies[index]
			enemy["touch_cd"] = 999.0
			enemies[index] = enemy
		v64_legacy_touch_suppressed_frames += 1
	super.update_enemies(delta)

# Dynamic dispatch from the inherited update loop lands here instead of the old
# 2D point-distance projectile simulation.
func update_player_shots(delta: float) -> void:
	if not _v64_floor_uses_combat_authority() or not _v64_3d_combat_authority_ready():
		super.update_player_shots(delta)
		return
	var result_value: Variant = v52_world_root.call("resolve_player_projectiles_3d", delta, player_shots, enemies)
	if not (result_value is Dictionary):
		super.update_player_shots(delta)
		return
	var result: Dictionary = result_value
	if not bool(result.get("ready", false)):
		super.update_player_shots(delta)
		return

	player_shots.clear()
	var survivor_values: Variant = result.get("shots", [])
	if survivor_values is Array:
		for shot_value in survivor_values:
			if shot_value is Dictionary:
				player_shots.append(shot_value)

	var hit_values: Variant = result.get("hits", [])
	if hit_values is Array:
		for hit_value in hit_values:
			if not (hit_value is Dictionary):
				continue
			var hit: Dictionary = hit_value
			apply_damage_to_enemy(
				int(hit.get("enemy_index", -1)),
				float(hit.get("damage", 0.0)),
				bool(hit.get("crit", false)),
				hit.get("hit_pos", player_pos)
			)
			v64_player_projectile_hits += 1
	v64_projectile_frames += 1
	v64_last_player_projectile_report = _v64_trim_projectile_report(result)

func update_enemy_shots(delta: float) -> void:
	if not _v64_floor_uses_combat_authority() or not _v64_3d_combat_authority_ready():
		super.update_enemy_shots(delta)
		return
	var result_value: Variant = v52_world_root.call("resolve_enemy_projectiles_3d", delta, enemy_shots, player_pos)
	if not (result_value is Dictionary):
		super.update_enemy_shots(delta)
		return
	var result: Dictionary = result_value
	if not bool(result.get("ready", false)):
		super.update_enemy_shots(delta)
		return

	enemy_shots.clear()
	var survivor_values: Variant = result.get("shots", [])
	if survivor_values is Array:
		for shot_value in survivor_values:
			if shot_value is Dictionary:
				enemy_shots.append(shot_value)

	var hit_values: Variant = result.get("hits", [])
	if hit_values is Array:
		for hit_value in hit_values:
			if not (hit_value is Dictionary):
				continue
			var hit: Dictionary = hit_value
			damage_player(float(hit.get("damage", 0.0)), hit.get("hit_pos", player_pos))
			v64_enemy_projectile_hits += 1
	v64_projectile_frames += 1
	v64_last_enemy_projectile_report = _v64_trim_projectile_report(result)

# v1.63 still resolves locomotion after the inherited game update. Once that
# authoritative endpoint is available, apply the contact trigger from 3D.
func update_game(delta: float) -> void:
	_v64_tick_contact_cooldowns(delta)
	super.update_game(delta)
	if state != State.RUNNING or run == null:
		return
	if not _v64_floor_uses_combat_authority() or not _v64_3d_combat_authority_ready():
		return
	_v64_reset_contacts_on_floor_change()
	_v64_apply_3d_touch_contacts()
	if state == State.RUNNING and run != null and float(run.hp) <= 0.0:
		die()

func _v64_apply_3d_touch_contacts() -> void:
	if v63_last_authority_report.is_empty():
		return
	var contact_values: Variant = v63_last_authority_report.get("contact_indices", [])
	if not (contact_values is Array):
		return
	var contacts: Array = contact_values
	for index_value in contacts:
		var enemy_index: int = int(index_value)
		if enemy_index < 0 or enemy_index >= enemies.size() or enemy_index >= v64_contact_cooldowns.size():
			continue
		if v64_contact_cooldowns[enemy_index] > 0.0:
			continue
		var enemy: Dictionary = enemies[enemy_index]
		var source: Vector2 = enemy.get("pos", player_pos)
		damage_player(float(enemy.get("touch_damage", 1.0)), source)
		v64_contact_cooldowns[enemy_index] = V64_TOUCH_COOLDOWN
		v64_touch_hits += 1

func _v64_tick_contact_cooldowns(delta: float) -> void:
	for index in range(v64_contact_cooldowns.size()):
		v64_contact_cooldowns[index] = maxf(0.0, v64_contact_cooldowns[index] - delta)

func _v64_reset_contacts_on_floor_change() -> void:
	var floor_no: int = int(run.floor_no) if run != null else -1
	if floor_no == v64_contact_floor:
		return
	v64_contact_floor = floor_no
	for index in range(v64_contact_cooldowns.size()):
		v64_contact_cooldowns[index] = 0.0

func _v64_floor_uses_combat_authority() -> bool:
	if run == null:
		return false
	var floor_no: int = int(run.floor_no)
	return floor_no >= V64_3D_MIN_FLOOR and floor_no <= V64_3D_MAX_FLOOR

func _v64_3d_combat_authority_ready() -> bool:
	return _v63_3d_gameplay_authority_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("combat_authority_ready") \
		and bool(v52_world_root.call("combat_authority_ready"))

func _v64_trim_projectile_report(report: Dictionary) -> Dictionary:
	var hit_count := 0
	var hit_values: Variant = report.get("hits", [])
	if hit_values is Array:
		hit_count = (hit_values as Array).size()
	var shot_count := 0
	var shot_values: Variant = report.get("shots", [])
	if shot_values is Array:
		shot_count = (shot_values as Array).size()
	return {
		"ready": bool(report.get("ready", false)),
		"mode": String(report.get("mode", "")),
		"hits": hit_count,
		"survivors": shot_count,
		"active_slots": int(report.get("active_slots", 0)),
		"expired": int(report.get("expired", 0)),
	}

func _v64_combat_authority_snapshot() -> Dictionary:
	var world_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("debug_snapshot"):
		world_snapshot = v52_world_root.call("debug_snapshot")
	return {
		"ready": _v64_3d_combat_authority_ready(),
		"mode": "hybrid_3d_combat_authority",
		"touch_trigger": "3d_contact",
		"projectile_mode": "3d_sphere_sweep",
		"touch_hits": v64_touch_hits,
		"player_projectile_hits": v64_player_projectile_hits,
		"enemy_projectile_hits": v64_enemy_projectile_hits,
		"projectile_frames": v64_projectile_frames,
		"legacy_touch_suppressed_frames": v64_legacy_touch_suppressed_frames,
		"contact_floor": v64_contact_floor,
		"last_player_projectiles": v64_last_player_projectile_report.duplicate(true),
		"last_enemy_projectiles": v64_last_enemy_projectile_report.duplicate(true),
		"world": world_snapshot,
	}
