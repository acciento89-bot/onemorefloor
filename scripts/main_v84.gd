extends "res://scripts/main_v83.gd"

# ONE MORE FLOOR v1.63 r2.1 — active boss-dominance correction integration.
# Keeps r2's quieter v1.46 frame and swaps only the combat world to the layer
# that fixes the actual v1.49 BossDominanceLookdev owner.

const BossDominanceWorldV163 = preload("res://scripts/world3d_chamber_v163_boss_dominance.gd")
const V84_FEATURE := "1.63-boss-dominance-r2.1"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.event("boss_dominance_v163_ready", _v84_boss_dominance_snapshot())

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

	v52_world_root = BossDominanceWorldV163.new()
	v52_world_root.name = "BossDominance3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v84_boss_dominance_ready() -> bool:
	return _v83_boss_identity_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("production_boss_dominance_ready") \
		and bool(v52_world_root.call("production_boss_dominance_ready"))

func _v84_boss_dominance_snapshot() -> Dictionary:
	var world_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("debug_snapshot"):
		world_snapshot = v52_world_root.call("debug_snapshot")
	return {
		"ready": _v84_boss_dominance_ready(),
		"feature": V84_FEATURE,
		"boss_r2_preserved": _v83_boss_identity_ready(),
		"projectile_r1_preserved": _v82_projectile_identity_ready(),
		"ui_r3_preserved": _v80_runtime_cta_ready(),
		"world": world_snapshot,
	}
