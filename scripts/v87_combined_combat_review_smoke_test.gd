extends SceneTree

const WorldR21 = preload("res://scripts/world3d_chamber_v163_boss_dominance.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = WorldR21.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if not bool(world.call("production_boss_dominance_ready")):
		_fail("accepted r2.1 world is not ready")
		return
	if world.authority_impact_pool.is_empty():
		_fail("authority impact pool missing from combined review")
		return
	if world.death_burst_pool.is_empty():
		_fail("death burst pool missing from combined review")
		return
	if world.spawn_signature_pool.is_empty() or world.death_signature_pool.is_empty():
		_fail("spawn/death signature pools missing from combined review")
		return
	if world.loot_marker_pool.is_empty():
		_fail("loot marker pool missing from combined review")
		return
	if world.player_shot_pool.is_empty() or world.enemy_shot_pool.is_empty():
		_fail("r1 projectile pools missing from combined review")
		return
	print("v1.63 combined combat identity review smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V163_COMBINED_REVIEW_FAIL:%s" % message)
	quit(1)
