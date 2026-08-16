extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run() -> void:
	var RoomSystem = load("res://scripts/room_system.gd")
	var rooms = RoomSystem.new()
	if rooms.area_for_floor(51) != "VOID CITADEL":
		_fail(2801, "v1.15: Floor 51 is not Void Citadel")
		return
	if rooms.area_for_floor(100) != "ECLIPSE SANCTUM":
		_fail(2802, "v1.15: Floor 100 is not Eclipse Sanctum")
		return
	if rooms.area_for_floor(150) != "BLOODSTAR KEEP":
		_fail(2803, "v1.15: Floor 150 is not Bloodstar Keep")
		return
	if rooms.area_for_floor(200) != "CELESTIAL GRAVE":
		_fail(2804, "v1.15: Floor 200 is not Celestial Grave")
		return

	if not rooms.enemy_pool("VOID CITADEL", 60).has("soul_cannon"):
		_fail(2805, "v1.15: Void Citadel roster is missing Soul Cannon")
		return
	if not rooms.enemy_pool("ECLIPSE SANCTUM", 120).has("eclipse_oracle"):
		_fail(2806, "v1.15: Eclipse roster is missing Oracle")
		return
	if not rooms.enemy_pool("BLOODSTAR KEEP", 170).has("chain_titan"):
		_fail(2807, "v1.15: Bloodstar roster is missing Chain Titan")
		return
	if not rooms.enemy_pool("CELESTIAL GRAVE", 220).has("star_devourer"):
		_fail(2808, "v1.15: Celestial roster is missing Star Devourer")
		return

	var EnemyFactory = load("res://scripts/enemy_factory.gd")
	var rng := RandomNumberGenerator.new()
	rng.seed = 2815
	for kind in ["void_lancer", "eclipse_oracle", "blood_seraph", "cosmic_eye"]:
		var enemy: Dictionary = EnemyFactory.make_enemy(kind, 220, rng, Vector2(360, 700))
		if String(enemy.get("type", "")) != kind or float(enemy.get("max_hp", 0.0)) <= 0.0:
			_fail(2809, "v1.15: endgame enemy factory failed for %s" % kind)
			return
	if String(EnemyFactory.make_enemy("world_eater", 200, rng, Vector2(360, 700)).get("boss_variant", "")) != "world_eater":
		_fail(2810, "v1.15: World Eater boss factory is missing")
		return

	var LootSystem = load("res://scripts/loot_system.gd")
	var loot = LootSystem.new()
	if LootSystem.RARITIES.size() < 7 or String(LootSystem.RARITIES[5]) != "MYTHIC" or String(LootSystem.RARITIES[6]) != "ASCENDANT":
		_fail(2811, "v1.15: Mythic/Ascendant loot tiers are missing")
		return
	var ascendant: Dictionary = loot._make_item("weapon", 6, 200, rng)
	if String(ascendant.get("rarity", "")) != "ASCENDANT" or int(ascendant.get("level", 0)) != 200:
		_fail(2812, "v1.15: Ascendant Floor 200 item generation failed")
		return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(2813, "v1.15: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	if not game.has_method("_v28_boss_kind_for_area") or not game.has_method("_v28_fire_enemy_ability"):
		_fail(2814, "v1.15: endgame controller is not active")
		return

	game.tutorial_active = false
	game.meta.best_floor = 100
	game.meta.checkpoint_floor = 100
	game.start_run()
	if int(game.run.floor_no) != 100 or String(game.current_room.get("area", "")) != "ECLIPSE SANCTUM":
		_fail(2815, "v1.15: Floor 100 checkpoint did not enter Eclipse Sanctum")
		return
	var found_regent := false
	for e in game.enemies:
		if String(e.get("boss_variant", "")) == "eclipse_regent":
			found_regent = true
			if not bool(e.get("milestone", false)):
				_fail(2816, "v1.15: Floor 100 Regent is not marked as a milestone boss")
				return
	if not found_regent:
		_fail(2817, "v1.15: Floor 100 did not spawn Eclipse Regent")
		return

	game.run.floor_no = 200
	game.spawn_floor()
	var found_world_eater := false
	for e in game.enemies:
		if String(e.get("boss_variant", "")) == "world_eater":
			found_world_eater = true
			break
	if not found_world_eater:
		_fail(2818, "v1.15: Floor 200 did not spawn World Eater")
		return

	game.current_room = {"area":"CELESTIAL GRAVE", "type":"COMBAT", "hazard":"comet_storm"}
	game.hazard_timer = 0.0
	game.enemy_shots.clear()
	game.update_room_hazard(0.1)
	if game.enemy_shots.size() < 8:
		_fail(2819, "v1.15: Celestial Grave hazard generated no meaningful pressure")
		return

	print("ONE MORE FLOOR v1.15 endgame realms smoke test passed")
	quit(0)
