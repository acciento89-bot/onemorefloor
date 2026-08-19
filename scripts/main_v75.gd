extends "res://scripts/main_v74.gd"

# ONE MORE FLOOR v1.61 — combat presentation milestone.
# Keeps the fully validated v1.60 authored environment/character stack and swaps
# only the combat-world presentation layer. Gameplay authority remains inherited.

const CombatPresentationWorldV161 = preload("res://scripts/world3d_chamber_v161_combat_presentation_r32.gd")
const V75_VERSION := "1.61.0-combat-presentation"
const V75_BUILD := "48-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V75_VERSION, V75_BUILD)
		telemetry.event("combat_presentation_v161_ready", _v75_combat_presentation_snapshot())

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

	v52_world_root = CombatPresentationWorldV161.new()
	v52_world_root.name = "CombatPresentation3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v75_combat_presentation_ready() -> bool:
	return _v74_meta_environment_ready() \
		and _v74_tower_environment_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("production_combat_presentation_ready") \
		and bool(v52_world_root.call("production_combat_presentation_ready"))

func _v75_combat_presentation_snapshot() -> Dictionary:
	var world_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("debug_snapshot"):
		world_snapshot = v52_world_root.call("debug_snapshot")
	return {
		"ready": _v75_combat_presentation_ready(),
		"version": V75_VERSION,
		"build": V75_BUILD,
		"v160_ready": _v74_meta_environment_ready() and _v74_tower_environment_ready(),
		"world": world_snapshot,
	}
