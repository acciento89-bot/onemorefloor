extends "res://scripts/main_v09.gd"

const SettingsManager = preload("res://scripts/settings_manager.gd")
const Telemetry = preload("res://scripts/telemetry.gd")
const BalanceProfile = preload("res://scripts/balance_profile.gd")
const ReleaseAudio = preload("res://scripts/release_audio.gd")

const V10_SETTINGS_HOME := Rect2(540, 748, 140, 52)
const V10_PAUSE := Rect2(626, 104, 44, 44)
const V10_RESUME := Rect2(170, 490, 380, 78)
const V10_PAUSE_SETTINGS := Rect2(170, 592, 380, 78)
const V10_PAUSE_HOME := Rect2(170, 694, 380, 78)
const V10_SET_MUSIC := Rect2(96, 322, 528, 64)
const V10_SET_SFX := Rect2(96, 404, 528, 64)
const V10_SET_HAPTICS := Rect2(96, 486, 528, 64)
const V10_SET_ANALYTICS := Rect2(96, 568, 528, 64)
const V10_SET_TUTORIAL := Rect2(96, 650, 528, 64)
const V10_SET_BACK := Rect2(170, 786, 380, 70)
const V10_TUTORIAL_NEXT := Rect2(170, 822, 380, 76)

var settings
var telemetry
var balance
var release_audio
var release_paused: bool = false
var settings_open: bool = false
var settings_return_to_pause: bool = false
var tutorial_active: bool = false
var tutorial_step: int = 0
var recovery_notice_time: float = 0.0

func _ready() -> void:
	super._ready()
	settings = SettingsManager.new()
	settings.load_data()
	haptics_enabled = bool(settings.haptics_enabled)
	telemetry = Telemetry.new()
	telemetry.begin_session(bool(settings.analytics_enabled))
	balance = BalanceProfile.new()
	release_audio = ReleaseAudio.new()
	add_child(release_audio)
	release_audio.setup(settings)
	if audio != null:
		audio.enabled = false
	tutorial_active = not bool(settings.tutorial_done)
	tutorial_step = 0
	if telemetry.had_unclean_previous_exit():
		recovery_notice_time = 4.0
	queue_redraw()

func _exit_tree() -> void:
	if telemetry != null:
		telemetry.end_session()

func _process(delta: float) -> void:
	recovery_notice_time = maxf(0.0, recovery_notice_time - delta)
	if _release_blocks_gameplay():
		elapsed += delta * 0.18
		queue_redraw()
		return
	super._process(delta)
	if tutorial_active and tutorial_step == 3 and state == State.UPGRADE:
		tutorial_step = 4
		queue_redraw()

func _release_blocks_gameplay() -> bool:
	if release_paused or settings_open:
		return true
	if tutorial_active and tutorial_step in [0, 1, 2, 4]:
		return true
	return false

func start_run() -> void:
	super.start_run()
	if telemetry != null:
		telemetry.event("run_start", {"best_floor": int(meta.best_floor), "power": int(meta.power_score())})

func spawn_floor() -> void:
	super.spawn_floor()
	_apply_release_balance()
	if telemetry != null:
		telemetry.event("floor_start", {
			"floor": int(run.floor_no),
			"area": String(current_room.get("area", "DUNGEON")),
			"room": String(current_room.get("type", "COMBAT"))
		})

func update_enemies(delta: float) -> void:
	super.update_enemies(delta)
	_apply_release_balance()

func _apply_release_balance() -> void:
	if balance == null or run == null:
		return
	for i in range(enemies.size()):
		if not bool(enemies[i].get("release_balanced", false)):
			enemies[i] = balance.apply_enemy(enemies[i], int(run.floor_no))

func apply_upgrade(index: int) -> void:
	var kind: String = ""
	if index >= 0 and index < upgrade_options.size():
		kind = String(upgrade_options[index].get("kind", ""))
	super.apply_upgrade(index)
	if telemetry != null and kind != "":
		telemetry.event("upgrade_pick", {"floor": int(run.floor_no), "kind": kind})

func cash_out() -> void:
	var floor_no: int = int(run.floor_no)
	var secured: int = int(run.run_coins)
	if telemetry != null:
		telemetry.event("cash_out", {"floor": floor_no, "coins": secured})
	super.cash_out()

func die() -> void:
	if telemetry != null:
		telemetry.event("run_end", {"floor": int(run.floor_no), "reason": "death", "coins": int(run.run_coins)})
	super.die()

func haptic(duration_ms: int) -> void:
	if settings != null and bool(settings.haptics_enabled):
		Input.vibrate_handheld(duration_ms)

