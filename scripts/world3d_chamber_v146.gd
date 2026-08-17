extends "res://scripts/world3d_chamber_v145.gd"

# ONE MORE FLOOR v1.46 - Production vertical slice.
# Adds camera choreography, realm-transition spectacle, boss framing, combat
# telegraphs, death feedback and loot presentation on top of the complete
# five-realm 3D tower. Gameplay/runtime authority remains unchanged.

const MAX_PRESENTATION_TELLS := 18
const MAX_DEATH_BURSTS := 12
const MAX_LOOT_MARKERS := 24
const TRANSITION_LONG := 1.05
const TRANSITION_SHORT := 0.34
const BOSS_INTRO_DURATION := 1.35
const DEATH_BURST_DURATION := 0.42

var production_slice_root: Node3D
var telegraph_root: Node3D
var death_feedback_root: Node3D
var loot_root: Node3D
var transition_root: Node3D
var boss_root: Node3D
var player_feedback_root: Node3D

var telegraph_pool: Array = []
var death_burst_pool: Array = []
var loot_marker_pool: Array = []
var previous_enemy_positions: Array = []
var previous_coin_positions: Array = []

var transition_disc: MeshInstance3D
var transition_crown: MeshInstance3D
var transition_light: OmniLight3D
var boss_halo: MeshInstance3D
var boss_beam: MeshInstance3D
var boss_crown: Node3D
var boss_light: OmniLight3D
var attack_ring: MeshInstance3D
var skill_ring_outer: MeshInstance3D
var skill_ring_inner: MeshInstance3D

var transition_materials: Dictionary = {}
var telegraph_normal_material: StandardMaterial3D
var telegraph_elite_material: StandardMaterial3D
var death_material: StandardMaterial3D
var loot_material: StandardMaterial3D
var boss_material: StandardMaterial3D
var attack_material: StandardMaterial3D
var skill_material: StandardMaterial3D

var presentation_floor := -1
var transition_timer := 0.0
var transition_duration := TRANSITION_SHORT
var boss_intro_timer := 0.0
var camera_kick := 0.0
var camera_base_position := Vector3.ZERO
var camera_base_size := 15.8
var camera_focus := Vector3(0.0, 0.0, -0.25)

func _ready() -> void:
	super._ready()
	if camera != null:
		camera_base_position = camera.position
		camera_base_size = camera.size
	_build_production_materials()
	_build_production_slice()

func _process(delta: float) -> void:
	super._process(delta)
	if production_slice_root == null:
		return
	transition_timer = maxf(0.0, transition_timer - delta)
	boss_intro_timer = maxf(0.0, boss_intro_timer - delta)
	camera_kick = maxf(0.0, camera_kick - delta * 3.9)
	_animate_camera(delta)
	_animate_transition()
	_animate_boss_frame()
	_animate_death_bursts(delta)
	_animate_loot_markers()
	_animate_player_feedback()

func production_slice_ready() -> bool:
	return full_tower_ready() \
		and production_slice_root != null \
		and telegraph_pool.size() == MAX_PRESENTATION_TELLS \
		and death_burst_pool.size() == MAX_DEATH_BURSTS \
		and loot_marker_pool.size() == MAX_LOOT_MARKERS \
		and transition_root != null \
		and boss_root != null \
		and player_feedback_root != null

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_slice_ready"] = production_slice_ready()
	data["presentation_floor"] = presentation_floor
	data["transition_active"] = transition_timer > 0.0
	data["boss_frame_active"] = boss_root != null and boss_root.visible
	data["telegraph_pool"] = telegraph_pool.size()
	data["death_burst_pool"] = death_burst_pool.size()
	data["loot_marker_pool"] = loot_marker_pool.size()
	data["camera_size"] = camera.size if camera != null else -1.0
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
	if not production_slice_ready():
		return

	if attack_flash > 0.0:
		camera_kick = maxf(camera_kick, 0.28)
	if skill_flash > 0.0:
		camera_kick = maxf(camera_kick, 0.72)

	_sync_ground_telegraphs(enemies)
	_sync_death_feedback(enemies)
	_sync_loot_presentation(coins)
	_sync_boss_presentation(enemies, floor_no)
	if player_feedback_root != null and player_root != null:
		player_feedback_root.position = player_root.position

