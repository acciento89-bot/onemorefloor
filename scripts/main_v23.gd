extends "res://scripts/main_v22.gd"

# ONE MORE FLOOR v1.11 gameplay pass.
# No new art direction here: this layer deepens the run itself with upgrade
# rarity, room events, miniboss encounters and Floors 41-50.

const V23_VERSION := "1.11-gameplay"
const EVENT_RECTS := [
	Rect2(58, 410, 604, 142),
	Rect2(58, 580, 604, 142),
	Rect2(58, 750, 604, 142),
]

var room_event_active := false
var room_event: Dictionary = {}
var v23_last_event_floor := -99
var v23_miniboss_intro := 0.0
var null_intro := 0.0

func _process(delta: float) -> void:
	super._process(delta)
	v23_miniboss_intro = maxf(0.0, v23_miniboss_intro - delta)
	null_intro = maxf(0.0, null_intro - delta)

func start_run() -> void:
	room_event_active = false
	room_event.clear()
	v23_last_event_floor = -99
	v23_miniboss_intro = 0.0
	null_intro = 0.0
	super.start_run()

# -----------------------------------------------------------------------------
# Upgrade rarity / Run System 2.0
# -----------------------------------------------------------------------------

func roll_upgrade_options() -> void:
	super.roll_upgrade_options()
	for i: int in range(upgrade_options.size()):
		var option: Dictionary = upgrade_options[i].duplicate(true)
		var tier := _v23_roll_upgrade_tier()
		option["tier"] = String(tier["name"])
		option["strength"] = float(tier["strength"])
		option["tier_color"] = tier["color"]
		option["desc"] = _v23_scaled_upgrade_desc(String(option["kind"]), float(tier["strength"]))
		upgrade_options[i] = option
	_v23_maybe_prepare_room_event()

func _v23_roll_upgrade_tier() -> Dictionary:
	var floor_value := float(run.floor_no if run != null else 1)
	var legendary_chance := minf(0.08, 0.012 + floor_value * 0.0013)
	var epic_chance := minf(0.20, 0.070 + floor_value * 0.0023)
	var rare_chance := minf(0.34, 0.260 + floor_value * 0.0015)
	var roll := rng.randf()
	if roll < legendary_chance:
		return {"name":"LEGENDARY", "strength":2.25, "color":Color("ffb13b")}
	if roll < legendary_chance + epic_chance:
		return {"name":"EPIC", "strength":1.70, "color":Color("b66cff")}
	if roll < legendary_chance + epic_chance + rare_chance:
		return {"name":"RARE", "strength":1.35, "color":Color("58b8ff")}
	return {"name":"COMMON", "strength":1.0, "color":Color("d9d9e2")}

func _v23_scaled_upgrade_desc(kind: String, strength: float) -> String:
	match kind:
		"power": return "+%d%% attack damage" % int(round(25.0 * strength))
		"lifesteal": return "+%.1f%% lifesteal" % (5.0 * strength)
		"multi": return "+%d auto-attack projectile%s" % [2 if strength >= 2.0 else 1, "s" if strength >= 2.0 else ""]
		"haste": return "+%d%% attack speed" % int(round(18.0 * strength))
		"range": return "+%d%% attack range" % int(round(22.0 * strength))
		"vitality": return "+%d max HP and heal" % int(round(25.0 * strength))
		"speed": return "+%d%% move speed" % int(round(12.0 * strength))
		"crit": return "+%.1f%% critical chance" % (8.0 * strength)
		"nova": return "+%d%% NOVA damage and radius" % int(round(25.0 * strength))
		"armor": return "+%.1f%% damage reduction" % (8.0 * strength)
	return "Run upgrade"

