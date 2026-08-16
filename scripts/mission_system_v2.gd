extends "res://scripts/mission_system.gd"

# v1.19 — Missions 2.0
# The first Daily stays a simple combat anchor; the other slots rotate. Advanced
# objectives are progression-gated so a new account never rolls an impossible
# Awaken/Enchant mission. Completing each full set unlocks a completion chest.

const DAILY_POOL: Array[Dictionary] = [
	{"id":"d_kills","title":"Tower Cleanup","event":"kills","goal":25,"coins":95,"xp":48,"min_floor":1},
	{"id":"d_floors_8","title":"Keep Climbing","event":"floors","goal":8,"coins":105,"xp":52,"min_floor":1},
	{"id":"d_cash_220","title":"Bring It Home","event":"cash","goal":220,"coins":125,"xp":62,"min_floor":1},
	{"id":"d_wardens_1","title":"Break the Gatekeeper","event":"wardens","goal":1,"coins":145,"xp":70,"min_floor":1},
	{"id":"d_contracts_2","title":"Contract Killer","event":"contracts","goal":2,"coins":135,"xp":68,"min_floor":6},
	{"id":"d_enhance_2","title":"Sharpen the Edge","event":"enhance","goal":2,"coins":115,"xp":58,"min_floor":8},
	{"id":"d_enchant_1","title":"Change Fate","event":"enchant","goal":1,"coins":130,"xp":66,"min_floor":20},
	{"id":"d_awaken_1","title":"Wake the Relic","event":"awaken","goal":1,"coins":180,"xp":90,"min_floor":50},
]

const WEEKLY_POOL: Array[Dictionary] = [
	{"id":"w_kills_240","title":"Purge the Tower","event":"kills","goal":240,"coins":620,"xp":310,"min_floor":1},
	{"id":"w_floors_55","title":"Tower Veteran","event":"floors","goal":55,"coins":700,"xp":340,"min_floor":1},
	{"id":"w_cash_2500","title":"Treasure Runner","event":"cash","goal":2500,"coins":820,"xp":390,"min_floor":1},
	{"id":"w_wardens_6","title":"Warden Hunter","event":"wardens","goal":6,"coins":780,"xp":380,"min_floor":5},
	{"id":"w_contracts_10","title":"Bounty Board","event":"contracts","goal":10,"coins":760,"xp":370,"min_floor":10},
	{"id":"w_enhance_12","title":"Master Smith","event":"enhance","goal":12,"coins":690,"xp":345,"min_floor":12},
	{"id":"w_enchant_5","title":"Fate Weaver","event":"enchant","goal":5,"coins":760,"xp":375,"min_floor":25},
	{"id":"w_awaken_2","title":"Ascendant Arsenal","event":"awaken","goal":2,"coins":980,"xp":470,"min_floor":60},
]

var daily_bonus_claimed := false
var weekly_bonus_claimed := false
var daily_bonus_key := ""
var weekly_bonus_key := ""
var progress_floor_context := 1

func set_progress_context(best_floor: int) -> void:
	progress_floor_context = maxi(1, best_floor)

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

func _eligible(pool: Array[Dictionary]) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for mission in pool:
		if progress_floor_context >= int(mission.get("min_floor", 1)):
			out.append(mission)
	return out

func _rotated(pool: Array[Dictionary], key: String, count: int) -> Array:
	var out: Array = []
	if pool.is_empty():
		return out
	var start := absi(key.hash()) % pool.size()
	for offset in range(pool.size()):
		out.append(pool[(start + offset) % pool.size()])
		if out.size() >= mini(count, pool.size()):
			break
	return out

func all_daily() -> Array:
	_refresh_periods()
	var eligible: Array[Dictionary] = _eligible(DAILY_POOL)
	if eligible.is_empty():
		return []
	var out: Array = [DAILY_POOL[0]]
	var rotating: Array[Dictionary] = []
	for mission in eligible:
		if String(mission.get("id", "")) != "d_kills":
			rotating.append(mission)
	out.append_array(_rotated(rotating, daily_key, 2))
	return out

func all_weekly() -> Array:
	_refresh_periods()
	return _rotated(_eligible(WEEKLY_POOL), weekly_key, 3)

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