func _apply_floor_identity(floor_no: int) -> void:
	super._apply_floor_identity(floor_no)
	if floor_no == presentation_floor:
		return
	var previous_floor: int = presentation_floor
	presentation_floor = floor_no
	var realm_boundary: bool = floor_no == 1 or floor_no == 11 or floor_no == 21 or floor_no == 31 or floor_no == 41
	transition_duration = TRANSITION_LONG if realm_boundary else TRANSITION_SHORT
	transition_timer = transition_duration
	if floor_no % 10 == 0:
		boss_intro_timer = BOSS_INTRO_DURATION
		camera_kick = maxf(camera_kick, 0.55)
	elif previous_floor > 0 and realm_boundary:
		camera_kick = maxf(camera_kick, 0.42)
	_apply_transition_material(floor_no)

func _build_production_materials() -> void:
	transition_materials = {
		"lower_halls": _transparent_emissive(Color(1.0, 0.72, 0.30, 0.24), 2.0),
		"ossuary": _transparent_emissive(Color(0.25, 0.95, 0.82, 0.22), 2.0),
		"iron_bastion": _transparent_emissive(Color(1.0, 0.34, 0.12, 0.24), 2.1),
		"rift_descent": _transparent_emissive(Color(0.70, 0.27, 1.0, 0.24), 2.2),
		"starless_spire": _transparent_emissive(Color(0.54, 0.68, 1.0, 0.22), 2.2),
	}
	telegraph_normal_material = _transparent_emissive(Color(1.0, 0.25, 0.20, 0.30), 2.15)
	telegraph_elite_material = _transparent_emissive(Color(1.0, 0.62, 0.16, 0.34), 2.30)
	death_material = _transparent_emissive(Color(0.78, 0.50, 1.0, 0.34), 2.35)
	loot_material = _transparent_emissive(Color(1.0, 0.78, 0.25, 0.30), 2.45)
	boss_material = _transparent_emissive(Color(1.0, 0.35, 0.22, 0.28), 2.60)
	attack_material = _transparent_emissive(Color(1.0, 0.82, 0.35, 0.26), 2.25)
	skill_material = _transparent_emissive(Color(0.67, 0.36, 1.0, 0.30), 2.55)

func _build_production_slice() -> void:
	production_slice_root = Node3D.new()
	production_slice_root.name = "ProductionVerticalSlice"
	add_child(production_slice_root)

	_build_ground_telegraphs()
	_build_death_feedback()
	_build_loot_markers()
	_build_realm_transition()
	_build_boss_frame()
	_build_player_feedback()

func _build_ground_telegraphs() -> void:
	telegraph_root = Node3D.new()
	telegraph_root.name = "CombatTelegraphs"
	production_slice_root.add_child(telegraph_root)
	for index in range(MAX_PRESENTATION_TELLS):
		var tell: MeshInstance3D = _add_cylinder_local(
			telegraph_root, "Telegraph%02d" % index,
			0.70, 0.70, 0.018, Vector3.ZERO, telegraph_normal_material, 32
		)
		tell.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		tell.visible = false
		telegraph_pool.append(tell)

func _build_death_feedback() -> void:
	death_feedback_root = Node3D.new()
	death_feedback_root.name = "DeathFeedback"
	production_slice_root.add_child(death_feedback_root)
	for index in range(MAX_DEATH_BURSTS):
		var burst: Node3D = Node3D.new()
		burst.name = "DeathBurst%02d" % index
		burst.visible = false
		burst.set_meta("age", DEATH_BURST_DURATION + 1.0)
		death_feedback_root.add_child(burst)
		var ring: MeshInstance3D = _add_cylinder_local(
			burst, "Ring", 0.58, 0.58, 0.022, Vector3(0.0, 0.055, 0.0), death_material, 28
		)
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for shard_index in range(4):
			var angle: float = TAU * float(shard_index) / 4.0
			var shard: MeshInstance3D = _add_box(
				burst, "Shard%d" % shard_index, Vector3(0.08, 0.34, 0.08),
				Vector3(cos(angle) * 0.24, 0.26, sin(angle) * 0.24), death_material
			)
			shard.rotation.z = angle * 0.35
			shard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		death_burst_pool.append(burst)

