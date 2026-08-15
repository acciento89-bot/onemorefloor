extends Node2D

const Progression = preload("res://scripts/progression.gd")
const RunProfile = preload("res://scripts/run_profile.gd")
const EnemyFactory = preload("res://scripts/enemy_factory.gd")

enum State { HOME, HERO, FORGE, TALENTS, VAULT, RUNNING, UPGRADE, DECISION, GAME_OVER }

const SIZE := Vector2(720, 1280)
const ARENA := Rect2(36, 160, 648, 840)
const PLAY := Rect2(180, 816, 360, 96)
const SKILL := Rect2(548, 1040, 120, 120)
const JOY_AREA := Rect2(24, 930, 350, 310)
const CASH := Rect2(72, 880, 264, 92)
const NEXT := Rect2(384, 880, 264, 92)
const RETRY := Rect2(72, 900, 264, 92)
const HOME_BTN := Rect2(384, 900, 264, 92)
const META_BACK := Rect2(36, 1160, 170, 62)
const META_BUY := Rect2(390, 840, 260, 82)
const HERO_TAB := Rect2(28, 1030, 151, 104)
const FORGE_TAB := Rect2(199, 1030, 151, 104)
const TALENTS_TAB := Rect2(370, 1030, 151, 104)
const VAULT_TAB := Rect2(541, 1030, 151, 104)

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
var meta
var run

var player_pos := Vector2(360, 700)
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
var skill_flash := 0.0
var screen_shake := 0.0
var floor_banner := 0.0
var haptics_enabled := true
var meta_notice := ""
var meta_notice_time := 0.0

func _ready() -> void:
	rng.randomize()
	font = ThemeDB.fallback_font
	meta = Progression.new()
	run = RunProfile.new()
	meta.load_data()
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	skill_flash = maxf(0.0, skill_flash - delta)
	screen_shake = maxf(0.0, screen_shake - delta * 24.0)
	floor_banner = maxf(0.0, floor_banner - delta)
	meta_notice_time = maxf(0.0, meta_notice_time - delta)
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
	if keys.length_squared() > 0.0:
		move = keys.normalized()
	player_pos += move * run.speed * delta
	player_pos = clamp_to_arena(player_pos, 26.0)

	update_enemies(delta)
	update_player_shots(delta)
	update_enemy_shots(delta)
	update_coin_orbs(delta)
	if run.hp <= 0.0:
		die()
		return

	run.attack_timer -= delta
	if run.attack_timer <= 0.0:
		fire_auto_attack()
		run.attack_timer = run.attack_delay
	run.skill_cd = maxf(0.0, run.skill_cd - delta)
	remove_dead()

	if enemies.is_empty() and coin_orbs.is_empty():
		meta.best_floor = maxi(meta.best_floor, run.floor_no)
		meta.save_data()
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
			if dist > 1.0: p += to_player.normalized() * float(e["speed"]) * delta
		elif kind == "bat":
			if dist > 1.0:
				var wobble := Vector2(-to_player.y, to_player.x).normalized() * sin(elapsed * 8.0 + float(e["phase"])) * 0.35
				p += (to_player.normalized() + wobble).normalized() * float(e["speed"]) * delta
		elif kind == "skeleton":
			if dist < 185.0 and dist > 1.0: p -= to_player.normalized() * float(e["speed"]) * delta
			elif dist > 300.0 and dist > 1.0: p += to_player.normalized() * float(e["speed"]) * delta
			if float(e["attack_cd"]) <= 0.0 and dist < 430.0:
				spawn_enemy_projectile(p, player_pos, 12.0 + run.floor_no * 0.65, 265.0, C_CYAN)
				e["attack_cd"] = 1.55
		elif kind == "warden":
			update_warden(e, p, to_player, dist, delta)
			p = e["pos"]

		if kind != "warden":
			e["pos"] = clamp_to_arena(p, float(e["radius"]))
		if dist < 34.0 + float(e["radius"]) and float(e["touch_cd"]) <= 0.0:
			damage_player(float(e["touch_damage"]), e["pos"])
			e["touch_cd"] = 0.62
		enemies[i] = e

