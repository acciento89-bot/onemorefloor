extends SceneTree

func _init() -> void:
	call_deferred("_run_smoke")

func _run_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		push_error("Smoke test: main scene did not load")
		quit(1)
		return

	var game = packed.instantiate()
	root.add_child(game)

	game.meta.coins = 100000
	game.buy_meta("hero")
	game.buy_meta("forge")
	game.buy_meta("vitality")
	game.buy_meta("precision")
	game.buy_meta("fortune")

	game.start_run()
	if game.state != game.State.RUNNING:
		push_error("Smoke test: run did not start")
		quit(2)
		return

	game.roll_upgrade_options()
	if game.upgrade_options.size() != 3:
		push_error("Smoke test: upgrade roll did not return three choices")
		quit(3)
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
		push_error("Smoke test: Warden did not spawn on floor 5")
		quit(4)
		return
	game.update_enemies(0.016)

	game.run.run_coins = 50
	game.cash_out()
	if game.state != game.State.HOME:
		push_error("Smoke test: cash out did not return home")
		quit(5)
		return

	print("ONE MORE FLOOR gameplay smoke test passed")
	quit(0)
