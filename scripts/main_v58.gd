extends "res://scripts/main_v57.gd"

# ONE MORE FLOOR v1.45 - Full Tower 3D completion.
# Production 3D now covers the complete original floor 1-50 tower with
# realm switches at floors 11, 21, 31 and 41.

const FullTowerWorld3DChamber = preload("res://scripts/world3d_chamber_v145.gd")
const V58_VERSION := "1.45.0-full-tower-3d"
const V58_BUILD := "31-dev"
const V58_3D_MIN_FLOOR := 1
const V58_3D_MAX_FLOOR := 50

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V58_VERSION, V58_BUILD)
		telemetry.event("full_tower_3d_rollout_ready", {
			"world_ready": _v58_full_tower_world_ready(),
			"floor_min": V58_3D_MIN_FLOOR,
			"floor_max": V58_3D_MAX_FLOOR,
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

	v52_world_root = FullTowerWorld3DChamber.new()
	v52_world_root.name = "Tower3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v52_3d_active() -> bool:
	if state != State.RUNNING or run == null:
		return false
	var floor_no: int = int(run.floor_no)
	return floor_no >= V58_3D_MIN_FLOOR and floor_no <= V58_3D_MAX_FLOOR

func _v58_full_tower_world_ready() -> bool:
	return _v57_iron_bastion_world_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("full_tower_ready") \
		and bool(v52_world_root.call("full_tower_ready"))
