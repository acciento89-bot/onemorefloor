extends "res://scripts/main_v94.gd"

# ONE MORE FLOOR v1.71 r1.1 — UX / Completion Sweep.
# r1.1 is the capture-driven presentation correction: Settings no longer leaks
# development-era copy and Tutorial body text is explicitly line-broken for the
# fixed portrait canvas. Routes, input authority, saves and gameplay stay intact.

const V95_UX_COMPLETION := "1.71-ux-completion-r1.1"
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
		"tutorial_copy_wrapped": true,
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
	# Draw the final production Settings surface from scratch rather than painting
	# patches over inherited playtest-era copy. Input rectangles remain inherited.
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.01, 0.015, 0.04, 0.91))
	panel(Rect2(66, 160, 588, 800), Color("10162b"), C_BLUE)
	draw_center("SETTINGS", 228, 42, C_TEXT)
	draw_center(V95_SETTINGS_SUBTITLE, 274, 14, C_MUTED)
	button(V10_SET_MUSIC, "MUSIC  %s   %d%%" % [_on_off(bool(settings.music_enabled)), int(float(settings.music_volume) * 100.0)], C_GREEN if bool(settings.music_enabled) else C_MUTED, 18)
	button(V10_SET_SFX, "SFX  %s   %d%%" % [_on_off(bool(settings.sfx_enabled)), int(float(settings.sfx_volume) * 100.0)], C_GREEN if bool(settings.sfx_enabled) else C_MUTED, 18)
	button(V10_SET_HAPTICS, "HAPTICS  %s" % _on_off(bool(settings.haptics_enabled)), C_GREEN if bool(settings.haptics_enabled) else C_MUTED, 18)
	button(V10_SET_ANALYTICS, "USAGE ANALYTICS  %s" % _on_off(bool(settings.analytics_enabled)), C_GOLD if bool(settings.analytics_enabled) else C_MUTED, 17)
	button(V10_SET_TUTORIAL, "REPLAY TUTORIAL", C_PURPLE, 18)
	draw_center("SETTINGS SAVE AUTOMATICALLY", 752, 11, C_MUTED)
	button(V10_SET_BACK, "BACK", C_BLUE, 20)
	button(V88_PRIVACY, "PRIVACY POLICY", C_BLUE, 14)
	draw_center(V95_ANALYTICS_COPY, 936, 10, C_MUTED)

func _draw_tutorial_overlay() -> void:
	# Explicit portrait line layout prevents inherited one-line body copy from
	# clipping at 720px width while preserving the established tutorial flow.
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.01, 0.015, 0.04, 0.86))
	panel(Rect2(82, 260, 556, 700), Color("10162b"), C_GOLD)
	var title: String = "WELCOME TO THE TOWER"
	var body_a: Array[String] = ["Move. Auto-attack. Survive."]
	var body_b: Array[String] = [
		"Every cleared floor asks one question:",
		"climb again or bank the loot?",
	]
	var button_text: String = "NEXT"

	match tutorial_step:
		1:
			title = "RISK VS REWARD"
			body_a = ["Pick one of three run upgrades after every floor."]
			body_b = [
				"Cash out to secure everything.",
				"Death only keeps part of unsecured coins.",
			]
			button_text = "START TUTORIAL RUN"
		2:
			title = "ONE-THUMB COMBAT"
			body_a = [
				"Drag the left joystick to dodge.",
				"Attacks fire automatically at nearby enemies.",
			]
			body_b = [
				"Tap NOVA when ready to damage nearby enemies",
				"and clear hostile projectiles.",
			]
			button_text = "GOT IT"
		4:
			title = "BUILD THE RUN"
			body_a = ["Choose one upgrade now. Your build changes every climb."]
			body_b = [
				"After the upgrade, CASH OUT to secure the run",
				"or press ONE MORE FLOOR to keep climbing.",
			]
			button_text = "FINISH TUTORIAL"

	draw_string(font, Vector2(112, 350), title, HORIZONTAL_ALIGNMENT_CENTER, 496, 30, C_GOLD)
	_v95_draw_tutorial_lines(body_a, 455, 17, C_TEXT, 32)
	_v95_draw_tutorial_lines(body_b, 530, 15, C_MUTED, 30)

	if tutorial_step == 2:
		draw_circle(Vector2(160, 680), 62, Color(C_BLUE, 0.18))
		draw_circle(Vector2(580, 680), 54, Color(C_CYAN, 0.18))
		draw_string(font, Vector2(90, 760), "MOVE", HORIZONTAL_ALIGNMENT_CENTER, 140, 16, C_BLUE)
		draw_string(font, Vector2(510, 760), "NOVA", HORIZONTAL_ALIGNMENT_CENTER, 140, 16, C_CYAN)

	button(V10_TUTORIAL_NEXT, button_text, C_GOLD, 20)
	if tutorial_step in [0, 1]:
		button(V95_TUTORIAL_SKIP, "SKIP TUTORIAL", C_MUTED, 14)

func _v95_draw_tutorial_lines(lines: Array[String], start_y: float, size: int, color: Color, gap: float) -> void:
	for index in range(lines.size()):
		draw_string(
			font,
			Vector2(122, start_y + float(index) * gap),
			String(lines[index]),
			HORIZONTAL_ALIGNMENT_CENTER,
			476,
			size,
			color
		)
