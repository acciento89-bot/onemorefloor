extends "res://scripts/main_v13.gd"

const V14_VERSION := "1.3.0-rc1"
const V14_ENV_PATH := "res://assets/art/hifi_environment.svg"
const V14_VFX_PATH := "res://assets/art/hifi_vfx.svg"
const V14_UI_PATH := "res://assets/art/hifi_ui.svg"
const V14_MENU_PATH := "res://assets/art/hifi_menu_backdrop.svg"

var tex_v14_environment: Texture2D
var tex_v14_vfx: Texture2D
var tex_v14_ui: Texture2D
var tex_v14_menu: Texture2D

func _ready() -> void:
	super._ready()
	tex_v14_environment = load(V14_ENV_PATH) as Texture2D
	tex_v14_vfx = load(V14_VFX_PATH) as Texture2D
	tex_v14_ui = load(V14_UI_PATH) as Texture2D
	tex_v14_menu = load(V14_MENU_PATH) as Texture2D
	queue_redraw()

# -----------------------------------------------------------------------------
# High-fidelity shared UI skin
# -----------------------------------------------------------------------------

func _v14_ui_cell(index: int, r: Rect2, modulate: Color = Color.WHITE) -> void:
	if tex_v14_ui == null:
		return
	var col: int = index % 4
	var row: int = index / 4
	var source := Rect2(float(col * 128), float(row * 128), 128.0, 128.0)
	draw_texture_rect_region(tex_v14_ui, r, source, modulate)

func _v14_vfx(index: int, r: Rect2, modulate: Color = Color.WHITE) -> void:
	if tex_v14_vfx == null:
		return
	var col: int = index % 4
	var row: int = index / 4
	var source := Rect2(float(col * 128), float(row * 128), 128.0, 128.0)
	draw_texture_rect_region(tex_v14_vfx, r, source, modulate)

func panel(r: Rect2, fill: Color, border: Color) -> void:
	# Deep stacked shadow and a soft accent underglow make cards feel like
	# physical fantasy UI plates instead of flat debug rectangles.
	draw_rect(r.grow(8.0) + Rect2(Vector2(0, 5), Vector2.ZERO), Color(0.0, 0.0, 0.0, 0.34))
	draw_rect(r.grow(4.0), Color(border, 0.055))
	draw_rect(r, fill)
	draw_rect(r.grow(-3.0), Color(border, 0.055))
	draw_rect(r, Color(border, 0.92), false, 2.0)
	draw_rect(r.grow(-5.0), Color(border, 0.22), false, 1.0)
	draw_line(r.position + Vector2(12, 6), Vector2(r.end.x - 12, r.position.y + 6), Color(1, 1, 1, 0.08), 1.0)
	draw_line(Vector2(r.position.x + 12, r.end.y - 7), r.end - Vector2(12, 7), Color(0, 0, 0, 0.48), 2.0)
	if tex_v14_ui != null and r.size.x >= 90.0 and r.size.y >= 44.0:
		var s: float = clampf(minf(r.size.x, r.size.y) * 0.32, 18.0, 30.0)
		_v14_ui_cell(0, Rect2(r.position.x - 3, r.position.y - 3, s, s), Color(border, 0.88))
		_v14_ui_cell(1, Rect2(r.end.x - s + 3, r.position.y - 3, s, s), Color(border, 0.88))
		_v14_ui_cell(2, Rect2(r.position.x - 3, r.end.y - s + 3, s, s), Color(border, 0.72))
		_v14_ui_cell(3, Rect2(r.end.x - s + 3, r.end.y - s + 3, s, s), Color(border, 0.72))

func button(r: Rect2, label: String, accent: Color, size: int) -> void:
	var active: bool = accent != C_MUTED
	var fill := Color(0.055, 0.075, 0.12, 0.97)
	if active:
		fill = Color(accent, 0.115)
	panel(r, fill, accent)
	draw_rect(r.grow(-8.0), Color(accent, 0.035))
	draw_line(r.position + Vector2(14, 10), Vector2(r.end.x - 14, r.position.y + 10), Color(accent, 0.18), 1.0)
	center_rect(label, r + Rect2(Vector2(0, 1), Vector2.ZERO), size, V12_IVORY if active else C_MUTED)