func _audio(name: String) -> void:
	if release_audio != null:
		release_audio.event(name)
		return
	super._audio(name)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_P:
			if settings_open:
				_close_settings()
				return
			if state == State.RUNNING and not tutorial_active:
				_set_pause(not release_paused)
				return
	super._unhandled_input(event)

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if not pressed:
		super.pointer(pos, pressed, id)
		return
	if settings_open:
		_pointer_settings(pos)
		return
	if tutorial_active and _pointer_tutorial(pos):
		return
	if release_paused:
		if V10_RESUME.has_point(pos):
			_set_pause(false)
			return
		if V10_PAUSE_SETTINGS.has_point(pos):
			settings_open = true
			settings_return_to_pause = true
			_audio("menu")
			return
		if V10_PAUSE_HOME.has_point(pos):
			release_paused = false
			joy_active = false
			joy_vector = Vector2.ZERO
			state = State.HOME
			if telemetry != null:
				telemetry.event("run_abandon", {"floor": int(run.floor_no)})
			return
		return
	if state == State.RUNNING and V10_PAUSE.has_point(pos):
		_set_pause(true)
		return
	if state == State.HOME and home_overlay == "" and V10_SETTINGS_HOME.has_point(pos):
		settings_open = true
		settings_return_to_pause = false
		_audio("menu")
		return
	super.pointer(pos, pressed, id)

func _set_pause(value: bool) -> void:
	release_paused = value
	joy_active = false
	joy_vector = Vector2.ZERO
	if telemetry != null:
		telemetry.event("pause" if value else "resume", {"floor": int(run.floor_no)})
	_audio("menu")
	queue_redraw()

func _pointer_settings(pos: Vector2) -> void:
	if V10_SET_MUSIC.has_point(pos):
		settings.toggle_music()
		release_audio.apply_settings()
		_audio("menu")
		return
	if V10_SET_SFX.has_point(pos):
		var enabled: bool = bool(settings.toggle_sfx())
		release_audio.apply_settings()
		if enabled:
			_audio("menu")
		return
	if V10_SET_HAPTICS.has_point(pos):
		haptics_enabled = bool(settings.toggle_haptics())
		if haptics_enabled:
			haptic(18)
		return
	if V10_SET_ANALYTICS.has_point(pos):
		var enabled: bool = bool(settings.toggle_analytics())
		telemetry.set_enabled(enabled)
		_audio("menu")
		return
	if V10_SET_TUTORIAL.has_point(pos):
		settings.reset_tutorial()
		if state == State.HOME:
			tutorial_active = true
			tutorial_step = 0
			settings_open = false
		else:
			loot_notice = "TUTORIAL WILL START FROM HOME"
			loot_notice_color = C_GOLD
			loot_notice_time = 2.0
		return
	if V10_SET_BACK.has_point(pos):
		_close_settings()

func _close_settings() -> void:
	settings_open = false
	if not settings_return_to_pause:
		release_paused = false
	settings_return_to_pause = false
	_audio("menu")
	queue_redraw()

func _pointer_tutorial(pos: Vector2) -> bool:
	if not V10_TUTORIAL_NEXT.has_point(pos):
		return true
	_audio("menu")
	match tutorial_step:
		0:
			tutorial_step = 1
		1:
			tutorial_step = 2
			start_run()
		2:
			tutorial_step = 3
		4:
			_complete_tutorial()
	queue_redraw()
	return true

func _complete_tutorial() -> void:
	tutorial_active = false
	tutorial_step = 0
	settings.complete_tutorial()
	if telemetry != null:
		telemetry.event("tutorial_complete", {})
	loot_notice = "TUTORIAL COMPLETE"
	loot_notice_color = C_GREEN
	loot_notice_time = 1.8

func draw_home() -> void:
	super.draw_home()
	if home_overlay == "":
		button(V10_SETTINGS_HOME, "SETTINGS", C_BLUE, 14)
		text("v1.0 RC1", Vector2(58, 1248), 12, C_GREEN)
	if recovery_notice_time > 0.0:
		panel(Rect2(120, 172, 480, 44), Color("101629"), C_GOLD)
		center_rect("PREVIOUS SESSION RECOVERED", Rect2(120, 172, 480, 44), 14, C_GOLD)
	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step in [0, 1]:
		_draw_tutorial_overlay()

func draw_game() -> void:
	super.draw_game()
	button(V10_PAUSE, "II", C_MUTED, 16)
	if release_paused and not settings_open:
		_draw_pause_overlay()
	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step == 2:
		_draw_tutorial_overlay()

func draw_upgrade() -> void:
	super.draw_upgrade()
	if tutorial_active and tutorial_step == 4:
		_draw_tutorial_overlay()

