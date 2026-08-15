extends SceneTree

func _init() -> void:
	call_deferred("_run_smoke")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(1, "Smoke test: main scene did not load")
		return

	var game = packed.instantiate()
	root.add_child(game)

	game.meta.coins = 100000
	game.buy_meta("hero")
	game.buy_meta("forge")
	game.buy_meta("vitality")
	game.buy_meta("precision")
	game.buy_meta("fortune")

	var forced_item: Dictionary = game.loot.roll_drop("warden", 5, game.rng)
	if forced_item.is_empty() or game.loot.inventory.is_empty():
		_fail(2, "Smoke test: guaranteed Warden loot did not drop")
		return
	if not game.loot.equip_index(0):
		_fail(3, "Smoke test: loot could not be equipped")
		return
	var gear_bonus: Dictionary = game.loot.equipped_bonuses()
	if float(gear_bonus["damage_pct"]) <= 0.0 and float(gear_bonus["hp"]) <= 0.0 and float(gear_bonus["crit_pct"]) <= 0.0 and float(gear_bonus["coin_pct"]) <= 0.0:
		_fail(4, "Smoke test: equipped loot produced no bonus")
		return

	game.missions.record("kills", 25)
	var coins_before_mission := int(game.meta.coins)
	game.claim_mission(0)
	if int(game.meta.coins) <= coins_before_mission:
		_fail(5, "Smoke test: completed mission did not grant coins")
		return

	game.tower_pass.add_xp(400)
	var pass_level := game.tower_pass.level()
	if pass_level < 1:
		_fail(6, "Smoke test: Tower Pass did not level")
		return
	var coins_before_pass := int(game.meta.coins)
	game.claim_pass_reward()
	if int(game.meta.coins) <= coins_before_pass:
		_fail(7, "Smoke test: Tower Pass reward did not grant coins")
		return

	game.start_run()
	if game.state != game.State.RUNNING:
		_fail(8, "Smoke test: run did not start")
		return

	game.roll_upgrade_options()
	if game.upgrade_options.size() != 3:
		_fail(9, "Smoke test: upgrade roll did not return three choices")
		return
	game.apply_upgrade(0)
	game.continue_run()
	game.use_skill()

	game.run.floor_no = 5
	game.spawn_floor()
	var found_warden := false
	for e in game.enemies:
		if String(e["type"]) == "warden":
			found_warden = true
			e["hp"] = float(e["max_hp"]) * 0.45
			break
	if not found_warden:
		_fail(10, "Smoke test: Warden did not spawn on floor 5")
		return
	game.update_enemies(0.016)

	game.run.run_coins = 50
	game.cash_out()
	if game.state != game.State.HOME:
		_fail(11, "Smoke test: cash out did not return home")
		return

	print("ONE MORE FLOOR gameplay smoke test passed")
	quit(0)
