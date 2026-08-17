extends "res://scripts/world3d_chamber_v148.gd"

# ONE MORE FLOOR v1.49 — Production Art & Lookdev Pass.
# Keeps all v1.48 combat presentation and swaps in the richer production-art
# actor factory. Adds realm-adaptive lighting, actor grounding, pooled hit shards,
# movement echoes and a boss dominance layer. Visual only; gameplay stays legacy.

const ProductionArtFactory = preload("res://scripts/world3d_actor_factory_v149.gd")
const HIT_BURST_POOL_SIZE := 14
const HIT_BURST_DURATION := 0.34
const MOVE_ECHO_POOL_SIZE := 6
const MOVE_ECHO_DURATION := 0.42
const ENEMY_GROUNDING_SLOTS := 18

var lookdev_root: Node3D
var grounding_root: Node3D
var hit_burst_root: Node3D
var move_echo_root: Node3D
var boss_dominance_root: Node3D
var player_rim_light: OmniLight3D
var player_fill_light: OmniLight3D
var boss_dominance_light: OmniLight3D
var boss_dominance_ring_outer: MeshInstance3D
var boss_dominance_ring_inner: MeshInstance3D
var enemy_grounding_pool: Array = []
var hit_burst_pool: Array = []
var move_echo_pool: Array = []
var last_hit_active: Array = []
var last_player_echo_position := Vector3(9999.0, 9999.0, 9999.0)
var move_echo_cursor := 0
var current_lookdev_realm := ""
var grounding_materials: Dictionary = {}
var realm_rim_colors: Dictionary = {}
var realm_fill_colors: Dictionary = {}

func _ready() -> void:
	super._ready()
	_build_production_lookdev()
	_reset_hit_state()

func _process(delta: float) -> void:
	super._process(delta)
	if not production_art_lookdev_ready():
		return
	_animate_hit_bursts(delta)
	_animate_move_echoes(delta)
	_animate_boss_dominance()
	_update_player_lighting()

# v1.48 owns the build hook. Replace only its factory; hierarchy and runtime
# synchronization contract stay exactly the same.
func _build_player() -> void:
	actor_factory = ProductionArtFactory.new()
	player_root = actor_factory.create_player(actor_materials)
	add_child(player_root)

func production_art_lookdev_ready() -> bool:
	return character_combat_vfx_ready() \
		and actor_factory != null \
		and actor_factory.has_method("production_art_ready") \
		and bool(actor_factory.call("production_art_ready", player_root)) \
		and lookdev_root != null \
		and enemy_grounding_pool.size() == ENEMY_GROUNDING_SLOTS \
		and hit_burst_pool.size() == HIT_BURST_POOL_SIZE \
		and move_echo_pool.size() == MOVE_ECHO_POOL_SIZE \
		and player_rim_light != null \
		and boss_dominance_root != null

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_art_lookdev_ready"] = production_art_lookdev_ready()
	data["grounding_slots"] = enemy_grounding_pool.size()
	data["hit_burst_pool"] = hit_burst_pool.size()
	data["move_echo_pool"] = move_echo_pool.size()
	data["lookdev_realm"] = current_lookdev_realm
	data["boss_dominance"] = boss_dominance_root != null and boss_dominance_root.visible
	if actor_factory != null and actor_factory.has_method("asset_quality_snapshot"):
		data["asset_quality"] = actor_factory.call("asset_quality_snapshot")
	if actor_factory != null and actor_factory.has_method("production_asset_report"):
		data["player_asset_report"] = actor_factory.call("production_asset_report", player_root)
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
	if not production_art_lookdev_ready():
		return
	_apply_realm_lookdev(floor_no)
	_sync_actor_grounding(enemies)
	_sync_hit_bursts(enemies)
	_sync_player_move_echo(joy)
	_sync_boss_dominance(enemies, floor_no)

