extends RefCounted

const SAVE_PATH := "user://save.cfg"
const RARITIES := ["COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY", "MYTHIC", "ASCENDANT"]
const RARITY_MULT := [1.0, 1.35, 1.85, 2.6, 3.8, 5.4, 7.5]
const SETS := ["EMBER", "CRYPT", "WARDEN", "VOID", "ECLIPSE", "BLOODSTAR", "CELESTIAL"]
const DISMANTLE_VALUES := [5, 12, 30, 70, 160, 360, 800]
const CRAFT_COST := 120

var inventory: Array = []
var equipped := {"weapon": "", "armor": "", "relic": ""}
var shards: int = 0
var active_sort_mode: String = "rarity"

func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	inventory = cfg.get_value("loot", "inventory", [])
	var saved_equipped = cfg.get_value("loot", "equipped", equipped)
	if saved_equipped is Dictionary:
		equipped = saved_equipped
	shards = int(cfg.get_value("loot", "shards", 0))
	active_sort_mode = String(cfg.get_value("loot", "sort_mode", "rarity"))

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("loot", "inventory", inventory)
	cfg.set_value("loot", "equipped", equipped)
	cfg.set_value("loot", "shards", shards)
	cfg.set_value("loot", "sort_mode", active_sort_mode)
	cfg.save(SAVE_PATH)

func roll_drop(enemy_type: String, floor_no: int, rng: RandomNumberGenerator) -> Dictionary:
	var chance: float = 0.055 + minf(0.08, float(floor_no) * 0.002)
	if floor_no >= 100:
		chance += 0.025
	if floor_no >= 200:
		chance += 0.025
	if enemy_type == "warden":
		chance = 1.0
	if rng.randf() > chance:
		return {}
	var rarity_index: int = _roll_rarity(enemy_type == "warden", floor_no, rng)
	var slot_roll: int = rng.randi_range(0, 2)
	var slot: String = String(["weapon", "armor", "relic"][slot_roll])
	var item: Dictionary = _make_item(slot, rarity_index, floor_no, rng)
	_store_item(item)
	save_data()
	return item

func craft_item(slot: String, floor_no: int, rng: RandomNumberGenerator) -> Dictionary:
	if not slot in ["weapon", "armor", "relic"]:
		return {}
	if shards < CRAFT_COST:
		return {}
	shards -= CRAFT_COST
	var roll: float = rng.randf()
	var rarity_index: int = 2
	if floor_no >= 200:
		if roll < 0.015:
			rarity_index = 6
		elif roll < 0.085:
			rarity_index = 5
		elif roll < 0.22:
			rarity_index = 4
		elif roll < 0.55:
			rarity_index = 3
	elif floor_no >= 100:
		if roll < 0.035:
			rarity_index = 5
		elif roll < 0.14:
			rarity_index = 4
		elif roll < 0.44:
			rarity_index = 3
	else:
		if roll < 0.035:
			rarity_index = 4
		elif roll < 0.22:
			rarity_index = 3
	var item: Dictionary = _make_item(slot, rarity_index, maxi(5, floor_no), rng)
	_store_item(item)
	save_data()
	return item

func dismantle_index(index: int) -> int:
	if index < 0 or index >= inventory.size():
		return 0
	var item: Dictionary = inventory[index]
	if is_equipped(item) or is_locked(item):
		return 0
	var rarity_index: int = clampi(int(item.get("rarity_index", 0)), 0, DISMANTLE_VALUES.size() - 1)
	var gained: int = int(DISMANTLE_VALUES[rarity_index])
	inventory.remove_at(index)
	shards += gained
	save_data()
	return gained

func dismantle_value(item: Dictionary) -> int:
	var rarity_index: int = clampi(int(item.get("rarity_index", 0)), 0, DISMANTLE_VALUES.size() - 1)
	return int(DISMANTLE_VALUES[rarity_index])

func craft_cost() -> int:
	return CRAFT_COST

func _store_item(item: Dictionary) -> void:
	inventory.push_front(item)
	if inventory.size() > 60:
		inventory.resize(60)

