extends "res://scripts/main_v88.gd"

# ONE MORE FLOOR v1.67 — Frontend Completion r1.
# Re-opens active development after the v1.66 release-readiness audit. The
# frontend now shares the exact gameplay Wanderer authority and receives a
# unified authored-menu composition pass. Gameplay, save/input and combat
# authority remain inherited unchanged.

const FrontendMenuStageV167 = preload("res://scripts/menu3d_stage_v167_completion.gd")
const V89_FRONTEND_COMPLETION := "1.67-frontend-completion-r1"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.event("frontend_completion_v167_ready", _v89_frontend_completion_snapshot())

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

	v70_menu_stage = FrontendMenuStageV167.new()
	v70_menu_stage.name = "FrontendCompletion3DMenuStage"
	v70_menu_viewport.add_child(v70_menu_stage)

func _v89_frontend_completion_ready() -> bool:
	return _v87_character_form_ready() \
		and v70_menu_stage != null \
		and v70_menu_stage.has_method("frontend_completion_ready") \
		and bool(v70_menu_stage.call("frontend_completion_ready"))

func _v89_frontend_completion_snapshot() -> Dictionary:
	var stage_snapshot: Dictionary = {}
	if v70_menu_stage != null and v70_menu_stage.has_method("debug_snapshot"):
		stage_snapshot = v70_menu_stage.call("debug_snapshot")
	return {
		"ready": _v89_frontend_completion_ready(),
		"feature": V89_FRONTEND_COMPLETION,
		"shared_gameplay_wanderer": bool(stage_snapshot.get("gameplay_wanderer_shared", false)),
		"v166_character_form_preserved": _v87_character_form_ready(),
		"v165_environment_preserved": _v86_environment_depth_ready(),
		"ui_r3_preserved": _v80_runtime_cta_ready(),
		"stage": stage_snapshot,
	}
