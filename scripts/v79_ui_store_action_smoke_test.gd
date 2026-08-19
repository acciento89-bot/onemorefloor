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

	if not game.has_method("_v79_ui_store_ready") or not game.has_method("_v79_ui_snapshot"):
		_fail("r2.1 UI methods missing")
		return
	if not bool(game.call("_v79_ui_store_ready")):
		_fail("r2.1 Store layer did not become ready")
		return
	var snapshot: Dictionary = game.call("_v79_ui_snapshot")
	if String(snapshot.get("version", "")) != "1.62.0-ui-foundation-r2.1":
		_fail("r2.1 version marker missing")
		return
	if String(snapshot.get("active_store_action_path", "")) != "_v50_store_card":
		_fail("r2.1 active Store path marker missing")
		return
	if not bool(snapshot.get("store_action_chip_live", false)) or not bool(snapshot.get("vault_r2_preserved", false)):
		_fail("r2.1 Store/Vault contract missing")
		return
	if String(snapshot.get("r2_fallback", "")) != "1.62.0-ui-foundation-r2":
		_fail("r2 fallback marker missing")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	for marker in ["main_v79.gd", "main_v78.gd", "main_v77.gd", "main_v76.gd", "main_v75.gd"]:
		if not scene_text.contains(marker):
			_fail("r2.1 scene marker missing: %s" % marker)
			return
	var source := FileAccess.get_file_as_string("res://scripts/main_v79.gd")
	for marker in [
		"func _v50_store_card",
		"_v79_store_action_chip",
		"action_rect",
		"UNAVAILABLE",
		"monetization.PRODUCT_REMOVE_ADS",
	]:
		if not source.contains(marker):
			_fail("r2.1 active Store source contract missing: %s" % marker)
			return

	# Exercise Store and Vault through the existing router so the draw path is live.
	game.tutorial_active = false
	game.settings_open = false
	game.release_paused = false
	if not bool(game.call("_v51_route_to", "store", false)):
		_fail("Store route failed under r2.1")
		return
	for _i in range(4):
		await process_frame
	if not bool(game.call("_v51_route_to", "vault", false)):
		_fail("Vault route failed under r2.1")
		return
	for _i in range(4):
		await process_frame

	print("v1.62 UI foundation r2.1 smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V79_UI_FAIL:%s" % message)
	quit(1)
