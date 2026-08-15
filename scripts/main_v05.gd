extends "res://scripts/main_v04.gd"

const RoomSystem = preload("res://scripts/room_system.gd")

var room_system
var current_room: Dictionary = {}
var rewarded_floor := 0
var hazard_timer := 2.5

func _ready() -> void:
	super._ready()
	room_system = RoomSystem.new()

func start_run() -> void:
	rewarded_floor = 0
	super.start_run()
	var bonuses: Dictionary = loot.equipped_bonuses()
	run.lifesteal += float(bonuses.get("lifesteal", 0.0))
	run.armor = minf(0.55, run.armor + float(bonuses.get("armor", 0.0)))
	run.attack_delay = maxf(0.18, run.attack_delay * (1.0 - float(bonuses.get("attack_speed", 0.0))))
	run.nova_mult += float(bonuses.get("nova_mult", 0.0))

func spawn_floor() -> void:
	current_room = room_system.roll_room(int(run.floor_no), rng)
	hazard_timer = 2.2
	super.spawn_floor()
	if int(run.floor_no) % 5 == 0:
		return
	enemies.clear()
	var room_type: String = String(current_room.get("type", "COMBAT"))
	var area: String = String(current_room.get("area", "DUNGEON"))
	var count: int = mini(12, 3 + int(run.floor_no))
	match room_type:
		"AMBUSH": count = mini(15, 5 + int(run.floor_no))
		"ELITE": count = mini(4, 1 + int(run.floor_no / 7))
		"TREASURE": count = mini(5, 2 + int(run.floor_no / 6))
	var pool: Array[String] = room_system.enemy_pool(area, int(run.floor_no))
	for i in range(count):
		var kind: String = String(pool[rng.randi_range(0, pool.size() - 1)])
		var enemy: Dictionary = EnemyFactory.make_enemy(kind, int(run.floor_no), rng, player_pos)
		if room_type == "ELITE":
			enemy = EnemyFactory.empower_elite(enemy)
		elif room_type == "AMBUSH":
			enemy["speed"] = float(enemy["speed"]) * 1.12
		enemies.append(enemy)

func update_game(delta: float) -> void:
	super.update_game(delta)
	if state == State.RUNNING:
		update_room_hazard(delta)

func update_room_hazard(delta: float) -> void:
	if String(current_room.get("area", "")) != "CRYPT" or String(current_room.get("type", "")) == "BOSS":
		return
	hazard_timer -= delta
	if hazard_timer > 0.0:
		return
	var hazard: String = String(current_room.get("hazard", "none"))
	if hazard == "soul_mist":
		var left := Vector2(ARENA.position.x + 10.0, rng.randf_range(250.0, 900.0))
		var right := Vector2(ARENA.end.x - 10.0, rng.randf_range(250.0, 900.0))
		spawn_enemy_projectile(left, player_pos, 7.0 + float(run.floor_no) * 0.28, 175.0, C_PURPLE)
		spawn_enemy_projectile(right, player_pos, 7.0 + float(run.floor_no) * 0.28, 175.0, C_PURPLE)
		hazard_timer = 4.4
	else:
		for x in [150.0, 360.0, 570.0]:
			spawn_enemy_projectile(Vector2(x, ARENA.position.y + 12.0), player_pos, 6.0 + float(run.floor_no) * 0.24, 205.0, C_CYAN)
		hazard_timer = 5.1

