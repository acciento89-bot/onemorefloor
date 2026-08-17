extends "res://scripts/world3d_chamber_v151.gd"

# ONE MORE FLOOR v1.52 — 3D combat core integration.
# v1.50 locomotion + v1.51 touch/projectile authority remain intact. This layer
# adds world-space target range, NOVA volume and Warden cast geometry authority.

const CombatQueryAuthorityV152 = preload("res://scripts/world3d_combat_query_authority_v152.gd")
const TARGET_LOCK_POOL := 4
const TARGET_LOCK_DURATION := 0.18
const NOVA_VOLUME_DURATION := 0.42
const WARDEN_THREAT_DURATION := 0.62
const WARDEN_LANE_VISUALS := 7

var combat_query_authority: Node3D
var combat_core_fx_root: Node3D
var target_lock_pool: Array = []
var target_lock_cursor := 0
var nova_volume_visual: Node3D
var warden_lane_visuals: Array = []
var warden_ring_visual: Node3D
var target_lock_material: StandardMaterial3D
var nova_volume_material: StandardMaterial3D
var warden_threat_material: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_build_combat_query_authority()
	_build_combat_core_feedback()

func _process(delta: float) -> void:
	super._process(delta)
	_animate_combat_core_feedback(delta)

func combat_core_authority_ready() -> bool:
	return combat_authority_ready() \
		and combat_query_authority != null \
		and combat_query_authority.has_method("combat_query_ready") \
		and bool(combat_query_authority.call("combat_query_ready")) \
		and target_lock_pool.size() == TARGET_LOCK_POOL \
		and warden_lane_visuals.size() == WARDEN_LANE_VISUALS \
		and nova_volume_visual != null \
		and warden_ring_visual != null

func query_targets_3d(
	player_pos: Vector2,
	enemies: Array,
	range_design: float,
	ignore: Array[int],
	max_count: int
) -> Dictionary:
	if not combat_core_authority_ready():
		return {"ready": false, "indices": [], "mode": "3d_world_range"}
	var value: Variant = combat_query_authority.call("query_targets", player_pos, enemies, range_design, ignore, max_count)
	if not (value is Dictionary):
		return {"ready": false, "indices": [], "mode": "3d_world_range"}
	var report: Dictionary = value
	if bool(report.get("ready", false)):
		_show_target_locks(report.get("world_points", []))
	return report

func query_nova_3d(player_pos: Vector2, enemies: Array, enemy_shots: Array, radius_design: float) -> Dictionary:
	if not combat_core_authority_ready():
		return {"ready": false, "enemy_indices": [], "projectile_indices": [], "mode": "3d_nova_volume"}
	var value: Variant = combat_query_authority.call("query_nova", player_pos, enemies, enemy_shots, radius_design)
	if not (value is Dictionary):
		return {"ready": false, "enemy_indices": [], "projectile_indices": [], "mode": "3d_nova_volume"}
	var report: Dictionary = value
	if bool(report.get("ready", false)):
		_show_nova_volume(report)
	return report

func plan_warden_cast_3d(
	origin: Vector2,
	target: Vector2,
	phase2: bool,
	cast_kind: String,
	attack_index: int
) -> Dictionary:
	if not combat_core_authority_ready():
		return {"ready": false, "directions": [], "mode": "3d_warden_cast_geometry"}
	var value: Variant = combat_query_authority.call("plan_warden_cast", origin, target, phase2, cast_kind, attack_index)
	if not (value is Dictionary):
		return {"ready": false, "directions": [], "mode": "3d_warden_cast_geometry"}
	var report: Dictionary = value
	if bool(report.get("ready", false)):
		_show_warden_threat(report)
	return report

func reset_gameplay_authority() -> void:
	super.reset_gameplay_authority()
	if combat_query_authority != null and combat_query_authority.has_method("reset_authority"):
		combat_query_authority.call("reset_authority")
	_hide_combat_core_feedback()

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["combat_core_authority_ready"] = combat_core_authority_ready()
	data["combat_core_mode"] = "3d_target_nova_warden_geometry"
	data["target_lock_pool"] = target_lock_pool.size()
	data["warden_lane_visuals"] = warden_lane_visuals.size()
	if combat_query_authority != null and combat_query_authority.has_method("debug_snapshot"):
		data["combat_query_authority"] = combat_query_authority.call("debug_snapshot")
	return data

