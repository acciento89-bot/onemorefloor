extends SceneTree

func _init() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(3901, "v1.26 build20: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame

	if not game.has_method("_v39_restore_home_navigation_after_cashout") or not game.has_method("_v39_home_navigation_ready"):
		_fail(3902, "v1.26 build20: cash-out navigation hotfix missing")
		return

	# Match a real post-run session: onboarding is not intercepting Home input.
	game.tutorial_active = false
	game.state = game.State.HOME
	game.settings_open = false
	game.home_overlay = ""
	var home_state = game.State.HOME

	# Reproduce the regression: main_v25 leaves summary_open=true after cash-out,
	# while modern Home no longer renders that summary. The first tap must both
	# clear the stale modal and open the requested destination.
	game.summary_open = true
	var hero_pos: Vector2 = game.HERO_TAB.get_center()
	game.pointer(hero_pos, true, 39001)
	game.pointer(hero_pos, false, 39001)
	if game.summary_open:
		_fail(3903, "v1.26 build20: invisible cash-out summary survived Home tap")
		return
	if game.state != game.State.HERO:
		_fail(3904, "v1.26 build20: HERO remained blocked after cash-out")
		return

	# Missions and Tower Pass use Home overlays instead of State transitions.
	game.state = home_state
	game.home_overlay = ""
	game.summary_open = true
	var missions_pos: Vector2 = game.MISSIONS_BTN.get_center()
	game.pointer(missions_pos, true, 39002)
	game.pointer(missions_pos, false, 39002)
	if game.home_overlay != "missions":
		_fail(3905, "v1.26 build20: MISSIONS remained blocked after cash-out")
		return

	game.state = home_state
	game.home_overlay = ""
	game.summary_open = true
	var pass_pos: Vector2 = game.PASS_BTN.get_center()
	game.pointer(pass_pos, true, 39003)
	game.pointer(pass_pos, false, 39003)
	if game.home_overlay != "pass":
		_fail(3906, "v1.26 build20: TOWER PASS remained blocked after cash-out")
		return

	# Also verify the four progression tabs are all routed by the modern Home layer.
	var tabs: Array = [
		[game.HERO_TAB, game.State.HERO],
		[game.FORGE_TAB, game.State.FORGE],
		[game.TALENTS_TAB, game.State.TALENTS],
		[game.VAULT_TAB, game.State.VAULT],
	]
	for entry in tabs:
		game.state = home_state
		game.home_overlay = ""
		game.summary_open = true
		game.pointer((entry[0] as Rect2).get_center(), true, 39100 + tabs.find(entry))
		if game.state != entry[1] or game.summary_open:
			_fail(3907, "v1.26 build20: progression tab remained blocked after cash-out")
			return

	game.state = home_state
	game.home_overlay = ""
	game.summary_open = true
	game._v39_restore_home_navigation_after_cashout()
	if not game._v39_home_navigation_ready():
		_fail(3908, "v1.26 build20: Home interaction state was not fully restored")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v39.gd"):
		_fail(3909, "v1.26 build20: main_v39 is not active")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_text.contains("application/version=\"20\"") or not export_text.contains("version/code=20"):
		_fail(3910, "v1.26 build20: mobile build number 20 missing")
		return

	print("ONE MORE FLOOR v1.26 build20 cash-out navigation smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