func _v12_coin_badge(r: Rect2, amount: int) -> void:
	panel(r, Color("080e19"), V12_GOLD)
	if tex_v14_vfx != null:
		_v14_vfx(7, Rect2(r.position.x + 4, r.position.y + 3, 48, 48))
	else:
		_v12_icon(11, Rect2(r.position.x + 7, r.position.y + 6, 42, 42))
	text(str(amount), Vector2(r.position.x + 54, r.position.y + 37), 20, V12_GOLD_LIGHT)

func _v12_background(accent: Color = V12_PURPLE) -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("03060d"))
	if tex_v14_menu != null:
		draw_texture_rect(tex_v14_menu, Rect2(Vector2.ZERO, SIZE), false, Color(0.58, 0.62, 0.78, 0.42))
	for i: int in range(7):
		var radius: float = 315.0 - float(i) * 37.0
		draw_circle(Vector2(360, 350), radius, Color(accent, 0.009 + float(i) * 0.0035))
	for y: int in range(118, 1140, 72):
		draw_rect(Rect2(0, y, 25, 61), Color("111725"))
		draw_rect(Rect2(695, y, 25, 61), Color("111725"))
		draw_line(Vector2(25, y + 4), Vector2(38, y + 10), Color(accent, 0.08), 1.0)
		draw_line(Vector2(695, y + 4), Vector2(682, y + 10), Color(accent, 0.08), 1.0)

func _v12_home_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("03060d"))
	if tex_v14_menu != null:
		draw_texture_rect(tex_v14_menu, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)
	else:
		super._v12_home_background()
	# Fine animated motes are separate from the static backdrop so the home
	# screen never feels like a single painted image.
	for i: int in range(24):
		var x: float = 24.0 + fmod(float(i * 139), 672.0)
		var y: float = 105.0 + fmod(float(i * i * 51), 590.0)
		var pulse: float = 0.07 + 0.055 * (sin(elapsed * 1.25 + float(i) * 0.7) + 1.0)
		draw_circle(Vector2(x, y), 0.9 + float(i % 3) * 0.45, Color(0.74, 0.72, 1.0, pulse))

