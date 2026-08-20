extends "res://scripts/main_v96.gd"

# ONE MORE FLOOR v1.73 r1 — Run Flow Presentation Completion.
# Replaces legacy between-combat/result presentation while preserving all input
# rectangles, progression math, save data, combat authority and accepted 3D locks.

const V97_RUN_FLOW_VERSION := "1.73-run-flow-presentation-r1"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.event("run_flow_v173_ready", _v97_run_flow_snapshot())
	queue_redraw()

func _v97_run_flow_ready() -> bool:
	return _v96_polish_ready() \
		and CASH == Rect2(72, 880, 264, 92) \
		and NEXT == Rect2(384, 880, 264, 92) \
		and RETRY == Rect2(72, 900, 264, 92) \
		and HOME_BTN == Rect2(384, 900, 264, 92)

func _v97_run_flow_snapshot() -> Dictionary:
	return {
		"ready": _v97_run_flow_ready(),
		"version": V97_RUN_FLOW_VERSION,
		"v172_preserved": _v96_polish_ready(),
		"decision_full_redraw": true,
		"game_over_full_redraw": true,
		"floor_transition_plate": true,
		"boss_intro_plate": true,
		"input_override": false,
		"cash_rect": CASH,
		"next_rect": NEXT,
		"retry_rect": RETRY,
		"home_rect": HOME_BTN,
	}

# -----------------------------------------------------------------------------
# Between-floor decision — full presentation replacement.
# CASH/NEXT remain the exact inherited interaction rectangles.
# -----------------------------------------------------------------------------

func draw_decision() -> void:
	var accent := _v173_accent()
	_v12_background(accent)

	var floor_no := int(run.floor_no) if run != null else 1
	var area := String(current_room.get("area", "THE TOWER"))
	var next_floor := floor_no + 1
	var header := Rect2(46, 116, 628, 220)
	_v16_frame(header, accent, Color("050811"), 0.32)
	_v16_text("ASCENT DECISION", Vector2(76, 158), 11, Color(accent, 0.94), true)
	_v16_text("FLOOR %d SECURED" % floor_no, Vector2(76, 211), 32, V17_IVORY, true)
	_v16_text(area, Vector2(76, 245), 12, V16_MUTED, true)
	_v16_text("The door above is open. Decide what this run is worth.", Vector2(76, 286), 12, V16_MUTED)

	_v173_draw_run_ledger(Rect2(58, 372, 604, 166), accent)

	var risk := Rect2(58, 574, 604, 186)
	_v16_frame(risk, accent, Color("070a13"), 0.18)
	_v16_text("THE NEXT FLOOR", Vector2(84, 614), 10, Color(accent, 0.90), true)
	_v16_text("FLOOR %d" % next_floor, Vector2(84, 661), 27, V17_IVORY, true)
	var next_identity := "UNKNOWN CHAMBER"
	if run != null:
		next_identity = _v49_floor_identity(next_floor)
	_v16_text(next_identity, Vector2(84, 690), 10, Color(accent, 0.86), true)
	_v16_text("Climb to keep every run upgrade active — but the unsecured haul stays at risk.", Vector2(84, 727), 10, V16_MUTED)

	_v173_draw_decision_choice(CASH, "BANK THE RUN", "Secure the haul and return Home.", V16_GREEN, false)
	_v173_draw_decision_choice(NEXT, "ONE MORE FLOOR", "Keep the build. Raise the stakes.", V16_GOLD, true)
	_v80_runtime_cta(CASH, "CASH OUT", V16_GREEN, false)
	_v80_runtime_cta(NEXT, "ONE MORE FLOOR", V16_GOLD, true)

	if run != null and meta != null and int(run.floor_no) >= 50 and meta.has_method("death_setback_amount"):
		var setback := int(meta.death_setback_amount(int(run.floor_no)))
		if setback > 0:
			_v16_center("DEATH NOW PUSHES THE CHECKPOINT BACK %d FLOORS" % setback, 1026, 10, V16_RED, true)
			_v16_center("Cashing out protects the current checkpoint.", 1050, 9, V16_MUTED)
	else:
		_v16_center("Your choice changes the run immediately. There is no confirmation screen.", 1040, 9, Color(V16_MUTED, 0.82))

