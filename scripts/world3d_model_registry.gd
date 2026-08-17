extends RefCounted

# ONE MORE FLOOR v1.42 — production model registry.
# The game can now accept imported .glb actor scenes without changing combat
# code. Missing assets fail closed to the existing native 3D actors.

const MODEL_DEFINITIONS := {
	"wanderer": {
		"scene": "res://assets/models/actors/wanderer.glb",
		"scale": Vector3(1.0, 1.0, 1.0),
		"offset": Vector3.ZERO,
	},
	"goblin": {
		"scene": "res://assets/models/actors/goblin.glb",
		"scale": Vector3(1.0, 1.0, 1.0),
		"offset": Vector3.ZERO,
	},
	"bat": {
		"scene": "res://assets/models/actors/bat.glb",
		"scale": Vector3(1.0, 1.0, 1.0),
		"offset": Vector3.ZERO,
	},
	"skeleton": {
		"scene": "res://assets/models/actors/skeleton.glb",
		"scale": Vector3(1.0, 1.0, 1.0),
		"offset": Vector3.ZERO,
	},
	"ghoul": {
		"scene": "res://assets/models/actors/ghoul.glb",
		"scale": Vector3(1.0, 1.0, 1.0),
		"offset": Vector3.ZERO,
	},
	"necromancer": {
		"scene": "res://assets/models/actors/necromancer.glb",
		"scale": Vector3(1.0, 1.0, 1.0),
		"offset": Vector3.ZERO,
	},
	"warden": {
		"scene": "res://assets/models/actors/warden.glb",
		"scale": Vector3(1.0, 1.0, 1.0),
		"offset": Vector3.ZERO,
	},
}

const ANIMATION_ALIASES := {
	"idle": ["Idle", "idle", "Idle_A", "BreathingIdle"],
	"run": ["Run", "run", "Jog", "Move"],
	"attack": ["Attack", "attack", "Attack01", "Slash", "MeleeAttack"],
	"hit": ["Hit", "hit", "HitReact", "Damage"],
	"skill": ["Skill", "skill", "Cast", "Ability", "SpellCast"],
}

func known_kind(kind: String) -> bool:
	return MODEL_DEFINITIONS.has(kind)

func actor_kinds() -> Array[String]:
	var result: Array[String] = []
	for key in MODEL_DEFINITIONS.keys():
		result.append(String(key))
	result.sort()
	return result

func asset_path(kind: String) -> String:
	if not known_kind(kind):
		return ""
	var definition: Dictionary = MODEL_DEFINITIONS[kind]
	return String(definition.get("scene", ""))

func model_available(kind: String) -> bool:
	var path := asset_path(kind)
	return not path.is_empty() and ResourceLoader.exists(path)

func instantiate_model(kind: String) -> Node3D:
	if not model_available(kind):
		return null
	var path := asset_path(kind)
	var resource: Resource = load(path)
	if not resource is PackedScene:
		return null
	var instance: Node = (resource as PackedScene).instantiate()
	if not instance is Node3D:
		instance.queue_free()
		return null
	var root := instance as Node3D
	var definition: Dictionary = MODEL_DEFINITIONS[kind]
	root.name = "ImportedModel"
	root.scale = definition.get("scale", Vector3.ONE)
	root.position = definition.get("offset", Vector3.ZERO)
	root.set_meta("model_kind", kind)
	root.set_meta("model_asset_path", path)
	root.set_meta("rigged_import", true)
	return root

func drive_animation(model_root: Node3D, state: String, speed: float = 1.0) -> bool:
	if model_root == null:
		return false
	model_root.set_meta("requested_animation_state", state)
	var player := _find_animation_player(model_root)
	if player != null:
		var clip := _resolve_clip(player, state)
		if not clip.is_empty():
			player.speed_scale = speed
			if player.current_animation != clip or not player.is_playing():
				player.play(clip, 0.12)
			return true
	var tree := _find_animation_tree(model_root)
	if tree != null:
		tree.active = true
		var playback: Variant = tree.get("parameters/playback")
		if playback is AnimationNodeStateMachinePlayback:
			(playback as AnimationNodeStateMachinePlayback).travel(state)
			return true
	return false

func snapshot() -> Dictionary:
	var available: Array[String] = []
	for kind in actor_kinds():
		if model_available(kind):
			available.append(kind)
	return {
		"known": actor_kinds(),
		"available": available,
		"available_count": available.size(),
		"fallback_count": actor_kinds().size() - available.size(),
	}

func _resolve_clip(player: AnimationPlayer, state: String) -> String:
	var aliases: Array = ANIMATION_ALIASES.get(state, [state])
	for alias in aliases:
		var candidate := String(alias)
		if player.has_animation(candidate):
			return candidate
	return ""

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null

func _find_animation_tree(node: Node) -> AnimationTree:
	if node is AnimationTree:
		return node as AnimationTree
	for child in node.get_children():
		var found := _find_animation_tree(child)
		if found != null:
			return found
	return null
