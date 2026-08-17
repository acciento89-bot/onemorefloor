extends SceneTree

const World3DChamber = preload("res://scripts/world3d_chamber.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = World3DChamber.new()
	world.name = "SmokeWorld3D"
	root.add_child(world)
	await process_frame

	if not world.world_ready():
		_fail("3D chamber did not finish building")
		return
	var center: Vector3 = world.design_to_world(Vector2(360.0, 580.0))
	if center.distance_to(Vector3.ZERO) > 0.001:
		_fail("design/world center mapping drifted: %s" % center)
		return

	var enemies := [
		{"pos":Vector2(470,420), "type":"goblin", "radius":24.0, "hp":30.0, "max_hp":30.0},
		{"pos":Vector2(260,360), "type":"warden", "boss_variant":"warden", "radius":38.0, "elite":true},
	]
	var player_shots := [{"pos":Vector2(390,520), "crit":true}]
	var enemy_shots := [{"pos":Vector2(440,470), "color":Color("ff606e")}]
	var coins := [{"pos":Vector2(330,650), "value":3}]
	world.sync_runtime(
		Vector2(360,580), enemies, player_shots, enemy_shots, coins,
		Vector2.RIGHT, 1.25, 1.0, 1.0, 1
	)
	await process_frame
	var snapshot: Dictionary = world.debug_snapshot()
	if not bool(snapshot.get("ready", false)):
		_fail("3D chamber debug snapshot reports not ready")
		return
	if int(snapshot.get("enemy_pool", 0)) < 2:
		_fail("3D enemy proxy pool missing")
		return
	if int(snapshot.get("player_shot_pool", 0)) < 1 or int(snapshot.get("enemy_shot_pool", 0)) < 1:
		_fail("3D projectile proxy pools missing")
		return
	if int(snapshot.get("camera_projection", -1)) != int(Camera3D.PROJECTION_ORTHOGONAL):
		_fail("3D chamber camera is no longer orthographic/isometric")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	if not main.has_method("_v52_world_layer_ready"):
		_fail("main scene is not running v1.39 3D chamber layer")
		return
	if not bool(main.call("_v52_world_layer_ready")):
		_fail("main scene 3D world layer is not ready")
		return

	print("v1.39 first 3D chamber smoke test passed")
	main.queue_free()
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.39 first 3D chamber smoke test: %s" % message)
	quit(1)
