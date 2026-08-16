extends "res://scripts/main_v08.gd"

var tex_motion_atlas: Texture2D
var player_facing: int = 1
var hollow_intro: float = 0.0

func _ready() -> void:
	super._ready()
	tex_motion_atlas = load("res://assets/art/motion_atlas.svg") as Texture2D

func _process(delta: float) -> void:
	var before: Vector2 = player_pos
	super._process(delta)
	hollow_intro = maxf(0.0, hollow_intro - delta)
	var dx: float = player_pos.x - before.x
	if absf(dx) > 0.25:
		player_facing = 1 if dx > 0.0 else -1

func fire_auto_attack() -> void:
	if not enemies.is_empty():
		var idx: int = nearest_enemy([])
		if idx >= 0:
			player_facing = 1 if float(enemies[idx]["pos"].x) >= player_pos.x else -1
	super.fire_auto_attack()

func spawn_floor() -> void:
	if int(run.floor_no) != 30:
		super.spawn_floor()
		return
	room_transition = 0.72
	current_room = room_system.roll_room(int(run.floor_no), rng)
	hazard_timer = 2.2
	enemies.clear()
	player_shots.clear()
	enemy_shots.clear()
	coin_orbs.clear()
	player_pos = Vector2(360, 700)
	floor_banner = 1.25
	boss_intro = 0.0
	keeper_intro = 0.0
	hollow_intro = 2.0
	enemies.append(EnemyFactory.make_enemy("hollow_king", int(run.floor_no), rng, player_pos))
	for i in range(3):
		var escort_kind: String = "sentinel" if i < 2 else "hexer"
		enemies.append(EnemyFactory.make_enemy(escort_kind, int(run.floor_no), rng, player_pos))
	_audio("warden")

func update_room_hazard(delta: float) -> void:
	if String(current_room.get("area", "")) != "FORGOTTEN CASTLE":
		super.update_room_hazard(delta)
		return
	if String(current_room.get("type", "")) == "BOSS":
		return
	hazard_timer -= delta
	if hazard_timer > 0.0:
		return
	var hazard: String = String(current_room.get("hazard", "none"))
	if hazard == "falling_masonry":
		for i in range(4):
			var x: float = 120.0 + float(i) * 155.0 + rng.randf_range(-35.0, 35.0)
			var start := Vector2(x, ARENA.position.y + 8.0)
			var target := Vector2(x + rng.randf_range(-45.0, 45.0), ARENA.end.y)
			spawn_enemy_projectile(start, target, 9.0 + float(run.floor_no) * 0.30, 255.0, Color("b8a47f"))
		hazard_timer = 4.2
	else:
		for y in [330.0, 540.0, 750.0, 900.0]:
			var left := Vector2(ARENA.position.x + 8.0, y)
			var right := Vector2(ARENA.end.x - 8.0, y + 28.0)
			spawn_enemy_projectile(left, player_pos, 8.0 + float(run.floor_no) * 0.27, 220.0, C_RED)
			spawn_enemy_projectile(right, player_pos, 8.0 + float(run.floor_no) * 0.27, 220.0, C_PURPLE)
		hazard_timer = 5.0

