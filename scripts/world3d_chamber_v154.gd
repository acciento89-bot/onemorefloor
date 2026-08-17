extends "res://scripts/world3d_chamber_v153.gd"

# ONE MORE FLOOR v1.54 — real model intake chamber.
# Gameplay authority, camera and realm presentation remain inherited unchanged.

const RealModelActorFactoryV154 = preload("res://scripts/world3d_actor_factory_v154.gd")

func _build_player() -> void:
	actor_factory = RealModelActorFactoryV154.new()
	player_root = actor_factory.create_player(actor_materials)
	add_child(player_root)

func real_model_intake_ready() -> bool:
	return visual_presentation_ready() \
		and actor_factory != null \
		and actor_factory.has_method("real_model_intake_ready") \
		and bool(actor_factory.call("real_model_intake_ready"))

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["real_model_intake_v154_ready"] = real_model_intake_ready()
	if actor_factory != null and actor_factory.has_method("real_model_intake_snapshot"):
		data["real_model_intake"] = actor_factory.call("real_model_intake_snapshot")
	return data

func real_model_intake_snapshot() -> Dictionary:
	var intake: Dictionary = {}
	if actor_factory != null and actor_factory.has_method("real_model_intake_snapshot"):
		intake = actor_factory.call("real_model_intake_snapshot")
	return {
		"ready": real_model_intake_ready(),
		"intake": intake,
		"visual_presentation": visual_presentation_snapshot(),
	}
