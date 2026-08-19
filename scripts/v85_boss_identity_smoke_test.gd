extends SceneTree

const WorldR1 = preload("res://scripts/world3d_chamber_v163_projectile_identity.gd")

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

	if not game.has_method("_v83_boss_identity_ready") or not bool(game.call("_v83_boss_identity_ready")):
		_fail("main scene is not on accepted v1.63 r2 boss identity integration")
		return
	if not game.has_method("_v82_projectile_identity_ready") or not bool(game.call("_v82_projectile_identity_ready")):
		_fail("accepted v1.63 r1 projectile identity regressed")
		return
	if not game.has_method("_v80_runtime_cta_ready") or not bool(game.call("_v80_runtime_cta_ready")):
		_fail("accepted v1.62 r3 UI readiness regressed")
		return

	var world = game.get("v52_world_root")
	if world == null or not world.has_method("production_boss_identity_ready"):
		_fail("v1.63 r2 boss world missing")
		return
	if not bool(world.call("production_boss_identity_ready")):
		_fail("v1.63 r2 boss identity contract failed")
		return

	var halo := world.boss_halo as MeshInstance3D
	var beam := world.boss_beam as MeshInstance3D
	if halo == null or not (halo.mesh is ArrayMesh) or halo.mesh is TorusMesh:
		_fail("boss halo did not replace the persistent TorusMesh")
		return
	if beam == null or not (beam.mesh is ArrayMesh) or beam.mesh is CylinderMesh:
		_fail("boss beam did not replace the inherited CylinderMesh")
		return
	var halo_size: Vector3 = halo.mesh.get_aabb().size
	var beam_size: Vector3 = beam.mesh.get_aabb().size
	if halo_size.x > 1.85 or halo_size.z > 1.85:
		_fail("boss floor anchors exceed restrained footprint: %s" % str(halo_size))
		return
	if beam_size.y > 1.40:
		_fail("boss fractured spire is still too tall: %s" % str(beam_size))
		return

	var crown_count := 0
	for value in world.boss_crown.get_children():
		var shard := value as MeshInstance3D
		if shard == null:
			continue
		if not (shard.mesh is ArrayMesh) or shard.mesh is BoxMesh:
			_fail("boss crown still contains block/box geometry")
			return
		crown_count += 1
	if crown_count != 4:
		_fail("boss crown shard count changed")
		return
	if world.boss_light.omni_range > 3.30:
		_fail("boss accent light still has legacy oversized range")
		return

	# Compare all five accepted r3.2 danger meshes against an untouched r1 world.
	# r2 may frame the boss, but it must not alter gameplay-significant tell shape.
	var baseline = WorldR1.new()
	root.add_child(baseline)
	baseline.set_active(false)
	for _i in range(8):
		await process_frame
	if not bool(baseline.call("production_projectile_identity_ready")):
		_fail("r1 reference world failed to initialize")
		return
	if not _same_aabb(world.v161_tell_focus_mesh.get_aabb(), baseline.v161_tell_focus_mesh.get_aabb()):
		_fail("focus tell geometry changed in boss r2")
		return
	if not _same_aabb(world.v161_tell_charge_mesh.get_aabb(), baseline.v161_tell_charge_mesh.get_aabb()):
		_fail("charge tell geometry changed in boss r2")
		return
	if not _same_aabb(world.v161_tell_phase_mesh.get_aabb(), baseline.v161_tell_phase_mesh.get_aabb()):
		_fail("phase tell geometry changed in boss r2")
		return
	if not _same_aabb(world.v161_tell_slam_mesh.get_aabb(), baseline.v161_tell_slam_mesh.get_aabb()):
		_fail("slam tell geometry changed in boss r2")
		return
	if not _same_aabb(world.v161_tell_ritual_mesh.get_aabb(), baseline.v161_tell_ritual_mesh.get_aabb()):
		_fail("ritual tell geometry changed in boss r2")
		return

	print("v1.63 boss identity r2 smoke test passed")
	baseline.queue_free()
	game.queue_free()
	await process_frame
	quit(0)

func _same_aabb(a: AABB, b: AABB) -> bool:
	return a.position.distance_to(b.position) <= 0.0001 and a.size.distance_to(b.size) <= 0.0001

func _fail(message: String) -> void:
	push_error("V163_BOSS_R2_FAIL:%s" % message)
	quit(1)
