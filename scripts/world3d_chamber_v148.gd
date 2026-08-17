extends "res://scripts/world3d_chamber_v147.gd"

# ONE MORE FLOOR v1.48 — Character Combat VFX & Animation Presentation.
# Adds archetype-specific, socket-driven combat spectacle on top of the v1.47
# production actor contract. All systems are pooled and visual-only; gameplay
# math, AI, collision and progression remain authoritative in the legacy runtime.

const CombatActorFactory = preload("res://scripts/world3d_actor_factory_v148.gd")
const ENEMY_COMBAT_VFX_SLOTS := 18
const SIGNATURE_POOL_SIZE := 12
const SIGNATURE_DURATION := 0.52

var character_vfx_root: Node3D
var enemy_vfx_root: Node3D
var player_vfx_root: Node3D
var signature_root: Node3D
var enemy_vfx_slots: Array = []
var spawn_signature_pool: Array = []
var death_signature_pool: Array = []
var previous_enemy_signatures: Array = []
var archetype_materials: Dictionary = {}
var archetype_colors: Dictionary = {}
var player_gold_material: StandardMaterial3D
var player_arcane_material: StandardMaterial3D
var player_weapon_flare: MeshInstance3D
var player_chest_sigil: MeshInstance3D
var player_skill_crown: Node3D
var player_combat_light: OmniLight3D

func _ready() -> void:
	super._ready()
	_build_character_combat_materials()
	_build_character_combat_vfx()
	_capture_signature_state([])

func _process(delta: float) -> void:
	super._process(delta)
	if not character_combat_vfx_ready():
		return
	_animate_signature_pool(spawn_signature_pool, delta, true)
	_animate_signature_pool(death_signature_pool, delta, false)
	_animate_player_socket_vfx()

# v1.47 owns the actor build hook; replace its factory with the v1.48 animation
# presentation factory while preserving the exact actor/world hierarchy.
func _build_player() -> void:
	actor_factory = CombatActorFactory.new()
	player_root = actor_factory.create_player(actor_materials)
	add_child(player_root)

func character_combat_vfx_ready() -> bool:
	return actor_production_ready() \
		and actor_factory != null \
		and actor_factory.has_method("combat_animation_ready") \
		and bool(actor_factory.call("combat_animation_ready", player_root)) \
		and character_vfx_root != null \
		and enemy_vfx_slots.size() == ENEMY_COMBAT_VFX_SLOTS \
		and spawn_signature_pool.size() == SIGNATURE_POOL_SIZE \
		and death_signature_pool.size() == SIGNATURE_POOL_SIZE \
		and player_weapon_flare != null \
		and player_chest_sigil != null

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["character_combat_vfx_ready"] = character_combat_vfx_ready()
	data["enemy_combat_vfx_slots"] = enemy_vfx_slots.size()
	data["spawn_signature_pool"] = spawn_signature_pool.size()
	data["death_signature_pool"] = death_signature_pool.size()
	data["player_socket_vfx"] = player_weapon_flare != null and player_chest_sigil != null
	var active_enemy_vfx: int = 0
	for slot_value in enemy_vfx_slots:
		var slot: Node3D = slot_value as Node3D
		if slot != null and slot.visible:
			active_enemy_vfx += 1
	data["active_enemy_combat_vfx"] = active_enemy_vfx
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
	if not character_combat_vfx_ready():
		return
	_sync_enemy_combat_vfx(enemies)
	_sync_spawn_death_signatures(enemies)
	_sync_player_socket_vfx()
	_capture_signature_state(enemies)

func _build_character_combat_materials() -> void:
	archetype_colors = {
		"goblin": Color("d7ff73"),
		"bat": Color("bc73ff"),
		"skeleton": Color("ffe7ad"),
		"ghoul": Color("7dff9a"),
		"necromancer": Color("a65cff"),
		"warden": Color("ff5b4f"),
		"enemy": Color("ff8d75"),
	}
	for key_value in archetype_colors.keys():
		var key: String = String(key_value)
		var color: Color = archetype_colors[key]
		archetype_materials[key] = _transparent_emissive(Color(color.r, color.g, color.b, 0.34), 2.65)
	player_gold_material = _transparent_emissive(Color(1.0, 0.80, 0.30, 0.36), 2.85)
	player_arcane_material = _transparent_emissive(Color(0.72, 0.42, 1.0, 0.36), 3.05)

