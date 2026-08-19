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

	for method in [
		"_v76_ui_foundation_ready",
		"_v76_ui_snapshot",
		"_v16_frame",
		"_v16_button",
		"_v16_medallion",
		"_v40_activity_button",
		"_v40_home_tab",
		"_v36_utility_button",
		"_v16_section",
	]:
		if not game.has_method(method):
			_fail("v1.62 UI method missing: %s" % method)
			return

	if not bool(game.call("_v76_ui_foundation_ready")):
		_fail("v1.62 UI foundation did not become ready")
		return
	var snapshot: Dictionary = game.call("_v76_ui_snapshot")
	if String(snapshot.get("version", "")) != "1.62.0-ui-foundation-r1":
		_fail("v1.62 UI version marker missing")
		return
	for key in ["shared_panel", "shared_button", "shared_tab", "shared_badge", "shared_section"]:
		if not bool(snapshot.get(key, false)):
			_fail("v1.62 shared component contract missing: %s" % key)
			return
	if String(snapshot.get("combat_lock", "")) != "1.61-combat-presentation-r3.2":
		_fail("v1.61 combat lock marker regressed")
		return

	# Navigation remains owned by the validated menu router. Exercise all major
	# menu routes rather than inventing new UI-specific click areas.
	game.tutorial_active = false
	game.settings_open = false
	game.release_paused = false
	for route in ["home", "hero", "forge", "talents", "vault", "missions", "pass", "store"]:
		if route == "home":
			if not bool(game.call("_v51_route_home", false)):
				_fail("home route failed under v1.62")
				return
		else:
			if not bool(game.call("_v51_route_to", route, false)):
				_fail("menu route failed under v1.62: %s" % route)
				return
		if String(game.call("_v51_screen_from_legacy")) != route:
			_fail("menu route mapping changed under v1.62: %s" % route)
			return

	# Confirm the new layer is actually the scene entry while older baselines stay
	# referenced for regressions.
	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	for marker in ["main_v76.gd", "main_v75.gd", "menu_shell.gd", "MenuShell"]:
		if not scene_text.contains(marker):
			_fail("v1.62 scene marker missing: %s" % marker)
			return
	var ui_text := FileAccess.get_file_as_string("res://scripts/main_v76.gd")
	for marker in ["_v76_surface", "_v76_primary_plate", "_v16_button", "_v40_home_tab", "V76_BRASS"]:
		if not ui_text.contains(marker):
			_fail("v1.62 UI source contract missing: %s" % marker)
			return

	print("v1.62 UI foundation smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V76_UI_FAIL:%s" % message)
	quit(1)
