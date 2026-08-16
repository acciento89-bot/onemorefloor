extends "res://scripts/main_v24.gd"

# ONE MORE FLOOR v1.13 — depth and replayability pass.
# Adds combat combos, elite affixes, run modifiers, real treasure-room bonuses,
# clearer run summaries and an MSDF font path that survives fractional preview
# scaling much better than the previous rasterized small text.

const V25_VERSION := "1.13-combos-affixes-summary"
const SUMMARY_CONTINUE := Rect2(170, 860, 380, 76)

var combo_count := 0
var combo_best := 0
var combo_timer := 0.0
var run_kills := 0
var run_elite_kills := 0
var run_boss_kills := 0
var run_start_floor := 1
var run_peak_floor := 1
var run_modifier := "NONE"
var run_modifier_coin_mult := 1.0
var summary_open := false
var summary_reason := ""
var summary_secured := 0
var treasure_awarded_floor := -1

func _ready() -> void:
	super._ready()
	_v25_install_msdf_fonts()

func _process(delta: float) -> void:
	super._process(delta)
	if combo_timer > 0.0:
		combo_timer = maxf(0.0, combo_timer - delta)
		if combo_timer <= 0.0:
			combo_count = 0

func _v25_install_msdf_fonts() -> void:
	# The Godot editor often embeds the 720x1280 game at ~50% scale. At that
	# fractional scale tiny raster glyphs become visibly soft. MSDF + mipmaps keeps
	# the vector glyph edge stable while scaling down and also sharpens combat text.
	var body := SystemFont.new()
	body.font_names = PackedStringArray(["Avenir Next", "Helvetica Neue", "Arial", "DejaVu Sans"])
	body.font_weight = 550
	body.allow_system_fallback = true
	body.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	body.hinting = TextServer.HINTING_NORMAL
	body.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO
	body.multichannel_signed_distance_field = true
	body.msdf_size = 64
	body.msdf_pixel_range = 16
	body.generate_mipmaps = true
	body.disable_embedded_bitmaps = true
	font = body
	v16_body_font = body

	var title := SystemFont.new()
	title.font_names = PackedStringArray(["Georgia", "Times New Roman", "DejaVu Serif"])
	title.font_weight = 650
	title.allow_system_fallback = true
	title.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	title.hinting = TextServer.HINTING_NORMAL
	title.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_AUTO
	title.multichannel_signed_distance_field = true
	title.msdf_size = 72
	title.msdf_pixel_range = 18
	title.generate_mipmaps = true
	title.disable_embedded_bitmaps = true
	v16_title_font = title

	var viewport := get_viewport()
	if viewport != null:
		viewport.oversampling_override = 3.0
	queue_redraw()

# -----------------------------------------------------------------------------
# Run modifiers / ascension pressure
# -----------------------------------------------------------------------------

func start_run() -> void:
	combo_count = 0
	combo_best = 0
	combo_timer = 0.0
	run_kills = 0
	run_elite_kills = 0
	run_boss_kills = 0
	summary_open = false
	treasure_awarded_floor = -1
	_v25_roll_run_modifier()
	super.start_run()
	run_start_floor = int(run.floor_no)
	run_peak_floor = run_start_floor
	if run_modifier == "GLASS CROWN":
		run.damage *= 1.18
	if run_modifier != "NONE":
		loot_notice = "%s — %s" % [run_modifier, _v25_modifier_short_desc()]
		loot_notice_color = C_PURPLE
		loot_notice_time = 3.0

func _v25_roll_run_modifier() -> void:
	run_modifier_coin_mult = 1.0
	if meta == null or int(meta.best_floor) < 10:
		run_modifier = "NONE"
		return
	var pool := ["BLOOD MOON", "IRON OATH", "GLASS CROWN"]
	run_modifier = String(pool[rng.randi_range(0, pool.size() - 1)])
	match run_modifier:
		"BLOOD MOON": run_modifier_coin_mult = 1.25
		"IRON OATH": run_modifier_coin_mult = 1.18
		"GLASS CROWN": run_modifier_coin_mult = 1.35

