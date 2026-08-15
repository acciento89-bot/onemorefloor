extends RefCounted

const SAVE_PATH := "user://save.cfg"
const RARITIES := ["COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY"]
const RARITY_MULT := [1.0, 1.35, 1.85, 2.6, 3.8]
const SETS := ["EMBER", "CRYPT", "WARDEN"]

var inventory: Array = []
var equipped := {"weapon": "", "armor": "", "relic": ""}

func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	inventory = cfg.get_value("loot", "inventory", [])
	var saved_equipped = cfg.get_value("loot", "equipped", equipped)
	if saved_equipped is Dictionary:
		equipped = saved_equipped

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("loot", "inventory", inventory)
	cfg.set_value("loot", "equipped", equipped)
	cfg.save(SAVE_PATH)

func roll_drop(enemy_type: String, floor_no: int, rng: RandomNumberGenerator) -> Dictionary:
	var chance: float = 0.055 + minf(0.08, float(floor_no) * 0.002)
	if enemy_type == "warden":
		chance = 1.0
	if rng.randf() > chance:
		return {}
	var rarity_index: int = _roll_rarity(enemy_type == "warden", floor_no, rng)
	var slot_roll: int = rng.randi_range(0, 2)
	var slot: String = String(["weapon", "armor", "relic"][slot_roll])
	var item: Dictionary = _make_item(slot, rarity_index, floor_no, rng)
	inventory.push_front(item)
	if inventory.size() > 60:
		inventory.resize(60)
	save_data()
	return item

func _roll_rarity(warden: bool, floor_no: int, rng: RandomNumberGenerator) -> int:
	var roll: float = rng.randf()
	var bonus: float = minf(0.12, float(floor_no) * 0.0025)
	if warden:
		if roll < 0.04 + bonus * 0.35: return 4
		if roll < 0.20 + bonus: return 3
		if roll < 0.58: return 2
		return 1
	if roll < 0.008 + bonus * 0.15: return 4
	if roll < 0.045 + bonus * 0.35: return 3
	if roll < 0.16 + bonus: return 2
	if roll < 0.43: return 1
	return 0

func _make_item(slot: String, rarity_index: int, floor_no: int, rng: RandomNumberGenerator) -> Dictionary:
	var rarity: String = String(RARITIES[rarity_index])
	var mult: float = float(RARITY_MULT[rarity_index])
	var level: int = maxi(1, floor_no)
	var item_id: String = "%d-%d-%d" % [Time.get_ticks_msec(), rng.randi(), inventory.size()]
	var names: Dictionary = {
		"weapon": ["Rustfang", "Tower Blade", "Void Edge", "Warden Breaker", "Crypt Cleaver"],
		"armor": ["Ironhide", "Crypt Guard", "Tower Plate", "Warden Shell", "Grave Mantle"],
		"relic": ["Ember Eye", "Lucky Sigil", "Void Charm", "Warden Seal", "Bone Lantern"]
	}
	var item: Dictionary = {
		"id": item_id, "slot": slot,
		"name": names[slot][rng.randi_range(0, names[slot].size() - 1)],
		"rarity": rarity, "rarity_index": rarity_index, "level": level,
		"damage_pct": 0.0, "hp": 0.0, "crit_pct": 0.0, "coin_pct": 0.0,
		"trait": "", "set": ""
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
		item["trait"] = _roll_trait(slot, rng)
	if rarity_index >= 1:
		var set_chance: float = 0.82 if rarity_index >= 2 else 0.35
		if rng.randf() < set_chance:
			item["set"] = String(SETS[rng.randi_range(0, SETS.size() - 1)])
	return item

func _roll_trait(slot: String, rng: RandomNumberGenerator) -> String:
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

func equipped_items() -> Array:
	var result: Array = []
	for raw_item in inventory:
		var item: Dictionary = raw_item
		if is_equipped(item):
			result.append(item)
	return result

func equipped_bonuses() -> Dictionary:
	var result: Dictionary = {
		"damage_pct":0.0, "hp":0.0, "crit_pct":0.0, "coin_pct":0.0,
		"lifesteal":0.0, "armor":0.0, "attack_speed":0.0, "nova_mult":0.0
	}
	var set_counts: Dictionary = {"EMBER":0, "CRYPT":0, "WARDEN":0}
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

func equipped_set_counts() -> Dictionary:
	var counts: Dictionary = {"EMBER":0, "CRYPT":0, "WARDEN":0}
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