func _build_production_lookdev() -> void:
	_build_lookdev_materials()
	lookdev_root = Node3D.new()
	lookdev_root.name = "ProductionArtLookdev"
	add_child(lookdev_root)

	grounding_root = Node3D.new()
	grounding_root.name = "ActorGrounding"
	lookdev_root.add_child(grounding_root)
	for index in range(ENEMY_GROUNDING_SLOTS):
		var ring: MeshInstance3D = _make_ring(grounding_root, "EnemyGround%02d" % index, 0.48, grounding_materials["enemy"], 24)
		ring.visible = false
		ring.position.y = 0.025
		enemy_grounding_pool.append(ring)

	player_rim_light = OmniLight3D.new()
	player_rim_light.name = "WandererRim"
	player_rim_light.light_color = Color("b87cff")
	player_rim_light.light_energy = 1.05
	player_rim_light.omni_range = 3.15
	player_rim_light.shadow_enabled = false
	lookdev_root.add_child(player_rim_light)

	player_fill_light = OmniLight3D.new()
	player_fill_light.name = "WandererFill"
	player_fill_light.light_color = Color("ffd17a")
	player_fill_light.light_energy = 0.42
	player_fill_light.omni_range = 2.55
	player_fill_light.shadow_enabled = false
	lookdev_root.add_child(player_fill_light)

	hit_burst_root = Node3D.new()
	hit_burst_root.name = "ActorHitShards"
	lookdev_root.add_child(hit_burst_root)
	for index in range(HIT_BURST_POOL_SIZE):
		var burst: Node3D = _build_hit_burst(index)
		hit_burst_root.add_child(burst)
		hit_burst_pool.append(burst)

	move_echo_root = Node3D.new()
	move_echo_root.name = "WandererMotionEcho"
	lookdev_root.add_child(move_echo_root)
	for index in range(MOVE_ECHO_POOL_SIZE):
		var echo := Node3D.new()
		echo.name = "MoveEcho%02d" % index
		echo.visible = false
		echo.set_meta("age", MOVE_ECHO_DURATION + 1.0)
		move_echo_root.add_child(echo)
		var ring: MeshInstance3D = _make_ring(echo, "Ring", 0.34, grounding_materials["wanderer"], 24)
		ring.position.y = 0.035
		for shard_index in range(3):
			var angle: float = TAU * float(shard_index) / 3.0
			var shard: MeshInstance3D = _make_box(echo, "Rune%d" % shard_index, Vector3(0.05, 0.04, 0.18), grounding_materials["wanderer"])
			shard.position = Vector3(cos(angle) * 0.28, 0.06, sin(angle) * 0.28)
			shard.rotation.y = angle
		move_echo_pool.append(echo)

	boss_dominance_root = Node3D.new()
	boss_dominance_root.name = "BossDominanceLookdev"
	boss_dominance_root.visible = false
	lookdev_root.add_child(boss_dominance_root)
	boss_dominance_ring_outer = _make_ring(boss_dominance_root, "DominanceOuter", 1.28, grounding_materials["warden"], 36)
	boss_dominance_ring_outer.position.y = 0.045
	boss_dominance_ring_inner = _make_ring(boss_dominance_root, "DominanceInner", 0.82, grounding_materials["warden"], 32)
	boss_dominance_ring_inner.position.y = 0.055
	for index in range(8):
		var angle: float = TAU * float(index) / 8.0
		var marker: MeshInstance3D = _make_box(boss_dominance_root, "DominanceMark%d" % index, Vector3(0.08, 0.05, 0.34), grounding_materials["warden"])
		marker.position = Vector3(cos(angle) * 1.02, 0.07, sin(angle) * 1.02)
		marker.rotation.y = -angle
	boss_dominance_light = OmniLight3D.new()
	boss_dominance_light.name = "BossDominanceLight"
	boss_dominance_light.position = Vector3(0.0, 1.25, 0.0)
	boss_dominance_light.light_color = Color("ff6656")
	boss_dominance_light.light_energy = 0.0
	boss_dominance_light.omni_range = 4.4
	boss_dominance_light.shadow_enabled = false
	boss_dominance_root.add_child(boss_dominance_light)

