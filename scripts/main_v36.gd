extends "res://scripts/main_v35.gd"

# v1.24 feedback polish: calmer Home hierarchy, integrated Ascension/Talents
# composition and seamless generated music loops.

const ReleaseAudioV2 = preload("res://scripts/release_audio_v2.gd")
const V36_VERSION := "1.24.0-ux-audio-feedback"

const V36_STORE_HOME := Rect2(468, 1168, 94, 50)
const V36_SETTINGS_HOME := Rect2(574, 1168, 106, 50)
const V36_MASTERY_OPEN := Rect2(430, 300, 198, 56)

func _ready() -> void:
	super._ready()
	# Replace the original generated-loop node after the inherited setup. Keeping
	# this at the top renderer avoids changing old compatibility layers.
	var old_audio: Node = release_audio as Node
	if old_audio != null and is_instance_valid(old_audio):
		if old_audio.get_parent() == self:
			remove_child(old_audio)
		old_audio.free()
	release_audio = ReleaseAudioV2.new()
	add_child(release_audio)
	release_audio.setup(settings)
	_sync_music_context(true)
	queue_redraw()

# -----------------------------------------------------------------------------
# Home — one dominant action, quieter secondary navigation.
# -----------------------------------------------------------------------------

func draw_home() -> void:
	if home_overlay == "store":
		draw_store_screen()
		return
	if home_overlay == "missions":
		draw_missions_screen()
		return
	if home_overlay == "pass":
		draw_pass_screen()
		return

	_v16_backdrop("home")
	_v16_frame(Rect2(18,18,190,100), V16_PURPLE, Color("050812"), 0.12)
	_v16_center_in(Rect2(30,32,166,28), "BEST FLOOR", 13, V16_MUTED, true)
	_v16_center_in(Rect2(30,57,166,49), str(int(meta.best_floor)), 35, V17_IVORY, true)
	_v16_currency(int(meta.coins), Rect2(512,18,190,92))

	# Strong identity, but the rest of the screen no longer competes with it.
	draw_string(v16_title_font, Vector2(48,159), "ONE MORE", HORIZONTAL_ALIGNMENT_CENTER, 624, 44, V17_IVORY)
	for off in [Vector2(0,5), Vector2(2,3), Vector2(-2,3)]:
		draw_string(v16_title_font, Vector2(46,236)+off, "FLOOR", HORIZONTAL_ALIGNMENT_CENTER, 628, 75, Color(0,0,0,0.78))
	draw_string(v16_title_font, Vector2(46,233), "FLOOR", HORIZONTAL_ALIGNMENT_CENTER, 628, 75, Color("fff0a6"))
	_v16_rule(255, V16_PURPLE, 390)
	_v16_center("CLIMB  •  LOOT  •  RISK IT ALL", 289, 14, V16_MUTED)

	_v15_soft_glow(Vector2(360,736), 70, V16_PURPLE, 0.90)
	draw_wanderer(Vector2(360,735), 1.55, false)

	# PLAY remains the only large, bright primary CTA.
	_v16_button(PLAY, "PLAY", V16_GOLD, 39)

	# Activities are intentionally flatter and quieter than PLAY.
	_v36_activity_button(MISSIONS_BTN, "MISSIONS", V16_GREEN, 0)
	_v36_activity_button(PASS_BTN, "TOWER PASS", V16_PURPLE, 6)

	# Progression tabs use one dark navigation family instead of four competing
	# glowing cards. Their accent survives as a small line/icon cue.
	_v36_home_tab(HERO_TAB, "HERO", 8, V16_BLUE)
	_v36_home_tab(FORGE_TAB, "FORGE", 7, V16_ORANGE)
	_v36_home_tab(TALENTS_TAB, "TALENTS", 1, V16_PURPLE)
	_v36_home_tab(VAULT_TAB, "VAULT", 10, V16_GOLD)

	# Utility actions live in the footer now. STORE no longer hangs under Coins
	# and SETTINGS no longer floats beside the character.
	_v16_frame(Rect2(20,1156,680,76), Color("323a5c"), Color("030611"), 0.05)
	_v16_text("POWER", Vector2(42,1194), 13, V16_MUTED, true)
	_v16_text(str(int(meta.power_score())), Vector2(106,1197), 23, V17_GOLD_HI, true)
	draw_string(v16_body_font, Vector2(222,1195), "KAMILUNAVO GAMES", HORIZONTAL_ALIGNMENT_CENTER, 225, 10, Color(V16_MUTED,0.72))
	_v36_utility_button(V36_STORE_HOME, "STORE", V16_GOLD, 11)
	_v36_utility_button(V36_SETTINGS_HOME, "SETTINGS", V16_BLUE, 9)

	if recovery_notice_time > 0.0:
		_v16_frame(Rect2(184,304,352,42), V16_GOLD, Color("07101d"), 0.08)
		_v16_center("PREVIOUS SESSION RECOVERED", 331, 11, V16_GOLD_HI)
	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step in [0,1]:
		_draw_tutorial_overlay()

func _v36_activity_button(r: Rect2, label: String, accent: Color, icon_index: int) -> void:
	draw_rect(Rect2(r.position + Vector2(4,5), r.size), Color(0,0,0,0.46))
	draw_rect(r, Color("070b13"))
	draw_rect(r.grow(-2), Color(accent,0.10))
	draw_line(Vector2(r.position.x+8,r.position.y+2), Vector2(r.end.x-8,r.position.y+2), Color(accent,0.82), 2.0)
	_v16_medallion(Vector2(r.position.x+34,r.get_center().y), 18, accent, icon_index)
	draw_string(v16_title_font, Vector2(r.position.x+62,r.get_center().y+6), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x-76, 16, V17_IVORY)