func update_warden(e: Dictionary, p: Vector2, to_player: Vector2, dist: float, delta: float) -> void:
	var hp_ratio := clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
	if hp_ratio <= 0.50 and not bool(e["phase2"]):
		e["phase2"] = true
		e["attack_cd"] = 0.45
		effects.append({"type":"phase2","pos":p,"age":0.0,"dur":0.75,"color":C_RED,"kind":""})
		screen_shake = 13.0
		haptic(75)

	if float(e["cast_timer"]) > 0.0:
		e["cast_timer"] = maxf(0.0, float(e["cast_timer"]) - delta)
		if float(e["cast_timer"]) <= 0.0:
			execute_warden_cast(e)
			e["cast_kind"] = ""
			e["attack_cd"] = 1.25 if bool(e["phase2"]) else 1.85
		return

	if float(e["attack_cd"]) <= 0.0:
		var idx := int(e["attack_index"])
		var cast_kind := "ring"
		if bool(e["phase2"]) and idx % 2 == 1:
			cast_kind = "fan"
		e["cast_kind"] = cast_kind
		e["cast_timer"] = 0.48 if bool(e["phase2"]) else 0.68
		e["attack_index"] = idx + 1
		effects.append({"type":"warden_telegraph","pos":p,"age":0.0,"dur":float(e["cast_timer"]),"color":C_RED if cast_kind == "fan" else C_PURPLE,"kind":cast_kind})
		return

	if dist > 138.0 and dist > 1.0:
		p += to_player.normalized() * float(e["speed"]) * delta * (1.15 if bool(e["phase2"]) else 1.0)
	e["pos"] = clamp_to_arena(p, float(e["radius"]))

func execute_warden_cast(e: Dictionary) -> void:
	var p: Vector2 = e["pos"]
	var phase2 := bool(e["phase2"])
	if String(e["cast_kind"]) == "fan":
		var aim := (player_pos - p).normalized()
		var count := 7
		for i in range(count):
			var spread := (float(i) - 3.0) * 0.16
			var dir := aim.rotated(spread)
			enemy_shots.append({"pos":p + dir * 44.0,"vel":dir * 330.0,"damage":15.0 + run.floor_no * 0.8,"life":2.7,"color":C_RED})
	else:
		var count := 14 if phase2 else 10
		var offset := float(e["attack_index"]) * 0.21
		for i in range(count):
			var angle := offset + TAU * float(i) / float(count)
			var dir := Vector2.from_angle(angle)
			enemy_shots.append({"pos":p + dir * 44.0,"vel":dir * (245.0 if phase2 else 195.0),"damage":14.0 + run.floor_no * 0.8,"life":3.3,"color":C_RED if phase2 else C_PURPLE})
	screen_shake = maxf(screen_shake, 5.0 if phase2 else 3.0)
	haptic(24)

func update_player_shots(delta: float) -> void:
	for i in range(player_shots.size() - 1, -1, -1):
		var shot := player_shots[i]
		shot["life"] = float(shot["life"]) - delta
		shot["pos"] = shot["pos"] + shot["vel"] * delta
		var hit := false
		for j in range(enemies.size()):
			var e := enemies[j]
			if shot["pos"].distance_to(e["pos"]) <= float(e["radius"]) + 10.0:
				apply_damage_to_enemy(j, float(shot["damage"]), bool(shot["crit"]), shot["pos"])
				hit = true
				break
		if hit or float(shot["life"]) <= 0.0 or not ARENA.grow(80).has_point(shot["pos"]): player_shots.remove_at(i)
		else: player_shots[i] = shot

func update_enemy_shots(delta: float) -> void:
	for i in range(enemy_shots.size() - 1, -1, -1):
		var shot := enemy_shots[i]
		shot["life"] = float(shot["life"]) - delta
		shot["pos"] = shot["pos"] + shot["vel"] * delta
		if shot["pos"].distance_to(player_pos) <= 28.0:
			damage_player(float(shot["damage"]), shot["pos"])
			enemy_shots.remove_at(i)
		elif float(shot["life"]) <= 0.0 or not ARENA.grow(70).has_point(shot["pos"]): enemy_shots.remove_at(i)
		else: enemy_shots[i] = shot

func update_visual_fx(delta: float) -> void:
	for i in range(damage_numbers.size() - 1, -1, -1):
		var d := damage_numbers[i]
		d["age"] = float(d["age"]) + delta
		d["pos"] = d["pos"] + Vector2(0, -42) * delta
		if float(d["age"]) >= float(d["dur"]): damage_numbers.remove_at(i)
		else: damage_numbers[i] = d
	for i in range(effects.size() - 1, -1, -1):
		var fx := effects[i]
		fx["age"] = float(fx["age"]) + delta
		if float(fx["age"]) >= float(fx["dur"]): effects.remove_at(i)
		else: effects[i] = fx

func update_coin_orbs(delta: float) -> void:
	var target := Vector2(610, 86)
	for i in range(coin_orbs.size() - 1, -1, -1):
		var orb := coin_orbs[i]
		orb["age"] = float(orb["age"]) + delta
		var p: Vector2 = orb["pos"]
		if float(orb["age"]) > 0.20:
			var to_target := target - p
			if to_target.length() < 22.0:
				run.run_coins += int(orb["value"])
				effects.append({"type":"coin","pos":target,"age":0.0,"dur":0.20,"color":C_GOLD,"kind":""})
				coin_orbs.remove_at(i)
				continue
			p += to_target.normalized() * minf(950.0 * delta, to_target.length())
		else: p.y -= 24.0 * delta
		orb["pos"] = p
		coin_orbs[i] = orb