func _build_lookdev_materials() -> void:
	realm_rim_colors = {
		"lower_halls": Color("c58cff"),
		"ossuary": Color("65e8df"),
		"iron_bastion": Color("ff9a52"),
		"rift_descent": Color("dc65ff"),
		"starless_spire": Color("81a8ff"),
	}
	realm_fill_colors = {
		"lower_halls": Color("ffd178"),
		"ossuary": Color("b7fff3"),
		"iron_bastion": Color("ffc16d"),
		"rift_descent": Color("89e9ff"),
		"starless_spire": Color("d9e0ff"),
	}
	grounding_materials = {
		"wanderer": _transparent_emissive(Color(0.72, 0.43, 1.0, 0.14), 0.72),
		"goblin": _transparent_emissive(Color(0.72, 1.0, 0.32, 0.11), 0.55),
		"bat": _transparent_emissive(Color(0.70, 0.39, 1.0, 0.11), 0.58),
		"skeleton": _transparent_emissive(Color(1.0, 0.90, 0.66, 0.11), 0.52),
		"ghoul": _transparent_emissive(Color(0.39, 1.0, 0.58, 0.11), 0.56),
		"necromancer": _transparent_emissive(Color(0.63, 0.30, 1.0, 0.13), 0.66),
		"warden": _transparent_emissive(Color(1.0, 0.28, 0.22, 0.16), 0.86),
		"enemy": _transparent_emissive(Color(1.0, 0.46, 0.36, 0.10), 0.48),
	}

func _build_hit_burst(index: int) -> Node3D:
	var root := Node3D.new()
	root.name = "HitShard%02d" % index
	root.visible = false
	root.set_meta("age", HIT_BURST_DURATION + 1.0)
	root.set_meta("kind", "enemy")
	var default_material: Material = grounding_materials["enemy"]
	for shard_index in range(5):
		var shard: MeshInstance3D = _make_box(root, "Shard%d" % shard_index, Vector3(0.055, 0.16, 0.055), default_material)
		var angle: float = TAU * float(shard_index) / 5.0
		shard.position = Vector3(cos(angle) * 0.12, 0.10 + float(shard_index % 2) * 0.04, sin(angle) * 0.12)
		shard.rotation = Vector3(angle * 0.25, angle, -angle * 0.18)
	var core: MeshInstance3D = _make_sphere(root, "Core", 0.09, default_material)
	core.position.y = 0.14
	return root

func _apply_realm_lookdev(floor_no: int) -> void:
	var realm: String = _realm_for_floor_v149(floor_no)
	if realm == current_lookdev_realm:
		return
	current_lookdev_realm = realm
	var rim_color: Color = realm_rim_colors.get(realm, Color("c58cff"))
	var fill_color: Color = realm_fill_colors.get(realm, Color("ffd178"))
	player_rim_light.light_color = rim_color
	player_fill_light.light_color = fill_color
	if player_combat_light != null:
		player_combat_light.light_color = rim_color
	# Re-grade ambient light without expensive post-process or volumetrics.
	var world_environment := get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_environment != null and world_environment.environment != null:
		world_environment.environment.ambient_light_color = fill_color.lerp(rim_color, 0.58)
		world_environment.environment.ambient_light_energy = 0.30 if realm == "starless_spire" else 0.34

func _realm_for_floor_v149(floor_no: int) -> String:
	if floor_no >= 41:
		return "starless_spire"
	if floor_no >= 31:
		return "rift_descent"
	if floor_no >= 21:
		return "iron_bastion"
	if floor_no >= 11:
		return "ossuary"
	return "lower_halls"

