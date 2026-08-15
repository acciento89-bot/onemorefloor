extends Node2D

enum State { HOME, RUNNING, UPGRADE, DECISION, GAME_OVER }

const SIZE := Vector2(720, 1280)
const ARENA := Rect2(36, 160, 648, 840)
const PLAY := Rect2(180, 816, 360, 96)
const SKILL := Rect2(548, 1040, 120, 120)
const JOY_AREA := Rect2(24, 930, 350, 310)
const CASH := Rect2(72, 880, 264, 92)
const NEXT := Rect2(384, 880, 264, 92)
const RETRY := Rect2(72, 900, 264, 92)
const HOME_BTN := Rect2(384, 900, 264, 92)

const C_BG := Color("07101f")
const C_PANEL := Color("171c38")
const C_PANEL_2 := Color("0e1630")
const C_GOLD := Color("f1b84b")
const C_PURPLE := Color("9a5cff")
const C_BLUE := Color("53b9ff")
const C_GREEN := Color("67e58e")
const C_RED := Color("ff5f69")
const C_TEXT := Color("f6f2ff")
const C_MUTED := Color("aaa8c7")
const C_ORANGE := Color("ff9b52")
const C_CYAN := Color("62e6ff")

const UPGRADE_POOL := [
	{"name":"POWER SURGE","desc":"+25% attack damage","kind":"power","color":C_GOLD},
	{"name":"BLOOD PACT","desc":"+5% lifesteal","kind":"lifesteal","color":C_RED},
	{"name":"MULTISHOT","desc":"+1 auto-attack projectile","kind":"multi","color":C_PURPLE},
	{"name":"QUICK HANDS","desc":"+18% attack speed","kind":"haste","color":C_CYAN},
	{"name":"LONG REACH","desc":"+22% attack range","kind":"range","color":C_BLUE},
	{"name":"IRON HEART","desc":"+25 max HP and heal 25","kind":"vitality","color":C_GREEN},
	{"name":"SWIFT BOOTS","desc":"+12% move speed","kind":"speed","color":C_ORANGE},
	{"name":"DEADLY EDGE","desc":"+8% critical chance","kind":"crit","color":C_GOLD},
	{"name":"NOVA CORE","desc":"+25% NOVA damage and radius","kind":"nova","color":C_BLUE},
	{"name":"WARDEN'S PLATE","desc":"+8% damage reduction","kind":"armor","color":C_PURPLE},
]

var state := State.HOME
var rng := RandomNumberGenerator.new()
var font: Font
var elapsed := 0.0

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
var crit_chance := 0.08
var crit_mult := 1.75
var armor := 0.0
var nova_mult := 2.8
var nova_radius := 250.0

var enemies: Array[Dictionary] = []
var player_shots: Array[Dictionary] = []
var enemy_shots: Array[Dictionary] = []
var damage_numbers: Array[Dictionary] = []
var coin_orbs: Array[Dictionary] = []
var effects: Array[Dictionary] = []
var upgrade_options: Array[Dictionary] = []

var joy_active := false
var joy_id := -1
var joy_origin := Vector2.ZERO
var joy_pos := Vector2.ZERO
var joy_vector := Vector2.ZERO

var skill_cd := 0.0
var skill_flash := 0.0
var screen_shake := 0.0
var floor_banner := 0.0
var haptics_enabled := true

func _ready() -> void:
	rng.randomize()
	font = ThemeDB.fallback_font
	load_progress()
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	skill_flash = maxf(0.0, skill_flash - delta)
	screen_shake = maxf(0.0, screen_shake - delta * 24.0)
	floor_banner = maxf(0.0, floor_banner - delta)
	update_visual_fx(delta)
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
	if keys.length_squared() > 0:
		move = keys.normalized()

	player_pos += move * speed * delta
	player_pos.x = clampf(player_pos.x, ARENA.position.x + 26, ARENA.end.x - 26)
	player_pos.y = clampf(player_pos.y, ARENA.position.y + 26, ARENA.end.y - 26)

	update_enemies(delta)
	update_player_shots(delta)
	update_enemy_shots(delta)
	update_coin_orbs(delta)

	if hp <= 0:
		die()
		return

	attack_timer -= delta
	if attack_timer <= 0:
		fire_auto_attack()
		attack_timer = attack_delay

	skill_cd = maxf(0.0, skill_cd - delta)
	remove_dead()

	if enemies.is_empty() and coin_orbs.is_empty():
		best_floor = maxi(best_floor, floor_no)
		save_progress()
		roll_upgrade_options()
		state = State.UPGRADE

