extends SceneTree

const RoomSystem = preload("res://scripts/room_system.gd")
const EnemyFactory = preload("res://scripts/enemy_factory.gd")
const RunProfile = preload("res://scripts/run_profile.gd")

func _init() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 23050
	var rooms = RoomSystem.new()
	if rooms.area_for_floor(40) != "DEEP TOWER":
		_fail(1201, "v1.11 gameplay: Floor 40 Deep Tower routing regressed")
		return
	if rooms.area_for_floor(41) != "STARLESS SPIRE" or rooms.area_for_floor(50) != "STARLESS SPIRE":
		_fail(1202, "v1.11 gameplay: Floors 41-50 are not Starless Spire")
		return
	var spire_pool: Array[String] = rooms.enemy_pool("STARLESS SPIRE", 47)
	for required in ["phase_stalker", "oathbreaker", "orb_weaver", "soul_reaver"]:
		if not String(required) in spire_pool:
			_fail(1203, "v1.11 gameplay: Starless Spire enemy missing: %s" % String(required))
			return

	var player_pos := Vector2(360, 700)
	for kind in ["phase_stalker", "orb_weaver", "oathbreaker"]:
		var enemy: Dictionary = EnemyFactory.make_enemy(String(kind), 45, rng, player_pos)
		if String(enemy.get("type", "")) != String(kind) or float(enemy.get("hp", 0.0)) <= 0.0:
			_fail(1204, "v1.11 gameplay: enemy factory failed for %s" % String(kind))
			return
	var sovereign: Dictionary = EnemyFactory.make_enemy("null_sovereign", 50, rng, player_pos)
	if String(sovereign.get("type", "")) != "warden" or String(sovereign.get("boss_variant", "")) != "null_sovereign":
		_fail(1205, "v1.11 gameplay: Floor 50 boss factory path missing")
		return

	var run = RunProfile.new()
	var fake_meta = _FakeMeta.new()
	run.reset(fake_meta)
	var base_damage := float(run.damage)
	run.apply_upgrade_scaled("power", 2.25)
	if float(run.damage) <= base_damage * 1.50:
		_fail(1206, "v1.11 gameplay: Legendary-scaled upgrade is not stronger than Common")
		return
	run.apply_upgrade_scaled("range", 1.0)
	if not run.has_synergy("hunters_edge"):
		_fail(1207, "v1.11 gameplay: scaled upgrades no longer form synergies")
		return
	if run.active_synergy_names().is_empty():
		_fail(1208, "v1.11 gameplay: active synergy HUD data missing")
		return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(1209, "v1.11 gameplay: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	if not game.has_method("_v23_gameplay_ready") or not game._v23_gameplay_ready():
		_fail(1210, "v1.11 gameplay: main_v23 is not active")
		return

	game.run.floor_no = 44
	game.current_room = {"area":"STARLESS SPIRE", "type":"MINIBOSS", "hazard":"starfall", "reward_bonus":160}
	game._v23_setup_miniboss_room()
	var found_miniboss := false
	for e: Dictionary in game.enemies:
		if bool(e.get("miniboss", false)):
			found_miniboss = true
			break
	if not found_miniboss:
		_fail(1211, "v1.11 gameplay: miniboss room did not create a miniboss")
		return

	game.run.floor_no = 50
	game.spawn_floor()
	var found_sovereign := false
	for e: Dictionary in game.enemies:
		if String(e.get("boss_variant", "")) == "null_sovereign":
			found_sovereign = true
			break
	if not found_sovereign:
		_fail(1212, "v1.11 gameplay: Floor 50 does not spawn The Null Sovereign")
		return

	game.state = game.State.UPGRADE
	game.run.hp = game.run.max_hp * 0.25
	var hp_before := float(game.run.hp)
	game._v23_set_room_event("arcane_shrine")
	game.pointer(game.EVENT_RECTS[0].get_center(), true, 923)
	if game.room_event_active or float(game.run.hp) <= hp_before:
		_fail(1213, "v1.11 gameplay: Arcane Shrine event choice did not resolve")
		return

	game.upgrade_options = [{
		"name":"POWER SURGE", "desc":"test", "kind":"power", "color":game.C_GOLD,
		"tier":"EPIC", "strength":1.70, "tier_color":game.C_PURPLE
	}]
	var before_epic := float(game.run.damage)
	game.apply_upgrade(0)
	if float(game.run.damage) <= before_epic * 1.35 or game.state != game.State.DECISION:
		_fail(1214, "v1.11 gameplay: rarity-aware upgrade application failed")
		return

	print("ONE MORE FLOOR v1.11 Run System 2.0 smoke test passed")
	quit(0)

class _FakeMeta:
	extends RefCounted
	func hp_bonus() -> float: return 0.0
	func damage_multiplier() -> float: return 1.0
	func crit_bonus() -> float: return 0.0
