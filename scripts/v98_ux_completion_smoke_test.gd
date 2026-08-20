extends SceneTree

# v1.71 UX completion smoke: prove the visible route graph, production Store
# guard, safe run-abandon flow and same-session tutorial replay handoff.

const MainScene = preload("res://scenes/main.tscn")
const PAUSE_HOME := Rect2(170, 694, 380, 78)
const SET_TUTORIAL := Rect2(96, 650, 528, 64)
const ABANDON_CANCEL := Rect2(92, 700, 248, 68)
const ABANDON_CONFIRM := Rect2(380, 700, 248, 68)
const TUTORIAL_SKIP := Rect2(220, 908, 280, 44)

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	for _i in range(12):
		await process_frame

	if not bool(app.call("_v95_ux_completion_ready")):
		_fail("v1.71 readiness contract failed")
		return
	if not bool(app.call("_v88_release_surfaces_active")):
		_fail("smoke must run with production release surfaces forced")
		return
	if bool(app.call("_v50_store_requests_available")):
		_fail("production Store provider must remain fail-closed")
		return
	if bool(app.call("_v51_apply_route", "store")):
		_fail("production route graph still exposes Store")
		return
	if not bool(app.call("_v88_privacy_link_ready")):
		_fail("Privacy Policy surface is not ready")
		return

	# A fresh CI profile starts with the tutorial active. Complete it before the
	# route graph walk so modal input cannot mask navigation behavior.
	if bool(app.get("tutorial_active")):
		app.call("_complete_tutorial")
		await process_frame

	for screen in ["hero", "forge", "talents", "vault", "missions", "pass"]:
		if not bool(app.call("_v51_route_to", screen, false)):
			_fail("could not route to %s" % screen)
			return
		if String(app.call("_v51_screen_from_legacy")) != screen:
			_fail("legacy/router mismatch on %s" % screen)
			return
		if not bool(app.call("_v51_route_home", false)):
			_fail("could not return Home from %s" % screen)
			return
		if String(app.call("_v51_screen_from_legacy")) != "home":
			_fail("Home return failed from %s" % screen)
			return

	# Pause -> Return Home must no longer abandon immediately.
	app.call("start_run")
	for _i in range(4):
		await process_frame
	app.set("release_paused", true)
	app.call("pointer", PAUSE_HOME.get_center(), true, 901)
	if not bool(app.get("v95_abandon_confirm")):
		_fail("Return Home did not open abandon confirmation")
		return
	if String(app.call("_v51_screen_from_legacy")) != "run":
		_fail("run was abandoned before confirmation")
		return
	app.call("pointer", ABANDON_CANCEL.get_center(), true, 902)
	if bool(app.get("v95_abandon_confirm")) or String(app.call("_v51_screen_from_legacy")) != "run":
		_fail("abandon cancel did not preserve the run")
		return
	app.call("pointer", PAUSE_HOME.get_center(), true, 903)
	app.call("pointer", ABANDON_CONFIRM.get_center(), true, 904)
	if String(app.call("_v51_screen_from_legacy")) != "home":
		_fail("confirmed abandon did not return Home")
		return

	# Replay Tutorial from a live run must start on the next Home visit in the
	# same session, not require an app restart.
	app.call("start_run")
	for _i in range(4):
		await process_frame
	app.set("release_paused", true)
	app.set("settings_open", true)
	app.set("settings_return_to_pause", true)
	app.call("pointer", SET_TUTORIAL.get_center(), true, 905)
	if not bool(app.get("v95_tutorial_pending_home")):
		_fail("tutorial replay intent was not queued from a live run")
		return
	app.call("_close_settings")
	app.set("release_paused", false)
	app.call("_v51_route_home", false)
	for _i in range(3):
		await process_frame
	if not bool(app.get("tutorial_active")) or int(app.get("tutorial_step")) != 0:
		_fail("queued tutorial did not start on Home")
		return

	# The pre-run tutorial can be skipped deliberately; guided combat itself is
	# still non-skippable once it starts.
	app.call("pointer", TUTORIAL_SKIP.get_center(), true, 906)
	if bool(app.get("tutorial_active")):
		_fail("pre-run tutorial skip did not complete")
		return
	var settings = app.get("settings")
	if settings == null or not bool(settings.tutorial_done):
		_fail("tutorial skip did not persist completion")
		return

	print("v1.71 UX completion smoke test passed")
	app.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V171_UX_COMPLETION_FAIL:%s" % message)
	quit(1)
