extends "res://scripts/main_v27.gd"

# ONE MORE FLOOR v1.15 — Endgame Realms.
# Floors beyond 50 are now different places instead of the same room with larger
# numbers. Each realm has its own roster, hazard language and boss pattern. The
# existing Endless Ascension multiplier still sits underneath all of this, so
# permanent upgrades and deep loot remain necessary rather than cosmetic.

const V28_VERSION := "1.15-endgame-realms"
const V28_REALMS := ["VOID CITADEL", "ECLIPSE SANCTUM", "BLOODSTAR KEEP", "CELESTIAL GRAVE"]

var v28_boss_intro := 0.0
var v28_realm_flash := 0.0

func _process(delta: float) -> void:
	super._process(delta)
	v28_boss_intro = maxf(0.0, v28_boss_intro - delta)
	v28_realm_flash = maxf(0.0, v28_realm_flash - delta)

func start_run() -> void:
	super.start_run()
	if run != null and int(run.floor_no) >= 51:
		v28_realm_flash = 2.4

func spawn_floor() -> void:
	super.spawn_floor()
	if run == null or int(run.floor_no) <= 50:
		return
	if String(current_room.get("type", "")) == "BOSS":
		_v28_replace_realm_boss()
	if int(run.floor_no) in [51, 100, 150, 200]:
		v28_realm_flash = 2.6

func _v28_replace_realm_boss() -> void:
	var floor_no := int(run.floor_no)
	var area := String(current_room.get("area", room_system.area_for_floor(floor_no)))
	var boss_kind := _v28_boss_kind_for_area(area)
	if boss_kind.is_empty():
		return

	enemies.clear()
	player_shots.clear()
	enemy_shots.clear()
	coin_orbs.clear()
	player_pos = Vector2(360, 700)
	var boss: Dictionary = EnemyFactory.make_enemy(boss_kind, floor_no, rng, player_pos)
	var milestone := floor_no in [100, 150, 200] or (floor_no > 200 and floor_no % 50 == 0)
	boss["milestone"] = milestone
	if milestone:
		boss["max_hp"] = float(boss["max_hp"]) * 1.35
		boss["hp"] = boss["max_hp"]
		boss["touch_damage"] = float(boss["touch_damage"]) * 1.15
		boss["reward"] = int(round(float(boss["reward"]) * 1.50))
	enemies.append(boss)

	var pool: Array[String] = room_system.enemy_pool(area, floor_no)
	var escort_count := mini(4, 1 + room_system.endgame_realm_tier(floor_no))
	for i in range(escort_count):
		if pool.is_empty():
			break
		var kind := String(pool[(i + floor_no) % pool.size()])
		enemies.append(EnemyFactory.make_enemy(kind, floor_no, rng, player_pos))

	# These enemies were created after v1.13/v1.14's normal spawn pipeline, so
	# explicitly run the same modifier, affix and Ascension passes on them.
	_v25_apply_modifier_to_spawned_enemies()
	_v25_apply_elite_affixes()
	_v27_scale_floor_enemies()
	v28_boss_intro = 2.2
	_audio("warden")

func _v28_boss_kind_for_area(area: String) -> String:
	match area:
		"VOID CITADEL": return "void_archon"
		"ECLIPSE SANCTUM": return "eclipse_regent"
		"BLOODSTAR KEEP": return "bloodstar_tyrant"
		"CELESTIAL GRAVE": return "world_eater"
	return ""

func _v28_boss_title(variant: String) -> String:
	match variant:
		"void_archon": return "VOID ARCHON"
		"eclipse_regent": return "ECLIPSE REGENT"
		"bloodstar_tyrant": return "BLOODSTAR TYRANT"
		"world_eater": return "WORLD EATER"
	return "WARDEN"

# -----------------------------------------------------------------------------
# Endgame enemy abilities
# -----------------------------------------------------------------------------