func update_enemies(delta: float) -> void:
	for i in range(enemies.size()):
		var e := enemies[i]
		e["touch_cd"] = maxf(0.0, float(e["touch_cd"]) - delta)
		e["attack_cd"] = maxf(0.0, float(e["attack_cd"]) - delta)
		var p: Vector2 = e["pos"]
		var to_player := player_pos - p
		var dist := to_player.length()
		var kind := String(e["type"])

		if kind == "goblin":
			if dist > 1.0:
				p += to_player / dist * float(e["speed"]) * delta

		elif kind == "bat":
			if dist > 1.0:
				var wobble := Vector2(-to_player.y, to_player.x).normalized() * sin(elapsed * 8.0 + float(e["phase"])) * 0.35
				p += (to_player.normalized() + wobble).normalized() * float(e["speed"]) * delta

		elif kind == "skeleton":
			if dist < 185.0 and dist > 1.0:
				p -= to_player.normalized() * float(e["speed"]) * delta
			elif dist > 300.0 and dist > 1.0:
				p += to_player.normalized() * float(e["speed"]) * delta
			if float(e["attack_cd"]) <= 0.0 and dist < 430.0:
				spawn_enemy_projectile(p, player_pos, 12.0 + floor_no * 0.65, 265.0, C_CYAN)
				e["attack_cd"] = 1.55

		elif kind == "warden":
			if dist > 128.0 and dist > 1.0:
				p += to_player.normalized() * float(e["speed"]) * delta
			if float(e["attack_cd"]) <= 0.0:
				warden_attack(p)
				e["attack_cd"] = maxf(1.25, 2.45 - floor_no * 0.025)

		e["pos"] = clamp_to_arena(p, float(e["radius"]))

		if dist < 34.0 + float(e["radius"]) and float(e["touch_cd"]) <= 0.0:
			var touch_damage := float(e["touch_damage"])
			damage_player(touch_damage, e["pos"])
			e["touch_cd"] = 0.62

		enemies[i] = e

func update_player_shots(delta: float) -> void:
	for i in range(player_shots.size() - 1, -1, -1):
		var shot := player_shots[i]
		shot["life"] = float(shot["life"]) - delta
		shot["pos"] = Vector2(shot["pos"]) + Vector2(shot["vel"]) * delta
		var hit := false
		for j in range(enemies.size()):
			var e := enemies[j]
			if Vector2(shot["pos"]).distance_to(Vector2(e["pos"])) <= float(e["radius"]) + 10.0:
				apply_damage_to_enemy(j, float(shot["damage"]), bool(shot["crit"]), Vector2(shot["pos"]))
				hit = true
				break
		if hit or float(shot["life"]) <= 0.0 or not ARENA.grow(80).has_point(Vector2(shot["pos"])):
			player_shots.remove_at(i)
		else:
			player_shots[i] = shot

func update_enemy_shots(delta: float) -> void:
	for i in range(enemy_shots.size() - 1, -1, -1):
		var shot := enemy_shots[i]
		shot["life"] = float(shot["life"]) - delta
		shot["pos"] = Vector2(shot["pos"]) + Vector2(shot["vel"]) * delta
		if Vector2(shot["pos"]).distance_to(player_pos) <= 28.0:
			damage_player(float(shot["damage"]), Vector2(shot["pos"]))
			enemy_shots.remove_at(i)
		elif float(shot["life"]) <= 0.0 or not ARENA.grow(70).has_point(Vector2(shot["pos"])):
			enemy_shots.remove_at(i)
		else:
			enemy_shots[i] = shot

func update_visual_fx(delta: float) -> void:
	for i in range(damage_numbers.size() - 1, -1, -1):
		var d := damage_numbers[i]
		d["age"] = float(d["age"]) + delta
		d["pos"] = Vector2(d["pos"]) + Vector2(0, -42) * delta
		if float(d["age"]) >= float(d["dur"]):
			damage_numbers.remove_at(i)
		else:
			damage_numbers[i] = d

	for i in range(effects.size() - 1, -1, -1):
		var fx := effects[i]
		fx["age"] = float(fx["age"]) + delta
		if float(fx["age"]) >= float(fx["dur"]):
			effects.remove_at(i)
		else:
			effects[i] = fx

