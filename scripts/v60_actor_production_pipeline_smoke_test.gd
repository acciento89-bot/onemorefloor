extends SceneTree

const ActorProductionWorld = preload("res://scripts/world3d_chamber_v147.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = ActorProductionWorld.new()
	world.name = "ActorProductionSmokeWorld"
	root.add_child(world)
	await process_frame
	world.set_active(true)

	if not world.actor_production_ready():
		_fail("actor production world did not finish building")
		return

	var registry: Dictionary = world.production_registry_snapshot()
	var known: Array = registry.get("known", [])
	if known.size() != 7:
		_fail("production registry does not expose all seven actor kinds")
		return
	if int(registry.get("production_profiles", 0)) != 7:
		_fail("production model profiles are incomplete")
		return
	var animation_contract: Array = registry.get("animation_contract", [])
	if not animation_contract.has("spawn") or not animation_contract.has("death"):
		_fail("production animation contract is missing spawn/death states")
		return

	var player_sockets: Dictionary = world.actor_socket_snapshot(world.player_root)
	for socket_name in ["weapon", "offhand", "head", "chest", "feet", "overhead", "vfx"]:
		if not bool(player_sockets.get(socket_name, false)):
			_fail("player production socket missing: %s" % socket_name)
			return

	var enemies: Array = [
		{"pos":Vector2(250,390), "type":"goblin", "radius":23.0, "attack_cd":0.04, "phase":0.1},
		{"pos":Vector2(330,350), "type":"bat", "radius":21.0, "dive_cd":0.05, "phase":0.3},
		{"pos":Vector2(410,390), "type":"skeleton", "radius":24.0, "attack_cd":0.06, "phase":0.5},
		{"pos":Vector2(285,470), "type":"ghoul", "radius":26.0, "lunge_cd":0.07, "phase":0.7},
		{"pos":Vector2(445,470), "type":"necromancer", "radius":27.0, "summon_cd":0.08, "phase":0.9},
		{"pos":Vector2(360,300), "type":"warden", "boss_variant":"warden", "radius":34.0, "elite":true, "slam_cd":0.05, "phase":1.1},
	]
	world.sync_runtime(
		Vector2(360,590), enemies, [], [], [], Vector2(0.55,-0.25),
		8.0, 1.0, 0.0, 50
	)
	await process_frame

	for index in range(enemies.size()):
		var enemy := world.enemy_pool[index] as Node3D
		if enemy == null or not enemy.visible:
			_fail("configured enemy proxy is not visible at index %d" % index)
			return
		var expected_kind: String = String(enemies[index].get("type", ""))
		if String(enemy.get_meta("actor_kind", "")) != expected_kind:
			_fail("enemy kind mismatch at index %d" % index)
			return
		var sockets: Dictionary = world.actor_socket_snapshot(enemy)
		if not bool(sockets.get("weapon", false)) or not bool(sockets.get("overhead", false)):
			_fail("enemy production socket contract missing at index %d" % index)
			return
		if String(enemy.get_meta("model_source", "")) == "native-fallback" and String(enemy.get_meta("v147_enemy_art_kind", "")) != expected_kind:
			_fail("native fallback detail pass missing for %s" % expected_kind)
			return

	var first_enemy := world.enemy_pool[0] as Node3D
	if first_enemy == null or String(first_enemy.get_meta("production_one_shot_state", "")) != "spawn":
		_fail("newly occupied actor slot did not queue spawn presentation")
		return

	if String(world.player_root.get_meta("model_source", "")) == "native-fallback" and not bool(world.player_root.get_meta("v147_player_art", false)):
		_fail("native Wanderer fallback did not receive v1.47 art upgrade")
		return

	# Move the hero during an active attack so the fixed weapon-arc pool receives
	# at least two distinct weapon-tip samples.
	world.sync_runtime(
		Vector2(380,590), enemies, [], [], [], Vector2(0.70,0.0),
		8.08, 1.0, 0.0, 50
	)
	await process_frame
	var trail_visible := false
	for segment_value in world.weapon_trail_pool:
		var segment := segment_value as MeshInstance3D
		if segment != null and segment.visible:
			trail_visible = true
			break
	if not trail_visible:
		_fail("Wanderer weapon-arc pool did not produce a visible segment")
		return

	var snapshot: Dictionary = world.debug_snapshot()
	if not bool(snapshot.get("actor_production_ready", false)):
		_fail("actor production readiness missing from debug snapshot")
		return
	if int(snapshot.get("weapon_trail_segments", 0)) != 7:
		_fail("weapon trail pool size is wrong")
		return
	if int(snapshot.get("production_model_profiles", 0)) != 7:
		_fail("debug snapshot production profile count is wrong")
		return
	if not bool(snapshot.get("production_slice_ready", false)) or String(snapshot.get("realm", "")) != "starless_spire":
		_fail("v1.46 full production slice regressed under actor pipeline")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	if not main.has_method("_v60_actor_production_ready"):
		_fail("main scene is not running v1.47")
		return
	if not bool(main.call("_v60_actor_production_ready")):
		_fail("main v1.47 actor production pipeline reports not ready")
		return

	print("v1.47 actor production pipeline smoke test passed")
	main.queue_free()
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.47 actor production pipeline smoke test: %s" % message)
	quit(1)
