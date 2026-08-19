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
		_fail("r3.2 combat presentation did not become ready")
		return
	var snapshot: Dictionary = world.debug_snapshot()
	if String(snapshot.get("combat_presentation_v161_version", "")) != "1.61-combat-presentation-r3.2":
		_fail("r3.2 version marker missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_directional_tells", false)):
		_fail("r3.2 directional tell contract missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_signatures", false)):
		_fail("r3.1 signature baseline regressed under r3.2")
		return
	if not bool(snapshot.get("combat_presentation_v161_ground_anchors", false)) or not bool(snapshot.get("combat_presentation_v161_loot_glints", false)):
		_fail("r3 grounding/loot baseline regressed under r3.2")
		return

	world.player_root.position = world.design_to_world(Vector2(360.0, 665.0))
	world.runtime_elapsed = 5.0

	var cases: Array = [
		{"mode":"focus", "enemy":{"type":"skeleton", "pos":Vector2(245.0, 475.0), "radius":25.0, "phase":0.2, "attack_cd":0.08}},
		{"mode":"charge", "enemy":{"type":"ghoul", "pos":Vector2(475.0, 470.0), "radius":24.0, "phase":0.4, "lunge_cd":0.09}},
		{"mode":"phase", "enemy":{"type":"necromancer", "pos":Vector2(270.0, 370.0), "radius":27.0, "phase":0.6, "attack_cd":1.0, "blink_cd":0.10}},
		{"mode":"slam", "enemy":{"type":"warden", "pos":Vector2(450.0, 350.0), "radius":31.0, "phase":0.8, "slam_cd":0.11, "elite":true}},
		{"mode":"ritual", "enemy":{"type":"necromancer", "pos":Vector2(360.0, 310.0), "radius":27.0, "phase":1.0, "attack_cd":1.0, "summon_cd":0.12}},
	]

	for case_value in cases:
		var case: Dictionary = case_value
		var enemy: Dictionary = case["enemy"]
		world.call("_sync_ground_telegraphs", [enemy])
		if world.telegraph_pool.is_empty():
			_fail("telegraph pool missing")
			return
		var tell := world.telegraph_pool[0] as MeshInstance3D
		if tell == null or not tell.visible:
			_fail("inherited tell trigger did not activate for %s" % String(case["mode"]))
			return
		var inherited_scale := tell.scale
		world.call("_apply_v161_enemy_presentation", [enemy])
		var mode := String(world.call("_v161_tell_mode", enemy))
		if mode != String(case["mode"]):
			_fail("r3.2 tell classification mismatch: expected %s got %s" % [String(case["mode"]), mode])
			return
		var expected_mesh: ArrayMesh = world.call("_v161_tell_mesh_for_mode", mode)
		if tell.mesh != expected_mesh:
			_fail("r3.2 tell mesh mismatch for %s" % mode)
			return
		if tell.scale.distance_to(inherited_scale) > 0.0001:
			_fail("r3.2 changed inherited danger radius scale for %s" % mode)
			return
		if not _mesh_within_accepted_radius(expected_mesh):
			_fail("r3.2 tell geometry exceeded accepted 0.68 local radius for %s" % mode)
			return
		if mode == "focus" or mode == "charge":
			var to_player := world.player_root.global_position - tell.global_position
			to_player.y = 0.0
			var expected_angle := atan2(to_player.x, -to_player.z)
			var angular_error := absf(wrapf(tell.rotation.y - expected_angle, -PI, PI))
			if angular_error > 0.001:
				_fail("r3.2 directional tell did not point at player for %s" % mode)
				return

	# Lowest active cooldown must continue to decide the inherited warning window.
	var mixed := {"type":"ghoul", "pos":Vector2(320.0, 430.0), "radius":24.0, "attack_cd":0.22, "lunge_cd":0.07}
	if String(world.call("_v161_active_tell_key", mixed)) != "lunge_cd":
		_fail("r3.2 active tell key no longer follows the lowest inherited cooldown")
		return
	if String(world.call("_v161_tell_mode", mixed)) != "charge":
		_fail("r3.2 mixed tell did not resolve to charge language")
		return

	print("v1.61 combat presentation r3.2 smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _mesh_within_accepted_radius(mesh: ArrayMesh) -> bool:
	if mesh == null:
		return false
	var box := mesh.get_aabb()
	var min_x := box.position.x
	var max_x := box.position.x + box.size.x
	var min_z := box.position.z
	var max_z := box.position.z + box.size.z
	var extent := maxf(maxf(absf(min_x), absf(max_x)), maxf(absf(min_z), absf(max_z)))
	return extent <= 0.681

func _fail(message: String) -> void:
	push_error("V75_R32_COMBAT_FAIL:%s" % message)
	quit(1)
