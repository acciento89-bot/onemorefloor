extends SceneTree

const ProductionWorld = preload("res://scripts/world3d_chamber_v146.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = ProductionWorld.new()
	world.name = "ProductionVerticalSliceSmokeWorld"
	root.add_child(world)
	await process_frame
	world.set_active(true)

	if not world.production_slice_ready():
		_fail("production vertical slice did not finish building")
		return

	var realm_checks: Array = [
		[1, "lower_halls"],
		[11, "ossuary"],
		[21, "iron_bastion"],
		[31, "rift_descent"],
		[41, "starless_spire"],
	]
	for check_value in realm_checks:
		var check: Array = check_value
		var floor_no: int = int(check[0])
		var expected_realm: String = String(check[1])
		world.sync_runtime(
			Vector2(360, 590), [], [], [], [], Vector2.ZERO,
			float(floor_no) * 0.2, 0.0, 0.0, floor_no
		)
		await process_frame
		var realm_snapshot: Dictionary = world.debug_snapshot()
		if String(realm_snapshot.get("realm", "")) != expected_realm:
			_fail("realm mismatch on floor %d" % floor_no)
			return

	var combat_enemies := [
		{"pos":Vector2(440,420), "type":"warden", "boss_variant":"warden", "radius":34.0, "elite":true, "slam_cd":0.05, "phase":0.2},
		{"pos":Vector2(285,385), "type":"necromancer", "radius":27.0, "summon_cd":0.06, "phase":0.7},
	]
	var coins := [
		{"pos":Vector2(335,650), "value":4},
		{"pos":Vector2(395,625), "value":12},
	]
	world.sync_runtime(
		Vector2(360,590), combat_enemies,
		[{"pos":Vector2(390,530), "crit":true}],
		[{"pos":Vector2(430,470), "color":Color("a568ff")}],
		coins, Vector2(0.55,-0.35), 5.0, 1.0, 1.0, 50
	)
	await process_frame

	var snapshot: Dictionary = world.debug_snapshot()
	if not bool(snapshot.get("production_slice_ready", false)):
		_fail("production readiness missing from debug snapshot")
		return
	if not bool(snapshot.get("boss_frame_active", false)):
		_fail("boss presentation did not activate on floor 50")
		return
	if int(snapshot.get("telegraph_pool", 0)) != 18:
		_fail("combat telegraph pool size is wrong")
		return
	if int(snapshot.get("death_burst_pool", 0)) != 12:
		_fail("death feedback pool size is wrong")
		return
	if int(snapshot.get("loot_marker_pool", 0)) != 24:
		_fail("loot presentation pool size is wrong")
		return

	var tell := world.get_node_or_null("ProductionVerticalSlice/CombatTelegraphs/Telegraph00") as MeshInstance3D
	if tell == null or not tell.visible:
		_fail("ground telegraph did not become visible")
		return
	var loot_marker := world.get_node_or_null("ProductionVerticalSlice/LootPresentation/LootMarker00") as Node3D
	if loot_marker == null or not loot_marker.visible:
		_fail("loot marker did not become visible")
		return
	var attack_pulse := world.get_node_or_null("ProductionVerticalSlice/PlayerCombatFeedback/AttackPulse") as MeshInstance3D
	var skill_pulse := world.get_node_or_null("ProductionVerticalSlice/PlayerCombatFeedback/SkillPulseOuter") as MeshInstance3D
	if attack_pulse == null or not attack_pulse.visible:
		_fail("player attack feedback did not activate")
		return
	if skill_pulse == null or not skill_pulse.visible:
		_fail("player skill feedback did not activate")
		return

	# Removing one enemy must produce pooled death feedback without touching gameplay state.
	world.sync_runtime(
		Vector2(360,590), [combat_enemies[0]], [], [], coins,
		Vector2.ZERO, 5.1, 0.0, 0.0, 50
	)
	await process_frame
	var death_root := world.get_node_or_null("ProductionVerticalSlice/DeathFeedback") as Node3D
	var death_visible := false
	if death_root != null:
		for child_value in death_root.get_children():
			var child := child_value as Node3D
			if child != null and child.visible:
				death_visible = true
				break
	if not death_visible:
		_fail("enemy removal did not spawn death feedback")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	if not main.has_method("_v59_production_slice_ready"):
		_fail("main scene is not running v1.46")
		return
	if not bool(main.call("_v59_production_slice_ready")):
		_fail("main v1.46 production slice reports not ready")
		return

	print("v1.46 production vertical slice smoke test passed")
	main.queue_free()
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.46 production vertical slice smoke test: %s" % message)
	quit(1)
