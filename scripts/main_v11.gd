extends "res://scripts/main_v10.gd"

const V11_VERSION := "1.1.0-rc1"
const V11_CONTENT_SIZE := Vector2(720, 1280)

var v11_layout_offset := Vector2.ZERO
var v11_last_viewport := Vector2.ZERO
var v11_music_context := ""

func _ready() -> void:
	super._ready()
	_refresh_v11_layout(true)
	_sync_music_context(true)

func _process(delta: float) -> void:
	_refresh_v11_layout(false)
	super._process(delta)
	_sync_music_context(false)

func _refresh_v11_layout(force: bool) -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	if not force and viewport_size.is_equal_approx(v11_last_viewport):
		return
	v11_last_viewport = viewport_size
	var centered := Vector2(
		maxf(0.0, (viewport_size.x - V11_CONTENT_SIZE.x) * 0.5),
		maxf(0.0, (viewport_size.y - V11_CONTENT_SIZE.y) * 0.5)
	)
	var safe := _safe_area_in_viewport(viewport_size)
	if viewport_size.x >= V11_CONTENT_SIZE.x and safe.size.x > 0.0:
		var min_x: float = safe.position.x + 6.0
		var max_x: float = safe.end.x - V11_CONTENT_SIZE.x - 6.0
		if max_x >= min_x:
			centered.x = clampf(centered.x, min_x, max_x)
	if viewport_size.y >= V11_CONTENT_SIZE.y and safe.size.y > 0.0:
		var min_y: float = safe.position.y + 6.0
		var max_y: float = safe.end.y - V11_CONTENT_SIZE.y - 6.0
		if max_y >= min_y:
			centered.y = clampf(centered.y, min_y, max_y)
	v11_layout_offset = centered
	position = v11_layout_offset
	queue_redraw()

func _safe_area_in_viewport(viewport_size: Vector2) -> Rect2:
	if not OS.has_feature("ios") and not OS.has_feature("android"):
		return Rect2(Vector2.ZERO, viewport_size)
	var safe_px: Rect2i = DisplayServer.get_display_safe_area()
	var window_px: Vector2 = Vector2(get_window().size)
	if safe_px.size.x <= 0 or safe_px.size.y <= 0 or window_px.x <= 0.0 or window_px.y <= 0.0:
		return Rect2(Vector2.ZERO, viewport_size)
	var sx: float = viewport_size.x / window_px.x
	var sy: float = viewport_size.y / window_px.y
	return Rect2(Vector2(safe_px.position.x * sx, safe_px.position.y * sy), Vector2(safe_px.size.x * sx, safe_px.size.y * sy))

func screen_to_design(pos: Vector2) -> Vector2:
	return pos - v11_layout_offset

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		pointer(screen_to_design(event.position), event.pressed, event.index)
	elif event is InputEventScreenDrag and joy_active and event.index == joy_id:
		move_joy(screen_to_design(event.position))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pointer(screen_to_design(event.position), event.pressed, -99)
	elif event is InputEventMouseMotion and joy_active and joy_id == -99:
		move_joy(screen_to_design(event.position))
	else:
		super._unhandled_input(event)

func _draw() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	_draw_extended_backdrop(viewport_size)
	draw_rect(Rect2(Vector2.ZERO, V11_CONTENT_SIZE), C_BG)
	match state:
		State.HOME: draw_home()
		State.HERO: draw_hero_screen()
		State.FORGE: draw_forge_screen()
		State.TALENTS: draw_talents_screen()
		State.VAULT: draw_vault_screen()
		State.RUNNING: draw_game()
		State.UPGRADE: draw_upgrade()
		State.DECISION: draw_decision()
		State.GAME_OVER: draw_game_over()