func _build_combat_query_authority() -> void:
	combat_query_authority = CombatQueryAuthorityV152.new()
	combat_query_authority.name = "CombatQueryAuthority3D"
	add_child(combat_query_authority)

func _build_combat_core_feedback() -> void:
	target_lock_material = _transparent_emissive(Color(1.0, 0.78, 0.30, 0.24), 1.65)
	nova_volume_material = _transparent_emissive(Color(0.31, 0.78, 1.0, 0.20), 1.75)
	warden_threat_material = _transparent_emissive(Color(1.0, 0.22, 0.28, 0.18), 1.70)
	combat_core_fx_root = Node3D.new()
	combat_core_fx_root.name = "CombatCoreAuthorityFeedback"
	add_child(combat_core_fx_root)

	for index in range(TARGET_LOCK_POOL):
		var root := Node3D.new()
		root.name = "TargetLock%02d" % index
		root.visible = false
		root.set_meta("age", TARGET_LOCK_DURATION + 1.0)
		combat_core_fx_root.add_child(root)
		var ring: MeshInstance3D = _make_ring(root, "LockRing", 0.34, target_lock_material, 28)
		ring.position.y = 0.04
		var marker: MeshInstance3D = _make_box(root, "LockNeedle", Vector3(0.035, 0.24, 0.035), target_lock_material)
		marker.position.y = 0.24
		target_lock_pool.append(root)

	nova_volume_visual = Node3D.new()
	nova_volume_visual.name = "NovaAuthorityVolume"
	nova_volume_visual.visible = false
	nova_volume_visual.set_meta("age", NOVA_VOLUME_DURATION + 1.0)
	combat_core_fx_root.add_child(nova_volume_visual)
	var nova_ring: MeshInstance3D = _make_ring(nova_volume_visual, "NovaBoundary", 1.0, nova_volume_material, 48)
	nova_ring.position.y = 0.035
	var nova_core: MeshInstance3D = _make_sphere(nova_volume_visual, "NovaCore", 0.12, nova_volume_material)
	nova_core.position.y = 0.10

	for index in range(WARDEN_LANE_VISUALS):
		var lane := Node3D.new()
		lane.name = "WardenThreatVisual%02d" % index
		lane.visible = false
		lane.set_meta("age", WARDEN_THREAT_DURATION + 1.0)
		combat_core_fx_root.add_child(lane)
		var strip: MeshInstance3D = _make_box(lane, "ThreatStrip", Vector3(1.0, 0.025, 1.0), warden_threat_material)
		strip.position.y = 0.035
		warden_lane_visuals.append(lane)

	warden_ring_visual = Node3D.new()
	warden_ring_visual.name = "WardenRingThreat"
	warden_ring_visual.visible = false
	warden_ring_visual.set_meta("age", WARDEN_THREAT_DURATION + 1.0)
	combat_core_fx_root.add_child(warden_ring_visual)
	var threat_ring: MeshInstance3D = _make_ring(warden_ring_visual, "ThreatRing", 1.0, warden_threat_material, 48)
	threat_ring.position.y = 0.035

func _show_target_locks(world_points_value: Variant) -> void:
	if not (world_points_value is Array):
		return
	for point_value in world_points_value:
		if target_lock_pool.is_empty():
			break
		var root: Node3D = target_lock_pool[target_lock_cursor] as Node3D
		target_lock_cursor = (target_lock_cursor + 1) % target_lock_pool.size()
		if root == null:
			continue
		root.visible = true
		root.position = point_value
		root.position.y = 0.02
		root.scale = Vector3.ONE
		root.rotation = Vector3.ZERO
		root.set_meta("age", 0.0)

func _show_nova_volume(report: Dictionary) -> void:
	if nova_volume_visual == null:
		return
	var center: Vector3 = report.get("center_world", Vector3.ZERO)
	var radius: float = maxf(0.1, float(report.get("radius_world", 0.1)))
	nova_volume_visual.visible = true
	nova_volume_visual.position = Vector3(center.x, 0.0, center.z)
	nova_volume_visual.scale = Vector3(radius, 1.0, radius)
	nova_volume_visual.rotation = Vector3.ZERO
	nova_volume_visual.set_meta("age", 0.0)

