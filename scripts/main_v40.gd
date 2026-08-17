extends "res://scripts/main_v39.gd"

# v1.27 visual art-direction pass.
# The approved screenshots/references are used as composition targets only. This
# layer upgrades the live Godot renderer with existing authored production art,
# removes the oversized Forge icon treatment, makes the Wanderer a real focal
# point on Hero, and keeps every button/value/hitbox dynamic.

const V40_VERSION := "1.26.0-art-direction-pass"
const V40_BUILD := "21"
const V40_HIFI_BACKDROP := "res://assets/art/hifi_menu_backdrop.svg"
const V40_CITADEL_ART := "res://assets/art/premium_menu_citadel.svg"
const V40_WANDERER_ART := "res://assets/art/wanderer.svg"

var tex_v40_hifi: Texture2D
var tex_v40_citadel: Texture2D
var tex_v40_wanderer: Texture2D

func _ready() -> void:
	super._ready()
	tex_v40_hifi = load(V40_HIFI_BACKDROP) as Texture2D
	tex_v40_citadel = load(V40_CITADEL_ART) as Texture2D
	tex_v40_wanderer = load(V40_WANDERER_ART) as Texture2D
	if telemetry != null:
		telemetry.set_build_context(V40_VERSION, V40_BUILD)
		telemetry.event("visual_art_direction_pass_ready", {
			"home_art": tex_v40_citadel != null,
			"hero_art": tex_v40_wanderer != null,
			"build": V40_BUILD
		})
	queue_redraw()

# -----------------------------------------------------------------------------
# HOME — layered authored environment instead of one flat castle illustration.
# -----------------------------------------------------------------------------

func _v16_backdrop(kind: String = "arcane", dim: float = 0.0) -> void:
	if kind != "home" or tex_v40_hifi == null or tex_v40_citadel == null:
		super._v16_backdrop(kind, dim)
		return

	# Cinematic distant environment.
	draw_texture_rect(tex_v40_hifi, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)

	var p := _v38_primary()
	var s := _v38_secondary()
	if visual_pack != null:
		# The pack halo sits behind the keep, giving the castle actual depth.
		_v38_draw_pack_halo(Vector2(360, 505), 278.0, p, s)

	# The more detailed production citadel is layered over the distant landscape.
	# Its own mountain silhouettes, masonry, warm windows and braziers create a
	# stronger midground than the previous single full-screen SVG.
	draw_texture_rect(tex_v40_citadel, Rect2(0, 300, 720, 640), false, Color.WHITE)
	_v40_home_lighting(p, s)

	if visual_pack != null:
		_v37_corner_runes(p, s)
	if dim > 0.0:
		draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0, 0, 0, dim))

