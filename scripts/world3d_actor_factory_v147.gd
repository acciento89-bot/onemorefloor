extends "res://scripts/world3d_actor_factory_v142.gd"

# ONE MORE FLOOR v1.47 — production actor factory.
# Adds a stable socket/animation contract for future rigged GLB characters and
# materially upgrades the native fallback silhouettes that are visible today.

const ProductionModelRegistry = preload("res://scripts/world3d_model_registry_v147.gd")

const SOCKET_DEFAULTS := {
	"weapon": Vector3(0.50, 0.98, -0.68),
	"offhand": Vector3(-0.42, 0.82, -0.12),
	"head": Vector3(0.0, 1.48, -0.10),
	"chest": Vector3(0.0, 0.96, -0.10),
	"feet": Vector3(0.0, 0.04, 0.04),
	"overhead": Vector3(0.0, 2.05, 0.0),
	"vfx": Vector3(0.0, 0.82, 0.0),
}

const ONE_SHOT_DEFAULT_DURATION := {
	"spawn": 0.48,
	"hit": 0.18,
	"death": 0.62,
	"skill": 0.42,
}

func _init() -> void:
	model_registry = ProductionModelRegistry.new()

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if not imported_model_active(root):
		_upgrade_player_fallback(root, materials)
	_ensure_production_contract(root, "wanderer", true)
	root.set_meta("actor_pipeline_v147", true)
	return root

func create_enemy_shell(index: int) -> Node3D:
	var root: Node3D = super.create_enemy_shell(index)
	_ensure_production_contract(root, "", false)
	root.set_meta("actor_pipeline_v147", true)
	return root

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	if not imported_model_active(root):
		_upgrade_enemy_fallback(root, kind, materials)
	_ensure_production_contract(root, kind, false)
	root.set_meta("actor_pipeline_v147", true)

func animate_player(root: Node3D, elapsed: float, move_amount: float, attack_amount: float, skill_amount: float) -> void:
	super.animate_player(root, elapsed, move_amount, attack_amount, skill_amount)
	_sync_socket_targets(root)
	var state: String = "idle"
	if skill_amount > 0.04:
		state = "skill"
	elif attack_amount > 0.04:
		state = "attack"
	elif move_amount > 0.10:
		state = "run"
	var one_shot: String = _active_one_shot(root, elapsed)
	if not one_shot.is_empty():
		state = one_shot
		_drive_imported(root, state, 1.0)
	root.set_meta("production_animation_state", state)
	_animate_player_fallback_details(root, elapsed, move_amount, attack_amount, skill_amount)

func animate_enemy(root: Node3D, elapsed: float, phase: float, tell: float, hit: float, index: int) -> void:
	super.animate_enemy(root, elapsed, phase, tell, hit, index)
	_sync_socket_targets(root)
	var state: String = _enemy_locomotion_state_v147(root)
	if hit > 0.05:
		state = "hit"
	elif tell > 0.18:
		state = "attack"
	var one_shot: String = _active_one_shot(root, elapsed)
	if not one_shot.is_empty():
		state = one_shot
		_drive_imported(root, state, 1.0)
		_animate_native_one_shot(root, state, elapsed)
	root.set_meta("production_animation_state", state)
	_animate_enemy_fallback_details(root, elapsed, tell, hit, index)

func queue_one_shot(root: Node3D, state: String, elapsed: float, duration: float = -1.0) -> void:
	if root == null:
		return
	var resolved_duration: float = duration
	if resolved_duration <= 0.0:
		resolved_duration = float(ONE_SHOT_DEFAULT_DURATION.get(state, 0.34))
	root.set_meta("production_one_shot_state", state)
	root.set_meta("production_one_shot_start", elapsed)
	root.set_meta("production_one_shot_until", elapsed + resolved_duration)
	if imported_model_active(root):
		_drive_imported(root, state, 1.0)

