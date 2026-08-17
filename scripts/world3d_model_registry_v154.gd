extends "res://scripts/world3d_model_registry_v147.gd"

# ONE MORE FLOOR v1.54 — real-model intake.
# Production actors can arrive as either binary GLB or text glTF. Animation
# lookup also tolerates common exporter naming conventions while preserving the
# v1.47 production socket/animation contract used by the actor factory.

const REGISTRY_VERSION := "1.54.0-real-model-intake"
const DEFAULT_MODEL_ROOT := "res://assets/models/actors"
const FUZZY_ANIMATION_TOKENS := {
	"idle": ["idle", "breath", "stand", "standing"],
	"run": ["run", "running", "jog", "jogging", "sprint", "locomotion", "walk"],
	"attack": ["attack", "slash", "melee", "swing", "strike", "slice"],
	"hit": ["hit", "hurt", "damage", "impact", "react"],
	"skill": ["skill", "cast", "spell", "ability", "magic"],
}

var model_root := DEFAULT_MODEL_ROOT

func _init(root_override: String = "") -> void:
	if not root_override.strip_edges().is_empty():
		model_root = root_override.trim_suffix("/")

func candidate_paths(kind: String) -> Array[String]:
	var result: Array[String] = []
	if not known_kind(kind):
		return result
	var base := "%s/%s" % [model_root, kind]
	result.append(base + ".glb")
	result.append(base + ".gltf")
	return result

func resolved_asset_path(kind: String) -> String:
	for candidate in candidate_paths(kind):
		if ResourceLoader.exists(candidate):
			return candidate
	return ""

func asset_path(kind: String) -> String:
	var resolved := resolved_asset_path(kind)
	if not resolved.is_empty():
		return resolved
	var candidates := candidate_paths(kind)
	return candidates[0] if not candidates.is_empty() else ""

func model_available(kind: String) -> bool:
	return not resolved_asset_path(kind).is_empty()

func instantiate_model(kind: String) -> Node3D:
	var path := resolved_asset_path(kind)
	if path.is_empty():
		return null
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
	root.set_meta("model_format", path.get_extension().to_lower())
	root.set_meta("rigged_import", true)
	return root

func resolve_animation_clip(player: AnimationPlayer, state: String) -> String:
	return _resolve_clip(player, state)

# world3d_actor_factory_v147 drives imported models through the production
# registry API. Keep that path on the v1.54 fuzzy resolver instead of falling
# back to the older exact-name-only clip lookup.
func _resolve_production_clip(player: AnimationPlayer, state: String) -> String:
	return _resolve_clip(player, state)

func snapshot() -> Dictionary:
	var data: Dictionary = super.snapshot()
	var formats := {"glb": 0, "gltf": 0}
	var resolved_paths := {}
	for kind in actor_kinds():
		var path := resolved_asset_path(kind)
		if path.is_empty():
			continue
		resolved_paths[kind] = path
		var extension := path.get_extension().to_lower()
		if formats.has(extension):
			formats[extension] = int(formats[extension]) + 1
	data["registry_version"] = REGISTRY_VERSION
	data["model_root"] = model_root
	data["supported_formats"] = ["glb", "gltf"]
	data["resolved_paths"] = resolved_paths
	data["formats"] = formats
	return data

func _resolve_clip(player: AnimationPlayer, state: String) -> String:
	var aliases: Array = ANIMATION_ALIASES.get(state, [state])
	for alias in aliases:
		var candidate := String(alias)
		if player.has_animation(candidate):
			return candidate

	var tokens: Array = FUZZY_ANIMATION_TOKENS.get(state, [state])
	var best_clip := ""
	var best_score := -1
	for clip_value in player.get_animation_list():
		var clip := String(clip_value)
		var normalized := _normalize_clip_name(clip)
		for token_value in tokens:
			var token := _normalize_clip_name(String(token_value))
			if token.is_empty() or normalized.find(token) < 0:
				continue
			var score := token.length() * 10
			if normalized == token:
				score += 1000
			elif normalized.ends_with(token) or normalized.begins_with(token):
				score += 120
			score -= maxi(0, normalized.length() - token.length())
			if score > best_score:
				best_score = score
				best_clip = clip
	return best_clip

func _normalize_clip_name(value: String) -> String:
	var result := value.to_lower()
	for separator in ["|", "-", " ", ".", ":", "/", "\\"]:
		result = result.replace(separator, "_")
	while result.find("__") >= 0:
		result = result.replace("__", "_")
	return result.strip_edges().trim_prefix("_").trim_suffix("_")