func _draw_extended_backdrop(viewport_size: Vector2) -> void:
	var outer := Rect2(-v11_layout_offset, viewport_size)
	draw_rect(outer, Color("02050d"))
	var top_h: float = maxf(0.0, v11_layout_offset.y)
	var bottom_h: float = maxf(0.0, viewport_size.y - v11_layout_offset.y - V11_CONTENT_SIZE.y)
	if top_h > 0.0:
		for i in range(10):
			var alpha: float = 0.16 * (1.0 - float(i) / 10.0)
			draw_rect(Rect2(-v11_layout_offset.x, -v11_layout_offset.y + float(i) * top_h / 10.0, viewport_size.x, top_h / 10.0 + 1.0), Color(0.18, 0.09, 0.34, alpha))
	if bottom_h > 0.0:
		for i in range(10):
			var alpha: float = 0.11 * (float(i + 1) / 10.0)
			draw_rect(Rect2(-v11_layout_offset.x, V11_CONTENT_SIZE.y + float(i) * bottom_h / 10.0, viewport_size.x, bottom_h / 10.0 + 1.0), Color(0.03, 0.15, 0.24, alpha))
	for i in range(16):
		var x: float = fmod(73.0 + float(i) * 149.0, maxf(1.0, viewport_size.x)) - v11_layout_offset.x
		var y: float = fmod(41.0 + float(i * i) * 71.0, maxf(1.0, viewport_size.y)) - v11_layout_offset.y
		draw_circle(Vector2(x, y), 1.5 if i % 3 else 2.2, Color(0.65, 0.72, 1.0, 0.12))

func draw_home() -> void:
	if home_overlay == "missions":
		draw_missions_screen()
		return
	if home_overlay == "pass":
		draw_pass_screen()
		return
	_draw_home_atmosphere()
	_draw_home_stats()
	_draw_home_title()
	_draw_home_tower(Vector2(360, 505))
	_draw_home_wanderer(Vector2(360, 706))
	button(PLAY, "ENTER THE TOWER", C_GOLD, 29)
	_draw_home_action_row()
	_draw_home_meta_tabs()
	if home_overlay == "":
		button(V10_SETTINGS_HOME, "SETTINGS", C_BLUE, 14)
	if recovery_notice_time > 0.0:
		panel(Rect2(138, 718, 404, 38), Color("101629"), C_GOLD)
		center_rect("PREVIOUS SESSION RECOVERED", Rect2(138, 718, 404, 38), 12, C_GOLD)
	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step in [0, 1]:
		_draw_tutorial_overlay()

func _draw_home_atmosphere() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("050b18"))
	for i in range(8):
		var r: float = 310.0 - float(i) * 25.0
		var a: float = 0.018 + float(i) * 0.004
		draw_circle(Vector2(360, 355), r, Color(0.35, 0.16, 0.62, a))
	# moon / portal
	draw_circle(Vector2(360, 366), 174, Color("151539"))
	draw_circle(Vector2(360, 366), 151, Color("101a35"))
	draw_arc(Vector2(360, 366), 168, -2.65, 0.42, 80, Color(0.62, 0.36, 1.0, 0.34), 4.0)
	draw_arc(Vector2(360, 366), 158, 0.5, 2.72, 80, Color(0.27, 0.74, 1.0, 0.16), 2.0)
	for i in range(22):
		var x: float = 32.0 + fmod(float(i * 97), 656.0)
		var y: float = 148.0 + fmod(float(i * i * 31), 430.0)
		var twinkle: float = 0.20 + 0.13 * sin(elapsed * 1.4 + float(i))
		draw_circle(Vector2(x, y), 1.2 + float(i % 3) * 0.5, Color(0.78, 0.83, 1.0, twinkle))
	# distant mountains / tower skyline
	draw_colored_polygon(PackedVector2Array([Vector2(0,650),Vector2(0,540),Vector2(82,484),Vector2(158,552),Vector2(238,472),Vector2(322,548),Vector2(415,455),Vector2(508,536),Vector2(603,468),Vector2(720,552),Vector2(720,650)]), Color("080d1d"))
	for i in range(4):
		var y: float = 586.0 + float(i) * 25.0
		var alpha: float = 0.075 - float(i) * 0.012
		draw_rect(Rect2(0, y, 720, 30), Color(0.38, 0.31, 0.66, alpha))

func _draw_home_stats() -> void:
	panel(Rect2(36, 36, 180, 78), Color(0.05, 0.07, 0.15, 0.92), C_PURPLE)
	text("BEST FLOOR", Vector2(54, 66), 13, C_MUTED)
	text(str(meta.best_floor), Vector2(54, 101), 29, C_TEXT)
	panel(Rect2(504, 36, 180, 78), Color(0.05, 0.07, 0.15, 0.92), C_GOLD)
	text("BANK", Vector2(524, 66), 13, C_MUTED)
	draw_circle(Vector2(528, 91), 6, C_GOLD)
	text("%d" % meta.coins, Vector2(544, 101), 28, C_GOLD)

