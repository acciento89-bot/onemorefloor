extends SceneTree

func _init() -> void:
	call_deferred("_run_v11_smoke")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run_v11_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(201, "v1.1 smoke: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)

	if not game.has_method("screen_to_design") or not game.has_method("_sync_music_context"):
		_fail(202, "v1.1 smoke: responsive visual controller is not active")
		return

	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("window/stretch/aspect=\"expand\""):
		_fail(203, "v1.1 smoke: edge-to-edge expand canvas is not configured")
		return
	if not project_text.contains("config/version=\"1.1.0-rc1\""):
		_fail(204, "v1.1 smoke: v1.1 project version is missing")
		return

	var controller_text := FileAccess.get_file_as_string("res://scripts/main_v11.gd")
	if controller_text.contains("super.draw_home()"):
		_fail(205, "v1.1 smoke: home still inherits legacy development-label drawing")
		return
	var legacy_labels := [
		"v0.3 META PROGRESSION",
		"v0.4 LOOT + MISSIONS",
		"v0.6 VISUAL PRODUCTION",
		"v0.8 ANIMATION + VAULT",
		"v0.9 FORGOTTEN CASTLE",
		"v1.0 RC1"
	]
	for label in legacy_labels:
		if controller_text.contains(label):
			_fail(206, "v1.1 smoke: legacy visible development label leaked into v1.1: %s" % label)
			return

	if game.release_audio == null:
		_fail(207, "v1.1 smoke: release audio is not initialized")
		return
	var contexts: Array[String] = game.release_audio.available_music_contexts()
	for context in ["menu", "dungeon", "crypt", "castle", "boss"]:
		if not contexts.has(context):
			_fail(208, "v1.1 smoke: missing music context %s" % context)
			return
		var stream = game.release_audio.music_streams.get(context)
		if stream == null or not stream is AudioStream:
			_fail(209, "v1.1 smoke: music context %s has no AudioStream" % context)
			return
	if game.release_audio.music_streams["menu"] == game.release_audio.music_streams["dungeon"]:
		_fail(210, "v1.1 smoke: menu and dungeon still share the same music stream")
		return

	game.tutorial_active = false
	game.start_run()
	game._sync_music_context(true)
	if String(game.release_audio.music_context) != "dungeon":
		_fail(211, "v1.1 smoke: run did not switch to dungeon music")
		return

	game.current_room["area"] = "CRYPT"
	game.enemies.clear()
	game._sync_music_context(true)
	if String(game.release_audio.music_context) != "crypt":
		_fail(212, "v1.1 smoke: Crypt did not switch music")
		return

	game.current_room["area"] = "FORGOTTEN CASTLE"
	game._sync_music_context(true)
	if String(game.release_audio.music_context) != "castle":
		_fail(213, "v1.1 smoke: Forgotten Castle did not switch music")
		return

	game.enemies.append({"type":"warden"})
	game._sync_music_context(true)
	if String(game.release_audio.music_context) != "boss":
		_fail(214, "v1.1 smoke: live boss did not switch to boss music")
		return

	game.enemies.clear()
	game.state = game.State.HOME
	game._sync_music_context(true)
	if String(game.release_audio.music_context) != "menu":
		_fail(215, "v1.1 smoke: home did not restore menu music")
		return

	var translated := game.screen_to_design(game.v11_layout_offset + Vector2(222, 333))
	if translated.distance_to(Vector2(222, 333)) > 0.01:
		_fail(216, "v1.1 smoke: touch coordinate translation is incorrect")
		return

	print("ONE MORE FLOOR v1.1 visual/audio smoke test passed")
	quit(0)