func _build_character_combat_vfx() -> void:
	character_vfx_root = Node3D.new()
	character_vfx_root.name = "CharacterCombatVFX"
	add_child(character_vfx_root)

	enemy_vfx_root = Node3D.new()
	enemy_vfx_root.name = "EnemyArchetypeVFX"
	character_vfx_root.add_child(enemy_vfx_root)
	for index in range(ENEMY_COMBAT_VFX_SLOTS):
		var slot: Node3D = _build_enemy_vfx_slot(index)
		enemy_vfx_root.add_child(slot)
		enemy_vfx_slots.append(slot)

	player_vfx_root = Node3D.new()
	player_vfx_root.name = "WandererSocketVFX"
	character_vfx_root.add_child(player_vfx_root)
	player_weapon_flare = _make_sphere(player_vfx_root, "WeaponFlare", 0.12, player_arcane_material)
	player_weapon_flare.visible = false
	player_chest_sigil = _make_ring(player_vfx_root, "ChestSigil", 0.62, player_gold_material, 32)
	player_chest_sigil.visible = false
	player_skill_crown = Node3D.new()
	player_skill_crown.name = "SkillCrown"
	player_skill_crown.visible = false
	player_vfx_root.add_child(player_skill_crown)
	for index in range(6):
		var angle: float = TAU * float(index) / 6.0
		var spike: MeshInstance3D = _make_box(player_skill_crown, "CrownSpike%d" % index, Vector3(0.08, 0.46, 0.08), player_arcane_material)
		spike.position = Vector3(cos(angle) * 0.72, 0.34, sin(angle) * 0.72)
		spike.rotation.z = sin(angle) * 0.18
	player_combat_light = OmniLight3D.new()
	player_combat_light.name = "WandererCombatLight"
	player_combat_light.light_color = Color("b778ff")
	player_combat_light.light_energy = 0.0
	player_combat_light.omni_range = 3.4
	player_combat_light.shadow_enabled = false
	player_vfx_root.add_child(player_combat_light)

	signature_root = Node3D.new()
	signature_root.name = "SpawnDeathSignatures"
	character_vfx_root.add_child(signature_root)
	for index in range(SIGNATURE_POOL_SIZE):
		spawn_signature_pool.append(_build_signature("SpawnSignature%02d" % index))
		death_signature_pool.append(_build_signature("DeathSignature%02d" % index))

func _build_enemy_vfx_slot(index: int) -> Node3D:
	var slot := Node3D.new()
	slot.name = "EnemyVFX%02d" % index
	slot.visible = false
	slot.set_meta("warden_burst_armed", true)
	var default_material: Material = archetype_materials.get("enemy")
	var core: MeshInstance3D = _make_sphere(slot, "ChargeCore", 0.14, default_material)
	core.visible = false
	var weapon_arc: MeshInstance3D = _make_box(slot, "WeaponArc", Vector3(0.08, 0.055, 0.76), default_material)
	weapon_arc.visible = false
	var head_ring: MeshInstance3D = _make_ring(slot, "HeadRune", 0.34, default_material, 28)
	head_ring.visible = false
	for wave_index in range(3):
		var shockwave: MeshInstance3D = _make_ring(slot, "Shockwave%d" % wave_index, 0.68, default_material, 32)
		shockwave.visible = false
	for orb_index in range(3):
		var orb: MeshInstance3D = _make_sphere(slot, "OrbitOrb%d" % orb_index, 0.09, default_material)
		orb.visible = false
	var light := OmniLight3D.new()
	light.name = "CombatAccentLight"
	light.light_color = Color("ff8d75")
	light.light_energy = 0.0
	light.omni_range = 2.6
	light.shadow_enabled = false
	slot.add_child(light)
	return slot

func _build_signature(name_value: String) -> Node3D:
	var root := Node3D.new()
	root.name = name_value
	root.visible = false
	root.set_meta("age", SIGNATURE_DURATION + 1.0)
	root.set_meta("kind", "enemy")
	signature_root.add_child(root)
	var material: Material = archetype_materials.get("enemy")
	var ring: MeshInstance3D = _make_ring(root, "Ring", 0.52, material, 28)
	ring.position.y = 0.045
	for index in range(5):
		var angle: float = TAU * float(index) / 5.0
		var shard: MeshInstance3D = _make_box(root, "Shard%d" % index, Vector3(0.07, 0.30, 0.07), material)
		shard.position = Vector3(cos(angle) * 0.28, 0.22, sin(angle) * 0.28)
	return root