func update_enemies(delta: float) -> void:
	super.update_enemies(delta)
	if run == null or int(run.floor_no) <= 50:
		return
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		var kind := String(e.get("type", ""))
		if kind == "warden" or not _v28_is_endgame_kind(kind):
			continue
		e["ability_cd"] = maxf(0.0, float(e.get("ability_cd", 0.0)) - delta)
		var p: Vector2 = e.get("pos", Vector2.ZERO)
		var to_player := player_pos - p
		var dist := to_player.length()

		# Ranged endgame enemies actively try to keep a firing lane instead of
		# behaving like another melee blob after the inherited movement step.
		if kind in ["soul_cannon", "eclipse_oracle", "hemomancer", "cosmic_eye"]:
			if dist < 240.0 and dist > 1.0:
				p -= to_player.normalized() * float(e.get("speed", 60.0)) * delta * 0.75
			elif dist > 450.0 and dist > 1.0:
				p += to_player.normalized() * float(e.get("speed", 60.0)) * delta * 0.30

		if float(e["ability_cd"]) <= 0.0:
			_v28_fire_enemy_ability(e, kind, p, to_player, dist)
		p = e.get("pos", p)
		e["pos"] = clamp_to_arena(p, float(e.get("radius", 24.0)))
		enemies[i] = e

func _v28_is_endgame_kind(kind: String) -> bool:
	return kind in [
		"void_lancer", "rift_hound", "soul_cannon",
		"eclipse_oracle", "shade_duelist", "sunless_guard",
		"blood_seraph", "chain_titan", "hemomancer",
		"star_devourer", "crownless", "cosmic_eye"
	]

func _v28_fire_enemy_ability(e: Dictionary, kind: String, p: Vector2, to_player: Vector2, dist: float) -> void:
	var floor_no := float(run.floor_no)
	var aim := to_player.normalized() if dist > 1.0 else Vector2.DOWN
	match kind:
		"void_lancer", "shade_duelist", "blood_seraph", "crownless":
			var dash_distance := 105.0
			if kind == "blood_seraph": dash_distance = 135.0
			if kind == "crownless": dash_distance = 155.0
			e["pos"] = clamp_to_arena(p + aim * dash_distance, float(e.get("radius", 25.0)))
			for offset in [-0.24, 0.0, 0.24]:
				var dir := aim.rotated(float(offset))
				enemy_shots.append({"pos":e["pos"], "vel":dir * 315.0, "damage":13.0 + floor_no * 0.34, "life":2.2, "color":_v28_kind_accent(kind)})
			e["ability_cd"] = 1.8 if kind != "crownless" else 1.35
			effects.append({"type":"phase2", "pos":e["pos"], "age":0.0, "dur":0.25, "color":_v28_kind_accent(kind), "kind":""})
		"rift_hound":
			e["pos"] = clamp_to_arena(p + aim * 125.0, float(e.get("radius", 27.0)))
			e["ability_cd"] = 2.2
			effects.append({"type":"slash", "pos":e["pos"], "dir":aim, "age":0.0, "dur":0.18, "color":C_PURPLE, "kind":""})
		"soul_cannon":
			for n in range(5):
				var spread := (float(n) - 2.0) * 0.14
				var dir := aim.rotated(spread)
				enemy_shots.append({"pos":p + dir * 28.0, "vel":dir * 300.0, "damage":14.0 + floor_no * 0.38, "life":2.8, "color":C_CYAN})
			e["ability_cd"] = 2.55
		"eclipse_oracle":
			_v28_radial_projectiles(p, 10, 255.0, 13.0 + floor_no * 0.36, C_PURPLE, float(e.get("phase", 0.0)))
			e["ability_cd"] = 2.25
		"sunless_guard":
			_v28_radial_projectiles(p, 12, 225.0, 16.0 + floor_no * 0.40, C_GOLD, 0.0)
			e["ability_cd"] = 2.7
			effects.append({"type":"keeper_cast", "pos":p, "age":0.0, "dur":0.28, "color":C_GOLD, "kind":""})
		"chain_titan":
			_v28_radial_projectiles(p, 14, 245.0, 18.0 + floor_no * 0.44, C_RED, float(e.get("phase", 0.0)))
			e["ability_cd"] = 2.35
			effects.append({"type":"keeper_cast", "pos":p, "age":0.0, "dur":0.32, "color":C_RED, "kind":""})
		"hemomancer":
			for offset in [-0.32, 0.0, 0.32]:
				var dir := aim.rotated(float(offset))
				enemy_shots.append({"pos":p, "vel":dir * 330.0, "damage":16.0 + floor_no * 0.40, "life":2.7, "color":C_RED})
			e["hp"] = minf(float(e.get("max_hp", 1.0)), float(e.get("hp", 1.0)) + float(e.get("max_hp", 1.0)) * 0.035)
			e["ability_cd"] = 2.0
		"star_devourer":
			_v28_radial_projectiles(p, 16, 270.0, 20.0 + floor_no * 0.46, C_CYAN, elapsed * 0.45)
			e["ability_cd"] = 2.1
		"cosmic_eye":
			_v28_radial_projectiles(p, 12, 305.0, 17.0 + floor_no * 0.41, C_PURPLE, elapsed * 0.72)
			for offset in [-0.18, 0.18]:
				var dir := aim.rotated(float(offset))
				enemy_shots.append({"pos":p, "vel":dir * 365.0, "damage":18.0 + floor_no * 0.43, "life":2.4, "color":C_CYAN})
			e["ability_cd"] = 1.75