func _draw_home_title() -> void:
	draw_string(font, Vector2(72, 174), "ONE MORE", HORIZONTAL_ALIGNMENT_CENTER, 576, 45, C_TEXT)
	draw_string(font, Vector2(72, 236), "FLOOR", HORIZONTAL_ALIGNMENT_CENTER, 576, 72, C_GOLD)
	draw_string(font, Vector2(72, 275), "CLIMB  •  LOOT  •  SURVIVE", HORIZONTAL_ALIGNMENT_CENTER, 576, 13, Color("bbb8d5"))

func _draw_home_tower(center: Vector2) -> void:
	# shadow behind the structure
	draw_circle(center + Vector2(0, 36), 138, Color(0.0, 0.0, 0.0, 0.20))
	# side towers
	for side in [-1.0, 1.0]:
		var x: float = center.x + side * 88.0
		draw_rect(Rect2(x - 28, center.y - 84, 56, 164), Color("10172b"))
		draw_rect(Rect2(x - 34, center.y - 98, 68, 20), Color("202342"))
		draw_colored_polygon(PackedVector2Array([Vector2(x-36,center.y-98),Vector2(x,center.y-145),Vector2(x+36,center.y-98)]), Color("1b2140"))
		draw_circle(Vector2(x, center.y - 68), 7, Color(0.96, 0.61, 0.23, 0.55))
	# central keep
	draw_rect(Rect2(center.x - 66, center.y - 154, 132, 242), Color("11182f"))
	draw_rect(Rect2(center.x - 78, center.y - 169, 156, 24), Color("252642"))
	draw_colored_polygon(PackedVector2Array([Vector2(center.x-78,center.y-168),Vector2(center.x,center.y-246),Vector2(center.x+78,center.y-168)]), Color("202347"))
	draw_circle(Vector2(center.x, center.y - 170), 27, Color("171637"))
	draw_arc(Vector2(center.x, center.y - 170), 26, 0, TAU, 36, C_PURPLE, 3)
	draw_colored_polygon(PackedVector2Array([Vector2(center.x,center.y-190),Vector2(center.x+15,center.y-167),Vector2(center.x,center.y-144),Vector2(center.x-15,center.y-167)]), Color(0.62, 0.36, 1.0, 0.28))
	for row in range(3):
		for col in range(2):
			var wx: float = center.x - 28.0 + float(col) * 56.0
			var wy: float = center.y - 106.0 + float(row) * 54.0
			draw_rect(Rect2(wx - 7, wy - 13, 14, 27), Color(0.95, 0.56, 0.20, 0.75))
			draw_rect(Rect2(wx - 4, wy - 10, 8, 21), Color(1.0, 0.82, 0.38, 0.58))
	# gate
	draw_rect(Rect2(center.x - 25, center.y + 30, 50, 58), Color("070b17"))
	draw_arc(Vector2(center.x, center.y + 31), 25, PI, TAU, 30, Color("394064"), 3)
	# floating runes
	for i in range(6):
		var a: float = elapsed * 0.16 + TAU * float(i) / 6.0
		var p := center + Vector2(cos(a) * 128.0, sin(a) * 86.0)
		draw_circle(p, 3.0, Color(C_PURPLE, 0.34))

func _draw_home_wanderer(pos: Vector2) -> void:
	draw_ellipse_shadow(pos + Vector2(0, 29), 45, 13)
	# cape silhouette
	draw_colored_polygon(PackedVector2Array([pos+Vector2(-31,25),pos+Vector2(-23,-19),pos+Vector2(0,-35),pos+Vector2(23,-19),pos+Vector2(33,27),pos+Vector2(0,44)]), Color("3a244d"))
	# hood and face
	draw_circle(pos + Vector2(0, -24), 24, Color("252944"))
	draw_colored_polygon(PackedVector2Array([pos+Vector2(-19,-25),pos+Vector2(0,-48),pos+Vector2(20,-25),pos+Vector2(14,-4),pos+Vector2(-14,-4)]), Color("35395b"))
	draw_circle(pos + Vector2(0, -22), 13, Color("cba47c"))
	draw_line(pos + Vector2(-8,-20), pos + Vector2(-3,-20), Color("171827"), 2)
	draw_line(pos + Vector2(3,-20), pos + Vector2(8,-20), Color("171827"), 2)
	# chest armor
	draw_colored_polygon(PackedVector2Array([pos+Vector2(-22,-3),pos+Vector2(22,-3),pos+Vector2(17,27),pos+Vector2(-17,27)]), Color("31466d"))
	draw_line(pos + Vector2(0,-1), pos + Vector2(0,25), Color(0.72,0.78,0.95,0.20), 2)
	# sword
	draw_line(pos + Vector2(-20, 14), pos + Vector2(-57, -30), Color("7d573a"), 8)
	draw_line(pos + Vector2(-55, -31), pos + Vector2(-86, -68), C_GOLD, 7)
	draw_line(pos + Vector2(-83, -70), pos + Vector2(-91, -80), C_TEXT, 3)
	draw_circle(pos + Vector2(-57, -31), 6, Color("d7a547"))

