extends "res://scripts/main_v70.gd"

# ONE MORE FLOOR v1.57 — production 3D lookdev.
# The shared v1.56 architecture remains intact; this layer swaps in the refined
# menu stage and exposes a dedicated production-lookdev validation gate.

const Menu3DStageV157Scene = preload("res://scripts/menu3d_stage_v157.gd")
const V71_VERSION := "1.57.0-production-3d-lookdev"
const V71_BUILD := "44-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V71_VERSION, V71_BUILD)
		telemetry.event("production_3d_lookdev_ready", _v71_lookdev_snapshot())

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

	v70_menu_stage = Menu3DStageV157Scene.new()
	v70_menu_stage.name = "Production3DMenuStage"
	v70_menu_viewport.add_child(v70_menu_stage)

func _v71_lookdev_ready() -> bool:
	return _v70_full_3d_presentation_ready() \
		and v70_menu_stage != null \
		and v70_menu_stage.has_method("lookdev_ready") \
		and bool(v70_menu_stage.call("lookdev_ready"))

func _v71_lookdev_snapshot() -> Dictionary:
	var stage_snapshot: Dictionary = {}
	if v70_menu_stage != null and v70_menu_stage.has_method("debug_snapshot"):
		stage_snapshot = v70_menu_stage.call("debug_snapshot")
	return {
		"ready": _v71_lookdev_ready(),
		"version": V71_VERSION,
		"build": V71_BUILD,
		"screen": _v70_menu_screen(),
		"stage": stage_snapshot,
		"v156_regression": _v70_presentation_snapshot(),
	}
