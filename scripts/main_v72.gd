extends "res://scripts/main_v71.gd"

# ONE MORE FLOOR v1.58 — composition rescue.
# Keeps the v1.57 materials/lighting baseline, but replaces the problematic
# foreground-heavy Home/Hero/Forge compositions with background-only large forms.

const Menu3DStageV158Scene = preload("res://scripts/menu3d_stage_v158.gd")
const V72_VERSION := "1.58.0-composition-rescue"
const V72_BUILD := "45-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V72_VERSION, V72_BUILD)
		telemetry.event("composition_rescue_ready", _v72_composition_snapshot())

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

	v70_menu_stage = Menu3DStageV158Scene.new()
	v70_menu_stage.name = "CompositionRescue3DMenuStage"
	v70_menu_viewport.add_child(v70_menu_stage)

func _v72_composition_ready() -> bool:
	return _v71_lookdev_ready() \
		and v70_menu_stage != null \
		and v70_menu_stage.has_method("composition_ready") \
		and bool(v70_menu_stage.call("composition_ready"))

func _v72_composition_snapshot() -> Dictionary:
	var stage_snapshot: Dictionary = {}
	if v70_menu_stage != null and v70_menu_stage.has_method("debug_snapshot"):
		stage_snapshot = v70_menu_stage.call("debug_snapshot")
	return {
		"ready": _v72_composition_ready(),
		"version": V72_VERSION,
		"build": V72_BUILD,
		"screen": _v70_menu_screen(),
		"stage": stage_snapshot,
		"v157_regression": _v71_lookdev_snapshot(),
	}