func _v12_home_tower(c: Vector2) -> void:
	# Layered keep with buttresses, recessed windows and a glowing crown.
	draw_circle(c + Vector2(0, -52), 174, Color(V12_PURPLE, 0.025))
	draw_ellipse_shadow(c + Vector2(0, 83), 142, 20)
	for side_value: float in [-1.0, 1.0]:
		var x: float = c.x + side_value * 104.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 35, c.y + 82), Vector2(x - 31, c.y - 90),
			Vector2(x + 31, c.y - 90), Vector2(x + 35, c.y + 82)
		]), Color("11192a"))
		draw_rect(Rect2(x - 39, c.y - 103, 78, 19), Color("34384c"))
		draw_colored_polygon(PackedVector2Array([Vector2(x-39,c.y-103),Vector2(x,c.y-151),Vector2(x+39,c.y-103)]), Color("20263a"))
		draw_line(Vector2(x - 24, c.y - 80), Vector2(x - 20, c.y + 64), Color(0.65,0.72,0.84,0.09), 3.0)
		draw_circle(Vector2(x, c.y - 48), 19, Color(0.94,0.58,0.17,0.055))
		draw_rect(Rect2(x - 6, c.y - 57, 12, 25), Color("d28a32"))
		draw_rect(Rect2(x - 3, c.y - 53, 6, 18), Color("ffe08b"))
	# central keep
	draw_colored_polygon(PackedVector2Array([
		Vector2(c.x - 79, c.y + 92), Vector2(c.x - 74, c.y - 181),
		Vector2(c.x + 74, c.y - 181), Vector2(c.x + 79, c.y + 92)
	]), Color("10182a"))
	draw_rect(Rect2(c.x - 86, c.y - 196, 172, 22), Color("383a50"))
	draw_colored_polygon(PackedVector2Array([Vector2(c.x-86,c.y-195),Vector2(c.x,c.y-284),Vector2(c.x+86,c.y-195)]), Color("222943"))
	draw_line(Vector2(c.x - 55, c.y - 166), Vector2(c.x - 49, c.y + 71), Color(0.7,0.75,0.9,0.08), 4.0)
	for row: int in range(3):
		for col: int in range(2):
			var wx: float = c.x - 31.0 + float(col) * 62.0
			var wy: float = c.y - 122.0 + float(row) * 61.0
			draw_circle(Vector2(wx, wy), 20, Color(0.95,0.59,0.2,0.035))
			draw_rect(Rect2(wx - 7, wy - 13, 14, 27), Color("c77a27"))
			draw_rect(Rect2(wx - 4, wy - 10, 8, 21), Color("ffe083"))
			draw_line(Vector2(wx, wy - 10), Vector2(wx, wy + 11), Color(0.4,0.2,0.08,0.7), 1.0)
	var crown := Vector2(c.x, c.y - 207)
	draw_circle(crown, 43, Color(V12_PURPLE, 0.065))
	draw_colored_polygon(PackedVector2Array([crown+Vector2(0,-31),crown+Vector2(18,-5),crown+Vector2(9,23),crown+Vector2(0,34),crown+Vector2(-10,23),crown+Vector2(-18,-5)]),Color("8646d6"))
	draw_line(crown+Vector2(0,-29),crown+Vector2(0,30),Color("f2d9ff"),2.0)

# -----------------------------------------------------------------------------
# High-fidelity combat room
# -----------------------------------------------------------------------------

func _v14_room_index(area: String) -> int:
	if area == "CRYPT":
		return 1
	if area == "FORGOTTEN CASTLE":
		return 2
	if area == "DEEP TOWER":
		return 3
	return 0

func _draw_room_floor() -> void:
	if tex_v14_environment == null:
		super._draw_room_floor()
		return
	var area: String = String(current_room.get("area", "DUNGEON"))
	var index: int = _v14_room_index(area)
	var source := Rect2(0.0, float(index * 840), 648.0, 840.0)
	draw_texture_rect_region(tex_v14_environment, ARENA, source, Color.WHITE)

