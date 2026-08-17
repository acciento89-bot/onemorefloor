extends "res://scripts/world3d_actor_factory_v153.gd"

# ONE MORE FLOOR v1.54 — imported real-model intake on top of the v1.53
# presentation fallback. Once a wanderer/enemy .glb or .gltf exists, the
# inherited rig mount hides the native fallback automatically.

const RealModelRegistryV154 = preload("res://scripts/world3d_model_registry_v154.gd")
const MODEL_INTAKE_VERSION := "1.54.0-real-model-intake"

func _init() -> void:
	super._init()
	model_registry = RealModelRegistryV154.new()

func real_model_intake_ready() -> bool:
	return model_registry != null \
		and model_registry.has_method("candidate_paths") \
		and model_registry.has_method("resolved_asset_path")

func real_model_intake_snapshot() -> Dictionary:
	var registry_snapshot: Dictionary = {}
	if model_registry != null:
		registry_snapshot = model_registry.snapshot()
	return {
		"ready": real_model_intake_ready(),
		"version": MODEL_INTAKE_VERSION,
		"registry": registry_snapshot,
		"fallback": "v1.53-smooth-pbr",
	}