func _sync_actor_grounding(enemies: Array) -> void:
	for index in range(enemy_grounding_pool.size()):
		var ring: MeshInstance3D = enemy_grounding_pool[index] as MeshInstance3D
		if ring == null:
			continue
		if index >= enemies.size() or index >= enemy_pool.size():
			ring.visible = false
			continue
		var proxy := enemy_pool[index] as Node3D
		if proxy == null or not proxy.visible:
			ring.visible = false
			continue
		var enemy: Dictionary = enemies[index]
		var kind: String = _visual_enemy_kind(enemy)
		var tell: float = _enemy_tell(enemy)
		var elite: bool = bool(enemy.get("elite", false)) or kind == "warden"
		ring.visible = elite or tell > 0.10 or kind == "necromancer"
		if not ring.visible:
			continue
		var feet_socket: Node3D = actor_factory.call("actor_socket", proxy, "feet") as Node3D
		ring.global_position = (feet_socket.global_position if feet_socket != null else proxy.global_position) + Vector3(0.0, 0.025, 0.0)
		ring.material_override = grounding_materials.get(kind, grounding_materials["enemy"])
		var radius: float = float(enemy.get("radius", 24.0))
		var base_scale: float = clampf(radius / 24.0, 0.76, 1.72)
		var pulse: float = 0.94 + tell * 0.22 + sin(runtime_elapsed * 5.4 + float(index) * 0.44) * 0.035
		ring.scale = Vector3(base_scale * pulse, 1.0, base_scale * pulse)
		ring.rotation.y = runtime_elapsed * (0.26 if kind == "warden" else 0.12)

func _sync_hit_bursts(enemies: Array) -> void:
	while last_hit_active.size() < ENEMY_GROUNDING_SLOTS:
		last_hit_active.append(false)
	for index in range(ENEMY_GROUNDING_SLOTS):
		var hit_active := false
		var kind := "enemy"
		var hit_position := Vector3.ZERO
		if index < enemies.size() and index < enemy_pool.size():
			var enemy: Dictionary = enemies[index]
			var hit_age: float = runtime_elapsed - float(enemy.get("v47_hit_stamp", -99.0))
			hit_active = hit_age >= 0.0 and hit_age < 0.16
			kind = _visual_enemy_kind(enemy)
			var proxy := enemy_pool[index] as Node3D
			if proxy != null:
				var chest_socket: Node3D = actor_factory.call("actor_socket", proxy, "chest") as Node3D
				hit_position = chest_socket.global_position if chest_socket != null else proxy.global_position + Vector3(0.0, 0.75, 0.0)
		var previous: bool = bool(last_hit_active[index])
		if hit_active and not previous:
			_spawn_hit_burst(hit_position, kind)
		last_hit_active[index] = hit_active

func _spawn_hit_burst(position: Vector3, kind: String) -> void:
	var selected: Node3D = null
	for burst_value in hit_burst_pool:
		var burst := burst_value as Node3D
		if burst != null and not burst.visible:
			selected = burst
			break
	if selected == null and not hit_burst_pool.is_empty():
		selected = hit_burst_pool[0] as Node3D
	if selected == null:
		return
	selected.visible = true
	selected.global_position = position
	selected.scale = Vector3.ONE
	selected.rotation = Vector3.ZERO
	selected.set_meta("age", 0.0)
	selected.set_meta("kind", kind)
	_apply_material_recursive(selected, grounding_materials.get(kind, grounding_materials["enemy"]))

func _animate_hit_bursts(delta: float) -> void:
	for burst_value in hit_burst_pool:
		var burst := burst_value as Node3D
		if burst == null or not burst.visible:
			continue
		var age: float = float(burst.get_meta("age", 0.0)) + delta
		burst.set_meta("age", age)
		if age >= HIT_BURST_DURATION:
			burst.visible = false
			continue
		var t: float = clampf(age / HIT_BURST_DURATION, 0.0, 1.0)
		var outward: float = 0.70 + t * 2.25
		burst.scale = Vector3(outward, 0.82 + t * 1.35, outward)
		burst.position.y += delta * 0.58
		burst.rotation.y += delta * 4.8