func _draw_home_action_row() -> void:
	button(MISSIONS_BTN, "MISSIONS", C_GREEN, 18)
	button(PASS_BTN, "TOWER PASS", C_PURPLE, 18)

func _draw_home_meta_tabs() -> void:
	var tabs := [
		{"r":HERO_TAB,"label":"HERO","c":C_BLUE,"icon":"hero"},
		{"r":FORGE_TAB,"label":"FORGE","c":C_ORANGE,"icon":"forge"},
		{"r":TALENTS_TAB,"label":"TALENTS","c":C_PURPLE,"icon":"talent"},
		{"r":VAULT_TAB,"label":"VAULT","c":C_GOLD,"icon":"vault"}
	]
	for tab in tabs:
		var r: Rect2 = tab["r"]
		panel(r, Color("11172e"), tab["c"])
		_draw_meta_icon(String(tab["icon"]), Vector2(r.get_center().x, r.position.y + 32.0), tab["c"])
		draw_string(font, Vector2(r.position.x + 8, r.position.y + 77), String(tab["label"]), HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16, 15, C_TEXT)
	panel(Rect2(38, 1164, 644, 64), Color("0b1225"), Color("343d6b"))
	text("POWER  %d" % meta.power_score(), Vector2(62, 1203), 17, C_GOLD)
	draw_string(font, Vector2(310, 1203), "KAMILUNAVO GAMES", HORIZONTAL_ALIGNMENT_RIGHT, 344, 13, C_MUTED)

func _draw_meta_icon(kind: String, p: Vector2, c: Color) -> void:
	if kind == "hero":
		draw_circle(p + Vector2(0,-4), 8, c)
		draw_arc(p + Vector2(0,9), 14, PI, TAU, 20, c, 3)
	elif kind == "forge":
		draw_line(p + Vector2(-10,10), p + Vector2(10,-10), c, 5)
		draw_line(p + Vector2(-12,-10), p + Vector2(12,12), Color(c,0.55), 3)
	elif kind == "talent":
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-14),p+Vector2(12,0),p+Vector2(0,14),p+Vector2(-12,0)]), Color(c,0.55))
		draw_circle(p, 4, C_TEXT)
	else:
		draw_rect(Rect2(p.x-13,p.y-8,26,18), Color(c,0.34))
		draw_line(p+Vector2(-13,-8),p+Vector2(0,-16),c,3)
		draw_line(p+Vector2(0,-16),p+Vector2(13,-8),c,3)

func draw_pass_screen() -> void:
	_draw_pass_background()
	panel(Rect2(42, 42, 636, 100), Color(0.05,0.06,0.14,0.94), C_PURPLE)
	text("TOWER PASS", Vector2(68, 88), 34, C_TEXT)
	text("FREE SEASON PATH", Vector2(70, 119), 13, C_PURPLE)
	draw_circle(Vector2(560, 85), 10, C_GOLD)
	text("%d" % meta.coins, Vector2(581, 96), 24, C_GOLD)
	var level_no: int = int(tower_pass.level())
	var p: Dictionary = tower_pass.progress_to_next()
	panel(Rect2(58, 178, 604, 188), Color("11172e"), C_PURPLE)
	text("LEVEL", Vector2(84, 220), 13, C_MUTED)
	text("%d" % level_no, Vector2(84, 270), 42, C_TEXT)
	text("/ %d" % tower_pass.MAX_LEVEL, Vector2(142, 270), 18, C_MUTED)
	text("NEXT REWARD", Vector2(430, 220), 13, C_MUTED)
	var preview_level: int = mini(tower_pass.MAX_LEVEL, level_no + 1)
	var preview: Dictionary = tower_pass.reward_for(preview_level)
	text(String(preview["label"]), Vector2(430, 250), 16, C_TEXT)
	text("%d COINS" % int(preview["coins"]), Vector2(430, 278), 15, C_GOLD)
	var bar := Rect2(84, 310, 552, 18)
	draw_rect(bar, Color("272642"))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * float(p["ratio"]), bar.size.y)), C_PURPLE)
	draw_circle(Vector2(bar.position.x + bar.size.x * float(p["ratio"]), bar.get_center().y), 9, C_TEXT)
	text("%d / %d XP" % [int(p["current"]), int(p["needed"])], Vector2(84, 351), 13, C_MUTED)
	text("REWARD TRACK", Vector2(58, 420), 15, C_GOLD)
	var start_level: int = maxi(1, level_no - 1)
	for i in range(5):
		var l: int = start_level + i
		if l > tower_pass.MAX_LEVEL:
			break
		_draw_pass_reward_card(l, i)
	var next_claim: int = int(tower_pass.next_claimable())
	button(PASS_CLAIM, "CLAIM LEVEL %d" % next_claim if next_claim > 0 else "NO REWARD READY", C_GOLD if next_claim > 0 else Color("4d526d"), 17)
	button(OVERLAY_BACK, "BACK", C_PURPLE, 19)
	_draw_notice(1008)