func _roll_rarity(warden: bool, floor_no: int, rng: RandomNumberGenerator) -> int:
	var roll: float = rng.randf()
	# Mythic starts to appear in the Void Citadel; Ascendant is an actual
	# endgame chase tier rather than something that can drop on Floor 1.
	if warden:
		if floor_no >= 200:
			if roll < 0.055: return 6
			if roll < 0.190: return 5
			if roll < 0.430: return 4
			if roll < 0.760: return 3
			return 2
		if floor_no >= 150:
			if roll < 0.025: return 6
			if roll < 0.135: return 5
			if roll < 0.360: return 4
			if roll < 0.720: return 3
			return 2
		if floor_no >= 100:
			if roll < 0.008: return 6
			if roll < 0.080: return 5
			if roll < 0.300: return 4
			if roll < 0.680: return 3
			return 2
		if floor_no >= 51:
			if roll < 0.025: return 5
			if roll < 0.220: return 4
			if roll < 0.610: return 3
			return 2
		var boss_bonus: float = minf(0.12, float(floor_no) * 0.0025)
		if roll < 0.04 + boss_bonus * 0.35: return 4
		if roll < 0.20 + boss_bonus: return 3
		if roll < 0.58: return 2
		return 1

	if floor_no >= 200:
		if roll < 0.012: return 6
		if roll < 0.075: return 5
		if roll < 0.190: return 4
		if roll < 0.420: return 3
		if roll < 0.690: return 2
		return 1
	if floor_no >= 150:
		if roll < 0.005: return 6
		if roll < 0.050: return 5
		if roll < 0.155: return 4
		if roll < 0.390: return 3
		if roll < 0.670: return 2
		return 1
	if floor_no >= 100:
		if roll < 0.025: return 5
		if roll < 0.125: return 4
		if roll < 0.360: return 3
		if roll < 0.650: return 2
		return 1
	if floor_no >= 51:
		if roll < 0.008: return 5
		if roll < 0.095: return 4
		if roll < 0.300: return 3
		if roll < 0.600: return 2
		return 1
	var bonus: float = minf(0.12, float(floor_no) * 0.0025)
	if roll < 0.008 + bonus * 0.15: return 4
	if roll < 0.045 + bonus * 0.35: return 3
	if roll < 0.16 + bonus: return 2
	if roll < 0.43: return 1
	return 0

