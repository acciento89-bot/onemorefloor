extends "res://scripts/main_v59.gd"

# ONE MORE FLOOR v1.47 - Actor Production Pipeline.
# Keeps the complete v1.46 vertical slice and upgrades the actor/model layer
# without changing gameplay authority, touch geometry or the 2D HUD/menu stack.

const ActorProductionWorld3DChamber = preload("res://scripts/world3d_chamber_v147.gd")
const V60_VERSION := "1.47.0-actor-production-pipeline"
const V60_BUILD := "33-dev"
const V60_3D_MIN_FLOOR := 1
const V60_3D_MAX_FLOOR := 50

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V60_VERSION, V60_BUILD)
		telemetry.event("actor_production_pipeline_ready", {
			"world_ready": _v60_actor_production_ready(),
			"floor_min": V60_3D_MIN_FLOOR,
			"floor_max": V60_3D_MAX_FLOOR,
			"realms": 5,
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

	v52_world_root = ActorProductionWorld3DChamber.new()
	v52_world_root.name = "Tower3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v52_3d_active() -> bool:
	if state != State.RUNNING or run == null:
		return false
	var floor_no: int = int(run.floor_no)
	return floor_no >= V60_3D_MIN_FLOOR and floor_no <= V60_3D_MAX_FLOOR

func _v60_actor_production_ready() -> bool:
	return _v59_production_slice_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("actor_production_ready") \
		and bool(v52_world_root.call("actor_production_ready"))