func _sync_enemy_combat_vfx(enemies: Array) -> void:
	for index in range(enemy_vfx_slots.size()):
		var slot: Node3D = enemy_vfx_slots[index] as Node3D
		if slot == null:
			continue
		if index >= enemies.size() or index >= enemy_pool.size():
			_hide_enemy_vfx_slot(slot)
			continue
		var proxy: Node3D = enemy_pool[index] as Node3D
		if proxy == null or not proxy.visible:
			_hide_enemy_vfx_slot(slot)
			continue
		var enemy: Dictionary = enemies[index]
		var kind: String = _visual_enemy_kind(enemy)
		var tell: float = _enemy_tell(enemy)
		var hit_age: float = runtime_elapsed - float(enemy.get("v47_hit_stamp", -99.0))
		var hit: float = clampf(1.0 - hit_age / 0.16, 0.0, 1.0) if hit_age >= 0.0 else 0.0
		_sync_enemy_vfx_slot(slot, proxy, kind, tell, hit, index)

func _sync_enemy_vfx_slot(slot: Node3D, proxy: Node3D, kind: String, tell: float, hit: float, index: int) -> void:
	var material: Material = archetype_materials.get(kind, archetype_materials.get("enemy"))
	var color: Color = archetype_colors.get(kind, archetype_colors.get("enemy"))
	var core := slot.get_node_or_null("ChargeCore") as MeshInstance3D
	var weapon_arc := slot.get_node_or_null("WeaponArc") as MeshInstance3D
	var head_ring := slot.get_node_or_null("HeadRune") as MeshInstance3D
	var light := slot.get_node_or_null("CombatAccentLight") as OmniLight3D
	var vfx_socket: Node3D = actor_factory.call("actor_socket", proxy, "vfx") as Node3D
	var weapon_socket: Node3D = actor_factory.call("actor_socket", proxy, "weapon") as Node3D
	var head_socket: Node3D = actor_factory.call("actor_socket", proxy, "head") as Node3D
	var feet_socket: Node3D = actor_factory.call("actor_socket", proxy, "feet") as Node3D
	var vfx_pos: Vector3 = vfx_socket.global_position if vfx_socket != null else proxy.global_position + Vector3(0.0, 0.8, 0.0)
	var head_pos: Vector3 = head_socket.global_position if head_socket != null else vfx_pos + Vector3(0.0, 0.55, 0.0)
	var feet_pos: Vector3 = feet_socket.global_position if feet_socket != null else proxy.global_position
	var active: bool = tell > 0.025 or hit > 0.025 or kind == "necromancer" or kind == "warden"
	slot.visible = active
	if not active:
		_hide_enemy_vfx_slot(slot)
		return

	if core != null:
		core.material_override = material
		core.visible = tell > 0.05 or hit > 0.03 or kind == "necromancer"
		core.global_position = vfx_pos
		var core_scale: float = 0.72 + tell * 1.20 + hit * 0.82
		core.scale = Vector3.ONE * core_scale
		core.rotation.y = runtime_elapsed * 4.8 + float(index)

	if weapon_arc != null:
		weapon_arc.material_override = material
		weapon_arc.visible = (kind == "goblin" or kind == "skeleton" or kind == "warden" or kind == "ghoul") and tell > 0.08
		if weapon_arc.visible and weapon_socket != null:
			weapon_arc.global_transform = weapon_socket.global_transform * Transform3D(Basis.IDENTITY, Vector3(0.0, 0.0, -0.34))
			weapon_arc.scale = Vector3(0.82 + tell * 0.80, 1.0, 0.78 + tell * 0.62)

	if head_ring != null:
		head_ring.material_override = material
		head_ring.visible = (kind == "bat" or kind == "necromancer" or kind == "warden") and (tell > 0.04 or kind == "necromancer")
		if head_ring.visible:
			head_ring.global_position = head_pos + Vector3(0.0, 0.12, 0.0)
			head_ring.rotation.y = runtime_elapsed * (2.4 if kind == "bat" else -1.8)
			var ring_scale: float = 0.78 + tell * 0.62 + sin(runtime_elapsed * 7.0 + float(index)) * 0.06
			head_ring.scale = Vector3(ring_scale, 1.0, ring_scale)

	for orb_index in range(3):
		var orb := slot.get_node_or_null("OrbitOrb%d" % orb_index) as MeshInstance3D
		if orb == null:
			continue
		orb.material_override = material
		orb.visible = kind == "necromancer" or (kind == "ghoul" and tell > 0.18) or (kind == "bat" and tell > 0.32)
		if orb.visible:
			var angle: float = runtime_elapsed * (2.2 + float(orb_index) * 0.13) + TAU * float(orb_index) / 3.0
			var radius: float = 0.46 + tell * 0.22
			orb.global_position = vfx_pos + Vector3(cos(angle) * radius, 0.16 + sin(angle * 1.7) * 0.10, sin(angle) * radius)
			orb.scale = Vector3.ONE * (0.72 + tell * 0.52 + hit * 0.35)

	for wave_index in range(3):
		var wave := slot.get_node_or_null("Shockwave%d" % wave_index) as MeshInstance3D
		if wave == null:
			continue
		wave.material_override = material
		wave.visible = kind == "warden" and tell > 0.10
		if wave.visible:
			var offset: float = float(wave_index) * 0.23
			var progress: float = fposmod((1.0 - tell) + offset, 1.0)
			wave.global_position = feet_pos + Vector3(0.0, 0.045 + float(wave_index) * 0.008, 0.0)
			var wave_scale: float = 0.72 + progress * (1.75 + float(wave_index) * 0.22)
			wave.scale = Vector3(wave_scale, 1.0, wave_scale)
			wave.rotation.y = runtime_elapsed * (0.65 + float(wave_index) * 0.18)

	if light != null:
		light.global_position = vfx_pos
		light.light_color = color
		light.light_energy = (tell * 1.15 + hit * 1.55) if kind == "warden" else (tell * 0.72 + hit * 0.80 if kind == "necromancer" else hit * 0.45)

	if kind == "warden":
		var armed: bool = bool(slot.get_meta("warden_burst_armed", true))
		if tell > 0.82 and armed:
			camera_kick = maxf(camera_kick, 0.82)
			slot.set_meta("warden_burst_armed", false)
		elif tell < 0.20:
			slot.set_meta("warden_burst_armed", true)

