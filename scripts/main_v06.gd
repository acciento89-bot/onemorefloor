extends "res://scripts/main_v05.gd"

var room_transition: float = 0.0
var keeper_intro: float = 0.0

func _process(delta: float) -> void:
	super._process(delta)
	room_transition = maxf(0.0, room_transition - delta)
	keeper_intro = maxf(0.0, keeper_intro - delta)

func spawn_floor() -> void:
	room_transition = 0.72
	if int(run.floor_no) != 20:
		super.spawn_floor()
		return
	current_room = room_system.roll_room(int(run.floor_no), rng)
	hazard_timer = 2.2
	enemies.clear()
	player_shots.clear()
	enemy_shots.clear()
	coin_orbs.clear()
	player_pos = Vector2(360, 700)
	floor_banner = 1.25
	boss_intro = 0.0
	keeper_intro = 1.75
	enemies.append(EnemyFactory.make_enemy("crypt_keeper", int(run.floor_no), rng, player_pos))
	for i in range(3):
		var escort_kind: String = "ghoul" if i % 2 == 0 else "necromancer"
		enemies.append(EnemyFactory.make_enemy(escort_kind, int(run.floor_no), rng, player_pos))
	_audio("warden")

func execute_warden_cast(e: Dictionary) -> void:
	if String(e.get("boss_variant", "warden")) != "crypt_keeper":
		super.execute_warden_cast(e)
		return
	var p: Vector2 = e["pos"]
	var phase2: bool = bool(e["phase2"])
	if String(e["cast_kind"]) == "fan":
		var aim: Vector2 = (player_pos - p).normalized()
		var count: int = 9 if phase2 else 7
		for i in range(count):
			var spread: float = (float(i) - float(count - 1) * 0.5) * 0.125
			var dir: Vector2 = aim.rotated(spread)
			enemy_shots.append({"pos":p + dir * 50.0,"vel":dir * 350.0,"damage":18.0 + run.floor_no * 0.82,"life":2.9,"color":C_CYAN})
		for side in [-1.0, 1.0]:
			var side_dir: Vector2 = aim.rotated(side * 0.58)
			enemy_shots.append({"pos":p + side_dir * 48.0,"vel":side_dir * 275.0,"damage":16.0 + run.floor_no * 0.72,"life":3.1,"color":C_PURPLE})
	else:
		var count: int = 18 if phase2 else 14
		var offset: float = float(e["attack_index"]) * 0.19
		for i in range(count):
			var angle: float = offset + TAU * float(i) / float(count)
			var dir: Vector2 = Vector2.from_angle(angle)
			var shot_color: Color = C_CYAN if i % 2 == 0 else C_PURPLE
			enemy_shots.append({"pos":p + dir * 50.0,"vel":dir * (285.0 if phase2 else 225.0),"damage":17.0 + run.floor_no * 0.76,"life":3.5,"color":shot_color})
	effects.append({"type":"keeper_cast","pos":p,"age":0.0,"dur":0.34,"color":C_CYAN,"kind":""})
	screen_shake = maxf(screen_shake, 7.0 if phase2 else 4.5)
	haptic(30)

func remove_dead() -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if float(enemies[i]["hp"]) > 0.0:
			continue
		var e: Dictionary = enemies[i]
		var kind: String = String(e["type"])
		var bonuses: Dictionary = loot.equipped_bonuses()
		var reward: int = int(round(float(e["reward"]) * meta.coin_multiplier() * (1.0 + float(bonuses["coin_pct"]))))
		coin_orbs.append({"pos":e["pos"],"value":reward,"age":0.0})
		effects.append({"type":"burst","pos":e["pos"],"age":0.0,"dur":0.30,"color":enemy_color(kind),"kind":""})
		missions.record("kills", 1)
		if kind == "warden":
			missions.record("wardens", 1)
			tower_pass.add_xp(70)
			screen_shake = 12.0
			haptic(80)
		var item: Dictionary = loot.roll_drop(kind, int(run.floor_no), rng)
		if not item.is_empty():
			loot_notice = "%s %s — %s" % [String(item["rarity"]), String(item["name"]), loot.stat_line(item)]
			loot_notice_color = rarity_color(String(item["rarity"]))
			loot_notice_time = 2.4
			effects.append({"type":"loot_beam","pos":e["pos"],"age":0.0,"dur":0.72,"color":loot_notice_color,"kind":String(item["rarity"])})
			_audio("loot")
		enemies.remove_at(i)

