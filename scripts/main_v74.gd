extends "res://scripts/main_v73.gd"

# ONE MORE FLOOR v1.60 — authored environment milestone.
# Expands the authored OBJ takeover across meta screens and the complete tower,
# including production floors, focals, materials, actors and combat VFX.
# Gameplay, input, saves and v1.54 real-model combat authority remain inherited.

const Menu3DStageV160Scene = preload("res://scripts/menu3d_stage_v160.gd")
const AuthoredTowerWorldV160 = preload("res://scripts/world3d_chamber_v160_combat_polish.gd")
const V74_VERSION := "1.60.0-authored-environment-milestone"
const V74_BUILD := "47-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V74_VERSION, V74_BUILD)
		telemetry.event("authored_environment_milestone_ready", _v74_meta_environment_snapshot())

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

	v52_world_root = AuthoredTowerWorldV160.new()
	v52_world_root.name = "AuthoredTower3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v74_meta_environment_ready() -> bool:
	return _v73_environment_ready() \
		and v70_menu_stage != null \
		and v70_menu_stage.has_method("meta_environment_assets_ready") \
		and bool(v70_menu_stage.call("meta_environment_assets_ready"))

func _v74_tower_environment_ready() -> bool:
	return _v68_real_model_intake_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("authored_tower_environment_ready") \
		and bool(v52_world_root.call("authored_tower_environment_ready")) \
		and v52_world_root.has_method("production_floor_ready") \
		and bool(v52_world_root.call("production_floor_ready")) \
		and v52_world_root.has_method("production_focal_ready") \
		and bool(v52_world_root.call("production_focal_ready")) \
		and v52_world_root.has_method("production_material_depth_ready") \
		and bool(v52_world_root.call("production_material_depth_ready")) \
		and v52_world_root.has_method("production_actor_presentation_ready") \
		and bool(v52_world_root.call("production_actor_presentation_ready")) \
		and v52_world_root.has_method("production_combat_vfx_ready") \
		and bool(v52_world_root.call("production_combat_vfx_ready"))

func _v74_meta_environment_snapshot() -> Dictionary:
	var stage_snapshot: Dictionary = {}
	if v70_menu_stage != null and v70_menu_stage.has_method("debug_snapshot"):
		stage_snapshot = v70_menu_stage.call("debug_snapshot")
	var tower_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("debug_snapshot"):
		tower_snapshot = v52_world_root.call("debug_snapshot")
	return {
		"ready": _v74_meta_environment_ready() and _v74_tower_environment_ready(),
		"menu_ready": _v74_meta_environment_ready(),
		"tower_ready": _v74_tower_environment_ready(),
		"version": V74_VERSION,
		"build": V74_BUILD,
		"screen": _v70_menu_screen(),
		"stage": stage_snapshot,
		"tower": tower_snapshot,
		"v159_regression": _v73_environment_snapshot(),
	}