func apply_upgrade(index: int) -> void:
	if index < 0 or index >= upgrade_options.size():
		return
	var option: Dictionary = upgrade_options[index]
	var strength := float(option.get("strength", 1.0))
	var kind := String(option.get("kind", ""))
	if run.has_method("apply_upgrade_scaled"):
		run.apply_upgrade_scaled(kind, strength)
	else:
		run.apply_upgrade(kind)
	state = State.DECISION

	var tier := String(option.get("tier", "COMMON"))
	if tier != "COMMON":
		loot_notice = "%s UPGRADE — %s" % [tier, String(option.get("name", "UPGRADE"))]
		loot_notice_color = option.get("tier_color", C_GOLD)
		loot_notice_time = 1.8

	if run.has_method("consume_synergy_notice"):
		var unlocked := String(run.consume_synergy_notice())
		if not unlocked.is_empty():
			loot_notice = "SYNERGY UNLOCKED — %s" % unlocked
			loot_notice_color = C_CYAN
			loot_notice_time = 2.6
			_audio("claim")

func draw_upgrade() -> void:
	if room_event_active:
		_v23_draw_room_event()
		return
	super.draw_upgrade()
	for i: int in range(upgrade_options.size()):
		var option: Dictionary = upgrade_options[i]
		var tier := String(option.get("tier", "COMMON"))
		var tier_color: Color = option.get("tier_color", C_MUTED)
		var r := upgrade_rect(i)
		draw_string(font, Vector2(r.end.x - 142.0, r.position.y + 28.0), tier, HORIZONTAL_ALIGNMENT_RIGHT, 122.0, 12, tier_color)

# -----------------------------------------------------------------------------
# Between-floor room events
# -----------------------------------------------------------------------------

func _v23_maybe_prepare_room_event() -> void:
	room_event_active = false
	room_event.clear()
	if run == null or int(run.floor_no) < 3:
		return
	if String(current_room.get("type", "")) == "BOSS":
		return
	if int(run.floor_no) - v23_last_event_floor < 3:
		return
	var floor_no := int(run.floor_no)
	var guaranteed := floor_no in [8, 18, 28, 38, 48]
	if not guaranteed and rng.randf() >= 0.18:
		return
	var kinds := ["blood_altar", "arcane_shrine", "lost_merchant"]
	_v23_set_room_event(String(kinds[rng.randi_range(0, kinds.size() - 1)]))
	v23_last_event_floor = floor_no

func _v23_set_room_event(kind: String) -> void:
	room_event_active = true
	match kind:
		"blood_altar":
			room_event = {"type":kind, "title":"BLOOD ALTAR", "subtitle":"Power always asks for something in return."}
		"arcane_shrine":
			room_event = {"type":kind, "title":"ARCANE SHRINE", "subtitle":"Choose one blessing before the climb continues."}
		_:
			room_event = {"type":"lost_merchant", "title":"LOST MERCHANT", "subtitle":"A masked trader waits where no shop should exist."}

func _v23_event_choices() -> Array[Dictionary]:
	var kind := String(room_event.get("type", ""))
	if kind == "blood_altar":
		return [
			{"title":"PAY IN BLOOD", "desc":"Lose 20% current HP • +18% damage • +4% crit", "accent":C_RED},
			{"title":"OFFER COINS", "desc":"Lose 15% run coins • +5% lifesteal", "accent":C_GOLD},
			{"title":"WALK AWAY", "desc":"Keep the run exactly as it is", "accent":C_MUTED},
		]
	if kind == "arcane_shrine":
		return [
			{"title":"RESTORATION", "desc":"Heal 35% max HP", "accent":C_GREEN},
			{"title":"NOVA BLESSING", "desc":"+20% NOVA damage • +18 radius", "accent":C_CYAN},
			{"title":"WIND BLESSING", "desc":"+10% speed • +8% attack speed", "accent":C_BLUE},
		]
	var cost := 55 + int(run.floor_no) * 5
	return [
		{"title":"BUY VOID BLADE", "desc":"%d coins • +16%% damage" % cost, "accent":C_RED},
		{"title":"BUY AEGIS CHARM", "desc":"%d coins • +30 max HP • +3%% armor" % cost, "accent":C_GOLD},
		{"title":"DECLINE", "desc":"Save your unsecured coins", "accent":C_MUTED},
	]