func _draw_room_architecture() -> void:
	var area: String = String(current_room.get("area", "DUNGEON"))
	var accent: Color = _area_accent(area)
	var room_type: String = String(current_room.get("type", "COMBAT"))
	# Animated practical lights over the painted environment.
	var light_points: Array[Vector2] = [Vector2(99, 420), Vector2(621, 420), Vector2(99, 820), Vector2(621, 820)]
	for i: int in range(light_points.size()):
		var lp: Vector2 = light_points[i]
		var pulse: float = 1.0 + sin(elapsed * 4.5 + float(i) * 1.7) * 0.12
		var light_color := accent
		if area == "DUNGEON" or area == "FORGOTTEN CASTLE":
			light_color = V12_GOLD
		draw_circle(lp, 52.0 * pulse, Color(light_color, 0.018))
		draw_circle(lp, 26.0 * pulse, Color(light_color, 0.025))
	# Volumetric shafts from the gate.
	var shaft := Color(accent, 0.025 if area != "CRYPT" else 0.018)
	draw_colored_polygon(PackedVector2Array([Vector2(255, 270),Vector2(300,270),Vector2(245,930),Vector2(125,930)]), shaft)
	draw_colored_polygon(PackedVector2Array([Vector2(340,270),Vector2(390,270),Vector2(565,930),Vector2(430,930)]), Color(shaft, shaft.a * 0.82))
	# Sparse drifting dust/magic motes.
	for i: int in range(14):
		var x: float = ARENA.position.x + 45.0 + fmod(float(i * 117), ARENA.size.x - 90.0)
		var y: float = ARENA.position.y + 120.0 + fmod(float(i * i * 67) + elapsed * (8.0 + float(i % 4) * 2.0), ARENA.size.y - 190.0)
		draw_circle(Vector2(x, y), 1.2 + float(i % 3) * 0.45, Color(accent, 0.10 + 0.04 * sin(elapsed + i)))
	# Room modifier reads clearly without giant prototype rings.
	if room_type == "ELITE":
		draw_arc(ARENA.get_center(), 257.0, elapsed * 0.18, elapsed * 0.18 + TAU, 80, Color(V12_GOLD, 0.19), 3.0)
		draw_arc(ARENA.get_center(), 249.0, -elapsed * 0.11, -elapsed * 0.11 + TAU, 80, Color(V12_PURPLE, 0.08), 2.0)
	elif room_type == "AMBUSH":
		draw_arc(ARENA.get_center(), 260.0, -elapsed * 0.14, -elapsed * 0.14 + TAU, 80, Color(C_RED, 0.11), 2.5)
	elif room_type == "TREASURE":
		draw_circle(Vector2(360, 330), 76.0, Color(V12_GOLD, 0.035))
		_v14_vfx(10, Rect2(320, 288, 80, 80), Color(1, 0.9, 0.66, 0.9))
	# Low fog strips give depth without obscuring combat.
	for i: int in range(3):
		var fog_y: float = 735.0 + float(i) * 75.0 + sin(elapsed * 0.33 + float(i)) * 9.0
		draw_rect(Rect2(58, fog_y, 604, 24), Color(accent, 0.012 + float(i) * 0.004))

func _draw_combat_hud() -> void:
	panel(Rect2(28, 22, 664, 112), Color("050a13"), Color("57647c"))
	text("FLOOR", Vector2(49, 54), 11, C_MUTED)
	text("%02d" % int(run.floor_no), Vector2(48, 102), 40, V12_IVORY)
	var area: String = String(current_room.get("area", "DUNGEON"))
	var accent: Color = _area_accent(area)
	text(area, Vector2(140, 65), 16, accent)
	text(String(current_room.get("type", "COMBAT")), Vector2(140, 94), 13, C_MUTED)
	_v12_coin_badge(Rect2(510, 43, 104, 58), int(run.run_coins))
	panel(V10_PAUSE, Color("0b0f19"), C_MUTED)
	center_rect("Ⅱ", V10_PAUSE, 18, V12_IVORY)
	# HP plate
	var hp_box := Rect2(108, 1013, 438, 37)
	panel(hp_box, Color("160c13"), Color("6f3b35"))
	var ratio: float = clampf(run.hp / run.max_hp, 0.0, 1.0)
	var inner := hp_box.grow(-6.0)
	draw_rect(inner, Color("35121d"))
	draw_rect(Rect2(inner.position, Vector2(inner.size.x * ratio, inner.size.y)), Color("b72d43"))
	draw_rect(Rect2(inner.position + Vector2(0, 1), Vector2(inner.size.x * ratio, 5)), Color(1.0, 0.64, 0.68, 0.38))
	_v14_ui_cell(4, Rect2(hp_box.position.x - 34, hp_box.position.y - 20, 72, 72))
	center_rect("%d / %d HP" % [int(run.hp), int(run.max_hp)], hp_box, 14, V12_IVORY)
	# Joystick
	var base: Vector2 = joy_origin if joy_active else Vector2(145, 1115)
	var knob: Vector2 = joy_pos if joy_active else base
	draw_circle(base, 86, Color(0.015, 0.025, 0.055, 0.90))
	draw_arc(base, 86, 0, TAU, 64, Color(V12_GOLD, 0.58), 3.0)
	draw_arc(base, 74, 0, TAU, 64, Color(V12_PURPLE, 0.30), 2.0)
	for a: float in [0.0, PI * 0.5, PI, PI * 1.5]:
		var rune: Vector2 = base + Vector2.from_angle(a) * 63.0
		draw_circle(rune, 3.5, Color(V12_IVORY, 0.5))
	draw_circle(knob, 37, Color("647087"))
	draw_circle(knob + Vector2(-8, -9), 6, Color(1,1,1,0.08))
	draw_arc(knob, 37, 0, TAU, 48, Color("c6d1e0"), 2.0)
	draw_string(font, Vector2(86, 1215), "MOVE", HORIZONTAL_ALIGNMENT_CENTER, 118, 12, C_MUTED)
	# NOVA button uses the dedicated production crest.
	var skill_center: Vector2 = SKILL.get_center()
	draw_circle(skill_center, 70, Color(0.008, 0.03, 0.07, 0.95))
	draw_arc(skill_center, 70, 0, TAU, 64, V12_GOLD, 3.0)
	draw_arc(skill_center, 62, -PI * 0.5, -PI * 0.5 + TAU * (1.0 if run.skill_cd <= 0.0 else clampf(1.0 - run.skill_cd / 7.0, 0.0, 1.0)), 64, C_CYAN if run.skill_cd <= 0.0 else Color("4b5368"), 5.0)
	if run.skill_cd <= 0.0:
		_v14_ui_cell(7, Rect2(skill_center.x - 50, skill_center.y - 50, 100, 100))
		text("NOVA", Vector2(skill_center.x - 25, skill_center.y + 40), 13, V12_IVORY)
	else:
		_v14_ui_cell(7, Rect2(skill_center.x - 43, skill_center.y - 43, 86, 86), Color(0.38,0.42,0.5,0.55))
		draw_string(font, Vector2(skill_center.x - 42, skill_center.y + 8), "%.1f" % run.skill_cd, HORIZONTAL_ALIGNMENT_CENTER, 84, 21, C_MUTED)
	if floor_banner > 0.0:
		var banner_color := V12_GOLD_LIGHT
		banner_color.a = clampf(floor_banner, 0.0, 1.0)
		draw_string(font, Vector2(80, 610), "FLOOR %d" % int(run.floor_no), HORIZONTAL_ALIGNMENT_CENTER, 560, 48, banner_color)

