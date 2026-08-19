extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	for _i in range(10):
		await process_frame

	if not game.has_method("_v80_runtime_cta_ready") or not game.has_method("_v80_ui_snapshot"):
		_fail("r3 runtime CTA methods missing")
		return
	if not bool(game.call("_v80_runtime_cta_ready")):
		_fail("r3 runtime CTA layer did not become ready")
		return
	var snapshot: Dictionary = game.call("_v80_ui_snapshot")
	if String(snapshot.get("version", "")) != "1.62.0-ui-foundation-r3":
		_fail("r3 version marker missing")
		return
	for key in ["decision_cta_surfaces", "game_over_cta_surfaces"]:
		if not bool(snapshot.get(key, false)):
			_fail("r3 CTA contract missing: %s" % key)
			return
	if bool(snapshot.get("input_override", true)):
		_fail("r3 must not own input")
		return
	if String(snapshot.get("r21_fallback", "")) != "1.62.0-ui-foundation-r2.1":
		_fail("r2.1 fallback marker missing")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	for marker in ["main_v80.gd", "main_v79.gd", "main_v78.gd", "main_v77.gd", "main_v76.gd", "main_v75.gd"]:
		if not scene_text.contains(marker):
			_fail("r3 scene marker missing: %s" % marker)
			return
	var source := FileAccess.get_file_as_string("res://scripts/main_v80.gd")
	for marker in [
		"func draw_decision()",
		"_v80_runtime_cta(CASH",
		"_v80_runtime_cta(NEXT",
		"func draw_game_over()",
		"_v80_runtime_cta(RETRY",
		"_v80_runtime_cta(HOME_BTN",
		"_v76_primary_plate",
	]:
		if not source.contains(marker):
			_fail("r3 runtime CTA source marker missing: %s" % marker)
			return
	if source.contains("func pointer("):
		_fail("r3 introduced forbidden input override")
		return

	# Exercise the actual inherited runtime states. State mapping comes from main_v03.
	game.tutorial_active = false
	game.settings_open = false
	game.release_paused = false
	game.start_run()
	for _i in range(4):
		await process_frame
	game.state = 7 # DECISION
	if String(game.call("_v51_screen_from_legacy")) != "decision":
		_fail("decision runtime mapping changed")
		return
	game.queue_redraw()
	for _i in range(3):
		await process_frame
	game.state = 8 # GAME_OVER
	if String(game.call("_v51_screen_from_legacy")) != "game_over":
		_fail("game-over runtime mapping changed")
		return
	game.queue_redraw()
	for _i in range(3):
		await process_frame

	print("v1.62 UI foundation r3 runtime CTA smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V80_UI_FAIL:%s" % message)
	quit(1)
