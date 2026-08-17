extends "res://scripts/world3d_model_registry.gd"

# ONE MORE FLOOR v1.47 — production actor model contract.
# This keeps the v1.42 fail-safe GLB pipeline, but adds the metadata, socket,
# animation and QA contract needed for real rigged production characters.
# No binary model assets are fabricated here: missing models still fall back to
# the self-contained native actor art.

const PRODUCTION_PROFILES := {
	"wanderer": {
		"scale": Vector3(1.0, 1.0, 1.0),
		"offset": Vector3.ZERO,
		"yaw_degrees": 0.0,
		"required_states": ["idle", "run", "attack"],
		"recommended_states": ["hit", "skill", "spawn", "death"],
	},
	"goblin": {
		"scale": Vector3.ONE,
		"offset": Vector3.ZERO,
		"yaw_degrees": 0.0,
		"required_states": ["idle", "run", "attack"],
		"recommended_states": ["hit", "spawn", "death"],
	},
	"bat": {
		"scale": Vector3.ONE,
		"offset": Vector3.ZERO,
		"yaw_degrees": 0.0,
		"required_states": ["idle", "run", "attack"],
		"recommended_states": ["hit", "spawn", "death"],
	},
	"skeleton": {
		"scale": Vector3.ONE,
		"offset": Vector3.ZERO,
		"yaw_degrees": 0.0,
		"required_states": ["idle", "run", "attack"],
		"recommended_states": ["hit", "spawn", "death"],
	},
	"ghoul": {
		"scale": Vector3.ONE,
		"offset": Vector3.ZERO,
		"yaw_degrees": 0.0,
		"required_states": ["idle", "run", "attack"],
		"recommended_states": ["hit", "spawn", "death"],
	},
	"necromancer": {
		"scale": Vector3.ONE,
		"offset": Vector3.ZERO,
		"yaw_degrees": 0.0,
		"required_states": ["idle", "run", "attack"],
		"recommended_states": ["hit", "skill", "spawn", "death"],
	},
	"warden": {
		"scale": Vector3.ONE,
		"offset": Vector3.ZERO,
		"yaw_degrees": 0.0,
		"required_states": ["idle", "run", "attack"],
		"recommended_states": ["hit", "skill", "spawn", "death"],
	},
}

const PRODUCTION_ANIMATION_ALIASES := {
	"idle": ["Idle", "idle", "Idle_A", "BreathingIdle", "Stand"],
	"run": ["Run", "run", "Jog", "Move", "Locomotion"],
	"attack": ["Attack", "attack", "Attack01", "Slash", "MeleeAttack", "PrimaryAttack"],
	"hit": ["Hit", "hit", "HitReact", "Damage", "Hurt"],
	"skill": ["Skill", "skill", "Cast", "Ability", "SpellCast", "Special"],
	"spawn": ["Spawn", "spawn", "Appear", "Intro", "Summon"],
	"death": ["Death", "death", "Die", "Dead", "Death01"],
}

const SOCKET_ALIASES := {
	"weapon": ["WeaponSocket", "weapon_socket", "hand_r", "Hand_R", "RightHand", "weapon_r", "Weapon_R"],
	"offhand": ["OffhandSocket", "offhand_socket", "hand_l", "Hand_L", "LeftHand", "shield", "ShieldSocket"],
	"head": ["HeadSocket", "head_socket", "Head", "head", "Bip01_Head"],
	"chest": ["ChestSocket", "chest_socket", "Chest", "Spine2", "spine_03", "UpperChest"],
	"feet": ["FeetSocket", "feet_socket", "Root", "root", "Hips", "hips"],
	"overhead": ["OverheadSocket", "overhead_socket", "UI_Overhead", "NameplateSocket"],
	"vfx": ["VFXSocket", "vfx_socket", "FXSocket", "EffectSocket", "Spine"],
}

func production_profile(kind: String) -> Dictionary:
	if not PRODUCTION_PROFILES.has(kind):
		return {}
	return PRODUCTION_PROFILES[kind].duplicate(true)

func instantiate_model(kind: String) -> Node3D:
	var root: Node3D = super.instantiate_model(kind)
	if root == null:
		return null
	var profile: Dictionary = production_profile(kind)
	if not profile.is_empty():
		root.scale = profile.get("scale", Vector3.ONE)
		root.position = profile.get("offset", Vector3.ZERO)
		root.rotation_degrees = Vector3(0.0, float(profile.get("yaw_degrees", 0.0)), 0.0)
	root.set_meta("production_profile", kind)
	var report: Dictionary = inspect_model(root, kind)
	root.set_meta("production_model_report", report)
	root.set_meta("production_model_ready", bool(report.get("production_ready", false)))
	return root