func fire_auto_attack() -> void:
	var used: Array[int] = []
	for n in range(1 + run.extra_targets):
		var idx := nearest_enemy(used)
		if idx == -1: break
		used.append(idx)
		var target: Vector2 = enemies[idx]["pos"]
		var crit := rng.randf() < run.crit_chance
		var shot_damage := run.damage * (run.crit_mult if crit else 1.0)
		var spread := (float(n) - float(run.extra_targets) * 0.5) * 0.06
		var dir := (target - player_pos).normalized().rotated(spread)
		player_shots.append({"pos":player_pos + dir * 28.0,"vel":dir * 720.0,"damage":shot_damage,"life":0.60,"crit":crit})
		effects.append({"type":"slash","pos":player_pos,"dir":dir,"age":0.0,"dur":0.12,"color":C_GOLD,"kind":""})

func nearest_enemy(ignore: Array[int]) -> int:
	var best := -1
	var best_dist := run.attack_range + 1.0
	for i in range(enemies.size()):
		if i in ignore: continue
		var dist := player_pos.distance_to(enemies[i]["pos"])
		if dist <= run.attack_range and dist < best_dist:
			best = i
			best_dist = dist
	return best

func apply_damage_to_enemy(index: int, amount: float, crit: bool, hit_pos: Vector2) -> void:
	if index < 0 or index >= enemies.size(): return
	var e := enemies[index]
	e["hp"] = float(e["hp"]) - amount
	enemies[index] = e
	if run.lifesteal > 0.0: run.hp = minf(run.max_hp, run.hp + amount * run.lifesteal)
	add_damage_popup(hit_pos, amount, crit, C_GOLD if crit else C_TEXT)
	effects.append({"type":"hit","pos":hit_pos,"age":0.0,"dur":0.16,"color":C_GOLD if crit else C_TEXT,"kind":""})
	screen_shake = maxf(screen_shake, 4.0 if crit else 1.5)
	if crit: haptic(16)

func damage_player(raw_damage: float, source: Vector2) -> void:
	var dealt := maxf(1.0, raw_damage * (1.0 - run.armor))
	run.hp -= dealt
	add_damage_popup(player_pos + Vector2(0, -34), dealt, false, C_RED)
	effects.append({"type":"hurt","pos":player_pos,"age":0.0,"dur":0.20,"color":C_RED,"kind":""})
	screen_shake = maxf(screen_shake, 7.0)
	haptic(28)
	if source != player_pos: player_pos = clamp_to_arena(player_pos + (player_pos - source).normalized() * 8.0, 26.0)

func add_damage_popup(pos: Vector2, amount: float, crit: bool, color: Color) -> void:
	damage_numbers.append({"pos":pos,"value":int(round(amount)),"crit":crit,"age":0.0,"dur":0.62,"color":color})

func remove_dead() -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if float(enemies[i]["hp"]) <= 0.0:
			var e := enemies[i]
			var reward := int(round(float(e["reward"]) * meta.coin_multiplier()))
			coin_orbs.append({"pos":e["pos"],"value":reward,"age":0.0})
			effects.append({"type":"burst","pos":e["pos"],"age":0.0,"dur":0.30,"color":enemy_color(String(e["type"])),"kind":""})
			if String(e["type"]) == "warden":
				screen_shake = 12.0
				haptic(80)
			enemies.remove_at(i)

func start_run() -> void:
	run.reset(meta)
	player_pos = Vector2(360, 700)
	player_shots.clear(); enemy_shots.clear(); damage_numbers.clear(); coin_orbs.clear(); effects.clear()
	state = State.RUNNING
	spawn_floor()

func spawn_floor() -> void:
	enemies.clear(); player_shots.clear(); enemy_shots.clear(); coin_orbs.clear()
	player_pos = Vector2(360, 700)
	floor_banner = 1.25
	if run.floor_no % 5 == 0:
		enemies.append(EnemyFactory.make_enemy("warden", run.floor_no, rng, player_pos))
		var escorts := mini(4, 1 + int(run.floor_no / 10))
		for i in range(escorts): enemies.append(EnemyFactory.make_enemy("bat" if i % 2 == 0 else "goblin", run.floor_no, rng, player_pos))
		return
	var count := mini(12, 3 + run.floor_no)
	for _i in range(count):
		var roll := rng.randf()
		var kind := "goblin"
		if run.floor_no >= 2 and roll >= 0.72: kind = "bat"
		if run.floor_no >= 3 and roll >= 0.73: kind = "skeleton"
		enemies.append(EnemyFactory.make_enemy(kind, run.floor_no, rng, player_pos))

func spawn_enemy_projectile(from: Vector2, toward: Vector2, projectile_damage: float, projectile_speed: float, color: Color) -> void:
	var dir := (toward - from).normalized()
	enemy_shots.append({"pos":from,"vel":dir * projectile_speed,"damage":projectile_damage,"life":2.2,"color":color})