func _v28_radial_projectiles(pos: Vector2, count: int, speed: float, damage_value: float, color: Color, offset: float) -> void:
	for n in range(count):
		var angle := offset + TAU * float(n) / float(count)
		var dir := Vector2.from_angle(angle)
		enemy_shots.append({"pos":pos + dir * 24.0, "vel":dir * speed, "damage":damage_value, "life":3.0, "color":color})

# -----------------------------------------------------------------------------
# Realm hazards
# -----------------------------------------------------------------------------

func update_room_hazard(delta: float) -> void:
	var area := String(current_room.get("area", ""))
	if not area in V28_REALMS or String(current_room.get("type", "")) == "BOSS":
		super.update_room_hazard(delta)
		return
	hazard_timer -= delta
	if hazard_timer > 0.0:
		return
	var hazard := String(current_room.get("hazard", "none"))
	var floor_no := float(run.floor_no)
	var damage_value := 14.0 + floor_no * 0.30
	match hazard:
		"void_crossfire":
			for y in [300.0, 500.0, 700.0, 900.0]:
				var from_left := rng.randf() < 0.5
				var start := Vector2(ARENA.position.x + 5.0 if from_left else ARENA.end.x - 5.0, y)
				var dir := Vector2.RIGHT if from_left else Vector2.LEFT
				enemy_shots.append({"pos":start, "vel":dir * 330.0, "damage":damage_value, "life":2.5, "color":C_PURPLE})
			hazard_timer = 3.4
		"collapsing_runes":
			for n in range(8):
				var start := Vector2(rng.randf_range(70.0, 650.0), ARENA.position.y + rng.randf_range(0.0, 45.0))
				enemy_shots.append({"pos":start, "vel":Vector2(rng.randf_range(-55.0, 55.0), 355.0), "damage":damage_value, "life":2.8, "color":C_CYAN})
			hazard_timer = 3.0
		"eclipse_beams":
			for y in [360.0, 570.0, 780.0]:
				for side in [-1, 1]:
					var start := Vector2(ARENA.position.x + 5.0 if side > 0 else ARENA.end.x - 5.0, y)
					enemy_shots.append({"pos":start, "vel":Vector2(float(side) * 365.0, 0.0), "damage":damage_value * 1.05, "life":2.3, "color":C_GOLD if y == 570.0 else C_PURPLE})
			hazard_timer = 3.6
		"shadow_orbit":
			var center := ARENA.get_center()
			for n in range(12):
				var angle := TAU * float(n) / 12.0 + elapsed * 0.35
				var start := center + Vector2.from_angle(angle) * 365.0
				var dir := (center - start).normalized()
				enemy_shots.append({"pos":start, "vel":dir * 290.0, "damage":damage_value, "life":3.0, "color":C_PURPLE})
			hazard_timer = 3.2
		"blood_rain":
			for n in range(10):
				var start := Vector2(rng.randf_range(60.0, 660.0), ARENA.position.y + rng.randf_range(0.0, 80.0))
				enemy_shots.append({"pos":start, "vel":Vector2(rng.randf_range(-80.0, 80.0), 390.0), "damage":damage_value * 1.08, "life":2.6, "color":C_RED})
			hazard_timer = 2.9
		"chain_sweep":
			var y := rng.randf_range(330.0, 850.0)
			for offset in [-52.0, -26.0, 0.0, 26.0, 52.0]:
				var from_left := rng.randf() < 0.5
				var start := Vector2(ARENA.position.x + 5.0 if from_left else ARENA.end.x - 5.0, y + float(offset))
				var dir := Vector2.RIGHT if from_left else Vector2.LEFT
				enemy_shots.append({"pos":start, "vel":dir * 340.0, "damage":damage_value * 1.10, "life":2.6, "color":C_RED})
			hazard_timer = 3.4
		"comet_storm":
			for n in range(11):
				var start := Vector2(rng.randf_range(40.0, 680.0), ARENA.position.y - 10.0)
				var dir := Vector2(rng.randf_range(-0.35, 0.35), 1.0).normalized()
				enemy_shots.append({"pos":start, "vel":dir * 430.0, "damage":damage_value * 1.12, "life":2.5, "color":C_CYAN if n % 2 == 0 else C_PURPLE})
			hazard_timer = 2.7
		"singularity":
			var target := player_pos
			for n in range(14):
				var angle := TAU * float(n) / 14.0 + elapsed * 0.25
				var start := ARENA.get_center() + Vector2.from_angle(angle) * 380.0
				var dir := (target - start).normalized()
				enemy_shots.append({"pos":start, "vel":dir * 315.0, "damage":damage_value * 1.15, "life":3.1, "color":C_PURPLE})
			hazard_timer = 3.1
		_:
			hazard_timer = 3.2