func _v25_modifier_short_desc() -> String:
	match run_modifier:
		"BLOOD MOON": return "+25% enemy damage • +25% coins"
		"IRON OATH": return "+35% enemy HP • +18% coins"
		"GLASS CROWN": return "+18% player damage • +55% enemy damage • +35% coins"
	return "Standard tower rules"

func spawn_floor() -> void:
	super.spawn_floor()
	run_peak_floor = maxi(run_peak_floor, int(run.floor_no))
	_v25_apply_modifier_to_spawned_enemies()
	_v25_apply_elite_affixes()
	_v25_award_treasure_room()

func _v25_apply_modifier_to_spawned_enemies() -> void:
	if run_modifier == "NONE":
		return
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		if bool(e.get("v25_modifier_applied", false)):
			continue
		match run_modifier:
			"BLOOD MOON":
				e["touch_damage"] = float(e.get("touch_damage", 0.0)) * 1.25
			"IRON OATH":
				e["max_hp"] = float(e.get("max_hp", e.get("hp", 1.0))) * 1.35
				e["hp"] = float(e["max_hp"])
			"GLASS CROWN":
				e["touch_damage"] = float(e.get("touch_damage", 0.0)) * 1.55
		e["v25_modifier_applied"] = true
		enemies[i] = e

# -----------------------------------------------------------------------------
# Elite affixes
# -----------------------------------------------------------------------------

func _v25_apply_elite_affixes() -> void:
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		var is_boss := String(e.get("type", "")) == "warden"
		var should_affix := bool(e.get("elite", false)) or bool(e.get("miniboss", false)) or (is_boss and int(run.floor_no) >= 15)
		if not should_affix or String(e.get("affix", "")) != "":
			continue
		var pool := ["BULWARK", "FRENZIED", "DEADLY", "VOLATILE"]
		var affix := String(pool[rng.randi_range(0, pool.size() - 1)])
		e["affix"] = affix
		match affix:
			"BULWARK":
				e["max_hp"] = float(e.get("max_hp", e.get("hp", 1.0))) * 1.35
				e["hp"] = float(e["max_hp"])
				e["reward"] = int(round(float(e.get("reward", 1)) * 1.22))
			"FRENZIED":
				e["speed"] = float(e.get("speed", 0.0)) * 1.25
				e["touch_damage"] = float(e.get("touch_damage", 0.0)) * 1.18
				e["reward"] = int(round(float(e.get("reward", 1)) * 1.20))
			"DEADLY":
				e["touch_damage"] = float(e.get("touch_damage", 0.0)) * 1.38
				e["reward"] = int(round(float(e.get("reward", 1)) * 1.24))
			"VOLATILE":
				e["reward"] = int(round(float(e.get("reward", 1)) * 1.18))
		enemies[i] = e

func _v25_affix_color(affix: String) -> Color:
	match affix:
		"BULWARK": return C_BLUE
		"FRENZIED": return C_ORANGE
		"DEADLY": return C_RED
		"VOLATILE": return C_PURPLE
	return C_MUTED

# -----------------------------------------------------------------------------
# Kills, combo streaks and rewards
# -----------------------------------------------------------------------------

func remove_dead() -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if float(enemies[i]["hp"]) > 0.0:
			continue
		var e: Dictionary = enemies[i]
		var kind := String(e.get("type", ""))
		_v25_register_kill(e)
		var bonuses: Dictionary = loot.equipped_bonuses()
		var combo_mult := 1.0 + minf(0.50, float(maxi(0, combo_count - 1)) * 0.035)
		var reward := int(round(
			float(e.get("reward", 1))
			* meta.coin_multiplier()
			* (1.0 + float(bonuses["coin_pct"]))
			* run_modifier_coin_mult
			* combo_mult
		))
		coin_orbs.append({"pos":e["pos"], "value":reward, "age":0.0})
		effects.append({"type":"burst", "pos":e["pos"], "age":0.0, "dur":0.30, "color":enemy_color(kind), "kind":""})
		missions.record("kills", 1)
		if kind == "warden":
			missions.record("wardens", 1)
			tower_pass.add_xp(70)
			screen_shake = 12.0
			haptic(80)
		if String(e.get("affix", "")) == "VOLATILE":
			_v25_volatile_death(e)
		var item: Dictionary = loot.roll_drop(kind, int(run.floor_no), rng)
		if not item.is_empty():
			loot_notice = "%s %s — %s" % [String(item["rarity"]), String(item["name"]), loot.stat_line(item)]
			loot_notice_color = rarity_color(String(item["rarity"]))
			loot_notice_time = 2.4
			effects.append({"type":"loot_beam", "pos":e["pos"], "age":0.0, "dur":0.72, "color":loot_notice_color, "kind":String(item["rarity"])})
			_audio("loot")
		enemies.remove_at(i)