func update_enemies(delta: float) -> void:
	super.update_enemies(delta)
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		var kind: String = String(e["type"])
		if not kind in ["gargoyle", "sentinel", "hexer"]:
			continue
		var p: Vector2 = e["pos"]
		var to_player: Vector2 = player_pos - p
		var dist: float = to_player.length()
		if kind == "gargoyle":
			e["dive_cd"] = maxf(0.0, float(e.get("dive_cd", 0.0)) - delta)
			e["dive_time"] = maxf(0.0, float(e.get("dive_time", 0.0)) - delta)
			if float(e["dive_cd"]) <= 0.0 and dist < 460.0:
				e["dive_time"] = 0.52
				e["dive_cd"] = 3.1
				effects.append({"type":"slash","pos":p,"dir":to_player.normalized(),"age":0.0,"dur":0.22,"color":Color("aeb7c8"),"kind":""})
			var speed_mult: float = 2.9 if float(e["dive_time"]) > 0.0 else 1.0
			if dist > 1.0:
				p += to_player.normalized() * float(e["speed"]) * speed_mult * delta
		elif kind == "sentinel":
			if dist > 95.0 and dist > 1.0:
				p += to_player.normalized() * float(e["speed"]) * delta
			if float(e["attack_cd"]) <= 0.0 and dist < 170.0:
				e["attack_cd"] = 1.45
				effects.append({"type":"slash","pos":p,"dir":to_player.normalized(),"age":0.0,"dur":0.18,"color":C_GOLD,"kind":""})
		elif kind == "hexer":
			p = _ranged_enemy_step(e, p, to_player, dist, delta, 250.0, 420.0)
			if float(e["attack_cd"]) <= 0.0 and dist < 560.0:
				var aim: Vector2 = to_player.normalized()
				for spread in [-0.16, 0.0, 0.16]:
					var dir: Vector2 = aim.rotated(float(spread))
					enemy_shots.append({"pos":p + dir * 24.0,"vel":dir * 250.0,"damage":15.0 + run.floor_no * 0.58,"life":2.8,"color":C_PURPLE})
				e["attack_cd"] = 1.75
			e["blink_cd"] = maxf(0.0, float(e.get("blink_cd", 0.0)) - delta)
			if float(e["blink_cd"]) <= 0.0:
				effects.append({"type":"phase2","pos":p,"age":0.0,"dur":0.30,"color":C_PURPLE,"kind":""})
				p = clamp_to_arena(p + Vector2(rng.randf_range(-150.0, 150.0), rng.randf_range(-120.0, 120.0)), float(e["radius"]))
				e["blink_cd"] = 4.4
		e["pos"] = clamp_to_arena(p, float(e["radius"]))
		var new_dist: float = player_pos.distance_to(e["pos"])
		if new_dist < 34.0 + float(e["radius"]) and float(e["touch_cd"]) <= 0.0:
			damage_player(float(e["touch_damage"]), e["pos"])
			e["touch_cd"] = 0.62
		enemies[i] = e

func apply_damage_to_enemy(index: int, amount: float, crit: bool, hit_pos: Vector2) -> void:
	if index >= 0 and index < enemies.size() and String(enemies[index]["type"]) == "sentinel":
		amount *= 1.0 - float(enemies[index].get("guard", 0.30))
	super.apply_damage_to_enemy(index, amount, crit, hit_pos)

func update_warden(e: Dictionary, p: Vector2, to_player: Vector2, dist: float, delta: float) -> void:
	if String(e.get("boss_variant", "warden")) != "hollow_king":
		super.update_warden(e, p, to_player, dist, delta)
		return
	var hp_ratio: float = clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
	if hp_ratio <= 0.55 and not bool(e["phase2"]):
		e["phase2"] = true
		e["attack_cd"] = 0.28
		effects.append({"type":"phase2","pos":p,"age":0.0,"dur":0.95,"color":C_GOLD,"kind":""})
		screen_shake = 15.0
		haptic(90)
	e["teleport_cd"] = maxf(0.0, float(e.get("teleport_cd", 0.0)) - delta)
	if float(e["teleport_cd"]) <= 0.0:
		effects.append({"type":"keeper_cast","pos":p,"age":0.0,"dur":0.36,"color":C_PURPLE,"kind":""})
		var spots := [Vector2(150,300), Vector2(570,300), Vector2(150,850), Vector2(570,850), Vector2(360,470)]
		p = spots[rng.randi_range(0, spots.size() - 1)]
		e["pos"] = p
		e["teleport_cd"] = 2.5 if bool(e["phase2"]) else 3.8
		for i in range(6):
			var dir: Vector2 = Vector2.from_angle(TAU * float(i) / 6.0)
			enemy_shots.append({"pos":p + dir * 48.0,"vel":dir * 210.0,"damage":17.0 + run.floor_no * 0.62,"life":3.0,"color":C_GOLD})
	if float(e["cast_timer"]) > 0.0:
		e["cast_timer"] = maxf(0.0, float(e["cast_timer"]) - delta)
		if float(e["cast_timer"]) <= 0.0:
			execute_warden_cast(e)
			e["cast_kind"] = ""
			e["attack_cd"] = 0.86 if bool(e["phase2"]) else 1.25
		return
	if float(e["attack_cd"]) <= 0.0:
		var idx: int = int(e["attack_index"])
		e["cast_kind"] = "crown" if idx % 2 == 0 else "fan"
		e["cast_timer"] = 0.38 if bool(e["phase2"]) else 0.52
		e["attack_index"] = idx + 1
		effects.append({"type":"warden_telegraph","pos":p,"age":0.0,"dur":float(e["cast_timer"]),"color":C_GOLD if String(e["cast_kind"]) == "crown" else C_RED,"kind":String(e["cast_kind"])})
		return
	if dist > 165.0 and dist > 1.0:
		p += to_player.normalized() * float(e["speed"]) * delta
	e["pos"] = clamp_to_arena(p, float(e["radius"]))