func update_coin_orbs(delta: float) -> void:
	var target := Vector2(610, 86)
	for i in range(coin_orbs.size() - 1, -1, -1):
		var orb := coin_orbs[i]
		orb["age"] = float(orb["age"]) + delta
		var p: Vector2 = orb["pos"]
		if float(orb["age"]) > 0.20:
			var to_target := target - p
			if to_target.length() < 22.0:
				run_coins += int(orb["value"])
				effects.append({"type":"coin","pos":target,"age":0.0,"dur":0.20,"color":C_GOLD})
				coin_orbs.remove_at(i)
				continue
			p += to_target.normalized() * minf(950.0 * delta, to_target.length())
		else:
			p.y -= 24.0 * delta
		orb["pos"] = p
		coin_orbs[i] = orb

func fire_auto_attack() -> void:
	var used: Array[int] = []
	for n in range(1 + extra_targets):
		var idx := nearest_enemy(used)
		if idx == -1:
			break
		used.append(idx)
		var e := enemies[idx]
		var target: Vector2 = e["pos"]
		var crit := rng.randf() < crit_chance
		var shot_damage := damage * (crit_mult if crit else 1.0)
		var spread := (float(n) - float(extra_targets) * 0.5) * 0.06
		var dir := (target - player_pos).normalized().rotated(spread)
		player_shots.append({
			"pos": player_pos + dir * 28.0,
			"vel": dir * 720.0,
			"damage": shot_damage,
			"life": 0.60,
			"crit": crit
		})
		effects.append({"type":"slash","pos":player_pos,"dir":dir,"age":0.0,"dur":0.12,"color":C_GOLD})

func nearest_enemy(ignore: Array[int]) -> int:
	var best := -1
	var best_dist := attack_range + 1.0
	for i in range(enemies.size()):
		if i in ignore:
			continue
		var dist := player_pos.distance_to(Vector2(enemies[i]["pos"]))
		if dist <= attack_range and dist < best_dist:
			best = i
			best_dist = dist
	return best

func apply_damage_to_enemy(index: int, amount: float, crit: bool, hit_pos: Vector2) -> void:
	if index < 0 or index >= enemies.size():
		return
	var e := enemies[index]
	e["hp"] = float(e["hp"]) - amount
	enemies[index] = e
	if lifesteal > 0.0:
		hp = minf(max_hp, hp + amount * lifesteal)
	add_damage_popup(hit_pos, amount, crit, C_GOLD if crit else C_TEXT)
	effects.append({"type":"hit","pos":hit_pos,"age":0.0,"dur":0.16,"color":C_GOLD if crit else C_TEXT})
	screen_shake = maxf(screen_shake, 4.0 if crit else 1.5)
	if crit:
		haptic(16)

func damage_player(raw_damage: float, source: Vector2) -> void:
	var dealt := maxf(1.0, raw_damage * (1.0 - armor))
	hp -= dealt
	add_damage_popup(player_pos + Vector2(0, -34), dealt, false, C_RED)
	effects.append({"type":"hurt","pos":player_pos,"age":0.0,"dur":0.20,"color":C_RED})
	screen_shake = maxf(screen_shake, 7.0)
	haptic(28)
	if source != player_pos:
		var push := (player_pos - source).normalized() * 8.0
		player_pos = clamp_to_arena(player_pos + push, 26.0)

func add_damage_popup(pos: Vector2, amount: float, crit: bool, color: Color) -> void:
	damage_numbers.append({
		"pos": pos,
		"value": int(round(amount)),
		"crit": crit,
		"age": 0.0,
		"dur": 0.62,
		"color": color
	})

func remove_dead() -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if float(enemies[i]["hp"]) <= 0.0:
			var e := enemies[i]
			var reward := int(e["reward"])
			coin_orbs.append({"pos":Vector2(e["pos"]), "value":reward, "age":0.0})
			effects.append({"type":"burst","pos":Vector2(e["pos"]),"age":0.0,"dur":0.30,"color":enemy_color(String(e["type"]))})
			if String(e["type"]) == "warden":
				screen_shake = 12.0
				haptic(80)
			enemies.remove_at(i)

func start_run() -> void:
	floor_no = 1
	run_coins = 0
	hp = 100.0
	max_hp = 100.0
	speed = 285.0
	damage = 27.0
	attack_delay = 0.48
	attack_range = 225.0
	lifesteal = 0.0
	extra_targets = 0
	crit_chance = 0.08
	crit_mult = 1.75
	armor = 0.0
	nova_mult = 2.8
	nova_radius = 250.0
	skill_cd = 0.0
	attack_timer = 0.12
	player_pos = Vector2(360, 700)
	player_shots.clear()
	enemy_shots.clear()
	damage_numbers.clear()
	coin_orbs.clear()
	effects.clear()
	state = State.RUNNING
	spawn_floor()

