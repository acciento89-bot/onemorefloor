extends "res://scripts/main_v89.gd"

# ONE MORE FLOOR v1.67 — Frontend Completion r1.1 UI hierarchy pass.
# Real 720x1280 captures showed that the shared 3D Wanderer was correct but the
# older 2D screen hierarchy still made Hero cramped, Talents overly saturated,
# Missions table-like and an empty Vault feel unfinished. This layer fixes those
# presentation issues only; existing routes, hit rectangles and progression stay
# authoritative and unchanged.

const V90_FRONTEND_VISUAL := "1.67-frontend-visual-r1.1"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.event("frontend_visual_v167_ready", _v90_menu_visual_snapshot())

func _v90_menu_visual_completion_ready() -> bool:
	return _v89_frontend_completion_ready() \
		and _v80_runtime_cta_ready() \
		and has_method("_v90_stat_chip") \
		and has_method("_v90_draw_mission_progress")

func _v90_menu_visual_snapshot() -> Dictionary:
	return {
		"ready": _v90_menu_visual_completion_ready(),
		"version": V90_FRONTEND_VISUAL,
		"hero_character_space": true,
		"neutral_talent_cards": true,
		"mission_progress_hierarchy": true,
		"vault_empty_state": true,
		"shared_gameplay_wanderer": _v89_frontend_completion_ready(),
	}

func _v90_stat_chip(r: Rect2, label: String, value: String, accent: Color, icon_index: int) -> void:
	_v76_surface(r, accent, Color("080c14"), 0.14, false)
	_v16_medallion(Vector2(r.position.x + 26.0, r.get_center().y), 13.0, accent, icon_index)
	_v16_text(label, Vector2(r.position.x + 48.0, r.position.y + 25.0), 9, V16_MUTED, true)
	draw_string(v16_title_font, Vector2(r.position.x + 46.0, r.position.y + 53.0), value, HORIZONTAL_ALIGNMENT_LEFT, r.size.x - 56.0, 16, accent)

# -----------------------------------------------------------------------------
# HERO — let the real shared 3D Wanderer own the upper half. The old 2D shrine
# pillars/ring stack are removed so the character no longer looks boxed in.
# -----------------------------------------------------------------------------

func draw_hero_screen() -> void:
	_v16_header("HERO", "Permanent Wanderer training", V16_GREEN, 0, "arcane")
	_v15_soft_glow(Vector2(360, 492), 174.0, _v38_primary(), 0.16)

	var card := Rect2(62, 680, 596, 272)
	_v76_surface(card, V16_PURPLE, Color("070b13"), 0.20, false)
	_v16_center("WANDERER", 722, 29, V17_GOLD_HI, true)
	_v16_center("LEVEL %d" % int(meta.hero_level), 754, 13, V16_MUTED, true)

	_v90_stat_chip(Rect2(84, 780, 170, 78), "BASE HP", "+%d" % int(meta.hp_bonus()), V16_GREEN, 0)
	_v90_stat_chip(Rect2(275, 780, 170, 78), "DAMAGE", "x%.2f" % meta.damage_multiplier(), V16_ORANGE, 6)
	_v90_stat_chip(Rect2(466, 780, 170, 78), "POWER", str(int(meta.power_score())), V16_PURPLE_HI, 8)

	_v16_center("Every level strengthens the same Wanderer you take into the tower.", 914, 11, Color(V16_MUTED, 0.86))
	_v16_button(V19_HERO_BUY, "TRAIN  %d" % int(meta.hero_cost()), V16_PURPLE, 25, -1, meta.coins >= meta.hero_cost())
	_v16_center("+5 HP  •  +3.5% DAMAGE PER HERO LEVEL", 1125, 12, V16_MUTED, true)

# -----------------------------------------------------------------------------
# FORGE — the authored 3D forge engine is now the focal. Keep the lower card
# compact so the environment has room to read instead of hiding it behind UI.
# -----------------------------------------------------------------------------

func draw_forge_screen() -> void:
	_v16_header("FORGE", "Temper the Wanderer's weapon", V16_ORANGE, 7, "forge")
	_v15_soft_glow(Vector2(360, 520), 150.0, V16_ORANGE, 0.12)

	var card := Rect2(94, 716, 532, 214)
	_v76_surface(card, V16_ORANGE, Color("0a0909"), 0.22, false)
	_v16_center("FORGE LEVEL %d" % int(meta.forge_level), 763, 27, V17_IVORY, true)
	_v16_center("PERMANENT WEAPON POWER", 800, 10, V16_MUTED, true)
	_v16_center("+%.1f%% DAMAGE" % (float(meta.forge_level) * 8.5), 867, 34, V17_GOLD_HI, true)
	_v16_button(V19_FORGE_BUY, "TEMPER  %d" % int(meta.forge_cost()), V16_ORANGE, 24, 11, meta.coins >= meta.forge_cost())
	_v16_center("Each temper adds +8.5% permanent damage.", 1100, 12, V16_MUTED)

