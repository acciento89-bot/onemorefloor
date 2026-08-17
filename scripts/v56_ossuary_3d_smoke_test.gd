extends SceneTree

const OssuaryWorld = preload("res://scripts/world3d_chamber_v143.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = OssuaryWorld.new()
	world.name = "OssuarySmokeWorld"
	root.add_child(world)
	await process_frame

	if not world.ossuary_ready():
		_fail("Ossuary world did not finish building")
		return

	# Lower Halls must remain the active realm for the original pilot floors.
	world.sync_runtime(
		Vector2(360,580), [], [], [], [], Vector2.ZERO,
		0.5, 0.0, 0.0, 5
	)
	await process_frame
	var lower_snapshot: Dictionary = world.debug_snapshot()
	if bool(lower_snapshot.get("ossuary_active", true)):
		_fail("Ossuary activated before floor 11")
		return
	if String(lower_snapshot.get("realm", "")) != "lower_halls":
		_fail("Lower Halls realm identity missing")
		return

	var enemies := [
		{"pos":Vector2(455,410), "type":"skeleton", "radius":24.0, "attack_cd":0.10, "phase":0.2},
		{"pos":Vector2(275,365), "type":"ghoul", "radius":27.0, "lunge_cd":0.14, "phase":0.7},
		{"pos":Vector2(365,315), "type":"necromancer", "radius":29.0, "summon_cd":0.12, "phase":1.1},
	]
	world.sync_runtime(
		Vector2(360,590), enemies,
		[{"pos":Vector2(392,520)}],
		[{"pos":Vector2(430,470), "color":Color("77d6ba")}],
		[{"pos":Vector2(330,650), "value":4}],
		Vector2(0.4,-0.5), 1.4, 1.0, 0.0, 15
	)
	await process_frame

	var snapshot: Dictionary = world.debug_snapshot()
	if not bool(snapshot.get("ossuary_active", false)):
		_fail("Ossuary did not activate for floor 15")
		return
	if String(snapshot.get("realm", "")) != "ossuary":
		_fail("Ossuary realm identity missing")
		return
	var ossuary := world.get_node_or_null("OssuaryRealm") as Node3D
	if ossuary == null or not ossuary.visible:
		_fail("Ossuary realm root missing or hidden")
		return
	if ossuary.get_node_or_null("BoneAltar") == null:
		_fail("Ossuary bone altar missing")
		return
	if ossuary.get_node_or_null("OssuaryColdLight") == null:
		_fail("Ossuary cold light missing")
		return
	var production_details := world.get_node_or_null("ProductionDetails") as Node3D
	if production_details == null or production_details.visible:
		_fail("Lower Halls production details were not hidden in Ossuary")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	if not main.has_method("_v56_ossuary_world_ready"):
		_fail("main scene is not running v1.43")
		return
	if not bool(main.call("_v56_ossuary_world_ready")):
		_fail("main v1.43 Ossuary layer reports not ready")
		return

	print("v1.43 Ossuary 3D smoke test passed")
	main.queue_free()
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.43 Ossuary 3D smoke test: %s" % message)
	quit(1)
