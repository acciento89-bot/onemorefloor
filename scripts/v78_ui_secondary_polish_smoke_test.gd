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

	if not game.has_method("_v78_ui_secondary_ready") or not game.has_method("_v78_ui_snapshot"):
		_fail("r2 UI methods missing")
		return
	if not bool(game.call("_v78_ui_secondary_ready")):
		_fail("r2 UI layer did not become ready")
		return
	var snapshot: Dictionary = game.call("_v78_ui_snapshot")
	if String(snapshot.get("version", "")) != "1.62.0-ui-foundation-r2":
		_fail("r2 version marker missing")
		return
	for key in ["vault_compact_controls", "store_action_chips", "missions_preserved", "tower_pass_preserved"]:
		if not bool(snapshot.get(key, false)):
			_fail("r2 UI contract missing: %s" % key)
			return
	if String(snapshot.get("r11_fallback", "")) != "1.62.0-ui-foundation-r1.1":
		_fail("r1.1 fallback marker missing")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	for marker in ["main_v78.gd", "main_v77.gd", "main_v76.gd", "main_v75.gd"]:
		if not scene_text.contains(marker):
			_fail("r2 scene marker missing: %s" % marker)
			return
	var source := FileAccess.get_file_as_string("res://scripts/main_v78.gd")
	for marker in [
		"_v78_draw_vault_compact_control",
		"V8_FILTER",
		"V8_CRAFT_WEAPON",
		"V31_ENHANCE",
		"_v78_store_action_chip",
		"_v42_store_card",
		"action_rect",
	]:
		if not source.contains(marker):
			_fail("r2 source contract missing: %s" % marker)
			return

	# Exercise the two changed screens through the existing router. No new route or
	# action ownership is introduced by this presentation pass.
	game.tutorial_active = false
	game.settings_open = false
	game.release_paused = false
	for route in ["vault", "store", "missions", "pass", "home"]:
		if route == "home":
			if not bool(game.call("_v51_route_home", false)):
				_fail("home route failed under r2")
				return
		else:
			if not bool(game.call("_v51_route_to", route, false)):
				_fail("route failed under r2: %s" % route)
				return
		for _i in range(2):
			await process_frame

	print("v1.62 UI foundation r2 smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V78_UI_FAIL:%s" % message)
	quit(1)
