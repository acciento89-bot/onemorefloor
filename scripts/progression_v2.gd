extends "res://scripts/progression.gd"

# v1.17 — Meta Progression 2.0
# Existing Hero/Forge/Talents remain useful, but high tower milestones now award
# Ascension Sigils. Sigils feed three permanent mastery branches so reaching a new
# realm creates a lasting progression decision instead of only a higher Best Floor.

var ascension_sigils := 0
var sigils_claimed_total := 0
var warpath_mastery := 0
var guardian_mastery := 0
var arcana_mastery := 0

func load_data() -> void:
	super.load_data()
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		ascension_sigils = int(cfg.get_value("mastery", "sigils", 0))
		sigils_claimed_total = int(cfg.get_value("mastery", "sigils_claimed_total", 0))
		warpath_mastery = int(cfg.get_value("mastery", "warpath", 0))
		guardian_mastery = int(cfg.get_value("mastery", "guardian", 0))
		arcana_mastery = int(cfg.get_value("mastery", "arcana", 0))
	_award_missing_sigil_milestones(best_floor)

func save_data() -> void:
	super.save_data()
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("mastery", "sigils", ascension_sigils)
	cfg.set_value("mastery", "sigils_claimed_total", sigils_claimed_total)
	cfg.set_value("mastery", "warpath", warpath_mastery)
	cfg.set_value("mastery", "guardian", guardian_mastery)
	cfg.set_value("mastery", "arcana", arcana_mastery)
	cfg.set_value("system", "meta_progression_feature", "v1.17")
	cfg.save(SAVE_PATH)

func _eligible_sigil_total(floor_no: int) -> int:
	if floor_no < 50:
		return 0
	# One sigil every 25 floors, with additional landmark rewards when a new
	# endgame realm is broken open.
	var total := 1 + int((floor_no - 50) / 25)
	if floor_no >= 100:
		total += 1
	if floor_no >= 150:
		total += 1
	if floor_no >= 200:
		total += 2
	if floor_no > 200:
		total += int((floor_no - 200) / 100)
	return total

func _award_missing_sigil_milestones(floor_no: int) -> int:
	var eligible := _eligible_sigil_total(floor_no)
	var gained := maxi(0, eligible - sigils_claimed_total)
	if gained > 0:
		ascension_sigils += gained
		sigils_claimed_total = eligible
		save_data()
	return gained

func unlock_checkpoint(floor_no: int) -> bool:
	var unlocked := super.unlock_checkpoint(floor_no)
	_award_missing_sigil_milestones(floor_no)
	return unlocked

func mastery_level(kind: String) -> int:
	match kind:
		"warpath": return warpath_mastery
		"guardian": return guardian_mastery
		"arcana": return arcana_mastery
	return 0

func mastery_cost(kind: String) -> int:
	var level := mastery_level(kind)
	return 1 + int(level / 5)

func buy_mastery(kind: String) -> bool:
	var cost := mastery_cost(kind)
	if ascension_sigils < cost:
		return false
	match kind:
		"warpath": warpath_mastery += 1
		"guardian": guardian_mastery += 1
		"arcana": arcana_mastery += 1
		_: return false
	ascension_sigils -= cost
	save_data()
	return true

func hero_cost() -> int:
	var base := super.hero_cost()
	var deep := maxi(0, hero_level - 10)
	return base + deep * deep * 24

func forge_cost() -> int:
	var base := super.forge_cost()
	var deep := maxi(0, forge_level - 8)
	return base + deep * deep * 32

func talent_cost(kind: String) -> int:
	var level := talent_level(kind)
	var deep := maxi(0, level - 8)
	return super.talent_cost(kind) + deep * deep * 28

func hp_bonus() -> float:
	var hero_milestones := int(maxi(0, hero_level - 1) / 5)
	var vitality_milestones := int(vitality_level / 5)
	return super.hp_bonus() + float(hero_milestones * 16 + vitality_milestones * 30) + float(guardian_mastery) * 11.0

func damage_multiplier() -> float:
	var hero_milestones := int(maxi(0, hero_level - 1) / 5)
	var forge_milestones := int(forge_level / 5)
	return super.damage_multiplier() * (1.0 + float(hero_milestones) * 0.025 + float(forge_milestones) * 0.05 + float(warpath_mastery) * 0.06)

func crit_bonus() -> float:
	var precision_milestones := int(precision_level / 5)
	return super.crit_bonus() + float(precision_milestones) * 0.012 + float(arcana_mastery) * 0.004

func coin_multiplier() -> float:
	var fortune_milestones := int(fortune_level / 5)
	return super.coin_multiplier() * (1.0 + float(fortune_milestones) * 0.035)

func mastery_armor_bonus() -> float:
	return minf(0.18, float(guardian_mastery) * 0.008)

func mastery_nova_multiplier() -> float:
	return 1.0 + float(arcana_mastery) * 0.08

func mastery_crit_mult_bonus() -> float:
	return float(arcana_mastery) * 0.025

func power_score() -> int:
	return super.power_score() + warpath_mastery * 240 + guardian_mastery * 230 + arcana_mastery * 235 + sigils_claimed_total * 40