func actor_production_ready(root: Node3D) -> bool:
	if root == null or not bool(root.get_meta("actor_pipeline_v147", false)):
		return false
	var sockets := root.get_node_or_null("ProductionSockets") as Node3D
	if sockets == null:
		return false
	for logical_name in ["weapon", "head", "chest", "feet", "overhead", "vfx"]:
		if sockets.get_node_or_null(_socket_node_name(logical_name)) == null:
			return false
	return model_pipeline_ready(root)

func actor_socket(root: Node3D, logical_name: String) -> Node3D:
	if root == null:
		return null
	return root.get_node_or_null("ProductionSockets/%s" % _socket_node_name(logical_name)) as Node3D

func actor_socket_position(root: Node3D, logical_name: String) -> Vector3:
	var socket: Node3D = actor_socket(root, logical_name)
	return socket.global_position if socket != null else (root.global_position if root != null else Vector3.ZERO)

func production_registry_snapshot() -> Dictionary:
	return model_registry.snapshot()

func socket_contract_snapshot(root: Node3D) -> Dictionary:
	var data: Dictionary = {}
	for logical_name in SOCKET_DEFAULTS.keys():
		var key: String = String(logical_name)
		var socket: Node3D = actor_socket(root, key)
		data[key] = socket != null
	return data

func _ensure_production_contract(root: Node3D, kind: String, is_player: bool) -> void:
	if root == null:
		return
	var sockets := root.get_node_or_null("ProductionSockets") as Node3D
	if sockets == null:
		sockets = Node3D.new()
		sockets.name = "ProductionSockets"
		root.add_child(sockets)
	for logical_value in SOCKET_DEFAULTS.keys():
		var logical_name: String = String(logical_value)
		var node_name: String = _socket_node_name(logical_name)
		var socket := sockets.get_node_or_null(node_name) as Node3D
		if socket == null:
			socket = Node3D.new()
			socket.name = node_name
			socket.position = SOCKET_DEFAULTS[logical_name]
			sockets.add_child(socket)
		socket.set_meta("logical_socket", logical_name)
	root.set_meta("production_contract_kind", kind)
	root.set_meta("production_contract_player", is_player)
	_bind_contract_targets(root, kind, is_player)

func _bind_contract_targets(root: Node3D, kind: String, is_player: bool) -> void:
	var imported: Node3D = root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	for logical_value in SOCKET_DEFAULTS.keys():
		var logical_name: String = String(logical_value)
		var socket: Node3D = actor_socket(root, logical_name)
		if socket == null:
			continue
		var target: Node3D = null
		if imported != null:
			target = model_registry.resolve_socket(imported, logical_name)
		if target == null:
			target = _native_socket_target(root, logical_name, is_player)
		if target != null:
			socket.set_meta("target_node", target)
			socket.set_meta("target_source", "imported" if imported != null and target.is_ancestor_of(imported) == false else "native")
		else:
			socket.remove_meta("target_node")
			socket.set_meta("target_source", "default")
	root.set_meta("production_socket_bound_kind", kind)
	_sync_socket_targets(root)

func _native_socket_target(root: Node3D, logical_name: String, is_player: bool) -> Node3D:
	if logical_name == "weapon":
		if is_player:
			return root.get_node_or_null("WeaponPivot") as Node3D
		return root.get_node_or_null("Motion/Visual/WeaponPivot") as Node3D
	if logical_name == "head":
		if is_player:
			return root.get_node_or_null("Motion/Hood") as Node3D
		return root.get_node_or_null("Motion/Visual/HeadPivot") as Node3D
	if logical_name == "chest":
		return root.get_node_or_null("Motion") as Node3D
	if logical_name == "feet":
		return root.get_node_or_null("Motion") as Node3D
	if logical_name == "vfx":
		return root.get_node_or_null("Motion") as Node3D
	return null

func _sync_socket_targets(root: Node3D) -> void:
	if root == null:
		return
	for logical_value in SOCKET_DEFAULTS.keys():
		var logical_name: String = String(logical_value)
		var socket: Node3D = actor_socket(root, logical_name)
		if socket == null:
			continue
		var target_value: Variant = socket.get_meta("target_node", null)
		if target_value is Node3D and is_instance_valid(target_value):
			var target: Node3D = target_value as Node3D
			socket.global_transform = target.global_transform

