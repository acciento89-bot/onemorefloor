extends SceneTree

const SCENARIO_ENV := "OMF_V66_SCENARIO"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame

	if not game.has_method("_v66_input_flow_snapshot"):
		_fail("main scene is not running the v1.52.1 input-flow hotfix")
		return
	if not bool(game.call("_v65_3d_combat_core_ready")):
		_fail("v1.52 3D combat core is not ready under the input hotfix")
		return

	var scenario := OS.get_environment(SCENARIO_ENV).strip_edges().to_lower()
	if scenario.is_empty():
		scenario = "all"
	print("V66_SCENARIO_BEGIN: %s" % scenario)

	var error := ""
	match scenario:
		"tutorial_upgrade":
			error = _scenario_tutorial_upgrade(game)
		"tutorial_death":
			error = _scenario_tutorial_death(game)
		"game_over_retry":
			error = _scenario_game_over_retry(game)
		"nova":
			error = _scenario_nova(game)
		"all":
			error = _scenario_tutorial_upgrade(game)
			if error.is_empty():
				error = _scenario_tutorial_death(game)
			if error.is_empty():
				error = _scenario_game_over_retry(game)
			if error.is_empty():
				error = _scenario_nova(game)
			if error.is_empty():
				error = _validate_aggregate_telemetry(game)
		_:
			error = "unknown scenario '%s'" % scenario

	if not error.is_empty():
		_fail("[%s] %s" % [scenario, error])
		return

	print("V66_SCENARIO_PASS: %s" % scenario)
	if scenario == "all":
		print("v1.52.1 tutorial/game-over input-flow smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _scenario_tutorial_upgrade(game) -> String:
	# The final tutorial instruction says to choose an upgrade. The actual card
	# must be clickable while tutorial_step=4 and must finish onboarding.
	game.settings.reset_tutorial()
	game.tutorial_active = true
	game.tutorial_step = 4
	game.room_event_active = false
	game.run.reset(game.meta)
	game.state = game.State.UPGRADE
	game.upgrade_options = [
		{"name":"POWER SURGE", "desc":"test", "kind":"power", "color":game.C_GOLD, "tier":"COMMON", "strength":1.0, "tier_color":game.C_GOLD},
		{"name":"IRON HEART", "desc":"test", "kind":"vitality", "color":game.C_GREEN, "tier":"COMMON", "strength":1.0, "tier_color":game.C_GREEN},
		{"name":"NOVA CORE", "desc":"test", "kind":"nova", "color":game.C_BLUE, "tier":"COMMON", "strength":1.0, "tier_color":game.C_BLUE},
	]
	game.pointer(game.upgrade_rect(0).get_center(), true, 61)
	if game.state != game.State.DECISION:
		return "tutorial upgrade tap did not advance to the decision screen"
	if bool(game.tutorial_active) or not bool(game.settings.tutorial_done):
		return "tutorial upgrade tap did not complete/persist onboarding"
	var snap: Dictionary = game.call("_v66_input_flow_snapshot")
	if int(snap.get("tutorial_upgrade_completions", 0)) < 1:
		return "tutorial upgrade completion telemetry counter is wrong"
	return ""

func _scenario_tutorial_death(game) -> String:
	# A tutorial death must release modal capture before GAME_OVER, then both
	# terminal actions must be reachable and leave the input stack clean.
	game.settings.reset_tutorial()
	game.tutorial_active = true
	game.tutorial_step = 3
	game.start_run()
	game.die()
	if game.state != game.State.GAME_OVER:
		return "tutorial death did not enter GAME_OVER"
	if bool(game.tutorial_active) or not bool(game.v66_tutorial_retry_pending):
		return "tutorial death did not release modal capture for GAME_OVER"

	game.pointer(game.RETRY.get_center(), true, 62)
	if game.state != game.State.RUNNING or not bool(game.tutorial_active) or int(game.tutorial_step) != 2:
		return "RETRY after tutorial death did not restart the tutorial run"
	if bool(game.release_paused) or bool(game.settings_open) or bool(game.summary_open) or bool(game.joy_active):
		return "RETRY after tutorial death left a modal/input blocker active"

	game.tutorial_step = 3
	game.die()
	if game.state != game.State.GAME_OVER:
		return "second tutorial death did not enter GAME_OVER"
	game.pointer(game.HOME_BTN.get_center(), true, 63)
	if game.state != game.State.HOME or not bool(game.tutorial_active) or int(game.tutorial_step) != 0:
		return "HOME after tutorial death did not return to a usable tutorial Home"
	if bool(game.release_paused) or bool(game.settings_open) or bool(game.summary_open) or bool(game.joy_active):
		return "HOME after tutorial death left a modal/input blocker active"

	var snap: Dictionary = game.call("_v66_input_flow_snapshot")
	if int(snap.get("tutorial_deaths", 0)) < 2:
		return "tutorial death recovery telemetry counter is wrong"
	if int(snap.get("terminal_input_recoveries", 0)) < 3:
		return "terminal input recovery counter is wrong after tutorial death routes"
	return ""

func _scenario_game_over_retry(game) -> String:
	# Normal post-onboarding GAME_OVER must remain directly clickable too.
	game._complete_tutorial()
	game.tutorial_active = false
	game.v66_tutorial_retry_pending = false
	game.start_run()
	game.die()
	if game.state != game.State.GAME_OVER:
		return "normal death did not enter GAME_OVER"
	game.pointer(game.RETRY.get_center(), true, 64)
	if game.state != game.State.RUNNING:
		return "normal GAME_OVER RETRY is not clickable"
	if bool(game.release_paused) or bool(game.settings_open) or bool(game.summary_open) or bool(game.joy_active):
		return "normal GAME_OVER RETRY left a modal/input blocker active"
	return ""

func _scenario_nova(game) -> String:
	# v1.52's 3D NOVA membership query must retain inherited presentation hooks.
	game._complete_tutorial()
	game.tutorial_active = false
	if game.state != game.State.RUNNING:
		game.start_run()
	game.run.skill_cd = 0.0
	game.use_skill()
	if String(game.player_anim_state) != "nova" or float(game.player_anim_timer) <= 0.0:
		return "3D NOVA did not restore the inherited NOVA animation state"
	if float(game.v47_player_skill_stamp) < float(game.elapsed) - 0.1:
		return "3D NOVA did not update the production skill animation stamp"
	if int(game.v65_nova_queries) <= 0:
		return "NOVA did not use the v1.52 3D volume authority"
	return ""

func _validate_aggregate_telemetry(game) -> String:
	var snap: Dictionary = game.call("_v66_input_flow_snapshot")
	if int(snap.get("tutorial_deaths", 0)) < 2:
		return "aggregate tutorial death recovery telemetry counter is wrong"
	if int(snap.get("tutorial_upgrade_completions", 0)) < 1:
		return "aggregate tutorial upgrade completion counter is wrong"
	if int(snap.get("terminal_input_recoveries", 0)) < 3:
		return "aggregate terminal input recovery counter is wrong"
	return ""

func _fail(message: String) -> void:
	push_error("V66_SMOKE_FAIL: %s" % message)
	quit(1)