func _build_loot_markers() -> void:
	loot_root = Node3D.new()
	loot_root.name = "LootPresentation"
	production_slice_root.add_child(loot_root)
	for index in range(MAX_LOOT_MARKERS):
		var marker: Node3D = Node3D.new()
		marker.name = "LootMarker%02d" % index
		marker.visible = false
		loot_root.add_child(marker)
		var beam: MeshInstance3D = _add_cylinder_local(
			marker, "Beam", 0.035, 0.055, 0.82, Vector3(0.0, 0.46, 0.0), loot_material, 10
		)
		beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var ring: MeshInstance3D = _add_cylinder_local(
			marker, "FloorGlow", 0.28, 0.28, 0.016, Vector3(0.0, 0.035, 0.0), loot_material, 24
		)
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		loot_marker_pool.append(marker)

func _build_realm_transition() -> void:
	transition_root = Node3D.new()
	transition_root.name = "RealmTransition"
	transition_root.visible = false
	production_slice_root.add_child(transition_root)
	transition_disc = _add_cylinder_local(
		transition_root, "TransitionDisc", 3.75, 3.75, 0.018,
		Vector3(0.0, 0.07, 0.0), transition_materials["lower_halls"], 48
	)
	transition_disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	transition_crown = _add_cylinder_local(
		transition_root, "TransitionCrown", 1.55, 1.55, 0.026,
		Vector3(0.0, 0.10, 0.0), transition_materials["lower_halls"], 32
	)
	transition_crown.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for index in range(8):
		var angle: float = TAU * float(index) / 8.0
		var rune: MeshInstance3D = _add_box(
			transition_root, "RealmRune%d" % index, Vector3(0.12, 0.045, 0.46),
			Vector3(cos(angle) * 2.75, 0.10, sin(angle) * 2.75), transition_materials["lower_halls"]
		)
		rune.rotation.y = -angle
		rune.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	transition_light = OmniLight3D.new()
	transition_light.name = "TransitionLight"
	transition_light.position = Vector3(0.0, 1.4, 0.0)
	transition_light.light_color = Color("ffd078")
	transition_light.light_energy = 0.0
	transition_light.omni_range = 6.6
	transition_light.shadow_enabled = false
	transition_root.add_child(transition_light)

func _build_boss_frame() -> void:
	boss_root = Node3D.new()
	boss_root.name = "BossPresentation"
	boss_root.visible = false
	production_slice_root.add_child(boss_root)
	boss_halo = _add_cylinder_local(
		boss_root, "BossHalo", 1.08, 1.08, 0.022, Vector3(0.0, 0.045, 0.0), boss_material, 36
	)
	boss_halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	boss_beam = _add_cylinder_local(
		boss_root, "BossBeam", 0.10, 0.18, 2.75, Vector3(0.0, 1.45, 0.0), boss_material, 12
	)
	boss_beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	boss_crown = Node3D.new()
	boss_crown.name = "BossCrown"
	boss_crown.position = Vector3(0.0, 2.35, 0.0)
	boss_root.add_child(boss_crown)
	for index in range(4):
		var angle: float = TAU * float(index) / 4.0
		var crown_piece: MeshInstance3D = _add_box(
			boss_crown, "CrownPiece%d" % index, Vector3(0.10, 0.48, 0.10),
			Vector3(cos(angle) * 0.35, 0.0, sin(angle) * 0.35), boss_material
		)
		crown_piece.rotation.z = sin(angle) * 0.22
		crown_piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	boss_light = OmniLight3D.new()
	boss_light.name = "BossAccentLight"
	boss_light.position = Vector3(0.0, 1.35, 0.0)
	boss_light.light_color = Color("ff664f")
	boss_light.light_energy = 1.25
	boss_light.omni_range = 4.2
	boss_light.shadow_enabled = false
	boss_root.add_child(boss_light)

