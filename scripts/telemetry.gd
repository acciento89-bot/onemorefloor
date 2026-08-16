extends RefCounted

const TELEMETRY_PATH := "user://telemetry.cfg"
const RECENT_LIMIT := 30

var enabled: bool = false
var previous_unclean: bool = false
var session_id: String = ""

func begin_session(allow_analytics: bool) -> void:
	enabled = allow_analytics
	var cfg := ConfigFile.new()
	cfg.load(TELEMETRY_PATH)
	previous_unclean = bool(cfg.get_value("session", "open", false))
	session_id = "%d-%d" % [int(Time.get_unix_time_from_system()), int(Time.get_ticks_msec())]
	cfg.set_value("session", "open", true)
	cfg.set_value("session", "id", session_id)
	cfg.set_value("session", "started_at", int(Time.get_unix_time_from_system()))
	cfg.save(TELEMETRY_PATH)
	if enabled:
		event("app_open", {"platform": OS.get_name()})
		if previous_unclean:
			event("unclean_previous_exit", {})

func set_enabled(value: bool) -> void:
	enabled = value
	if enabled:
		event("analytics_opt_in", {})

func event(name: String, properties: Dictionary = {}) -> void:
	if not enabled:
		return
	var cfg := ConfigFile.new()
	cfg.load(TELEMETRY_PATH)
	var counts: Dictionary = cfg.get_value("analytics", "counts", {})
	counts[name] = int(counts.get(name, 0)) + 1
	var recent: Array = cfg.get_value("analytics", "recent", [])
	recent.push_back({
		"event": name,
		"time": int(Time.get_unix_time_from_system()),
		"session": session_id,
		"properties": properties.duplicate(true)
	})
	while recent.size() > RECENT_LIMIT:
		recent.pop_front()
	cfg.set_value("analytics", "counts", counts)
	cfg.set_value("analytics", "recent", recent)
	cfg.save(TELEMETRY_PATH)

func end_session() -> void:
	var cfg := ConfigFile.new()
	cfg.load(TELEMETRY_PATH)
	cfg.set_value("session", "open", false)
	cfg.set_value("session", "ended_at", int(Time.get_unix_time_from_system()))
	cfg.save(TELEMETRY_PATH)

func had_unclean_previous_exit() -> bool:
	return previous_unclean

func event_count(name: String) -> int:
	var cfg := ConfigFile.new()
	cfg.load(TELEMETRY_PATH)
	var counts: Dictionary = cfg.get_value("analytics", "counts", {})
	return int(counts.get(name, 0))