func draw_game() -> void:
	var shake_offset := Vector2.ZERO
	if screen_shake > 0.0:
		shake_offset = Vector2(rng.randf_range(-screen_shake, screen_shake), rng.randf_range(-screen_shake, screen_shake))
	draw_set_transform(shake_offset)
	_draw_room_floor()
	_draw_room_architecture()
	for e in enemies:
		draw_enemy(e)
	for shot in player_shots:
		draw_player_projectile(shot)
	for shot in enemy_shots:
		draw_enemy_projectile(shot)
	for orb in coin_orbs:
		draw_coin_orb(orb)
	for fx in effects:
		draw_effect(fx)
	draw_wanderer(player_pos, 1.0, true)
	for d in damage_numbers:
		var alpha: float = clampf(1.0 - float(d["age"]) / float(d["dur"]), 0.0, 1.0)
		var c: Color = d["color"]
		c.a = alpha
		var fs: int = 27 if bool(d["crit"]) else 19
		draw_string(font, d["pos"] + Vector2(-32, 0), ("CRIT %d" if bool(d["crit"]) else "%d") % int(d["value"]), HORIZONTAL_ALIGNMENT_CENTER, 78, fs, c)
	draw_set_transform(Vector2.ZERO)
	_draw_combat_hud()
	_draw_room_badge()
	_draw_boss_ui()
	_draw_notice(950)
	_draw_transition_overlay()

func _draw_room_floor() -> void:
	var crypt: bool = String(current_room.get("area", "DUNGEON")) == "CRYPT"
	var floor_color: Color = Color("090b18") if crypt else Color("101321")
	draw_rect(ARENA, floor_color)
	var line_color: Color = Color(0.36, 0.28, 0.52, 0.16) if crypt else Color(0.43, 0.34, 0.22, 0.14)
	for x in range(48, 690, 54):
		draw_line(Vector2(x, 160), Vector2(x, 1000), line_color, 1.0)
	for y in range(172, 1010, 54):
		draw_line(Vector2(36, y), Vector2(684, y), line_color, 1.0)
	for y in range(190, 1000, 108):
		var offset: float = 27.0 if int(y / 108) % 2 == 0 else 0.0
		for x in range(52, 680, 108):
			draw_rect(Rect2(float(x) + offset, float(y), 52, 52), Color(1.0, 1.0, 1.0, 0.012), false, 1.0)
	if crypt:
		for i in range(7):
			var rune_pos := Vector2(105.0 + float(i % 4) * 170.0, 300.0 + float(i / 4) * 390.0)
			draw_arc(rune_pos, 18.0 + float(i % 3) * 4.0, elapsed * 0.18 + i, elapsed * 0.18 + i + PI * 1.55, 20, Color(0.55, 0.36, 0.85, 0.16), 2.0)

