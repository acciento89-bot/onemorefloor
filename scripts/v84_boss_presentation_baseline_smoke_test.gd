extends SceneTree

const WorldR1 = preload("res://scripts/world3d_chamber_v163_projectile_identity.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = WorldR1.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if not bool(world.call("production_projectile_identity_ready")):
		_fail("accepted v1.63 r1 projectile identity is not ready")
		return

	var warden := {
		"type":"warden", "pos":Vector2(360.0, 330.0), "radius":32.0,
		"phase":0.8, "elite":true, "attack_cd":0.8, "cast_kind":"ring"
	}
	world.sync_runtime(Vector2(360.0, 690.0), [warden], [], [], [], Vector2.ZERO, 22.0, 0.0, 0.0, 10)
	if world.boss_root == null or not world.boss_root.visible:
		_fail("inherited v1.46 boss frame is not active on floor 10")
		return
	if world.boss_halo == null or not (world.boss_halo.mesh is CylinderMesh):
		_fail("boss baseline halo is no longer the inherited CylinderMesh")
		return
	if world.boss_beam == null or not (world.boss_beam.mesh is CylinderMesh):
		_fail("boss baseline beam is no longer the inherited CylinderMesh")
		return
	if world.boss_crown == null:
		_fail("boss baseline crown is missing")
		return
	var box_count := 0
	for child_value in world.boss_crown.get_children():
		var child := child_value as MeshInstance3D
		if child != null and child.mesh is BoxMesh:
			box_count += 1
	if box_count != 4:
		_fail("boss baseline crown no longer contains four BoxMesh rods")
		return

	print("v1.63 boss presentation baseline smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V163_BOSS_BASELINE_FAIL:%s" % message)
	quit(1)
