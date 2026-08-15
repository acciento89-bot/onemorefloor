extends RefCounted

const SAVE_PATH := "user://save.cfg"
const RARITIES := ["COMMON", "UNCOMMON", "RARE", "EPIC", "LEGENDARY"]
const RARITY_MULT := [1.0, 1.35, 1.85, 2.6, 3.8]

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
	var chance := 0.055 + minf(0.08, float(floor_no) * 0.002)
	if enemy_type == "warden":
		chance = 1.0
	if rng.randf() > chance:
		return {}
	var rarity_index := _roll_rarity(enemy_type == "warden", floor_no, rng)
	var slot_roll := rng.randi_range(0, 2)
	var slot := ["weapon", "armor", "relic"][slot_roll]
	var item := _make_item(slot, rarity_index, floor_no, rng)
	inventory.push_front(item)
	if inventory.size() > 60:
		inventory.resize(60)
	save_data()
	return item

func _roll_rarity(warden: bool, floor_no: int, rng: RandomNumberGenerator) -> int:
	var roll := rng.randf()
	var bonus := minf(0.12, float(floor_no) * 0.0025)
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
	var rarity := RARITIES[rarity_index]
	var mult := float(RARITY_MULT[rarity_index])
	var level := maxi(1, floor_no)
	var item_id := "%d-%d-%d" % [Time.get_ticks_msec(), rng.randi(), inventory.size()]
	var names := {
		"weapon": ["Rustfang", "Tower Blade", "Void Edge", "Warden Breaker"],
		"armor": ["Ironhide", "Crypt Guard", "Tower Plate", "Warden Shell"],
		"relic": ["Ember Eye", "Lucky Sigil", "Void Charm", "Warden Seal"]
	}
	var item := {
		"id": item_id,
		"slot": slot,
		"name": names[slot][rng.randi_range(0, names[slot].size() - 1)],
		"rarity": rarity,
		"rarity_index": rarity_index,
		"level": level,
		"damage_pct": 0.0,
		"hp": 0.0,
		"crit_pct": 0.0,
		"coin_pct": 0.0
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
	return item

func equip_index(index: int) -> bool:
	if index < 0 or index >= inventory.size():
		return false
	var item: Dictionary = inventory[index]
	equipped[String(item["slot"])] = String(item["id"])
	save_data()
	return true

func is_equipped(item: Dictionary) -> bool:
	return String(equipped.get(String(item["slot"]), "")) == String(item["id"])

func equipped_bonuses() -> Dictionary:
	var result := {"damage_pct":0.0, "hp":0.0, "crit_pct":0.0, "coin_pct":0.0}
	for item in inventory:
		if not is_equipped(item):
			continue
		result["damage_pct"] += float(item.get("damage_pct", 0.0))
		result["hp"] += float(item.get("hp", 0.0))
		result["crit_pct"] += float(item.get("crit_pct", 0.0))
		result["coin_pct"] += float(item.get("coin_pct", 0.0))
	return result

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