func _v173_draw_run_ledger(r: Rect2, accent: Color) -> void:
	_v16_frame(r, accent, Color("050811"), 0.14)
	var run_coins := int(run.run_coins) if run != null else 0
	var hp_now := float(run.hp) if run != null else 0.0
	var hp_max := maxf(1.0, float(run.max_hp)) if run != null else 1.0
	var hp_pct := int(round(clampf(hp_now / hp_max, 0.0, 1.0) * 100.0))
	var floor_no := int(run.floor_no) if run != null else 1

	var col_w := r.size.x / 3.0
	for i in range(1, 3):
		var x := r.position.x + col_w * float(i)
		draw_line(Vector2(x, r.position.y + 24), Vector2(x, r.end.y - 24), Color(accent, 0.16), 1.0)
	_v173_stat_cell(Rect2(r.position, Vector2(col_w, r.size.y)), "UNSECURED", "%d" % run_coins, "RUN COINS", V17_GOLD_HI)
	_v173_stat_cell(Rect2(r.position + Vector2(col_w, 0), Vector2(col_w, r.size.y)), "SURVIVAL", "%d%%" % hp_pct, "HEALTH", V16_GREEN)
	_v173_stat_cell(Rect2(r.position + Vector2(col_w * 2.0, 0), Vector2(col_w, r.size.y)), "DEPTH", "%d" % floor_no, "FLOOR", accent)

func _v173_stat_cell(r: Rect2, eyebrow: String, value: String, label: String, color: Color) -> void:
	draw_string(v16_body_font, Vector2(r.position.x + 8, r.position.y + 38), eyebrow, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16, 9, Color(V16_MUTED, 0.78))
	draw_string(v16_title_font, Vector2(r.position.x + 8, r.position.y + 92), value, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16, 29, color)
	draw_string(v16_body_font, Vector2(r.position.x + 8, r.position.y + 122), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16, 9, V16_MUTED)

func _v173_draw_decision_choice(r: Rect2, title: String, subtitle: String, accent: Color, primary: bool) -> void:
	var info_y := r.position.y - 54.0
	draw_string(v16_title_font, Vector2(r.position.x, info_y), title, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 11, V17_IVORY if primary else V76_IVORY)
	draw_string(v16_body_font, Vector2(r.position.x - 4, info_y + 22.0), subtitle, HORIZONTAL_ALIGNMENT_CENTER, r.size.x + 8, 8, Color(accent, 0.82))

# -----------------------------------------------------------------------------
# Game over / run result — full presentation replacement.
# RETRY/HOME_BTN remain the exact inherited interaction rectangles.
# -----------------------------------------------------------------------------