func execute_warden_cast(e: Dictionary) -> void:
	if String(e.get("boss_variant", "warden")) != "hollow_king":
		super.execute_warden_cast(e)
		return
	var p: Vector2 = e["pos"]
	var phase2: bool = bool(e["phase2"])
	if String(e["cast_kind"]) == "fan":
		var aim: Vector2 = (player_pos - p).normalized()
		var count: int = 11 if phase2 else 9
		for i in range(count):
			var spread: float = (float(i) - float(count - 1) * 0.5) * 0.115
			var dir: Vector2 = aim.rotated(spread)
			enemy_shots.append({"pos":p + dir * 54.0,"vel":dir * 365.0,"damage":20.0 + run.floor_no * 0.86,"life":2.8,"color":C_RED})
	else:
		var count: int = 22 if phase2 else 16
		var offset: float = float(e["attack_index"]) * 0.17
		for i in range(count):
			var angle: float = offset + TAU * float(i) / float(count)
			var dir: Vector2 = Vector2.from_angle(angle)
			var color: Color = C_GOLD if i % 2 == 0 else C_PURPLE
			enemy_shots.append({"pos":p + dir * 54.0,"vel":dir * (320.0 if phase2 else 255.0),"damage":19.0 + run.floor_no * 0.80,"life":3.4,"color":color})
		if phase2:
			for dir in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
				enemy_shots.append({"pos":p + dir * 58.0,"vel":dir * 390.0,"damage":22.0 + run.floor_no * 0.82,"life":2.6,"color":C_CYAN})
	effects.append({"type":"keeper_cast","pos":p,"age":0.0,"dur":0.40,"color":C_GOLD,"kind":""})
	screen_shake = maxf(screen_shake, 9.0 if phase2 else 5.0)
	haptic(34)

func _enemy_anim_state(e: Dictionary) -> String:
	var kind: String = String(e["type"])
	if kind == "gargoyle" and float(e.get("dive_time", 0.0)) > 0.0:
		return "attack"
	if kind == "sentinel" and float(e.get("attack_cd", 0.0)) > 1.05:
		return "attack"
	if kind == "hexer" and float(e.get("attack_cd", 0.0)) > 1.25:
		return "attack"
	if kind == "warden" and String(e.get("boss_variant", "")) == "hollow_king" and float(e.get("cast_timer", 0.0)) > 0.0:
		return "attack"
	return super._enemy_anim_state(e)

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	if tex_motion_atlas == null:
		super.draw_wanderer(pos, scale, combat)
		return
	var state_name: String = player_anim_state if combat else "idle"
	var frame: int = _motion_frame(state_name, player_anim_timer, false)
	var size: Vector2 = Vector2(94.0, 94.0) * scale
	var rect := Rect2(pos.x - size.x * 0.5, pos.y - size.y * 0.59, size.x, size.y)
	_draw_motion_region(0, frame, player_facing, rect, Color.WHITE)
	if state_name == "nova":
		draw_circle(pos, 45.0 * scale, Color(C_CYAN, 0.11))
		draw_arc(pos, 46.0 * scale, elapsed * 2.5, elapsed * 2.5 + TAU, 38, C_CYAN, 3.0 * scale)

