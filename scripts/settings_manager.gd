extends RefCounted

const SETTINGS_PATH := "user://settings.cfg"
const SETTINGS_VERSION := 1

var music_enabled: bool = true
var sfx_enabled: bool = true
var haptics_enabled: bool = true
var analytics_enabled: bool = false
var music_volume: float = 0.72
var sfx_volume: float = 0.88
var tutorial_done: bool = false

func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		save_data()
		return
	music_enabled = bool(cfg.get_value("audio", "music_enabled", true))
	sfx_enabled = bool(cfg.get_value("audio", "sfx_enabled", true))
	haptics_enabled = bool(cfg.get_value("feedback", "haptics_enabled", true))
	analytics_enabled = bool(cfg.get_value("privacy", "analytics_enabled", false))
	music_volume = clampf(float(cfg.get_value("audio", "music_volume", 0.72)), 0.0, 1.0)
	sfx_volume = clampf(float(cfg.get_value("audio", "sfx_volume", 0.88)), 0.0, 1.0)
	tutorial_done = bool(cfg.get_value("onboarding", "tutorial_done", false))

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SETTINGS_PATH)
	cfg.set_value("system", "version", SETTINGS_VERSION)
	cfg.set_value("audio", "music_enabled", music_enabled)
	cfg.set_value("audio", "sfx_enabled", sfx_enabled)
	cfg.set_value("audio", "music_volume", music_volume)
	cfg.set_value("audio", "sfx_volume", sfx_volume)
	cfg.set_value("feedback", "haptics_enabled", haptics_enabled)
	cfg.set_value("privacy", "analytics_enabled", analytics_enabled)
	cfg.set_value("onboarding", "tutorial_done", tutorial_done)
	cfg.save(SETTINGS_PATH)

func toggle_music() -> bool:
	music_enabled = not music_enabled
	save_data()
	return music_enabled

func toggle_sfx() -> bool:
	sfx_enabled = not sfx_enabled
	save_data()
	return sfx_enabled

func toggle_haptics() -> bool:
	haptics_enabled = not haptics_enabled
	save_data()
	return haptics_enabled

func toggle_analytics() -> bool:
	analytics_enabled = not analytics_enabled
	save_data()
	return analytics_enabled

func complete_tutorial() -> void:
	tutorial_done = true
	save_data()

func reset_tutorial() -> void:
	tutorial_done = false
	save_data()
