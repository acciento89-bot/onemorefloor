extends "res://scripts/main_v61.gd"

# ONE MORE FLOOR v1.49 - Production Art & Lookdev.
# Keeps floors 1-50 in the established 3D bridge and upgrades actor art quality,
# asset validation, grounding and realm-aware lighting without gameplay changes.

const ProductionArtWorld3DChamber = preload("res://scripts/world3d_chamber_v149.gd")
const V62_VERSION := "1.49.0-production-art-lookdev"
const V62_BUILD := "35-dev"
const V62_3D_MIN_FLOOR := 1
const V62_3D_MAX_FLOOR := 50

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V62_VERSION, V62_BUILD)
		telemetry.event("production_art_lookdev_ready", {
			"world_ready": _v62_production_art_lookdev_ready(),
			"floor_min": V62_3D_MIN_FLOOR,
			"floor_max": V62_3D_MAX_FLOOR,
			"realms": 5,
			"asset_profiles": 7,
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

	v52_world_root = ProductionArtWorld3DChamber.new()
	v52_world_root.name = "Tower3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v52_3d_active() -> bool:
	if state != State.RUNNING or run == null:
		return false
	var floor_no: int = int(run.floor_no)
	return floor_no >= V62_3D_MIN_FLOOR and floor_no <= V62_3D_MAX_FLOOR

func _v62_production_art_lookdev_ready() -> bool:
	return _v61_character_combat_vfx_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("production_art_lookdev_ready") \
		and bool(v52_world_root.call("production_art_lookdev_ready"))