func _draw_pass_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("060b19"))
	draw_circle(Vector2(610, 250), 260, Color(0.41,0.20,0.72,0.10))
	draw_circle(Vector2(110, 840), 230, Color(0.12,0.39,0.58,0.08))
	for i in range(7):
		var y: float = 390.0 + float(i) * 108.0
		draw_line(Vector2(72,y), Vector2(648,y), Color(0.55,0.40,0.90,0.05), 1)

func _draw_pass_reward_card(level_no: int, index: int) -> void:
	var reward: Dictionary = tower_pass.reward_for(level_no)
	var unlocked: bool = level_no <= int(tower_pass.level())
	var claimable: bool = bool(tower_pass.can_claim(level_no))
	var accent: Color = C_GOLD if claimable else (C_PURPLE if unlocked else Color("39415d"))
	var r := Rect2(58, 452 + index * 100, 604, 82)
	panel(r, Color("11172e"), accent)
	draw_circle(Vector2(r.position.x + 45, r.get_center().y), 20, Color(accent,0.18))
	draw_circle(Vector2(r.position.x + 45, r.get_center().y), 8, C_GOLD if unlocked else C_MUTED)
	text("LV %02d" % level_no, r.position + Vector2(82, 34), 16, C_TEXT)
	text(String(reward["label"]), r.position + Vector2(168, 31), 14, C_MUTED)
	text("+%d" % int(reward["coins"]), r.position + Vector2(168, 57), 15, C_GOLD)
	var status: String = "CLAIM" if claimable else ("UNLOCKED" if unlocked else "LOCKED")
	text(status, r.position + Vector2(474, 48), 13, C_GOLD if claimable else C_MUTED)

func _draw_room_floor() -> void:
	var area: String = String(current_room.get("area", "DUNGEON"))
	var base := Color("0b1324")
	var seam := Color(0.23,0.31,0.48,0.16)
	var glow := Color(0.95,0.58,0.20,0.08)
	if area == "CRYPT":
		base = Color("090f1c")
		seam = Color(0.26,0.53,0.58,0.13)
		glow = Color(0.45,0.24,0.72,0.10)
	elif area == "FORGOTTEN CASTLE":
		base = Color("0c1320")
		seam = Color(0.37,0.42,0.52,0.16)
		glow = Color(0.62,0.18,0.22,0.09)
	elif area == "DEEP TOWER":
		base = Color("0b0b1b")
		seam = Color(0.43,0.30,0.62,0.15)
		glow = Color(0.48,0.24,0.72,0.11)
	draw_rect(ARENA, base)
	# stone slabs
	var tile_w: float = 72.0
	var tile_h: float = 64.0
	for row in range(14):
		var y: float = ARENA.position.y + float(row) * tile_h
		var stagger: float = 36.0 if row % 2 else 0.0
		for col in range(10):
			var x: float = ARENA.position.x - 36.0 + stagger + float(col) * tile_w
			var tile := Rect2(x, y, tile_w, tile_h)
			if tile.intersects(ARENA):
				draw_rect(tile, Color(1.0,1.0,1.0,0.009 if (row+col)%2 else 0.015))
			draw_line(Vector2(x,y), Vector2(x+tile_w,y), seam, 1.0)
		draw_line(Vector2(ARENA.position.x,y), Vector2(ARENA.end.x,y), seam, 1.0)
	# center atmosphere
	for i in range(5):
		draw_arc(ARENA.get_center(), 118.0 + float(i) * 52.0, elapsed * 0.035 + float(i), elapsed * 0.035 + float(i) + PI * 1.15, 52, Color(glow, 0.22 + float(i) * 0.08), 2.0)
	# area-specific floor marks
	if area == "CRYPT":
		for i in range(5):
			var p := Vector2(128.0 + float(i % 3) * 225.0, 335.0 + float(i / 3) * 410.0)
			draw_arc(p, 24, elapsed * 0.12 + i, elapsed * 0.12 + i + PI * 1.65, 24, Color(0.33,0.78,0.82,0.15), 2)
	elif area == "FORGOTTEN CASTLE":
		for x in [175.0, 545.0]:
			draw_line(Vector2(x, 295), Vector2(x + 28, 350), Color(0.74,0.68,0.58,0.10), 3)
			draw_line(Vector2(x + 28,350), Vector2(x - 12,405), Color(0.74,0.68,0.58,0.07), 2)
	# inner rim / vignette
	draw_rect(ARENA, Color(0.55,0.60,0.85,0.10), false, 2)
	draw_rect(Rect2(ARENA.position, Vector2(ARENA.size.x, 18)), Color(0,0,0,0.20))
	draw_rect(Rect2(Vector2(ARENA.position.x, ARENA.end.y-18), Vector2(ARENA.size.x,18)), Color(0,0,0,0.18))
	draw_rect(Rect2(ARENA.position, Vector2(18,ARENA.size.y)), Color(0,0,0,0.18))
	draw_rect(Rect2(Vector2(ARENA.end.x-18,ARENA.position.y), Vector2(18,ARENA.size.y)), Color(0,0,0,0.18))

