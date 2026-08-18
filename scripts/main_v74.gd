extends "res://scripts/main_v73.gd"

# ONE MORE FLOOR v1.60 — authored meta-environment expansion.
# Completes the menu-side authored environment takeover for Talents, Vault,
# Missions, Tower Pass and Store without touching gameplay/input/save authority.

const Menu3DStageV160Scene = preload("res://scripts/menu3d_stage_v160.gd")
const V74_VERSION := "1.60.0-meta-environment-expansion"
const V74_BUILD := "47-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V74_VERSION, V74_BUILD)
		telemetry.event("meta_environment_expansion_ready", _v74_meta_environment_snapshot())

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

	v70_menu_stage = Menu3DStageV160Scene.new()
	v70_menu_stage.name = "MetaEnvironment3DMenuStage"
	v70_menu_viewport.add_child(v70_menu_stage)

func _v74_meta_environment_ready() -> bool:
	return _v73_environment_ready() \
		and v70_menu_stage != null \
		and v70_menu_stage.has_method("meta_environment_assets_ready") \
		and bool(v70_menu_stage.call("meta_environment_assets_ready"))

func _v74_meta_environment_snapshot() -> Dictionary:
	var stage_snapshot: Dictionary = {}
	if v70_menu_stage != null and v70_menu_stage.has_method("debug_snapshot"):
		stage_snapshot = v70_menu_stage.call("debug_snapshot")
	return {
		"ready": _v74_meta_environment_ready(),
		"version": V74_VERSION,
		"build": V74_BUILD,
		"screen": _v70_menu_screen(),
		"stage": stage_snapshot,
		"v159_regression": _v73_environment_snapshot(),
	}
