extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(2501, "v1.13: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame

	if not game.has_method("_v25_install_msdf_fonts") or not game.has_method("_v25_apply_elite_affixes"):
		_fail(2502, "v1.13: gameplay depth layer is not active")
		return
	if not game.font is SystemFont or not bool(game.font.multichannel_signed_distance_field):
		_fail(2503, "v1.13: MSDF body font is not active")
		return
	if not game.v16_title_font is SystemFont or not bool(game.v16_title_font.multichannel_signed_distance_field):
		_fail(2504, "v1.13: MSDF title font is not active")
		return

	game.tutorial_active = false
	game.meta.best_floor = 60
	game.meta.checkpoint_floor = 50
	game.start_run()
	if int(game.run.floor_no) != 50:
		_fail(2505, "v1.13: Floor 50 checkpoint did not resume")
		return
	if String(game.run_modifier) == "NONE":
		_fail(2506, "v1.13: ascension run modifier was not rolled")
		return

	var EnemyFactory = load("res://scripts/enemy_factory.gd")
	var elite: Dictionary = EnemyFactory.make_enemy("goblin", 16, game.rng, Vector2(360, 700))
	elite["elite"] = true
	game.enemies.clear()
	game.enemies.append(elite)
	game.run.floor_no = 16
	game._v25_apply_elite_affixes()
	if String(game.enemies[0].get("affix", "")) == "":
		_fail(2507, "v1.13: elite affix was not assigned")
		return

	game.combo_count = 0
	game.combo_timer = 0.0
	game._v25_register_kill({"type":"goblin", "elite":false})
	game._v25_register_kill({"type":"goblin", "elite":false})
	if int(game.combo_count) != 2 or int(game.combo_best) < 2:
		_fail(2508, "v1.13: kill combo tracking failed")
		return

	game.run.floor_no = 12
	game.current_room = {"type":"TREASURE", "area":"CRYPT"}
	game.treasure_awarded_floor = -1
	var shards_before := int(game.loot.shards)
	var coins_before := int(game.run.run_coins)
	game._v25_award_treasure_room()
	if int(game.loot.shards) <= shards_before or int(game.run.run_coins) <= coins_before:
		_fail(2509, "v1.13: treasure room did not grant shards and coins")
		return

	print("ONE MORE FLOOR v1.13 gameplay depth smoke test passed")
	quit(0)