func _draw_room_architecture() -> void:
	var area: String = String(current_room.get("area", "DUNGEON"))
	var stone := Color("263148")
	var trim := Color("59657b")
	var flame := C_ORANGE
	if area == "CRYPT":
		stone = Color("202b37")
		trim = Color("4f6470")
		flame = C_CYAN
	elif area == "FORGOTTEN CASTLE":
		stone = Color("2a303d")
		trim = Color("646878")
		flame = C_RED
	for y in [238.0, 468.0, 698.0, 928.0]:
		for x in [47.0, 649.0]:
			_draw_v11_pillar(Vector2(x, y), stone, trim, flame, area)
	# banners and wall ornaments
	if area == "FORGOTTEN CASTLE":
		for x in [112.0, 608.0]:
			draw_colored_polygon(PackedVector2Array([Vector2(x-18,190),Vector2(x+18,190),Vector2(x+14,268),Vector2(x,283),Vector2(x-14,268)]), Color("5a1f2c"))
			draw_line(Vector2(x-21,190),Vector2(x+21,190),C_GOLD,3)
	elif area == "CRYPT":
		for x in [105.0, 615.0]:
			draw_circle(Vector2(x, 204), 13, Color(C_CYAN,0.10))
			draw_arc(Vector2(x,204), 14, 0, TAU, 24, Color(C_CYAN,0.40), 2)
	var room_type: String = String(current_room.get("type", "COMBAT"))
	if room_type == "TREASURE":
		_draw_v11_chest(Vector2(360, 291))
	elif room_type == "ELITE":
		draw_arc(ARENA.get_center(), 252, elapsed * 0.12, elapsed * 0.12 + PI * 1.7, 80, Color(C_GOLD,0.16), 3)
		draw_arc(ARENA.get_center(), 238, -elapsed * 0.16, -elapsed * 0.16 + PI * 1.25, 80, Color(C_PURPLE,0.10), 2)
	elif room_type == "AMBUSH":
		for i in range(4):
			var p := ARENA.get_center() + Vector2.from_angle(TAU*float(i)/4.0) * 236.0
			draw_colored_polygon(PackedVector2Array([p+Vector2(0,-12),p+Vector2(10,8),p+Vector2(-10,8)]), Color(C_RED,0.26))

func _draw_v11_pillar(p: Vector2, stone: Color, trim: Color, flame_color: Color, area: String) -> void:
	draw_rect(Rect2(p.x, p.y, 26, 72), stone)
	draw_rect(Rect2(p.x-5, p.y-8, 36, 10), trim)
	draw_rect(Rect2(p.x-5, p.y+66, 36, 10), trim)
	draw_line(Vector2(p.x+5,p.y+9),Vector2(p.x+5,p.y+60),Color(1,1,1,0.06),2)
	var fp := Vector2(p.x+13, p.y+18 + sin(elapsed*6.5+p.y)*2.0)
	draw_circle(fp, 13, Color(flame_color,0.08))
	if area == "CRYPT":
		draw_circle(fp, 6, Color(flame_color,0.70))
		draw_circle(fp, 3, C_TEXT)
	else:
		draw_colored_polygon(PackedVector2Array([fp+Vector2(-6,7),fp+Vector2(0,-14),fp+Vector2(6,7)]), flame_color)
		draw_colored_polygon(PackedVector2Array([fp+Vector2(-3,5),fp+Vector2(0,-8),fp+Vector2(3,5)]), C_GOLD)