func _v40_home_lighting(primary: Color, secondary: Color) -> void:
	# Window spill / gate depth — low alpha on purpose so text remains pristine.
	draw_colored_polygon(PackedVector2Array([
		Vector2(286, 575), Vector2(322, 575), Vector2(278, 925), Vector2(196, 925)
	]), Color(V16_GOLD, 0.022))
	draw_colored_polygon(PackedVector2Array([
		Vector2(398, 575), Vector2(434, 575), Vector2(524, 925), Vector2(442, 925)
	]), Color(V16_GOLD, 0.022))
	_v15_soft_glow(Vector2(360, 374), 86, primary, 0.44)
	_v15_soft_glow(Vector2(360, 772), 74, primary, 0.22)

	# Slow dust motes make the environment read as a place rather than a poster.
	for i in range(16):
		var phase := elapsed * (5.0 + float(i % 4)) + float(i * 41)
		var x := 88.0 + fmod(float(i * 97), 544.0) + sin(phase * 0.021) * 11.0
		var y := 360.0 + fmod(float(i * 73) - elapsed * (5.0 + float(i % 3)), 520.0)
		if y < 360.0:
			y += 520.0
		var a := 0.10 + 0.08 * (0.5 + 0.5 * sin(phase * 0.13))
		draw_circle(Vector2(x, y), 1.2 + float(i % 2) * 0.6, Color(secondary, a))

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
	_v16_frame(Rect2(18, 18, 190, 100), V16_PURPLE, Color("050812"), 0.12)
	_v16_center_in(Rect2(30, 32, 166, 28), "BEST FLOOR", 13, V16_MUTED, true)
	_v16_center_in(Rect2(30, 57, 166, 49), str(int(meta.best_floor)), 35, V17_IVORY, true)
	_v16_currency(int(meta.coins), Rect2(512, 18, 190, 92))

	# Title stays the brand anchor while the upgraded castle now carries the art.
	draw_string(v16_title_font, Vector2(48, 159), "ONE MORE", HORIZONTAL_ALIGNMENT_CENTER, 624, 44, V17_IVORY)
	for off in [Vector2(0, 5), Vector2(2, 3), Vector2(-2, 3)]:
		draw_string(v16_title_font, Vector2(46, 236) + off, "FLOOR", HORIZONTAL_ALIGNMENT_CENTER, 628, 75, Color(0, 0, 0, 0.78))
	draw_string(v16_title_font, Vector2(46, 233), "FLOOR", HORIZONTAL_ALIGNMENT_CENTER, 628, 75, Color("fff0a6"))
	_v16_rule(255, V16_PURPLE, 390)
	_v16_center("CLIMB  •  LOOT  •  RISK IT ALL", 289, 14, V16_MUTED)

	# Authored Wanderer texture replaces the tiny simplified runtime figure here.
	_v40_draw_wanderer_texture(Rect2(318, 676, 84, 126), 0.96)

	_v16_button(PLAY, "PLAY", V16_GOLD, 39)
	_v40_activity_button(MISSIONS_BTN, "MISSIONS", V16_GREEN, 0)
	_v40_activity_button(PASS_BTN, "TOWER PASS", V16_PURPLE, 6)
	_v40_home_tab(HERO_TAB, "HERO", 8, V16_BLUE)
	_v40_home_tab(FORGE_TAB, "FORGE", 7, V16_ORANGE)
	_v40_home_tab(TALENTS_TAB, "TALENTS", 1, V16_PURPLE)
	_v40_home_tab(VAULT_TAB, "VAULT", 10, V16_GOLD)

	_v16_frame(Rect2(20, 1156, 680, 76), Color("323a5c"), Color("030611"), 0.05)
	_v16_text("POWER", Vector2(42, 1194), 13, V16_MUTED, true)
	_v16_text(str(int(meta.power_score())), Vector2(106, 1197), 23, V17_GOLD_HI, true)
	draw_string(v16_body_font, Vector2(222, 1195), "KAMILUNAVO GAMES", HORIZONTAL_ALIGNMENT_CENTER, 225, 10, Color(V16_MUTED, 0.72))
	_v36_utility_button(V36_STORE_HOME, "STORE", V16_GOLD, 11)
	_v36_utility_button(V36_SETTINGS_HOME, "SETTINGS", V16_BLUE, 9)

	if recovery_notice_time > 0.0:
		_v16_frame(Rect2(184, 304, 352, 42), V16_GOLD, Color("07101d"), 0.08)
		_v16_center("PREVIOUS SESSION RECOVERED", 331, 11, V16_GOLD_HI)
	if v39_cashout_notice_time > 0.0:
		var accent := _v38_primary()
		_v16_frame(Rect2(184, 306, 352, 48), accent, Color("06101a"), 0.10)
		_v16_center(v39_cashout_notice, 337, 12, V17_IVORY)
	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step in [0, 1]:
		_draw_tutorial_overlay()

