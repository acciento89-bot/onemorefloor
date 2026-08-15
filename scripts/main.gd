extends Node2D

enum State { HOME, RUNNING, UPGRADE, DECISION, GAME_OVER }

const SIZE := Vector2(720, 1280)
const ARENA := Rect2(36, 160, 648, 840)
const PLAY := Rect2(180, 810, 360, 96)
const SKILL := Rect2(548, 1040, 120, 120)
const JOY_AREA := Rect2(24, 930, 350, 310)
const CASH := Rect2(72, 880, 264, 92)
const NEXT := Rect2(384, 880, 264, 92)
const RETRY := Rect2(72, 900, 264, 92)
const HOME := Rect2(384, 900, 264, 92)

const C_BG := Color("07101f")
const C_PANEL := Color("171c38")
const C_GOLD := Color("f1b84b")
const C_PURPLE := Color("9a5cff")
const C_BLUE := Color("53b9ff")
const C_GREEN := Color("67e58e")
const C_RED := Color("ff5f69")
const C_TEXT := Color("f6f2ff")
const C_MUTED := Color("aaa8c7")

var state := State.HOME
var rng := RandomNumberGenerator.new()
var font: Font

var floor_no := 1
var best_floor := 1
var bank_coins := 0
var run_coins := 0
var saved_after_death := 0

var player_pos := Vector2(360, 700)
var hp := 100.0
var max_hp := 100.0
var speed := 285.0
var damage := 27.0
var attack_delay := 0.48
var attack_timer := 0.0
var attack_range := 225.0
var lifesteal := 0.0
var extra_targets := 0
var enemies: Array[Dictionary] = []

var joy_active := false
var joy_id := -1
var joy_origin := Vector2.ZERO
var joy_pos := Vector2.ZERO
var joy_vector := Vector2.ZERO

var skill_cd := 0.0
var skill_flash := 0.0
var hit_flash := 0.0
var hit_from := Vector2.ZERO
var hit_to := Vector2.ZERO

var upgrades := [
	{"name": "POWER SURGE", "desc": "+25% attack damage", "kind": "power", "color": C_GOLD},
	{"name": "LIFESTEAL", "desc": "+5% damage heals you", "kind": "lifesteal", "color": C_GREEN},
	{"name": "MULTISHOT", "desc": "+1 auto-attack target", "kind": "multi", "color": C_PURPLE},
]

func _ready() -> void:
	rng.randomize()
	font = ThemeDB.fallback_font
	load_progress()
	queue_redraw()

func _process(delta: float) -> void:
	hit_flash = maxf(0.0, hit_flash - delta)
	skill_flash = maxf(0.0, skill_flash - delta)
	if state == State.RUNNING:
		update_game(delta)
	queue_redraw()

func update_game(delta: float) -> void:
	var move := joy_vector
	var keys := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): keys.x -= 1
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): keys.x += 1
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): keys.y -= 1
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): keys.y += 1
	if keys.length_squared() > 0: move = keys.normalized()

	player_pos += move * speed * delta
	player_pos.x = clampf(player_pos.x, ARENA.position.x + 24, ARENA.end.x - 24)
	player_pos.y = clampf(player_pos.y, ARENA.position.y + 24, ARENA.end.y - 24)

	for i in range(enemies.size()):
		var e := enemies[i]
		var dir: Vector2 = player_pos - e["pos"]
		var dist := dir.length()
		if dist > 1:
			e["pos"] += dir / dist * float(e["speed"]) * delta
		if dist < 48 + float(e["radius"]):
			hp -= float(e["dps"]) * delta
		enemies[i] = e

	if hp <= 0:
		die()
		return

	attack_timer -= delta
	if attack_timer <= 0:
		auto_attack()
		attack_timer = attack_delay

	skill_cd = maxf(0.0, skill_cd - delta)
	remove_dead()
	if enemies.is_empty():
		best_floor = maxi(best_floor, floor_no)
		save_progress()
		state = State.UPGRADE

func auto_attack() -> void:
	var used: Array[int] = []
	for _n in range(1 + extra_targets):
		var idx := nearest_enemy(used)
		if idx == -1:
			break
		used.append(idx)
		var e := enemies[idx]
		e["hp"] = float(e["hp"]) - damage
		enemies[idx] = e
		if lifesteal > 0:
			hp = minf(max_hp, hp + damage * lifesteal)
		if used.size() == 1:
			hit_from = player_pos
			hit_to = e["pos"]
			hit_flash = 0.09