func _v23_resolve_room_event(index: int) -> void:
	if index < 0 or index > 2 or not room_event_active:
		return
	var kind := String(room_event.get("type", ""))
	var result := "EVENT PASSED"
	if kind == "blood_altar":
		if index == 0:
			run.hp = maxf(1.0, run.hp * 0.80)
			run.damage *= 1.18
			run.crit_chance = minf(0.68, run.crit_chance + 0.04)
			result = "BLOOD ALTAR — POWER ACCEPTED"
		elif index == 1:
			var payment := int(round(float(run.run_coins) * 0.15))
			run.run_coins = maxi(0, run.run_coins - payment)
			run.lifesteal = minf(0.36, run.lifesteal + 0.05)
			result = "BLOOD ALTAR — OFFER ACCEPTED"
		else:
			result = "BLOOD ALTAR — LEFT UNTOUCHED"
	elif kind == "arcane_shrine":
		if index == 0:
			run.hp = minf(run.max_hp, run.hp + run.max_hp * 0.35)
			result = "SHRINE — RESTORED"
		elif index == 1:
			run.nova_mult *= 1.20
			run.nova_radius = minf(440.0, run.nova_radius + 18.0)
			result = "SHRINE — NOVA BLESSED"
		else:
			run.speed *= 1.10
			run.attack_delay = maxf(0.16, run.attack_delay * 0.92)
			result = "SHRINE — WIND BLESSED"
	else:
		var cost := 55 + int(run.floor_no) * 5
		if index < 2 and int(run.run_coins) < cost:
			loot_notice = "NOT ENOUGH RUN COINS"
			loot_notice_color = C_RED
			loot_notice_time = 1.4
			return
		if index == 0:
			run.run_coins -= cost
			run.damage *= 1.16
			result = "MERCHANT — VOID BLADE BOUGHT"
		elif index == 1:
			run.run_coins -= cost
			run.max_hp += 30.0
			run.hp = minf(run.max_hp, run.hp + 30.0)
			run.armor = minf(0.55, run.armor + 0.03)
			result = "MERCHANT — AEGIS CHARM BOUGHT"
		else:
			result = "MERCHANT — NO DEAL"

	room_event_active = false
	room_event.clear()
	loot_notice = result
	loot_notice_color = C_GOLD
	loot_notice_time = 2.0
	_audio("claim")

func _v23_draw_room_event() -> void:
	_v12_background(C_PURPLE)
	_v12_title(String(room_event.get("title", "TOWER EVENT")), 168, 42, C_GOLD)
	draw_string(font, Vector2(72, 235), String(room_event.get("subtitle", "")), HORIZONTAL_ALIGNMENT_CENTER, 576, 17, C_MUTED)
	draw_string(font, Vector2(72, 290), "FLOOR %d EVENT" % int(run.floor_no), HORIZONTAL_ALIGNMENT_CENTER, 576, 13, C_PURPLE)
	var choices := _v23_event_choices()
	for i: int in range(choices.size()):
		var choice: Dictionary = choices[i]
		var r: Rect2 = EVENT_RECTS[i]
		var accent: Color = choice["accent"]
		panel(r, Color("0b1020"), accent)
		text(String(choice["title"]), r.position + Vector2(24, 52), 22, C_TEXT)
		text(String(choice["desc"]), r.position + Vector2(24, 91), 15, C_MUTED)
	draw_string(font, Vector2(70, 1015), "Room events affect this run only.", HORIZONTAL_ALIGNMENT_CENTER, 580, 14, C_MUTED)

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if pressed and state == State.UPGRADE and room_event_active:
		for i: int in range(EVENT_RECTS.size()):
			if EVENT_RECTS[i].has_point(pos):
				_v23_resolve_room_event(i)
				return
		return
	super.pointer(pos, pressed, id)

# -----------------------------------------------------------------------------
# Miniboss encounters and Floors 41-50
# -----------------------------------------------------------------------------

func spawn_floor() -> void:
	if int(run.floor_no) == 50:
		_v23_spawn_null_sovereign()
		return
	super.spawn_floor()
	if String(current_room.get("type", "")) == "MINIBOSS":
		_v23_setup_miniboss_room()

