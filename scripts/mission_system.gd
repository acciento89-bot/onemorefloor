extends RefCounted

const SAVE_PATH := "user://save.cfg"

const DAILY := [
	{"id":"d_kills","title":"Tower Cleanup","event":"kills","goal":25,"coins":80,"xp":40},
	{"id":"d_floors","title":"Keep Climbing","event":"floors","goal":8,"coins":100,"xp":50},
	{"id":"d_cash","title":"Bring It Home","event":"cash","goal":150,"coins":120,"xp":60},
]
const WEEKLY := [
	{"id":"w_wardens","title":"Warden Hunter","event":"wardens","goal":3,"coins":350,"xp":180},
	{"id":"w_floors","title":"Tower Veteran","event":"floors","goal":40,"coins":450,"xp":220},
	{"id":"w_cash","title":"Treasure Runner","event":"cash","goal":1500,"coins":600,"xp":300},
]

var daily_progress := {}
var weekly_progress := {}
var daily_claimed := {}
var weekly_claimed := {}
var daily_key := ""
var weekly_key := ""

func load_data() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	daily_key = String(cfg.get_value("missions", "daily_key", ""))
	weekly_key = String(cfg.get_value("missions", "weekly_key", ""))
	daily_progress = cfg.get_value("missions", "daily_progress", {})
	weekly_progress = cfg.get_value("missions", "weekly_progress", {})
	daily_claimed = cfg.get_value("missions", "daily_claimed", {})
	weekly_claimed = cfg.get_value("missions", "weekly_claimed", {})
	_refresh_periods()

func _refresh_periods() -> void:
	var now_daily := Time.get_date_string_from_system()
	var now_weekly := str(int(Time.get_unix_time_from_system() / 604800.0))
	var changed := false
	if daily_key != now_daily:
		daily_key = now_daily
		daily_progress = {}
		daily_claimed = {}
		changed = true
	if weekly_key != now_weekly:
		weekly_key = now_weekly
		weekly_progress = {}
		weekly_claimed = {}
		changed = true
	if changed:
		save_data()

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("missions", "daily_key", daily_key)
	cfg.set_value("missions", "weekly_key", weekly_key)
	cfg.set_value("missions", "daily_progress", daily_progress)
	cfg.set_value("missions", "weekly_progress", weekly_progress)
	cfg.set_value("missions", "daily_claimed", daily_claimed)
	cfg.set_value("missions", "weekly_claimed", weekly_claimed)
	cfg.save(SAVE_PATH)

func record(event: String, amount: int = 1) -> void:
	_refresh_periods()
	for mission in DAILY:
		if String(mission["event"]) == event:
			var id := String(mission["id"])
			daily_progress[id] = mini(int(mission["goal"]), int(daily_progress.get(id, 0)) + amount)
	for mission in WEEKLY:
		if String(mission["event"]) == event:
			var id := String(mission["id"])
			weekly_progress[id] = mini(int(mission["goal"]), int(weekly_progress.get(id, 0)) + amount)
	save_data()

func progress(mission: Dictionary, weekly: bool) -> int:
	var source := weekly_progress if weekly else daily_progress
	return int(source.get(String(mission["id"]), 0))

func is_complete(mission: Dictionary, weekly: bool) -> bool:
	return progress(mission, weekly) >= int(mission["goal"])

func is_claimed(mission: Dictionary, weekly: bool) -> bool:
	var source := weekly_claimed if weekly else daily_claimed
	return bool(source.get(String(mission["id"]), false))

func claim(mission: Dictionary, weekly: bool) -> Dictionary:
	if not is_complete(mission, weekly) or is_claimed(mission, weekly):
		return {}
	var id := String(mission["id"])
	if weekly:
		weekly_claimed[id] = true
	else:
		daily_claimed[id] = true
	save_data()
	return {"coins":int(mission["coins"]), "xp":int(mission["xp"])}

func all_daily() -> Array:
	return DAILY

func all_weekly() -> Array:
	return WEEKLY