func _v25_register_kill(e: Dictionary) -> void:
	run_kills += 1
	if bool(e.get("elite", false)) or bool(e.get("miniboss", false)):
		run_elite_kills += 1
	if String(e.get("type", "")) == "warden":
		run_boss_kills += 1
	if combo_timer > 0.0:
		combo_count += 1
	else:
		combo_count = 1
	combo_timer = 2.2
	combo_best = maxi(combo_best, combo_count)
	if combo_count in [5, 10, 15, 20]:
		loot_notice = "%d KILL COMBO — COIN BONUS x%.2f" % [combo_count, 1.0 + minf(0.50, float(combo_count - 1) * 0.035)]
		loot_notice_color = C_GOLD
		loot_notice_time = 1.4

func _v25_volatile_death(e: Dictionary) -> void:
	var p: Vector2 = e.get("pos", Vector2.ZERO)
	var dmg := 8.0 + float(run.floor_no) * 0.42
	for n in range(8):
		var dir := Vector2.from_angle(TAU * float(n) / 8.0)
		enemy_shots.append({"pos":p + dir * 24.0, "vel":dir * 245.0, "damage":dmg, "life":2.4, "color":C_PURPLE})
	effects.append({"type":"nova", "pos":p, "age":0.0, "dur":0.34, "color":C_PURPLE, "kind":""})

# -----------------------------------------------------------------------------
# Treasure rooms that are actually worth finding
# -----------------------------------------------------------------------------

func _v25_award_treasure_room() -> void:
	if String(current_room.get("type", "")) != "TREASURE":
		return
	if treasure_awarded_floor == int(run.floor_no):
		return
	treasure_awarded_floor = int(run.floor_no)
	var bonus_coins := 24 + int(run.floor_no) * 3
	var bonus_shards := 7 + int(run.floor_no / 4)
	run.run_coins += bonus_coins
	loot.shards += bonus_shards
	var cache_item: Dictionary = loot.roll_drop("warden", int(run.floor_no), rng)
	loot.save_data()
	if cache_item.is_empty():
		loot_notice = "TREASURE CHAMBER — +%d COINS • +%d SHARDS" % [bonus_coins, bonus_shards]
	else:
		loot_notice = "TREASURE CHAMBER — %s %s • +%d SHARDS" % [String(cache_item["rarity"]), String(cache_item["name"]), bonus_shards]
	loot_notice_color = C_GOLD
	loot_notice_time = 3.0
	_audio("loot")

# -----------------------------------------------------------------------------
# Run summaries
# -----------------------------------------------------------------------------

func continue_run() -> void:
	super.continue_run()
	run_peak_floor = maxi(run_peak_floor, int(run.floor_no))

func cash_out() -> void:
	summary_reason = "CASHED OUT"
	summary_secured = int(run.run_coins)
	run_peak_floor = maxi(run_peak_floor, int(run.floor_no))
	super.cash_out()
	summary_open = true

func die() -> void:
	summary_reason = "DEFEATED"
	run_peak_floor = maxi(run_peak_floor, int(run.floor_no))
	super.die()
	summary_secured = int(run.saved_after_death)

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if pressed and summary_open:
		if SUMMARY_CONTINUE.has_point(pos):
			summary_open = false
			_audio("menu")
		return
	super.pointer(pos, pressed, id)

