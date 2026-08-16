extends "res://scripts/loot_system.gd"

# v1.16 — Loot 2.0
# Keeps every existing item/save compatible and adds three long-term shard sinks:
# Enhance -> strengthen the item's rolled stat.
# Enchant -> reroll its trait.
# Awaken -> promote a fully enhanced item to the next rarity when its floor level
# allows that tier. This makes a great drop worth investing in instead of being
# replaced immediately by the next coloured item.

const ENHANCE_CAPS := [3, 4, 5, 6, 8, 10, 12]

func load_data() -> void:
	super.load_data()
	var changed := false
	for i in range(inventory.size()):
		var item: Dictionary = inventory[i]
		if not item.has("enhance_level"):
			item["enhance_level"] = 0
			changed = true
		if not item.has("enchant_count"):
			item["enchant_count"] = 0
			changed = true
		if not item.has("awaken_count"):
			item["awaken_count"] = 0
			changed = true
		inventory[i] = item
	if changed:
		save_data()

func max_enhance_level(item: Dictionary) -> int:
	var rarity_index := clampi(int(item.get("rarity_index", 0)), 0, ENHANCE_CAPS.size() - 1)
	return int(ENHANCE_CAPS[rarity_index])

func enhance_cost(item: Dictionary) -> int:
	var rarity_index := clampi(int(item.get("rarity_index", 0)), 0, RARITIES.size() - 1)
	var level := int(item.get("enhance_level", 0))
	return 18 + rarity_index * 18 + level * level * 9 + level * 12

func enhance_index(index: int) -> bool:
	if index < 0 or index >= inventory.size():
		return false
	var item: Dictionary = inventory[index]
	var current := int(item.get("enhance_level", 0))
	if current >= max_enhance_level(item):
		return false
	var cost := enhance_cost(item)
	if shards < cost:
		return false
	shards -= cost
	var rarity_index := clampi(int(item.get("rarity_index", 0)), 0, RARITIES.size() - 1)
	var stat_mult := 1.075 + float(rarity_index) * 0.004
	match String(item.get("slot", "")):
		"weapon": item["damage_pct"] = float(item.get("damage_pct", 0.0)) * stat_mult
		"armor": item["hp"] = float(item.get("hp", 0.0)) * stat_mult
		"relic":
			if float(item.get("crit_pct", 0.0)) > 0.0:
				item["crit_pct"] = float(item.get("crit_pct", 0.0)) * stat_mult
			else:
				item["coin_pct"] = float(item.get("coin_pct", 0.0)) * stat_mult
	item["enhance_level"] = current + 1
	inventory[index] = item
	save_data()
	return true

func enchant_cost(item: Dictionary) -> int:
	var rarity_index := clampi(int(item.get("rarity_index", 0)), 0, RARITIES.size() - 1)
	var count := int(item.get("enchant_count", 0))
	return 55 + rarity_index * 28 + count * 34

func enchant_index(index: int, rng: RandomNumberGenerator) -> bool:
	if index < 0 or index >= inventory.size():
		return false
	var item: Dictionary = inventory[index]
	var rarity_index := int(item.get("rarity_index", 0))
	if rarity_index < 2:
		return false
	var cost := enchant_cost(item)
	if shards < cost:
		return false
	shards -= cost
	var old_trait := String(item.get("trait", ""))
	var new_trait := old_trait
	for _attempt in range(6):
		new_trait = _roll_trait(String(item.get("slot", "weapon")), int(item.get("level", 1)), rarity_index, rng)
		if new_trait != old_trait:
			break
	item["trait"] = new_trait
	item["enchant_count"] = int(item.get("enchant_count", 0)) + 1
	inventory[index] = item
	save_data()
	return true

func awaken_rarity_cap(item: Dictionary) -> int:
	var item_level := int(item.get("level", 1))
	if item_level >= 150:
		return 6 # ASCENDANT
	if item_level >= 51:
		return 5 # MYTHIC
	return 4 # LEGENDARY

func can_awaken(item: Dictionary) -> bool:
	var rarity_index := int(item.get("rarity_index", 0))
	return rarity_index >= 2 and rarity_index < awaken_rarity_cap(item) and int(item.get("enhance_level", 0)) >= max_enhance_level(item)

func awaken_cost(item: Dictionary) -> int:
	var rarity_index := clampi(int(item.get("rarity_index", 0)), 0, RARITIES.size() - 1)
	return 280 + rarity_index * 180 + int(item.get("awaken_count", 0)) * 240

func awaken_index(index: int) -> bool:
	if index < 0 or index >= inventory.size():
		return false
	var item: Dictionary = inventory[index]
	if not can_awaken(item):
		return false
	var cost := awaken_cost(item)
	if shards < cost:
		return false
	shards -= cost
	var old_index := clampi(int(item.get("rarity_index", 0)), 0, RARITIES.size() - 2)
	var new_index := old_index + 1
	var ratio := float(RARITY_MULT[new_index]) / maxf(0.001, float(RARITY_MULT[old_index]))
	match String(item.get("slot", "")):
		"weapon": item["damage_pct"] = float(item.get("damage_pct", 0.0)) * ratio
		"armor": item["hp"] = float(item.get("hp", 0.0)) * ratio
		"relic":
			if float(item.get("crit_pct", 0.0)) > 0.0:
				item["crit_pct"] = float(item.get("crit_pct", 0.0)) * ratio
			else:
				item["coin_pct"] = float(item.get("coin_pct", 0.0)) * ratio
	item["rarity_index"] = new_index
	item["rarity"] = String(RARITIES[new_index])
	item["enhance_level"] = 0
	item["awaken_count"] = int(item.get("awaken_count", 0)) + 1
	inventory[index] = item
	save_data()
	return true

func dismantle_value(item: Dictionary) -> int:
	var base := super.dismantle_value(item)
	return base + int(item.get("enhance_level", 0)) * 12 + int(item.get("awaken_count", 0)) * 45

func dismantle_index(index: int) -> int:
	if index < 0 or index >= inventory.size():
		return 0
	var expected := dismantle_value(inventory[index])
	var base_gained := super.dismantle_index(index)
	if base_gained <= 0:
		return 0
	var bonus := maxi(0, expected - base_gained)
	if bonus > 0:
		shards += bonus
		save_data()
	return expected

func item_score(item: Dictionary) -> int:
	return super.item_score(item) + int(item.get("enhance_level", 0)) * 145 + int(item.get("awaken_count", 0)) * 260

func stat_line(item: Dictionary) -> String:
	var line := super.stat_line(item)
	var enhance := int(item.get("enhance_level", 0))
	if enhance > 0:
		line += "  •  +%d" % enhance
	return line

func progression_line(item: Dictionary) -> String:
	var enhance := int(item.get("enhance_level", 0))
	var cap := max_enhance_level(item)
	var enchant_count := int(item.get("enchant_count", 0))
	return "ENHANCE %d/%d  •  ENCHANTS %d" % [enhance, cap, enchant_count]