func nearest_enemy(ignore: Array[int]) -> int:
	var best := -1
	var best_dist := attack_range + 1
	for i in range(enemies.size()):
		if i in ignore: continue
		var dist := player_pos.distance_to(enemies[i]["pos"])
		if dist <= attack_range and dist < best_dist:
			best = i
			best_dist = dist
	return best

func remove_dead() -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if float(enemies[i]["hp"]) <= 0:
			run_coins += int(enemies[i]["reward"])
			enemies.remove_at(i)

func start_run() -> void:
	floor_no = 1
	run_coins = 0
	hp = 100
	max_hp = 100
	speed = 285
	damage = 27
	attack_delay = 0.48
	attack_range = 225
	lifesteal = 0
	extra_targets = 0
	skill_cd = 0
	player_pos = Vector2(360, 700)
	state = State.RUNNING
	spawn_floor()

func spawn_floor() -> void:
	enemies.clear()
	player_pos = Vector2(360, 700)
	var count := mini(11, 3 + floor_no)
	if floor_no % 5 == 0:
		enemies.append(make_enemy(true))
		count = 2
	for _i in range(count):
		enemies.append(make_enemy(false))

func make_enemy(boss: bool) -> Dictionary:
	var pos := Vector2(rng.randf_range(90, 630), rng.randf_range(220, 920))
	while pos.distance_to(player_pos) < 240:
		pos = Vector2(rng.randf_range(90, 630), rng.randf_range(220, 920))
	if boss:
		var boss_hp := 260.0 + floor_no * 35.0
		return {"pos": pos, "hp": boss_hp, "max_hp": boss_hp, "speed": 58.0, "radius": 44.0, "dps": 20.0, "reward": 60 + floor_no * 5, "boss": true}
	var enemy_hp := 48.0 + floor_no * 11.0
	return {"pos": pos, "hp": enemy_hp, "max_hp": enemy_hp, "speed": 70.0 + floor_no * 2.0, "radius": 20.0, "dps": 8.0 + floor_no * 0.5, "reward": 3 + floor_no, "boss": false}

func use_skill() -> void:
	if state != State.RUNNING or skill_cd > 0: return
	skill_cd = 7
	skill_flash = 0.32
	for i in range(enemies.size()):
		if player_pos.distance_to(enemies[i]["pos"]) <= 250:
			var e := enemies[i]
			e["hp"] = float(e["hp"]) - damage * 2.8
			enemies[i] = e

func apply_upgrade(index: int) -> void:
	match upgrades[index]["kind"]:
		"power": damage *= 1.25
		"lifesteal": lifesteal = minf(0.30, lifesteal + 0.05)
		"multi": extra_targets = mini(4, extra_targets + 1)
	state = State.DECISION

func continue_run() -> void:
	floor_no += 1
	hp = minf(max_hp, hp + max_hp * 0.18)
	state = State.RUNNING
	spawn_floor()

func cash_out() -> void:
	bank_coins += run_coins
	run_coins = 0
	save_progress()
	state = State.HOME

func die() -> void:
	saved_after_death = int(round(run_coins * 0.60))
	bank_coins += saved_after_death
	best_floor = maxi(best_floor, floor_no)
	save_progress()
	state = State.GAME_OVER
	joy_active = false
	joy_vector = Vector2.ZERO

func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "best_floor", best_floor)
	cfg.set_value("progress", "coins", bank_coins)
	cfg.save("user://save.cfg")