func draw_home() -> void:
	super.draw_home()
	if summary_open and not settings_open:
		_v25_draw_cashout_summary()

func draw_game_over() -> void:
	super.draw_game_over()
	panel(Rect2(118, 690, 484, 158), Color("0a1020"), C_PURPLE)
	draw_string(font, Vector2(140, 728), "RUN SUMMARY", HORIZONTAL_ALIGNMENT_CENTER, 440, 20, C_GOLD)
	draw_string(font, Vector2(140, 766), "F%d → F%d   •   %d KILLS   •   BEST COMBO x%d" % [run_start_floor, run_peak_floor, run_kills, combo_best], HORIZONTAL_ALIGNMENT_CENTER, 440, 14, C_TEXT)
	draw_string(font, Vector2(140, 804), "%d ELITES   •   %d BOSSES   •   %s" % [run_elite_kills, run_boss_kills, run_modifier], HORIZONTAL_ALIGNMENT_CENTER, 440, 13, C_MUTED)

func _v25_draw_cashout_summary() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.005, 0.008, 0.02, 0.88))
	panel(Rect2(92, 278, 536, 690), Color("09101f"), C_GOLD)
	draw_string(v16_title_font, Vector2(118, 358), "RUN SECURED", HORIZONTAL_ALIGNMENT_CENTER, 484, 38, V16_GOLD_HI)
	draw_string(font, Vector2(118, 414), "The tower paid out. Your build is recorded below.", HORIZONTAL_ALIGNMENT_CENTER, 484, 15, C_MUTED)
	panel(Rect2(132, 470, 456, 286), Color("07111f"), C_PURPLE)
	draw_string(v16_title_font, Vector2(150, 530), "%d COINS SECURED" % summary_secured, HORIZONTAL_ALIGNMENT_CENTER, 420, 28, C_GOLD)
	draw_string(font, Vector2(150, 584), "FLOORS  %d → %d" % [run_start_floor, run_peak_floor], HORIZONTAL_ALIGNMENT_CENTER, 420, 17, C_TEXT)
	draw_string(font, Vector2(150, 626), "KILLS  %d    ELITES  %d    BOSSES  %d" % [run_kills, run_elite_kills, run_boss_kills], HORIZONTAL_ALIGNMENT_CENTER, 420, 16, C_TEXT)
	draw_string(font, Vector2(150, 668), "BEST COMBO  x%d" % combo_best, HORIZONTAL_ALIGNMENT_CENTER, 420, 18, C_GOLD)
	draw_string(font, Vector2(150, 710), "MODIFIER  %s" % run_modifier, HORIZONTAL_ALIGNMENT_CENTER, 420, 14, C_PURPLE)
	_v16_button(SUMMARY_CONTINUE, "BACK TO TOWER", V16_GOLD, 20)

# -----------------------------------------------------------------------------
# Runtime HUD additions
# -----------------------------------------------------------------------------

func draw_game() -> void:
	super.draw_game()
	if run_modifier != "NONE":
		panel(Rect2(42, 270, 248, 42), Color(0.03, 0.04, 0.09, 0.92), C_PURPLE)
		draw_string(font, Vector2(52, 297), run_modifier, HORIZONTAL_ALIGNMENT_CENTER, 228, 13, C_PURPLE_HI)
	if combo_count >= 2 and combo_timer > 0.0:
		var accent := C_GOLD if combo_count >= 5 else C_CYAN
		panel(Rect2(500, 270, 170, 48), Color(0.03, 0.04, 0.09, 0.94), accent)
		draw_string(v16_title_font, Vector2(510, 302), "x%d COMBO" % combo_count, HORIZONTAL_ALIGNMENT_CENTER, 150, 17, accent)
	for e in enemies:
		var affix := String(e.get("affix", ""))
		if affix == "":
			continue
		var p: Vector2 = e.get("pos", Vector2.ZERO)
		var r := Rect2(p.x - 55.0, p.y - float(e.get("radius", 24.0)) - 42.0, 110.0, 20.0)
		draw_string(font, Vector2(r.position.x, r.position.y + 15.0), affix, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, 12, _v25_affix_color(affix))
