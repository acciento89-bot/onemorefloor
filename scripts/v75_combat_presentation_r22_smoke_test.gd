extends SceneTree

const WorldR22 = preload("res://scripts/world3d_chamber_v161_combat_presentation_r22.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = WorldR22.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame

	if not bool(world.call("production_combat_presentation_ready")):
		_fail("r2.2 combat presentation did not become ready")
		return
	var snapshot: Dictionary = world.debug_snapshot()
	if String(snapshot.get("combat_presentation_v161_version", "")) != "1.61-combat-presentation-r2.2":
		_fail("r2.2 version marker missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_death_bursts", false)):
		_fail("r2.2 death-burst contract missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_motion_streaks", false)):
		_fail("r2.1 motion-streak baseline regressed under r2.2")
		return
	if not bool(snapshot.get("combat_presentation_v161_impact_bursts", false)):
		_fail("r2 impact-burst baseline regressed under r2.2")
		return

	if world.death_burst_pool.is_empty():
		_fail("inherited death-burst pool missing")
		return
	var burst := world.death_burst_pool[0] as Node3D
	var burst_mesh := burst.get_node_or_null("Ring") as MeshInstance3D if burst != null else null
	if burst_mesh == null or not (burst_mesh.mesh is ArrayMesh):
		_fail("legacy death ring was not replaced by radial ArrayMesh")
		return
	world.call("_spawn_death_burst", Vector3.ZERO)
	if burst == null or not burst.visible:
		_fail("r2.2 death burst did not activate")
		return

	print("v1.61 combat presentation r2.2 smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V75_R22_COMBAT_PRESENTATION_FAIL:%s" % message)
	quit(1)