func _draw_v11_chest(p: Vector2) -> void:
	draw_circle(p + Vector2(0,12), 54, Color(C_GOLD,0.055))
	draw_rect(Rect2(p.x-42,p.y-2,84,42), Color("5b3824"))
	draw_colored_polygon(PackedVector2Array([p+Vector2(-42,-2),p+Vector2(-31,-25),p+Vector2(31,-25),p+Vector2(42,-2)]), Color("6d4327"))
	draw_rect(Rect2(p.x-5,p.y-25,10,65), C_GOLD)
	draw_line(p+Vector2(-42,-2),p+Vector2(42,-2),C_GOLD,3)
	draw_circle(p+Vector2(0,13),5,C_TEXT)

func _draw_combat_hud() -> void:
	# top glass panel
	panel(Rect2(30, 24, 660, 112), Color(0.025,0.04,0.09,0.96), Color("39466f"))
	text("FLOOR", Vector2(52, 57), 12, C_MUTED)
	text("%02d" % int(run.floor_no), Vector2(52, 101), 38, C_TEXT)
	var area_name: String = String(current_room.get("area", "DUNGEON"))
	var room_name: String = String(current_room.get("type", "COMBAT"))
	text(area_name, Vector2(138, 65), 15, _area_accent(area_name))
	text(room_name, Vector2(138, 94), 13, C_MUTED)
	panel(Rect2(504, 48, 108, 54), Color("11172e"), C_GOLD)
	draw_circle(Vector2(524, 75), 7, C_GOLD)
	text("%d" % int(run.run_coins), Vector2(541, 84), 20, C_GOLD)
	# hp / status strip
	var hp_box := Rect2(110, 1016, 430, 30)
	draw_rect(hp_box, Color("241421"))
	var ratio: float = clampf(run.hp / run.max_hp, 0.0, 1.0)
	draw_rect(Rect2(hp_box.position, Vector2(hp_box.size.x * ratio, hp_box.size.y)), Color("e84d64"))
	draw_rect(Rect2(hp_box.position + Vector2(2,2), Vector2(maxf(0.0,hp_box.size.x * ratio - 4.0),5)), Color(1,1,1,0.16))
	center_rect("%d / %d HP" % [int(run.hp), int(run.max_hp)], hp_box, 15, C_TEXT)
	# joystick
	var base: Vector2 = joy_origin if joy_active else Vector2(145, 1115)
	var knob: Vector2 = joy_pos if joy_active else base
	draw_circle(base, 82, Color(0.12,0.17,0.31,0.72))
	draw_arc(base, 82, 0, TAU, 64, Color(0.38,0.47,0.75,0.34), 3)
	draw_arc(base, 68, -PI*0.12, PI*1.16, 50, Color(0.45,0.68,1.0,0.10), 2)
	draw_circle(knob, 37, Color(0.43,0.48,0.70,0.90))
	draw_circle(knob-Vector2(7,8), 9, Color(1,1,1,0.08))
	text("MOVE", Vector2(110, 1215), 11, C_MUTED)
	# nova
	var center: Vector2 = SKILL.get_center()
	var ready: bool = float(run.skill_cd) <= 0.0
	draw_circle(center, 64, Color("0c1832"))
	draw_circle(center, 52, Color("173766"))
	draw_circle(center, 44, Color(0.12,0.31,0.58,0.82))
	var fill: float = 1.0 if ready else clampf(1.0 - run.skill_cd / 7.0,0.0,1.0)
	draw_arc(center, 62, -PI/2.0, -PI/2.0 + TAU*fill, 64, C_CYAN if ready else Color("53627d"), 6)
	if ready:
		draw_arc(center, 68 + sin(elapsed*4.0)*2.0, 0, TAU, 64, Color(C_CYAN,0.18), 3)
	_draw_nova_icon(center + Vector2(0,-5), C_TEXT if ready else C_MUTED)
	center_rect("NOVA" if ready else "%.1f" % run.skill_cd, Rect2(center-Vector2(52,5),Vector2(104,42)), 14, C_TEXT)
	if floor_banner > 0.0:
		var c := C_GOLD
		c.a = clampf(floor_banner, 0.0, 1.0)
		draw_string(font, Vector2(80, 606), "FLOOR %d" % run.floor_no, HORIZONTAL_ALIGNMENT_CENTER, 560, 44, c)

