extends "res://scripts/main_v91.gd"

# ONE MORE FLOOR v1.68 r1 — Wanderer Visual Completion.
# Promotes the same v1.68 authored Wanderer into both the completed frontend and
# the combat world. Menus, realm art, gameplay, input and progression are inherited.

const CharacterCompletionWorldV168 = preload("res://scripts/world3d_chamber_v168_character_completion.gd")
const CharacterCompletionMenuV168 = preload("res://scripts/menu3d_stage_v168_character_completion.gd")
const V92_CHARACTER_COMPLETION := "1.68-wanderer-visual-completion-r1"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.event("character_completion_v168_ready", _v92_character_completion_snapshot())

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

	v52_world_root = CharacterCompletionWorldV168.new()
	v52_world_root.name = "CharacterCompletion3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v70_create_menu_3d() -> void:
	v70_menu_viewport = SubViewport.new()
	v70_menu_viewport.name = "Menu3DViewport"
	v70_menu_viewport.size = Vector2i(int(SIZE.x), int(SIZE.y))
	v70_menu_viewport.own_world_3d = true
	v70_menu_viewport.transparent_bg = false
	v70_menu_viewport.disable_3d = false
	v70_menu_viewport.msaa_3d = Viewport.MSAA_2X
	v70_menu_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(v70_menu_viewport)

	v70_menu_stage = CharacterCompletionMenuV168.new()
	v70_menu_stage.name = "CharacterCompletionV168MenuStage"
	v70_menu_viewport.add_child(v70_menu_stage)

func _v92_character_completion_ready() -> bool:
	if not _v91_frontend_finish_ready() or v52_world_root == null or v70_menu_stage == null:
		return false
	if not v52_world_root.has_method("production_character_completion_ready") \
		or not bool(v52_world_root.call("production_character_completion_ready")):
		return false
	v70_menu_stage.set_screen("hero")
	if not v70_menu_stage.has_method("frontend_completion_ready") \
		or not bool(v70_menu_stage.call("frontend_completion_ready")):
		return false
	return true

func _v92_character_completion_snapshot() -> Dictionary:
	var world_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("debug_snapshot"):
		world_snapshot = v52_world_root.call("debug_snapshot")
	var menu_snapshot: Dictionary = {}
	if v70_menu_stage != null and v70_menu_stage.has_method("debug_snapshot"):
		menu_snapshot = v70_menu_stage.call("debug_snapshot")
	return {
		"ready": _v92_character_completion_ready(),
		"version": V92_CHARACTER_COMPLETION,
		"frontend_r12_preserved": _v91_frontend_finish_ready(),
		"world": world_snapshot,
		"menu": menu_snapshot,
	}
