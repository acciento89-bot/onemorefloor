extends RefCounted

const SAVE_PATH := "user://save.cfg"
const CURRENT_SAVE_VERSION := 3

var best_floor := 1
var checkpoint_floor := 1
var coins := 0
var hero_level := 1
var forge_level := 0
var vitality_level := 0
var precision_level := 0
var fortune_level := 0

func load_data() -> void:
	var cfg := ConfigFile.new()
	var status: Error = cfg.load(SAVE_PATH)
	if status != OK:
		save_data()
		return
	var from_version: int = int(cfg.get_value("system", "save_version", 0))
	if from_version < CURRENT_SAVE_VERSION:
		_migrate(cfg, from_version)
	best_floor = int(cfg.get_value("progress", "best_floor", 1))
	if not cfg.has_section_key("progress", "checkpoint_floor"):
		checkpoint_floor = 50 if best_floor >= 50 else 1
		cfg.set_value("progress", "checkpoint_floor", checkpoint_floor)
		cfg.set_value("system", "checkpoint_feature", "v1.14-setback")
		cfg.save(SAVE_PATH)
	else:
		checkpoint_floor = int(cfg.get_value("progress", "checkpoint_floor", 1))
	if checkpoint_floor > 1 and checkpoint_floor < 50:
		checkpoint_floor = 1
	coins = int(cfg.get_value("progress", "coins", 0))
	hero_level = int(cfg.get_value("meta", "hero_level", 1))
	forge_level = int(cfg.get_value("meta", "forge_level", 0))
	vitality_level = int(cfg.get_value("meta", "vitality_level", 0))
	precision_level = int(cfg.get_value("meta", "precision_level", 0))
	fortune_level = int(cfg.get_value("meta", "fortune_level", 0))

func _migrate(cfg: ConfigFile, from_version: int) -> void:
	# Preserve all previous progress. v1.14 only changes the rules around how a
	# deep checkpoint can move backwards after death; historical best floor never
	# decreases.
	if from_version < 1:
		cfg.set_value("system", "created_with", "pre-v1.0")
	if from_version < 2:
		cfg.set_value("system", "last_migration", "v1.0-rc1")
	if from_version < 3:
		cfg.set_value("system", "last_migration", "v1.14-endless-ascension")
		cfg.set_value("system", "checkpoint_feature", "v1.14-setback")
	cfg.set_value("system", "save_version", CURRENT_SAVE_VERSION)
	cfg.save(SAVE_PATH)

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("system", "save_version", CURRENT_SAVE_VERSION)
	cfg.set_value("system", "game_version", "1.14-endless-ascension")
	cfg.set_value("system", "checkpoint_feature", "v1.14-setback")
	cfg.set_value("progress", "best_floor", best_floor)
	cfg.set_value("progress", "checkpoint_floor", checkpoint_floor)
	cfg.set_value("progress", "coins", coins)
	cfg.set_value("meta", "hero_level", hero_level)
	cfg.set_value("meta", "forge_level", forge_level)
	cfg.set_value("meta", "vitality_level", vitality_level)
	cfg.set_value("meta", "precision_level", precision_level)
	cfg.set_value("meta", "fortune_level", fortune_level)
	cfg.save(SAVE_PATH)

func save_version() -> int:
	return CURRENT_SAVE_VERSION

func run_start_floor() -> int:
	return checkpoint_floor if checkpoint_floor >= 50 else 1

func unlock_checkpoint(floor_no: int) -> bool:
	if floor_no < 50 or floor_no <= checkpoint_floor:
		return false
	checkpoint_floor = floor_no
	best_floor = maxi(best_floor, floor_no)
	save_data()
	return true

func death_setback_amount(death_floor: int) -> int:
	if checkpoint_floor < 50:
		return 0
	var depth := maxi(death_floor, checkpoint_floor)
	if depth >= 200:
		return 15
	if depth >= 125:
		return 10
	if depth >= 75:
		return 7
	return 5

func apply_death_setback(death_floor: int) -> int:
	# Floor 50 is the permanent deep-tower foothold. Above that, dying costs real
	# progress. Cashing out never applies this penalty, so pushing deeper remains a
	# meaningful risk/reward decision.
	if checkpoint_floor < 50:
		return 0
	var old_checkpoint := checkpoint_floor
	checkpoint_floor = maxi(50, checkpoint_floor - death_setback_amount(death_floor))
	best_floor = maxi(best_floor, death_floor)
	save_data()
	return old_checkpoint - checkpoint_floor

func hero_cost() -> int:
	return 90 + (hero_level - 1) * 70

func forge_cost() -> int:
	return 130 + forge_level * 105

func talent_cost(kind: String) -> int:
	var level: int = talent_level(kind)
	return 160 + level * 130

func talent_level(kind: String) -> int:
	match kind:
		"vitality": return vitality_level
		"precision": return precision_level
		"fortune": return fortune_level
	return 0

func buy_hero() -> bool:
	var cost: int = hero_cost()
	if coins < cost:
		return false
	coins -= cost
	hero_level += 1
	save_data()
	return true

func buy_forge() -> bool:
	var cost: int = forge_cost()
	if coins < cost:
		return false
	coins -= cost
	forge_level += 1
	save_data()
	return true

func buy_talent(kind: String) -> bool:
	var cost: int = talent_cost(kind)
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