func drive_animation(model_root: Node3D, state: String, speed: float = 1.0) -> bool:
	if model_root == null:
		return false
	model_root.set_meta("requested_animation_state", state)
	var player: AnimationPlayer = _find_animation_player(model_root)
	if player != null:
		var clip: String = _resolve_production_clip(player, state)
		if not clip.is_empty():
			player.speed_scale = speed
			if player.current_animation != clip or not player.is_playing():
				player.play(clip, 0.10)
			model_root.set_meta("active_animation_clip", clip)
			return true
	var tree: AnimationTree = _find_animation_tree(model_root)
	if tree != null:
		tree.active = true
		var playback: Variant = tree.get("parameters/playback")
		if playback is AnimationNodeStateMachinePlayback:
			(playback as AnimationNodeStateMachinePlayback).travel(state)
			model_root.set_meta("active_animation_clip", state)
			return true
	return false

func animation_state_available(model_root: Node3D, state: String) -> bool:
	if model_root == null:
		return false
	var player: AnimationPlayer = _find_animation_player(model_root)
	if player != null and not _resolve_production_clip(player, state).is_empty():
		return true
	return _find_animation_tree(model_root) != null

func resolve_socket(model_root: Node3D, logical_name: String) -> Node3D:
	if model_root == null:
		return null
	var aliases: Array = SOCKET_ALIASES.get(logical_name, [logical_name])
	return _find_named_node3d(model_root, aliases)

func inspect_model(model_root: Node3D, kind: String = "") -> Dictionary:
	if model_root == null:
		return {
			"kind": kind,
			"production_ready": false,
			"mesh_count": 0,
			"skeleton_count": 0,
			"animation_driver": false,
			"states": {},
			"sockets": {},
		}
	var mesh_count: int = _count_type_recursive(model_root, "GeometryInstance3D")
	var skeleton_count: int = _count_type_recursive(model_root, "Skeleton3D")
	var animation_driver: bool = _find_animation_player(model_root) != null or _find_animation_tree(model_root) != null
	var states: Dictionary = {}
	for state_value in PRODUCTION_ANIMATION_ALIASES.keys():
		var state: String = String(state_value)
		states[state] = animation_state_available(model_root, state)
	var sockets: Dictionary = {}
	for socket_value in SOCKET_ALIASES.keys():
		var socket_name: String = String(socket_value)
		sockets[socket_name] = resolve_socket(model_root, socket_name) != null

	var profile: Dictionary = production_profile(kind)
	var required_states: Array = profile.get("required_states", ["idle", "run", "attack"])
	var required_ok := true
	for state_value in required_states:
		if not bool(states.get(String(state_value), false)):
			required_ok = false
			break
	var production_ready: bool = mesh_count > 0 and skeleton_count > 0 and animation_driver and required_ok
	return {
		"kind": kind,
		"production_ready": production_ready,
		"mesh_count": mesh_count,
		"skeleton_count": skeleton_count,
		"animation_driver": animation_driver,
		"required_states_ok": required_ok,
		"states": states,
		"sockets": sockets,
	}

func snapshot() -> Dictionary:
	var data: Dictionary = super.snapshot()
	data["production_profiles"] = PRODUCTION_PROFILES.size()
	data["socket_contracts"] = SOCKET_ALIASES.keys()
	data["animation_contract"] = PRODUCTION_ANIMATION_ALIASES.keys()
	var production_ready_count := 0
	var reports: Dictionary = {}
	for kind in actor_kinds():
		if not model_available(kind):
			continue
		var model: Node3D = instantiate_model(kind)
		if model == null:
			continue
		var report: Dictionary = inspect_model(model, kind)
		reports[kind] = report
		if bool(report.get("production_ready", false)):
			production_ready_count += 1
		model.free()
	data["production_ready_count"] = production_ready_count
	data["reports"] = reports
	return data

func _resolve_production_clip(player: AnimationPlayer, state: String) -> String:
	var aliases: Array = PRODUCTION_ANIMATION_ALIASES.get(state, [state])
	for alias_value in aliases:
		var candidate: String = String(alias_value)
		if player.has_animation(candidate):
			return candidate
	return ""

func _find_named_node3d(node: Node, aliases: Array) -> Node3D:
	var own_name: String = String(node.name)
	for alias_value in aliases:
		if own_name.to_lower() == String(alias_value).to_lower() and node is Node3D:
			return node as Node3D
	for child_value in node.get_children():
		var child: Node = child_value as Node
		if child == null:
			continue
		var found: Node3D = _find_named_node3d(child, aliases)
		if found != null:
			return found
	return null

func _count_type_recursive(node: Node, class_name_value: String) -> int:
	var total := 0
	if node.is_class(class_name_value):
		total += 1
	for child_value in node.get_children():
		var child: Node = child_value as Node
		if child != null:
			total += _count_type_recursive(child, class_name_value)
	return total