func _draw_room_architecture() -> void:
	var crypt: bool = String(current_room.get("area", "DUNGEON")) == "CRYPT"
	var stone: Color = Color("24273a") if crypt else Color("332b28")
	var trim: Color = Color("59516f") if crypt else Color("6a5040")
	for y in [240.0, 465.0, 690.0, 915.0]:
		for x in [46.0, 650.0]:
			draw_rect(Rect2(x, y, 28, 68), stone)
			draw_rect(Rect2(x - 4, y - 8, 36, 10), trim)
			draw_rect(Rect2(x - 4, y + 62, 36, 10), trim)
			if crypt:
				draw_circle(Vector2(x + 14, y + 18), 7, Color("b9b2a7"))
			else:
				var flame := Vector2(x + 14, y + 16 + sin(elapsed * 7.0 + y) * 2.0)
				draw_circle(flame, 12, Color(1.0, 0.35, 0.08, 0.10))
				draw_colored_polygon(PackedVector2Array([flame+Vector2(-6,6), flame+Vector2(0,-13), flame+Vector2(6,6)]), C_ORANGE)
	var room_type: String = String(current_room.get("type", "COMBAT"))
	if room_type == "TREASURE":
		draw_rect(Rect2(319, 275, 82, 48), Color("4a2f22"))
		draw_rect(Rect2(313, 267, 94, 14), C_GOLD)
		draw_rect(Rect2(354, 267, 12, 56), Color("d79234"))
		draw_circle(Vector2(360, 298), 5, C_TEXT)
	elif room_type == "ELITE":
		draw_arc(ARENA.get_center(), 292, elapsed * 0.15, elapsed * 0.15 + TAU, 72, Color(1.0, 0.71, 0.22, 0.13), 5.0)
	elif room_type == "AMBUSH":
		draw_arc(ARENA.get_center(), 292, -elapsed * 0.2, -elapsed * 0.2 + TAU, 72, Color(1.0, 0.23, 0.30, 0.13), 5.0)

func _draw_combat_hud() -> void:
	panel(Rect2(34, 34, 652, 104), Color("080c19"), Color("343d6b"))
	text("FLOOR %d" % run.floor_no, Vector2(58, 84), 32, C_TEXT)
	var area_name: String = String(current_room.get("area", "DUNGEON"))
	text("%s  •  %s" % [area_name, String(current_room.get("type", "COMBAT"))], Vector2(58, 116), 13, C_MUTED)
	text("%d" % run.run_coins, Vector2(586, 86), 26, C_GOLD)
	draw_circle(Vector2(565, 78), 7, C_GOLD)
	var hp_box := Rect2(110, 1018, 430, 28)
	draw_rect(hp_box, Color("321824"))
	draw_rect(Rect2(hp_box.position, Vector2(hp_box.size.x * clampf(run.hp / run.max_hp, 0.0, 1.0), 28)), C_RED)
	center_rect("%d / %d HP" % [int(run.hp), int(run.max_hp)], hp_box, 16, C_TEXT)
	var base: Vector2 = joy_origin if joy_active else Vector2(145, 1115)
	var knob: Vector2 = joy_pos if joy_active else base
	draw_circle(base, 80, Color(0.20, 0.22, 0.36, 0.48))
	draw_arc(base, 80, 0, TAU, 48, Color(0.55, 0.58, 0.82, 0.30), 3)
	draw_circle(knob, 38, Color(0.58, 0.60, 0.80, 0.72))
	draw_circle(SKILL.get_center(), 61, Color("111f42"))
	draw_circle(SKILL.get_center(), 49, Color("183367"))
	draw_arc(SKILL.get_center(), 60, -PI/2.0, -PI/2.0 + TAU * (1.0 if run.skill_cd <= 0.0 else clampf(1.0 - run.skill_cd / 7.0, 0.0, 1.0)), 52, C_CYAN if run.skill_cd <= 0.0 else Color("55607b"), 6)
	center_rect("NOVA" if run.skill_cd <= 0.0 else "%.1f" % run.skill_cd, SKILL, 18, C_TEXT)
	if floor_banner > 0.0:
		var c := C_GOLD
		c.a = clampf(floor_banner, 0.0, 1.0)
		draw_string(font, Vector2(80, 608), "FLOOR %d" % run.floor_no, HORIZONTAL_ALIGNMENT_CENTER, 560, 50, c)

func _draw_room_badge() -> void:
	var label: String = room_system.room_label(current_room)
	var accent: Color = C_PURPLE if String(current_room.get("area", "")) == "CRYPT" else C_GOLD
	panel(Rect2(208, 218, 304, 42), Color(0.03, 0.04, 0.09, 0.92), accent)
	center_rect(label, Rect2(208, 218, 304, 42), 13, C_TEXT)