func _build_player_feedback() -> void:
	player_feedback_root = Node3D.new()
	player_feedback_root.name = "PlayerCombatFeedback"
	production_slice_root.add_child(player_feedback_root)
	attack_ring = _add_cylinder_local(
		player_feedback_root, "AttackPulse", 0.72, 0.72, 0.018,
		Vector3(0.0, 0.06, 0.0), attack_material, 28
	)
	attack_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	attack_ring.visible = false
	skill_ring_outer = _add_cylinder_local(
		player_feedback_root, "SkillPulseOuter", 1.22, 1.22, 0.018,
		Vector3(0.0, 0.065, 0.0), skill_material, 36
	)
	skill_ring_outer.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	skill_ring_outer.visible = false
	skill_ring_inner = _add_cylinder_local(
		player_feedback_root, "SkillPulseInner", 0.58, 0.58, 0.024,
		Vector3(0.0, 0.08, 0.0), skill_material, 28
	)
	skill_ring_inner.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	skill_ring_inner.visible = false

func _sync_ground_telegraphs(enemies: Array) -> void:
	for index in range(telegraph_pool.size()):
		var tell_node: MeshInstance3D = telegraph_pool[index] as MeshInstance3D
		if tell_node == null or index >= enemies.size():
			if tell_node != null:
				tell_node.visible = false
			continue
		var enemy: Dictionary = enemies[index]
		var tell_amount: float = _enemy_tell(enemy)
		if tell_amount <= 0.05:
			tell_node.visible = false
			continue
		var pos_value: Vector2 = enemy.get("pos", DESIGN_ARENA.get_center())
		var radius: float = float(enemy.get("radius", 24.0))
		var base_scale: float = clampf(radius / 24.0, 0.82, 1.62)
		var pulse: float = 0.86 + tell_amount * 0.28 + sin(runtime_elapsed * 18.0 + float(index)) * 0.035
		tell_node.visible = true
		tell_node.position = design_to_world(pos_value) + Vector3(0.0, 0.04, 0.0)
		tell_node.scale = Vector3(base_scale * pulse, 1.0, base_scale * pulse)
		tell_node.rotation.y = runtime_elapsed * (0.70 + tell_amount * 1.25)
		var elite: bool = bool(enemy.get("elite", false)) or String(enemy.get("type", "")) == "warden"
		tell_node.material_override = telegraph_elite_material if elite else telegraph_normal_material

func _sync_death_feedback(enemies: Array) -> void:
	var current_positions: Array = []
	for enemy_value in enemies:
		var enemy: Dictionary = enemy_value
		var pos_value: Vector2 = enemy.get("pos", DESIGN_ARENA.get_center())
		current_positions.append(design_to_world(pos_value))

	if not previous_enemy_positions.is_empty() and current_positions.size() < previous_enemy_positions.size():
		for previous_value in previous_enemy_positions:
			var previous_pos: Vector3 = previous_value
			var matched := false
			for current_value in current_positions:
				var current_pos: Vector3 = current_value
				if previous_pos.distance_squared_to(current_pos) < 0.62 * 0.62:
					matched = true
					break
			if not matched:
				_spawn_death_burst(previous_pos)
	previous_enemy_positions = current_positions

func _spawn_death_burst(pos: Vector3) -> void:
	var selected: Node3D = null
	for burst_value in death_burst_pool:
		var burst: Node3D = burst_value
		if not burst.visible:
			selected = burst
			break
	if selected == null and not death_burst_pool.is_empty():
		selected = death_burst_pool[0] as Node3D
	if selected == null:
		return
	selected.visible = true
	selected.position = pos
	selected.scale = Vector3.ONE
	selected.rotation = Vector3.ZERO
	selected.set_meta("age", 0.0)