func _v23_setup_miniboss_room() -> void:
	enemies.clear()
	var pool: Array[String] = room_system.enemy_pool(String(current_room.get("area", "DUNGEON")), int(run.floor_no))
	if pool.is_empty():
		return
	var boss_kind := String(pool[rng.randi_range(0, pool.size() - 1)])
	var mini: Dictionary = EnemyFactory.make_enemy(boss_kind, int(run.floor_no), rng, player_pos)
	mini["max_hp"] = float(mini["max_hp"]) * 4.5
	mini["hp"] = mini["max_hp"]
	mini["touch_damage"] = float(mini["touch_damage"]) * 1.55
	mini["reward"] = int(round(float(mini["reward"]) * 4.8))
	mini["radius"] = float(mini["radius"]) * 1.28
	mini["elite"] = true
	mini["miniboss"] = true
	enemies.append(mini)
	var guards := 2 if int(run.floor_no) >= 31 else (1 if int(run.floor_no) >= 16 else 0)
	for i: int in range(guards):
		var guard_kind := String(pool[rng.randi_range(0, pool.size() - 1)])
		enemies.append(EnemyFactory.make_enemy(guard_kind, int(run.floor_no), rng, player_pos))
	v23_miniboss_intro = 1.5
	_audio("warden")

func _v23_spawn_null_sovereign() -> void:
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
	hollow_intro = 0.0
	astral_intro = 0.0
	null_intro = 2.0
	enemies.append(EnemyFactory.make_enemy("null_sovereign", int(run.floor_no), rng, player_pos))
	for kind in ["oathbreaker", "phase_stalker", "orb_weaver"]:
		enemies.append(EnemyFactory.make_enemy(String(kind), int(run.floor_no), rng, player_pos))
	_audio("warden")

func update_room_hazard(delta: float) -> void:
	if String(current_room.get("area", "")) != "STARLESS SPIRE" or String(current_room.get("type", "")) == "BOSS":
		super.update_room_hazard(delta)
		return
	hazard_timer -= delta
	if hazard_timer > 0.0:
		return
	var hazard := String(current_room.get("hazard", "none"))
	var damage_value := 12.0 + float(run.floor_no) * 0.36
	if hazard == "gravity_well":
		var center := ARENA.get_center()
		for angle_index: int in range(12):
			var angle := TAU * float(angle_index) / 12.0
			var start := center + Vector2.from_angle(angle) * 360.0
			var dir := (center - start).normalized()
			enemy_shots.append({"pos":start,"vel":dir*265.0,"damage":damage_value,"life":3.2,"color":C_PURPLE if angle_index%2==0 else C_CYAN})
		hazard_timer = 4.6
	else:
		for i: int in range(7):
			var x := rng.randf_range(80.0, 640.0)
			var start := Vector2(x, ARENA.position.y + rng.randf_range(0.0, 70.0))
			var drift := rng.randf_range(-70.0, 70.0)
			enemy_shots.append({"pos":start,"vel":Vector2(drift, 330.0),"damage":damage_value,"life":3.0,"color":C_CYAN if i%2==0 else C_PURPLE})
		hazard_timer = 4.1

