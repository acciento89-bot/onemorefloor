extends RefCounted

const SAVE_PATH := "user://save.cfg"

var best_floor := 1
var coins := 0
var hero_level := 1
var forge_level := 0
var vitality_level := 0
var precision_level := 0
var fortune_level := 0

func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	best_floor = int(cfg.get_value("progress", "best_floor", 1))
	coins = int(cfg.get_value("progress", "coins", 0))
	hero_level = int(cfg.get_value("meta", "hero_level", 1))
	forge_level = int(cfg.get_value("meta", "forge_level", 0))
	vitality_level = int(cfg.get_value("meta", "vitality_level", 0))
	precision_level = int(cfg.get_value("meta", "precision_level", 0))
	fortune_level = int(cfg.get_value("meta", "fortune_level", 0))

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "best_floor", best_floor)
	cfg.set_value("progress", "coins", coins)
	cfg.set_value("meta", "hero_level", hero_level)
	cfg.set_value("meta", "forge_level", forge_level)
	cfg.set_value("meta", "vitality_level", vitality_level)
	cfg.set_value("meta", "precision_level", precision_level)
	cfg.set_value("meta", "fortune_level", fortune_level)
	cfg.save(SAVE_PATH)

func hero_cost() -> int:
	return 90 + (hero_level - 1) * 70

func forge_cost() -> int:
	return 130 + forge_level * 105

func talent_cost(kind: String) -> int:
	var level := talent_level(kind)
	return 160 + level * 130

func talent_level(kind: String) -> int:
	match kind:
		"vitality": return vitality_level
		"precision": return precision_level
		"fortune": return fortune_level
	return 0

func buy_hero() -> bool:
	var cost := hero_cost()
	if coins < cost:
		return false
	coins -= cost
	hero_level += 1
	save_data()
	return true

func buy_forge() -> bool:
	var cost := forge_cost()
	if coins < cost:
		return false
	coins -= cost
	forge_level += 1
	save_data()
	return true

func buy_talent(kind: String) -> bool:
	var cost := talent_cost(kind)
	if coins < cost:
		return false
	coins -= cost
	match kind:
		"vitality": vitality_level += 1
		"precision": precision_level += 1
		"fortune": fortune_level += 1
		_: return false
	save_data()
	return true

func hp_bonus() -> float:
	return float((hero_level - 1) * 5 + vitality_level * 12)

func damage_multiplier() -> float:
	return 1.0 + float(hero_level - 1) * 0.035 + float(forge_level) * 0.085

func crit_bonus() -> float:
	return float(precision_level) * 0.018

func coin_multiplier() -> float:
	return 1.0 + float(fortune_level) * 0.06

func power_score() -> int:
	return 100 + hero_level * 75 + forge_level * 110 + vitality_level * 65 + precision_level * 70 + fortune_level * 55