func use_skill() -> void:
	if state != State.RUNNING or run.skill_cd > 0.0: return
	run.skill_cd = 7.0
	skill_flash = 0.36
	screen_shake = 8.0
	haptic(38)
	effects.append({"type":"nova","pos":player_pos,"age":0.0,"dur":0.38,"color":C_BLUE,"kind":""})
	for i in range(enemies.size()):
		if player_pos.distance_to(enemies[i]["pos"]) <= run.nova_radius: apply_damage_to_enemy(i, run.damage * run.nova_mult, false, enemies[i]["pos"])
	for i in range(enemy_shots.size() - 1, -1, -1):
		if player_pos.distance_to(enemy_shots[i]["pos"]) <= run.nova_radius: enemy_shots.remove_at(i)

func roll_upgrade_options() -> void:
	upgrade_options.clear()
	var available: Array[int] = []
	for i in range(UPGRADE_POOL.size()): available.append(i)
	while upgrade_options.size() < 3 and not available.is_empty():
		var pick_pos := rng.randi_range(0, available.size() - 1)
		var pick := available[pick_pos]
		available.remove_at(pick_pos)
		upgrade_options.append(UPGRADE_POOL[pick])

func apply_upgrade(index: int) -> void:
	if index < 0 or index >= upgrade_options.size(): return
	run.apply_upgrade(String(upgrade_options[index]["kind"]))
	state = State.DECISION

func continue_run() -> void:
	run.next_floor()
	state = State.RUNNING
	spawn_floor()

func cash_out() -> void:
	meta.coins += run.run_coins
	run.run_coins = 0
	meta.save_data()
	state = State.HOME

func die() -> void:
	run.saved_after_death = run.death_secure_amount()
	meta.coins += run.saved_after_death
	meta.best_floor = maxi(meta.best_floor, run.floor_no)
	meta.save_data()
	state = State.GAME_OVER
	joy_active = false
	joy_vector = Vector2.ZERO
	haptic(110)

func buy_meta(kind: String) -> void:
	var ok := false
	match kind:
		"hero": ok = meta.buy_hero()
		"forge": ok = meta.buy_forge()
		"vitality", "precision", "fortune": ok = meta.buy_talent(kind)
	meta_notice = "UPGRADE PURCHASED" if ok else "NOT ENOUGH COINS"
	meta_notice_time = 1.4
	if ok: haptic(22)

func haptic(duration_ms: int) -> void:
	if haptics_enabled: Input.vibrate_handheld(duration_ms)

func clamp_to_arena(pos: Vector2, radius: float) -> Vector2:
	return Vector2(clampf(pos.x, ARENA.position.x + radius, ARENA.end.x - radius), clampf(pos.y, ARENA.position.y + radius, ARENA.end.y - radius))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch: pointer(event.position, event.pressed, event.index)
	elif event is InputEventScreenDrag and joy_active and event.index == joy_id: move_joy(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT: pointer(event.position, event.pressed, -99)
	elif event is InputEventMouseMotion and joy_active and joy_id == -99: move_joy(event.position)
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE: use_skill()

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if not pressed:
		if joy_active and id == joy_id:
			joy_active = false; joy_vector = Vector2.ZERO
		return
	match state:
		State.HOME:
			if PLAY.has_point(pos): start_run()
			elif HERO_TAB.has_point(pos): state = State.HERO
			elif FORGE_TAB.has_point(pos): state = State.FORGE
			elif TALENTS_TAB.has_point(pos): state = State.TALENTS
			elif VAULT_TAB.has_point(pos): state = State.VAULT
		State.HERO:
			if META_BACK.has_point(pos): state = State.HOME
			elif META_BUY.has_point(pos): buy_meta("hero")
		State.FORGE:
			if META_BACK.has_point(pos): state = State.HOME
			elif META_BUY.has_point(pos): buy_meta("forge")
		State.TALENTS:
			if META_BACK.has_point(pos): state = State.HOME
			else:
				for i in range(3):
					if talent_rect(i).has_point(pos): buy_meta(["vitality","precision","fortune"][i])
		State.VAULT:
			if META_BACK.has_point(pos): state = State.HOME
		State.RUNNING:
			if SKILL.has_point(pos): use_skill()
			elif JOY_AREA.has_point(pos):
				joy_active = true; joy_id = id; joy_origin = pos; joy_pos = pos
		State.UPGRADE:
			for i in range(3):
				if upgrade_rect(i).has_point(pos): apply_upgrade(i)
		State.DECISION:
			if CASH.has_point(pos): cash_out()
			elif NEXT.has_point(pos): continue_run()
		State.GAME_OVER:
			if RETRY.has_point(pos): start_run()
			elif HOME_BTN.has_point(pos): state = State.HOME

func move_joy(pos: Vector2) -> void:
	var delta := pos - joy_origin
	if delta.length() > 74.0: delta = delta.normalized() * 74.0
	joy_pos = joy_origin + delta
	joy_vector = delta / 74.0

func upgrade_rect(i: int) -> Rect2:
	return Rect2(68, 390 + i * 166, 584, 138)

func talent_rect(i: int) -> Rect2:
	return Rect2(54, 380 + i * 170, 612, 136)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), C_BG)
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