# -----------------------------------------------------------------------------
# TALENTS — same interaction geometry, but neutral forged cards replace the
# large green/purple/gold slabs seen in the first v1.67 capture.
# -----------------------------------------------------------------------------

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
		_v76_surface(r, accent, Color("080c14"), 0.18, false)
		draw_line(Vector2(r.position.x + 22.0, r.position.y + 3.0), Vector2(r.position.x + 120.0, r.position.y + 3.0), Color(accent, 0.92), 3.0, true)
		_v16_medallion(Vector2(r.position.x + 78.0, r.get_center().y), 35.0, accent, int(row["icon"]))
		_v16_text(String(row["name"]), r.position + Vector2(146.0, 58.0), 24, V17_IVORY, true)
		_v16_text("LEVEL %d" % int(row["level"]), r.position + Vector2(146.0, 87.0), 10, accent, true)
		_v16_text(String(row["desc"]), r.position + Vector2(146.0, 112.0), 12, V16_MUTED)
		draw_line(r.position + Vector2(148.0, 132.0), r.position + Vector2(354.0, 132.0), Color(accent, 0.22), 1.0, true)
		var cost: int = int(meta.talent_cost(String(row["kind"])))
		var buy := Rect2(r.end.x - 214.0, r.position.y + 51.0, 188.0, 68.0)
		_v16_button(buy, "UPGRADE  %d" % cost, accent, 13, 11, meta.coins >= cost)

# -----------------------------------------------------------------------------
# MISSIONS — retain the original row hitboxes but add a readable progress rail,
# reward grouping and compact status chip instead of a developer-table row.
# -----------------------------------------------------------------------------

func _draw_mission_v34(m: Dictionary, r: Rect2, weekly: bool) -> void:
	var complete: bool = bool(missions.is_complete(m, weekly))
	var claimed: bool = bool(missions.is_claimed(m, weekly))
	var accent: Color = V16_PURPLE_HI if weekly else V16_GREEN
	if complete and not claimed:
		accent = V16_GOLD
	if claimed:
		accent = Color("596273")
	_v76_surface(r, accent, Color("080c14"), 0.16, false)

	var progress_value: int = int(missions.progress(m, weekly))
	var goal: int = maxi(1, int(m.get("goal", 1)))
	_v16_text(String(m.get("title", "MISSION")), r.position + Vector2(18.0, 28.0), 17, V17_IVORY, true)
	_v16_text("%d / %d" % [progress_value, goal], r.position + Vector2(18.0, 54.0), 10, accent, true)
	_v90_draw_mission_progress(Rect2(r.position.x + 78.0, r.position.y + 45.0, 248.0, 8.0), progress_value, goal, accent)
	_v16_text("%d COINS" % int(m.get("coins", 0)), r.position + Vector2(348.0, 54.0), 9, V16_GOLD_HI, true)
	_v16_text("%d XP" % int(m.get("xp", 0)), r.position + Vector2(424.0, 54.0), 9, V16_PURPLE_HI, true)

	var status: String = "CLAIMED" if claimed else ("CLAIM" if complete else "ACTIVE")
	var status_accent: Color = Color("697080") if claimed else (V16_GOLD if complete else accent)
	_v76_surface(Rect2(r.end.x - 122.0, r.position.y + 20.0, 100.0, 44.0), status_accent, Color("090d14"), 0.10, complete and not claimed)
	draw_string(v16_title_font, Vector2(r.end.x - 117.0, r.position.y + 48.0), status, HORIZONTAL_ALIGNMENT_CENTER, 90.0, 10, V76_IVORY if not claimed else V16_MUTED)

func _v90_draw_mission_progress(r: Rect2, progress_value: int, goal: int, accent: Color) -> void:
	draw_rect(r, Color("151b26"))
	var ratio: float = clampf(float(progress_value) / float(maxi(goal, 1)), 0.0, 1.0)
	draw_rect(Rect2(r.position, Vector2(r.size.x * ratio, r.size.y)), Color(accent, 0.86))
	draw_line(r.position + Vector2(0.0, 1.0), Vector2(r.position.x + r.size.x * ratio, r.position.y + 1.0), Color("f1ecff", 0.22), 1.0, true)

func _draw_completion_v34(r: Rect2, weekly: bool) -> void:
	var ready: bool = bool(missions.completion_bonus_claimable(weekly))
	var claimed: bool = bool(missions.weekly_bonus_claimed if weekly else missions.daily_bonus_claimed)
	var accent: Color = V16_GOLD if ready else (V16_PURPLE_HI if weekly else V16_GREEN)
	_v76_surface(r, accent, Color("070b12"), 0.16, ready)
	_v16_medallion(Vector2(r.position.x + 28.0, r.get_center().y), 13.0, accent, 11)
	_v16_text(("WEEKLY" if weekly else "DAILY") + " COMPLETION", r.position + Vector2(52.0, 35.0), 12, V17_IVORY, true)
	var state_label: String = "CLAIM" if ready else ("CLAIMED" if claimed else "LOCKED")
	draw_string(v16_title_font, Vector2(r.end.x - 112.0, r.position.y + 37.0), state_label, HORIZONTAL_ALIGNMENT_CENTER, 96.0, 10, V16_GOLD_HI if ready else V16_MUTED)

# -----------------------------------------------------------------------------
# VAULT — when inventory is empty, the 3D vault door becomes an intentional
# destination rather than a giant blank patch behind disabled controls.
# -----------------------------------------------------------------------------

func draw_vault_screen() -> void:
	super.draw_vault_screen()
	if not _visible_vault_indices().is_empty():
		return
	var empty := Rect2(142, 382, 436, 244)
	_v76_surface(empty, V16_GOLD, Color(0.035, 0.045, 0.07, 0.88), 0.10, false)
	_v16_medallion(Vector2(360, 454), 31.0, V16_GOLD, 10)
	_v16_center("THE VAULT AWAITS", 516, 22, V17_IVORY, true)
	_v16_center("Gear recovered in the tower appears here.", 552, 11, V16_MUTED)
	_v16_center("Equip • compare • craft • awaken", 582, 10, Color(V16_GOLD, 0.86), true)