func _v40_draw_wanderer_texture(r: Rect2, alpha: float = 1.0) -> void:
	if tex_v40_wanderer == null:
		draw_wanderer(r.get_center() + Vector2(0, r.size.y * 0.18), r.size.y / 82.0, false)
		return
	var shadow_center := Vector2(r.get_center().x, r.end.y - 6.0)
	draw_ellipse_safe(shadow_center, Vector2(r.size.x * 0.42, 9.0), Color(0, 0, 0, 0.58 * alpha))
	_v15_soft_glow(r.get_center(), r.size.x * 0.74, _v38_primary(), 0.28 * alpha)
	draw_texture_rect(tex_v40_wanderer, r, false, Color(1, 1, 1, alpha))

# Godot has no direct draw_ellipse primitive; approximate one with a polygon.
func draw_ellipse_safe(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(32):
		var a := TAU * float(i) / 32.0
		points.append(center + Vector2(cos(a) * radii.x, sin(a) * radii.y))
	draw_colored_polygon(points, color)

func _v40_activity_button(r: Rect2, label: String, accent: Color, icon_index: int) -> void:
	# Quiet activity cards, but with enough bevel/material depth to match the new art.
	draw_rect(Rect2(r.position + Vector2(4, 6), r.size), Color(0, 0, 0, 0.52))
	draw_rect(r, Color("050a13"))
	draw_rect(r.grow(-2), Color(accent, 0.095))
	draw_line(Vector2(r.position.x + 8, r.position.y + 2), Vector2(r.end.x - 8, r.position.y + 2), Color(accent, 0.90), 2.0)
	draw_line(Vector2(r.position.x + 16, r.end.y - 3), Vector2(r.end.x - 16, r.end.y - 3), Color(0, 0, 0, 0.58), 2.0)
	_v16_medallion(Vector2(r.position.x + 34, r.get_center().y), 18, accent, icon_index)
	draw_string(v16_title_font, Vector2(r.position.x + 62, r.get_center().y + 6), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 76, 16, V17_IVORY)

func _v40_home_tab(r: Rect2, label: String, icon_index: int, accent: Color) -> void:
	draw_rect(Rect2(r.position + Vector2(3, 6), r.size), Color(0, 0, 0, 0.58))
	draw_rect(r, Color("040811"))
	draw_rect(r.grow(-2), Color(accent, 0.035))
	draw_rect(r, Color("3b435b"), false, 1.4)
	draw_line(Vector2(r.position.x + 8, r.position.y + 2), Vector2(r.end.x - 8, r.position.y + 2), Color(accent, 0.88), 2.0)
	_v16_medallion(Vector2(r.get_center().x, r.position.y + 35), 20, accent, icon_index)
	draw_string(v16_title_font, Vector2(r.position.x + 5, r.end.y - 18), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 10, 14, V17_IVORY)

# -----------------------------------------------------------------------------
# HERO — the character is now the focal point, not a tiny figure inside a portal.
# -----------------------------------------------------------------------------

func draw_hero_screen() -> void:
	_v16_header("HERO", "Permanent Wanderer training", V16_GREEN, 0, "arcane")
	var p := _v38_primary()
	var s := _v38_secondary()
	var stage_center := Vector2(360, 452)

	# Temple alcove / light crown behind the authored character.
	_v15_soft_glow(stage_center, 205, p, 0.62)
	for rr in [174.0, 145.0, 116.0]:
		draw_arc(stage_center, rr, elapsed * 0.035, elapsed * 0.035 + TAU, 96, Color(p, 0.17), 1.6)
	for x in [118.0, 602.0]:
		draw_rect(Rect2(x - 28, 270, 56, 338), Color("080b16"))
		draw_rect(Rect2(x - 28, 270, 56, 338), Color(s, 0.16), false, 2.0)
		draw_colored_polygon(PackedVector2Array([
			Vector2(x, 332), Vector2(x + 13, 350), Vector2(x, 368), Vector2(x - 13, 350)
		]), Color(p, 0.52))

	draw_ellipse_safe(Vector2(360, 636), Vector2(148, 25), Color(0, 0, 0, 0.62))
	_v40_draw_wanderer_texture(Rect2(242, 248, 236, 354), 1.0)

	var card := Rect2(54, 660, 612, 306)
	_v16_frame(card, V16_PURPLE, Color("06101d"), 0.20)
	_v16_center("WANDERER  •  LEVEL %d" % int(meta.hero_level), 713, 31, V17_GOLD_HI, true)
	_v19_stat_row(Rect2(112, 754, 496, 50), 0, "Base HP bonus", "+%d" % int(meta.hp_bonus()), V16_GREEN)
	_v19_stat_row(Rect2(112, 827, 496, 50), 6, "Combined damage", "x%.2f" % meta.damage_multiplier(), V16_ORANGE)
	_v19_stat_row(Rect2(112, 900, 496, 50), 8, "Power", str(int(meta.power_score())), V16_PURPLE_HI)
	_v16_button(V19_HERO_BUY, "TRAIN  %d" % int(meta.hero_cost()), V16_PURPLE, 25, -1, meta.coins >= meta.hero_cost())
	_v16_center("Each Hero level: +5 HP and +3.5% damage", 1125, 15, V16_MUTED)

# -----------------------------------------------------------------------------
# FORGE — reveal the authored anvil/hammer scene instead of covering it with an
# oversized blurred medallion. Live sparks/heat provide the motion layer.
# -----------------------------------------------------------------------------

func draw_forge_screen() -> void:
	_v16_header("FORGE", "Temper the Wanderer's weapon", V16_ORANGE, 7, "forge")
	_v40_draw_forge_heat()

	var card := Rect2(78, 690, 564, 250)
	_v16_frame(card, V16_ORANGE, Color("100a09"), 0.24)
	_v16_center("FORGE LEVEL %d" % int(meta.forge_level), 748, 31, V17_IVORY, true)
	_v16_center("Weapon multiplier contribution", 805, 17, V16_MUTED)
	_v16_center("+%.1f%% DAMAGE" % (float(meta.forge_level) * 8.5), 877, 36, V17_GOLD_HI, true)
	_v16_button(V19_FORGE_BUY, "TEMPER  %d" % int(meta.forge_cost()), V16_ORANGE, 24, 11, meta.coins >= meta.forge_cost())
	_v16_center("Every Forge level adds +8.5% permanent damage.", 1100, 15, V16_MUTED)

func _v40_draw_forge_heat() -> void:
	var center := Vector2(360, 505)
	_v15_soft_glow(center, 170, V16_ORANGE, 0.34)
	# Hot blade reflection across the authored anvil.
	draw_line(Vector2(294, 503), Vector2(426, 484), Color(V16_ORANGE, 0.26), 8.0)
	draw_line(Vector2(298, 501), Vector2(424, 483), Color("ffd87a", 0.58), 2.0)
	for i in range(18):
		var base_x := 220.0 + fmod(float(i * 67), 280.0)
		var rise := fmod(elapsed * (34.0 + float(i % 5) * 7.0) + float(i * 43), 210.0)
		var x := base_x + sin(elapsed * 1.3 + float(i)) * 10.0
		var y := 646.0 - rise
		var alpha := 0.10 + 0.22 * (1.0 - rise / 210.0)
		draw_circle(Vector2(x, y), 1.3 + float(i % 3) * 0.55, Color(V16_ORANGE, alpha))
	# A restrained heat ring reads better than the old giant circular icon.
	draw_arc(center, 150.0, 0.08, PI - 0.08, 64, Color(V16_ORANGE, 0.22), 2.0)
	draw_arc(center, 162.0, PI + 0.16, TAU - 0.16, 64, Color(_v38_primary(), 0.13), 1.4)

func _v40_visual_art_pass_ready() -> bool:
	return tex_v40_hifi != null and tex_v40_citadel != null and tex_v40_wanderer != null
