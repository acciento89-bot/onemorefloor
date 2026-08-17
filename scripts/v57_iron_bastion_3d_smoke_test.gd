extends SceneTree

const IronBastionWorld = preload("res://scripts/world3d_chamber_v144.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = IronBastionWorld.new()
	world.name = "IronBastionSmokeWorld"
	root.add_child(world)
	await process_frame

	if not world.iron_bastion_ready():
		_fail("Iron Bastion world did not finish building")
		return

	# Floor 5 keeps the Lower Halls presentation.
	world.sync_runtime(
		Vector2(360,580), [], [], [], [], Vector2.ZERO,
		0.5, 0.0, 0.0, 5
	)
	await process_frame
	var lower_snapshot: Dictionary = world.debug_snapshot()
	if String(lower_snapshot.get("realm", "")) != "lower_halls":
		_fail("Lower Halls realm identity missing")
		return
	if bool(lower_snapshot.get("iron_bastion_active", true)):
		_fail("Iron Bastion activated before floor 21")
		return

	# Floor 15 still routes to the Ossuary presentation inherited from v1.43.
	world.sync_runtime(
		Vector2(360,580), [], [], [], [], Vector2.ZERO,
		0.9, 0.0, 0.0, 15
	)
	await process_frame
	var ossuary_snapshot: Dictionary = world.debug_snapshot()
	if String(ossuary_snapshot.get("realm", "")) != "ossuary":
		_fail("Ossuary realm identity did not survive v1.44")
		return
	if bool(ossuary_snapshot.get("iron_bastion_active", true)):
		_fail("Iron Bastion activated on an Ossuary floor")
		return

	var enemies := [
		{"pos":Vector2(455,410), "type":"warden", "radius":30.0, "attack_cd":0.10, "phase":0.2},
		{"pos":Vector2(275,365), "type":"skeleton", "radius":25.0, "attack_cd":0.14, "phase":0.7},
		{"pos":Vector2(365,315), "type":"ghoul", "radius":27.0, "lunge_cd":0.12, "phase":1.1},
	]
	world.sync_runtime(
		Vector2(360,590), enemies,
		[{"pos":Vector2(392,520)}],
		[{"pos":Vector2(430,470), "color":Color("f07a42")}],
		[{"pos":Vector2(330,650), "value":7}],
		Vector2(0.5,-0.35), 1.6, 1.0, 0.0, 25
	)
	await process_frame

	var snapshot: Dictionary = world.debug_snapshot()
	if not bool(snapshot.get("iron_bastion_active", false)):
		_fail("Iron Bastion did not activate for floor 25")
		return
	if String(snapshot.get("realm", "")) != "iron_bastion":
		_fail("Iron Bastion realm identity missing")
		return
	var bastion := world.get_node_or_null("IronBastionRealm") as Node3D
	if bastion == null or not bastion.visible:
		_fail("Iron Bastion realm root missing or hidden")
		return
	if bastion.get_node_or_null("ForgeHeart") == null:
		_fail("Iron Bastion Forge Heart missing")
		return
	if bastion.get_node_or_null("BastionKeyLight") == null:
		_fail("Iron Bastion key light missing")
		return
	var ossuary := world.get_node_or_null("OssuaryRealm") as Node3D
	if ossuary == null or ossuary.visible:
		_fail("Ossuary presentation remained visible in Iron Bastion")
		return
	var production_details := world.get_node_or_null("ProductionDetails") as Node3D
	if production_details == null or production_details.visible:
		_fail("Lower Halls production details remained visible in Iron Bastion")
		return

	# A floor beyond the current rollout must not leave Iron Bastion presentation stuck on.
	world.sync_runtime(
		Vector2(360,580), [], [], [], [], Vector2.ZERO,
		2.0, 0.0, 0.0, 31
	)
	await process_frame
	var beyond_snapshot: Dictionary = world.debug_snapshot()
	if bool(beyond_snapshot.get("iron_bastion_active", true)):
		_fail("Iron Bastion remained active beyond floor 30")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	if not main.has_method("_v57_iron_bastion_world_ready"):
		_fail("main scene is not running v1.44")
		return
	if not bool(main.call("_v57_iron_bastion_world_ready")):
		_fail("main v1.44 Iron Bastion layer reports not ready")
		return

	print("v1.44 Iron Bastion 3D smoke test passed")
	main.queue_free()
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.44 Iron Bastion 3D smoke test: %s" % message)
	quit(1)
