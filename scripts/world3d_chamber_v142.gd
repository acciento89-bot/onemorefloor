extends "res://scripts/world3d_chamber_v141.gd"

# ONE MORE FLOOR v1.42 - rigged model pipeline chamber.
# v1.41 presentation stays intact; this layer swaps the actor factory at the
# player build point so future imported GLB rigs plug into the same world.

const RigActorFactory = preload("res://scripts/world3d_actor_factory_v142.gd")

func _build_player() -> void:
	actor_factory = RigActorFactory.new()
	super._build_player()

func rig_pipeline_ready() -> bool:
	return production_quality_ready() \
		and actor_factory.has_method("model_pipeline_ready") \
		and bool(actor_factory.call("model_pipeline_ready", player_root)) \
		and actor_factory.has_method("model_registry_snapshot")

func model_registry_snapshot() -> Dictionary:
	if not actor_factory.has_method("model_registry_snapshot"):
		return {}
	var data: Dictionary = actor_factory.call("model_registry_snapshot")
	return data

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	var registry: Dictionary = model_registry_snapshot()
	var known: Array = registry.get("known", [])
	data["rig_pipeline"] = rig_pipeline_ready()
	data["model_known_count"] = known.size()
	data["model_available_count"] = int(registry.get("available_count", 0))
	data["model_fallback_count"] = int(registry.get("fallback_count", 0))
	data["player_model_source"] = String(player_root.get_meta("model_source", "")) if player_root != null else ""
	return data
