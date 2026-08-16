extends "res://scripts/mission_system.gd"

# v1.19 — Missions 2.0
# The screen still shows three Daily + three Weekly contracts, but the contracts
# rotate deterministically each period instead of repeating the same six forever.
# Completing a whole set also unlocks a completion chest.

const DAILY_POOL: Array[Dictionary] = [
	{"id":"d_kills_30","title":"Tower Cleanup","event":"kills","goal":30,"coins":95,"xp":48},
	{"id":"d_floors_8","title":"Keep Climbing","event":"floors","goal":8,"coins":105,"xp":52},
	{"id":"d_cash_220","title":"Bring It Home","event":"cash","goal":220,"coins":125,"xp":62},
	{"id":"d_wardens_1","title":"Break the Gatekeeper","event":"wardens","goal":1,"coins":145,"xp":70},
	{"id":"d_contracts_2","title":"Contract Killer","event":"contracts","goal":2,"coins":135,"xp":68},
	{"id":"d_enhance_2","title":"Sharpen the Edge","event":"enhance","goal":2,"coins":115,"xp":58},
	{"id":"d_enchant_1","title":"Change Fate","event":"enchant","goal":1,"coins":130,"xp":66},
	{"id":"d_awaken_1","title":"Wake the Relic","event":"awaken","goal":1,"coins":180,"xp":90},
]

const WEEKLY_POOL: Array[Dictionary] = [
	{"id":"w_kills_240","title":"Purge the Tower","event":"kills","goal":240,"coins":620,"xp":310},
	{"id":"w_floors_55","title":"Tower Veteran","event":"floors","goal":55,"coins":700,"xp":340},
	{"id":"w_cash_2500","title":"Treasure Runner","event":"cash","goal":2500,"coins":820,"xp":390},
	{"id":"w_wardens_6","title":"Warden Hunter","event":"wardens","goal":6,"coins":780,"xp":380},
	{"id":"w_contracts_10","title":"Bounty Board","event":"contracts","goal":10,"coins":760,"xp":370},
	{"id":"w_enhance_12","title":"Master Smith","event":"enhance","goal":12,"coins":690,"xp":345},
	{"id":"w_enchant_5","title":"Fate Weaver","event":"enchant","goal":5,"coins":760,"xp":375},
	{"id":"w_awaken_2","title":"Ascendant Arsenal","event":"awaken","goal":2,"coins":980,"xp":470},
]

var daily_bonus_claimed := false
var weekly_bonus_claimed := false
var daily_bonus_key := ""
var weekly_bonus_key := ""

func load_data() -> void:
	super.load_data()
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		daily_bonus_key = String(cfg.get_value("missions_v2", "daily_bonus_key", ""))
		weekly_bonus_key = String(cfg.get_value("missions_v2", "weekly_bonus_key", ""))
		daily_bonus_claimed = bool(cfg.get_value("missions_v2", "daily_bonus_claimed", false))
		weekly_bonus_claimed = bool(cfg.get_value("missions_v2", "weekly_bonus_claimed", false))
	_refresh_completion_periods()

func save_data() -> void:
	super.save_data()
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("missions_v2", "daily_bonus_key", daily_bonus_key)
	cfg.set_value("missions_v2", "weekly_bonus_key", weekly_bonus_key)
	cfg.set_value("missions_v2", "daily_bonus_claimed", daily_bonus_claimed)
	cfg.set_value("missions_v2", "weekly_bonus_claimed", weekly_bonus_claimed)
	cfg.set_value("system", "missions_feature", "v1.19")
	cfg.save(SAVE_PATH)

func _refresh_periods() -> void:
	super._refresh_periods()
	_refresh_completion_periods()

func _refresh_completion_periods() -> void:
	var changed := false
	if daily_bonus_key != daily_key:
		daily_bonus_key = daily_key
		daily_bonus_claimed = false
		changed = true
	if weekly_bonus_key != weekly_key:
		weekly_bonus_key = weekly_key
		weekly_bonus_claimed = false
		changed = true
	if changed and daily_key != "":
		save_data()

func _rotated(pool: Array[Dictionary], key: String, count: int, step: int) -> Array:
	var out: Array = []
	if pool.is_empty():
		return out
	var start := absi(key.hash()) % pool.size()
	for i in range(mini(count, pool.size())):
		out.append(pool[(start + i * step) % pool.size()])
	return out

func all_daily() -> Array:
	_refresh_periods()
	return _rotated(DAILY_POOL, daily_key, 3, 5)

func all_weekly() -> Array:
	_refresh_periods()
	return _rotated(WEEKLY_POOL, weekly_key, 3, 3)

func record(event: String, amount: int = 1) -> void:
	_refresh_periods()
	for mission in all_daily():
		if String(mission["event"]) == event:
			var id := String(mission["id"])
			daily_progress[id] = mini(int(mission["goal"]), int(daily_progress.get(id, 0)) + amount)
	for mission in all_weekly():
		if String(mission["event"]) == event:
			var id := String(mission["id"])
			weekly_progress[id] = mini(int(mission["goal"]), int(weekly_progress.get(id, 0)) + amount)
	save_data()

func completion_bonus_claimable(weekly: bool) -> bool:
	var list: Array = all_weekly() if weekly else all_daily()
	if list.is_empty():
		return false
	for mission in list:
		if not is_claimed(mission, weekly):
			return false
	return not (weekly_bonus_claimed if weekly else daily_bonus_claimed)

func claim_completion_bonus(weekly: bool) -> Dictionary:
	if not completion_bonus_claimable(weekly):
		return {}
	if weekly:
		weekly_bonus_claimed = true
	else:
		daily_bonus_claimed = true
	save_data()
	if weekly:
		return {"coins":900, "xp":420, "shards":45}
	return {"coins":180, "xp":90, "shards":10}
