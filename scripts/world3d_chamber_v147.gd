extends "res://scripts/world3d_chamber_v146.gd"

# ONE MORE FLOOR v1.47 — actor production pipeline.
# Keeps the complete v1.46 production vertical slice and swaps in the stronger
# actor factory: production sockets/animation contract, richer native fallback
# silhouettes and a lightweight weapon-arc trail. Gameplay authority stays in
# the existing runtime.

const ActorProductionFactory = preload("res://scripts/world3d_actor_factory_v147.gd")
const WEAPON_TRAIL_SEGMENTS := 7
const WEAPON_TRAIL_SAMPLE_DISTANCE := 0.035

var actor_production_root: Node3D
var weapon_trail_root: Node3D
var weapon_trail_pool: Array = []
var weapon_trail_history: Array = []
var weapon_trail_material: StandardMaterial3D
var last_enemy_visible: Array = []
var last_enemy_kinds: Array = []

func _ready() -> void:
	super._ready()
	_build_actor_production_presentation()
	_capture_enemy_state()

func _process(delta: float) -> void:
	super._process(delta)
	if not actor_production_ready():
		return
	_animate_weapon_trail(delta)

# v1.42 originally swaps its own rig-aware factory inside _build_player().
# Override the build point directly so every actor shell created afterwards uses
# the v1.47 production factory while preserving the exact same world hierarchy.
func _build_player() -> void:
	actor_factory = ActorProductionFactory.new()
	player_root = actor_factory.create_player(actor_materials)
	add_child(player_root)

func actor_production_ready() -> bool:
	if not production_slice_ready():
		return false
	if actor_factory == null or not actor_factory.has_method("actor_production_ready"):
		return false
	if not bool(actor_factory.call("actor_production_ready", player_root)):
		return false
	# Enemy shells exist before they receive their first runtime kind. At startup
	# they only need the stable production socket contract; configure_enemy()
	# upgrades the rig/model mount the first time a real enemy occupies a slot.
	for enemy_value in enemy_pool:
		var enemy: Node3D = enemy_value as Node3D
		if enemy == null or not bool(enemy.get_meta("actor_pipeline_v147", false)):
			return false
		if enemy.get_node_or_null("ProductionSockets") == null:
			return false
	return actor_production_root != null and weapon_trail_pool.size() == WEAPON_TRAIL_SEGMENTS

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["actor_production_ready"] = actor_production_ready()
	data["weapon_trail_segments"] = weapon_trail_pool.size()
	data["weapon_trail_samples"] = weapon_trail_history.size()
	if actor_factory != null and actor_factory.has_method("production_registry_snapshot"):
		var registry: Dictionary = actor_factory.call("production_registry_snapshot")
		data["production_model_profiles"] = int(registry.get("production_profiles", 0))
		data["production_model_ready_count"] = int(registry.get("production_ready_count", 0))
	if player_root != null:
		data["player_actor_source"] = String(player_root.get_meta("model_source", ""))
		data["player_animation_state"] = String(player_root.get_meta("production_animation_state", ""))
	return data

func sync_runtime(
	player_pos: Vector2,
	enemies: Array,
	player_shots: Array,
	enemy_shots: Array,
	coins: Array,
	joy: Vector2,
	elapsed_value: float,
	attack_flash: float,
	skill_flash: float,
	floor_no: int
) -> void:
	super.sync_runtime(
		player_pos, enemies, player_shots, enemy_shots, coins, joy,
		elapsed_value, attack_flash, skill_flash, floor_no
	)
	if not actor_production_ready():
		return
	_update_weapon_trail(attack_flash > 0.0 or skill_flash > 0.0 or attack_amount > 0.03 or skill_amount > 0.03, skill_flash > 0.0 or skill_amount > 0.06)

func _sync_enemies(enemies: Array, player_world: Vector3) -> void:
	var before_visible: Array = []
	var before_kind: Array = []
	for enemy_value in enemy_pool:
		var proxy := enemy_value as Node3D
		before_visible.append(proxy.visible if proxy != null else false)
		before_kind.append(String(proxy.get_meta("actor_kind", "")) if proxy != null else "")

	super._sync_enemies(enemies, player_world)

	if actor_factory == null or not actor_factory.has_method("queue_one_shot"):
		return
	for index in range(enemy_pool.size()):
		var proxy := enemy_pool[index] as Node3D
		if proxy == null or not proxy.visible:
			continue
		var was_visible: bool = bool(before_visible[index]) if index < before_visible.size() else false
		var old_kind: String = String(before_kind[index]) if index < before_kind.size() else ""
		var new_kind: String = String(proxy.get_meta("actor_kind", ""))
		if not was_visible or old_kind != new_kind:
			actor_factory.call("queue_one_shot", proxy, "spawn", runtime_elapsed, 0.48)
	_capture_enemy_state()

