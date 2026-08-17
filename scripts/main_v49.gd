extends "res://scripts/main_v48.gd"

# ONE MORE FLOOR v1.36 — Run Progression Presentation.
# Finishes the between-floor loop: upgrade choices, room events and reward/loot
# presentation now use the same authored visual language as the combat and realm
# art. Existing hit rectangles, progression math, event outcomes, save data and
# economy remain untouched.

const V49_VERSION := "1.36.0-run-progression-polish"
const V49_BUILD := "22-dev"
const V49_REWARD_ATLAS := "res://assets/art/progression_rewards_v49.svg"
const V49_REWARD_CELL := 256.0

var v49_reward_atlas: Texture2D
var v49_floor_start_coins := 0
var v49_upgrade_screens := 0
var v49_event_screens := 0

func _ready() -> void:
	super._ready()
	v49_reward_atlas = load(V49_REWARD_ATLAS) as Texture2D
	if telemetry != null:
		telemetry.set_build_context(V49_VERSION, V49_BUILD)
		telemetry.event("run_progression_presentation_ready", {
			"build": V49_BUILD,
			"reward_atlas": v49_reward_atlas != null,
		})
	queue_redraw()

func spawn_floor() -> void:
	super.spawn_floor()
	if run != null:
		v49_floor_start_coins = int(run.run_coins)

# -----------------------------------------------------------------------------
# Upgrade reward screen.
# The original upgrade_rect(i) geometry remains the interaction map, so this is
# strictly a presentation replacement over the existing run-upgrade system.
# -----------------------------------------------------------------------------

func draw_upgrade() -> void:
	if room_event_active:
		_v49_draw_room_event()
		return
	v49_upgrade_screens += 1
	_v12_background(_v49_screen_accent())
	_v49_draw_upgrade_header()
	for i in range(upgrade_options.size()):
		_v49_draw_upgrade_card(i, upgrade_options[i])
	_v49_draw_upgrade_footer()

func _v49_draw_upgrade_header() -> void:
	var floor_no := int(run.floor_no) if run != null else 1
	var accent := _v49_screen_accent()
	var panel := Rect2(46, 128, 628, 164)
	_v16_frame(panel, accent, Color("050812"), 0.22)
	_v49_draw_reward_icon(3, Vector2(108, 209), 76.0, 0.0, Color.WHITE)
	_v16_text("FLOOR %d CLEARED" % floor_no, Vector2(158, 186), 28, V17_IVORY, true)
	_v16_text(_v49_floor_identity(floor_no), Vector2(158, 214), 11, accent, true)
	_v16_text("Choose one edge before the next floor opens.", Vector2(158, 241), 11, V16_MUTED)
	var haul := maxi(0, int(run.run_coins) - v49_floor_start_coins) if run != null else 0
	var chip := Rect2(492, 231, 148, 38)
	draw_rect(chip, Color("0b0e18"))
	draw_rect(chip, Color(C_GOLD, 0.46), false, 1.5)
	_v16_text("+%d RUN COINS" % haul, Vector2(508, 256), 10, V17_GOLD_HI, true)

func _v49_draw_upgrade_card(index: int, option: Dictionary) -> void:
	var r := upgrade_rect(index)
	var tier := String(option.get("tier", "COMMON"))
	var tier_color: Color = option.get("tier_color", Color("d9d9e2"))
	var kind := String(option.get("kind", "power"))
	var title := String(option.get("name", "UPGRADE"))
	var desc := String(option.get("desc", "Run upgrade"))
	var card := r.grow(-3.0)
	var fill := Color(tier_color, 0.055 if tier == "COMMON" else 0.085)
	_v16_frame(card, tier_color, fill, 0.18 if tier == "COMMON" else 0.34)

	# Rarity rail and authored crest.
	draw_rect(Rect2(card.position + Vector2(13, 15), Vector2(5, card.size.y - 30)), Color(tier_color, 0.72))
	var icon_center := Vector2(card.position.x + 69.0, card.get_center().y)
	_v49_draw_reward_icon(_v49_upgrade_icon_for_kind(kind), icon_center, minf(92.0, card.size.y - 28.0), sin(elapsed * 0.7 + float(index)) * 0.02, Color.WHITE)
	if tier != "COMMON":
		draw_arc(icon_center, 48.0, elapsed * 0.34 + float(index), elapsed * 0.34 + float(index) + PI * 1.55, 36, Color(tier_color, 0.42), 2.0)

	var tx := card.position.x + 128.0
	var text_w := maxf(190.0, card.size.x - 158.0)
	_v16_text(_v49_upgrade_class(kind), Vector2(tx, card.position.y + 28), 9, Color(tier_color, 0.92), true)
	_v16_text(title.to_upper(), Vector2(tx, card.position.y + 58), 21, V17_IVORY, true)
	_v16_text(desc, Vector2(tx, card.position.y + 88), 12, V16_MUTED)
	var tier_r := Rect2(card.end.x - 126.0, card.position.y + 18.0, 102.0, 30.0)
	draw_rect(tier_r, Color(tier_color, 0.10))
	draw_rect(tier_r, Color(tier_color, 0.54), false, 1.0)
	draw_string(v16_title_font, Vector2(tier_r.position.x + 4, tier_r.position.y + 20), tier, HORIZONTAL_ALIGNMENT_CENTER, tier_r.size.x - 8, 10, tier_color)

	# The lower line communicates permanence without another modal or tooltip.
	var footer_y := card.end.y - 22.0
	draw_line(Vector2(tx, footer_y - 14.0), Vector2(card.end.x - 25.0, footer_y - 14.0), Color(tier_color, 0.14), 1.0)
	_v16_text("RUN UPGRADE", Vector2(tx, footer_y), 9, Color(V16_MUTED, 0.86), true)
	draw_string(v16_body_font, Vector2(card.end.x - 167.0, footer_y), "TAP TO CLAIM", HORIZONTAL_ALIGNMENT_RIGHT, 142.0, 9, Color(tier_color, 0.90))