func _draw_pause_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.01, 0.015, 0.04, 0.82))
	panel(Rect2(112, 330, 496, 520), Color("10162b"), C_PURPLE)
	draw_center("PAUSED", 410, 46, C_TEXT)
	draw_center("Floor %d  •  %s" % [int(run.floor_no), String(current_room.get("area", "TOWER"))], 452, 16, C_MUTED)
	button(V10_RESUME, "RESUME", C_GREEN, 22)
	button(V10_PAUSE_SETTINGS, "SETTINGS", C_BLUE, 20)
	button(V10_PAUSE_HOME, "RETURN HOME", C_PURPLE, 20)

func _draw_settings_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.01, 0.015, 0.04, 0.91))
	panel(Rect2(66, 160, 588, 760), Color("10162b"), C_BLUE)
	draw_center("SETTINGS", 228, 42, C_TEXT)
	draw_center("Playtest controls & privacy", 266, 16, C_MUTED)
	button(V10_SET_MUSIC, "MUSIC  %s   %d%%" % [_on_off(bool(settings.music_enabled)), int(float(settings.music_volume) * 100.0)], C_GREEN if bool(settings.music_enabled) else C_MUTED, 18)
	button(V10_SET_SFX, "SFX  %s   %d%%" % [_on_off(bool(settings.sfx_enabled)), int(float(settings.sfx_volume) * 100.0)], C_GREEN if bool(settings.sfx_enabled) else C_MUTED, 18)
	button(V10_SET_HAPTICS, "HAPTICS  %s" % _on_off(bool(settings.haptics_enabled)), C_GREEN if bool(settings.haptics_enabled) else C_MUTED, 18)
	button(V10_SET_ANALYTICS, "ANALYTICS  %s" % _on_off(bool(settings.analytics_enabled)), C_GOLD if bool(settings.analytics_enabled) else C_MUTED, 18)
	button(V10_SET_TUTORIAL, "REPLAY TUTORIAL", C_PURPLE, 18)
	button(V10_SET_BACK, "BACK", C_BLUE, 20)
	draw_string(font, Vector2(96, 895), "Analytics is opt-in. Playtest events stay local in this build.", HORIZONTAL_ALIGNMENT_CENTER, 528, 13, C_MUTED)

func _draw_tutorial_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.01, 0.015, 0.04, 0.86))
	panel(Rect2(82, 260, 556, 700), Color("10162b"), C_GOLD)
	var title: String = "WELCOME TO THE TOWER"
	var body_a: String = "Move. Auto-attack. Survive."
	var body_b: String = "Every cleared floor asks one question: climb again or bank the loot?"
	var button_text: String = "NEXT"
	match tutorial_step:
		1:
			title = "RISK VS REWARD"
			body_a = "Pick one of three run upgrades after every floor."
			body_b = "Cash out to secure everything. Death only keeps part of unsecured coins."
			button_text = "START TUTORIAL RUN"
		2:
			title = "ONE-THUMB COMBAT"
			body_a = "Drag the left joystick to dodge. Attacks fire automatically at nearby enemies."
			body_b = "Tap NOVA when ready: it damages nearby enemies and clears hostile projectiles."
			button_text = "GOT IT"
		4:
			title = "BUILD THE RUN"
			body_a = "Choose one upgrade now. Your build changes every climb."
			body_b = "After the upgrade you can CASH OUT or press ONE MORE FLOOR."
			button_text = "FINISH TUTORIAL"
	draw_string(font, Vector2(112, 350), title, HORIZONTAL_ALIGNMENT_CENTER, 496, 30, C_GOLD)
	draw_string(font, Vector2(122, 455), body_a, HORIZONTAL_ALIGNMENT_CENTER, 476, 17, C_TEXT)
	draw_string(font, Vector2(122, 530), body_b, HORIZONTAL_ALIGNMENT_CENTER, 476, 16, C_MUTED)
	if tutorial_step == 2:
		draw_circle(Vector2(160, 660), 62, Color(C_BLUE, 0.18))
		draw_circle(Vector2(580, 660), 54, Color(C_CYAN, 0.18))
		draw_string(font, Vector2(90, 740), "MOVE", HORIZONTAL_ALIGNMENT_CENTER, 140, 16, C_BLUE)
		draw_string(font, Vector2(510, 740), "NOVA", HORIZONTAL_ALIGNMENT_CENTER, 140, 16, C_CYAN)
	button(V10_TUTORIAL_NEXT, button_text, C_GOLD, 20)

func _on_off(value: bool) -> String:
	return "ON" if value else "OFF"