func spawn_floor() -> void:
	enemies.clear()
	player_shots.clear()
	enemy_shots.clear()
	coin_orbs.clear()
	player_pos = Vector2(360, 700)
	floor_banner = 1.25

	if floor_no % 5 == 0:
		enemies.append(make_enemy("warden"))
		var escorts := mini(4, 1 + int(floor_no / 10))
		for i in range(escorts):
			enemies.append(make_enemy("bat" if i % 2 == 0 else "goblin"))
		return

	var count := mini(12, 3 + floor_no)
	for i in range(count):
		var roll := rng.randf()
		if floor_no < 2:
			enemies.append(make_enemy("goblin"))
		elif floor_no < 3:
			enemies.append(make_enemy("goblin" if roll < 0.72 else "bat"))
		else:
			if roll < 0.46:
				enemies.append(make_enemy("goblin"))
			elif roll < 0.73:
				enemies.append(make_enemy("bat"))
			else:
				enemies.append(make_enemy("skeleton"))

func make_enemy(kind: String) -> Dictionary:
	var pos := random_spawn_pos()
	var base_hp := 42.0 + floor_no * 10.0
	if kind == "goblin":
		return {
			"type":"goblin","pos":pos,"hp":base_hp,"max_hp":base_hp,
			"speed":80.0 + floor_no * 1.4,"radius":22.0,
			"touch_damage":9.0 + floor_no * 0.55,"reward":4 + floor_no,
			"touch_cd":0.0,"attack_cd":0.0,"phase":rng.randf_range(0.0, TAU)
		}
	if kind == "bat":
		var bat_hp := base_hp * 0.66
		return {
			"type":"bat","pos":pos,"hp":bat_hp,"max_hp":bat_hp,
			"speed":132.0 + floor_no * 1.7,"radius":17.0,
			"touch_damage":7.0 + floor_no * 0.45,"reward":3 + floor_no,
			"touch_cd":0.0,"attack_cd":0.0,"phase":rng.randf_range(0.0, TAU)
		}
	if kind == "skeleton":
		var sk_hp := base_hp * 0.86
		return {
			"type":"skeleton","pos":pos,"hp":sk_hp,"max_hp":sk_hp,
			"speed":66.0 + floor_no * 1.1,"radius":20.0,
			"touch_damage":8.0 + floor_no * 0.42,"reward":5 + floor_no,
			"touch_cd":0.0,"attack_cd":rng.randf_range(0.35, 1.1),"phase":rng.randf_range(0.0, TAU)
		}
	var boss_hp := 310.0 + floor_no * 48.0
	return {
		"type":"warden","pos":pos,"hp":boss_hp,"max_hp":boss_hp,
		"speed":62.0 + floor_no * 0.5,"radius":48.0,
		"touch_damage":22.0 + floor_no * 0.8,"reward":70 + floor_no * 7,
		"touch_cd":0.0,"attack_cd":1.15,"phase":rng.randf_range(0.0, TAU)
	}

func random_spawn_pos() -> Vector2:
	var pos := Vector2(rng.randf_range(88, 632), rng.randf_range(220, 920))
	var guard := 0
	while pos.distance_to(player_pos) < 245.0 and guard < 20:
		pos = Vector2(rng.randf_range(88, 632), rng.randf_range(220, 920))
		guard += 1
	return pos

func spawn_enemy_projectile(from: Vector2, toward: Vector2, projectile_damage: float, projectile_speed: float, color: Color) -> void:
	var dir := (toward - from).normalized()
	enemy_shots.append({
		"pos":from,
		"vel":dir * projectile_speed,
		"damage":projectile_damage,
		"life":2.2,
		"color":color
	})

func warden_attack(pos: Vector2) -> void:
	effects.append({"type":"warden_cast","pos":pos,"age":0.0,"dur":0.42,"color":C_PURPLE})
	var count := 10
	var offset := rng.randf_range(0.0, TAU)
	for i in range(count):
		var angle := offset + TAU * float(i) / float(count)
		var dir := Vector2.from_angle(angle)
		enemy_shots.append({
			"pos":pos + dir * 42.0,
			"vel":dir * (185.0 + floor_no * 2.0),
			"damage":13.0 + floor_no * 0.8,
			"life":3.4,
			"color":C_PURPLE
		})
	screen_shake = maxf(screen_shake, 3.0)

