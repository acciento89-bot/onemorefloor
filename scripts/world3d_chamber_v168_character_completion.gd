extends "res://scripts/world3d_chamber_v166_character_form.gd"

# ONE MORE FLOOR v1.68 r1.1 — shared Wanderer visual-completion world layer.
# Environments, camera, enemies, combat timing and collision remain inherited;
# only the player actor factory is promoted to the corrected v1.68 authored kit.

const ActorFactoryV168 = preload("res://scripts/world3d_actor_factory_v168_character_completion.gd")
const CHARACTER_COMPLETION_WORLD_VERSION := "1.68-wanderer-visual-completion-r1.1"

func _build_player() -> void:
	actor_factory = ActorFactoryV168.new()
	player_root = actor_factory.create_player(actor_materials)
	add_child(player_root)

func production_character_completion_ready() -> bool:
	return production_environment_depth_ready() \
		and actor_factory != null \
		and actor_factory.has_method("wanderer_completion_v168_ready") \
		and bool(actor_factory.call("wanderer_completion_v168_ready", player_root))

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_character_completion_ready"] = production_character_completion_ready()
	data["production_character_completion_version"] = CHARACTER_COMPLETION_WORLD_VERSION
	if actor_factory != null and actor_factory.has_method("character_quality_snapshot"):
		data["character_completion_v168"] = actor_factory.call("character_quality_snapshot", player_root)
	return data