# -----------------------------------------------------------------------------
# Realm bosses
# -----------------------------------------------------------------------------

func update_warden(e: Dictionary, p: Vector2, to_player: Vector2, dist: float, delta: float) -> void:
	var variant := String(e.get("boss_variant", "warden"))
	if not variant in ["void_archon", "eclipse_regent", "bloodstar_tyrant", "world_eater"]:
		super.update_warden(e, p, to_player, dist, delta)
		return

	var hp_ratio := clampf(float(e.get("hp", 1.0)) / maxf(1.0, float(e.get("max_hp", 1.0))), 0.0, 1.0)
	if hp_ratio <= 0.50 and not bool(e.get("phase2", false)):
		e["phase2"] = true
		e["ability_cd"] = 0.08
		e["attack_cd"] = 0.08
		effects.append({"type":"phase2", "pos":p, "age":0.0, "dur":0.9, "color":_v28_boss_accent(variant), "kind":""})
		screen_shake = 16.0
		haptic(95)

	e["ability_cd"] = maxf(0.0, float(e.get("ability_cd", 0.0)) - delta)
	var phase2 := bool(e.get("phase2", false))
	var milestone := bool(e.get("milestone", false))
	var aim := to_player.normalized() if dist > 1.0 else Vector2.DOWN

	if float(e["ability_cd"]) <= 0.0:
		_v28_boss_special(e, variant, p, aim, phase2, milestone)
		e["ability_cd"] = _v28_boss_special_cooldown(variant, phase2, milestone)
		return

	if float(e.get("attack_cd", 0.0)) <= 0.0:
		var fan_count := 5 if not phase2 else 7
		for n in range(fan_count):
			var center := float(fan_count - 1) * 0.5
			var spread := (float(n) - center) * (0.12 if phase2 else 0.15)
			var dir := aim.rotated(spread)
			enemy_shots.append({"pos":p + dir * 55.0, "vel":dir * (350.0 if phase2 else 315.0), "damage":21.0 + float(run.floor_no) * 0.50, "life":2.6, "color":_v28_boss_accent(variant)})
		e["attack_cd"] = 0.62 if phase2 else 0.86

	if dist > 175.0 and dist > 1.0:
		p += aim * float(e.get("speed", 80.0)) * delta
	e["pos"] = clamp_to_arena(p, float(e.get("radius", 70.0)))