func _draw_boss_ui() -> void:
	var boss: Dictionary = {}
	for e in enemies:
		if String(e["type"]) == "warden":
			boss = e
			break
	if boss.is_empty():
		return
	var keeper: bool = String(boss.get("boss_variant", "warden")) == "crypt_keeper"
	var ratio: float = clampf(float(boss["hp"]) / float(boss["max_hp"]), 0.0, 1.0)
	var accent: Color = C_CYAN if keeper else (C_RED if bool(boss["phase2"]) else C_PURPLE)
	panel(Rect2(104, 158, 512, 56), Color("120d1e"), accent)
	text("THE CRYPT KEEPER" if keeper else "THE WARDEN", Vector2(124, 181), 15, C_TEXT)
	draw_rect(Rect2(265, 178, 326, 14), Color("32152d"))
	draw_rect(Rect2(265, 178, 326 * ratio, 14), accent)
	if keeper_intro > 0.0:
		var alpha: float = clampf(keeper_intro, 0.0, 1.0)
		draw_rect(Rect2(50, 475, 620, 170), Color(0.015, 0.02, 0.05, 0.88 * alpha))
		var c: Color = C_CYAN
		c.a = alpha
		draw_string(font, Vector2(70, 545), "THE CRYPT KEEPER", HORIZONTAL_ALIGNMENT_CENTER, 580, 43, c)
		draw_string(font, Vector2(70, 590), "FLOOR 20  •  GUARDIAN OF THE DEAD", HORIZONTAL_ALIGNMENT_CENTER, 580, 16, C_TEXT)

func _draw_transition_overlay() -> void:
	if room_transition <= 0.0:
		return
	var t: float = clampf(room_transition / 0.72, 0.0, 1.0)
	var alpha: float = sin(t * PI) * 0.62
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.02, 0.02, 0.07, alpha))
	var accent: Color = C_PURPLE if String(current_room.get("area", "")) == "CRYPT" else C_GOLD
	accent.a = sin(t * PI)
	draw_string(font, Vector2(80, 665), room_system.room_label(current_room), HORIZONTAL_ALIGNMENT_CENTER, 560, 28, accent)

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	var bob: float = sin(elapsed * (7.0 if combat else 2.5)) * (1.6 if combat else 1.0)
	var p: Vector2 = pos + Vector2(0, bob)
	draw_ellipse_shadow(p + Vector2(0, 28) * scale, 30.0 * scale, 11.0 * scale)
	draw_colored_polygon(PackedVector2Array([p+Vector2(-23,4)*scale,p+Vector2(-16,35)*scale,p+Vector2(3,43)*scale,p+Vector2(25,31)*scale,p+Vector2(20,0)*scale]), Color("54233f"))
	draw_colored_polygon(PackedVector2Array([p+Vector2(-18,2)*scale,p+Vector2(-12,28)*scale,p+Vector2(16,25)*scale,p+Vector2(18,-1)*scale]), Color("303d67"))
	draw_circle(p + Vector2(0, -13) * scale, 15 * scale, Color("d6aa82"))
	draw_colored_polygon(PackedVector2Array([p+Vector2(-16,-16)*scale,p+Vector2(-5,-31)*scale,p+Vector2(14,-25)*scale,p+Vector2(17,-10)*scale,p+Vector2(5,-19)*scale]), Color("22283f"))
	draw_circle(p + Vector2(-5, -15) * scale, 2.2 * scale, C_BG)
	var sword_dir: Vector2 = Vector2(0.72, -0.69)
	if combat and not enemies.is_empty():
		var idx: int = nearest_enemy([])
		if idx >= 0:
			sword_dir = (Vector2(enemies[idx]["pos"]) - p).normalized()
	var hand: Vector2 = p + Vector2(11, 5) * scale
	var tip: Vector2 = hand + sword_dir * 47.0 * scale
	draw_line(hand, tip, Color("d9e7ff"), 6.0 * scale)
	draw_line(hand, tip, C_GOLD, 2.0 * scale)
	draw_line(hand - Vector2(-sword_dir.y, sword_dir.x) * 8.0 * scale, hand + Vector2(-sword_dir.y, sword_dir.x) * 8.0 * scale, C_GOLD, 4.0 * scale)
	if combat:
		draw_arc(p, 33 * scale, sword_dir.angle() - 0.72, sword_dir.angle() + 0.72, 20, Color(1.0, 0.77, 0.32, 0.28), 3.0 * scale)

