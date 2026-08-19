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

	if not game.has_method("_v77_ui_balance_ready") or not game.has_method("_v77_ui_snapshot"):
		_fail("r1.1 UI balance methods missing")
		return
	if not bool(game.call("_v77_ui_balance_ready")):
		_fail("r1.1 UI balance did not become ready")
		return
	var snapshot: Dictionary = game.call("_v77_ui_snapshot")
	if String(snapshot.get("version", "")) != "1.62.0-ui-foundation-r1.1":
		_fail("r1.1 version marker missing")
		return
	if not bool(snapshot.get("dark_panel_balance", false)):
		_fail("r1.1 dark panel contract missing")
		return
	if String(snapshot.get("r1_fallback", "")) != "1.62.0-ui-foundation-r1":
		_fail("r1 fallback marker missing")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	for marker in ["main_v77.gd", "main_v76.gd", "main_v75.gd"]:
		if not scene_text.contains(marker):
			_fail("r1.1 scene marker missing: %s" % marker)
			return
	var source := FileAccess.get_file_as_string("res://scripts/main_v77.gd")
	for marker in ["tint_strength", "safe_fill.a = 0.96", "fill.a < 0.50"]:
		if not source.contains(marker):
			_fail("r1.1 surface-balance source marker missing: %s" % marker)
			return

	# Router ownership remains unchanged under the new visual subclass.
	game.tutorial_active = false
	game.settings_open = false
	for route in ["hero", "forge", "talents", "home"]:
		if route == "home":
			if not bool(game.call("_v51_route_home", false)):
				_fail("home route failed")
				return
		else:
			if not bool(game.call("_v51_route_to", route, false)):
				_fail("route failed: %s" % route)
				return

	print("v1.62 UI foundation r1.1 smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V77_UI_FAIL:%s" % message)
	quit(1)
