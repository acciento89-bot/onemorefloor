extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(2701, "v1.14: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame

	if not game.has_method("_v27_scale_floor_enemies") or not game.has_method("_v27_ascension_tier"):
		_fail(2702, "v1.14: endless ascension runtime is not active")
		return
	if not game.meta.has_method("apply_death_setback"):
		_fail(2703, "v1.14: checkpoint setback API is missing")
		return

	# This smoke test intentionally manipulates persistent progression. Preserve the
	# state it inherited so later smoke tests do not accidentally start at a deep
	# checkpoint and test a different biome than they were written for.
	var original_best_floor := int(game.meta.best_floor)
	var original_checkpoint_floor := int(game.meta.checkpoint_floor)
	var original_coins := int(game.meta.coins)

	game.tutorial_active = false
	game.meta.best_floor = 100
	game.meta.checkpoint_floor = 100
	game.start_run()
	if int(game.run.floor_no) != 100:
		_fail(2704, "v1.14: deep checkpoint did not resume at Floor 100")
		return
	if int(game._v27_ascension_tier()) != 10:
		_fail(2705, "v1.14: Floor 100 should be Ascension tier 10")
		return
	if game.enemies.is_empty():
		_fail(2706, "v1.14: Floor 100 spawned no enemies")
		return
	for e in game.enemies:
		if not bool(e.get("v27_ascended", false)):
			_fail(2707, "v1.14: deep-floor enemy missed ascension scaling")
			return

	var shot_damage := 10.0
	game.enemy_shots.clear()
	game.enemy_shots.append({"pos":Vector2(100, 100), "vel":Vector2.ZERO, "damage":shot_damage, "life":2.0, "color":Color.WHITE})
	game.update_enemy_shots(0.0)
	if game.enemy_shots.is_empty() or float(game.enemy_shots[0].get("damage", 0.0)) <= shot_damage:
		_fail(2708, "v1.14: projectile damage did not scale with ascension")
		return

	game.meta.checkpoint_floor = 100
	var lost := int(game.meta.apply_death_setback(100))
	if lost != 7 or int(game.meta.checkpoint_floor) != 93:
		_fail(2709, "v1.14: Floor 100 death setback should drop checkpoint by 7 floors")
		return
	game.meta.checkpoint_floor = 52
	lost = int(game.meta.apply_death_setback(52))
	if lost != 2 or int(game.meta.checkpoint_floor) != 50:
		_fail(2710, "v1.14: setback must never push the deep checkpoint below Floor 50")
		return

	game.meta.checkpoint_floor = 200
	lost = int(game.meta.apply_death_setback(200))
	if lost != 15 or int(game.meta.checkpoint_floor) != 185:
		_fail(2711, "v1.14: Floor 200 death setback should be 15 floors")
		return

	game.meta.best_floor = original_best_floor
	game.meta.checkpoint_floor = original_checkpoint_floor
	game.meta.coins = original_coins
	game.meta.save_data()

	print("ONE MORE FLOOR v1.14 endless ascension smoke test passed")
	quit(0)
