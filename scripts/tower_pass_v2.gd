extends RefCounted

# v1.19 — Tower Pass 2.0
# Calendar-month seasons, 50 levels, free + premium claim tracks. The premium
# track adds convenience currency only; core combat power still comes from play.

const SAVE_PATH := "user://save.cfg"
const MAX_LEVEL := 50

var xp := 0
var free_claimed := {}
var premium_claimed := {}
var season_key := ""

func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		season_key = current_season_key()
		save_data()
		return
	var stored_season := String(cfg.get_value("tower_pass_v2", "season_key", ""))
	if stored_season == "":
		# Migrate the original 20-level pass in place without deleting progress.
		xp = int(cfg.get_value("tower_pass", "xp", 0))
		free_claimed = cfg.get_value("tower_pass", "claimed", {})
		premium_claimed = {}
		season_key = current_season_key()
		save_data()
		return
	season_key = stored_season
	xp = int(cfg.get_value("tower_pass_v2", "xp", 0))
	free_claimed = cfg.get_value("tower_pass_v2", "free_claimed", {})
	premium_claimed = cfg.get_value("tower_pass_v2", "premium_claimed", {})
	_refresh_season()

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("tower_pass_v2", "season_key", season_key)
	cfg.set_value("tower_pass_v2", "xp", xp)
	cfg.set_value("tower_pass_v2", "free_claimed", free_claimed)
	cfg.set_value("tower_pass_v2", "premium_claimed", premium_claimed)
	cfg.set_value("system", "tower_pass_feature", "v1.19")
	cfg.save(SAVE_PATH)

func current_season_key() -> String:
	var dt := Time.get_datetime_dict_from_system()
	return "%04d-%02d" % [int(dt.get("year", 2026)), int(dt.get("month", 1))]

func _refresh_season() -> void:
	var current := current_season_key()
	if season_key == current:
		return
	season_key = current
	xp = 0
	free_claimed = {}
	premium_claimed = {}
	save_data()

func add_xp(amount: int) -> void:
	_refresh_season()
	xp = maxi(0, xp + amount)
	save_data()

func xp_for_level(level_no: int) -> int:
	# Cumulative XP. Early levels move quickly; the back half asks for consistent
	# mission/contract play without turning into an impossible grind.
	var level := clampi(level_no, 0, MAX_LEVEL)
	return int(round(float(level) * 85.0 + pow(float(level), 1.55) * 18.0))

func level() -> int:
	_refresh_season()
	var result := 0
	for i in range(1, MAX_LEVEL + 1):
		if xp >= xp_for_level(i):
			result = i
		else:
			break
	return result

func progress_to_next() -> Dictionary:
	var current := level()
	if current >= MAX_LEVEL:
		return {"current":100, "needed":100, "ratio":1.0}
	var prev_xp := xp_for_level(current)
	var next_xp := xp_for_level(current + 1)
	var current_xp := maxi(0, xp - prev_xp)
	var needed := maxi(1, next_xp - prev_xp)
	return {"current":current_xp, "needed":needed, "ratio":clampf(float(current_xp) / float(needed), 0.0, 1.0)}

func reward_for(level_no: int, premium: bool = false) -> Dictionary:
	var lvl := clampi(level_no, 1, MAX_LEVEL)
	if premium:
		if lvl % 10 == 0:
			return {"coins":500 + lvl * 24, "shards":35 + int(lvl * 0.8), "label":"PREMIUM RELIC CACHE"}
		if lvl % 5 == 0:
			return {"coins":280 + lvl * 18, "shards":22 + int(lvl * 0.5), "label":"PREMIUM CACHE"}
		return {"coins":100 + lvl * 8, "shards":6 + int(lvl / 7), "label":"PREMIUM SUPPLIES"}
	if lvl % 10 == 0:
		return {"coins":420 + lvl * 22, "shards":18 + int(lvl * 0.35), "label":"BIG COIN CACHE"}
	if lvl % 5 == 0:
		return {"coins":240 + lvl * 15, "shards":10 + int(lvl * 0.25), "label":"TOWER CACHE"}
	if lvl % 3 == 0:
		return {"coins":150 + lvl * 10, "shards":4, "label":"COIN CACHE"}
	return {"coins":95 + lvl * 7, "shards":0, "label":"COINS"}

func can_claim(level_no: int, premium: bool = false, premium_unlocked: bool = false) -> bool:
	_refresh_season()
	if level_no <= 0 or level_no > level():
		return false
	if premium and not premium_unlocked:
		return false
	var source: Dictionary = premium_claimed if premium else free_claimed
	return not bool(source.get(str(level_no), false))

func claim(level_no: int, premium: bool = false, premium_unlocked: bool = false) -> Dictionary:
	if not can_claim(level_no, premium, premium_unlocked):
		return {}
	if premium:
		premium_claimed[str(level_no)] = true
	else:
		free_claimed[str(level_no)] = true
	save_data()
	return reward_for(level_no, premium)

func next_claimable(premium: bool = false, premium_unlocked: bool = false) -> int:
	for i in range(1, level() + 1):
		if can_claim(i, premium, premium_unlocked):
			return i
	return -1

func unclaimed_count(premium: bool = false, premium_unlocked: bool = false) -> int:
	var total := 0
	for i in range(1, level() + 1):
		if can_claim(i, premium, premium_unlocked):
			total += 1
	return total