func draw_game_over() -> void:
	var accent := V16_RED
	_v12_background(accent)
	var floor_no := int(run.floor_no) if run != null else 1
	var area := String(current_room.get("area", "THE TOWER"))
	var run_coins := int(run.run_coins) if run != null else 0

	var header := Rect2(46, 122, 628, 222)
	_v16_frame(header, accent, Color("08080d"), 0.34)
	_v16_text("RUN ENDED", Vector2(76, 164), 11, Color(accent, 0.94), true)
	_v16_text("THE TOWER WON THIS ROUND", Vector2(76, 214), 27, V17_IVORY, true)
	_v16_text("%s  •  FLOOR %d" % [area, floor_no], Vector2(76, 250), 11, V16_MUTED, true)
	_v16_text("Your permanent progress remains. The next climb starts from the saved checkpoint.", Vector2(76, 295), 10, V16_MUTED)

	var summary := Rect2(58, 382, 604, 210)
	_v16_frame(summary, accent, Color("060810"), 0.15)
	_v16_text("RUN SUMMARY", Vector2(84, 422), 10, Color(accent, 0.88), true)
	_v16_text("FLOOR %d" % floor_no, Vector2(84, 478), 30, V17_IVORY, true)
	_v16_text("%d RUN COINS AT DEATH" % run_coins, Vector2(84, 516), 11, V17_GOLD_HI, true)
	var resume_floor := maxi(1, int(v27_resume_floor))
	_v16_text("NEXT START  •  FLOOR %d" % resume_floor, Vector2(84, 554), 10, V16_MUTED, true)

	var consequence := Rect2(58, 628, 604, 142)
	_v16_frame(consequence, accent, Color("070910"), 0.12)
	if int(v27_last_setback) > 0:
		_v16_text("TOWER SETBACK", Vector2(84, 669), 10, Color(accent, 0.92), true)
		_v16_text("-%d FLOORS" % int(v27_last_setback), Vector2(84, 713), 26, accent, true)
		_v16_text("Checkpoint moved back to Floor %d." % resume_floor, Vector2(286, 709), 10, V16_MUTED)
	else:
		_v16_text("CHECKPOINT READY", Vector2(84, 674), 10, V16_GREEN, true)
		_v16_text("RETRY WHEN READY", Vector2(84, 718), 23, V17_IVORY, true)
		_v16_text("Permanent progression and equipped gear remain intact.", Vector2(84, 746), 9, V16_MUTED)

	_v173_draw_result_choice(RETRY, "RETRY", "Return to the saved checkpoint.", V16_GOLD, true)
	_v173_draw_result_choice(HOME_BTN, "HOME", "Review gear and permanent upgrades.", V16_PURPLE, false)
	_v80_runtime_cta(RETRY, "RETRY", V16_GOLD, true)
	_v80_runtime_cta(HOME_BTN, "HOME", V16_PURPLE, false)
	if bool(v66_tutorial_retry_pending):
		_v16_center("Retry continues the guided run.", 1044, 9, V16_MUTED)
	else:
		_v16_center("Every failed climb strengthens the next decision.", 1044, 9, Color(V16_MUTED, 0.82))

func _v173_draw_result_choice(r: Rect2, title: String, subtitle: String, accent: Color, primary: bool) -> void:
	var info_y := r.position.y - 52.0
	draw_string(v16_title_font, Vector2(r.position.x, info_y), title, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 11, V17_IVORY if primary else V76_IVORY)
	draw_string(v16_body_font, Vector2(r.position.x - 4, info_y + 21.0), subtitle, HORIZONTAL_ALIGNMENT_CENTER, r.size.x + 8, 8, Color(accent, 0.82))

# -----------------------------------------------------------------------------
# Running-state transition / boss introduction replacement.
# Legacy presentation timers are suppressed only during the inherited draw call;
# their actual values and gameplay timing are restored immediately afterwards.
# -----------------------------------------------------------------------------

func draw_game() -> void:
	var legacy := {
		"room_transition": room_transition,
		"floor_banner": floor_banner,
		"boss_intro": boss_intro,
		"keeper_intro": keeper_intro,
		"hollow_intro": hollow_intro,
		"miniboss_intro": v23_miniboss_intro,
		"null_intro": null_intro,
		"endgame_boss_intro": v28_boss_intro,
		"realm_flash": v28_realm_flash,
	}
	room_transition = 0.0
	floor_banner = 0.0
	boss_intro = 0.0
	keeper_intro = 0.0
	hollow_intro = 0.0
	v23_miniboss_intro = 0.0
	null_intro = 0.0
	v28_boss_intro = 0.0
	v28_realm_flash = 0.0
	super.draw_game()
	room_transition = float(legacy["room_transition"])
	floor_banner = float(legacy["floor_banner"])
	boss_intro = float(legacy["boss_intro"])
	keeper_intro = float(legacy["keeper_intro"])
	hollow_intro = float(legacy["hollow_intro"])
	v23_miniboss_intro = float(legacy["miniboss_intro"])
	null_intro = float(legacy["null_intro"])
	v28_boss_intro = float(legacy["endgame_boss_intro"])
	v28_realm_flash = float(legacy["realm_flash"])

	var intro_key := _v173_intro_key_from(legacy)
	if not intro_key.is_empty():
		_v173_draw_boss_intro(intro_key)
	elif float(legacy["realm_flash"]) > 0.0 or float(legacy["room_transition"]) > 0.0 or float(legacy["floor_banner"]) > 0.0:
		_v173_draw_floor_transition()