func _draw_nova_icon(p: Vector2, c: Color) -> void:
	draw_colored_polygon(PackedVector2Array([p+Vector2(-5,-19),p+Vector2(8,-19),p+Vector2(1,-4),p+Vector2(13,-4),p+Vector2(-9,19),p+Vector2(-2,3),p+Vector2(-13,3)]), Color(c,0.82))

func _draw_room_badge() -> void:
	if String(current_room.get("type", "")) == "BOSS":
		return
	var label: String = room_system.room_label(current_room)
	var accent: Color = _area_accent(String(current_room.get("area", "DUNGEON")))
	var r := Rect2(238, 170, 244, 38)
	panel(r, Color(0.025,0.035,0.08,0.92), accent)
	center_rect(label, r, 12, C_TEXT)

func _area_accent(area: String) -> Color:
	match area:
		"CRYPT": return C_CYAN
		"FORGOTTEN CASTLE": return Color("d86f75")
		"DEEP TOWER": return C_PURPLE
	return C_GOLD

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	if combat:
		draw_ellipse_shadow(pos + Vector2(0, 25.0*scale), 32.0*scale, 10.0*scale)
		draw_circle(pos + Vector2(0,4), 36.0*scale, Color(C_BLUE,0.035))
	super.draw_wanderer(pos, scale, combat)
	if combat and player_anim_state == "hit":
		draw_arc(pos, 44.0*scale, -0.4, PI+0.4, 30, Color(C_RED,0.60), 3)

func draw_enemy(e: Dictionary) -> void:
	var p: Vector2 = e["pos"]
	var radius: float = float(e["radius"])
	draw_ellipse_shadow(p + Vector2(0, radius*0.65), radius*0.82, maxf(5.0,radius*0.24))
	if bool(e.get("elite",false)):
		draw_circle(p, radius+12.0, Color(C_GOLD,0.045))
	super.draw_enemy(e)

func draw_player_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot["pos"]
	var dir: Vector2 = shot["vel"].normalized()
	var c: Color = C_GOLD if bool(shot["crit"]) else C_CYAN
	draw_line(p-dir*34.0,p+dir*5.0,Color(c,0.10),12.0 if bool(shot["crit"]) else 9.0)
	draw_line(p-dir*24.0,p+dir*8.0,Color(c,0.42),6.0 if bool(shot["crit"]) else 4.0)
	draw_line(p-dir*12.0,p+dir*8.0,C_TEXT,2.0)
	draw_circle(p,5.0 if bool(shot["crit"]) else 4.0,c)

func draw_enemy_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot["pos"]
	var c: Color = shot["color"]
	var pulse: float = 1.0 + sin(elapsed*9.0+p.x*0.03)*0.10
	draw_circle(p,14.0*pulse,Color(c,0.07))
	draw_circle(p,9.0*pulse,Color(c,0.16))
	draw_circle(p,5.0*pulse,c)
	draw_circle(p-Vector2(2,2),2.0,C_TEXT)

func draw_coin_orb(orb: Dictionary) -> void:
	var p: Vector2 = orb["pos"]
	var pulse: float = 1.0 + sin(elapsed*8.0+p.x)*0.12
	draw_circle(p,16.0*pulse,Color(C_GOLD,0.07))
	draw_circle(p,10.0*pulse,Color("b97724"))
	draw_circle(p,7.0*pulse,C_GOLD)
	draw_circle(p-Vector2(2,2),2.0,Color(1,1,1,0.70))

func _sync_music_context(force: bool) -> void:
	if release_audio == null:
		return
	var desired := "menu"
	if state in [State.RUNNING, State.UPGRADE, State.DECISION]:
		var area: String = String(current_room.get("area", "DUNGEON"))
		if state == State.RUNNING and _v11_has_boss():
			desired = "boss"
		elif area == "CRYPT":
			desired = "crypt"
		elif area == "FORGOTTEN CASTLE":
			desired = "castle"
		else:
			desired = "dungeon"
	if force or desired != v11_music_context:
		v11_music_context = desired
		release_audio.set_music_context(desired)

func _v11_has_boss() -> bool:
	for e in enemies:
		if String(e.get("type", "")) == "warden":
			return true
	return false