func _make_item(slot: String, rarity_index: int, floor_no: int, rng: RandomNumberGenerator) -> Dictionary:
	rarity_index = clampi(rarity_index, 0, RARITIES.size() - 1)
	var rarity: String = String(RARITIES[rarity_index])
	var mult: float = float(RARITY_MULT[rarity_index])
	var level: int = maxi(1, floor_no)
	var item_id: String = "%d-%d-%d" % [Time.get_ticks_msec(), rng.randi(), inventory.size()]
	var names: Dictionary = {
		"weapon": ["Rustfang", "Tower Blade", "Void Edge", "Warden Breaker", "Crypt Cleaver"],
		"armor": ["Ironhide", "Crypt Guard", "Tower Plate", "Warden Shell", "Grave Mantle"],
		"relic": ["Ember Eye", "Lucky Sigil", "Void Charm", "Warden Seal", "Bone Lantern"]
	}
	if floor_no >= 51:
		names["weapon"].append_array(["Rift Pike", "Soulcutter"])
		names["armor"].append_array(["Void Carapace", "Citadel Plate"])
		names["relic"].append_array(["Black Prism", "Rift Heart"])
	if floor_no >= 100:
		names["weapon"].append_array(["Eclipse Fang", "Nightglass Edge"])
		names["armor"].append_array(["Eclipse Aegis", "Sunless Mail"])
		names["relic"].append_array(["Black Sun", "Oracle Eye"])
	if floor_no >= 150:
		names["weapon"].append_array(["Bloodstar Edge", "Chainbreaker"])
		names["armor"].append_array(["Bloodstar Plate", "Titan Husk"])
		names["relic"].append_array(["Crimson Halo", "Heart of Chains"])
	if floor_no >= 200:
		names["weapon"].append_array(["Grave of Suns", "Worldsplitter"])
		names["armor"].append_array(["Celestial Husk", "Crownless Plate"])
		names["relic"].append_array(["Dead Star", "World Eater Eye"])
	var item: Dictionary = {
		"id": item_id, "slot": slot,
		"name": names[slot][rng.randi_range(0, names[slot].size() - 1)],
		"rarity": rarity, "rarity_index": rarity_index, "level": level,
		"damage_pct": 0.0, "hp": 0.0, "crit_pct": 0.0, "coin_pct": 0.0,
		"trait": "", "set": "", "locked": false
	}
	if slot == "weapon":
		item["damage_pct"] = (0.025 + float(level) * 0.0022) * mult
	elif slot == "armor":
		item["hp"] = (5.0 + float(level) * 1.2) * mult
	else:
		if rng.randf() < 0.55:
			item["crit_pct"] = (0.008 + float(level) * 0.0007) * mult
		else:
			item["coin_pct"] = (0.018 + float(level) * 0.0013) * mult
	if rarity_index >= 2:
		item["trait"] = _roll_trait(slot, floor_no, rarity_index, rng)
	if rarity_index >= 1:
		var set_chance: float = 0.92 if rarity_index >= 5 else (0.82 if rarity_index >= 2 else 0.35)
		if rng.randf() < set_chance:
			var set_pool := _set_pool_for_floor(floor_no)
			item["set"] = String(set_pool[rng.randi_range(0, set_pool.size() - 1)])
	return item

func _set_pool_for_floor(floor_no: int) -> Array[String]:
	var pool: Array[String] = ["EMBER", "CRYPT", "WARDEN"]
	if floor_no >= 51:
		pool.append("VOID")
	if floor_no >= 100:
		pool.append("ECLIPSE")
	if floor_no >= 150:
		pool.append("BLOODSTAR")
	if floor_no >= 200:
		pool.append("CELESTIAL")
	return pool

func _roll_trait(slot: String, floor_no: int, rarity_index: int, rng: RandomNumberGenerator) -> String:
	var deep_trait_chance := 0.0
	if floor_no >= 100:
		deep_trait_chance = 0.16
	if rarity_index >= 5:
		deep_trait_chance += 0.24
	if rarity_index >= 6:
		deep_trait_chance += 0.20
	if rng.randf() < deep_trait_chance:
		if slot == "weapon":
			return "RIFTBORN"
		if slot == "armor":
			return "IMMORTAL"
		return "STARHEART"
	if slot == "weapon":
		return "EXECUTIONER" if rng.randf() < 0.55 else "FRENZY"
	if slot == "armor":
		return "BULWARK" if rng.randf() < 0.55 else "VITAL CORE"
	return "VAMPIRIC" if rng.randf() < 0.55 else "FORTUNE"

func equip_index(index: int) -> bool:
	if index < 0 or index >= inventory.size():
		return false
	var item: Dictionary = inventory[index]
	equipped[String(item["slot"])] = String(item["id"])
	save_data()
	return true

func is_equipped(item: Dictionary) -> bool:
	return String(equipped.get(String(item["slot"]), "")) == String(item["id"])

func is_locked(item: Dictionary) -> bool:
	return bool(item.get("locked", false))

func toggle_lock_index(index: int) -> bool:
	if index < 0 or index >= inventory.size():
		return false
	var item: Dictionary = inventory[index]
	item["locked"] = not bool(item.get("locked", false))
	inventory[index] = item
	save_data()
	return bool(item["locked"])

func find_index_by_id(item_id: String) -> int:
	for i in range(inventory.size()):
		if String(inventory[i].get("id", "")) == item_id:
			return i
	return -1

func equipped_item_for_slot(slot: String) -> Dictionary:
	var wanted_id: String = String(equipped.get(slot, ""))
	if wanted_id == "":
		return {}
	var index: int = find_index_by_id(wanted_id)
	if index < 0:
		return {}
	return inventory[index]

