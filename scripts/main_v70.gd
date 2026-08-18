extends "res://scripts/main_v69.gd"

# ONE MORE FLOOR v1.56 — full 3D presentation foundation.
# Persistent/meta screens now render a real Node3D stage behind the proven 2D
# UI shell. Gameplay, input, saves and the v1.55 Wanderer combat model remain
# authoritative and unchanged.

const Menu3DStage = preload("res://scripts/menu3d_stage_v156.gd")
const V70_VERSION := "1.56.0-full-3d-presentation"
const V70_BUILD := "43-dev"
const V70_MENU_SCREENS := ["home", "hero", "forge", "talents", "vault", "missions", "pass", "store"]

var v70_menu_viewport: SubViewport
var v70_menu_stage: Node3D
var v70_last_screen := ""
var v70_3d_frames := 0

func _ready() -> void:
	super._ready()
	_v70_create_menu_3d()
	_v70_sync_menu_3d(true)
	if telemetry != null:
		telemetry.set_build_context(V70_VERSION, V70_BUILD)
		telemetry.event("full_3d_presentation_ready", _v70_presentation_snapshot())
	queue_redraw()

func _process(delta: float) -> void:
	super._process(delta)
	_v70_sync_menu_3d(false)

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

	v70_menu_stage = Menu3DStage.new()
	v70_menu_stage.name = "Full3DMenuStage"
	v70_menu_viewport.add_child(v70_menu_stage)

func _v70_menu_screen() -> String:
	return _v51_screen_from_legacy()

func _v70_menu_3d_active() -> bool:
	return _v70_menu_screen() in V70_MENU_SCREENS \
		and v70_menu_viewport != null \
		and v70_menu_stage != null

func _v70_sync_menu_3d(force: bool = false) -> void:
	if v70_menu_viewport == null or v70_menu_stage == null:
		return
	var screen := _v70_menu_screen()
	var active := screen in V70_MENU_SCREENS
	v70_menu_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if active else SubViewport.UPDATE_DISABLED
	v70_menu_stage.visible = active
	if not active:
		return
	if force or screen != v70_last_screen:
		if v70_menu_stage.has_method("set_screen"):
			v70_menu_stage.call("set_screen", screen)
		v70_last_screen = screen
		if telemetry != null:
			telemetry.event("menu_3d_stage_changed", {"screen": screen})
	v70_3d_frames += 1

# Replace the legacy authored 2D menu backdrops with the shared real 3D stage.
# UI remains on the existing Canvas/Node2D layer so touch targets do not move.
func _v16_backdrop(kind: String = "arcane", dim: float = 0.0) -> void:
	if not _v70_menu_3d_active():
		super._v16_backdrop(kind, dim)
		return
	var texture := v70_menu_viewport.get_texture()
	if texture == null:
		super._v16_backdrop(kind, dim)
		return
	draw_texture_rect(texture, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)
	# Cinematic edge treatment only; no fake 2D environment art is layered back in.
	draw_rect(Rect2(0, 0, SIZE.x, 190), Color(0.015, 0.018, 0.045, 0.34))
	draw_rect(Rect2(0, SIZE.y - 220, SIZE.x, 220), Color(0.01, 0.012, 0.03, 0.42))
	if visual_pack != null:
		_v37_corner_runes(_v38_primary(), _v38_secondary())
	if dim > 0.0:
		draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0, 0, 0, dim))

# The Home/Hero Wanderer is now the imported 3D actor inside Menu3DStage.
# Keep the old SVG fallback only if the 3D stage is unavailable.
func _v40_draw_wanderer_texture(r: Rect2, alpha: float = 1.0) -> void:
	var screen := _v70_menu_screen()
	if _v70_menu_3d_active() and screen in ["home", "hero"]:
		return
	super._v40_draw_wanderer_texture(r, alpha)

func _v70_full_3d_presentation_ready() -> bool:
	if not _v69_wanderer_production_ready():
		return false
	if v70_menu_viewport == null or v70_menu_stage == null:
		return false
	if not v70_menu_stage.has_method("stage_ready") or not bool(v70_menu_stage.call("stage_ready")):
		return false
	return v70_menu_viewport.size == Vector2i(int(SIZE.x), int(SIZE.y))

func _v70_presentation_snapshot() -> Dictionary:
	var stage_snapshot: Dictionary = {}
	if v70_menu_stage != null and v70_menu_stage.has_method("debug_snapshot"):
		stage_snapshot = v70_menu_stage.call("debug_snapshot")
	return {
		"ready": _v70_full_3d_presentation_ready(),
		"version": V70_VERSION,
		"build": V70_BUILD,
		"screen": _v70_menu_screen(),
		"menu_3d_active": _v70_menu_3d_active(),
		"viewport_size": v70_menu_viewport.size if v70_menu_viewport != null else Vector2i.ZERO,
		"frames": v70_3d_frames,
		"stage": stage_snapshot,
		"wanderer_regression": _v69_wanderer_snapshot(),
		"input_flow": _v66_input_flow_snapshot(),
	}
