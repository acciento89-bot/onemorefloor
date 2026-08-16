extends RefCounted

const ROOM_TYPES := ["COMBAT", "AMBUSH", "ELITE", "TREASURE", "MINIBOSS"]

func area_for_floor(floor_no: int) -> String:
	if floor_no >= 41:
		return "STARLESS SPIRE"
	if floor_no >= 31:
		return "DEEP TOWER"
	if floor_no >= 21:
		return "FORGOTTEN CASTLE"
	if floor_no >= 11:
		return "CRYPT"
	return "DUNGEON"

func roll_room(floor_no: int, rng: RandomNumberGenerator) -> Dictionary:
	if floor_no % 5 == 0:
		return {
			"area": area_for_floor(floor_no),
			"type": "BOSS",
			"enemy_bonus": 0,
			"reward_bonus": 0,
			"elite": false,
			"hazard": "none"
		}

	# The deeper the climb, the less often the tower gives away a soft Treasure
	# room. Ambush, Elite and Miniboss rooms become steadily more common.
	var treasure_cut := 0.14
	var ambush_cut := 0.32
	var elite_cut := 0.46
	var miniboss_cut := 0.54
	if floor_no >= 16:
		treasure_cut = 0.10
		ambush_cut = 0.38
		elite_cut = 0.60
		miniboss_cut = 0.72
	elif floor_no >= 6:
		treasure_cut = 0.12
		ambush_cut = 0.36
		elite_cut = 0.54
		miniboss_cut = 0.64
	if floor_no >= 31:
		treasure_cut = 0.08
		ambush_cut = 0.38
		elite_cut = 0.62
		miniboss_cut = 0.76
	if floor_no >= 50:
		treasure_cut = 0.06
		ambush_cut = 0.40
		elite_cut = 0.66
		miniboss_cut = 0.82

	var roll := rng.randf()
	var room_type := "COMBAT"
	if roll < treasure_cut:
		room_type = "TREASURE"
	elif roll < ambush_cut:
		room_type = "AMBUSH"
	elif roll < elite_cut:
		room_type = "ELITE"
	elif roll < miniboss_cut and floor_no >= 6:
		room_type = "MINIBOSS"

	var reward_bonus := 0
	var enemy_bonus := 0
	var hazard := "none"
	if room_type == "TREASURE":
		reward_bonus = 14 + floor_no * 3
		enemy_bonus = -2
	elif room_type == "AMBUSH":
		enemy_bonus = 3
		reward_bonus = 6 + floor_no
	elif room_type == "ELITE":
		enemy_bonus = -1
		reward_bonus = 18 + floor_no * 2
	elif room_type == "MINIBOSS":
		enemy_bonus = -2
		reward_bonus = 28 + floor_no * 3

	var area := area_for_floor(floor_no)
	if area == "CRYPT":
		hazard = "soul_mist" if rng.randf() < 0.55 else "bone_runes"
	elif area == "FORGOTTEN CASTLE":
		hazard = "falling_masonry" if rng.randf() < 0.52 else "cursed_banners"
	elif area == "DEEP TOWER":
		hazard = "void_lanes" if rng.randf() < 0.52 else "arcane_pulse"
	elif area == "STARLESS SPIRE":
		hazard = "gravity_well" if rng.randf() < 0.50 else "starfall"

	return {
		"area": area,
		"type": room_type,
		"enemy_bonus": enemy_bonus,
		"reward_bonus": reward_bonus,
		"elite": room_type == "ELITE",
		"hazard": hazard
	}

func enemy_pool(area: String, floor_no: int) -> Array[String]:
	if area == "STARLESS SPIRE":
		var spire_pool: Array[String] = ["phase_stalker", "oathbreaker", "rift_mage"]
		if floor_no >= 43:
			spire_pool.append("orb_weaver")
		if floor_no >= 47:
			spire_pool.append("soul_reaver")
		return spire_pool
	if area == "DEEP TOWER":
		var deep_pool: Array[String] = ["void_knight", "soul_reaver", "sentinel"]
		if floor_no >= 33:
			deep_pool.append("rift_mage")
		if floor_no >= 36:
			deep_pool.append("hexer")
		return deep_pool
	if area == "FORGOTTEN CASTLE":
		var castle_pool: Array[String] = ["gargoyle", "sentinel", "skeleton"]
		if floor_no >= 23:
			castle_pool.append("hexer")
		return castle_pool
	if area == "CRYPT":
		var crypt_pool: Array[String] = ["skeleton", "ghoul", "bat"]
		if floor_no >= 13:
			crypt_pool.append("necromancer")
		return crypt_pool
	var pool: Array[String] = ["goblin"]
	if floor_no >= 2:
		pool.append("bat")
	if floor_no >= 3:
		pool.append("skeleton")
	return pool

func room_label(profile: Dictionary) -> String:
	return "%s • %s" % [String(profile.get("area", "DUNGEON")), String(profile.get("type", "COMBAT"))]
