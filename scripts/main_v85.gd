extends "res://scripts/main_v84.gd"

# ONE MORE FLOOR v1.64 r1 — active character lighting/material integration.
# Keeps the accepted v1.63 r2.1 main/UI/gameplay stack and swaps only the 3D
# combat-world presentation layer to the v1.64 readability pass.

const CharacterLightingWorldV164 = preload("res://scripts/world3d_chamber_v164_character_lighting.gd")
const V85_FEATURE := "1.64-character-lighting-r1"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.event("character_lighting_v164_ready", _v85_character_lighting_snapshot())

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

	v52_world_root = CharacterLightingWorldV164.new()
	v52_world_root.name = "CharacterLighting3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v85_character_lighting_ready() -> bool:
	return _v84_boss_dominance_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("production_character_lighting_ready") \
		and bool(v52_world_root.call("production_character_lighting_ready"))

func _v85_character_lighting_snapshot() -> Dictionary:
	var world_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("debug_snapshot"):
		world_snapshot = v52_world_root.call("debug_snapshot")
	return {
		"ready": _v85_character_lighting_ready(),
		"feature": V85_FEATURE,
		"boss_r21_preserved": _v84_boss_dominance_ready(),
		"projectile_r1_preserved": _v82_projectile_identity_ready(),
		"ui_r3_preserved": _v80_runtime_cta_ready(),
		"world": world_snapshot,
	}