func update_enemies(delta: float) -> void:
	var pending_summons: Array[Dictionary] = []
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		e["touch_cd"] = maxf(0.0, float(e["touch_cd"]) - delta)
		e["attack_cd"] = maxf(0.0, float(e["attack_cd"]) - delta)
		var p: Vector2 = e["pos"]
		var to_player: Vector2 = player_pos - p
		var dist: float = to_player.length()
		var kind: String = String(e["type"])

		if kind == "goblin":
			if dist > 1.0: p += to_player.normalized() * float(e["speed"]) * delta
		elif kind == "bat":
			if dist > 1.0:
				var wobble: Vector2 = Vector2(-to_player.y, to_player.x).normalized() * sin(elapsed * 8.0 + float(e["phase"])) * 0.35
				p += (to_player.normalized() + wobble).normalized() * float(e["speed"]) * delta
		elif kind == "skeleton":
			p = _ranged_enemy_step(e, p, to_player, dist, delta, 185.0, 300.0)
			if float(e["attack_cd"]) <= 0.0 and dist < 430.0:
				spawn_enemy_projectile(p, player_pos, 12.0 + run.floor_no * 0.65, 265.0, C_CYAN)
				e["attack_cd"] = 1.55
		elif kind == "ghoul":
			var hp_ratio: float = clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
			var rage_mult: float = 1.42 if hp_ratio <= 0.40 else 1.0
			if dist > 1.0: p += to_player.normalized() * float(e["speed"]) * rage_mult * delta
			e["rage"] = 1.0 if hp_ratio <= 0.40 else 0.0
		elif kind == "necromancer":
			p = _ranged_enemy_step(e, p, to_player, dist, delta, 235.0, 390.0)
			if float(e["attack_cd"]) <= 0.0 and dist < 520.0:
				spawn_enemy_projectile(p, player_pos, 13.0 + run.floor_no * 0.62, 225.0, C_PURPLE)
				e["attack_cd"] = 1.8
			e["summon_cd"] = maxf(0.0, float(e.get("summon_cd", 0.0)) - delta)
			if float(e["summon_cd"]) <= 0.0 and enemies.size() + pending_summons.size() < 15:
				var summon: Dictionary = EnemyFactory.make_enemy("skeleton", int(run.floor_no), rng, player_pos)
				summon["pos"] = clamp_to_arena(p + Vector2(rng.randf_range(-70.0, 70.0), rng.randf_range(-70.0, 70.0)), float(summon["radius"]))
				summon["hp"] = float(summon["hp"]) * 0.65
				summon["max_hp"] = summon["hp"]
				pending_summons.append(summon)
				e["summon_cd"] = 5.6
				effects.append({"type":"phase2","pos":p,"age":0.0,"dur":0.42,"color":C_PURPLE,"kind":""})
		elif kind == "warden":
			update_warden(e, p, to_player, dist, delta)
			p = e["pos"]

		if kind != "warden":
			e["pos"] = clamp_to_arena(p, float(e["radius"]))
		if dist < 34.0 + float(e["radius"]) and float(e["touch_cd"]) <= 0.0:
			damage_player(float(e["touch_damage"]), e["pos"])
			e["touch_cd"] = 0.62
		enemies[i] = e
	for summon in pending_summons:
		enemies.append(summon)

func _ranged_enemy_step(e: Dictionary, p: Vector2, to_player: Vector2, dist: float, delta: float, min_dist: float, max_dist: float) -> Vector2:
	if dist < min_dist and dist > 1.0:
		p -= to_player.normalized() * float(e["speed"]) * delta
	elif dist > max_dist and dist > 1.0:
		p += to_player.normalized() * float(e["speed"]) * delta
	return p

func roll_upgrade_options() -> void:
	if rewarded_floor != int(run.floor_no):
		var bonus: int = int(current_room.get("reward_bonus", 0))
		if bonus > 0:
			run.run_coins += bonus
			loot_notice = "%s CLEARED  +%d COINS" % [String(current_room.get("type", "ROOM")), bonus]
			loot_notice_color = C_GOLD
			loot_notice_time = 1.7
			tower_pass.add_xp(mini(40, 8 + bonus / 3))
		rewarded_floor = int(run.floor_no)
	super.roll_upgrade_options()

func draw_enemy(e: Dictionary) -> void:
	var kind: String = String(e["type"])
	if kind != "ghoul" and kind != "necromancer":
		super.draw_enemy(e)
		if bool(e.get("elite", false)):
			_draw_elite_mark(e)
		return
	var p: Vector2 = e["pos"]
	var radius: float = float(e["radius"])
	if kind == "ghoul":
		var body_color := Color("9bb36a") if float(e.get("rage", 0.0)) <= 0.0 else C_RED
		draw_circle(p + Vector2(0, 5), radius, Color("263121"))
		draw_circle(p + Vector2(0, -5), radius * 0.72, body_color)
		draw_line(p + Vector2(-12, 8), p + Vector2(-25, 28), body_color, 7)
		draw_line(p + Vector2(12, 8), p + Vector2(25, 28), body_color, 7)
		draw_circle(p + Vector2(-7, -9), 3, C_RED)
		draw_circle(p + Vector2(7, -9), 3, C_RED)
	else:
		draw_circle(p, radius + 3, Color("20172e"))
		draw_colored_polygon(PackedVector2Array([p+Vector2(-23,18),p+Vector2(-13,-22),p,p+Vector2(13,-22),p+Vector2(23,18)]), Color("5d3a78"))
		draw_circle(p + Vector2(0, -15), 11, Color("d9d3c0"))
		draw_circle(p + Vector2(-4, -17), 2.5, C_PURPLE)
		draw_circle(p + Vector2(4, -17), 2.5, C_PURPLE)
		draw_arc(p, radius + 9, elapsed, elapsed + PI * 1.45, 22, C_PURPLE, 3)
	var ratio: float = clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
	var width: float = radius * 2.0
	draw_rect(Rect2(p.x-radius, p.y-radius-17, width, 7), Color("381726"))
	draw_rect(Rect2(p.x-radius, p.y-radius-17, width*ratio, 7), C_RED)
	if bool(e.get("elite", false)):
		_draw_elite_mark(e)