func _v49_draw_upgrade_footer() -> void:
	var accent := _v49_screen_accent()
	var y := 1082.0
	draw_line(Vector2(92, y - 28.0), Vector2(628, y - 28.0), Color(accent, 0.18), 1.0)
	draw_string(v16_body_font, Vector2(80, y), "Rarity changes the strength of the same upgrade. Choose for the build, not only the color.", HORIZONTAL_ALIGNMENT_CENTER, 560, 10, Color(V16_MUTED, 0.90))

func _v49_upgrade_icon_for_kind(kind: String) -> int:
	if kind in ["power", "multi", "haste", "range", "crit"]:
		return 0
	if kind in ["vitality", "armor", "lifesteal", "speed"]:
		return 1
	return 2

func _v49_upgrade_class(kind: String) -> String:
	if kind in ["power", "multi", "haste", "range", "crit"]:
		return "OFFENSE"
	if kind in ["vitality", "armor", "lifesteal"]:
		return "SURVIVAL"
	if kind == "speed":
		return "MOBILITY"
	return "ARCANA"

# -----------------------------------------------------------------------------
# Room events.
# EVENT_RECTS are preserved exactly from v1.11; only the presentation changes.
# -----------------------------------------------------------------------------

func _v49_draw_room_event() -> void:
	v49_event_screens += 1
	var event_type := String(room_event.get("type", ""))
	var accent := _v49_event_accent(event_type)
	_v12_background(accent)
	var top := Rect2(46, 116, 628, 224)
	_v16_frame(top, accent, Color("050812"), 0.30)
	_v49_draw_reward_icon(_v49_event_icon(event_type), Vector2(360, 178), 104.0, sin(elapsed * 0.55) * 0.025, Color.WHITE)
	_v16_title(String(room_event.get("title", "TOWER EVENT")), 251, 34, V17_IVORY)
	_v16_center(String(room_event.get("subtitle", "")), 282, 12, V16_MUTED)
	var floor_no := int(run.floor_no) if run != null else 1
	_v16_center("FLOOR %d  •  %s" % [floor_no, _v49_floor_identity(floor_no)], 316, 10, Color(accent, 0.92))

	var choices: Array[Dictionary] = _v23_event_choices()
	for i in range(choices.size()):
		_v49_draw_event_choice(i, choices[i], event_type)

	var currency := int(run.run_coins) if run != null else 0
	var footer := Rect2(90, 988, 540, 82)
	_v16_frame(footer, accent, Color("050812"), 0.10)
	_v16_text("RUN COINS  %d" % currency, Vector2(116, 1024), 12, V17_GOLD_HI, true)
	draw_string(v16_body_font, Vector2(288, 1024), "Event choices affect this run only.", HORIZONTAL_ALIGNMENT_RIGHT, 316, 10, V16_MUTED)
	_v16_center("There is no hidden fourth option. Pick a price you can live with.", 1053, 9, Color(V16_MUTED, 0.78))

func _v49_draw_event_choice(index: int, choice: Dictionary, event_type: String) -> void:
	var r: Rect2 = EVENT_RECTS[index]
	var accent: Color = choice.get("accent", C_GOLD)
	var affordable := _v49_event_choice_affordable(index, event_type)
	var frame_accent := accent if affordable else Color("555b68")
	_v16_frame(r, frame_accent, Color(frame_accent, 0.055), 0.20 if affordable else 0.06)
	var icon := _v49_event_choice_icon(index, event_type)
	_v49_draw_reward_icon(icon, Vector2(r.position.x + 70, r.get_center().y), 82.0, 0.0, Color.WHITE if affordable else Color(0.55,0.55,0.60,0.72))
	var tx := r.position.x + 132.0
	_v16_text(_v49_event_choice_tag(index, event_type), Vector2(tx, r.position.y + 29), 9, Color(frame_accent, 0.92), true)
	_v16_text(String(choice.get("title", "CHOICE")), Vector2(tx, r.position.y + 61), 20, V17_IVORY if affordable else Color("8b8e98"), true)
	_v16_text(String(choice.get("desc", "")), Vector2(tx, r.position.y + 94), 11, V16_MUTED)
	draw_string(v16_body_font, Vector2(r.end.x - 150, r.end.y - 18), "TAP TO CHOOSE" if affordable else "NOT ENOUGH COINS", HORIZONTAL_ALIGNMENT_RIGHT, 126, 9, Color(frame_accent, 0.88))

