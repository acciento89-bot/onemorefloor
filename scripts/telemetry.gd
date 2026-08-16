extends RefCounted

# v1.24 — privacy-first local analytics / release diagnostics.
# Nothing is uploaded from this class. It stores only game-state counters and
# bounded recent events after the player opts in. No names, emails, device IDs or
# free-form user text are collected.

const TELEMETRY_PATH := "user://telemetry.cfg"
const RECENT_LIMIT := 100
const RUN_HISTORY_LIMIT := 20
const SCHEMA_VERSION := 2

var enabled: bool = false
var previous_unclean: bool = false
var session_id: String = ""
var session_started_unix: int = 0
var build_version: String = "unknown"
var build_number: String = "unknown"
var last_heartbeat_msec: int = 0

func begin_session(allow_analytics: bool) -> void:
	enabled = allow_analytics
	var cfg := ConfigFile.new()
	cfg.load(TELEMETRY_PATH)
	previous_unclean = bool(cfg.get_value("session", "open", false))
	session_started_unix = int(Time.get_unix_time_from_system())
	session_id = "%d-%d" % [session_started_unix, int(Time.get_ticks_msec())]
	cfg.set_value("system", "schema_version", SCHEMA_VERSION)
	cfg.set_value("session", "open", true)
	cfg.set_value("session", "id", session_id)
	cfg.set_value("session", "started_at", session_started_unix)
	cfg.set_value("session", "platform", OS.get_name())
	cfg.save(TELEMETRY_PATH)
	if enabled:
		event("app_open", {"platform": OS.get_name(), "schema": SCHEMA_VERSION})
		if previous_unclean:
			event("unclean_previous_exit", {})

func set_build_context(version_name: String, build_no: String) -> void:
	build_version = version_name.left(48)
	build_number = build_no.left(24)
	var cfg := ConfigFile.new()
	cfg.load(TELEMETRY_PATH)
	cfg.set_value("system", "schema_version", SCHEMA_VERSION)
	cfg.set_value("system", "game_version", build_version)
	cfg.set_value("system", "build_number", build_number)
	cfg.save(TELEMETRY_PATH)
	if enabled:
		event("build_context", {"version": build_version, "build": build_number})

func set_enabled(value: bool) -> void:
	var changed := enabled != value
	enabled = value
	if enabled and changed:
		event("analytics_opt_in", {})
	elif not enabled and changed:
		# Store the consent state but intentionally do not log another analytics event.
		var cfg := ConfigFile.new()
		cfg.load(TELEMETRY_PATH)
		cfg.set_value("analytics", "disabled_at", int(Time.get_unix_time_from_system()))
		cfg.save(TELEMETRY_PATH)

func event(name: String, properties: Dictionary = {}) -> void:
	if not enabled:
		return
	var safe_name := _sanitize_event_name(name)
	if safe_name.is_empty():
		return
	var cfg := ConfigFile.new()
	cfg.load(TELEMETRY_PATH)
	var counts: Dictionary = cfg.get_value("analytics", "counts", {})
	counts[safe_name] = int(counts.get(safe_name, 0)) + 1
	var recent: Array = cfg.get_value("analytics", "recent", [])
	recent.push_back({
		"event": safe_name,
		"time": int(Time.get_unix_time_from_system()),
		"session": session_id,
		"properties": _sanitize_properties(properties)
	})
	while recent.size() > RECENT_LIMIT:
		recent.pop_front()
	cfg.set_value("analytics", "counts", counts)
	cfg.set_value("analytics", "recent", recent)
	cfg.set_value("system", "schema_version", SCHEMA_VERSION)
	cfg.save(TELEMETRY_PATH)

func heartbeat(floor_no: int, fps: float, enemy_count: int) -> void:
	if not enabled:
		return
	var now_msec := int(Time.get_ticks_msec())
	if last_heartbeat_msec > 0 and now_msec - last_heartbeat_msec < 15000:
		return
	last_heartbeat_msec = now_msec
	event("runtime_heartbeat", {
		"floor": maxi(0, floor_no),
		"fps": clampi(int(round(fps)), 0, 240),
		"enemies": clampi(enemy_count, 0, 100)
	})

func record_run_summary(summary: Dictionary) -> void:
	if not enabled:
		return
	var safe := _sanitize_properties(summary)
	var cfg := ConfigFile.new()
	cfg.load(TELEMETRY_PATH)
	var runs: Array = cfg.get_value("analytics", "recent_runs", [])
	runs.push_back({"time": int(Time.get_unix_time_from_system()), "summary": safe})
	while runs.size() > RUN_HISTORY_LIMIT:
		runs.pop_front()
	cfg.set_value("analytics", "recent_runs", runs)
	cfg.save(TELEMETRY_PATH)
	event("run_summary", safe)

func end_session() -> void:
	var now := int(Time.get_unix_time_from_system())
	if enabled:
		event("app_close", {"session_seconds": maxi(0, now - session_started_unix)})
	var cfg := ConfigFile.new()
	cfg.load(TELEMETRY_PATH)
	cfg.set_value("session", "open", false)
	cfg.set_value("session", "ended_at", now)
	cfg.set_value("session", "duration_seconds", maxi(0, now - session_started_unix))
	cfg.save(TELEMETRY_PATH)

func had_unclean_previous_exit() -> bool:
	return previous_unclean

func event_count(name: String) -> int:
	var cfg := ConfigFile.new()
	cfg.load(TELEMETRY_PATH)
	var counts: Dictionary = cfg.get_value("analytics", "counts", {})
	return int(counts.get(_sanitize_event_name(name), 0))

func diagnostic_snapshot() -> Dictionary:
	var cfg := ConfigFile.new()
	cfg.load(TELEMETRY_PATH)
	return {
		"schema": int(cfg.get_value("system", "schema_version", SCHEMA_VERSION)),
		"version": String(cfg.get_value("system", "game_version", build_version)),
		"build": String(cfg.get_value("system", "build_number", build_number)),
		"previous_unclean": previous_unclean,
		"session_open": bool(cfg.get_value("session", "open", false)),
		"event_counts": Dictionary(cfg.get_value("analytics", "counts", {})).duplicate(true),
		"recent_runs": Array(cfg.get_value("analytics", "recent_runs", [])).duplicate(true)
	}

func _sanitize_event_name(name: String) -> String:
	var out := ""
	for ch in name.to_lower():
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9") or ch == "_":
			out += ch
		if out.length() >= 48:
			break
	return out

func _sanitize_properties(properties: Dictionary) -> Dictionary:
	var out := {}
	var keys := properties.keys()
	for i in range(mini(keys.size(), 24)):
		var raw_key = keys[i]
		var key := _sanitize_event_name(String(raw_key))
		if key.is_empty():
			continue
		var value = properties[raw_key]
		if value is bool or value is int or value is float:
			out[key] = value
		elif value is String:
			out[key] = String(value).left(64)
	return out
