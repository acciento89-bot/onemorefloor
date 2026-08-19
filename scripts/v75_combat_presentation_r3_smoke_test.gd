extends SceneTree

const WorldR3 = preload("res://scripts/world3d_chamber_v161_combat_presentation_r3.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = WorldR3.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame

	if not bool(world.call("production_combat_presentation_ready")):
		_fail("r3 combat presentation did not become ready")
		return
	var snapshot: Dictionary = world.debug_snapshot()
	if String(snapshot.get("combat_presentation_v161_version", "")) != "1.61-combat-presentation-r3":
		_fail("r3 version marker missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_ground_anchors", false)):
		_fail("r3 enemy ground-anchor contract missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_loot_glints", false)):
		_fail("r3 loot-glint contract missing")
		return

	if world.enemy_grounding_pool.is_empty():
		_fail("inherited enemy grounding pool missing")
		return
	var ground := world.enemy_grounding_pool[0] as MeshInstance3D
	if ground == null or not (ground.mesh is ArrayMesh):
		_fail("legacy enemy grounding ring was not replaced by ArrayMesh anchor geometry")
		return

	if world.loot_marker_pool.is_empty():
		_fail("inherited loot marker pool missing")
		return
	var marker := world.loot_marker_pool[0] as Node3D
	var beam := marker.get_node_or_null("Beam") as MeshInstance3D
	var floor_glow := marker.get_node_or_null("FloorGlow") as MeshInstance3D
	if beam == null or not (beam.mesh is ArrayMesh):
		_fail("legacy loot beam was not replaced by r3 glint geometry")
		return
	if floor_glow == null or not (floor_glow.mesh is ArrayMesh):
		_fail("legacy circular loot floor glow was not replaced by r3 glint geometry")
		return

	# Use the inherited gameplay paths to verify the visual replacements remain
	# active under real pressure and that primary danger telegraphs stay intact.
	var enemies: Array = [
		{"type":"necromancer", "pos":Vector2(285.0, 430.0), "radius":27.0, "phase":0.8, "attack_cd":0.05},
		{"type":"warden", "pos":Vector2(435.0, 390.0), "radius":31.0, "phase":1.2, "attack_cd":0.09, "elite":true},
	]
	var coins: Array = [
		{"pos":Vector2(300.0, 520.0), "value":1},
		{"pos":Vector2(350.0, 535.0), "value":8},
	]
	world.sync_runtime(Vector2(360.0, 665.0), enemies, [], [], coins, Vector2.ZERO, 4.0, 0.0, 0.0, 7)
	if world.transition_root != null:
		world.transition_root.visible = false

	var visible_ground := false
	for value in world.enemy_grounding_pool:
		var item := value as MeshInstance3D
		if item != null and item.visible:
			visible_ground = true
			if not (item.mesh is ArrayMesh):
				_fail("visible r3 enemy grounding regressed to non-ArrayMesh geometry")
				return
	if not visible_ground:
		_fail("r3 grounding did not activate under enemy pressure")
		return
	if not marker.visible:
		_fail("r3 loot marker did not activate through inherited loot sync")
		return
	if world.telegraph_pool.is_empty() or not ((world.telegraph_pool[0] as MeshInstance3D).mesh is ArrayMesh):
		_fail("primary segmented danger telegraph regressed under r3")
		return

	print("v1.61 combat presentation r3 smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V75_R3_COMBAT_FAIL:%s" % message)
	quit(1)