func _v49_event_choice_affordable(index: int, event_type: String) -> bool:
	if event_type != "lost_merchant" or index >= 2 or run == null:
		return true
	var cost := 55 + int(run.floor_no) * 5
	return int(run.run_coins) >= cost

func _v49_event_choice_tag(index: int, event_type: String) -> String:
	match event_type:
		"blood_altar": return ["SACRIFICE", "OFFERING", "REFUSE"][clampi(index,0,2)]
		"arcane_shrine": return ["RESTORE", "ARCANA", "MOBILITY"][clampi(index,0,2)]
		_: return ["WEAPON", "DEFENSE", "DECLINE"][clampi(index,0,2)]

func _v49_event_choice_icon(index: int, event_type: String) -> int:
	if event_type == "blood_altar":
		return [0, 2, 1][clampi(index,0,2)]
	if event_type == "arcane_shrine":
		return [1, 2, 0][clampi(index,0,2)]
	return [0, 1, 3][clampi(index,0,2)]

func _v49_event_icon(event_type: String) -> int:
	match event_type:
		"blood_altar": return 0
		"arcane_shrine": return 2
		_: return 3

func _v49_event_accent(event_type: String) -> Color:
	match event_type:
		"blood_altar": return Color("d75855")
		"arcane_shrine": return Color("a875ef")
		_: return Color("ddb05a")

# -----------------------------------------------------------------------------
# Pick-up/readability polish.
# Existing authored coin art remains intact; this only adds restrained value and
# motion cues around the pickup so rewards read immediately during dense fights.
# -----------------------------------------------------------------------------

func draw_coin_orb(orb: Dictionary) -> void:
	super.draw_coin_orb(orb)
	var p: Vector2 = orb.get("pos", Vector2.ZERO)
	var age := float(orb.get("age", 0.0))
	var value := maxi(1, int(orb.get("value", 1)))
	var pulse := 0.5 + 0.5 * sin(age * 8.0)
	if value >= 3:
		draw_arc(p, 18.0 + 3.0 * pulse, elapsed * 0.65, elapsed * 0.65 + PI * 1.45, 24, Color(C_GOLD, 0.26 + 0.16 * pulse), 2.0)
	for n in range(2):
		var a := age * (3.2 + float(n)) + PI * float(n)
		draw_circle(p + Vector2.from_angle(a) * (13.0 + 4.0 * float(n)), 1.6 + 0.5 * pulse, Color(V17_GOLD_HI, 0.24))

# -----------------------------------------------------------------------------
# Shared art helpers.
# -----------------------------------------------------------------------------

func _v49_draw_reward_icon(cell: int, center: Vector2, size: float, rotation: float = 0.0, modulate: Color = Color.WHITE) -> void:
	if v49_reward_atlas == null:
		return
	var safe_cell := clampi(cell, 0, 3)
	var src := Rect2(float(safe_cell) * V49_REWARD_CELL, 0.0, V49_REWARD_CELL, V49_REWARD_CELL)
	draw_set_transform(center, rotation, Vector2.ONE)
	draw_texture_rect_region(v49_reward_atlas, Rect2(Vector2(-size * 0.5, -size * 0.5), Vector2(size, size)), src, modulate)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _v49_screen_accent() -> Color:
	if run == null:
		return V16_PURPLE
	var floor_no := int(run.floor_no)
	if floor_no <= 50:
		return _v48_zone_accent(_v48_zone_for_floor(floor_no))
	return _v28_realm_accent(String(current_room.get("area", "VOID CITADEL")))

func _v49_floor_identity(floor_no: int) -> String:
	if floor_no <= 50:
		var zone := _v48_zone_for_floor(floor_no)
		return "%s  •  %s" % [V48_ZONES[zone], _v48_chamber_for_floor(floor_no)]
	var area := String(current_room.get("area", "DEEP TOWER"))
	var chamber := String(current_room.get("chamber", ""))
	return area if chamber.is_empty() else "%s  •  %s" % [area, chamber]

func _v49_run_progression_ready() -> bool:
	return v49_reward_atlas is Texture2D and _v49_upgrade_icon_for_kind("power") == 0 and _v49_upgrade_icon_for_kind("armor") == 1 and _v49_upgrade_icon_for_kind("nova") == 2 and _v49_event_icon("lost_merchant") == 3 and _v48_foundation_environments_ready()
