extends "res://scripts/main_v72.gd"

# ONE MORE FLOOR v1.59 — authored environment asset foundation.
# Keeps v1.58 composition safety, but swaps the Home/Hero/Forge focal blockout
# architecture for imported OBJ environment meshes.

const Menu3DStageV159Scene = preload("res://scripts/menu3d_stage_v159.gd")
const V73_VERSION := "1.59.0-environment-asset-foundation"
const V73_BUILD := "46-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V73_VERSION, V73_BUILD)
		telemetry.event("environment_asset_foundation_ready", _v73_environment_snapshot())

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

	v70_menu_stage = Menu3DStageV159Scene.new()
	v70_menu_stage.name = "AuthoredEnvironment3DMenuStage"
	v70_menu_viewport.add_child(v70_menu_stage)

func _v73_environment_ready() -> bool:
	return _v72_composition_ready() \
		and v70_menu_stage != null \
		and v70_menu_stage.has_method("environment_assets_ready") \
		and bool(v70_menu_stage.call("environment_assets_ready"))

func _v73_environment_snapshot() -> Dictionary:
	var stage_snapshot: Dictionary = {}
	if v70_menu_stage != null and v70_menu_stage.has_method("debug_snapshot"):
		stage_snapshot = v70_menu_stage.call("debug_snapshot")
	return {
		"ready": _v73_environment_ready(),
		"version": V73_VERSION,
		"build": V73_BUILD,
		"screen": _v70_menu_screen(),
		"stage": stage_snapshot,
		"v158_regression": _v72_composition_snapshot(),
	}