func draw_home() -> void:
	draw_circle(Vector2(360, 350), 260, Color(0.28, 0.12, 0.50, 0.18))
	draw_circle(Vector2(360, 350), 180, Color(0.45, 0.16, 0.72, 0.12))
	draw_tower(Vector2(360, 470))
	draw_center("ONE MORE", 212, 54, C_TEXT)
	draw_center("FLOOR", 292, 92, C_GOLD)
	draw_center("Climb. Loot. Risk it all.", 350, 20, C_MUTED)
	panel(Rect2(40, 64, 190, 82), C_PANEL, C_PURPLE)
	text("BEST FLOOR", Vector2(58, 98), 17, C_MUTED); text(str(meta.best_floor), Vector2(60, 134), 32, C_TEXT)
	panel(Rect2(490, 64, 190, 82), C_PANEL, C_GOLD)
	text("BANK", Vector2(512, 98), 17, C_MUTED); text("%d" % meta.coins, Vector2(512, 134), 30, C_GOLD)
	draw_wanderer(Vector2(360, 655), 1.35, false)
	button(PLAY, "PLAY", C_GOLD, 38)
	var tabs := [{"r":HERO_TAB,"label":"HERO","c":C_BLUE},{"r":FORGE_TAB,"label":"FORGE","c":C_ORANGE},{"r":TALENTS_TAB,"label":"TALENTS","c":C_PURPLE},{"r":VAULT_TAB,"label":"VAULT","c":C_GOLD}]
	for tab in tabs:
		panel(tab["r"], C_PANEL, tab["c"]); center_rect(tab["label"], tab["r"], 17, C_TEXT)
	panel(Rect2(38, 1164, 644, 64), C_PANEL_2, Color("343d6b"))
	text("POWER %d" % meta.power_score(), Vector2(62, 1203), 17, C_GOLD)
	text("v0.3 META PROGRESSION", Vector2(445, 1203), 14, C_TEXT)
	draw_center("Kamilunavo Games", 1258, 14, C_MUTED)

func draw_meta_header(title: String, subtitle: String, accent: Color) -> void:
	draw_circle(Vector2(360, 260), 190, Color(accent, 0.08))
	draw_center(title, 130, 48, accent)
	draw_center(subtitle, 176, 18, C_MUTED)
	panel(Rect2(470, 52, 205, 72), C_PANEL, C_GOLD)
	text("COINS", Vector2(490, 82), 15, C_MUTED); text("%d" % meta.coins, Vector2(490, 112), 26, C_GOLD)
	button(META_BACK, "BACK", C_PURPLE, 20)
	if meta_notice_time > 0.0: draw_center(meta_notice, 1080, 20, C_GREEN if meta_notice.begins_with("UPGRADE") else C_RED)

func draw_hero_screen() -> void:
	draw_meta_header("HERO", "Permanent Wanderer training", C_BLUE)
	draw_wanderer(Vector2(360, 365), 2.0, false)
	panel(Rect2(78, 530, 564, 220), C_PANEL, C_BLUE)
	draw_center("WANDERER  •  LEVEL %d" % meta.hero_level, 585, 28, C_TEXT)
	draw_center("Base HP bonus  +%d" % int(meta.hp_bonus()), 640, 20, C_GREEN)
	draw_center("Combined damage  x%.2f" % meta.damage_multiplier(), 682, 20, C_GOLD)
	draw_center("Power  %d" % meta.power_score(), 724, 18, C_MUTED)
	button(META_BUY, "TRAIN  %d" % meta.hero_cost(), C_BLUE if meta.coins >= meta.hero_cost() else C_MUTED, 22)
	text("Each Hero level: +5 HP and +3.5% damage", Vector2(70, 972), 17, C_MUTED)

func draw_forge_screen() -> void:
	draw_meta_header("FORGE", "Temper the Wanderer's weapon", C_ORANGE)
	draw_circle(Vector2(360, 380), 105, Color(C_ORANGE, 0.13))
	draw_line(Vector2(285, 440), Vector2(435, 290), C_GOLD, 20)
	draw_line(Vector2(425, 300), Vector2(455, 270), C_TEXT, 6)
	panel(Rect2(78, 530, 564, 220), C_PANEL, C_ORANGE)
	draw_center("FORGE LEVEL %d" % meta.forge_level, 590, 30, C_TEXT)
	draw_center("Weapon multiplier contribution", 646, 18, C_MUTED)
	draw_center("+%.1f%% DAMAGE" % (float(meta.forge_level) * 8.5), 700, 30, C_GOLD)
	button(META_BUY, "TEMPER  %d" % meta.forge_cost(), C_ORANGE if meta.coins >= meta.forge_cost() else C_MUTED, 22)
	text("Every Forge level adds +8.5% permanent damage.", Vector2(70, 972), 17, C_MUTED)

