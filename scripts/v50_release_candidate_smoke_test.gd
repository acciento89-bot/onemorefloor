extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(5001, "v1.37 main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	for method in ["_v50_release_candidate_ready", "_v50_touch_geometry_safe", "_v50_checkpoint_save", "_v50_store_requests_available", "_v50_pass_lock_badge_rect"]:
		if not game.has_method(method):
			_fail(5002, "v1.37 release-candidate method missing: %s" % method)
			return
	if not bool(game._v50_release_candidate_ready()):
		_fail(5003, "v1.37 release-candidate runtime not ready")
		return
	if not bool(game._v50_touch_geometry_safe()):
		_fail(5004, "v1.37 critical touch geometry leaves 720x1280 safe canvas")
		return
	if Engine.max_fps != 60:
		_fail(5005, "v1.37 mobile frame cap is not 60 fps")
		return

	if not bool(game._v50_checkpoint_save("smoke_test")):
		_fail(5006, "v1.37 lifecycle checkpoint save failed")
		return
	if not FileAccess.file_exists("user://save.cfg"):
		_fail(5007, "v1.37 checkpoint did not persist save.cfg")
		return
	if game.release_guard == null or not bool(game.release_guard.backup_exists()):
		_fail(5008, "v1.37 last-known-good save backup missing")
		return

	var renderer := FileAccess.get_file_as_string("res://scripts/main_v50.gd")
	for marker in ["1.26.0-rc3", "V50_BUILD := \"24\"", "PURCHASES CURRENTLY UNAVAILABLE", "NOTIFICATION_APPLICATION_PAUSED", "V50_MAX_FPS := 60", "V50_COMBAT_VISUAL_SCALE := 1.12"]:
		if not renderer.contains(marker):
			_fail(5009, "v1.37 renderer marker missing: %s" % marker)
			return

	# Regression for the device screenshot: the locked badge must stay in the
	# header band and never cover premium coin/shard values around y=49..70.
	var pass_card := Rect2(112, 374, 556, 98)
	var lock_badge: Rect2 = game._v50_pass_lock_badge_rect(pass_card)
	if lock_badge.position.y < pass_card.position.y or lock_badge.end.y > pass_card.position.y + 32.0:
		_fail(5010, "v1.37 Tower Pass lock badge overlaps premium reward content")
		return
	if lock_badge.end.x > pass_card.end.x or lock_badge.size.x < 72.0:
		_fail(5011, "v1.37 Tower Pass lock badge leaves card bounds")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v50.gd") or not scene_text.contains("main_v49.gd"):
		_fail(5012, "v1.37 scene wiring or v1.36 compatibility baseline missing")
		return

	var backdrop := FileAccess.get_file_as_string("res://scripts/fullscreen_backdrop.gd")
	if not backdrop.contains("0.0667"):
		_fail(5013, "v1.37 fullscreen backdrop redraw throttle missing")
		return
	var pack_fx := FileAccess.get_file_as_string("res://scripts/visual_pack_fx_overlay.gd")
	if not pack_fx.contains("REDRAW_INTERVAL := 1.0 / 30.0"):
		_fail(5014, "v1.37 graphics-pack FX redraw throttle missing")
		return

	var preset := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not preset.contains("application/short_version=\"1.26.0\"") or not preset.contains("application/version=\"20\""):
		_fail(5015, "v1.37 checked-in export baseline changed unexpectedly")
		return
	var workflow := FileAccess.get_file_as_string("res://.github/workflows/ios-testflight.yml")
	if not workflow.contains("Apply TestFlight build override") or not workflow.contains("Requested build"):
		_fail(5016, "v1.37 TestFlight build override / metadata guard is not armed")
		return

	print("ONE MORE FLOOR v1.37 rc3 Build 24 smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
