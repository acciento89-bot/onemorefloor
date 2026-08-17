extends "res://scripts/main_v67.gd"

# ONE MORE FLOOR v1.54 — production GLB/glTF model intake.
# v1.53 smooth PBR actors remain the fallback until real assets are present.

const RealModelWorld3DChamberV154 = preload("res://scripts/world3d_chamber_v154.gd")
const V68_VERSION := "1.54.0-real-model-intake"
const V68_BUILD := "41-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V68_VERSION, V68_BUILD)
		telemetry.event("real_model_intake_ready", {
			"ready": _v68_real_model_intake_ready(),
			"formats": ["glb", "gltf"],
			"fallback": "v1.53-smooth-pbr",
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

	v52_world_root = RealModelWorld3DChamberV154.new()
	v52_world_root.name = "Tower3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v68_real_model_intake_ready() -> bool:
	return _v67_3d_visual_presentation_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("real_model_intake_ready") \
		and bool(v52_world_root.call("real_model_intake_ready"))

func _v68_real_model_intake_snapshot() -> Dictionary:
	var world_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("real_model_intake_snapshot"):
		world_snapshot = v52_world_root.call("real_model_intake_snapshot")
	return {
		"ready": _v68_real_model_intake_ready(),
		"version": V68_VERSION,
		"build": V68_BUILD,
		"world": world_snapshot,
		"visual_presentation": _v67_visual_presentation_snapshot(),
	}