# -----------------------------------------------------------------------------
# Character presentation and combat VFX
# -----------------------------------------------------------------------------

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	var tex := _v13_actor_texture(0)
	if tex == null:
		super.draw_wanderer(pos, scale, combat)
		return
	var pace: float = 6.4 if combat else 2.1
	var bob: float = sin(elapsed * pace) * (2.8 if combat else 1.5) * scale
	var breath: float = 1.0 + sin(elapsed * 2.3) * 0.014
	var attack_push: float = 8.0 * scale if combat and player_anim_state == "attack" else 0.0
	var hit_offset: float = sin(elapsed * 38.0) * 3.5 * scale if player_anim_state == "hit" else 0.0
	var w: float = (92.0 if combat else 126.0) * scale * breath
	var h: float = (138.0 if combat else 189.0) * scale / breath
	var p := pos + Vector2(attack_push * float(player_facing), bob + hit_offset)
	draw_ellipse_shadow(pos + Vector2(0, 31 * scale), w * 0.43, 12.5 * scale)
	draw_circle(pos + Vector2(0, 8), 49 * scale, Color(V12_PURPLE, 0.035))
	if player_anim_state == "nova":
		_v14_vfx(2, Rect2(pos.x - 78 * scale, pos.y - 78 * scale, 156 * scale, 156 * scale), Color(1,1,1,0.78))
		draw_arc(pos, 72 * scale, elapsed * 2.5, elapsed * 2.5 + TAU, 64, Color(C_CYAN, 0.75), 3.0 * scale)
	elif combat and player_anim_state == "attack":
		var slash_center := pos + Vector2(30.0 * float(player_facing) * scale, -7.0 * scale)
		_v14_vfx(3, Rect2(slash_center.x - 55 * scale, slash_center.y - 55 * scale, 110 * scale, 110 * scale), Color(1,1,1,0.56))
		draw_arc(slash_center, 54 * scale, -1.15, 0.8, 32, Color(V12_GOLD_LIGHT, 0.62), 5.0 * scale)
	var r := Rect2(p.x - w * 0.5, p.y - h * 0.67, w, h)
	draw_texture_rect(tex, r, false, Color.WHITE)
	# cool rim light separates the silhouette from all four dark biomes
	draw_arc(pos + Vector2(0, -6), w * 0.43, -2.75, -0.45, 30, Color(0.55, 0.82, 1.0, 0.22), 2.2 * scale)
	if combat and player_anim_state == "attack":
		_v14_vfx(0, Rect2(pos.x + 20 * float(player_facing) - 13, pos.y - 62, 26, 26), Color(1,1,1,0.8))

