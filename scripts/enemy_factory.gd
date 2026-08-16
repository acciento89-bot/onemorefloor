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

	# Floors 31-40 — Deep Tower roster.
	if kind == "void_knight":
		var knight: Dictionary = _base_enemy("void_knight", pos, base_hp * 1.92, 56.0 + floor_no * 0.78, 30.0, 15.0 + floor_no * 0.68, 18 + floor_no, rng)
		knight["guard"] = 0.18
		knight["dash_cd"] = rng.randf_range(1.6, 2.7)
		knight["dash_time"] = 0.0
		return knight
	if kind == "rift_mage":
		var mage: Dictionary = _base_enemy("rift_mage", pos, base_hp * 0.96, 59.0 + floor_no * 0.86, 23.0, 11.0 + floor_no * 0.50, 19 + floor_no, rng)
		mage["attack_cd"] = rng.randf_range(0.25, 0.8)
		mage["blink_cd"] = rng.randf_range(2.2, 3.5)
		mage["rift_angle"] = rng.randf_range(0.0, TAU)
		return mage
	if kind == "soul_reaver":
		var reaver: Dictionary = _base_enemy("soul_reaver", pos, base_hp * 1.12, 116.0 + floor_no * 1.15, 24.0, 13.0 + floor_no * 0.60, 20 + floor_no, rng)
		reaver["lunge_cd"] = rng.randf_range(1.2, 2.2)
		reaver["lunge_time"] = 0.0
		reaver["rage"] = 0.0
		return reaver

	# Floors 41-50 — Starless Spire.
	if kind == "phase_stalker":
		var stalker: Dictionary = _base_enemy("phase_stalker", pos, base_hp * 1.14, 126.0 + floor_no * 1.08, 23.0, 14.0 + floor_no * 0.62, 24 + floor_no, rng)
		stalker["phase_cd"] = rng.randf_range(1.4, 2.5)
		stalker["phase_time"] = 0.0
		return stalker
	if kind == "orb_weaver":
		var weaver: Dictionary = _base_enemy("orb_weaver", pos, base_hp * 1.08, 57.0 + floor_no * 0.74, 24.0, 12.0 + floor_no * 0.54, 26 + floor_no, rng)
		weaver["attack_cd"] = rng.randf_range(0.25, 0.75)
		weaver["orbit_angle"] = rng.randf_range(0.0, TAU)
		return weaver
	if kind == "oathbreaker":
		var oath: Dictionary = _base_enemy("oathbreaker", pos, base_hp * 2.18, 52.0 + floor_no * 0.68, 31.0, 17.0 + floor_no * 0.72, 28 + floor_no, rng)
		oath["guard"] = 0.22
		oath["slam_cd"] = rng.randf_range(1.5, 2.8)
		return oath

	# Floors 51-99 — Void Citadel. Fast lancers and hounds force movement while
	# Soul Cannons punish standing still at range.
	if kind == "void_lancer":
		var lancer: Dictionary = _base_enemy("void_lancer", pos, base_hp * 1.35, 112.0 + floor_no * 0.72, 26.0, 16.0 + floor_no * 0.65, 32 + floor_no, rng)
		lancer["dash_cd"] = rng.randf_range(1.2, 2.0)
		lancer["ability_cd"] = lancer["dash_cd"]
		return lancer
	if kind == "rift_hound":
		var hound: Dictionary = _base_enemy("rift_hound", pos, base_hp * 1.55, 138.0 + floor_no * 0.78, 27.0, 17.0 + floor_no * 0.68, 34 + floor_no, rng)
		hound["ability_cd"] = rng.randf_range(1.8, 2.8)
		return hound
	if kind == "soul_cannon":
		var cannon: Dictionary = _base_enemy("soul_cannon", pos, base_hp * 1.10, 48.0 + floor_no * 0.30, 25.0, 12.0 + floor_no * 0.52, 38 + floor_no, rng)
		cannon["attack_cd"] = rng.randf_range(0.45, 1.0)
		cannon["ability_cd"] = rng.randf_range(2.3, 3.2)
		return cannon

	# Floors 100-149 — Eclipse Sanctum. The roster deliberately mixes ranged
	# pattern pressure, agile duelists and a shielded frontline.
	if kind == "eclipse_oracle":
		var oracle: Dictionary = _base_enemy("eclipse_oracle", pos, base_hp * 1.25, 58.0 + floor_no * 0.34, 24.0, 13.0 + floor_no * 0.55, 46 + floor_no, rng)
		oracle["attack_cd"] = rng.randf_range(0.35, 0.85)
		oracle["ability_cd"] = rng.randf_range(2.0, 3.0)
		return oracle
	if kind == "shade_duelist":
		var duelist: Dictionary = _base_enemy("shade_duelist", pos, base_hp * 1.35, 124.0 + floor_no * 0.62, 25.0, 18.0 + floor_no * 0.72, 48 + floor_no, rng)
		duelist["ability_cd"] = rng.randf_range(1.25, 2.1)
		return duelist
	if kind == "sunless_guard":
		var guard: Dictionary = _base_enemy("sunless_guard", pos, base_hp * 2.25, 52.0 + floor_no * 0.30, 32.0, 20.0 + floor_no * 0.78, 54 + floor_no, rng)
		guard["guard"] = 0.26
		guard["ability_cd"] = rng.randf_range(2.0, 3.0)
		return guard

	# Floors 150-199 — Bloodstar Keep. Damage spikes are sharper here: Seraphs
	# dive, Titans create shockwaves and Hemomancers fill space with blood bolts.
	if kind == "blood_seraph":
		var seraph: Dictionary = _base_enemy("blood_seraph", pos, base_hp * 1.45, 135.0 + floor_no * 0.55, 26.0, 21.0 + floor_no * 0.80, 62 + floor_no, rng)
		seraph["ability_cd"] = rng.randf_range(1.2, 2.0)
		return seraph
	if kind == "chain_titan":
		var titan: Dictionary = _base_enemy("chain_titan", pos, base_hp * 2.80, 44.0 + floor_no * 0.24, 35.0, 24.0 + floor_no * 0.90, 70 + floor_no, rng)
		titan["guard"] = 0.18
		titan["ability_cd"] = rng.randf_range(1.8, 2.8)
		return titan
	if kind == "hemomancer":
		var hemo: Dictionary = _base_enemy("hemomancer", pos, base_hp * 1.30, 58.0 + floor_no * 0.32, 24.0, 17.0 + floor_no * 0.65, 66 + floor_no, rng)
		hemo["attack_cd"] = rng.randf_range(0.25, 0.75)
		hemo["ability_cd"] = rng.randf_range(1.8, 2.7)
		return hemo

	# Floor 200+ — Celestial Grave. These enemies are intentionally extreme;
	# reaching this realm means the permanent and run build are already mature.
	if kind == "star_devourer":
		var devourer: Dictionary = _base_enemy("star_devourer", pos, base_hp * 3.00, 52.0 + floor_no * 0.24, 36.0, 27.0 + floor_no * 1.00, 86 + floor_no, rng)
		devourer["guard"] = 0.16
		devourer["ability_cd"] = rng.randf_range(1.6, 2.5)
		return devourer
	if kind == "crownless":
		var crownless: Dictionary = _base_enemy("crownless", pos, base_hp * 1.65, 145.0 + floor_no * 0.50, 27.0, 24.0 + floor_no * 0.90, 82 + floor_no, rng)
		crownless["ability_cd"] = rng.randf_range(1.0, 1.8)
		return crownless
	if kind == "cosmic_eye":
		var eye: Dictionary = _base_enemy("cosmic_eye", pos, base_hp * 1.40, 60.0 + floor_no * 0.28, 24.0, 19.0 + floor_no * 0.72, 84 + floor_no, rng)
		eye["attack_cd"] = rng.randf_range(0.20, 0.65)
		eye["ability_cd"] = rng.randf_range(1.4, 2.3)
		return eye

	# Named realm bosses. They keep type=warden so existing mission, loot and boss
	# UI logic remains compatible while boss_variant selects the new mechanics.
	if kind == "void_archon":
		var archon: Dictionary = _base_enemy("warden", pos, 1900.0 + float(floor_no) * 130.0, 88.0 + floor_no * 0.34, 70.0, 45.0 + floor_no * 1.25, 480 + floor_no * 18, rng)
		archon["boss_variant"] = "void_archon"
		archon["attack_cd"] = 0.62
		archon["ability_cd"] = 1.8
		return archon
	if kind == "eclipse_regent":
		var regent: Dictionary = _base_enemy("warden", pos, 2700.0 + float(floor_no) * 165.0, 92.0 + floor_no * 0.30, 73.0, 52.0 + floor_no * 1.35, 720 + floor_no * 21, rng)
		regent["boss_variant"] = "eclipse_regent"
		regent["attack_cd"] = 0.54
		regent["ability_cd"] = 1.6
		return regent
	if kind == "bloodstar_tyrant":
		var tyrant: Dictionary = _base_enemy("warden", pos, 3800.0 + float(floor_no) * 210.0, 96.0 + floor_no * 0.28, 77.0, 60.0 + floor_no * 1.48, 980 + floor_no * 24, rng)
		tyrant["boss_variant"] = "bloodstar_tyrant"
		tyrant["attack_cd"] = 0.48
		tyrant["ability_cd"] = 1.45
		return tyrant
	if kind == "world_eater":
		var eater: Dictionary = _base_enemy("warden", pos, 5200.0 + float(floor_no) * 260.0, 100.0 + floor_no * 0.24, 82.0, 70.0 + floor_no * 1.60, 1400 + floor_no * 28, rng)
		eater["boss_variant"] = "world_eater"
		eater["attack_cd"] = 0.42
		eater["ability_cd"] = 1.25
		return eater

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
	if kind == "astral_warden":
		var astral_hp: float = 1180.0 + float(floor_no) * 88.0
		var astral: Dictionary = _base_enemy("warden", pos, astral_hp, 80.0 + floor_no * 0.52, 62.0, 34.0 + floor_no * 1.08, 240 + floor_no * 13, rng)
		astral["boss_variant"] = "astral_warden"
		astral["attack_cd"] = 0.68
		astral["teleport_cd"] = 2.8
		astral["rift_angle"] = 0.0
		return astral
	if kind == "null_sovereign":
		var null_hp: float = 1540.0 + float(floor_no) * 105.0
		var sovereign: Dictionary = _base_enemy("warden", pos, null_hp, 84.0 + floor_no * 0.50, 66.0, 38.0 + floor_no * 1.15, 340 + floor_no * 15, rng)
		sovereign["boss_variant"] = "null_sovereign"
		sovereign["attack_cd"] = 0.58
		sovereign["teleport_cd"] = 2.4
		sovereign["eclipse_angle"] = 0.0
		return sovereign

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
		"ability_cd": 0.0,
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
