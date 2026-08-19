extends SceneTree

const ProjectileAuthorityV151 = preload("res://scripts/world3d_projectile_authority_v151.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	for _i in range(16):
		await process_frame

	if not game.has_method("_v82_projectile_identity_ready"):
		_fail("main scene is not on v1.63 projectile identity integration")
		return
	if not bool(game.call("_v82_projectile_identity_ready")):
		_fail("v1.63 projectile identity integration is not ready")
		return
	if not game.has_method("_v80_runtime_cta_ready") or not bool(game.call("_v80_runtime_cta_ready")):
		_fail("v1.62 r3 UI readiness regressed")
		return

	var world = game.get("v52_world_root")
	if world == null or not world.has_method("production_projectile_identity_ready"):
		_fail("v1.63 combat world missing")
		return
	if not bool(world.call("production_projectile_identity_ready")):
		_fail("v1.63 projectile world contract failed")
		return

	var player_head := world.player_shot_pool[0] as MeshInstance3D
	var enemy_head := world.enemy_shot_pool[0] as MeshInstance3D
	var player_trail := world.player_trail_pool[0] as MeshInstance3D
	var enemy_trail := world.enemy_trail_pool[0] as MeshInstance3D
	if player_head == null or not (player_head.mesh is ArrayMesh) or player_head.mesh is SphereMesh:
		_fail("player projectile did not replace the inherited SphereMesh")
		return
	if enemy_head == null or not (enemy_head.mesh is ArrayMesh) or enemy_head.mesh is SphereMesh:
		_fail("enemy projectile did not replace the inherited SphereMesh")
		return
	if player_trail == null or not (player_trail.mesh is ArrayMesh) or player_trail.mesh is BoxMesh:
		_fail("player trail did not replace the inherited BoxMesh")
		return
	if enemy_trail == null or not (enemy_trail.mesh is ArrayMesh) or enemy_trail.mesh is BoxMesh:
		_fail("enemy trail did not replace the inherited BoxMesh")
		return

	if world.projectile_authority == null or not bool(world.projectile_authority.call("projectile_authority_ready")):
		_fail("v1.51 projectile collision authority is not ready")
		return
	if ProjectileAuthorityV151.PLAYER_SHOT_RADIUS_DESIGN != 10.0:
		_fail("player projectile authority radius changed")
		return
	if ProjectileAuthorityV151.ENEMY_SHOT_RADIUS_DESIGN != 9.0:
		_fail("enemy projectile authority radius changed")
		return
	if ProjectileAuthorityV151.PLAYER_HIT_RADIUS_DESIGN != 28.0:
		_fail("player hit authority radius changed")
		return

	var snapshot: Dictionary = world.call("debug_snapshot")
	if not bool(snapshot.get("collision_authority_preserved", false)):
		_fail("projectile identity snapshot does not preserve collision authority")
		return
	if String(snapshot.get("player_projectile_shape", "")) != "blade_shard":
		_fail("player projectile identity marker missing")
		return
	if String(snapshot.get("enemy_projectile_shape", "")) != "thorn_dart":
		_fail("enemy projectile identity marker missing")
		return

	print("v1.63 projectile identity r1 smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V163_PROJECTILE_R1_FAIL:%s" % message)
	quit(1)
