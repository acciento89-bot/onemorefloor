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

	# Exercise the inherited presentation paths deterministically. The full r3
	# gameplay-distance capture below remains the authority for real combined visual
	# behavior; this smoke verifies that the new meshes survive those old triggers.
	var enemy: Dictionary = {
		"type":"necromancer",
		"pos":Vector2(285.0, 430.0),
		"radius":27.0,
		"phase":0.8,
		"attack_cd":0.05,
	}
	var proxy := world.enemy_pool[0] as Node3D
	world.actor_factory.configure_enemy(proxy, "necromancer", world.actor_materials)
	proxy.visible = true
	proxy.position = world.design_to_world(enemy["pos"])
	world.runtime_elapsed = 4.0
	world.call("_sync_actor_grounding", [enemy])
	if not ground.visible:
		_fail("r3 grounding did not activate through inherited grounding path")
		return
	if not (ground.mesh is ArrayMesh):
		_fail("visible r3 grounding regressed to non-ArrayMesh geometry")
		return

	var coins: Array = [
		{"pos":Vector2(300.0, 520.0), "value":1},
		{"pos":Vector2(350.0, 535.0), "value":8},
	]
	world.call("_sync_loot_presentation", coins)
	if not marker.visible:
		_fail("r3 loot marker did not activate through inherited loot path")
		return
	if beam == null or not (beam.mesh is ArrayMesh) or floor_glow == null or not (floor_glow.mesh is ArrayMesh):
		_fail("r3 loot geometry regressed after inherited loot sync")
		return

	# Primary danger telegraphs are gameplay-significant and must remain the
	# segmented v1.61 tell geometry rather than being folded into the new grounding.
	world.call("_sync_ground_telegraphs", [enemy])
	if world.telegraph_pool.is_empty():
		_fail("primary danger telegraph pool missing")
		return
	var tell := world.telegraph_pool[0] as MeshInstance3D
	if tell == null or not tell.visible or not (tell.mesh is ArrayMesh):
		_fail("primary segmented danger telegraph regressed under r3")
		return

	print("v1.61 combat presentation r3 smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V75_R3_COMBAT_FAIL:%s" % message)
	quit(1)