func update_enemies(delta: float) -> void:
	super.update_enemies(delta)
	for i: int in range(enemies.size()):
		var e: Dictionary = enemies[i]
		var kind := String(e.get("type", ""))
		if not kind in ["phase_stalker", "orb_weaver", "oathbreaker"]:
			continue
		var p: Vector2 = e["pos"]
		var to_player := player_pos - p
		var dist := to_player.length()
		if kind == "phase_stalker":
			e["phase_cd"] = maxf(0.0, float(e.get("phase_cd", 0.0)) - delta)
			e["phase_time"] = maxf(0.0, float(e.get("phase_time", 0.0)) - delta)
			if float(e["phase_cd"]) <= 0.0:
				effects.append({"type":"phase2","pos":p,"age":0.0,"dur":0.28,"color":C_PURPLE,"kind":""})
				var offset := Vector2.from_angle(rng.randf_range(0.0, TAU)) * rng.randf_range(95.0, 180.0)
				p = clamp_to_arena(player_pos + offset, float(e["radius"]))
				e["phase_time"] = 0.30
				e["phase_cd"] = 2.65
			if dist > 1.0:
				var weave := Vector2(-to_player.y, to_player.x).normalized() * sin(elapsed * 7.0 + float(e.get("phase", 0.0))) * 0.20
				p += (to_player.normalized() + weave).normalized() * float(e["speed"]) * delta
		elif kind == "orb_weaver":
			p = _ranged_enemy_step(e, p, to_player, dist, delta, 270.0, 450.0)
			e["orbit_angle"] = float(e.get("orbit_angle", 0.0)) + delta * 1.4
			if float(e["attack_cd"]) <= 0.0 and dist < 600.0:
				var base_angle := float(e["orbit_angle"])
				for shot_index: int in range(5):
					var dir := Vector2.from_angle(base_angle + TAU * float(shot_index) / 5.0)
					enemy_shots.append({"pos":p+dir*26.0,"vel":dir*255.0,"damage":17.0+float(run.floor_no)*0.60,"life":3.1,"color":C_CYAN})
				e["attack_cd"] = 1.30
		else:
			e["slam_cd"] = maxf(0.0, float(e.get("slam_cd", 0.0)) - delta)
			if dist > 120.0 and dist > 1.0:
				p += to_player.normalized() * float(e["speed"]) * delta
			if float(e["slam_cd"]) <= 0.0 and dist < 220.0:
				for shot_index: int in range(8):
					var dir := Vector2.from_angle(TAU * float(shot_index) / 8.0)
					enemy_shots.append({"pos":p+dir*34.0,"vel":dir*220.0,"damage":18.0+float(run.floor_no)*0.66,"life":2.8,"color":C_GOLD})
				e["slam_cd"] = 2.8
				effects.append({"type":"keeper_cast","pos":p,"age":0.0,"dur":0.30,"color":C_GOLD,"kind":""})
		e["pos"] = clamp_to_arena(p, float(e["radius"]))
		var new_dist := player_pos.distance_to(e["pos"])
		if new_dist < 34.0 + float(e["radius"]) and float(e["touch_cd"]) <= 0.0:
			damage_player(float(e["touch_damage"]), e["pos"])
			e["touch_cd"] = 0.62
		enemies[i] = e

func apply_damage_to_enemy(index: int, amount: float, crit: bool, hit_pos: Vector2) -> void:
	if index >= 0 and index < enemies.size() and String(enemies[index].get("type", "")) == "oathbreaker":
		amount *= 1.0 - float(enemies[index].get("guard", 0.22))
	super.apply_damage_to_enemy(index, amount, crit, hit_pos)

func update_warden(e: Dictionary, p: Vector2, to_player: Vector2, dist: float, delta: float) -> void:
	if String(e.get("boss_variant", "warden")) != "null_sovereign":
		super.update_warden(e, p, to_player, dist, delta)
		return
	var hp_ratio := clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
	if hp_ratio <= 0.45 and not bool(e["phase2"]):
		e["phase2"] = true
		e["attack_cd"] = 0.18
		effects.append({"type":"phase2","pos":p,"age":0.0,"dur":1.0,"color":C_PURPLE,"kind":""})
		screen_shake = 17.0
		haptic(100)

	e["teleport_cd"] = maxf(0.0, float(e.get("teleport_cd", 0.0)) - delta)
	if float(e["teleport_cd"]) <= 0.0:
		var spots := [Vector2(125,290), Vector2(595,290), Vector2(125,875), Vector2(595,875), Vector2(360,470)]
		p = spots[rng.randi_range(0, spots.size() - 1)]
		e["pos"] = p
		e["teleport_cd"] = 1.95 if bool(e["phase2"]) else 2.9
		effects.append({"type":"keeper_cast","pos":p,"age":0.0,"dur":0.36,"color":C_PURPLE,"kind":""})
		for shot_index: int in range(10):
			var dir := Vector2.from_angle(TAU * float(shot_index) / 10.0)
			enemy_shots.append({"pos":p+dir*60.0,"vel":dir*255.0,"damage":21.0+float(run.floor_no)*0.74,"life":3.0,"color":C_PURPLE if shot_index%2==0 else C_CYAN})

	if float(e["cast_timer"]) > 0.0:
		e["cast_timer"] = maxf(0.0, float(e["cast_timer"]) - delta)
		if float(e["cast_timer"]) <= 0.0:
			execute_warden_cast(e)
			e["cast_kind"] = ""
			e["attack_cd"] = 0.62 if bool(e["phase2"]) else 0.92
		return
	if float(e["attack_cd"]) <= 0.0:
		var attack_index := int(e["attack_index"])
		e["cast_kind"] = "eclipse" if attack_index % 2 == 0 else "starburst"
		e["cast_timer"] = 0.30 if bool(e["phase2"]) else 0.44
		e["attack_index"] = attack_index + 1
		effects.append({"type":"warden_telegraph","pos":p,"age":0.0,"dur":float(e["cast_timer"]),"color":C_PURPLE,"kind":String(e["cast_kind"])})
		return
	if dist > 185.0 and dist > 1.0:
		p += to_player.normalized() * float(e["speed"]) * delta
	e["pos"] = clamp_to_arena(p, float(e["radius"]))