func matching_indices(slot_filter: String = "all") -> Array[int]:
	var result: Array[int] = []
	for i in range(inventory.size()):
		var item: Dictionary = inventory[i]
		if slot_filter == "all" or String(item.get("slot", "")) == slot_filter:
			result.append(i)
	return result

func sort_inventory(mode: String) -> void:
	if not mode in ["rarity", "level", "score", "newest"]:
		mode = "rarity"
	active_sort_mode = mode
	if mode != "newest":
		inventory.sort_custom(Callable(self, "_sort_items"))
	save_data()

func _sort_items(a: Dictionary, b: Dictionary) -> bool:
	if active_sort_mode == "level":
		if int(a.get("level", 0)) != int(b.get("level", 0)):
			return int(a.get("level", 0)) > int(b.get("level", 0))
	elif active_sort_mode == "score":
		if item_score(a) != item_score(b):
			return item_score(a) > item_score(b)
	else:
		if int(a.get("rarity_index", 0)) != int(b.get("rarity_index", 0)):
			return int(a.get("rarity_index", 0)) > int(b.get("rarity_index", 0))
	return int(a.get("level", 0)) > int(b.get("level", 0))

func item_score(item: Dictionary) -> int:
	var score: float = float(item.get("rarity_index", 0)) * 1000.0 + float(item.get("level", 0)) * 10.0
	score += float(item.get("damage_pct", 0.0)) * 5000.0
	score += float(item.get("hp", 0.0)) * 5.0
	score += float(item.get("crit_pct", 0.0)) * 4500.0
	score += float(item.get("coin_pct", 0.0)) * 2200.0
	if String(item.get("trait", "")) != "": score += 180.0
	if String(item.get("set", "")) != "": score += 120.0
	return int(round(score))

func comparison_delta(item: Dictionary) -> int:
	var equipped_item: Dictionary = equipped_item_for_slot(String(item.get("slot", "")))
	if equipped_item.is_empty():
		return item_score(item)
	return item_score(item) - item_score(equipped_item)

func equipped_items() -> Array:
	var result: Array = []
	for raw_item in inventory:
		var item: Dictionary = raw_item
		if is_equipped(item):
			result.append(item)
	return result

func _empty_set_counts() -> Dictionary:
	return {
		"EMBER":0, "CRYPT":0, "WARDEN":0, "VOID":0,
		"ECLIPSE":0, "BLOODSTAR":0, "CELESTIAL":0
	}

func equipped_bonuses() -> Dictionary:
	var result: Dictionary = {
		"damage_pct":0.0, "hp":0.0, "crit_pct":0.0, "coin_pct":0.0,
		"lifesteal":0.0, "armor":0.0, "attack_speed":0.0, "nova_mult":0.0
	}
	var set_counts: Dictionary = _empty_set_counts()
	var items: Array = equipped_items()
	for raw_item in items:
		var item: Dictionary = raw_item
		result["damage_pct"] = float(result["damage_pct"]) + float(item.get("damage_pct", 0.0))
		result["hp"] = float(result["hp"]) + float(item.get("hp", 0.0))
		result["crit_pct"] = float(result["crit_pct"]) + float(item.get("crit_pct", 0.0))
		result["coin_pct"] = float(result["coin_pct"]) + float(item.get("coin_pct", 0.0))
		var trait_name: String = String(item.get("trait", ""))
		match trait_name:
			"EXECUTIONER": result["damage_pct"] = float(result["damage_pct"]) + 0.06
			"FRENZY": result["attack_speed"] = float(result["attack_speed"]) + 0.07
			"BULWARK": result["armor"] = float(result["armor"]) + 0.04
			"VITAL CORE": result["hp"] = float(result["hp"]) + 18.0
			"VAMPIRIC": result["lifesteal"] = float(result["lifesteal"]) + 0.025
			"FORTUNE": result["coin_pct"] = float(result["coin_pct"]) + 0.06
			"RIFTBORN":
				result["damage_pct"] = float(result["damage_pct"]) + 0.10
				result["attack_speed"] = float(result["attack_speed"]) + 0.05
			"IMMORTAL":
				result["hp"] = float(result["hp"]) + 42.0
				result["armor"] = float(result["armor"]) + 0.045
			"STARHEART":
				result["crit_pct"] = float(result["crit_pct"]) + 0.055
				result["nova_mult"] = float(result["nova_mult"]) + 0.22
		var set_name: String = String(item.get("set", ""))
		if set_counts.has(set_name):
			set_counts[set_name] = int(set_counts[set_name]) + 1
	_apply_set_bonus(result, set_counts)
	return result