func _sync_loot_presentation(coins: Array) -> void:
	var current_positions: Array = []
	for index in range(loot_marker_pool.size()):
		var marker: Node3D = loot_marker_pool[index] as Node3D
		if marker == null:
			continue
		if index >= coins.size():
			marker.visible = false
			continue
		var orb: Dictionary = coins[index]
		var pos_value: Vector2 = orb.get("pos", DESIGN_ARENA.get_center())
		var world_pos: Vector3 = design_to_world(pos_value)
		current_positions.append(world_pos)
		var value: float = maxf(1.0, float(orb.get("value", 1)))
		var size_boost: float = clampf(1.0 + log(value) * 0.08, 1.0, 1.36)
		marker.visible = true
		marker.position = world_pos
		marker.scale = Vector3(size_boost, 1.0, size_boost)
	previous_coin_positions = current_positions

func _sync_boss_presentation(enemies: Array, floor_no: int) -> void:
	if boss_root == null:
		return
	if floor_no % 10 != 0 or enemies.is_empty():
		boss_root.visible = false
		return

	var best_index := -1
	var best_score := -1.0
	for index in range(enemies.size()):
		var enemy: Dictionary = enemies[index]
		var score: float = float(enemy.get("radius", 24.0))
		if String(enemy.get("type", "")) == "warden":
			score += 100.0
		if bool(enemy.get("elite", false)):
			score += 18.0
		if score > best_score:
			best_score = score
			best_index = index
	if best_index < 0:
		boss_root.visible = false
		return
	var boss_enemy: Dictionary = enemies[best_index]
	var boss_pos: Vector2 = boss_enemy.get("pos", DESIGN_ARENA.get_center())
	boss_root.visible = true
	boss_root.position = design_to_world(boss_pos)

func _animate_camera(delta: float) -> void:
	if camera == null:
		return
	var transition_strength := 0.0
	if transition_timer > 0.0 and transition_duration > 0.0:
		var t: float = 1.0 - transition_timer / transition_duration
		transition_strength = sin(clampf(t, 0.0, 1.0) * PI)
	var boss_strength: float = clampf(boss_intro_timer / BOSS_INTRO_DURATION, 0.0, 1.0)
	var desired_size: float = camera_base_size - transition_strength * 0.46 - boss_strength * 0.28 - skill_amount * 0.18
	camera.size = lerpf(camera.size, desired_size, minf(1.0, delta * 8.5))
	var shake_x: float = sin(runtime_elapsed * 52.0) * 0.045 * camera_kick
	var shake_y: float = cos(runtime_elapsed * 43.0) * 0.026 * camera_kick
	var desired_pos: Vector3 = camera_base_position + Vector3(shake_x, shake_y + transition_strength * 0.08, -transition_strength * 0.05)
	camera.position = camera.position.lerp(desired_pos, minf(1.0, delta * 13.0))
	camera.look_at(camera_focus + Vector3(shake_x * 0.18, 0.0, shake_y * 0.18), Vector3.UP)

func _animate_transition() -> void:
	if transition_root == null:
		return
	if transition_timer <= 0.0 or transition_duration <= 0.0:
		transition_root.visible = false
		if transition_light != null:
			transition_light.light_energy = 0.0
		return
	transition_root.visible = true
	var t: float = 1.0 - transition_timer / transition_duration
	var wave: float = sin(clampf(t, 0.0, 1.0) * PI)
	transition_root.scale = Vector3(0.76 + wave * 0.42, 1.0, 0.76 + wave * 0.42)
	transition_root.rotation.y = runtime_elapsed * 0.42
	if transition_disc != null:
		transition_disc.scale = Vector3(0.88 + t * 0.34, 1.0, 0.88 + t * 0.34)
	if transition_crown != null:
		transition_crown.scale = Vector3(1.18 - t * 0.30, 1.0, 1.18 - t * 0.30)
	if transition_light != null:
		transition_light.light_energy = wave * 2.2

func _animate_boss_frame() -> void:
	if boss_root == null or not boss_root.visible:
		return
	var intro_strength: float = clampf(boss_intro_timer / BOSS_INTRO_DURATION, 0.0, 1.0)
	var pulse: float = 1.0 + sin(runtime_elapsed * 4.8) * 0.06
	boss_halo.scale = Vector3(pulse * (1.0 + intro_strength * 0.22), 1.0, pulse * (1.0 + intro_strength * 0.22))
	boss_halo.rotation.y = runtime_elapsed * 0.7
	boss_beam.scale = Vector3(0.76 + intro_strength * 0.38, 0.65 + intro_strength * 0.55, 0.76 + intro_strength * 0.38)
	boss_crown.rotation.y = -runtime_elapsed * 0.85
	boss_crown.position.y = 2.35 + sin(runtime_elapsed * 3.4) * 0.08
	boss_light.light_energy = 1.15 + intro_strength * 1.55 + sin(runtime_elapsed * 5.2) * 0.12