func draw_enemy(e: Dictionary) -> void:
	var p: Vector2 = e["pos"]
	var radius: float = float(e["radius"])
	var kind: String = String(e["type"])
	var bob: float = sin(elapsed * 4.5 + float(e.get("phase", 0.0))) * 1.6
	p.y += bob
	draw_ellipse_shadow(p + Vector2(0, radius * 0.72), radius * 0.88, radius * 0.30)
	if kind == "goblin":
		_draw_goblin(p, radius)
	elif kind == "bat":
		_draw_bat(p, e)
	elif kind == "skeleton":
		_draw_skeleton(p)
	elif kind == "ghoul":
		_draw_ghoul(p, e)
	elif kind == "necromancer":
		_draw_necromancer(p, e)
	elif String(e.get("boss_variant", "warden")) == "crypt_keeper":
		_draw_crypt_keeper(p, e)
	else:
		_draw_warden(p, e)
	_draw_enemy_hp(p, e)
	if bool(e.get("elite", false)):
		draw_arc(p, radius + 12.0, elapsed * 0.8, elapsed * 0.8 + TAU, 36, C_GOLD, 3.0)
		draw_string(font, p + Vector2(-40, -radius - 29), "ELITE", HORIZONTAL_ALIGNMENT_CENTER, 80, 12, C_GOLD)

func _draw_goblin(p: Vector2, radius: float) -> void:
	var c := Color("58a565")
	draw_circle(p + Vector2(0, 5), radius, Color("26362a"))
	draw_circle(p + Vector2(0, -4), radius * 0.82, c)
	draw_colored_polygon(PackedVector2Array([p+Vector2(-17,-10),p+Vector2(-34,-23),p+Vector2(-22,1)]), c)
	draw_colored_polygon(PackedVector2Array([p+Vector2(17,-10),p+Vector2(34,-23),p+Vector2(22,1)]), c)
	draw_circle(p + Vector2(-7, -7), 3, Color("f7e37c"))
	draw_circle(p + Vector2(7, -7), 3, Color("f7e37c"))
	draw_line(p + Vector2(-10, 11), p + Vector2(10, 11), Color("233127"), 3)

func _draw_bat(p: Vector2, e: Dictionary) -> void:
	var c := Color("8054bd")
	var flap: float = 13.0 + sin(elapsed * 13.0 + float(e["phase"])) * 9.0
	draw_circle(p, 11, Color("392350"))
	draw_circle(p, 8, c)
	draw_colored_polygon(PackedVector2Array([p+Vector2(-7,0),p+Vector2(-34,-flap),p+Vector2(-27,17),p+Vector2(-15,8)]), c)
	draw_colored_polygon(PackedVector2Array([p+Vector2(7,0),p+Vector2(34,-flap),p+Vector2(27,17),p+Vector2(15,8)]), c)
	draw_circle(p + Vector2(-3, -2), 2, C_RED)
	draw_circle(p + Vector2(3, -2), 2, C_RED)

func _draw_skeleton(p: Vector2) -> void:
	var bone := Color("ddd9c8")
	draw_circle(p + Vector2(0, -10), 15, bone)
	draw_circle(p + Vector2(-5, -12), 3, C_BG)
	draw_circle(p + Vector2(5, -12), 3, C_BG)
	draw_line(p + Vector2(0, 5), p + Vector2(0, 27), bone, 6)
	for y in [10.0, 16.0, 22.0]:
		draw_line(p + Vector2(-12, y), p + Vector2(12, y), bone, 3)
	draw_line(p + Vector2(10, 8), p + Vector2(24, 29), Color("8f6a48"), 4)
	draw_arc(p + Vector2(25, 10), 18, -PI/2.0, PI/2.0, 18, Color("8f6a48"), 3)