func draw_enemy(e: Dictionary) -> void:
	if tex_motion_atlas == null:
		super.draw_enemy(e)
		return
	var kind: String = String(e["type"])
	var variant: String = String(e.get("boss_variant", "warden"))
	var row: int = _motion_row(kind, variant)
	if row < 0:
		super.draw_enemy(e)
		return
	var state_name: String = _enemy_anim_state(e)
	var frame: int = _motion_frame(state_name, 0.0, true)
	var p: Vector2 = e["pos"]
	var radius: float = float(e["radius"])
	var size_px: float = maxf(64.0, radius * 2.75)
	if kind == "warden": size_px = radius * 2.68
	var rect := Rect2(p.x - size_px * 0.5, p.y - size_px * 0.61, size_px, size_px)
	var facing: int = 1 if player_pos.x >= p.x else -1
	var modulate: Color = Color.WHITE
	if kind == "ghoul" and float(e.get("rage", 0.0)) > 0.0: modulate = Color(1.0, 0.58, 0.58, 1.0)
	if bool(e.get("elite", false)): modulate = modulate.lerp(C_GOLD, 0.18)
	_draw_motion_region(row, frame, facing, rect, modulate)
	if kind == "sentinel":
		draw_arc(p, radius + 8.0, -0.8, 0.8, 18, Color(C_GOLD, 0.45), 4.0)
	if bool(e.get("elite", false)):
		draw_arc(p, radius + 12.0, elapsed * 0.9, elapsed * 0.9 + TAU, 36, C_GOLD, 3.0)
	if kind == "warden" and bool(e.get("phase2", false)):
		var phase_color: Color = C_GOLD if variant == "hollow_king" else (C_CYAN if variant == "crypt_keeper" else C_RED)
		draw_arc(p, radius + 14.0, elapsed * 1.25, elapsed * 1.25 + TAU, 44, phase_color, 4.0)
	var ratio: float = clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
	draw_rect(Rect2(p.x - radius, p.y - radius - 18, radius * 2.0, 7), Color("381726"))
	draw_rect(Rect2(p.x - radius, p.y - radius - 18, radius * 2.0 * ratio, 7), C_RED)

func draw_effect(fx: Dictionary) -> void:
	if String(fx.get("type", "")) != "actor_death" or tex_motion_atlas == null:
		super.draw_effect(fx)
		return
	var row: int = _motion_row(String(fx.get("kind", "")), String(fx.get("variant", "warden")))
	if row < 0:
		return
	var t: float = clampf(float(fx["age"]) / float(fx["dur"]), 0.0, 1.0)
	var size_px: float = float(fx.get("size", 72.0)) * (1.0 - t * 0.12)
	var p: Vector2 = fx["pos"] + Vector2(0, t * 12.0)
	var rect := Rect2(p.x - size_px * 0.5, p.y - size_px * 0.58, size_px, size_px)
	_draw_motion_region(row, 7, 1, rect, Color(1.0,1.0,1.0,1.0-t))

func _motion_frame(state_name: String, timer: float, enemy: bool) -> int:
	match state_name:
		"move": return 1 + int(elapsed * (10.0 if enemy else 9.0)) % 3
		"attack", "nova": return 4 + int(elapsed * 15.0) % 2
		"hit": return 6
		"death": return 7
	return 0

func _motion_row(kind: String, variant: String = "warden") -> int:
	match kind:
		"goblin": return 1
		"bat": return 2
		"skeleton": return 3
		"ghoul": return 4
		"necromancer": return 5
		"gargoyle": return 8
		"sentinel": return 9
		"hexer": return 10
		"warden":
			if variant == "crypt_keeper": return 7
			if variant == "hollow_king": return 11
			return 6
	return -1

func _draw_motion_region(row: int, frame: int, facing: int, rect: Rect2, modulate: Color) -> void:
	var column: int = frame if facing >= 0 else 15 - frame
	var source := Rect2(float(column * 100), float(row * 100), 100.0, 100.0)
	draw_texture_rect_region(tex_motion_atlas, rect, source, modulate)