func execute_warden_cast(e: Dictionary) -> void:
	if String(e.get("boss_variant", "warden")) != "null_sovereign":
		super.execute_warden_cast(e)
		return
	var p: Vector2 = e["pos"]
	var phase2 := bool(e["phase2"])
	if String(e["cast_kind"]) == "eclipse":
		var aim := (player_pos - p).normalized()
		var count := 17 if phase2 else 13
		for shot_index: int in range(count):
			var spread := (float(shot_index) - float(count - 1) * 0.5) * 0.095
			var dir := aim.rotated(spread)
			enemy_shots.append({"pos":p+dir*62.0,"vel":dir*(415.0 if phase2 else 355.0),"damage":23.0+float(run.floor_no)*0.86,"life":2.7,"color":C_PURPLE if shot_index%2==0 else C_CYAN})
	else:
		var count := 30 if phase2 else 22
		var offset := float(e["attack_index"]) * 0.11
		for shot_index: int in range(count):
			var dir := Vector2.from_angle(offset + TAU * float(shot_index) / float(count))
			enemy_shots.append({"pos":p+dir*62.0,"vel":dir*(365.0 if phase2 else 300.0),"damage":22.0+float(run.floor_no)*0.82,"life":3.3,"color":C_CYAN if shot_index%2==0 else C_PURPLE})
		if phase2:
			for shot_index: int in range(12):
				var dir := Vector2.from_angle(offset + PI / 12.0 + TAU * float(shot_index) / 12.0)
				enemy_shots.append({"pos":p+dir*56.0,"vel":dir*250.0,"damage":20.0+float(run.floor_no)*0.76,"life":3.5,"color":C_GOLD})
	effects.append({"type":"keeper_cast","pos":p,"age":0.0,"dur":0.42,"color":C_PURPLE,"kind":""})
	screen_shake = maxf(screen_shake, 11.0 if phase2 else 7.0)
	haptic(40)

# -----------------------------------------------------------------------------
# Reuse existing production art for the new gameplay entities.
# -----------------------------------------------------------------------------

func _v12_actor_index(kind: String, variant: String) -> int:
	match kind:
		"phase_stalker": return 8
		"orb_weaver": return 10
		"oathbreaker": return 9
		"warden":
			if variant == "null_sovereign": return 11
	return super._v12_actor_index(kind, variant)

func _motion_row(kind: String, variant: String = "warden") -> int:
	match kind:
		"phase_stalker": return 8
		"orb_weaver": return 10
		"oathbreaker": return 9
		"warden":
			if variant == "null_sovereign": return 11
	return super._motion_row(kind, variant)

func enemy_color(kind: String) -> Color:
	match kind:
		"phase_stalker": return Color("8f62ff")
		"orb_weaver": return Color("55dbff")
		"oathbreaker": return Color("d2a24d")
	return super.enemy_color(kind)

func _v14_room_index(area: String) -> int:
	if area == "STARLESS SPIRE":
		return 3
	return super._v14_room_index(area)

