extends "res://scripts/main_v80.gd"

# ONE MORE FLOOR v1.63 r1 — projectile/trail identity integration.
# Keeps the accepted v1.62 UI top layer and swaps only the 3D combat-world
# presentation class. No release metadata/build number is changed here.

const CombatIdentityWorldV163 = preload("res://scripts/world3d_chamber_v163_projectile_identity.gd")
const V82_FEATURE := "1.63-projectile-identity-r1"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.event("combat_identity_v163_ready", _v82_combat_identity_snapshot())

func _v52_create_world_viewport() -> void:
	# Mirrors the accepted v1.61 viewport setup exactly; only the world class is
	# replaced by the narrow v1.63 presentation subclass.
	v52_world_viewport = SubViewport.new()
	v52_world_viewport.name = "Combat3DViewport"
	v52_world_viewport.size = Vector2i(int(ARENA.size.x), int(ARENA.size.y))
	v52_world_viewport.own_world_3d = true
	v52_world_viewport.transparent_bg = false
	v52_world_viewport.disable_3d = false
	v52_world_viewport.msaa_3d = Viewport.MSAA_2X
	v52_world_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(v52_world_viewport)

	v52_world_root = CombatIdentityWorldV163.new()
	v52_world_root.name = "CombatIdentity3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v82_projectile_identity_ready() -> bool:
	return _v80_runtime_cta_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("production_projectile_identity_ready") \
		and bool(v52_world_root.call("production_projectile_identity_ready"))

func _v82_combat_identity_snapshot() -> Dictionary:
	var world_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("debug_snapshot"):
		world_snapshot = v52_world_root.call("debug_snapshot")
	return {
		"ready": _v82_projectile_identity_ready(),
		"feature": V82_FEATURE,
		"ui_r3_preserved": _v80_runtime_cta_ready(),
		"world": world_snapshot,
	}
