extends "res://scripts/main_v60.gd"

# ONE MORE FLOOR v1.48 - Character Combat VFX & Animation Presentation.
# Keeps the complete five-realm 3D tower and v1.47 production actor contract,
# then layers archetype/socket-driven combat spectacle on top.

const CharacterCombatWorld3DChamber = preload("res://scripts/world3d_chamber_v148.gd")
const V61_VERSION := "1.48.0-character-combat-vfx"
const V61_BUILD := "34-dev"
const V61_3D_MIN_FLOOR := 1
const V61_3D_MAX_FLOOR := 50

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V61_VERSION, V61_BUILD)
		telemetry.event("character_combat_vfx_ready", {
			"world_ready": _v61_character_combat_vfx_ready(),
			"floor_min": V61_3D_MIN_FLOOR,
			"floor_max": V61_3D_MAX_FLOOR,
			"realms": 5,
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

	v52_world_root = CharacterCombatWorld3DChamber.new()
	v52_world_root.name = "Tower3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v52_3d_active() -> bool:
	if state != State.RUNNING or run == null:
		return false
	var floor_no: int = int(run.floor_no)
	return floor_no >= V61_3D_MIN_FLOOR and floor_no <= V61_3D_MAX_FLOOR

func _v61_character_combat_vfx_ready() -> bool:
	return _v60_actor_production_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("character_combat_vfx_ready") \
		and bool(v52_world_root.call("character_combat_vfx_ready"))
