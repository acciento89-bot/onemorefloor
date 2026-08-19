extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if OS.get_environment("OMF_FORCE_RELEASE_SURFACES") != "1":
		_fail("release-surface smoke must run with OMF_FORCE_RELEASE_SURFACES=1")
		return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	for _i in range(12):
		await process_frame

	if not game.has_method("_v88_release_surface_ready"):
		_fail("active main scene is not wired to v1.66 release hardening")
		return
	if not bool(game.call("_v88_release_surfaces_active")):
		_fail("production release surfaces did not activate")
		return
	if not bool(game.call("_v88_release_surface_ready")):
		_fail("production release surface contract is not ready")
		return
	if game.monetization == null or not bool(game.monetization.premium_pass_unlocked()):
		_fail("Tower Pass bonus track was not unlocked for the no-IAP release")
		return
	if bool(game.call("_v50_store_requests_available")):
		_fail("debug purchase simulator leaked into forced production surfaces")
		return

	game.state = game.State.HOME
	game.home_overlay = ""
	if bool(game.call("_v51_apply_route", "store")):
		_fail("production routing still allows the unfinished Store")
		return
	if String(game.home_overlay) == "store":
		_fail("production routing opened the unfinished Store")
		return

	# The old footer Store hitbox must be inert even if a device sends a touch at
	# its historical coordinates. Settings and all other navigation stay inherited.
	game.pointer(Vector2(515.0, 1193.0), true, 1)
	await process_frame
	if String(game.home_overlay) == "store":
		_fail("historical Store footer hitbox still opens Store in production")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v88.gd"):
		_fail("main scene release-hardening wiring is missing")
		return

	print("v1.66 production release surface smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V166_RELEASE_SURFACE_FAIL:%s" % message)
	quit(1)