func _sync_player_move_echo(joy: Vector2) -> void:
	if player_root == null or joy.length_squared() < 0.20:
		return
	var feet_socket: Node3D = actor_factory.call("actor_socket", player_root, "feet") as Node3D
	var current_position: Vector3 = feet_socket.global_position if feet_socket != null else player_root.global_position
	if last_player_echo_position.x > 9000.0:
		last_player_echo_position = current_position
		return
	if current_position.distance_to(last_player_echo_position) < 0.48:
		return
	last_player_echo_position = current_position
	var echo := move_echo_pool[move_echo_cursor % move_echo_pool.size()] as Node3D
	move_echo_cursor = (move_echo_cursor + 1) % move_echo_pool.size()
	if echo == null:
		return
	echo.visible = true
	echo.global_position = current_position + Vector3(0.0, 0.02, 0.0)
	echo.scale = Vector3.ONE
	echo.rotation = Vector3.ZERO
	echo.set_meta("age", 0.0)

func _animate_move_echoes(delta: float) -> void:
	for echo_value in move_echo_pool:
		var echo := echo_value as Node3D
		if echo == null or not echo.visible:
			continue
		var age: float = float(echo.get_meta("age", 0.0)) + delta
		echo.set_meta("age", age)
		if age >= MOVE_ECHO_DURATION:
			echo.visible = false
			continue
		var t: float = clampf(age / MOVE_ECHO_DURATION, 0.0, 1.0)
		var scale_value: float = 0.72 + t * 1.15
		echo.scale = Vector3(scale_value, 1.0, scale_value)
		echo.rotation.y += delta * 1.8
		echo.position.y += delta * 0.05

func _sync_boss_dominance(enemies: Array, floor_no: int) -> void:
	if boss_dominance_root == null:
		return
	if floor_no % 10 != 0:
		boss_dominance_root.visible = false
		return
	var best_index := -1
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index]
		if String(enemy.get("type", "")) == "warden":
			best_index = index
			break
	if best_index < 0 or best_index >= enemy_pool.size():
		boss_dominance_root.visible = false
		return
	var proxy := enemy_pool[best_index] as Node3D
	if proxy == null or not proxy.visible:
		boss_dominance_root.visible = false
		return
	var feet_socket: Node3D = actor_factory.call("actor_socket", proxy, "feet") as Node3D
	boss_dominance_root.visible = true
	boss_dominance_root.global_position = feet_socket.global_position if feet_socket != null else proxy.global_position

func _animate_boss_dominance() -> void:
	if boss_dominance_root == null or not boss_dominance_root.visible:
		if boss_dominance_light != null:
			boss_dominance_light.light_energy = 0.0
		return
	var pulse: float = 1.0 + sin(runtime_elapsed * 3.8) * 0.075
	if boss_dominance_ring_outer != null:
		boss_dominance_ring_outer.scale = Vector3(pulse, 1.0, pulse)
		boss_dominance_ring_outer.rotation.y = runtime_elapsed * 0.54
	if boss_dominance_ring_inner != null:
		boss_dominance_ring_inner.scale = Vector3(1.12 - pulse * 0.10, 1.0, 1.12 - pulse * 0.10)
		boss_dominance_ring_inner.rotation.y = -runtime_elapsed * 0.82
	boss_dominance_root.rotation.y = sin(runtime_elapsed * 1.2) * 0.04
	if boss_dominance_light != null:
		boss_dominance_light.light_energy = 0.92 + sin(runtime_elapsed * 4.6) * 0.16

func _update_player_lighting() -> void:
	if player_root == null or player_rim_light == null or player_fill_light == null:
		return
	var chest_socket: Node3D = actor_factory.call("actor_socket", player_root, "chest") as Node3D
	var target: Vector3 = chest_socket.global_position if chest_socket != null else player_root.global_position + Vector3(0.0, 0.9, 0.0)
	player_rim_light.global_position = target + Vector3(-0.82, 0.86, 0.48)
	player_fill_light.global_position = target + Vector3(0.68, 0.42, -0.36)
	player_rim_light.light_energy = 0.82 + move_amount * 0.15 + attack_amount * 0.28 + skill_amount * 0.62
	player_fill_light.light_energy = 0.34 + attack_amount * 0.18 + skill_amount * 0.26

func _reset_hit_state() -> void:
	last_hit_active.clear()
	for _index in range(ENEMY_GROUNDING_SLOTS):
		last_hit_active.append(false)
