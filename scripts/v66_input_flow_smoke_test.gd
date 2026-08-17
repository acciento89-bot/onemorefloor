extends SceneTree

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

	# Regression 1: the tutorial's final instruction says to choose an upgrade.
	# The actual upgrade card must therefore be clickable while tutorial_step=4.
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
		_fail("tutorial upgrade tap did not advance to the decision screen")
		return
	if bool(game.tutorial_active) or not bool(game.settings.tutorial_done):
		_fail("tutorial upgrade tap did not complete/persist onboarding")
		return

	# Regression 2: dying during tutorial step 3 used to leave tutorial_active on
	# GAME_OVER, causing _pointer_tutorial() to swallow RETRY/HOME forever.
	game.settings.reset_tutorial()
	game.tutorial_active = true
	game.tutorial_step = 3
	game.start_run()
	game.die()
	if game.state != game.State.GAME_OVER:
		_fail("tutorial death did not enter GAME_OVER")
		return
	if bool(game.tutorial_active) or not bool(game.v66_tutorial_retry_pending):
		_fail("tutorial death did not release modal capture for GAME_OVER")
		return
	game.pointer(game.RETRY.get_center(), true, 62)
	if game.state != game.State.RUNNING or not bool(game.tutorial_active) or int(game.tutorial_step) != 2:
		_fail("RETRY after tutorial death did not restart the tutorial run")
		return

	# HOME must also be reachable after a tutorial death and restart onboarding at
	# the first visible tutorial card rather than trapping the terminal screen.
	game.tutorial_step = 3
	game.die()
	game.pointer(game.HOME_BTN.get_center(), true, 63)
	if game.state != game.State.HOME or not bool(game.tutorial_active) or int(game.tutorial_step) != 0:
		_fail("HOME after tutorial death did not return to a usable tutorial Home")
		return

	# Regression 3: normal GAME_OVER controls stay reachable after onboarding.
	game._complete_tutorial()
	game.start_run()
	game.die()
	game.pointer(game.RETRY.get_center(), true, 64)
	if game.state != game.State.RUNNING:
		_fail("normal GAME_OVER RETRY is not clickable")
		return

	# Regression 4: v1.52's 3D NOVA query must not bypass the inherited player
	# animation/audio/VFX hooks. The generic gameplay smoke previously caught this
	# as exit code 32 (NOVA animation state missing).
	game.tutorial_active = false
	game.run.skill_cd = 0.0
	game.use_skill()
	if String(game.player_anim_state) != "nova" or float(game.player_anim_timer) <= 0.0:
		_fail("3D NOVA did not restore the inherited NOVA animation state")
		return
	if float(game.v47_player_skill_stamp) < float(game.elapsed) - 0.1:
		_fail("3D NOVA did not update the production skill animation stamp")
		return
	if int(game.v65_nova_queries) <= 0:
		_fail("NOVA did not use the v1.52 3D volume authority")
		return

	var snap: Dictionary = game.call("_v66_input_flow_snapshot")
	if int(snap.get("tutorial_deaths", 0)) < 2:
		_fail("tutorial death recovery telemetry counter is wrong")
		return
	if int(snap.get("tutorial_upgrade_completions", 0)) < 1:
		_fail("tutorial upgrade completion counter is wrong")
		return
	if int(snap.get("terminal_input_recoveries", 0)) < 3:
		_fail("terminal input recovery counter is wrong")
		return

	print("v1.52.1 tutorial/game-over input-flow smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.52.1 input-flow smoke test: %s" % message)
	quit(1)
