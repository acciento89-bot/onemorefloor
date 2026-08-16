extends SceneTree

func _init() -> void:
	call_deferred("_run_release_smoke")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run_release_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(101, "Release smoke: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)

	if game.settings == null or game.telemetry == null or game.balance == null or game.release_audio == null:
		_fail(102, "Release smoke: v1.0 release systems were not initialized")
		return

	var audio_paths := [
		"res://assets/audio/menu_click.wav",
		"res://assets/audio/attack.wav",
		"res://assets/audio/loot.wav",
		"res://assets/audio/nova.wav",
		"res://assets/audio/boss.wav"
	]
	for path in audio_paths:
		var stream = load(path)
		if stream == null or not stream is AudioStream:
			_fail(103, "Release smoke: WAV failed to import: %s" % path)
			return
	if game.release_audio.music_player == null or game.release_audio.music_player.stream == null:
		_fail(104, "Release smoke: release music player is not wired")
		return

	var save_cfg := ConfigFile.new()
	save_cfg.load("user://save.cfg")
	save_cfg.set_value("smoke", "preserve_me", 12345)
	save_cfg.save("user://save.cfg")
	game.meta.coins += 1
	game.meta.save_data()
	var check_cfg := ConfigFile.new()
	if check_cfg.load("user://save.cfg") != OK:
		_fail(105, "Release smoke: save file could not be reloaded")
		return
	var persisted_save_version := int(check_cfg.get_value("system", "save_version", 0))
	if persisted_save_version < 2 or persisted_save_version != int(game.meta.save_version()):
		_fail(106, "Release smoke: save version migration did not reach the current schema")
		return
	if int(check_cfg.get_value("smoke", "preserve_me", 0)) != 12345:
		_fail(107, "Release smoke: meta save overwrote another save section")
		return

	game.settings.music_enabled = false
	game.settings.sfx_enabled = false
	game.settings.haptics_enabled = false
	game.settings.analytics_enabled = false
	game.settings.save_data()
	var SettingsManager = load("res://scripts/settings_manager.gd")
	var settings_copy = SettingsManager.new()
	settings_copy.load_data()
	if bool(settings_copy.music_enabled) or bool(settings_copy.sfx_enabled) or bool(settings_copy.haptics_enabled) or bool(settings_copy.analytics_enabled):
		_fail(108, "Release smoke: settings persistence failed")
		return
	game.settings.music_enabled = true
	game.settings.sfx_enabled = true
	game.settings.haptics_enabled = true
	game.settings.save_data()
	game.haptics_enabled = true
	game.release_audio.apply_settings()

	var enemy_factory = load("res://scripts/enemy_factory.gd")
	var entry_enemy: Dictionary = enemy_factory.make_enemy("goblin", 1, game.rng, Vector2(360, 700))
	var hp_before: float = float(entry_enemy["max_hp"])
	entry_enemy = game.balance.apply_enemy(entry_enemy, 1)
	if not bool(entry_enemy.get("release_balanced", false)) or float(entry_enemy["max_hp"]) >= hp_before:
		_fail(109, "Release smoke: entry-floor balance profile was not applied")
		return
	var castle_m: Dictionary = game.balance.multipliers(30, true)
	if float(castle_m["hp"]) <= 1.0:
		_fail(110, "Release smoke: Castle boss balance curve is missing")
		return

	game.tutorial_active = false
	game.start_run()
	if game.state != game.State.RUNNING:
		_fail(111, "Release smoke: release controller could not start a run")
		return
	game._set_pause(true)
	if not bool(game.release_paused) or not bool(game._release_blocks_gameplay()):
		_fail(112, "Release smoke: pause did not block gameplay")
		return
	game._set_pause(false)
	if bool(game.release_paused):
		_fail(113, "Release smoke: resume did not clear pause")
		return

	game.settings.reset_tutorial()
	game.tutorial_active = true
	game.tutorial_step = 4
	game._complete_tutorial()
	if bool(game.tutorial_active) or not bool(game.settings.tutorial_done):
		_fail(114, "Release smoke: tutorial completion was not persisted")
		return

	game.telemetry.set_enabled(false)
	var count_before_disabled: int = int(game.telemetry.event_count("release_smoke"))
	game.telemetry.event("release_smoke", {"mode": "disabled"})
	if int(game.telemetry.event_count("release_smoke")) != count_before_disabled:
		_fail(115, "Release smoke: analytics recorded while opt-out was active")
		return
	game.telemetry.set_enabled(true)
	var count_before_enabled: int = int(game.telemetry.event_count("release_smoke"))
	game.telemetry.event("release_smoke", {"mode": "enabled"})
	if int(game.telemetry.event_count("release_smoke")) != count_before_enabled + 1:
		_fail(116, "Release smoke: opt-in analytics event was not recorded")
		return

	print("ONE MORE FLOOR v1.0 release smoke test passed")
	quit(0)
