extends "res://scripts/world3d_chamber_v165_environment_depth_r13.gd"

# ONE MORE FLOOR v1.66 r1 — Character Form & Readability world layer.
# Keeps the accepted v1.65 r1.3 environment, camera and all gameplay authority;
# only the actor factory is promoted to the presentation-only v1.66 form pass.

const ActorFactoryV166 = preload("res://scripts/world3d_actor_factory_v166_character_form.gd")
const CHARACTER_FORM_WORLD_VERSION := "1.66-character-form-r1"

func _build_player() -> void:
	actor_factory = ActorFactoryV166.new()
	player_root = actor_factory.create_player(actor_materials)
	add_child(player_root)

func production_character_form_ready() -> bool:
	return production_environment_depth_ready() \
		and actor_factory != null \
		and actor_factory.has_method("character_form_pipeline_ready") \
		and bool(actor_factory.call("character_form_pipeline_ready")) \
		and actor_factory.has_method("v166_character_form_player_ready") \
		and bool(actor_factory.call("v166_character_form_player_ready", player_root))

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_character_form_ready"] = production_character_form_ready()
	data["production_character_form_version"] = CHARACTER_FORM_WORLD_VERSION
	if actor_factory != null and actor_factory.has_method("character_quality_snapshot"):
		data["character_form_v166"] = actor_factory.call("character_quality_snapshot", player_root)
	return data