func _hide_enemy_vfx_slot(slot: Node3D) -> void:
	if slot == null:
		return
	slot.visible = false
	var light := slot.get_node_or_null("CombatAccentLight") as OmniLight3D
	if light != null:
		light.light_energy = 0.0

func _sync_player_socket_vfx() -> void:
	if player_root == null:
		return
	var weapon_socket: Node3D = actor_factory.call("actor_socket", player_root, "weapon") as Node3D
	var vfx_socket: Node3D = actor_factory.call("actor_socket", player_root, "vfx") as Node3D
	var overhead_socket: Node3D = actor_factory.call("actor_socket", player_root, "overhead") as Node3D
	if player_weapon_flare != null:
		player_weapon_flare.visible = attack_amount > 0.03 or skill_amount > 0.03
		if player_weapon_flare.visible and weapon_socket != null:
			player_weapon_flare.global_position = weapon_socket.to_global(Vector3(0.0, 0.0, -0.62))
			var flare_scale: float = 0.75 + attack_amount * 0.85 + skill_amount * 1.10
			player_weapon_flare.scale = Vector3.ONE * flare_scale
	if player_chest_sigil != null:
		player_chest_sigil.visible = skill_amount > 0.035
		if player_chest_sigil.visible:
			player_chest_sigil.global_position = (vfx_socket.global_position if vfx_socket != null else player_root.global_position) + Vector3(0.0, -0.70, 0.0)
			var sigil_scale: float = 0.85 + (1.0 - skill_amount) * 0.85
			player_chest_sigil.scale = Vector3(sigil_scale, 1.0, sigil_scale)
			player_chest_sigil.rotation.y = -runtime_elapsed * 2.8
	if player_skill_crown != null:
		player_skill_crown.visible = skill_amount > 0.08
		if player_skill_crown.visible:
			player_skill_crown.global_position = overhead_socket.global_position if overhead_socket != null else player_root.global_position + Vector3(0.0, 2.0, 0.0)
			player_skill_crown.rotation.y = runtime_elapsed * 1.9
			player_skill_crown.scale = Vector3.ONE * (0.82 + skill_amount * 0.36)
	if player_combat_light != null:
		player_combat_light.global_position = vfx_socket.global_position if vfx_socket != null else player_root.global_position + Vector3(0.0, 0.8, 0.0)
		player_combat_light.light_energy = attack_amount * 0.60 + skill_amount * 1.75

func _animate_player_socket_vfx() -> void:
	if player_weapon_flare != null and player_weapon_flare.visible:
		player_weapon_flare.rotation.y = runtime_elapsed * 9.0
	if player_skill_crown != null and player_skill_crown.visible:
		var pulse: float = 1.0 + sin(runtime_elapsed * 7.2) * 0.08
		player_skill_crown.scale *= Vector3.ONE * pulse