func draw_enemy(e: Dictionary) -> void:
	var kind: String = String(e["type"])
	var variant: String = String(e.get("boss_variant", "warden"))
	var idx: int = _v12_actor_index(kind, variant)
	var tex := _v13_actor_texture(idx)
	if tex == null:
		super.draw_enemy(e)
		return
	var p: Vector2 = e["pos"]
	var radius: float = float(e["radius"])
	var phase: float = float(e.get("phase", 0.0))
	var bob: float = sin(elapsed * (8.8 if kind == "bat" else 4.1) + phase) * (5.8 if kind == "bat" else 2.1)
	var breathe: float = 1.0 + sin(elapsed * 3.1 + phase) * 0.018
	var hit: bool = float(e.get("anim_hit", 0.0)) > 0.0
	var jitter: float = sin(elapsed * 45.0) * 3.5 if hit else 0.0
	var width: float = maxf(70.0, radius * 2.72) * breathe
	if kind == "bat":
		width *= 1.12
	if kind == "warden":
		width = radius * 2.95 * breathe
	var height: float = width * 1.5
	var tint := Color(1.0, 0.68, 0.68, 1.0) if hit else Color.WHITE
	var elite: bool = bool(e.get("elite", false))
	if elite:
		_v14_vfx(9, Rect2(p.x - radius - 29, p.y - radius - 29, radius * 2.0 + 58, radius * 2.0 + 58), Color(1,1,1,0.35))
		tint = tint.lerp(V12_GOLD_LIGHT, 0.09)
	if kind == "warden" and bool(e.get("phase2", false)):
		_v14_vfx(12, Rect2(p.x - radius - 33, p.y - radius - 33, radius * 2.0 + 66, radius * 2.0 + 66), Color(1,1,1,0.22))
	draw_ellipse_shadow(p + Vector2(0, radius * 0.86), width * 0.37, 10.0)
	var r := Rect2(p.x - width * 0.5 + jitter, p.y - height * 0.66 + bob, width, height)
	draw_texture_rect(tex, r, false, tint)
	if elite:
		draw_arc(p, radius + 15.0, elapsed * 0.92, elapsed * 0.92 + TAU, 48, V12_GOLD, 2.6)
	if kind == "sentinel":
		draw_arc(p, radius + 10.0, -1.0, 1.0, 28, Color(V12_GOLD_LIGHT,0.55), 4.0)
	if kind == "warden" and bool(e.get("phase2", false)):
		var phase_color: Color = V12_GOLD if variant == "hollow_king" else (C_CYAN if variant == "crypt_keeper" else C_RED)
		draw_arc(p, radius + 20.0, elapsed * 1.35, elapsed * 1.35 + TAU, 56, phase_color, 3.5)
	# compact polished HP bar
	var ratio: float = clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
	var hp := Rect2(p.x - radius - 2, p.y - radius - 22, radius * 2.0 + 4, 10)
	draw_rect(hp, Color("160a10"))
	draw_rect(hp, Color(0.3,0.35,0.48,0.5), false, 1.0)
	var hp_inner := hp.grow(-2.0)
	draw_rect(Rect2(hp_inner.position, Vector2(hp_inner.size.x * ratio, hp_inner.size.y)), Color("d94058"))
	draw_line(hp_inner.position + Vector2(1,1), Vector2(hp_inner.position.x + hp_inner.size.x * ratio - 1, hp_inner.position.y + 1), Color(1,0.68,0.72,0.45), 1.0)