func _animate_death_bursts(delta: float) -> void:
	for burst_value in death_burst_pool:
		var burst: Node3D = burst_value
		if burst == null or not burst.visible:
			continue
		var age: float = float(burst.get_meta("age", 0.0)) + delta
		burst.set_meta("age", age)
		if age >= DEATH_BURST_DURATION:
			burst.visible = false
			continue
		var t: float = age / DEATH_BURST_DURATION
		var scale_value: float = 0.55 + t * 1.75
		burst.scale = Vector3(scale_value, 1.0 + t * 0.75, scale_value)
		burst.position.y += delta * 0.34
		burst.rotation.y += delta * 2.4

func _animate_loot_markers() -> void:
	for index in range(loot_marker_pool.size()):
		var marker: Node3D = loot_marker_pool[index] as Node3D
		if marker == null or not marker.visible:
			continue
		var beam: MeshInstance3D = marker.get_node_or_null("Beam") as MeshInstance3D
		var ring: MeshInstance3D = marker.get_node_or_null("FloorGlow") as MeshInstance3D
		var pulse: float = 1.0 + sin(runtime_elapsed * 6.4 + float(index) * 0.7) * 0.12
		if beam != null:
			beam.scale = Vector3(pulse, 0.92 + pulse * 0.08, pulse)
		if ring != null:
			ring.scale = Vector3(pulse, 1.0, pulse)
		marker.rotation.y = runtime_elapsed * 0.44 + float(index) * 0.08

func _animate_player_feedback() -> void:
	if player_feedback_root == null:
		return
	if attack_ring != null:
		attack_ring.visible = attack_amount > 0.03
		if attack_ring.visible:
			var attack_scale: float = 0.72 + (1.0 - attack_amount) * 0.62
			attack_ring.scale = Vector3(attack_scale, 1.0, attack_scale)
			attack_ring.rotation.y = runtime_elapsed * 2.8
	if skill_ring_outer != null and skill_ring_inner != null:
		var skill_visible: bool = skill_amount > 0.025
		skill_ring_outer.visible = skill_visible
		skill_ring_inner.visible = skill_visible
		if skill_visible:
			var outward: float = 0.82 + (1.0 - skill_amount) * 0.92
			var inward: float = 1.16 - (1.0 - skill_amount) * 0.34
			skill_ring_outer.scale = Vector3(outward, 1.0, outward)
			skill_ring_inner.scale = Vector3(inward, 1.0, inward)
			skill_ring_outer.rotation.y = runtime_elapsed * 1.9
			skill_ring_inner.rotation.y = -runtime_elapsed * 2.4

func _apply_transition_material(floor_no: int) -> void:
	if transition_root == null:
		return
	var realm_key := "lower_halls"
	var light_color := Color("ffd078")
	if floor_no >= 41:
		realm_key = "starless_spire"
		light_color = Color("8eaaff")
	elif floor_no >= 31:
		realm_key = "rift_descent"
		light_color = Color("b65aff")
	elif floor_no >= 21:
		realm_key = "iron_bastion"
		light_color = Color("ff7034")
	elif floor_no >= 11:
		realm_key = "ossuary"
		light_color = Color("5de1c5")
	var material: StandardMaterial3D = transition_materials.get(realm_key, transition_materials["lower_halls"])
	if transition_disc != null:
		transition_disc.material_override = material
	if transition_crown != null:
		transition_crown.material_override = material
	for child in transition_root.get_children():
		var mesh_child: MeshInstance3D = child as MeshInstance3D
		if mesh_child != null and String(mesh_child.name).begins_with("RealmRune"):
			mesh_child.material_override = material
	if transition_light != null:
		transition_light.light_color = light_color