func draw_talents_screen() -> void:
	draw_meta_header("TALENTS", "Permanent passive bonuses", C_PURPLE)
	var rows := [
		{"name":"VITALITY","kind":"vitality","level":meta.vitality_level,"desc":"+12 starting HP / level","c":C_GREEN},
		{"name":"PRECISION","kind":"precision","level":meta.precision_level,"desc":"+1.8% starting crit / level","c":C_GOLD},
		{"name":"FORTUNE","kind":"fortune","level":meta.fortune_level,"desc":"+6% coin drops / level","c":C_PURPLE},
	]
	for i in range(rows.size()):
		var row = rows[i]
		var r := talent_rect(i)
		panel(r, C_PANEL, row["c"])
		text(row["name"], r.position + Vector2(26, 42), 23, C_TEXT)
		text("Lv. %d  •  %s" % [row["level"], row["desc"]], r.position + Vector2(26, 78), 16, C_MUTED)
		var cost := meta.talent_cost(row["kind"])
		text("UPGRADE %d" % cost, r.position + Vector2(395, 92), 17, C_GOLD if meta.coins >= cost else C_MUTED)

func draw_vault_screen() -> void:
	draw_meta_header("VAULT", "Artifacts and equipment", C_GOLD)
	panel(Rect2(90, 330, 540, 420), C_PANEL, C_GOLD)
	draw_center("VAULT DOORS SEALED", 440, 30, C_TEXT)
	draw_center("Artifacts arrive in the next content pass.", 500, 18, C_MUTED)
	draw_center("Future: weapon traits • relics • sets", 548, 17, C_PURPLE)
	draw_center("Your permanent progression is already saved.", 650, 17, C_GREEN)

func draw_tower(center: Vector2) -> void:
	draw_rect(Rect2(center.x - 78, center.y - 160, 156, 250), Color("11162f")); draw_rect(Rect2(center.x - 54, center.y - 205, 108, 55), Color("181a3a"))
	draw_colored_polygon(PackedVector2Array([Vector2(center.x - 70, center.y - 205),Vector2(center.x, center.y - 275),Vector2(center.x + 70, center.y - 205)]), Color("1b1c43"))
	draw_circle(Vector2(center.x, center.y - 190), 22, C_PURPLE)
	for row in range(3):
		for col in range(2):
			var p := Vector2(center.x - 35 + col * 70, center.y - 110 + row * 62); draw_rect(Rect2(p.x - 10, p.y - 18, 20, 34), Color("f19f4b"))

func draw_game() -> void:
	var shake_offset := Vector2.ZERO
	if screen_shake > 0.0: shake_offset = Vector2(rng.randf_range(-screen_shake, screen_shake), rng.randf_range(-screen_shake, screen_shake))
	draw_set_transform(shake_offset)
	draw_rect(ARENA, Color("0b1225"))
	for x in range(40, 690, 54): draw_line(Vector2(x,160), Vector2(x,1000), Color(0.3,0.3,0.5,0.16), 1)
	for y in range(160, 1010, 54): draw_line(Vector2(36,y), Vector2(684,y), Color(0.3,0.3,0.5,0.16), 1)
	for e in enemies: draw_enemy(e)
	for shot in player_shots: draw_player_projectile(shot)
	for shot in enemy_shots: draw_enemy_projectile(shot)
	for orb in coin_orbs: draw_coin_orb(orb)
	for fx in effects: draw_effect(fx)
	draw_wanderer(player_pos, 1.0, true)
	for d in damage_numbers:
		var alpha := clampf(1.0 - float(d["age"]) / float(d["dur"]), 0.0, 1.0)
		var c: Color = d["color"]; c.a = alpha
		var fs := 25 if bool(d["crit"]) else 19
		draw_string(font, d["pos"] + Vector2(-28,0), ("CRIT %d" if bool(d["crit"]) else "%d") % int(d["value"]), HORIZONTAL_ALIGNMENT_CENTER, 70, fs, c)
	draw_set_transform(Vector2.ZERO)
	panel(Rect2(34,34,652,104), Color("0b1025"), Color("343d6b"))
	text("FLOOR %d" % run.floor_no, Vector2(58,86), 34, C_TEXT); text("WARDEN" if run.floor_no % 5 == 0 else "DUNGEON", Vector2(58,118), 14, C_MUTED); text("%d" % run.run_coins, Vector2(586,86), 26, C_GOLD)
	var hp_box := Rect2(110,1018,430,28)
	draw_rect(hp_box, Color("321824")); draw_rect(Rect2(hp_box.position, Vector2(hp_box.size.x * clampf(run.hp/run.max_hp,0.0,1.0),28)), C_RED); center_rect("%d / %d HP" % [int(run.hp),int(run.max_hp)], hp_box, 16, C_TEXT)
	var base := joy_origin if joy_active else Vector2(145,1115); var knob := joy_pos if joy_active else base
	draw_circle(base,78,Color(0.3,0.32,0.5,0.36)); draw_circle(knob,36,Color(0.58,0.60,0.8,0.65))
	draw_circle(SKILL.get_center(),58,Color("172954")); draw_arc(SKILL.get_center(),58,0,TAU,48,C_BLUE if run.skill_cd<=0.0 else Color("4a5070"),5); center_rect("NOVA" if run.skill_cd<=0.0 else "%.1f" % run.skill_cd, SKILL, 18, C_TEXT)
	if floor_banner > 0.0:
		var c := C_GOLD; c.a = clampf(floor_banner,0.0,1.0); draw_string(font, Vector2(80,608), "FLOOR %d" % run.floor_no, HORIZONTAL_ALIGNMENT_CENTER, 560, 50, c)

