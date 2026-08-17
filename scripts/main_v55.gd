extends "res://scripts/main_v54.gd"

# ONE MORE FLOOR v1.42 - rigged production model pipeline.
# Gameplay remains authoritative in the inherited runtime. The active 3D world
# now exposes stable rig mounts and optional GLB/AnimationPlayer integration.

const RigReadyWorld3DChamber = preload("res://scripts/world3d_chamber_v142.gd")
const V55_VERSION := "1.42.0-rigged-model-pipeline"
const V55_BUILD := "28-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V55_VERSION, V55_BUILD)
		var registry: Dictionary = _v55_model_registry_snapshot()
		telemetry.event("rigged_model_pipeline_ready", {
			"world_ready": _v55_rig_pipeline_ready(),
			"known_models": (registry.get("known", []) as Array).size(),
			"available_models": int(registry.get("available_count", 0)),
			"fallback_models": int(registry.get("fallback_count", 0)),
		})

func _v52_create_world_viewport() -> void:
	v52_world_viewport = SubViewport.new()
	v52_world_viewport.name = "Combat3DViewport"
	v52_world_viewport.size = Vector2i(int(ARENA.size.x), int(ARENA.size.y))
	v52_world_viewport.own_world_3d = true
	v52_world_viewport.transparent_bg = false
	v52_world_viewport.disable_3d = false
	v52_world_viewport.msaa_3d = Viewport.MSAA_2X
	v52_world_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(v52_world_viewport)

	v52_world_root = RigReadyWorld3DChamber.new()
	v52_world_root.name = "LowerHalls3DRigReady"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v55_rig_pipeline_ready() -> bool:
	return _v54_production_quality_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("rig_pipeline_ready") \
		and bool(v52_world_root.call("rig_pipeline_ready"))

func _v55_model_registry_snapshot() -> Dictionary:
	if v52_world_root == null or not v52_world_root.has_method("model_registry_snapshot"):
		return {}
	var data: Dictionary = v52_world_root.call("model_registry_snapshot")
	return data