func _draw_room_floor() -> void:
	if String(current_room.get("area", "")) != "FORGOTTEN CASTLE":
		super._draw_room_floor()
		return
	draw_rect(ARENA, Color("15151d"))
	for y in range(170, 1000, 64):
		for x in range(42, 680, 64):
			var odd: bool = (int(x / 64) + int(y / 64)) % 2 == 0
			var tile: Color = Color("262633") if odd else Color("20212b")
			draw_rect(Rect2(x, y, 60, 60), tile)
	for i in range(8):
		var crack_x: float = 90.0 + float(i) * 76.0
		var crack_y: float = 260.0 + float((i * 137) % 620)
		draw_line(Vector2(crack_x, crack_y), Vector2(crack_x + 25, crack_y + 18), Color(0.55,0.48,0.40,0.18), 2.0)
		draw_line(Vector2(crack_x + 25, crack_y + 18), Vector2(crack_x + 12, crack_y + 38), Color(0.55,0.48,0.40,0.14), 2.0)

func _draw_room_architecture() -> void:
	if String(current_room.get("area", "")) != "FORGOTTEN CASTLE":
		super._draw_room_architecture()
		return
	for y in [235.0, 455.0, 675.0, 895.0]:
		for x in [43.0, 651.0]:
			draw_rect(Rect2(x, y, 30, 72), Color("44434d"))
			draw_rect(Rect2(x - 5, y - 8, 40, 11), Color("77707a"))
			draw_rect(Rect2(x - 5, y + 66, 40, 11), Color("77707a"))
	for x in [120.0, 600.0]:
		draw_colored_polygon(PackedVector2Array([Vector2(x-28,205),Vector2(x+28,205),Vector2(x+20,300),Vector2(x,325),Vector2(x-20,300)]), Color("5a2334"))
		draw_line(Vector2(x,210), Vector2(x,300), C_GOLD, 4.0)
	if String(current_room.get("type", "")) == "TREASURE":
		draw_rect(Rect2(314, 268, 92, 54), Color("51351f"))
		draw_rect(Rect2(308, 260, 104, 14), C_GOLD)
	elif String(current_room.get("type", "")) == "ELITE":
		draw_arc(ARENA.get_center(), 292, elapsed * 0.2, elapsed * 0.2 + TAU, 72, Color(C_GOLD,0.18), 5.0)

func _draw_room_badge() -> void:
	if String(current_room.get("area", "")) != "FORGOTTEN CASTLE":
		super._draw_room_badge()
		return
	panel(Rect2(188, 218, 344, 42), Color(0.03,0.03,0.05,0.94), C_GOLD)
	center_rect(room_system.room_label(current_room), Rect2(188,218,344,42), 13, C_TEXT)

func _draw_boss_ui() -> void:
	var boss: Dictionary = {}
	for e in enemies:
		if String(e["type"]) == "warden":
			boss = e
			break
	if boss.is_empty() or String(boss.get("boss_variant", "warden")) != "hollow_king":
		super._draw_boss_ui()
		return
	var ratio: float = clampf(float(boss["hp"]) / float(boss["max_hp"]), 0.0, 1.0)
	var accent: Color = C_RED if bool(boss["phase2"]) else C_GOLD
	panel(Rect2(96, 158, 528, 58), Color("160f1b"), accent)
	text("THE HOLLOW KING", Vector2(118, 182), 15, C_TEXT)
	draw_rect(Rect2(258, 179, 340, 14), Color("3b1725"))
	draw_rect(Rect2(258, 179, 340 * ratio, 14), accent)
	if hollow_intro > 0.0:
		var alpha: float = clampf(hollow_intro, 0.0, 1.0)
		draw_rect(Rect2(46, 468, 628, 184), Color(0.015,0.012,0.025,0.90*alpha))
		var c: Color = C_GOLD
		c.a = alpha
		draw_string(font, Vector2(70, 542), "THE HOLLOW KING", HORIZONTAL_ALIGNMENT_CENTER, 580, 42, c)
		draw_string(font, Vector2(70, 590), "FLOOR 30  •  LAST CROWN OF THE CASTLE", HORIZONTAL_ALIGNMENT_CENTER, 580, 16, C_TEXT)

func draw_home() -> void:
	super.draw_home()
	if home_overlay == "":
		panel(Rect2(454, 1148, 210, 38), Color("0b1025"), C_GOLD)
		center_rect("v0.9 FORGOTTEN CASTLE", Rect2(454,1148,210,38), 10, C_TEXT)
