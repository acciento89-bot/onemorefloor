extends "res://scripts/main_v85.gd"

# ONE MORE FLOOR v1.65 r1.1 — active Environment Surface & Depth top layer.
# Keeps the accepted v1.64 character-lighting + v1.63 combat/UI/gameplay stack
# and swaps only the 3D presentation world to the corrected v1.65 environment pass.

const EnvironmentDepthWorldV165 = preload("res://scripts/world3d_chamber_v165_environment_depth_r11.gd")
const V86_FEATURE := "1.65-environment-depth-r1.1"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.event("environment_depth_v165_ready", _v86_environment_depth_snapshot())

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

	v52_world_root = EnvironmentDepthWorldV165.new()
	v52_world_root.name = "EnvironmentDepth3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v86_environment_depth_ready() -> bool:
	return _v85_character_lighting_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("production_environment_depth_ready") \
		and bool(v52_world_root.call("production_environment_depth_ready"))

func _v86_environment_depth_snapshot() -> Dictionary:
	var world_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("debug_snapshot"):
		world_snapshot = v52_world_root.call("debug_snapshot")
	return {
		"ready": _v86_environment_depth_ready(),
		"feature": V86_FEATURE,
		"character_lighting_r11_preserved": _v85_character_lighting_ready(),
		"boss_r21_preserved": _v84_boss_dominance_ready(),
		"projectile_r1_preserved": _v82_projectile_identity_ready(),
		"ui_r3_preserved": _v80_runtime_cta_ready(),
		"world": world_snapshot,
	}
