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
	rng.seed = 4040
	var rooms = RoomSystem.new()

	if rooms.area_for_floor(31) != "DEEP TOWER" or rooms.area_for_floor(40) != "DEEP TOWER":
		_fail(1201,"Deep Tower floor routing is missing")
		return
	var room: Dictionary = rooms.roll_room(31,rng)
	if String(room.get("area","")) != "DEEP TOWER" or not String(room.get("hazard","")) in ["void_lanes","arcane_pulse"]:
		_fail(1202,"Deep Tower hazard rotation is missing")
		return
	var pool: Array[String] = rooms.enemy_pool("DEEP TOWER",36)
	for required: String in ["void_knight","rift_mage","soul_reaver"]:
		if not required in pool:
			_fail(1203,"Deep Tower enemy pool missing %s" % required)
			return

	for kind: String in ["void_knight","rift_mage","soul_reaver"]:
		var enemy: Dictionary = EnemyFactory.make_enemy(kind,36,rng,Vector2(360,700))
		if String(enemy.get("type","")) != kind or float(enemy.get("hp",0.0)) <= 0.0:
			_fail(1204,"EnemyFactory failed for %s" % kind)
			return
	var boss: Dictionary = EnemyFactory.make_enemy("astral_warden",40,rng,Vector2(360,700))
	if String(boss.get("type","")) != "warden" or String(boss.get("boss_variant","")) != "astral_warden":
		_fail(1205,"Astral Warden factory path is missing")
		return

	var run = RunProfile.new()
	run.apply_upgrade("multi")
	run.apply_upgrade("crit")
	if not run.has_synergy("shatter_volley"):
		_fail(1206,"Shatter Volley synergy did not unlock")
		return
	if run.consume_synergy_notice() != "SHATTER VOLLEY":
		_fail(1207,"Synergy notice did not surface")
		return
	run.apply_upgrade("lifesteal")
	run.apply_upgrade("armor")
	run.apply_upgrade("nova")
	run.apply_upgrade("haste")
	run.apply_upgrade("power")
	run.apply_upgrade("range")
	run.apply_upgrade("speed")
	for synergy: String in ["bloodsteel","stormcore","hunters_edge","momentum"]:
		if not run.has_synergy(synergy):
			_fail(1208,"Run synergy missing %s" % synergy)
			return
	if run.synergy_count() != 5:
		_fail(1209,"Expected five run synergies")
		return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(1210,"Main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	game.run.floor_no = 40
	game.spawn_floor()
	if String(game.current_room.get("area","")) != "DEEP TOWER":
		_fail(1211,"Floor 40 did not create a Deep Tower boss room")
		return
	var found_astral := false
	for e: Dictionary in game.enemies:
		if String(e.get("boss_variant","")) == "astral_warden":
			found_astral = true
			break
	if not found_astral:
		_fail(1212,"Floor 40 Astral Warden did not spawn")
		return
	if game._v12_actor_index("void_knight","") < 0 or game._v12_actor_index("rift_mage","") < 0 or game._v12_actor_index("soul_reaver","") < 0:
		_fail(1213,"Deep Tower enemies have no temporary production-art mapping")
		return

	game.queue_free()
	print("ONE MORE FLOOR Deep Tower gameplay smoke test passed")
	quit(0)