func _active_one_shot(root: Node3D, elapsed: float) -> String:
	if root == null:
		return ""
	var until: float = float(root.get_meta("production_one_shot_until", -1.0))
	if elapsed >= until:
		return ""
	return String(root.get_meta("production_one_shot_state", ""))

func _animate_native_one_shot(root: Node3D, state: String, elapsed: float) -> void:
	if imported_model_active(root):
		return
	var start: float = float(root.get_meta("production_one_shot_start", elapsed))
	var until: float = float(root.get_meta("production_one_shot_until", elapsed + 0.01))
	var duration: float = maxf(0.01, until - start)
	var t: float = clampf((elapsed - start) / duration, 0.0, 1.0)
	var motion := root.get_node_or_null("Motion") as Node3D
	if motion == null:
		return
	if state == "spawn":
		var ease: float = 1.0 - pow(1.0 - t, 3.0)
		motion.position.y += (1.0 - ease) * 0.22
		motion.scale = Vector3.ONE * (0.82 + ease * 0.18)
	elif state == "death":
		motion.rotation.z = t * 1.15
		motion.position.y -= t * 0.12

func _enemy_locomotion_state_v147(root: Node3D) -> String:
	var previous: Vector3 = root.get_meta("v147_prev_position", root.position)
	var distance: float = root.position.distance_to(previous)
	root.set_meta("v147_prev_position", root.position)
	return "run" if distance > 0.008 else "idle"

func _upgrade_player_fallback(root: Node3D, materials: Dictionary) -> void:
	if root == null or bool(root.get_meta("v147_player_art", false)):
		return
	var motion := root.get_node_or_null("Motion") as Node3D
	if motion == null:
		return
	# Layering and asymmetric equipment push the fallback closer to a deliberate
	# action-RPG hero instead of a primitive construction sample.
	_add_box(motion, "HoodBrowTrim", Vector3(0.42, 0.055, 0.07), Vector3(0.0, 1.52, -0.315), materials["gold"])
	_add_box(motion, "CollarL", Vector3(0.24, 0.12, 0.24), Vector3(-0.20, 1.18, 0.0), materials["steel_dark"])
	_add_box(motion, "CollarR", Vector3(0.24, 0.12, 0.24), Vector3(0.20, 1.18, 0.0), materials["steel_dark"])
	_add_box(motion, "HipSatchel", Vector3(0.24, 0.30, 0.18), Vector3(-0.33, 0.58, 0.15), materials["leather"])
	_add_box(motion, "SatchelClasp", Vector3(0.10, 0.07, 0.035), Vector3(-0.33, 0.63, 0.052), materials["gold"])
	var back_blade: MeshInstance3D = _add_box(motion, "BackScabbard", Vector3(0.10, 0.08, 0.82), Vector3(-0.22, 0.86, 0.34), materials["leather"])
	back_blade.rotation.x = -0.30
	back_blade.rotation.z = -0.28
	var gem: MeshInstance3D = _add_sphere(motion, "ShoulderGem", 0.085, Vector3(0.39, 1.15, -0.11), materials["glow_purple"], 8, 4)
	gem.scale = Vector3(0.72, 0.72, 0.42)
	var weapon := root.get_node_or_null("WeaponPivot") as Node3D
	if weapon != null:
		_add_box(weapon, "BladeCoreV147", Vector3(0.038, 0.064, 0.88), Vector3(0.0, 0.0, -0.69), materials["glow_purple"])
		_add_box(weapon, "GuardGemV147", Vector3(0.11, 0.08, 0.07), Vector3(0.0, 0.0, -0.18), materials["glow_gold"])
	root.set_meta("v147_player_art", true)

