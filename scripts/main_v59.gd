extends "res://scripts/main_v58.gd"

# ONE MORE FLOOR v1.46 - Production vertical slice.
# Keeps the complete 1-50 3D tower and layers cinematic/combat presentation
# upgrades on top without changing gameplay authority.

const ProductionSliceWorld3DChamber = preload("res://scripts/world3d_chamber_v146.gd")
const V59_VERSION := "1.46.0-production-vertical-slice"
const V59_BUILD := "32-dev"
const V59_3D_MIN_FLOOR := 1
const V59_3D_MAX_FLOOR := 50

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V59_VERSION, V59_BUILD)
		telemetry.event("production_vertical_slice_ready", {
			"world_ready": _v59_production_slice_ready(),
			"floor_min": V59_3D_MIN_FLOOR,
			"floor_max": V59_3D_MAX_FLOOR,
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

	v52_world_root = ProductionSliceWorld3DChamber.new()
	v52_world_root.name = "Tower3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v52_3d_active() -> bool:
	if state != State.RUNNING or run == null:
		return false
	var floor_no: int = int(run.floor_no)
	return floor_no >= V59_3D_MIN_FLOOR and floor_no <= V59_3D_MAX_FLOOR

func _v59_production_slice_ready() -> bool:
	return _v58_full_tower_world_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("production_slice_ready") \
		and bool(v52_world_root.call("production_slice_ready"))
