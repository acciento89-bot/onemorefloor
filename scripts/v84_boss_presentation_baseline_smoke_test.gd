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
	if world.boss_halo == null or world.boss_halo.mesh == null:
		_fail("boss baseline halo mesh is missing")
		return
	if world.boss_beam == null or world.boss_beam.mesh == null:
		_fail("boss baseline beam mesh is missing")
		return
	if world.boss_crown == null:
		_fail("boss baseline crown is missing")
		return

	print("V163_BOSS_BASELINE_HALO_CLASS:%s" % world.boss_halo.mesh.get_class())
	print("V163_BOSS_BASELINE_BEAM_CLASS:%s" % world.boss_beam.mesh.get_class())
	print("V163_BOSS_BASELINE_HALO_AABB:%s" % str(world.boss_halo.mesh.get_aabb()))
	print("V163_BOSS_BASELINE_BEAM_AABB:%s" % str(world.boss_beam.mesh.get_aabb()))
	print("V163_BOSS_BASELINE_HALO_IS_CYLINDER:%s" % str(world.boss_halo.mesh is CylinderMesh))
	print("V163_BOSS_BASELINE_BEAM_IS_CYLINDER:%s" % str(world.boss_beam.mesh is CylinderMesh))

	var crown_mesh_classes: Array[String] = []
	var box_count := 0
	for child_value in world.boss_crown.get_children():
		var child := child_value as MeshInstance3D
		if child == null or child.mesh == null:
			continue
		crown_mesh_classes.append(child.mesh.get_class())
		if child.mesh is BoxMesh:
			box_count += 1
	print("V163_BOSS_BASELINE_CROWN_CLASSES:%s" % ",".join(crown_mesh_classes))
	print("V163_BOSS_BASELINE_CROWN_BOX_COUNT:%d" % box_count)

	# Runtime class/AABB evidence is the source of truth for this baseline gate.
	# The prior `is CylinderMesh` assertion proved unreliable for these imported
	# PrimitiveMesh resources even though the creation helper uses CylinderMesh.
	if world.boss_halo.mesh.get_class() != "CylinderMesh":
		_fail("boss baseline halo runtime class is %s, expected CylinderMesh" % world.boss_halo.mesh.get_class())
		return
	if world.boss_beam.mesh.get_class() != "CylinderMesh":
		_fail("boss baseline beam runtime class is %s, expected CylinderMesh" % world.boss_beam.mesh.get_class())
		return
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