func _apply_set_bonus(result: Dictionary, counts: Dictionary) -> void:
	if int(counts["EMBER"]) >= 2:
		result["damage_pct"] = float(result["damage_pct"]) + 0.08
	if int(counts["EMBER"]) >= 3:
		result["crit_pct"] = float(result["crit_pct"]) + 0.05
	if int(counts["CRYPT"]) >= 2:
		result["hp"] = float(result["hp"]) + 25.0
	if int(counts["CRYPT"]) >= 3:
		result["lifesteal"] = float(result["lifesteal"]) + 0.03
	if int(counts["WARDEN"]) >= 2:
		result["armor"] = float(result["armor"]) + 0.035
	if int(counts["WARDEN"]) >= 3:
		result["nova_mult"] = float(result["nova_mult"]) + 0.20
	if int(counts["VOID"]) >= 2:
		result["damage_pct"] = float(result["damage_pct"]) + 0.10
	if int(counts["VOID"]) >= 3:
		result["lifesteal"] = float(result["lifesteal"]) + 0.035
	if int(counts["ECLIPSE"]) >= 2:
		result["crit_pct"] = float(result["crit_pct"]) + 0.07
	if int(counts["ECLIPSE"]) >= 3:
		result["nova_mult"] = float(result["nova_mult"]) + 0.28
	if int(counts["BLOODSTAR"]) >= 2:
		result["hp"] = float(result["hp"]) + 40.0
		result["damage_pct"] = float(result["damage_pct"]) + 0.08
	if int(counts["BLOODSTAR"]) >= 3:
		result["lifesteal"] = float(result["lifesteal"]) + 0.045
	if int(counts["CELESTIAL"]) >= 2:
		result["armor"] = float(result["armor"]) + 0.05
		result["attack_speed"] = float(result["attack_speed"]) + 0.08
	if int(counts["CELESTIAL"]) >= 3:
		result["damage_pct"] = float(result["damage_pct"]) + 0.14
		result["nova_mult"] = float(result["nova_mult"]) + 0.35

func equipped_set_counts() -> Dictionary:
	var counts: Dictionary = _empty_set_counts()
	var items: Array = equipped_items()
	for raw_item in items:
		var item: Dictionary = raw_item
		var set_name: String = String(item.get("set", ""))
		if counts.has(set_name):
			counts[set_name] = int(counts[set_name]) + 1
	return counts

func rarity_color_name(item: Dictionary) -> String:
	return String(item.get("rarity", "COMMON"))

func stat_line(item: Dictionary) -> String:
	if String(item["slot"]) == "weapon":
		return "+%.1f%% damage" % (float(item["damage_pct"]) * 100.0)
	if String(item["slot"]) == "armor":
		return "+%d HP" % int(round(float(item["hp"])))
	if float(item.get("crit_pct", 0.0)) > 0.0:
		return "+%.1f%% crit" % (float(item["crit_pct"]) * 100.0)
	return "+%.1f%% coins" % (float(item.get("coin_pct", 0.0)) * 100.0)

func trait_line(item: Dictionary) -> String:
	var set_name: String = String(item.get("set", ""))
	var trait_name: String = String(item.get("trait", ""))
	if set_name != "" and trait_name != "":
		return "%s SET • %s" % [set_name, trait_name]
	if set_name != "":
		return "%s SET" % set_name
	return trait_name
