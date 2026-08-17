extends "res://scripts/main_v66.gd"

# ONE MORE FLOOR v1.53 — 3D visual presentation pass.
# The tested v1.52 combat authority and v1.52.1 input fixes remain unchanged.
# This version replaces only the visible native 3D actor surface with smoother
# PBR silhouettes and shadow-casting geometry while preserving imported GLBs.

const VisualPresentationWorld3DChamber = preload("res://scripts/world3d_chamber_v153.gd")
const V67_VERSION := "1.53.0-3d-visual-presentation"
const V67_BUILD := "40-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V67_VERSION, V67_BUILD)
		telemetry.event("visual_presentation_3d_ready", {
			"world_ready": _v67_3d_visual_presentation_ready(),
			"mode": "smooth_pbr_native_fallback",
			"imported_glb_preferred": true,
			"shadow_casting": true,
			"gameplay_authority": "v1.52_unchanged",
			"input_hotfix": "v1.52.1_unchanged",
		})

# Keep the exact viewport contract established by v1.52, swapping only the world
# implementation so all inherited touch/projectile/query authority still routes
# through the same v52_world_root reference.
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

	v52_world_root = VisualPresentationWorld3DChamber.new()
	v52_world_root.name = "Tower3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v67_3d_visual_presentation_ready() -> bool:
	return _v65_3d_combat_core_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("visual_presentation_ready") \
		and bool(v52_world_root.call("visual_presentation_ready"))

func _v67_visual_presentation_snapshot() -> Dictionary:
	var world_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("visual_presentation_snapshot"):
		world_snapshot = v52_world_root.call("visual_presentation_snapshot")
	return {
		"ready": _v67_3d_visual_presentation_ready(),
		"version": V67_VERSION,
		"build": V67_BUILD,
		"mode": "smooth_pbr_native_fallback",
		"imported_glb_preferred": true,
		"gameplay_authority_ready": _v65_3d_combat_core_ready(),
		"input_flow_snapshot": _v66_input_flow_snapshot(),
		"world": world_snapshot,
	}
