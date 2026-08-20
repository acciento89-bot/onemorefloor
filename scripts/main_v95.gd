extends "res://scripts/main_v94.gd"

# ONE MORE FLOOR v1.71 r1 — UX / Completion Sweep.
# Finishes existing routes and safety affordances without reopening accepted
# art, combat, economy, save or progression authority.

const V95_UX_COMPLETION := "1.71-ux-completion-r1"
const V95_ABANDON_CANCEL := Rect2(92, 700, 248, 68)
const V95_ABANDON_CONFIRM := Rect2(380, 700, 248, 68)
const V95_TUTORIAL_SKIP := Rect2(220, 908, 280, 44)
const V95_SETTINGS_SUBTITLE := "AUDIO  •  FEEDBACK  •  PRIVACY"
const V95_ANALYTICS_COPY := "Usage analytics is optional and can be changed anytime."

var v95_abandon_confirm: bool = false
var v95_tutorial_pending_home: bool = false

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.event("ux_completion_v171_ready", _v95_ux_snapshot())
	queue_redraw()

func _process(delta: float) -> void:
	super._process(delta)
	if v95_tutorial_pending_home \
		and state == State.HOME \
		and home_overlay == "" \
		and not settings_open \
		and not tutorial_active:
		v95_tutorial_pending_home = false
		tutorial_active = true
		tutorial_step = 0
		queue_redraw()

func _v95_touch_rect_ready(rect: Rect2) -> bool:
	return rect.position.x >= 0.0 \
		and rect.position.y >= 0.0 \
		and rect.end.x <= SIZE.x \
		and rect.end.y <= SIZE.y \
		and rect.size.x >= 44.0 \
		and rect.size.y >= 44.0

func _v95_route_graph_ready() -> bool:
	if v51_navigation == null:
		return false
	for screen in ["home", "hero", "forge", "talents", "vault", "missions", "pass", "run", "upgrade", "decision", "game_over"]:
		if not bool(v51_navigation.is_known_screen(screen)):
			return false
	return true

func _v95_ux_completion_ready() -> bool:
	if not _v94_realm_completion_ready() or not _v95_route_graph_ready():
		return false
	if String(_v94_realm_completion_snapshot().get("version", "")) != "1.70-realm-endgame-visual-completion-r1.1":
		return false
	if not _v88_privacy_link_ready():
		return false
	if not _v95_touch_rect_ready(V95_ABANDON_CANCEL) \
		or not _v95_touch_rect_ready(V95_ABANDON_CONFIRM) \
		or not _v95_touch_rect_ready(V95_TUTORIAL_SKIP):
		return false
	if _v88_release_surfaces_active() and bool(_v50_store_requests_available()):
		return false
	if V95_SETTINGS_SUBTITLE.to_lower().contains("playtest") \
		or V95_ANALYTICS_COPY.to_lower().contains("playtest"):
		return false
	return true

func _v95_ux_snapshot() -> Dictionary:
	return {
		"ready": _v95_ux_completion_ready(),
		"version": V95_UX_COMPLETION,
		"realm_v170_r11_preserved": _v94_realm_completion_ready(),
		"route_graph_ready": _v95_route_graph_ready(),
		"privacy_ready": _v88_privacy_link_ready(),
		"production_store_hidden": _v88_release_surfaces_active() and not bool(_v50_store_requests_available()),
		"abandon_confirmation": true,
		"tutorial_home_pending": true,
		"tutorial_skip_before_run": true,
		"settings_copy_final": true,
	}

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if not pressed:
		super.pointer(pos, pressed, id)
		return

	# If Replay Tutorial is requested from a live run, remember the intent and
	# start the tutorial as soon as the player safely reaches Home in this session.
	if settings_open and state != State.HOME and V10_SET_TUTORIAL.has_point(pos):
		v95_tutorial_pending_home = true

	# Confirmation owns all pause input until the player explicitly cancels or
	# accepts. This prevents an accidental tap from silently abandoning a run.
	if v95_abandon_confirm:
		if V95_ABANDON_CANCEL.has_point(pos):
			v95_abandon_confirm = false
			_audio("menu")
			queue_redraw()
			return
		if V95_ABANDON_CONFIRM.has_point(pos):
			v95_abandon_confirm = false
			release_paused = false
			settings_return_to_pause = false
			joy_active = false
			joy_vector = Vector2.ZERO
			state = State.HOME
			home_overlay = ""
			if telemetry != null:
				telemetry.event("run_abandon", {"floor": int(run.floor_no) if run != null else 0, "confirmed": true})
			_v51_sync_navigation(false)
			_v51_sync_shell()
			_audio("menu")
			queue_redraw()
			return
		return

	if release_paused and not settings_open and V10_PAUSE_HOME.has_point(pos):
		v95_abandon_confirm = true
		_audio("menu")
		queue_redraw()
		return

	# Skip is deliberately available only before the tutorial run starts. Once
	# combat begins, the existing guided run stays authoritative.
	if tutorial_active and tutorial_step in [0, 1] and V95_TUTORIAL_SKIP.has_point(pos):
		v95_tutorial_pending_home = false
		_audio("menu")
		_complete_tutorial()
		return

	super.pointer(pos, pressed, id)

func _draw_pause_overlay() -> void:
	if not v95_abandon_confirm:
		super._draw_pause_overlay()
		return

	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.01, 0.015, 0.04, 0.90))
	panel(Rect2(72, 330, 576, 520), Color("10162b"), C_RED)
	draw_center("ABANDON RUN?", 416, 38, C_TEXT)
	draw_center("Unsecured run progress will be lost.", 474, 16, C_MUTED)
	draw_center("Floor %d" % (int(run.floor_no) if run != null else 0), 520, 16, C_GOLD)
	button(V95_ABANDON_CANCEL, "KEEP CLIMBING", C_GREEN, 17)
	button(V95_ABANDON_CONFIRM, "RETURN HOME", C_RED, 17)

func _draw_settings_overlay() -> void:
	super._draw_settings_overlay()
	# Replace development-era copy while preserving the accepted controls and
	# the v1.66 Privacy Policy action.
	draw_rect(Rect2(96, 242, 528, 42), Color("10162b"))
	draw_center(V95_SETTINGS_SUBTITLE, 268, 14, C_MUTED)
	button(
		V10_SET_ANALYTICS,
		"USAGE ANALYTICS  %s" % _on_off(bool(settings.analytics_enabled)),
		C_GOLD if bool(settings.analytics_enabled) else C_MUTED,
		17
	)
	draw_rect(Rect2(96, 724, 528, 46), Color("10162b"))
	draw_center("SETTINGS SAVE AUTOMATICALLY", 752, 11, C_MUTED)

func _draw_tutorial_overlay() -> void:
	super._draw_tutorial_overlay()
	if tutorial_step in [0, 1]:
		button(V95_TUTORIAL_SKIP, "SKIP TUTORIAL", C_MUTED, 14)