func _draw_ghoul(p: Vector2, e: Dictionary) -> void:
	var raging: bool = float(e.get("rage", 0.0)) > 0.0
	var skin: Color = Color("b3484f") if raging else Color("8fae67")
	draw_circle(p + Vector2(0, 8), 24, Color("2a3324"))
	draw_circle(p + Vector2(0, -5), 18, skin)
	draw_line(p + Vector2(-11, 11), p + Vector2(-30, 28), skin, 8)
	draw_line(p + Vector2(11, 11), p + Vector2(30, 28), skin, 8)
	draw_circle(p + Vector2(-7, -8), 3, C_RED)
	draw_circle(p + Vector2(7, -8), 3, C_RED)
	if raging:
		draw_arc(p, 31, elapsed, elapsed + PI * 1.5, 24, Color(1.0, 0.2, 0.2, 0.7), 3)

func _draw_necromancer(p: Vector2, e: Dictionary) -> void:
	draw_colored_polygon(PackedVector2Array([p+Vector2(-25,25),p+Vector2(-15,-17),p,p+Vector2(15,-17),p+Vector2(25,25)]), Color("4d3068"))
	draw_circle(p + Vector2(0, -18), 12, Color("ded8c8"))
	draw_colored_polygon(PackedVector2Array([p+Vector2(-15,-20),p+Vector2(0,-42),p+Vector2(15,-20)]), Color("2a183b"))
	draw_circle(p + Vector2(-4, -20), 2.5, C_PURPLE)
	draw_circle(p + Vector2(4, -20), 2.5, C_PURPLE)
	var staff_top := p + Vector2(25, -28)
	draw_line(p + Vector2(20, 26), staff_top, Color("72553b"), 5)
	draw_circle(staff_top, 8, Color(C_PURPLE, 0.22))
	draw_circle(staff_top, 4, C_PURPLE)
	draw_arc(p, 30, elapsed, elapsed + PI * 1.4, 24, Color(0.6, 0.35, 0.9, 0.35), 2)

func _draw_warden(p: Vector2, e: Dictionary) -> void:
	var phase2: bool = bool(e["phase2"])
	var armor := Color("3d3558") if not phase2 else Color("572d47")
	draw_circle(p, 50, Color("24182e"))
	draw_rect(Rect2(p.x - 34, p.y - 26, 68, 55), armor)
	draw_colored_polygon(PackedVector2Array([p+Vector2(-36,-28),p+Vector2(-24,-57),p+Vector2(-9,-35),p+Vector2(0,-64),p+Vector2(10,-35),p+Vector2(27,-57),p+Vector2(36,-28)]), C_GOLD)
	draw_circle(p + Vector2(-12, -11), 4, C_RED)
	draw_circle(p + Vector2(12, -11), 4, C_RED)
	draw_line(p + Vector2(30, 12), p + Vector2(58, 44), C_GOLD, 8)
	if phase2:
		draw_arc(p, 60, elapsed, elapsed + TAU, 42, C_RED, 4)

func _draw_crypt_keeper(p: Vector2, e: Dictionary) -> void:
	var phase2: bool = bool(e["phase2"])
	draw_circle(p, 55, Color("111a29"))
	draw_circle(p, 48, Color("26344a"))
	draw_colored_polygon(PackedVector2Array([p+Vector2(-39,25),p+Vector2(-32,-31),p+Vector2(-14,-46),p+Vector2(0,-60),p+Vector2(16,-46),p+Vector2(34,-31),p+Vector2(39,25)]), Color("34445c"))
	draw_colored_polygon(PackedVector2Array([p+Vector2(-31,-32),p+Vector2(-20,-68),p+Vector2(-6,-42),p+Vector2(0,-76),p+Vector2(8,-42),p+Vector2(22,-68),p+Vector2(32,-32)]), C_CYAN)
	draw_circle(p + Vector2(-13, -16), 5, C_CYAN)
	draw_circle(p + Vector2(13, -16), 5, C_CYAN)
	draw_line(p + Vector2(-30, 17), p + Vector2(-61, 46), Color("c7d7e9"), 7)
	draw_line(p + Vector2(30, 17), p + Vector2(61, 46), Color("c7d7e9"), 7)
	var aura: Color = C_RED if phase2 else C_CYAN
	draw_arc(p, 66, -elapsed * 0.55, -elapsed * 0.55 + TAU, 48, Color(aura, 0.72), 4)
	draw_arc(p, 74, elapsed * 0.32, elapsed * 0.32 + PI * 1.5, 48, Color(C_PURPLE, 0.45), 2)