func _show_warden_threat(report: Dictionary) -> void:
	var cast_kind: String = String(report.get("cast_kind", "ring"))
	var origin: Vector3 = report.get("origin_world", Vector3.ZERO)
	if cast_kind == "fan":
		if warden_ring_visual != null:
			warden_ring_visual.visible = false
		var endpoints_value: Variant = report.get("lane_endpoints", [])
		if not (endpoints_value is Array):
			return
		var endpoints: Array = endpoints_value
		for index in range(warden_lane_visuals.size()):
			var lane: Node3D = warden_lane_visuals[index] as Node3D
			if lane == null:
				continue
			if index >= endpoints.size():
				lane.visible = false
				continue
			var endpoint: Vector3 = endpoints[index]
			var vector: Vector3 = endpoint - origin
			vector.y = 0.0
			var length: float = vector.length()
			if length <= 0.001:
				lane.visible = false
				continue
			lane.visible = true
			lane.position = origin + vector * 0.5
			lane.position.y = 0.0
			lane.rotation = Vector3(0.0, atan2(vector.x, vector.z), 0.0)
			lane.scale = Vector3(0.34, 1.0, length)
			lane.set_meta("age", 0.0)
	else:
		for lane_value in warden_lane_visuals:
			var lane: Node3D = lane_value as Node3D
			if lane != null:
				lane.visible = false
		if warden_ring_visual != null:
			warden_ring_visual.visible = true
			warden_ring_visual.position = Vector3(origin.x, 0.0, origin.z)
			warden_ring_visual.scale = Vector3(1.35 if bool(report.get("phase2", false)) else 1.05, 1.0, 1.35 if bool(report.get("phase2", false)) else 1.05)
			warden_ring_visual.rotation = Vector3.ZERO
			warden_ring_visual.set_meta("age", 0.0)

func _animate_combat_core_feedback(delta: float) -> void:
	for value in target_lock_pool:
		var item: Node3D = value as Node3D
		if item == null or not item.visible:
			continue
		var age: float = float(item.get_meta("age", 0.0)) + delta
		item.set_meta("age", age)
		if age >= TARGET_LOCK_DURATION:
			item.visible = false
			continue
		var t: float = clampf(age / TARGET_LOCK_DURATION, 0.0, 1.0)
		item.rotation.y += delta * 9.0
		item.scale = Vector3.ONE * lerpf(0.78, 1.18, t)

	if nova_volume_visual != null and nova_volume_visual.visible:
		var age: float = float(nova_volume_visual.get_meta("age", 0.0)) + delta
		nova_volume_visual.set_meta("age", age)
		if age >= NOVA_VOLUME_DURATION:
			nova_volume_visual.visible = false
		else:
			nova_volume_visual.rotation.y += delta * 2.8

	for value in warden_lane_visuals:
		var lane: Node3D = value as Node3D
		if lane == null or not lane.visible:
			continue
		var age: float = float(lane.get_meta("age", 0.0)) + delta
		lane.set_meta("age", age)
		if age >= WARDEN_THREAT_DURATION:
			lane.visible = false
			continue
		var t: float = clampf(age / WARDEN_THREAT_DURATION, 0.0, 1.0)
		lane.position.y = 0.015 + sin(t * PI) * 0.02

	if warden_ring_visual != null and warden_ring_visual.visible:
		var age: float = float(warden_ring_visual.get_meta("age", 0.0)) + delta
		warden_ring_visual.set_meta("age", age)
		if age >= WARDEN_THREAT_DURATION:
			warden_ring_visual.visible = false
		else:
			warden_ring_visual.rotation.y += delta * 2.2

func _hide_combat_core_feedback() -> void:
	for value in target_lock_pool:
		var item: Node3D = value as Node3D
		if item != null:
			item.visible = false
	if nova_volume_visual != null:
		nova_volume_visual.visible = false
	for value in warden_lane_visuals:
		var lane: Node3D = value as Node3D
		if lane != null:
			lane.visible = false
	if warden_ring_visual != null:
		warden_ring_visual.visible = false
