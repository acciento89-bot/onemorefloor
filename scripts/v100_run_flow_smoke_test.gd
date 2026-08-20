extends SceneTree

# ONE MORE FLOOR v1.73 — run-flow presentation contract.
# Input rectangles/progression authority must remain inherited while the visible
# Decision, Game Over and running transition surfaces are replaced.

const STATE_RUNNING := 5
const STATE_DECISION := 7
const STATE_GAME_OVER := 8

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene failed to load")
		return
	var app = packed.instantiate()
	root.add_child(app)
	for _i in range(12):
		await process_frame

	var script = app.get_script()
	if script == null or String(script.resource_path) != "res://scripts/main_v97.gd":
		_fail("main_v97 is not the active production entrypoint")
		return
	if not app.has_method("_v97_run_flow_ready") or not bool(app.call("_v97_run_flow_ready")):
		_fail("v1.73 run-flow readiness failed")
		return
	if not app.has_method("_v96_polish_ready") or not bool(app.call("_v96_polish_ready")):
		_fail("v1.72 feedback/performance lock regressed")
		return

	app.set("tutorial_active", false)
	app.call("start_run")
	for _i in range(5):
		await process_frame

	app.set("state", STATE_DECISION)
	if String(app.call("_v51_screen_from_legacy")) != "decision":
		_fail("Decision route mapping changed")
		return
	app.set("state", STATE_GAME_OVER)
	if String(app.call("_v51_screen_from_legacy")) != "game_over":
		_fail("Game Over route mapping changed")
		return
	app.set("state", STATE_RUNNING)
	if String(app.call("_v51_screen_from_legacy")) != "run":
		_fail("running route mapping changed")
		return

	# Boss-intro priority must be deterministic and cover every accepted boss path.
	var legacy := {
		"room_transition": 0.72,
		"floor_banner": 1.0,
		"boss_intro": 0.0,
		"keeper_intro": 0.0,
		"hollow_intro": 2.0,
		"miniboss_intro": 0.0,
		"null_intro": 0.0,
		"endgame_boss_intro": 0.0,
		"realm_flash": 0.0,
	}
	if String(app.call("_v173_intro_key_from", legacy)) != "hollow_king":
		_fail("Hollow King intro priority invalid")
		return
	legacy["hollow_intro"] = 0.0
	legacy["keeper_intro"] = 1.6
	if String(app.call("_v173_intro_key_from", legacy)) != "crypt_keeper":
		_fail("Crypt Keeper intro priority invalid")
		return
	legacy["keeper_intro"] = 0.0
	legacy["endgame_boss_intro"] = 2.0
	if String(app.call("_v173_intro_key_from", legacy)) != "endgame_boss":
		_fail("endgame boss intro priority invalid")
		return

	var snapshot: Dictionary = app.call("_v97_run_flow_snapshot")
	if not bool(snapshot.get("ready", false)) or bool(snapshot.get("input_override", true)):
		_fail("v1.73 snapshot contract invalid")
		return
	if String(snapshot.get("version", "")) != "1.73-run-flow-presentation-r1":
		_fail("v1.73 version marker invalid")
		return

	print("V173_RUN_FLOW_SNAPSHOT:%s" % JSON.stringify(snapshot))
	print("v1.73 run flow presentation smoke test passed")
	app.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V173_RUN_FLOW_FAIL:%s" % message)
	quit(1)