func _draw_boss_ui() -> void:
	var boss: Dictionary = {}
	for e: Dictionary in enemies:
		if String(e.get("type", "")) == "warden" and String(e.get("boss_variant", "")) == "null_sovereign":
			boss = e
			break
	if boss.is_empty():
		super._draw_boss_ui()
		return
	var ratio := clampf(float(boss["hp"]) / float(boss["max_hp"]), 0.0, 1.0)
	var accent := C_RED if bool(boss["phase2"]) else C_PURPLE
	panel(Rect2(80, 154, 560, 62), Color("090913"), accent)
	text("THE NULL SOVEREIGN", Vector2(102, 181), 15, C_TEXT)
	draw_rect(Rect2(276, 178, 336, 14), Color("281426"))
	draw_rect(Rect2(276, 178, 336 * ratio, 14), accent)
	if null_intro > 0.0:
		var alpha := clampf(null_intro, 0.0, 1.0)
		draw_rect(Rect2(42, 460, 636, 196), Color(0.01, 0.005, 0.02, 0.93 * alpha))
		var title_color := C_PURPLE
		title_color.a = alpha
		draw_string(font, Vector2(66, 536), "THE NULL SOVEREIGN", HORIZONTAL_ALIGNMENT_CENTER, 588, 42, title_color)
		draw_string(font, Vector2(66, 590), "FLOOR 50  •  CROWN OF THE STARLESS SPIRE", HORIZONTAL_ALIGNMENT_CENTER, 588, 16, C_TEXT)

func draw_game() -> void:
	super.draw_game()
	_v23_draw_synergy_strip()
	_v23_draw_miniboss_ui()

func _v23_draw_synergy_strip() -> void:
	if run == null or not run.has_method("active_synergy_names"):
		return
	var names: Array[String] = run.active_synergy_names()
	if names.is_empty():
		return
	var shown: Array[String] = []
	for i: int in range(mini(2, names.size())):
		shown.append(names[i])
	var suffix := " +%d" % (names.size() - 2) if names.size() > 2 else ""
	var label := "SYNERGIES %d • %s%s" % [names.size(), " • ".join(shown), suffix]
	draw_rect(Rect2(150, 964, 420, 30), Color(0.02, 0.04, 0.09, 0.82))
	draw_rect(Rect2(150, 964, 420, 30), Color(C_CYAN, 0.35), false, 1.0)
	draw_string(font, Vector2(160, 984), label, HORIZONTAL_ALIGNMENT_CENTER, 400, 10, C_CYAN)

func _v23_draw_miniboss_ui() -> void:
	var mini: Dictionary = {}
	for e: Dictionary in enemies:
		if bool(e.get("miniboss", false)):
			mini = e
			break
	if mini.is_empty():
		return
	var ratio := clampf(float(mini["hp"]) / float(mini["max_hp"]), 0.0, 1.0)
	panel(Rect2(112, 158, 496, 54), Color("11101a"), C_GOLD)
	text("MINI-BOSS • %s" % _v23_enemy_name(String(mini.get("type", "ENEMY"))), Vector2(132, 181), 14, C_TEXT)
	draw_rect(Rect2(300, 178, 280, 12), Color("3a2614"))
	draw_rect(Rect2(300, 178, 280 * ratio, 12), C_GOLD)
	if v23_miniboss_intro > 0.0:
		var alpha := clampf(v23_miniboss_intro, 0.0, 1.0)
		draw_rect(Rect2(95, 485, 530, 116), Color(0.02, 0.015, 0.02, 0.84 * alpha))
		var c := C_GOLD
		c.a = alpha
		draw_string(font, Vector2(115, 548), "MINI-BOSS", HORIZONTAL_ALIGNMENT_CENTER, 490, 34, c)

func _v23_enemy_name(kind: String) -> String:
	match kind:
		"goblin": return "GOBLIN BRUTE"
		"bat": return "NIGHT SWARM"
		"skeleton": return "BONE CHAMPION"
		"ghoul": return "RAVENOUS GHOUL"
		"necromancer": return "SOUL CALLER"
		"gargoyle": return "STONE HUNTER"
		"sentinel": return "ROYAL SENTINEL"
		"hexer": return "CURSE HEXER"
		"void_knight": return "VOID KNIGHT"
		"rift_mage": return "RIFT MAGE"
		"soul_reaver": return "SOUL REAVER"
		"phase_stalker": return "PHASE STALKER"
		"orb_weaver": return "ORB WEAVER"
		"oathbreaker": return "OATHBREAKER"
	return kind.replace("_", " ").to_upper()

func _v23_gameplay_ready() -> bool:
	return run != null and room_system != null and run.has_method("apply_upgrade_scaled") and run.has_method("active_synergy_names")