func _v36_home_tab(r: Rect2, label: String, icon_index: int, accent: Color) -> void:
	draw_rect(Rect2(r.position + Vector2(3,5), r.size), Color(0,0,0,0.52))
	draw_rect(r, Color("050912"))
	draw_rect(r, Color("343b54"), false, 1.5)
	draw_line(Vector2(r.position.x+8,r.position.y+2), Vector2(r.end.x-8,r.position.y+2), Color(accent,0.78), 2.0)
	_v16_medallion(Vector2(r.get_center().x,r.position.y+35), 20, accent, icon_index)
	draw_string(v16_title_font, Vector2(r.position.x+5,r.end.y-18), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x-10, 14, V17_IVORY)

func _v36_utility_button(r: Rect2, label: String, accent: Color, icon_index: int) -> void:
	draw_rect(r, Color("080c15"))
	draw_rect(r, Color(accent,0.34), false, 1.0)
	_v16_medallion(Vector2(r.position.x+20,r.get_center().y), 13, accent, icon_index)
	draw_string(v16_body_font, Vector2(r.position.x+38,r.get_center().y+4), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x-42, 9, V17_IVORY)

# -----------------------------------------------------------------------------
# Talents — Ascension is now one intentional summary card instead of a second
# framed block/button stack sitting on top of the Talent layout.
# -----------------------------------------------------------------------------

func talent_rect(i: int) -> Rect2:
	return Rect2(42, 416 + i * 196, 636, 170)

func draw_talents_screen() -> void:
	if v31_mastery_open:
		_v16_backdrop("arcane")
		_v31_draw_mastery_overlay()
		return

	_v16_header("TALENTS", "Permanent passive bonuses", V16_PURPLE, 1, "arcane")
	_v36_draw_ascension_summary()

	var rows: Array = [
		{"name":"VITALITY", "kind":"vitality", "level":meta.vitality_level, "desc":"+12 starting HP / level", "color":V16_GREEN, "icon":0},
		{"name":"PRECISION", "kind":"precision", "level":meta.precision_level, "desc":"+1.8% starting crit / level", "color":V16_PURPLE, "icon":1},
		{"name":"FORTUNE", "kind":"fortune", "level":meta.fortune_level, "desc":"+6% coin drops / level", "color":V16_GOLD, "icon":11},
	]
	for i in range(rows.size()):
		var row: Dictionary = rows[i]
		var r: Rect2 = talent_rect(i)
		var accent: Color = row["color"]
		_v16_frame(r, accent, Color(accent,0.065), 0.13)
		_v16_medallion(Vector2(r.position.x+78,r.get_center().y), 42, accent, int(row["icon"]))
		_v16_text(String(row["name"]), r.position+Vector2(146,60), 25, V17_IVORY, true)
		_v16_text("Lv. %d  •  %s" % [int(row["level"]), String(row["desc"])], r.position+Vector2(146,96), 14, V16_MUTED)
		draw_line(r.position+Vector2(148,122), r.position+Vector2(366,122), Color(accent,0.24), 1.0)
		var cost: int = int(meta.talent_cost(String(row["kind"])))
		var buy := Rect2(r.end.x-214, r.position.y+51, 188, 68)
		_v16_button(buy, "UPGRADE  %d" % cost, accent, 13, 11, meta.coins >= cost)

func _v36_draw_ascension_summary() -> void:
	var r := Rect2(54, 226, 612, 156)
	_v16_frame(r, V16_PURPLE, Color("070912"), 0.10)
	_v16_medallion(Vector2(94, r.get_center().y), 26, V16_PURPLE, 1)
	_v16_text("ASCENSION", Vector2(136,266), 18, V17_IVORY, true)
	_v16_text("%d SIGILS" % int(meta.ascension_sigils), Vector2(136,294), 14, V16_GOLD_HI, true)
	_v16_text("Warpath %d  •  Guardian %d  •  Arcana %d" % [int(meta.mastery_level("warpath")), int(meta.mastery_level("guardian")), int(meta.mastery_level("arcana"))], Vector2(136,322), 11, V16_MUTED)
	_v16_text("Deep-floor milestones fund permanent masteries.", Vector2(136,346), 10, Color(V16_MUTED,0.80))
	_v16_button(V36_MASTERY_OPEN, "MASTERY", V16_PURPLE, 12, -1, true)

# -----------------------------------------------------------------------------
# Input alignment for moved Home utilities and compact Mastery button.
# -----------------------------------------------------------------------------

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if not pressed:
		super.pointer(pos, pressed, id)
		return

	if state == State.HOME and home_overlay == "" and not settings_open and not tutorial_active:
		if V36_STORE_HOME.has_point(pos):
			home_overlay = "store"
			_audio("menu")
			return
		if V36_SETTINGS_HOME.has_point(pos):
			settings_open = true
			settings_return_to_pause = false
			_audio("menu")
			return
		# Swallow the retired invisible hit areas from older renderers.
		if STORE_HOME.has_point(pos) or V10_SETTINGS_HOME.has_point(pos):
			return

	if state == State.TALENTS and not settings_open and not v31_mastery_open:
		if V36_MASTERY_OPEN.has_point(pos):
			v31_mastery_open = true
			_audio("menu")
			queue_redraw()
			return
		# The v1.17 button occupied a much larger overlapping area. It is retired.
		if V31_MASTERY_OPEN.has_point(pos):
			return

	super.pointer(pos, pressed, id)
