extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(5101, "v1.38 main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	for method in [
		"_v51_menu_foundation_ready",
		"_v51_screen_from_legacy",
		"_v51_route_to",
		"_v51_route_home",
		"_v51_world_layer_requested",
	]:
		if not game.has_method(method):
			_fail(5102, "v1.38 menu foundation method missing: %s" % method)
			return
	if not bool(game._v51_menu_foundation_ready()):
		_fail(5103, "v1.38 menu foundation runtime not ready")
		return
	if game.v51_navigation == null or game.v51_menu_shell == null:
		_fail(5104, "v1.38 router or CanvasLayer shell missing")
		return

	var menu_routes := ["hero", "forge", "talents", "vault", "missions", "pass", "store"]
	for route in menu_routes:
		if not bool(game._v51_route_to(route, false)):
			_fail(5105, "v1.38 route rejected: %s" % route)
			return
		if String(game._v51_screen_from_legacy()) != route:
			_fail(5106, "v1.38 legacy mapping mismatch: %s" % route)
			return
		if String(game.v51_navigation.current_screen) != route:
			_fail(5107, "v1.38 router mismatch: %s" % route)
			return
		game._v51_sync_shell()
		if String(game.v51_menu_shell.active_screen) != route or not bool(game.v51_menu_shell.menu_visible):
			_fail(5108, "v1.38 CanvasLayer shell mismatch: %s" % route)
			return
		if not bool(game._v51_route_home(false)):
			_fail(5109, "v1.38 route home failed from: %s" % route)
			return
		if String(game.v51_navigation.current_screen) != "home":
			_fail(5110, "v1.38 router did not return home")
			return

	if bool(game._v51_route_to("not-a-screen", false)):
		_fail(5111, "v1.38 unknown route was accepted")
		return
	if bool(game._v51_world_layer_requested()):
		_fail(5112, "v1.38 world layer requested while Home is active")
		return

	# The gameplay state still owns run start. The router must observe it and flip
	# the shell out of menu mode without the run knowing anything about menu code.
	game.start_run()
	game._v51_sync_navigation(false)
	game._v51_sync_shell()
	if String(game.v51_navigation.current_screen) != "run":
		_fail(5113, "v1.38 run state did not synchronize into router")
		return
	if not bool(game._v51_world_layer_requested()):
		_fail(5114, "v1.38 run did not request future world layer")
		return
	if bool(game.v51_menu_shell.menu_visible):
		_fail(5115, "v1.38 menu shell remained visible in run mode")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	for marker in ["main_v51.gd", "main_v50.gd", "menu_shell.gd", "MenuShell"]:
		if not scene_text.contains(marker):
			_fail(5116, "v1.38 scene foundation marker missing: %s" % marker)
			return
	var router_text := FileAccess.get_file_as_string("res://scripts/screen_router.gd")
	for marker in ["SCREEN_HOME", "SCREEN_RUN", "MENU_SCREENS", "WORLD_SCREENS"]:
		if not router_text.contains(marker):
			_fail(5117, "v1.38 router marker missing: %s" % marker)
			return

	print("ONE MORE FLOOR v1.38 3D menu foundation smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