func use_skill() -> void:
	if state != State.RUNNING or skill_cd > 0.0:
		return
	skill_cd = 7.0
	skill_flash = 0.36
	screen_shake = 8.0
	haptic(38)
	effects.append({"type":"nova","pos":player_pos,"age":0.0,"dur":0.38,"color":C_BLUE})
	for i in range(enemies.size()):
		if player_pos.distance_to(Vector2(enemies[i]["pos"])) <= nova_radius:
			apply_damage_to_enemy(i, damage * nova_mult, false, Vector2(enemies[i]["pos"]))
	for i in range(enemy_shots.size() - 1, -1, -1):
		if player_pos.distance_to(Vector2(enemy_shots[i]["pos"])) <= nova_radius:
			enemy_shots.remove_at(i)

func roll_upgrade_options() -> void:
	upgrade_options.clear()
	var available: Array[int] = []
	for i in range(UPGRADE_POOL.size()):
		available.append(i)
	while upgrade_options.size() < 3 and not available.is_empty():
		var pick_pos := rng.randi_range(0, available.size() - 1)
		var pick := available[pick_pos]
		available.remove_at(pick_pos)
		upgrade_options.append(UPGRADE_POOL[pick])

func apply_upgrade(index: int) -> void:
	if index < 0 or index >= upgrade_options.size():
		return
	var u := upgrade_options[index]
	match String(u["kind"]):
		"power":
			damage *= 1.25
		"lifesteal":
			lifesteal = minf(0.30, lifesteal + 0.05)
		"multi":
			extra_targets = mini(4, extra_targets + 1)
		"haste":
			attack_delay = maxf(0.18, attack_delay * 0.82)
		"range":
			attack_range *= 1.22
		"vitality":
			max_hp += 25.0
			hp = minf(max_hp, hp + 25.0)
		"speed":
			speed *= 1.12
		"crit":
			crit_chance = minf(0.50, crit_chance + 0.08)
		"nova":
			nova_mult *= 1.25
			nova_radius = minf(390.0, nova_radius * 1.25)
		"armor":
			armor = minf(0.40, armor + 0.08)
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
	haptic(110)

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

func haptic(duration_ms: int) -> void:
	if haptics_enabled:
		Input.vibrate_handheld(duration_ms)

func clamp_to_arena(pos: Vector2, radius: float) -> Vector2:
	return Vector2(
		clampf(pos.x, ARENA.position.x + radius, ARENA.end.x - radius),
		clampf(pos.y, ARENA.position.y + radius, ARENA.end.y - radius)
	)

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
			if PLAY.has_point(pos):
				start_run()
		State.RUNNING:
			if SKILL.has_point(pos):
				use_skill()
			elif JOY_AREA.has_point(pos):
				joy_active = true
				joy_id = id
				joy_origin = pos
				joy_pos = pos
		State.UPGRADE:
			for i in range(3):
				if upgrade_rect(i).has_point(pos):
					apply_upgrade(i)
		State.DECISION:
			if CASH.has_point(pos):
				cash_out()
			elif NEXT.has_point(pos):
				continue_run()
		State.GAME_OVER:
			if RETRY.has_point(pos):
				start_run()
			elif HOME_BTN.has_point(pos):
				state = State.HOME

func move_joy(pos: Vector2) -> void:
	var delta := pos - joy_origin
	if delta.length() > 74.0:
		delta = delta.normalized() * 74.0
	joy_pos = joy_origin + delta
	joy_vector = delta / 74.0

func upgrade_rect(i: int) -> Rect2:
	return Rect2(68, 390 + i * 166, 584, 138)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), C_BG)
	match state:
		State.HOME:
			draw_home()
		State.RUNNING:
			draw_game()
		State.UPGRADE:
			draw_upgrade()
		State.DECISION:
			draw_decision()
		State.GAME_OVER:
			draw_game_over()