func draw_player_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot["pos"]
	var dir: Vector2 = Vector2(shot["vel"]).normalized()
	var crit: bool = bool(shot["crit"])
	var c: Color = V12_GOLD_LIGHT if crit else C_BLUE
	draw_line(p - dir * 31, p + dir * 5, Color(c, 0.12), 13.0 if crit else 9.0)
	draw_line(p - dir * 27, p + dir * 7, Color(c, 0.62), 5.0 if crit else 3.5)
	_v14_vfx(1 if crit else 0, Rect2(p.x - 11, p.y - 11, 22, 22), Color(1,1,1,0.88))

func draw_enemy_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot["pos"]
	var vel: Vector2 = Vector2(shot["vel"])
	var dir: Vector2 = vel.normalized() if vel.length_squared() > 0.01 else Vector2.RIGHT
	var c: Color = shot["color"]
	var cell: int = 5 if c.b >= c.r else 4
	draw_line(p - dir * 21, p, Color(c,0.22), 7.0)
	_v14_vfx(cell, Rect2(p.x - 13, p.y - 13, 26, 26), Color(1,1,1,0.78))

func draw_coin_orb(orb: Dictionary) -> void:
	var p: Vector2 = orb["pos"]
	var bob: float = sin(elapsed * 5.0 + float(orb.get("age",0.0))*7.0) * 2.0
	_v14_vfx(7, Rect2(p.x - 15, p.y - 15 + bob, 30, 30), Color(1,1,1,0.92))

func draw_effect(fx: Dictionary) -> void:
	super.draw_effect(fx)
	var kind: String = String(fx.get("type", ""))
	var t: float = clampf(float(fx.get("age",0.0)) / maxf(0.01, float(fx.get("dur",1.0))), 0.0, 1.0)
	var p: Vector2 = Vector2(fx.get("pos", Vector2.ZERO))
	var fade: float = 1.0 - t
	if kind == "burst" or kind == "hit":
		var s: float = 38.0 + t * 56.0
		_v14_vfx(1, Rect2(p.x - s*0.5, p.y - s*0.5, s, s), Color(1,1,1,fade*0.55))
	elif kind == "nova":
		var s: float = 90.0 + t * 170.0
		_v14_vfx(2, Rect2(p.x - s*0.5, p.y - s*0.5, s, s), Color(1,1,1,fade*0.38))
	elif kind == "coin":
		_v14_vfx(7, Rect2(p.x - 24, p.y - 24, 48, 48), Color(1,1,1,fade))
	elif kind == "loot_beam":
		var beam_h: float = 115.0 * fade
		draw_rect(Rect2(p.x - 9, p.y - beam_h, 18, beam_h), Color(V12_GOLD_LIGHT, 0.06 * fade))
		_v14_vfx(10, Rect2(p.x - 34, p.y - 72, 68, 68), Color(1,1,1,fade*0.72))
	elif kind == "keeper_cast":
		_v14_vfx(5, Rect2(p.x - 58, p.y - 58, 116, 116), Color(1,1,1,fade*0.5))
	elif kind == "actor_death":
		var s: float = 70.0 + t * 46.0
		_v14_vfx(11, Rect2(p.x - s*0.5, p.y - s*0.5, s, s), Color(1,1,1,fade*0.45))

func _draw_room_badge() -> void:
	var area: String = String(current_room.get("area", "DUNGEON"))
	var r := Rect2(211, 168, 298, 46)
	panel(r, Color("050912"), _area_accent(area))
	center_rect(room_system.room_label(current_room), r, 12, V12_IVORY)
