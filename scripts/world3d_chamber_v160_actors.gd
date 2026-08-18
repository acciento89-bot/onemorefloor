extends "res://scripts/world3d_chamber_v160_materials.gd"

# ONE MORE FLOOR v1.60 — production actor presentation world layer.
# Swaps only the actor factory used by the already-proven v1.54 chamber. All
# combat/world authority remains inherited from the v1.60 material stack.

const ActorFactoryV160 = preload("res://scripts/world3d_actor_factory_v160_enemy_quality_r5.gd")
const ACTOR_PRESENTATION_VERSION := "1.60-character-quality-r8.1-hood-r9-enemy-r5"

func _build_player() -> void:
	actor_factory = ActorFactoryV160.new()
	player_root = actor_factory.create_player(actor_materials)
	add_child(player_root)

func production_actor_presentation_ready() -> bool:
	return production_material_depth_ready() \
		and actor_factory != null \
		and actor_factory.has_method("v160_wanderer_presentation_ready") \
		and bool(actor_factory.call("v160_wanderer_presentation_ready", player_root)) \
		and actor_factory.has_method("v160_authored_wanderer_ready") \
		and bool(actor_factory.call("v160_authored_wanderer_ready", player_root)) \
		and actor_factory.has_method("enemy_presentation_pipeline_ready") \
		and bool(actor_factory.call("enemy_presentation_pipeline_ready")) \
		and actor_factory.has_method("character_quality_pipeline_ready") \
		and bool(actor_factory.call("character_quality_pipeline_ready")) \
		and actor_factory.has_method("character_quality_player_ready") \
		and bool(actor_factory.call("character_quality_player_ready", player_root))

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_actor_presentation_ready"] = production_actor_presentation_ready()
	data["production_actor_presentation_version"] = ACTOR_PRESENTATION_VERSION
	data["production_enemy_presentation_pipeline_ready"] = actor_factory != null \
		and actor_factory.has_method("enemy_presentation_pipeline_ready") \
		and bool(actor_factory.call("enemy_presentation_pipeline_ready"))
	if actor_factory != null and actor_factory.has_method("enemy_lookdev_snapshot"):
		data["enemy_v160_lookdev"] = actor_factory.call("enemy_lookdev_snapshot")
	if actor_factory != null and actor_factory.has_method("v160_wanderer_presentation_snapshot"):
		data["wanderer_v160"] = actor_factory.call("v160_wanderer_presentation_snapshot", player_root)
	if actor_factory != null and actor_factory.has_method("v160_wanderer_polish_snapshot"):
		data["wanderer_v160_polish"] = actor_factory.call("v160_wanderer_polish_snapshot", player_root)
	if actor_factory != null and actor_factory.has_method("v160_authored_wanderer_snapshot"):
		data["wanderer_v160_authored"] = actor_factory.call("v160_authored_wanderer_snapshot", player_root)
	if actor_factory != null and actor_factory.has_method("character_quality_snapshot"):
		data["character_quality_v160"] = actor_factory.call("character_quality_snapshot", player_root)
	return data
