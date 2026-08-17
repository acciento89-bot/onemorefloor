extends "res://scripts/main_v56.gd"

# ONE MORE FLOOR v1.44 - Iron Bastion 3D rollout.
# Production 3D now covers floors 1-30. The chamber swaps realm presentation
# at floors 11 and 21 while gameplay/runtime authority remains unchanged.

const IronBastionWorld3DChamber = preload("res://scripts/world3d_chamber_v144.gd")
const V57_VERSION := "1.44.0-iron-bastion-3d"
const V57_BUILD := "30-dev"
const V57_3D_MIN_FLOOR := 1
const V57_3D_MAX_FLOOR := 30

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V57_VERSION, V57_BUILD)
		telemetry.event("iron_bastion_3d_rollout_ready", {
			"world_ready": _v57_iron_bastion_world_ready(),
			"floor_min": V57_3D_MIN_FLOOR,
			"floor_max": V57_3D_MAX_FLOOR,
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

	v52_world_root = IronBastionWorld3DChamber.new()
	v52_world_root.name = "Tower3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v52_3d_active() -> bool:
	if state != State.RUNNING or run == null:
		return false
	var floor_no: int = int(run.floor_no)
	return floor_no >= V57_3D_MIN_FLOOR and floor_no <= V57_3D_MAX_FLOOR

func _v57_iron_bastion_world_ready() -> bool:
	return _v56_ossuary_world_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("iron_bastion_ready") \
		and bool(v52_world_root.call("iron_bastion_ready"))