func draw_home() -> void:
	draw_circle(Vector2(360, 350), 260, Color(0.28, 0.12, 0.50, 0.18))
	draw_circle(Vector2(360, 350), 180, Color(0.45, 0.16, 0.72, 0.12))
	draw_tower(Vector2(360, 470))
	draw_center("ONE MORE", 212, 54, C_TEXT)
	draw_center("FLOOR", 292, 92, C_GOLD)
	draw_center("Climb. Loot. Risk it all.", 350, 20, C_MUTED)

	panel(Rect2(40, 64, 190, 82), C_PANEL, C_PURPLE)
	text("BEST FLOOR", Vector2(58, 98), 17, C_MUTED)
	text(str(best_floor), Vector2(60, 134), 32, C_TEXT)
	panel(Rect2(490, 64, 190, 82), C_PANEL, C_GOLD)
	text("BANK", Vector2(512, 98), 17, C_MUTED)
	text("%d" % bank_coins, Vector2(512, 134), 30, C_GOLD)

	draw_wanderer(Vector2(360, 655), 1.35, false)
	button(PLAY, "PLAY", C_GOLD, 38)

	var menu := [
		{"label":"HERO","color":C_BLUE},
		{"label":"FORGE","color":C_ORANGE},
		{"label":"TALENTS","color":C_PURPLE},
		{"label":"VAULT","color":C_GOLD},
	]
	for i in range(menu.size()):
		var r := Rect2(28 + i * 171, 1030, 151, 104)
		panel(r, C_PANEL, menu[i]["color"])
		center_rect(menu[i]["label"], r, 17, C_TEXT)

	panel(Rect2(38, 1164, 644, 64), C_PANEL_2, Color("343d6b"))
	text("TOWER PASS", Vector2(62, 1203), 17, C_MUTED)
	draw_rect(Rect2(190, 1185, 410, 14), Color("252846"))
	draw_rect(Rect2(190, 1185, 205, 14), C_PURPLE)
	text("v0.2 COMBAT SLICE", Vector2(486, 1203), 14, C_TEXT)
	draw_center("Kamilunavo Games", 1258, 14, C_MUTED)

func draw_tower(center: Vector2) -> void:
	draw_rect(Rect2(center.x - 78, center.y - 160, 156, 250), Color("11162f"))
	draw_rect(Rect2(center.x - 54, center.y - 205, 108, 55), Color("181a3a"))
	draw_polygon(
		PackedVector2Array([
			Vector2(center.x - 70, center.y - 205),
			Vector2(center.x, center.y - 275),
			Vector2(center.x + 70, center.y - 205)
		]),
		PackedColorArray([Color("1b1c43")])
	)
	draw_circle(Vector2(center.x, center.y - 190), 22, C_PURPLE)
	for row in range(3):
		for col in range(2):
			var p := Vector2(center.x - 35 + col * 70, center.y - 110 + row * 62)
			draw_rect(Rect2(p.x - 10, p.y - 18, 20, 34), Color("f19f4b"))

func draw_game() -> void:
	var shake_offset := Vector2.ZERO
	if screen_shake > 0.0:
		shake_offset = Vector2(rng.randf_range(-screen_shake, screen_shake), rng.randf_range(-screen_shake, screen_shake))
	draw_set_transform(shake_offset)

	draw_rect(ARENA, Color("0b1225"))
	for x in range(40, 690, 54):
		draw_line(Vector2(x, 160), Vector2(x, 1000), Color(0.3, 0.3, 0.5, 0.16), 1)
	for y in range(160, 1010, 54):
		draw_line(Vector2(36, y), Vector2(684, y), Color(0.3, 0.3, 0.5, 0.16), 1)

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
		var alpha := clampf(1.0 - float(d["age"]) / float(d["dur"]), 0.0, 1.0)
		var c: Color = d["color"]
		c.a = alpha
		var fs := 25 if bool(d["crit"]) else 19
		draw_string(font, Vector2(d["pos"]) + Vector2(-28, 0), ("CRIT %d" if bool(d["crit"]) else "%d") % int(d["value"]), HORIZONTAL_ALIGNMENT_CENTER, 70, fs, c)

	draw_set_transform(Vector2.ZERO)

	panel(Rect2(34, 34, 652, 104), Color("0b1025"), Color("343d6b"))
	text("FLOOR %d" % floor_no, Vector2(58, 86), 34, C_TEXT)
	var floor_type := "WARDEN" if floor_no % 5 == 0 else "DUNGEON"
	text(floor_type, Vector2(58, 118), 14, C_MUTED)
	text("%d" % run_coins, Vector2(586, 86), 26, C_GOLD)

	var hp_box := Rect2(110, 1018, 430, 28)
	draw_rect(hp_box, Color("321824"))
	draw_rect(Rect2(hp_box.position, Vector2(hp_box.size.x * clampf(hp / max_hp, 0.0, 1.0), 28)), C_RED)
	center_rect("%d / %d HP" % [int(hp), int(max_hp)], hp_box, 16, C_TEXT)

	var base := joy_origin if joy_active else Vector2(145, 1115)
	var knob := joy_pos if joy_active else base
	draw_circle(base, 78, Color(0.3, 0.32, 0.5, 0.36))
	draw_circle(knob, 36, Color(0.58, 0.60, 0.8, 0.65))

	draw_circle(SKILL.get_center(), 58, Color("172954"))
	draw_arc(SKILL.get_center(), 58, 0, TAU, 48, C_BLUE if skill_cd <= 0.0 else Color("4a5070"), 5)
	center_rect("NOVA" if skill_cd <= 0.0 else "%.1f" % skill_cd, SKILL, 18, C_TEXT)

	if floor_banner > 0.0:
		var a := clampf(floor_banner, 0.0, 1.0)
		var c := C_GOLD
		c.a = a
		draw_string(font, Vector2(80, 608), "FLOOR %d" % floor_no, HORIZONTAL_ALIGNMENT_CENTER, 560, 50, c)