func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://save.cfg") == OK:
		best_floor = int(cfg.get_value("progress", "best_floor", 1))
		bank_coins = int(cfg.get_value("progress", "coins", 0))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		pointer(event.position, event.pressed, event.index)
	elif event is InputEventScreenDrag and joy_active and event.index == joy_id:
		move_joy(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		pointer(event.position, event.pressed, -99)
	elif event is InputEventMouseMotion and joy_active and joy_id == -99:
		move_joy(event.position)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		use_skill()

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if not pressed:
		if joy_active and id == joy_id:
			joy_active = false
			joy_vector = Vector2.ZERO
		return
	match state:
		State.HOME:
			if PLAY.has_point(pos): start_run()
		State.RUNNING:
			if SKILL.has_point(pos): use_skill()
			elif JOY_AREA.has_point(pos):
				joy_active = true
				joy_id = id
				joy_origin = pos
				joy_pos = pos
		State.UPGRADE:
			for i in range(3):
				if upgrade_rect(i).has_point(pos): apply_upgrade(i)
		State.DECISION:
			if CASH.has_point(pos): cash_out()
			elif NEXT.has_point(pos): continue_run()
		State.GAME_OVER:
			if RETRY.has_point(pos): start_run()
			elif HOME.has_point(pos): state = State.HOME

func move_joy(pos: Vector2) -> void:
	var delta := pos - joy_origin
	if delta.length() > 74: delta = delta.normalized() * 74
	joy_pos = joy_origin + delta
	joy_vector = delta / 74

func upgrade_rect(i: int) -> Rect2:
	return Rect2(68, 410 + i * 155, 584, 126)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), C_BG)
	if state == State.HOME: draw_home()
	elif state == State.RUNNING: draw_game()
	elif state == State.UPGRADE: draw_upgrade()
	elif state == State.DECISION: draw_decision()
	else: draw_game_over()

func draw_home() -> void:
	draw_circle(Vector2(360, 360), 230, Color(0.28, 0.12, 0.50, 0.18))
	draw_rect(Rect2(285, 280, 150, 330), Color("11152d"))
	draw_center("ONE MORE", 260, 58, C_TEXT)
	draw_center("FLOOR", 342, 94, C_GOLD)
	draw_center("Climb. Loot. Risk it all.", 420, 22, C_MUTED)
	panel(Rect2(52, 80, 180, 82), C_PANEL, C_PURPLE)
	text("BEST FLOOR", Vector2(72, 112), 18, C_MUTED)
	text(str(best_floor), Vector2(74, 150), 34, C_TEXT)
	panel(Rect2(488, 80, 180, 82), C_PANEL, C_GOLD)
	text("COINS", Vector2(510, 112), 18, C_MUTED)
	text(str(bank_coins), Vector2(510, 150), 30, C_GOLD)
	button(PLAY, "PLAY", C_GOLD, 38)
	var labels := ["HEROES", "SHOP", "MISSIONS", "SETTINGS"]
	for i in range(4):
		var r := Rect2(34 + i * 168, 1060, 148, 112)
		panel(r, C_PANEL, Color("3d456f"))
		center_rect(labels[i], r, 17, C_TEXT)
	draw_center("Prototype v0.1 • Kamilunavo Games", 1230, 16, C_MUTED)

func draw_game() -> void:
	draw_rect(ARENA, Color("0b1225"))
	for x in range(40, 690, 54): draw_line(Vector2(x, 160), Vector2(x, 1000), Color(0.3, 0.3, 0.5, 0.16), 1)
	for y in range(160, 1010, 54): draw_line(Vector2(36, y), Vector2(684, y), Color(0.3, 0.3, 0.5, 0.16), 1)
	for e in enemies:
		var p: Vector2 = e["pos"]
		var radius := float(e["radius"])
		draw_circle(p, radius, Color("a43d55") if e["boss"] else Color("5b9459"))
		draw_circle(p + Vector2(-7, -6), 3, C_TEXT)
		draw_circle(p + Vector2(7, -6), 3, C_TEXT)
		var ratio := clampf(float(e["hp"]) / float(e["max_hp"]), 0, 1)
		draw_rect(Rect2(p.x - radius, p.y - radius - 15, radius * 2, 6), Color("381726"))
		draw_rect(Rect2(p.x - radius, p.y - radius - 15, radius * 2 * ratio, 6), C_RED)
	draw_circle(player_pos, 24, Color("343e70"))
	draw_circle(player_pos + Vector2(0, -10), 11, Color("d7aa80"))
	draw_line(player_pos + Vector2(15, 0), player_pos + Vector2(46, -30), C_GOLD, 6)
	if hit_flash > 0: draw_line(hit_from, hit_to, C_GOLD, 5)
	if skill_flash > 0:
		var radius := lerpf(40, 250, 1.0 - skill_flash / 0.32)
		draw_arc(player_pos, radius, 0, TAU, 64, C_BLUE, 8)
	panel(Rect2(34, 34, 652, 104), Color("0b1025"), Color("343d6b"))
	text("FLOOR %d" % floor_no, Vector2(58, 86), 34, C_TEXT)
	text("%d coins" % run_coins, Vector2(540, 86), 24, C_GOLD)
	var hp_box := Rect2(110, 1018, 430, 28)
	draw_rect(hp_box, Color("321824"))
	draw_rect(Rect2(hp_box.position, Vector2(hp_box.size.x * clampf(hp / max_hp, 0, 1), 28)), C_RED)
	center_rect("%d / %d HP" % [int(hp), int(max_hp)], hp_box, 16, C_TEXT)
	var base := joy_origin if joy_active else Vector2(145, 1115)
	var knob := joy_pos if joy_active else base
	draw_circle(base, 78, Color(0.3, 0.32, 0.5, 0.36))
	draw_circle(knob, 36, Color(0.58, 0.60, 0.8, 0.65))
	draw_circle(SKILL.get_center(), 58, Color("172954"))
	draw_arc(SKILL.get_center(), 58, 0, TAU, 48, C_BLUE if skill_cd <= 0 else Color("4a5070"), 5)
	center_rect("NOVA" if skill_cd <= 0 else "%.1f" % skill_cd, SKILL, 18, C_TEXT)

