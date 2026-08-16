extends SceneTree

const LootV2 = preload("res://scripts/loot_system_v2.gd")
const ProgressionV2 = preload("res://scripts/progression_v2.gd")

func _init() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 181818

	# Loot 2.0: enhancement reaches cap, awakening promotes rarity, enchanting
	# remains available on the promoted item.
	var loot = LootV2.new()
	loot.inventory = [{
		"id":"v31-test", "slot":"weapon", "name":"Test Blade",
		"rarity":"LEGENDARY", "rarity_index":4, "level":160,
		"damage_pct":0.42, "hp":0.0, "crit_pct":0.0, "coin_pct":0.0,
		"trait":"EXECUTIONER", "set":"BLOODSTAR", "locked":false,
		"enhance_level":0, "enchant_count":0, "awaken_count":0,
	}]
	loot.shards = 20000
	var enhance_cap := int(loot.max_enhance_level(loot.inventory[0]))
	for _i in range(enhance_cap):
		if not loot.enhance_index(0):
			_fail(1801, "v1.16 Loot 2.0: enhance failed before cap")
			return
	if not loot.can_awaken(loot.inventory[0]):
		_fail(1802, "v1.16 Loot 2.0: maxed item cannot awaken")
		return
	if not loot.awaken_index(0) or String(loot.inventory[0].get("rarity", "")) != "MYTHIC":
		_fail(1803, "v1.16 Loot 2.0: awakening did not promote Legendary to Mythic")
		return
	if not loot.enchant_index(0, rng):
		_fail(1804, "v1.16 Loot 2.0: enchanting failed on Mythic item")
		return

	# Meta 2.0: milestone currency and permanent mastery branches.
	var meta = ProgressionV2.new()
	meta.best_floor = 200
	meta.ascension_sigils = 10
	var before_damage := float(meta.damage_multiplier())
	if not meta.buy_mastery("warpath"):
		_fail(1805, "v1.17 Meta 2.0: Warpath mastery purchase failed")
		return
	if float(meta.damage_multiplier()) <= before_damage:
		_fail(1806, "v1.17 Meta 2.0: Warpath mastery did not raise damage")
		return

	# Runtime integration: new systems replace the compatible v1.15 instances,
	# guaranteed Floor-57 contract exists, and new event families resolve choices.
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(1807, "v1.18 Runs 3.0: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	if not game.has_method("_v31_prepare_floor_contract") or not game.loot.has_method("enhance_index") or not game.meta.has_method("buy_mastery"):
		_fail(1808, "v1.18 Runs 3.0: cumulative systems are not active")
		return
	game.tutorial_active = false
	game.start_run()
	game.run.floor_no = 57
	game.current_room = {"type":"COMBAT", "area":"VOID CITADEL", "hazard":"none"}
	game.enemies.clear()
	game.enemies.append({
		"type":"void_lancer", "hp":100.0, "max_hp":100.0, "speed":80.0,
		"touch_damage":10.0, "reward":10, "elite":false,
	})
	game.rng.seed = 57
	game._v31_prepare_floor_contract()
	if not game.v31_challenge_active:
		_fail(1809, "v1.18 Runs 3.0: guaranteed Floor-57 contract did not activate")
		return
	game._v23_set_room_event("cursed_gate")
	if not game.room_event_active or game._v23_event_choices().size() != 3:
		_fail(1810, "v1.18 Runs 3.0: Cursed Gate event is not wired")
		return

	print("ONE MORE FLOOR v1.16-v1.18 three-step gameplay smoke test passed")
	quit(0)
