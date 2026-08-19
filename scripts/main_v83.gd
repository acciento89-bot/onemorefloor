extends "res://scripts/main_v82.gd"

# ONE MORE FLOOR v1.63 r2 — boss presentation identity integration.
# Preserves the accepted r1 projectile identity and v1.62 UI top layer while
# replacing only the 3D combat-world presentation class.

const BossIdentityWorldV163 = preload("res://scripts/world3d_chamber_v163_boss_identity.gd")
const V83_FEATURE := "1.63-boss-identity-r2"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.event("boss_identity_v163_ready", _v83_boss_identity_snapshot())

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

	v52_world_root = BossIdentityWorldV163.new()
	v52_world_root.name = "BossIdentity3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v83_boss_identity_ready() -> bool:
	return _v82_projectile_identity_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("production_boss_identity_ready") \
		and bool(v52_world_root.call("production_boss_identity_ready"))

func _v83_boss_identity_snapshot() -> Dictionary:
	var world_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("debug_snapshot"):
		world_snapshot = v52_world_root.call("debug_snapshot")
	return {
		"ready": _v83_boss_identity_ready(),
		"feature": V83_FEATURE,
		"projectile_r1_preserved": _v82_projectile_identity_ready(),
		"ui_r3_preserved": _v80_runtime_cta_ready(),
		"world": world_snapshot,
	}