func _v28_boss_special(e: Dictionary, variant: String, p: Vector2, aim: Vector2, phase2: bool, milestone: bool) -> void:
	var floor_no := float(run.floor_no)
	var accent := _v28_boss_accent(variant)
	var bonus_count := 4 if milestone else 0
	match variant:
		"void_archon":
			_v28_radial_projectiles(p, 12 + bonus_count, 285.0, 19.0 + floor_no * 0.46, accent, elapsed * 0.25)
			for offset in [-0.28, 0.0, 0.28]:
				var dir := aim.rotated(float(offset))
				enemy_shots.append({"pos":p, "vel":dir * 390.0, "damage":22.0 + floor_no * 0.50, "life":2.4, "color":C_CYAN})
		"eclipse_regent":
			_v28_radial_projectiles(p, 14 + bonus_count, 300.0, 21.0 + floor_no * 0.48, accent, elapsed * 0.42)
			var spots := [Vector2(135,330), Vector2(585,330), Vector2(135,830), Vector2(585,830), Vector2(360,560)]
			e["pos"] = spots[rng.randi_range(0, spots.size() - 1)]
		"bloodstar_tyrant":
			_v28_radial_projectiles(p, 16 + bonus_count, 315.0, 23.0 + floor_no * 0.52, accent, elapsed * 0.50)
			for offset in [-0.38, -0.19, 0.0, 0.19, 0.38]:
				var dir := aim.rotated(float(offset))
				enemy_shots.append({"pos":p, "vel":dir * 410.0, "damage":24.0 + floor_no * 0.55, "life":2.3, "color":C_RED})
		"world_eater":
			_v28_radial_projectiles(p, 20 + bonus_count, 335.0, 26.0 + floor_no * 0.56, accent, elapsed * 0.58)
			for offset in [-0.45, -0.30, -0.15, 0.0, 0.15, 0.30, 0.45]:
				var dir := aim.rotated(float(offset))
				enemy_shots.append({"pos":p, "vel":dir * 435.0, "damage":27.0 + floor_no * 0.58, "life":2.2, "color":C_CYAN if absf(float(offset)) > 0.2 else C_PURPLE})
	if phase2:
		effects.append({"type":"nova", "pos":p, "age":0.0, "dur":0.36, "color":accent, "kind":""})
	else:
		effects.append({"type":"keeper_cast", "pos":p, "age":0.0, "dur":0.30, "color":accent, "kind":""})
	screen_shake = maxf(screen_shake, 8.0 if not milestone else 12.0)
	haptic(34 if not milestone else 52)

func _v28_boss_special_cooldown(variant: String, phase2: bool, milestone: bool) -> float:
	var base := 2.55
	match variant:
		"eclipse_regent": base = 2.30
		"bloodstar_tyrant": base = 2.10
		"world_eater": base = 1.90
	if phase2:
		base *= 0.78
	if milestone:
		base *= 0.84
	return maxf(1.0, base)

func _v28_boss_accent(variant: String) -> Color:
	match variant:
		"void_archon": return Color("7f5cff")
		"eclipse_regent": return Color("d45cff")
		"bloodstar_tyrant": return Color("ff455f")
		"world_eater": return Color("65e8ff")
	return C_PURPLE

# -----------------------------------------------------------------------------
# Rendering aliases — reuse the production actor sheets, but make the new enemy
# families read as distinct gameplay silhouettes until dedicated actor sheets are
# authored. No placeholder circles are introduced.
# -----------------------------------------------------------------------------