func _draw_enemy_hp(p: Vector2, e: Dictionary) -> void:
	var radius: float = float(e["radius"])
	var ratio: float = clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
	var width: float = radius * 2.0
	draw_rect(Rect2(p.x - radius, p.y - radius - 18, width, 7), Color("321521"))
	draw_rect(Rect2(p.x - radius, p.y - radius - 18, width * ratio, 7), C_RED)

func draw_player_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot["pos"]
	var dir: Vector2 = shot["vel"].normalized()
	var c: Color = C_GOLD if bool(shot["crit"]) else C_CYAN
	draw_line(p - dir * 28.0, p + dir * 7.0, Color(c, 0.22), 10.0 if bool(shot["crit"]) else 7.0)
	draw_line(p - dir * 19.0, p + dir * 8.0, c, 5.0 if bool(shot["crit"]) else 3.0)
	draw_circle(p, 5.0 if bool(shot["crit"]) else 3.5, C_TEXT)

func draw_enemy_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot["pos"]
	var c: Color = shot["color"]
	var pulse: float = 1.0 + sin(elapsed * 10.0 + p.x * 0.02) * 0.12
	draw_circle(p, 11 * pulse, Color(c, 0.12))
	draw_circle(p, 6 * pulse, Color(c, 0.32))
	draw_circle(p, 3.5 * pulse, c)

func draw_coin_orb(orb: Dictionary) -> void:
	var p: Vector2 = orb["pos"]
	var pulse: float = 1.0 + sin(elapsed * 9.0 + p.x) * 0.14
	draw_circle(p, 13 * pulse, Color(C_GOLD, 0.12))
	draw_circle(p, 7 * pulse, C_GOLD)
	draw_line(p + Vector2(-3, -4), p + Vector2(3, 4), C_TEXT, 2)
	draw_line(p + Vector2(3, -4), p + Vector2(-3, 4), C_TEXT, 2)

func draw_effect(fx: Dictionary) -> void:
	super.draw_effect(fx)
	var kind: String = String(fx["type"])
	var t: float = clampf(float(fx["age"]) / float(fx["dur"]), 0.0, 1.0)
	var p: Vector2 = fx["pos"]
	var c: Color = fx["color"]
	if kind == "loot_beam":
		c.a = 1.0 - t
		draw_rect(Rect2(p.x - 7, p.y - 120 + t * 40, 14, 145 - t * 55), Color(c, 0.10 * (1.0 - t)))
		draw_line(p + Vector2(0, -115 + t * 30), p + Vector2(0, 18), c, 4.0 * (1.0 - t) + 1.0)
		for i in range(6):
			var a: float = TAU * float(i) / 6.0 + elapsed
			var spark: Vector2 = p + Vector2.from_angle(a) * (14.0 + t * 36.0)
			draw_circle(spark, 3.0 * (1.0 - t), c)
	elif kind == "keeper_cast":
		c.a = 1.0 - t
		draw_arc(p, 22.0 + t * 64.0, 0, TAU, 42, c, 5.0 * (1.0 - t) + 1.0)

func draw_ellipse_shadow(center: Vector2, rx: float, ry: float) -> void:
	var points := PackedVector2Array()
	for i in range(24):
		var a: float = TAU * float(i) / 24.0
		points.append(center + Vector2(cos(a) * rx, sin(a) * ry))
	draw_colored_polygon(points, Color(0.0, 0.0, 0.0, 0.30))

func draw_home() -> void:
	super.draw_home()
	var glow := 0.18 + sin(elapsed * 2.0) * 0.05
	draw_arc(Vector2(360, 393), 176, -0.25, PI + 0.25, 54, Color(C_PURPLE, glow), 5)
	text("v0.6  VISUAL PRODUCTION", Vector2(465, 1174), 12, C_CYAN)
