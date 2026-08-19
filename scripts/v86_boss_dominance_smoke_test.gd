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

	if not game.has_method("_v84_boss_dominance_ready") or not bool(game.call("_v84_boss_dominance_ready")):
		_fail("main scene is not on v1.63 r2.1 boss-dominance integration")
		return
	if not game.has_method("_v83_boss_identity_ready") or not bool(game.call("_v83_boss_identity_ready")):
		_fail("technical r2 boss-frame layer regressed")
		return
	if not game.has_method("_v82_projectile_identity_ready") or not bool(game.call("_v82_projectile_identity_ready")):
		_fail("accepted r1 projectile identity regressed")
		return
	if not game.has_method("_v80_runtime_cta_ready") or not bool(game.call("_v80_runtime_cta_ready")):
		_fail("accepted v1.62 r3 UI regressed")
		return

	var world = game.get("v52_world_root")
	if world == null or not world.has_method("production_boss_dominance_ready"):
		_fail("r2.1 world missing")
		return
	if not bool(world.call("production_boss_dominance_ready")):
		_fail("r2.1 boss-dominance contract failed")
		return

	var outer := world.boss_dominance_ring_outer as MeshInstance3D
	var inner := world.boss_dominance_ring_inner as MeshInstance3D
	if outer == null or not (outer.mesh is ArrayMesh) or outer.mesh is TorusMesh:
		_fail("outer dominance ring was not replaced by open ArrayMesh geometry")
		return
	if inner == null or not (inner.mesh is ArrayMesh) or inner.mesh is TorusMesh:
		_fail("inner dominance ring was not replaced by open ArrayMesh geometry")
		return
	if outer.mesh.get_aabb().size.x > 2.12 or outer.mesh.get_aabb().size.z > 2.12:
		_fail("outer dominance geometry is still oversized: %s" % str(outer.mesh.get_aabb().size))
		return
	if inner.mesh.get_aabb().size.x > 1.42 or inner.mesh.get_aabb().size.z > 1.42:
		_fail("inner dominance geometry is still oversized: %s" % str(inner.mesh.get_aabb().size))
		return

	var marker_count := 0
	var visible_markers := 0
	for value in world.boss_dominance_root.get_children():
		var marker := value as MeshInstance3D
		if marker == null or not String(marker.name).begins_with("DominanceMark"):
			continue
		marker_count += 1
		if marker.visible:
			visible_markers += 1
		if not (marker.mesh is ArrayMesh) or marker.mesh is BoxMesh:
			_fail("dominance marker still uses BoxMesh/block geometry")
			return
	if marker_count != 8 or visible_markers != 4:
		_fail("dominance marker visibility contract changed: %d total / %d visible" % [marker_count, visible_markers])
		return
	if world.boss_dominance_light.omni_range > 2.90:
		_fail("boss dominance light range remains oversized")
		return

	# Danger-language geometry must remain byte-for-byte equivalent in footprint to
	# an untouched accepted r1 world. r2.1 changes decorative dominance only.
	var baseline = WorldR1.new()
	root.add_child(baseline)
	baseline.set_active(false)
	for _i in range(8):
		await process_frame
	if not bool(baseline.call("production_projectile_identity_ready")):
		_fail("r1 reference world failed to initialize")
		return
	for pair in [
		[world.v161_tell_focus_mesh, baseline.v161_tell_focus_mesh, "focus"],
		[world.v161_tell_charge_mesh, baseline.v161_tell_charge_mesh, "charge"],
		[world.v161_tell_phase_mesh, baseline.v161_tell_phase_mesh, "phase"],
		[world.v161_tell_slam_mesh, baseline.v161_tell_slam_mesh, "slam"],
		[world.v161_tell_ritual_mesh, baseline.v161_tell_ritual_mesh, "ritual"],
	]:
		var a: ArrayMesh = pair[0]
		var b: ArrayMesh = pair[1]
		if not _same_aabb(a.get_aabb(), b.get_aabb()):
			_fail("%s tell geometry changed in boss r2.1" % String(pair[2]))
			return

	print("v1.63 boss dominance r2.1 smoke test passed")
	baseline.queue_free()
	game.queue_free()
	await process_frame
	quit(0)

func _same_aabb(a: AABB, b: AABB) -> bool:
	return a.position.distance_to(b.position) <= 0.0001 and a.size.distance_to(b.size) <= 0.0001

func _fail(message: String) -> void:
	push_error("V163_BOSS_R21_FAIL:%s" % message)
	quit(1)