func _sync_spawn_death_signatures(enemies: Array) -> void:
	var current: Array = _enemy_signature_state(enemies)
	for current_value in current:
		var entry: Dictionary = current_value
		if not _signature_has_match(entry, previous_enemy_signatures):
			_spawn_signature(spawn_signature_pool, String(entry.get("kind", "enemy")), entry.get("pos", Vector3.ZERO), true)
	for previous_value in previous_enemy_signatures:
		var entry: Dictionary = previous_value
		if not _signature_has_match(entry, current):
			_spawn_signature(death_signature_pool, String(entry.get("kind", "enemy")), entry.get("pos", Vector3.ZERO), false)

func _enemy_signature_state(enemies: Array) -> Array:
	var result: Array = []
	for enemy_value in enemies:
		var enemy: Dictionary = enemy_value
		var design_pos: Vector2 = enemy.get("pos", DESIGN_ARENA.get_center())
		result.append({
			"kind": _visual_enemy_kind(enemy),
			"pos": design_to_world(design_pos),
		})
	return result

func _signature_has_match(entry: Dictionary, candidates: Array) -> bool:
	var position: Vector3 = entry.get("pos", Vector3.ZERO)
	for candidate_value in candidates:
		var candidate: Dictionary = candidate_value
		var candidate_position: Vector3 = candidate.get("pos", Vector3.ZERO)
		if position.distance_squared_to(candidate_position) <= 0.78 * 0.78:
			return true
	return false

func _capture_signature_state(enemies: Array) -> void:
	previous_enemy_signatures = _enemy_signature_state(enemies)

func _spawn_signature(pool: Array, kind: String, position: Vector3, spawning: bool) -> void:
	var selected: Node3D = null
	for item_value in pool:
		var item: Node3D = item_value as Node3D
		if item != null and not item.visible:
			selected = item
			break
	if selected == null and not pool.is_empty():
		selected = pool[0] as Node3D
	if selected == null:
		return
	selected.visible = true
	selected.global_position = position
	selected.scale = Vector3.ONE * (1.35 if spawning else 0.72)
	selected.rotation = Vector3.ZERO
	selected.set_meta("age", 0.0)
	selected.set_meta("kind", kind)
	selected.set_meta("spawning", spawning)
	_apply_material_recursive(selected, archetype_materials.get(kind, archetype_materials.get("enemy")))
	if not spawning and kind == "warden":
		camera_kick = maxf(camera_kick, 0.95)

func _animate_signature_pool(pool: Array, delta: float, spawning: bool) -> void:
	for item_value in pool:
		var item: Node3D = item_value as Node3D
		if item == null or not item.visible:
			continue
		var age: float = float(item.get_meta("age", 0.0)) + delta
		item.set_meta("age", age)
		if age >= SIGNATURE_DURATION:
			item.visible = false
			continue
		var t: float = clampf(age / SIGNATURE_DURATION, 0.0, 1.0)
		var scale_value: float = lerpf(1.42, 0.72, t) if spawning else lerpf(0.62, 2.05, t)
		item.scale = Vector3(scale_value, 1.0 + t * 0.55, scale_value)
		item.rotation.y += delta * (2.8 if spawning else -3.4)
		item.position.y += delta * (0.12 if spawning else 0.48)

func _visual_enemy_kind(enemy: Dictionary) -> String:
	var kind: String = String(enemy.get("type", "enemy"))
	if kind == "warden":
		return "warden"
	if archetype_materials.has(kind):
		return kind
	return "enemy"

func _apply_material_recursive(node: Node, material: Material) -> void:
	if node is MeshInstance3D:
		(node as MeshInstance3D).material_override = material
	for child_value in node.get_children():
		var child: Node = child_value as Node
		_apply_material_recursive(child, material)

func _make_sphere(parent: Node3D, name_value: String, radius: float, material: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 10
	mesh.rings = 5
	var node := MeshInstance3D.new()
	node.name = name_value
	node.mesh = mesh
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)
	return node

func _make_ring(parent: Node3D, name_value: String, radius: float, material: Material, segments: int) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.018
	mesh.radial_segments = segments
	var node := MeshInstance3D.new()
	node.name = name_value
	node.mesh = mesh
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)
	return node

func _make_box(parent: Node3D, name_value: String, size: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = name_value
	node.mesh = mesh
	node.material_override = material
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(node)
	return node