func _draw_elite_mark(e: Dictionary) -> void:
	var p: Vector2 = e["pos"]
	var radius: float = float(e["radius"])
	draw_arc(p, radius + 10.0, 0.0, TAU, 36, C_GOLD, 3.0)
	draw_string(font, p + Vector2(-38, -radius - 26), "ELITE", HORIZONTAL_ALIGNMENT_CENTER, 76, 12, C_GOLD)

func enemy_color(kind: String) -> Color:
	if kind == "ghoul": return Color("9bb36a")
	if kind == "necromancer": return Color("8b58b8")
	return super.enemy_color(kind)

func draw_game() -> void:
	super.draw_game()
	_draw_room_atmosphere()
	var label: String = room_system.room_label(current_room)
	panel(Rect2(218, 222, 284, 40), Color(0.04, 0.06, 0.12, 0.86), C_PURPLE if String(current_room.get("area", "")) == "CRYPT" else C_GOLD)
	center_rect(label, Rect2(218, 222, 284, 40), 13, C_TEXT)

func _draw_room_atmosphere() -> void:
	var area: String = String(current_room.get("area", "DUNGEON"))
	var room_type: String = String(current_room.get("type", "COMBAT"))
	if area == "CRYPT":
		for y in [300.0, 500.0, 700.0, 900.0]:
			draw_rect(Rect2(40, y, 22, 58), Color(0.22, 0.24, 0.34, 0.46))
			draw_rect(Rect2(658, y, 22, 58), Color(0.22, 0.24, 0.34, 0.46))
			draw_circle(Vector2(51, y + 12), 8, Color("c9c3ae"))
			draw_circle(Vector2(669, y + 12), 8, Color("c9c3ae"))
		for i in range(5):
			var mist_x: float = 130.0 + float(i) * 115.0
			var mist_y: float = 350.0 + sin(elapsed * 0.8 + float(i)) * 120.0
			draw_circle(Vector2(mist_x, mist_y), 46.0, Color(0.42, 0.32, 0.60, 0.055))
	else:
		for y in [330.0, 610.0, 890.0]:
			draw_circle(Vector2(54, y), 9, Color("ff9b52"))
			draw_circle(Vector2(666, y), 9, Color("ff9b52"))
	if room_type == "AMBUSH":
		draw_rect(ARENA.grow(-4.0), Color(0,0,0,0), false, 4.0)
		draw_arc(ARENA.get_center(), 310.0, 0.0, TAU, 64, Color(1.0,0.25,0.3,0.16), 4.0)
	elif room_type == "ELITE":
		draw_arc(ARENA.get_center(), 305.0, 0.0, TAU, 64, Color(1.0,0.72,0.25,0.14), 4.0)
	elif room_type == "TREASURE":
		draw_rect(Rect2(328, 280, 64, 42), Color("5a381f"))
		draw_rect(Rect2(322, 272, 76, 14), C_GOLD)
		draw_circle(Vector2(360, 301), 5, C_GOLD)

func draw_vault_screen() -> void:
	super.draw_vault_screen()
	for i in range(mini(6, loot.inventory.size())):
		var item: Dictionary = loot.inventory[i]
		var detail: String = loot.trait_line(item)
		if detail != "":
			var r: Rect2 = vault_item_rect(i)
			text(detail, r.position + Vector2(220, 84), 12, rarity_color(String(item.get("rarity", "COMMON"))))
	var sets: Dictionary = loot.equipped_set_counts()
	text("SETS  Ember %d/3   Crypt %d/3   Warden %d/3" % [int(sets["EMBER"]), int(sets["CRYPT"]), int(sets["WARDEN"])], Vector2(88, 1040), 15, C_GOLD)
	text("2 pieces unlock a bonus • 3 pieces unlock the set capstone", Vector2(88, 1068), 13, C_MUTED)
