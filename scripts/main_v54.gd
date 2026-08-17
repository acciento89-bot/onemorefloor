extends "res://scripts/main_v53.gd"

# ONE MORE FLOOR v1.41 — 3D Production Quality Pass.
# Reuses the proven v1.39 combat bridge and v1.40 authored actors, but swaps the
# Lower Halls renderer to the production-quality chamber implementation.

const ProductionWorld3DChamber = preload("res://scripts/world3d_chamber_v141.gd")
const V54_VERSION := "1.41.0-3d-production-quality"
const V54_BUILD := "27-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V54_VERSION, V54_BUILD)
		telemetry.event("production_3d_quality_ready", {
			"world_ready": _v54_production_quality_ready(),
			"pilot_floor_min": V52_PILOT_MIN_FLOOR,
			"pilot_floor_max": V52_PILOT_MAX_FLOOR,
		})

# This override is intentionally called from the inherited v1.39 _ready().
# Gameplay/state synchronization remains untouched; only the presentation node
# created inside the SubViewport changes.
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

	v52_world_root = ProductionWorld3DChamber.new()
	v52_world_root.name = "LowerHalls3DProduction"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v54_production_quality_ready() -> bool:
	return _v53_authored_3d_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("production_quality_ready") \
		and bool(v52_world_root.call("production_quality_ready"))