func actor_socket_snapshot(root: Node3D) -> Dictionary:
	if actor_factory == null or not actor_factory.has_method("socket_contract_snapshot"):
		return {}
	return actor_factory.call("socket_contract_snapshot", root)

func production_registry_snapshot() -> Dictionary:
	if actor_factory == null or not actor_factory.has_method("production_registry_snapshot"):
		return {}
	return actor_factory.call("production_registry_snapshot")

func _build_actor_production_presentation() -> void:
	actor_production_root = Node3D.new()
	actor_production_root.name = "ActorProductionPresentation"
	add_child(actor_production_root)

	weapon_trail_root = Node3D.new()
	weapon_trail_root.name = "WandererWeaponTrail"
	actor_production_root.add_child(weapon_trail_root)
	weapon_trail_material = _transparent_emissive(Color(0.78, 0.49, 1.0, 0.38), 2.75)
	for index in range(WEAPON_TRAIL_SEGMENTS):
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.052, 0.045, 0.36)
		var segment := MeshInstance3D.new()
		segment.name = "WeaponArc%02d" % index
		segment.mesh = mesh
		segment.material_override = weapon_trail_material
		segment.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		segment.visible = false
		segment.set_meta("fade", 0.0)
		weapon_trail_root.add_child(segment)
		weapon_trail_pool.append(segment)

func _update_weapon_trail(active: bool, skill_active: bool) -> void:
	if player_root == null or actor_factory == null or not actor_factory.has_method("actor_socket"):
		_hide_weapon_trail()
		return
	if not active:
		weapon_trail_history.clear()
		_hide_weapon_trail()
		return
	var socket: Node3D = actor_factory.call("actor_socket", player_root, "weapon") as Node3D
	if socket == null:
		_hide_weapon_trail()
		return
	var tip: Vector3 = socket.to_global(Vector3(0.0, 0.0, -0.62))
	if weapon_trail_history.is_empty() or tip.distance_to(weapon_trail_history[weapon_trail_history.size() - 1]) >= WEAPON_TRAIL_SAMPLE_DISTANCE:
		weapon_trail_history.append(tip)
	while weapon_trail_history.size() > WEAPON_TRAIL_SEGMENTS + 1:
		weapon_trail_history.pop_front()

	for index in range(weapon_trail_pool.size()):
		var segment := weapon_trail_pool[index] as MeshInstance3D
		if index + 1 >= weapon_trail_history.size():
			segment.visible = false
			continue
		var a: Vector3 = weapon_trail_history[index]
		var b: Vector3 = weapon_trail_history[index + 1]
		var distance: float = a.distance_to(b)
		if distance <= 0.004:
			segment.visible = false
			continue
		segment.visible = true
		segment.global_position = (a + b) * 0.5
		segment.scale = Vector3(1.35 if skill_active else 1.0, 1.0, clampf(distance / 0.36, 0.18, 1.8))
		segment.look_at(b, Vector3.UP)
		segment.set_meta("fade", 1.0)

func _animate_weapon_trail(delta: float) -> void:
	for segment_value in weapon_trail_pool:
		var segment := segment_value as MeshInstance3D
		if segment == null or not segment.visible:
			continue
		var fade: float = maxf(0.0, float(segment.get_meta("fade", 0.0)) - delta * 4.6)
		segment.set_meta("fade", fade)
		if fade <= 0.0 and weapon_trail_history.is_empty():
			segment.visible = false

func _hide_weapon_trail() -> void:
	for segment_value in weapon_trail_pool:
		var segment := segment_value as MeshInstance3D
		if segment != null:
			segment.visible = false

func _capture_enemy_state() -> void:
	last_enemy_visible.clear()
	last_enemy_kinds.clear()
	for enemy_value in enemy_pool:
		var proxy := enemy_value as Node3D
		last_enemy_visible.append(proxy.visible if proxy != null else false)
		last_enemy_kinds.append(String(proxy.get_meta("actor_kind", "")) if proxy != null else "")
