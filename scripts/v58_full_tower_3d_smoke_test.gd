extends SceneTree

const FullTowerWorld = preload("res://scripts/world3d_chamber_v145.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = FullTowerWorld.new()
	world.name = "FullTowerSmokeWorld"
	root.add_child(world)
	await process_frame

	if not world.full_tower_ready():
		_fail("Full tower world did not finish building")
		return

	var realm_checks: Array = [
		[5, "lower_halls"],
		[15, "ossuary"],
		[25, "iron_bastion"],
		[35, "rift_descent"],
		[45, "starless_spire"],
		[50, "starless_spire"],
	]
	for check_value in realm_checks:
		var check: Array = check_value as Array
		var floor_no: int = int(check[0])
		var expected_realm: String = String(check[1])
		world.sync_runtime(
			Vector2(360,590),
			[{"pos":Vector2(440,390), "type":"skeleton", "radius":25.0, "attack_cd":0.12, "phase":0.3}],
			[{"pos":Vector2(390,520)}],
			[{"pos":Vector2(420,470), "color":Color("a657ff")}],
			[{"pos":Vector2(335,650), "value":5}],
			Vector2(0.35,-0.45), 1.25, 0.8, 0.0, floor_no
		)
		await process_frame
		var snapshot: Dictionary = world.debug_snapshot()
		if String(snapshot.get("realm", "")) != expected_realm:
			_fail("Floor %d expected realm %s, got %s" % [floor_no, expected_realm, String(snapshot.get("realm", "missing"))])
			return

	# Verify Rift Descent late-floor chamber variant and root visibility.
	world.sync_runtime(Vector2(360,590), [], [], [], [], Vector2.ZERO, 2.0, 0.0, 0.0, 39)
	await process_frame
	var rift_snapshot: Dictionary = world.debug_snapshot()
	if not bool(rift_snapshot.get("rift_active", false)) or int(rift_snapshot.get("rift_variant", -1)) != 2:
		_fail("Rift Descent late-floor variant did not activate")
		return
	var rift_root := world.get_node_or_null("RiftDescentRealm") as Node3D
	if rift_root == null or not rift_root.visible or rift_root.get_node_or_null("RiftAnchor") == null:
		_fail("Rift Descent production root is missing or hidden")
		return

	# Verify Starless Spire apex variant and that earlier realm roots are hidden.
	world.sync_runtime(Vector2(360,590), [], [], [], [], Vector2.ZERO, 2.6, 0.0, 0.0, 48)
	await process_frame
	var starless_snapshot: Dictionary = world.debug_snapshot()
	if not bool(starless_snapshot.get("starless_active", false)) or int(starless_snapshot.get("starless_variant", -1)) != 2:
		_fail("Starless Spire apex variant did not activate")
		return
	var starless_root := world.get_node_or_null("StarlessSpireRealm") as Node3D
	if starless_root == null or not starless_root.visible or starless_root.get_node_or_null("Starwell") == null:
		_fail("Starless Spire production root is missing or hidden")
		return
	var iron_root := world.get_node_or_null("IronBastionRealm") as Node3D
	var ossuary_root := world.get_node_or_null("OssuaryRealm") as Node3D
	if (iron_root != null and iron_root.visible) or (ossuary_root != null and ossuary_root.visible) or rift_root.visible:
		_fail("Previous realm presentation remained visible in Starless Spire")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	if not main.has_method("_v58_full_tower_world_ready"):
		_fail("main scene is not running v1.45")
		return
	if not bool(main.call("_v58_full_tower_world_ready")):
		_fail("main v1.45 full-tower layer reports not ready")
		return

	print("v1.45 full tower 3D smoke test passed")
	main.queue_free()
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.45 full tower 3D smoke test: %s" % message)
	quit(1)