func draw_enemy(e: Dictionary) -> void:
	var p: Vector2 = e["pos"]
	var radius := float(e["radius"])
	var kind := String(e["type"])
	var c := enemy_color(kind)

	if kind == "goblin":
		draw_circle(p, radius, c)
		draw_polygon(
			PackedVector2Array([p + Vector2(-18,-13), p + Vector2(-8,-32), p + Vector2(-2,-12)]),
			PackedColorArray([c])
		)
		draw_polygon(
			PackedVector2Array([p + Vector2(18,-13), p + Vector2(8,-32), p + Vector2(2,-12)]),
			PackedColorArray([c])
		)
		draw_circle(p + Vector2(-7,-4), 3, C_TEXT)
		draw_circle(p + Vector2(7,-4), 3, C_TEXT)
		draw_line(p + Vector2(13,6), p + Vector2(30,18), C_ORANGE, 5)

	elif kind == "bat":
		draw_circle(p, 10, c)
		var flap := 8.0 + sin(elapsed * 13.0 + float(e["phase"])) * 6.0
		draw_polygon(
			PackedVector2Array([p + Vector2(-8,0), p + Vector2(-30,-flap), p + Vector2(-23,12), p + Vector2(-5,8)]),
			PackedColorArray([c])
		)
		draw_polygon(
			PackedVector2Array([p + Vector2(8,0), p + Vector2(30,-flap), p + Vector2(23,12), p + Vector2(5,8)]),
			PackedColorArray([c])
		)
		draw_circle(p + Vector2(-4,-2), 2, C_RED)
		draw_circle(p + Vector2(4,-2), 2, C_RED)

	elif kind == "skeleton":
		draw_circle(p + Vector2(0,-7), 15, Color("ddd9c8"))
		draw_line(p + Vector2(0,8), p + Vector2(0,26), Color("ddd9c8"), 6)
		draw_line(p + Vector2(-15,16), p + Vector2(15,16), Color("ddd9c8"), 5)
		draw_circle(p + Vector2(-5,-9), 2.5, C_BG)
		draw_circle(p + Vector2(5,-9), 2.5, C_BG)
		draw_arc(p + Vector2(20,7), 20, -1.25, 1.25, 16, C_ORANGE, 3)

	else:
		draw_circle(p, radius, Color("48214f"))
		draw_circle(p, radius - 8, c)
		draw_rect(Rect2(p.x - 32, p.y - 30, 64, 38), Color("252a47"))
		draw_polygon(
			PackedVector2Array([p + Vector2(-34,-30),p + Vector2(-22,-56),p + Vector2(-8,-34),p + Vector2(0,-62),p + Vector2(10,-34),p + Vector2(26,-55),p + Vector2(34,-30)]),
			PackedColorArray([C_GOLD])
		)
		draw_circle(p + Vector2(-12,-12), 4, C_RED)
		draw_circle(p + Vector2(12,-12), 4, C_RED)
		draw_line(p + Vector2(38,6), p + Vector2(65,30), C_PURPLE, 8)

	var ratio := clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
	var width := radius * 2.0
	draw_rect(Rect2(p.x - radius, p.y - radius - 17, width, 7), Color("381726"))
	draw_rect(Rect2(p.x - radius, p.y - radius - 17, width * ratio, 7), C_RED)