func draw_enemy(e: Dictionary) -> void:
	var p: Vector2 = e["pos"]; var radius := float(e["radius"]); var kind := String(e["type"]); var c := enemy_color(kind)
	if kind == "goblin":
		draw_circle(p,radius,c); draw_colored_polygon(PackedVector2Array([p+Vector2(-18,-13),p+Vector2(-8,-32),p+Vector2(-2,-12)]),c); draw_colored_polygon(PackedVector2Array([p+Vector2(18,-13),p+Vector2(8,-32),p+Vector2(2,-12)]),c); draw_circle(p+Vector2(-7,-4),3,C_TEXT); draw_circle(p+Vector2(7,-4),3,C_TEXT)
	elif kind == "bat":
		draw_circle(p,10,c); var flap := 8.0 + sin(elapsed*13.0+float(e["phase"]))*6.0; draw_colored_polygon(PackedVector2Array([p+Vector2(-8,0),p+Vector2(-30,-flap),p+Vector2(-23,12),p+Vector2(-5,8)]),c); draw_colored_polygon(PackedVector2Array([p+Vector2(8,0),p+Vector2(30,-flap),p+Vector2(23,12),p+Vector2(5,8)]),c)
	elif kind == "skeleton":
		draw_circle(p+Vector2(0,-7),15,Color("ddd9c8")); draw_line(p+Vector2(0,8),p+Vector2(0,26),Color("ddd9c8"),6); draw_line(p+Vector2(-15,16),p+Vector2(15,16),Color("ddd9c8"),5); draw_circle(p+Vector2(-5,-9),2.5,C_BG); draw_circle(p+Vector2(5,-9),2.5,C_BG)
	else:
		draw_circle(p,radius,Color("48214f")); draw_circle(p,radius-8,c); draw_rect(Rect2(p.x-32,p.y-30,64,38),Color("252a47")); draw_colored_polygon(PackedVector2Array([p+Vector2(-34,-30),p+Vector2(-22,-56),p+Vector2(-8,-34),p+Vector2(0,-62),p+Vector2(10,-34),p+Vector2(26,-55),p+Vector2(34,-30)]),C_GOLD); draw_circle(p+Vector2(-12,-12),4,C_RED); draw_circle(p+Vector2(12,-12),4,C_RED)
		if bool(e["phase2"]): draw_arc(p, radius+10, 0, TAU, 36, C_RED, 4)
	var ratio := clampf(float(e["hp"])/float(e["max_hp"]),0.0,1.0); var width := radius*2.0
	draw_rect(Rect2(p.x-radius,p.y-radius-17,width,7),Color("381726")); draw_rect(Rect2(p.x-radius,p.y-radius-17,width*ratio,7),C_RED)
	if kind == "warden" and bool(e["phase2"]): draw_string(font,p+Vector2(-48,-76),"PHASE II",HORIZONTAL_ALIGNMENT_CENTER,96,13,C_RED)

func enemy_color(kind: String) -> Color:
	match kind:
		"goblin": return Color("55a85d")
		"bat": return Color("7551ae")
		"skeleton": return Color("dad6c7")
		"warden": return Color("8d3b72")
	return C_MUTED

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	draw_circle(pos+Vector2(0,12)*scale,23*scale,Color("273050")); draw_circle(pos+Vector2(0,-13)*scale,15*scale,Color("d4a47b")); draw_colored_polygon(PackedVector2Array([pos+Vector2(-22,3)*scale,pos+Vector2(-6,40)*scale,pos+Vector2(25,28)*scale,pos+Vector2(18,0)*scale]),Color("6b2948")); draw_line(pos+Vector2(13,6)*scale,pos+Vector2(43,-26)*scale,C_GOLD,5*scale); draw_circle(pos+Vector2(-5,-16)*scale,2.2*scale,C_BG)
	if combat: draw_arc(pos,31*scale,-0.7,0.9,18,Color(1.0,0.75,0.3,0.35),2.5*scale)

func draw_player_projectile(shot: Dictionary) -> void:
	var p: Vector2=shot["pos"]; var dir: Vector2=shot["vel"].normalized(); var c:=C_GOLD if bool(shot["crit"]) else C_BLUE; draw_line(p-dir*20.0,p+dir*8.0,c,6.0 if bool(shot["crit"]) else 4.0); draw_circle(p,5.0 if bool(shot["crit"]) else 3.0,C_TEXT)

