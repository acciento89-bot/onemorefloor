extends "res://scripts/main_v52.gd"

# ONE MORE FLOOR v1.40 — authored 3D actors.
# The 3D bridge stays gameplay-passive; this layer only validates the upgraded
# Lower Halls actor presentation and publishes a distinct build context.

const V53_VERSION := "1.40.0-authored-3d-actors"
const V53_BUILD := "26-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V53_VERSION, V53_BUILD)
		telemetry.event("authored_3d_actor_layer_ready", {
			"world_ready": _v53_authored_3d_ready(),
			"pilot_floor_min": V52_PILOT_MIN_FLOOR,
			"pilot_floor_max": V52_PILOT_MAX_FLOOR,
		})

func _v53_authored_3d_ready() -> bool:
	return _v52_world_layer_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("authored_actor_ready") \
		and bool(v52_world_root.call("authored_actor_ready"))