func _v173_intro_key_from(legacy: Dictionary) -> String:
	if float(legacy.get("hollow_intro", 0.0)) > 0.0:
		return "hollow_king"
	if float(legacy.get("keeper_intro", 0.0)) > 0.0:
		return "crypt_keeper"
	if float(legacy.get("null_intro", 0.0)) > 0.0:
		return "null_sovereign"
	if float(legacy.get("endgame_boss_intro", 0.0)) > 0.0:
		return "endgame_boss"
	if float(legacy.get("miniboss_intro", 0.0)) > 0.0:
		return "miniboss"
	if float(legacy.get("boss_intro", 0.0)) > 0.0:
		return "warden"
	return ""

func _v173_draw_floor_transition() -> void:
	if run == null:
		return
	var accent := _v173_accent()
	var floor_no := int(run.floor_no)
	var area := String(current_room.get("area", "THE TOWER"))
	var room_type := String(current_room.get("type", "COMBAT"))
	var plate := Rect2(92, 402, 536, 166)
	draw_rect(Rect2(0, 368, 720, 238), Color("02040a", 0.74))
	_v16_frame(plate, accent, Color("050811", 0.96), 0.34)
	_v16_center("FLOOR %d" % floor_no, 453, 13, Color(accent, 0.94), true)
	_v16_center(area, 493, 28, V17_IVORY, true)
	_v16_center("%s  •  %s" % [room_type, _v49_floor_identity(floor_no)], 529, 9, V16_MUTED, true)
	draw_line(Vector2(150, 548), Vector2(570, 548), Color(accent, 0.32), 1.0)

func _v173_draw_boss_intro(key: String) -> void:
	var accent := _v173_boss_accent(key)
	var title := _v173_boss_title(key)
	var subtitle := _v173_boss_subtitle(key)
	var plate := Rect2(74, 360, 572, 224)
	draw_rect(Rect2(0, 320, 720, 302), Color("010207", 0.82))
	_v16_frame(plate, accent, Color("05070d", 0.98), 0.44)
	_v16_center("BOSS ENCOUNTER" if key != "miniboss" else "ELITE ENCOUNTER", 407, 10, Color(accent, 0.94), true)
	_v16_center(title, 468, 34, V17_IVORY, true)
	_v16_center(subtitle, 510, 10, V16_MUTED, true)
	_v16_center("SURVIVE THE PATTERN. BREAK THE CYCLE.", 551, 9, Color(accent, 0.80), true)

func _v173_boss_title(key: String) -> String:
	match key:
		"hollow_king": return "HOLLOW KING"
		"crypt_keeper": return "CRYPT KEEPER"
		"null_sovereign": return "NULL SOVEREIGN"
		"miniboss": return "TOWER ELITE"
		"warden": return "THE WARDEN"
		"endgame_boss":
			for e in enemies:
				if String(e.get("type", "")) == "warden":
					return _v28_boss_title(String(e.get("boss_variant", "warden")))
			return "ASCENSION WARDEN"
	return "BOSS"

func _v173_boss_subtitle(key: String) -> String:
	var floor_no := int(run.floor_no) if run != null else 1
	var area := String(current_room.get("area", "THE TOWER"))
	if key == "miniboss":
		return "%s  •  FLOOR %d MINIBOSS" % [area, floor_no]
	return "%s  •  FLOOR %d" % [area, floor_no]

func _v173_boss_accent(key: String) -> Color:
	match key:
		"hollow_king": return V16_GOLD
		"crypt_keeper": return Color("73d9d1")
		"null_sovereign": return Color("c58cff")
		"miniboss": return Color("e6a85c")
		"warden": return Color("d99b53")
		"endgame_boss": return _v173_accent()
	return V16_RED

func _v173_accent() -> Color:
	if run != null:
		return _v49_screen_accent()
	return V16_PURPLE