func draw_upgrade() -> void:
	draw_center("FLOOR CLEARED!", 170, 46, C_GOLD)
	draw_center("Choose an Upgrade", 235, 30, C_TEXT)
	for i in range(3):
		var r := upgrade_rect(i)
		var u = upgrades[i]
		panel(r, C_PANEL, u["color"])
		text(u["name"], r.position + Vector2(34, 52), 25, C_TEXT)
		text(u["desc"], r.position + Vector2(34, 90), 18, C_MUTED)

func draw_decision() -> void:
	draw_center("TAKE THE LOOT?", 200, 44, C_TEXT)
	draw_center("OR", 258, 20, C_MUTED)
	draw_center("ONE MORE FLOOR", 330, 52, C_GOLD)
	panel(Rect2(118, 420, 484, 230), C_PANEL, Color("3d456f"))
	draw_center("RUN LOOT", 468, 18, C_MUTED)
	draw_center("%d COINS" % run_coins, 542, 48, C_GOLD)
	draw_center("Floor %d cleared" % floor_no, 600, 22, C_TEXT)
	button(CASH, "CASH OUT", C_GREEN, 24)
	button(NEXT, "ONE MORE FLOOR", C_GOLD, 22)
	draw_center("Death keeps only 60% of unsecured coins.", 1040, 18, C_MUTED)

func draw_game_over() -> void:
	draw_center("RUN ENDED", 230, 54, C_RED)
	draw_center("The tower wins this time.", 292, 22, C_MUTED)
	panel(Rect2(118, 410, 484, 260), C_PANEL, C_PURPLE)
	draw_center("FLOOR %d" % floor_no, 510, 46, C_TEXT)
	draw_center("%d coins secured" % saved_after_death, 590, 26, C_GOLD)
	button(RETRY, "RETRY", C_GOLD, 28)
	button(HOME, "HOME", C_PURPLE, 28)

func panel(r: Rect2, fill: Color, border: Color) -> void:
	draw_rect(r, fill)
	draw_rect(r, border, false, 2)

func button(r: Rect2, label: String, accent: Color, size: int) -> void:
	panel(r, Color(accent, 0.18), accent)
	center_rect(label, r, size, C_TEXT)

func text(value: String, pos: Vector2, size: int, color: Color) -> void:
	draw_string(font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func draw_center(value: String, y: float, size: int, color: Color) -> void:
	draw_string(font, Vector2(40, y), value, HORIZONTAL_ALIGNMENT_CENTER, 640, size, color)

func center_rect(value: String, r: Rect2, size: int, color: Color) -> void:
	var y := r.position.y + r.size.y * 0.5 + size * 0.34
	draw_string(font, Vector2(r.position.x, y), value, HORIZONTAL_ALIGNMENT_CENTER, r.size.x, size, color)