func _upgrade_enemy_fallback(root: Node3D, kind: String, materials: Dictionary) -> void:
	if root == null or String(root.get_meta("v147_enemy_art_kind", "")) == kind:
		return
	var visual := root.get_node_or_null("Motion/Visual") as Node3D
	if visual == null:
		return
	match kind:
		"goblin": _decorate_goblin(visual, materials)
		"bat": _decorate_bat(visual, materials)
		"skeleton": _decorate_skeleton(visual, materials)
		"ghoul": _decorate_ghoul(visual, materials)
		"necromancer": _decorate_necromancer(visual, materials)
		"warden": _decorate_warden(visual, materials)
		_: _decorate_fallback(visual, materials)
	root.set_meta("v147_enemy_art_kind", kind)

func _decorate_goblin(visual: Node3D, materials: Dictionary) -> void:
	_add_box(visual, "ScrapShoulder", Vector3(0.28, 0.12, 0.30), Vector3(-0.33, 0.79, -0.02), materials["steel_dark"])
	_add_box(visual, "LootPouch", Vector3(0.20, 0.24, 0.15), Vector3(-0.25, 0.42, 0.14), materials["leather"])
	var shield: MeshInstance3D = _add_cylinder(visual, "Buckler", 0.27, 0.27, 0.07, Vector3(-0.43, 0.64, -0.06), materials["steel"], 10)
	shield.rotation.x = PI * 0.5
	_add_sphere(visual, "BucklerBoss", 0.075, Vector3(-0.43, 0.64, -0.105), materials["gold"], 8, 4)

func _decorate_bat(visual: Node3D, materials: Dictionary) -> void:
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		var claw: MeshInstance3D = _add_cylinder(visual, "WingClaw", 0.0, 0.045, 0.24, Vector3(side * 0.67, 0.82, -0.02), materials["bone"], 6)
		claw.rotation.z = -side * 1.05
	_add_sphere(visual, "ChestCore", 0.11, Vector3(0.0, 0.74, -0.23), materials["glow_purple"], 8, 4)

func _decorate_skeleton(visual: Node3D, materials: Dictionary) -> void:
	var shield: MeshInstance3D = _add_box(visual, "BoneShield", Vector3(0.46, 0.62, 0.10), Vector3(-0.44, 0.70, -0.04), materials["steel_dark"])
	shield.rotation.z = -0.08
	_add_box(visual, "ShieldCross", Vector3(0.10, 0.48, 0.04), Vector3(-0.44, 0.70, -0.102), materials["bone"])
	_add_box(visual, "ShieldBand", Vector3(0.34, 0.08, 0.04), Vector3(-0.44, 0.70, -0.103), materials["bone"])
	_add_box(visual, "JawGuard", Vector3(0.30, 0.08, 0.12), Vector3(0.0, 1.07, -0.19), materials["steel_dark"])

func _decorate_ghoul(visual: Node3D, materials: Dictionary) -> void:
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		_add_box(visual, "ChainLink", Vector3(0.10, 0.34, 0.10), Vector3(side * 0.22, 0.62, -0.22), materials["steel_dark"])
		var claw: MeshInstance3D = _add_cylinder(visual, "Claw", 0.0, 0.04, 0.25, Vector3(side * 0.46, 0.34, -0.18), materials["bone"], 6)
		claw.rotation.z = side * 0.36
	_add_box(visual, "RibPlate", Vector3(0.50, 0.14, 0.28), Vector3(0.0, 0.74, -0.10), materials["undead_dark"])

func _decorate_necromancer(visual: Node3D, materials: Dictionary) -> void:
	var focus := Node3D.new()
	focus.name = "SpellFocusV147"
	focus.position = Vector3(-0.48, 1.18, -0.18)
	visual.add_child(focus)
	_add_sphere(focus, "Orb", 0.13, Vector3.ZERO, materials["glow_purple"], 10, 5)
	for index in range(3):
		var angle: float = TAU * float(index) / 3.0
		_add_sphere(focus, "RuneMote%d" % index, 0.035, Vector3(cos(angle) * 0.22, sin(angle) * 0.13, 0.0), materials["glow_gold"], 6, 3)
	_add_box(visual, "RobeSigil", Vector3(0.20, 0.30, 0.035), Vector3(0.0, 0.57, -0.29), materials["glow_purple"])

