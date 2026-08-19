extends SceneTree

const WorldR21 = preload("res://scripts/world3d_chamber_v161_combat_presentation_r21.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = WorldR21.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame

	if not bool(world.call("production_combat_presentation_ready")):
		_fail("r2.1 combat presentation did not become ready")
		return
	var snapshot: Dictionary = world.debug_snapshot()
	if String(snapshot.get("combat_presentation_v161_version", "")) != "1.61-combat-presentation-r2.1":
		_fail("r2.1 version marker missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_motion_streaks", false)):
		_fail("r2.1 motion-streak contract missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_impact_bursts", false)):
		_fail("r2 impact-burst baseline regressed under r2.1")
		return

	if world.move_echo_pool.is_empty():
		_fail("inherited move-echo pool missing")
		return
	var echo_root := world.move_echo_pool[0] as Node3D
	if echo_root == null:
		_fail("move-echo root missing")
		return
	var streak := echo_root.get_node_or_null("Ring") as MeshInstance3D
	if streak == null or not (streak.mesh is ArrayMesh):
		_fail("legacy motion ring was not replaced by ArrayMesh streaks")
		return
	for rune_index in range(3):
		var rune := echo_root.get_node_or_null("Rune%d" % rune_index) as MeshInstance3D
		if rune != null and rune.visible:
			_fail("legacy motion rune remained visible: Rune%d" % rune_index)
			return

	var feet_socket: Node3D = world.actor_factory.call("actor_socket", world.player_root, "feet") as Node3D
	var current_position: Vector3 = feet_socket.global_position if feet_socket != null else world.player_root.global_position
	world.last_player_echo_position = current_position + Vector3(-1.0, 0.0, 0.0)
	world.call("_sync_player_move_echo", Vector2(1.0, 0.0))
	var visible_echo := false
	for value in world.move_echo_pool:
		var echo := value as Node3D
		if echo != null and echo.visible:
			visible_echo = true
			break
	if not visible_echo:
		_fail("directional motion streak did not activate")
		return

	if world.impact_pool.is_empty() or not ((world.impact_pool[0] as MeshInstance3D).mesh is ArrayMesh):
		_fail("r2 projectile impact burst regressed")
		return
	if world.combat_authority_impact_pool.is_empty():
		_fail("r2 combat impact pool missing")
		return
	var combat_root := world.combat_authority_impact_pool[0] as Node3D
	var combat_burst := combat_root.get_node_or_null("ImpactRing") as MeshInstance3D
	if combat_burst == null or not (combat_burst.mesh is ArrayMesh):
		_fail("r2 combat impact burst regressed")
		return

	print("v1.61 combat presentation r2.1 smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V75_R21_COMBAT_PRESENTATION_FAIL:%s" % message)
	quit(1)
