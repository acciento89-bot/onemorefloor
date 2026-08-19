extends SceneTree

const WorldR31 = preload("res://scripts/world3d_chamber_v161_combat_presentation_r31.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = WorldR31.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame

	if not bool(world.call("production_combat_presentation_ready")):
		_fail("r3.1 combat presentation did not become ready")
		return
	var snapshot: Dictionary = world.debug_snapshot()
	if String(snapshot.get("combat_presentation_v161_version", "")) != "1.61-combat-presentation-r3.1":
		_fail("r3.1 version marker missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_signatures", false)):
		_fail("r3.1 signature contract missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_ground_anchors", false)) or not bool(snapshot.get("combat_presentation_v161_loot_glints", false)):
		_fail("r3 grounding/loot baseline regressed under r3.1")
		return

	for pool_value in [world.spawn_signature_pool, world.death_signature_pool]:
		var pool: Array = pool_value
		if pool.is_empty():
			_fail("inherited signature pool missing")
			return
		var signature := pool[0] as Node3D
		var ring := signature.get_node_or_null("Ring") as MeshInstance3D
		if ring == null or not (ring.mesh is ArrayMesh):
			_fail("legacy signature ring was not replaced by r3.1 bracket geometry")
			return
		for shard_index in range(5):
			var shard := signature.get_node_or_null("Shard%d" % shard_index) as MeshInstance3D
			if shard == null or not (shard.mesh is ArrayMesh):
				_fail("legacy signature rod was not replaced: Shard%d" % shard_index)
				return

	var enemy: Dictionary = {
		"type":"goblin",
		"pos":Vector2(255.0, 505.0),
		"radius":23.0,
		"phase":0.2,
		"attack_cd":0.08,
	}
	world.call("_capture_signature_state", [])
	world.call("_sync_spawn_death_signatures", [enemy])
	var spawn := _first_visible(world.spawn_signature_pool)
	if spawn == null:
		_fail("r3.1 spawn signature did not trigger through inherited path")
		return
	world.call("_animate_signature_pool", world.spawn_signature_pool, 0.26, true)
	if spawn.scale.x > 1.12:
		_fail("r3.1 spawn signature remained excessively expanded")
		return

	world.call("_capture_signature_state", [enemy])
	world.call("_sync_spawn_death_signatures", [])
	var death := _first_visible(world.death_signature_pool)
	if death == null:
		_fail("r3.1 death signature did not trigger through inherited path")
		return
	world.call("_animate_signature_pool", world.death_signature_pool, 0.26, false)
	if death.scale.x > 1.36:
		_fail("r3.1 death signature exceeded restrained expansion ceiling")
		return

	print("v1.61 combat presentation r3.1 smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _first_visible(pool: Array) -> Node3D:
	for value in pool:
		var item := value as Node3D
		if item != null and item.visible:
			return item
	return null

func _fail(message: String) -> void:
	push_error("V75_R31_COMBAT_FAIL:%s" % message)
	quit(1)
