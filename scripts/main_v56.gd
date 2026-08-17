extends "res://scripts/main_v55.gd"

# ONE MORE FLOOR v1.43 - Ossuary 3D rollout.
# Floors 1-20 now share the production 3D bridge; the chamber swaps realm kits
# at floor 11 while gameplay/runtime authority remains untouched.

const OssuaryWorld3DChamber = preload("res://scripts/world3d_chamber_v143.gd")
const V56_VERSION := "1.43.0-ossuary-3d"
const V56_BUILD := "29-dev"
const V56_3D_MIN_FLOOR := 1
const V56_3D_MAX_FLOOR := 20

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V56_VERSION, V56_BUILD)
		telemetry.event("ossuary_3d_rollout_ready", {
			"world_ready": _v56_ossuary_world_ready(),
			"floor_min": V56_3D_MIN_FLOOR,
			"floor_max": V56_3D_MAX_FLOOR,
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

	v52_world_root = OssuaryWorld3DChamber.new()
	v52_world_root.name = "Tower3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v52_3d_active() -> bool:
	if state != State.RUNNING or run == null:
		return false
	var floor_no := int(run.floor_no)
	return floor_no >= V56_3D_MIN_FLOOR and floor_no <= V56_3D_MAX_FLOOR

func _v56_ossuary_world_ready() -> bool:
	return _v55_rig_pipeline_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("ossuary_ready") \
		and bool(v52_world_root.call("ossuary_ready"))
