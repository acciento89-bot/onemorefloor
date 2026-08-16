extends RefCounted

static func make_enemy(kind: String, floor_no: int, rng: RandomNumberGenerator, player_pos: Vector2) -> Dictionary:
	var pos: Vector2 = random_spawn_pos(rng, player_pos)
	var base_hp: float = 42.0 + float(floor_no) * 10.0
	if kind == "goblin":
		return _base_enemy("goblin", pos, base_hp, 80.0 + floor_no * 1.4, 22.0, 9.0 + floor_no * 0.55, 4 + floor_no, rng)
	if kind == "bat":
		return _base_enemy("bat", pos, base_hp * 0.66, 132.0 + floor_no * 1.7, 17.0, 7.0 + floor_no * 0.45, 3 + floor_no, rng)
	if kind == "skeleton":
		var skeleton: Dictionary = _base_enemy("skeleton", pos, base_hp * 0.86, 66.0 + floor_no * 1.1, 20.0, 8.0 + floor_no * 0.42, 5 + floor_no, rng)
		skeleton["attack_cd"] = rng.randf_range(0.35, 1.1)
		return skeleton
	if kind == "ghoul":
		var ghoul: Dictionary = _base_enemy("ghoul", pos, base_hp * 1.18, 94.0 + floor_no * 1.45, 24.0, 11.0 + floor_no * 0.56, 7 + floor_no, rng)
		ghoul["rage"] = 0.0
		return ghoul
	if kind == "necromancer":
		var necro: Dictionary = _base_enemy("necromancer", pos, base_hp * 0.95, 54.0 + floor_no * 0.8, 23.0, 8.0 + floor_no * 0.4, 9 + floor_no, rng)
		necro["attack_cd"] = rng.randf_range(0.4, 1.0)
		necro["summon_cd"] = rng.randf_range(2.8, 4.2)
		return necro
	if kind == "gargoyle":
		var gargoyle: Dictionary = _base_enemy("gargoyle", pos, base_hp * 1.06, 92.0 + floor_no * 1.25, 25.0, 12.0 + floor_no * 0.58, 10 + floor_no, rng)
		gargoyle["dive_cd"] = rng.randf_range(1.4, 2.8)
		gargoyle["dive_time"] = 0.0
		return gargoyle
	if kind == "sentinel":
		var sentinel: Dictionary = _base_enemy("sentinel", pos, base_hp * 1.72, 48.0 + floor_no * 0.7, 28.0, 14.0 + floor_no * 0.62, 13 + floor_no, rng)
		sentinel["guard"] = 0.30
		sentinel["attack_cd"] = rng.randf_range(0.4, 1.0)
		return sentinel
	if kind == "hexer":
		var hexer: Dictionary = _base_enemy("hexer", pos, base_hp * 0.92, 60.0 + floor_no * 0.9, 22.0, 10.0 + floor_no * 0.46, 14 + floor_no, rng)
		hexer["attack_cd"] = rng.randf_range(0.35, 0.9)
		hexer["blink_cd"] = rng.randf_range(2.6, 4.2)
		return hexer
	if kind == "crypt_keeper":
		var keeper_hp: float = 520.0 + float(floor_no) * 58.0
		var keeper: Dictionary = _base_enemy("warden", pos, keeper_hp, 68.0 + floor_no * 0.48, 54.0, 26.0 + floor_no * 0.9, 120 + floor_no * 9, rng)
		keeper["boss_variant"] = "crypt_keeper"
		keeper["attack_cd"] = 0.95
		return keeper
	if kind == "hollow_king":
		var king_hp: float = 860.0 + float(floor_no) * 72.0
		var king: Dictionary = _base_enemy("warden", pos, king_hp, 74.0 + floor_no * 0.52, 60.0, 30.0 + floor_no * 1.0, 185 + floor_no * 11, rng)
		king["boss_variant"] = "hollow_king"
		king["attack_cd"] = 0.75
		king["teleport_cd"] = 3.3
		king["crown_angle"] = 0.0
		return king
	var boss_hp: float = 310.0 + float(floor_no) * 48.0
	var boss: Dictionary = _base_enemy("warden", pos, boss_hp, 62.0 + floor_no * 0.5, 48.0, 22.0 + floor_no * 0.8, 70 + floor_no * 7, rng)
	boss["attack_cd"] = 1.15
	return boss

static func _base_enemy(kind: String, pos: Vector2, hp: float, speed: float, radius: float, touch_damage: float, reward: int, rng: RandomNumberGenerator) -> Dictionary:
	return {
		"type": kind,
		"pos": pos,
		"hp": hp,
		"max_hp": hp,
		"speed": speed,
		"radius": radius,
		"touch_damage": touch_damage,
		"reward": reward,
		"touch_cd": 0.0,
		"attack_cd": 0.0,
		"phase": rng.randf_range(0.0, TAU),
		"cast_timer": 0.0,
		"cast_kind": "",
		"phase2": false,
		"attack_index": 0,
		"elite": false,
		"summon_cd": 0.0,
		"rage": 0.0,
		"boss_variant": "warden"
	}

static func empower_elite(enemy: Dictionary) -> Dictionary:
	enemy["elite"] = true
	enemy["max_hp"] = float(enemy["max_hp"]) * 2.15
	enemy["hp"] = enemy["max_hp"]
	enemy["touch_damage"] = float(enemy["touch_damage"]) * 1.45
	enemy["reward"] = int(round(float(enemy["reward"]) * 2.8))
	enemy["radius"] = float(enemy["radius"]) * 1.12
	return enemy

static func random_spawn_pos(rng: RandomNumberGenerator, player_pos: Vector2) -> Vector2:
	var pos := Vector2(rng.randf_range(88, 632), rng.randf_range(220, 920))
	var guard := 0
	while pos.distance_to(player_pos) < 245.0 and guard < 20:
		pos = Vector2(rng.randf_range(88, 632), rng.randf_range(220, 920))
		guard += 1
	return pos