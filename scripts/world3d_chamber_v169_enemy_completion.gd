extends "res://scripts/world3d_chamber_v168_character_completion.gd"

# ONE MORE FLOOR v1.69 r1 — Enemy + Boss Visual Completion world layer.
# Environment, accepted v1.68 Wanderer, camera, combat, collision and timing stay
# inherited. Only the combat-world actor factory is promoted so enemies receive
# the authored v1.69 secondary silhouette kits.

const ActorFactoryV169 = preload("res://scripts/world3d_actor_factory_v169_enemy_completion.gd")
const ENEMY_COMPLETION_WORLD_V169_VERSION := "1.69-enemy-boss-visual-completion-r1"

func _build_player() -> void:
	actor_factory = ActorFactoryV169.new()
	player_root = actor_factory.create_player(actor_materials)
	add_child(player_root)

func production_enemy_completion_ready() -> bool:
	return production_character_completion_ready() \
		and actor_factory != null \
		and actor_factory.has_method("enemy_completion_pipeline_v169_ready") \
		and bool(actor_factory.call("enemy_completion_pipeline_v169_ready"))

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_enemy_completion_ready"] = production_enemy_completion_ready()
	data["production_enemy_completion_version"] = ENEMY_COMPLETION_WORLD_V169_VERSION
	return data
