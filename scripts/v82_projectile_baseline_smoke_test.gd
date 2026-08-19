extends SceneTree

const WorldR32 = preload("res://scripts/world3d_chamber_v161_combat_presentation_r32.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = WorldR32.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame

	if not bool(world.call("production_combat_presentation_ready")):
		_fail("v1.61 r3.2 presentation baseline is not ready")
		return
	if world.player_shot_pool.is_empty() or world.enemy_shot_pool.is_empty():
		_fail("projectile visual pools are missing")
		return
	if world.player_trail_pool.is_empty() or world.enemy_trail_pool.is_empty():
		_fail("projectile trail pools are missing")
		return

	var player_head := world.player_shot_pool[0] as MeshInstance3D
	var enemy_head := world.enemy_shot_pool[0] as MeshInstance3D
	var player_trail := world.player_trail_pool[0] as MeshInstance3D
	var enemy_trail := world.enemy_trail_pool[0] as MeshInstance3D
	if player_head == null or not (player_head.mesh is SphereMesh):
		_fail("player projectile baseline is no longer SphereMesh")
		return
	if enemy_head == null or not (enemy_head.mesh is SphereMesh):
		_fail("enemy projectile baseline is no longer SphereMesh")
		return
	if player_trail == null or not (player_trail.mesh is BoxMesh):
		_fail("player trail baseline is no longer BoxMesh")
		return
	if enemy_trail == null or not (enemy_trail.mesh is BoxMesh):
		_fail("enemy trail baseline is no longer BoxMesh")
		return
	if world.projectile_authority == null or not bool(world.projectile_authority.call("projectile_authority_ready")):
		_fail("separate v1.51 projectile collision authority is not ready")
		return

	print("v1.63 projectile visual baseline smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V163_PROJECTILE_BASELINE_FAIL:%s" % message)
	quit(1)