func enemy_color(kind: String) -> Color:
	match kind:
		"goblin":
			return Color("55a85d")
		"bat":
			return Color("7551ae")
		"skeleton":
			return Color("dad6c7")
		"warden":
			return Color("8d3b72")
	return C_MUTED

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	draw_circle(pos + Vector2(0, 12) * scale, 23 * scale, Color("273050"))
	draw_circle(pos + Vector2(0, -13) * scale, 15 * scale, Color("d4a47b"))
	draw_polygon(
		PackedVector2Array([
			pos + Vector2(-22, 3) * scale,
			pos + Vector2(-6, 40) * scale,
			pos + Vector2(25, 28) * scale,
			pos + Vector2(18, 0) * scale
		]),
		PackedColorArray([Color("6b2948")])
	)
	draw_line(pos + Vector2(13, 6) * scale, pos + Vector2(43, -26) * scale, C_GOLD, 5 * scale)
	draw_line(pos + Vector2(43, -26) * scale, pos + Vector2(48, -32) * scale, C_TEXT, 2 * scale)
	draw_circle(pos + Vector2(-5, -16) * scale, 2.2 * scale, C_BG)
	if combat:
		draw_arc(pos, 31 * scale, -0.7, 0.9, 18, Color(1.0, 0.75, 0.3, 0.35), 2.5 * scale)

func draw_player_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot["pos"]
	var v: Vector2 = shot["vel"]
	var dir := v.normalized()
	var c := C_GOLD if bool(shot["crit"]) else C_BLUE
	draw_line(p - dir * 20.0, p + dir * 8.0, c, 6.0 if bool(shot["crit"]) else 4.0)
	draw_circle(p, 5.0 if bool(shot["crit"]) else 3.0, C_TEXT)

func draw_enemy_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot["pos"]
	var c: Color = shot["color"]
	draw_circle(p, 8, Color(c, 0.20))
	draw_circle(p, 4, c)

func draw_coin_orb(orb: Dictionary) -> void:
	var p: Vector2 = orb["pos"]
	draw_circle(p, 9, Color(C_GOLD, 0.25))
	draw_circle(p, 5, C_GOLD)

func draw_effect(fx: Dictionary) -> void:
	var t := clampf(float(fx["age"]) / float(fx["dur"]), 0.0, 1.0)
	var p: Vector2 = fx["pos"]
	var c: Color = fx["color"]
	c.a = 1.0 - t
	match String(fx["type"]):
		"slash":
			var dir: Vector2 = fx["dir"]
			var ang := dir.angle()
			draw_arc(p, 40 + t * 18, ang - 0.8, ang + 0.8, 18, c, 5)
		"hit":
			draw_circle(p, 5 + t * 18, Color(c, 0.22 * (1.0 - t)))
			for i in range(5):
				var dir := Vector2.from_angle(TAU * float(i) / 5.0)
				draw_line(p + dir * 6, p + dir * (18 + t * 16), c, 3)
		"hurt":
			draw_circle(p, 30 + t * 24, Color(C_RED, 0.18 * (1.0 - t)))
		"burst":
			for i in range(8):
				var dir := Vector2.from_angle(TAU * float(i) / 8.0)
				draw_line(p + dir * 8, p + dir * (18 + t * 35), c, 4)
		"nova":
			draw_arc(p, lerpf(34.0, nova_radius, t), 0, TAU, 64, c, 8)
		"warden_cast":
			draw_arc(p, 48 + t * 36, 0, TAU, 48, c, 6)
		"coin":
			draw_circle(p, 12 + t * 12, Color(C_GOLD, 0.25 * (1.0 - t)))

func draw_upgrade() -> void:
	draw_center("FLOOR CLEARED!", 150, 46, C_GOLD)
	draw_center("Choose an Upgrade", 214, 30, C_TEXT)
	draw_center("Build the run. Break the tower.", 254, 18, C_MUTED)
	for i in range(upgrade_options.size()):
		var r := upgrade_rect(i)
		var u := upgrade_options[i]
		panel(r, C_PANEL, u["color"])
		draw_circle(r.position + Vector2(64, 69), 31, Color(u["color"], 0.18))
		draw_circle(r.position + Vector2(64, 69), 18, u["color"])
		text(u["name"], r.position + Vector2(112, 58), 25, C_TEXT)
		text(u["desc"], r.position + Vector2(112, 96), 18, C_MUTED)
	draw_center("Tap an upgrade to continue.", 982, 16, C_MUTED)

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
	button(HOME_BTN, "HOME", C_PURPLE, 28)

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
