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

	var art_paths := [
		"res://assets/art/wanderer.svg",
		"res://assets/art/goblin.svg",
		"res://assets/art/bat.svg",
		"res://assets/art/skeleton.svg",
		"res://assets/art/ghoul.svg",
		"res://assets/art/necromancer.svg",
		"res://assets/art/warden.svg",
		"res://assets/art/crypt_keeper.svg"
	]
	for path in art_paths:
		var texture = load(path)
		if texture == null or not texture is Texture2D:
			_fail(20, "Smoke test: production SVG asset failed to import: %s" % path)
			return
	var atlas := load("res://assets/art/combat_atlas.svg") as Texture2D
	if atlas == null or atlas.get_width() < 500 or atlas.get_height() < 800 or game.tex_combat_atlas == null:
		_fail(23, "Smoke test: v0.8 combat animation atlas failed to import")
		return

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

	game.loot.equipped = {"weapon":"", "armor":"", "relic":""}
	game.loot.shards = 0
	if not bool(game.loot.toggle_lock_index(0)):
		_fail(24, "Smoke test: item lock did not activate")
		return
	if int(game.loot.dismantle_index(0)) != 0:
		_fail(25, "Smoke test: locked item was dismantled")
		return
	game.loot.toggle_lock_index(0)
	var dismantled: int = int(game.loot.dismantle_index(0))
	if dismantled <= 0 or int(game.loot.shards) != dismantled:
		_fail(21, "Smoke test: dismantling did not award Soul Shards")
		return
	game.loot.shards = int(game.loot.craft_cost())
	var crafted: Dictionary = game.loot.craft_item("weapon", 12, game.rng)
	if crafted.is_empty() or int(crafted.get("rarity_index", 0)) < 2 or int(game.loot.shards) != 0:
		_fail(22, "Smoke test: Rare+ Soul Shard crafting failed")
		return

	game.loot.inventory = [
		{"id":"set-w","slot":"weapon","name":"Crypt Blade","rarity":"EPIC","rarity_index":3,"level":12,"damage_pct":0.12,"hp":0.0,"crit_pct":0.0,"coin_pct":0.0,"trait":"EXECUTIONER","set":"CRYPT","locked":false},
		{"id":"set-a","slot":"armor","name":"Crypt Plate","rarity":"EPIC","rarity_index":3,"level":12,"damage_pct":0.0,"hp":30.0,"crit_pct":0.0,"coin_pct":0.0,"trait":"BULWARK","set":"CRYPT","locked":false},
		{"id":"set-r","slot":"relic","name":"Crypt Eye","rarity":"EPIC","rarity_index":3,"level":12,"damage_pct":0.0,"hp":0.0,"crit_pct":0.03,"coin_pct":0.0,"trait":"VAMPIRIC","set":"CRYPT","locked":false}
	]
	game.loot.equipped = {"weapon":"", "armor":"", "relic":""}
	var weapon_filter: Array[int] = game.loot.matching_indices("weapon")
	if weapon_filter.size() != 1 or String(game.loot.inventory[weapon_filter[0]]["slot"]) != "weapon":
		_fail(26, "Smoke test: Vault slot filtering failed")
		return
	game.loot.sort_inventory("score")
	if game.loot.inventory.size() >= 2 and int(game.loot.item_score(game.loot.inventory[0])) < int(game.loot.item_score(game.loot.inventory[1])):
		_fail(27, "Smoke test: Vault score sorting failed")
		return
	for i in range(3):
		if not game.loot.equip_index(i):
			_fail(3, "Smoke test: set item could not be equipped")
			return
	var gear_bonus: Dictionary = game.loot.equipped_bonuses()
	if float(gear_bonus["damage_pct"]) <= 0.15 or float(gear_bonus["hp"]) < 55.0 or float(gear_bonus["lifesteal"]) < 0.05:
		_fail(4, "Smoke test: traits or three-piece Crypt set bonus missing")
		return
	var equipped_weapon: Dictionary = game.loot.equipped_item_for_slot("weapon")
	if equipped_weapon.is_empty() or int(game.loot.comparison_delta(equipped_weapon)) != 0:
		_fail(28, "Smoke test: selected-vs-equipped comparison failed")
		return

	var crypt_pool: Array[String] = game.room_system.enemy_pool("CRYPT", 13)
	if not ("ghoul" in crypt_pool) or not ("necromancer" in crypt_pool):
		_fail(5, "Smoke test: Crypt enemy pool missing new archetypes")
		return
	var enemy_factory = load("res://scripts/enemy_factory.gd")
	var ghoul: Dictionary = enemy_factory.make_enemy("ghoul", 13, game.rng, Vector2(360, 700))
	var necro: Dictionary = enemy_factory.make_enemy("necromancer", 13, game.rng, Vector2(360, 700))
	var keeper_factory: Dictionary = enemy_factory.make_enemy("crypt_keeper", 20, game.rng, Vector2(360, 700))
	if String(ghoul["type"]) != "ghoul" or String(necro["type"]) != "necromancer" or not necro.has("summon_cd"):
		_fail(6, "Smoke test: Crypt enemy factory output invalid")
		return
	if String(keeper_factory["type"]) != "warden" or String(keeper_factory.get("boss_variant", "")) != "crypt_keeper":
		_fail(7, "Smoke test: Crypt Keeper factory output invalid")
		return

	game.missions.record("kills", 25)
	var coins_before_mission: int = int(game.meta.coins)
	game.claim_mission(0)
	if int(game.meta.coins) <= coins_before_mission:
		_fail(8, "Smoke test: completed mission did not grant coins")
		return

	game.tower_pass.add_xp(400)
	var pass_level: int = int(game.tower_pass.level())
	if pass_level < 1:
		_fail(9, "Smoke test: Tower Pass did not level")
		return
	var coins_before_pass: int = int(game.meta.coins)
	game.claim_pass_reward()
	if int(game.meta.coins) <= coins_before_pass:
		_fail(10, "Smoke test: Tower Pass reward did not grant coins")
		return

	game.start_run()
	if game.state != game.State.RUNNING:
		_fail(11, "Smoke test: run did not start")
		return
	if float(game.run.lifesteal) < 0.05 or float(game.run.armor) < 0.04:
		_fail(12, "Smoke test: equipped traits/set bonuses were not applied to run")
		return

	var anim_enemy: Dictionary = enemy_factory.make_enemy("goblin", 2, game.rng, game.player_pos)
	anim_enemy["pos"] = game.player_pos + Vector2(60, 0)
	game.enemies.clear()
	game.enemies.append(anim_enemy)
	game.fire_auto_attack()
	if String(game.player_anim_state) != "attack":
		_fail(29, "Smoke test: player attack animation state did not trigger")
		return
	game.apply_damage_to_enemy(0, 1.0, false, game.enemies[0]["pos"])
	if float(game.enemies[0].get("anim_hit", 0.0)) <= 0.0:
		_fail(30, "Smoke test: enemy hit animation state did not trigger")
		return
	game.damage_player(1.0, game.player_pos + Vector2(-20, 0))
	if String(game.player_anim_state) != "hit":
		_fail(31, "Smoke test: player hit animation state did not trigger")
		return
	game.run.skill_cd = 0.0
	game.use_skill()
	if String(game.player_anim_state) != "nova":
		_fail(32, "Smoke test: NOVA animation state did not trigger")
		return
	game.enemies[0]["hp"] = 0.0
	game.remove_dead()
	var found_death_fx: bool = false
	for fx in game.effects:
		if String(fx.get("type", "")) == "actor_death":
			found_death_fx = true
			break
	if not found_death_fx:
		_fail(33, "Smoke test: enemy death animation effect was not created")
		return
	game.spawn_floor()

	game.current_room = {"area":"DUNGEON","type":"TREASURE","reward_bonus":50,"hazard":"none"}
	game.rewarded_floor = 0
	var coins_before_room: int = int(game.run.run_coins)
	game.roll_upgrade_options()
	if int(game.run.run_coins) < coins_before_room + 50 or game.upgrade_options.size() != 3:
		_fail(13, "Smoke test: treasure room reward or upgrade roll failed")
		return
	game.apply_upgrade(0)
	game.continue_run()

	game.run.floor_no = 11
	game.spawn_floor()
	if String(game.current_room.get("area", "")) != "CRYPT":
		_fail(14, "Smoke test: Floor 11 did not enter Crypt area")
		return
	if float(game.room_transition) <= 0.0:
		_fail(15, "Smoke test: v0.6 room transition was not triggered")
		return

	game.run.floor_no = 20
	game.spawn_floor()
	var found_keeper := false
	for e in game.enemies:
		if String(e["type"]) == "warden" and String(e.get("boss_variant", "")) == "crypt_keeper":
			found_keeper = true
			e["hp"] = float(e["max_hp"]) * 0.45
			break
	if not found_keeper:
		_fail(16, "Smoke test: Crypt Keeper did not spawn on floor 20")
		return
	if float(game.keeper_intro) <= 0.0:
		_fail(17, "Smoke test: Crypt Keeper intro was not triggered")
		return
	game.update_enemies(0.016)

	game.run.floor_no = 5
	game.spawn_floor()
	var found_warden := false
	for e in game.enemies:
		if String(e["type"]) == "warden" and String(e.get("boss_variant", "warden")) == "warden":
			found_warden = true
			e["hp"] = float(e["max_hp"]) * 0.45
			break
	if not found_warden:
		_fail(18, "Smoke test: standard Warden did not remain on floor 5")
		return
	game.update_enemies(0.016)

	game.run.run_coins = 50
	game.cash_out()
	if game.state != game.State.HOME:
		_fail(19, "Smoke test: cash out did not return home")
		return

	print("ONE MORE FLOOR gameplay smoke test passed")
	quit(0)
