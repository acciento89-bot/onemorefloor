extends RefCounted

const ROOM_TYPES := ["COMBAT", "AMBUSH", "ELITE", "TREASURE"]

func area_for_floor(floor_no: int) -> String:
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

	var roll: float = rng.randf()
	var room_type := "COMBAT"
	if roll < 0.18:
		room_type = "TREASURE"
	elif roll < 0.38:
		room_type = "AMBUSH"
	elif roll < 0.53:
		room_type = "ELITE"

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

	var area: String = area_for_floor(floor_no)
	if area == "CRYPT":
		hazard = "soul_mist" if rng.randf() < 0.55 else "bone_runes"
	elif area == "FORGOTTEN CASTLE":
		hazard = "falling_masonry" if rng.randf() < 0.52 else "cursed_banners"
	elif area == "DEEP TOWER":
		# The Deep Tower finally has its own gameplay identity instead of falling
		# back to the Dungeon rules. Void lanes punish standing still while arcane
		# pulses force the player to keep repositioning between attack windows.
		hazard = "void_lanes" if rng.randf() < 0.52 else "arcane_pulse"

	return {
		"area": area,
		"type": room_type,
		"enemy_bonus": enemy_bonus,
		"reward_bonus": reward_bonus,
		"elite": room_type == "ELITE",
		"hazard": hazard
	}

func enemy_pool(area: String, floor_no: int) -> Array[String]:
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