func _decorate_warden(visual: Node3D, materials: Dictionary) -> void:
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		var horn: MeshInstance3D = _add_cylinder(visual, "HelmHorn", 0.0, 0.085, 0.42, Vector3(side * 0.23, 1.73, -0.03), materials["bone_dark"], 7)
		horn.rotation.z = -side * 0.48
		_add_box(visual, "ShoulderBlade", Vector3(0.16, 0.38, 0.18), Vector3(side * 0.54, 1.12, 0.02), materials["steel_dark"])
	_add_box(visual, "ChestSigilV147", Vector3(0.24, 0.34, 0.04), Vector3(0.0, 1.05, -0.36), materials["glow_red"])
	var cape: MeshInstance3D = _add_box(visual, "WardenCape", Vector3(0.78, 0.92, 0.08), Vector3(0.0, 0.84, 0.31), materials["warden"])
	cape.rotation.x = -0.14
	var weapon := visual.get_node_or_null("WeaponPivot") as Node3D
	if weapon != null:
		_add_box(weapon, "WardenEdgeGlow", Vector3(0.05, 0.08, 0.76), Vector3(0.0, 0.0, -0.55), materials["glow_red"])

func _decorate_fallback(visual: Node3D, materials: Dictionary) -> void:
	_add_box(visual, "FallbackChestMark", Vector3(0.18, 0.22, 0.04), Vector3(0.0, 0.78, -0.26), materials["glow_purple"])

func _animate_player_fallback_details(root: Node3D, elapsed: float, move_amount: float, attack_amount: float, skill_amount: float) -> void:
	if imported_model_active(root):
		return
	var motion := root.get_node_or_null("Motion") as Node3D
	if motion != null:
		var gem := motion.get_node_or_null("ShoulderGem") as MeshInstance3D
		if gem != null:
			var pulse: float = 0.92 + sin(elapsed * 4.8) * 0.08 + skill_amount * 0.22
			gem.scale = Vector3(0.72, 0.72, 0.42) * pulse
		var satchel := motion.get_node_or_null("HipSatchel") as Node3D
		if satchel != null:
			satchel.rotation.z = sin(elapsed * 6.0) * 0.035 * clampf(move_amount, 0.0, 1.0)
	var weapon := root.get_node_or_null("WeaponPivot") as Node3D
	if weapon != null:
		var core := weapon.get_node_or_null("BladeCoreV147") as MeshInstance3D
		if core != null:
			var attack_scale: float = 1.0 + attack_amount * 0.34 + skill_amount * 0.18
			core.scale = Vector3(attack_scale, 1.0, 1.0)

func _animate_enemy_fallback_details(root: Node3D, elapsed: float, tell: float, hit: float, index: int) -> void:
	if imported_model_active(root):
		return
	var visual := root.get_node_or_null("Motion/Visual") as Node3D
	if visual == null:
		return
	var focus := visual.get_node_or_null("SpellFocusV147") as Node3D
	if focus != null:
		focus.rotation.z = elapsed * 0.8 + float(index) * 0.17
		focus.position.y = 1.18 + sin(elapsed * 3.7 + float(index)) * 0.055
	var sigil := visual.get_node_or_null("ChestSigilV147") as MeshInstance3D
	if sigil != null:
		var pulse: float = 1.0 + tell * 0.30 + sin(elapsed * 5.0) * 0.05
		sigil.scale = Vector3.ONE * pulse
	var cape := visual.get_node_or_null("WardenCape") as MeshInstance3D
	if cape != null:
		cape.rotation.x = -0.14 - tell * 0.10 + sin(elapsed * 3.2) * 0.025
		cape.rotation.z = hit * 0.08

func _socket_node_name(logical_name: String) -> String:
	match logical_name:
		"weapon": return "WeaponSocket"
		"offhand": return "OffhandSocket"
		"head": return "HeadSocket"
		"chest": return "ChestSocket"
		"feet": return "FeetSocket"
		"overhead": return "OverheadSocket"
		"vfx": return "VFXSocket"
		_: return logical_name.capitalize().replace(" ", "") + "Socket"