func draw_enemy(e: Dictionary) -> void:
	var original_kind := String(e.get("type", ""))
	var visual := e.duplicate(false)
	var alias := _v28_visual_alias(original_kind)
	if alias != "":
		visual["type"] = alias
	if original_kind == "warden":
		var variant := String(e.get("boss_variant", "warden"))
		match variant:
			"void_archon": visual["boss_variant"] = "astral_warden"
			"eclipse_regent": visual["boss_variant"] = "null_sovereign"
			"bloodstar_tyrant": visual["boss_variant"] = "hollow_king"
			"world_eater": visual["boss_variant"] = "null_sovereign"
	super.draw_enemy(visual)

	if _v28_is_endgame_kind(original_kind):
		var p: Vector2 = e.get("pos", Vector2.ZERO)
		var r := float(e.get("radius", 24.0)) + 8.0
		draw_arc(p, r, 0, TAU, 36, Color(_v28_kind_accent(original_kind), 0.58), 2.2)
	elif original_kind == "warden" and String(e.get("boss_variant", "")) in ["void_archon", "eclipse_regent", "bloodstar_tyrant", "world_eater"]:
		var p: Vector2 = e.get("pos", Vector2.ZERO)
		var r := float(e.get("radius", 70.0)) + 15.0
		var accent := _v28_boss_accent(String(e.get("boss_variant", "")))
		draw_arc(p, r, -2.8, 0.2, 48, Color(accent, 0.78), 4.0)
		draw_arc(p, r + 7.0, 0.35, 2.75, 48, Color(accent, 0.42), 2.5)

func _v28_visual_alias(kind: String) -> String:
	match kind:
		"void_lancer": return "void_knight"
		"rift_hound": return "soul_reaver"
		"soul_cannon": return "rift_mage"
		"eclipse_oracle": return "hexer"
		"shade_duelist": return "phase_stalker"
		"sunless_guard": return "sentinel"
		"blood_seraph": return "gargoyle"
		"chain_titan": return "oathbreaker"
		"hemomancer": return "necromancer"
		"star_devourer": return "oathbreaker"
		"crownless": return "phase_stalker"
		"cosmic_eye": return "orb_weaver"
	return ""

func _v28_kind_accent(kind: String) -> Color:
	match kind:
		"void_lancer", "rift_hound": return Color("7f5cff")
		"soul_cannon": return Color("5adfff")
		"eclipse_oracle", "shade_duelist": return Color("c45cff")
		"sunless_guard": return Color("e9bd66")
		"blood_seraph", "hemomancer": return Color("ff455f")
		"chain_titan": return Color("c86b52")
		"star_devourer", "cosmic_eye": return Color("65e8ff")
		"crownless": return Color("d9a5ff")
	return C_PURPLE

func rarity_color(rarity: String) -> Color:
	if rarity == "MYTHIC":
		return Color("5deaff")
	if rarity == "ASCENDANT":
		return Color("f7c6ff")
	return super.rarity_color(rarity)

func draw_game() -> void:
	super.draw_game()
	if run == null or int(run.floor_no) <= 50:
		return
	var area := String(current_room.get("area", room_system.area_for_floor(int(run.floor_no))))
	var accent := _v28_realm_accent(area)
	var realm_badge := Rect2(242, 317, 236, 38)
	panel(realm_badge, Color(0.02, 0.03, 0.08, 0.94), accent)
	draw_string(font, Vector2(250, 343), area, HORIZONTAL_ALIGNMENT_CENTER, 220, 12, accent)

	if String(current_room.get("type", "")) == "BOSS" and not enemies.is_empty():
		var boss_variant := ""
		for e in enemies:
			if String(e.get("type", "")) == "warden":
				boss_variant = String(e.get("boss_variant", "warden"))
				break
		if boss_variant in ["void_archon", "eclipse_regent", "bloodstar_tyrant", "world_eater"]:
			draw_string(v16_title_font, Vector2(90, 392), _v28_boss_title(boss_variant), HORIZONTAL_ALIGNMENT_CENTER, 540, 20, _v28_boss_accent(boss_variant))

	if v28_realm_flash > 0.0:
		var alpha := clampf(v28_realm_flash / 2.6, 0.0, 1.0)
		var c := accent
		c.a = alpha
		draw_string(v16_title_font, Vector2(70, 610), area, HORIZONTAL_ALIGNMENT_CENTER, 580, 34, c)

func _v28_realm_accent(area: String) -> Color:
	match area:
		"VOID CITADEL": return Color("7f5cff")
		"ECLIPSE SANCTUM": return Color("d45cff")
		"BLOODSTAR KEEP": return Color("ff455f")
		"CELESTIAL GRAVE": return Color("65e8ff")
	return C_PURPLE