func draw_enemy_projectile(shot: Dictionary) -> void:
	var p: Vector2=shot["pos"]; var c: Color=shot["color"]; draw_circle(p,8,Color(c,0.20)); draw_circle(p,4,c)

func draw_coin_orb(orb: Dictionary) -> void:
	var p: Vector2=orb["pos"]; draw_circle(p,9,Color(C_GOLD,0.25)); draw_circle(p,5,C_GOLD)

func draw_effect(fx: Dictionary) -> void:
	var t:=clampf(float(fx["age"])/float(fx["dur"]),0.0,1.0); var p: Vector2=fx["pos"]; var c: Color=fx["color"]; c.a=1.0-t
	match String(fx["type"]):
		"slash": var dir: Vector2=fx["dir"]; var ang:=dir.angle(); draw_arc(p,40+t*18,ang-0.8,ang+0.8,18,c,5)
		"hit": draw_circle(p,5+t*18,Color(c,0.22*(1.0-t)))
		"hurt": draw_circle(p,30+t*24,Color(C_RED,0.18*(1.0-t)))
		"burst":
			for i in range(8): var dir:=Vector2.from_angle(TAU*float(i)/8.0); draw_line(p+dir*8,p+dir*(18+t*35),c,4)
		"nova": draw_arc(p,lerpf(34.0,run.nova_radius,t),0,TAU,64,c,8)
		"warden_telegraph":
			if String(fx["kind"])=="fan": draw_line(p,player_pos,C_RED,4+t*5)
			else: draw_arc(p,55+t*72,0,TAU,48,c,7)
		"phase2": draw_arc(p,50+t*180,0,TAU,64,C_RED,10*(1.0-t)+2.0)
		"coin": draw_circle(p,12+t*12,Color(C_GOLD,0.25*(1.0-t)))

func draw_upgrade() -> void:
	draw_center("FLOOR CLEARED!",150,46,C_GOLD); draw_center("Choose an Upgrade",214,30,C_TEXT); draw_center("Build the run. Break the tower.",254,18,C_MUTED)
	for i in range(upgrade_options.size()):
		var r:=upgrade_rect(i); var u=upgrade_options[i]; panel(r,C_PANEL,u["color"]); draw_circle(r.position+Vector2(64,69),31,Color(u["color"],0.18)); draw_circle(r.position+Vector2(64,69),18,u["color"]); text(u["name"],r.position+Vector2(112,58),25,C_TEXT); text(u["desc"],r.position+Vector2(112,96),18,C_MUTED)
	draw_center("Tap an upgrade to continue.",982,16,C_MUTED)

func draw_decision() -> void:
	draw_center("TAKE THE LOOT?",200,44,C_TEXT); draw_center("OR",258,20,C_MUTED); draw_center("ONE MORE FLOOR",330,52,C_GOLD); panel(Rect2(118,420,484,230),C_PANEL,Color("3d456f")); draw_center("RUN LOOT",468,18,C_MUTED); draw_center("%d COINS" % run.run_coins,542,48,C_GOLD); draw_center("Floor %d cleared" % run.floor_no,600,22,C_TEXT); button(CASH,"CASH OUT",C_GREEN,24); button(NEXT,"ONE MORE FLOOR",C_GOLD,22); draw_center("Death keeps only 60% of unsecured coins.",1040,18,C_MUTED)

func draw_game_over() -> void:
	draw_center("RUN ENDED",230,54,C_RED); draw_center("The tower wins this time.",292,22,C_MUTED); panel(Rect2(118,410,484,260),C_PANEL,C_PURPLE); draw_center("FLOOR %d" % run.floor_no,510,46,C_TEXT); draw_center("%d coins secured" % run.saved_after_death,590,26,C_GOLD); button(RETRY,"RETRY",C_GOLD,28); button(HOME_BTN,"HOME",C_PURPLE,28)

func panel(r: Rect2, fill: Color, border: Color) -> void:
	draw_rect(r,fill); draw_rect(r,border,false,2)

func button(r: Rect2, label: String, accent: Color, size: int) -> void:
	panel(r,Color(accent,0.18),accent); center_rect(label,r,size,C_TEXT)

func text(value: String, pos: Vector2, size: int, color: Color) -> void:
	draw_string(font,pos,value,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)

func draw_center(value: String, y: float, size: int, color: Color) -> void:
	draw_string(font,Vector2(40,y),value,HORIZONTAL_ALIGNMENT_CENTER,640,size,color)

func center_rect(value: String, r: Rect2, size: int, color: Color) -> void:
	var y:=r.position.y+r.size.y*0.5+size*0.34; draw_string(font,Vector2(r.position.x,y),value,HORIZONTAL_ALIGNMENT_CENTER,r.size.x,size,color)
