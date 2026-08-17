extends SceneTree

const ProductionWorld = preload("res://scripts/world3d_chamber_v141.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = ProductionWorld.new()
	world.name = "ProductionSmokeWorld"
	root.add_child(world)
	await process_frame

	if not world.production_quality_ready():
		_fail("production-quality chamber did not finish building")
		return

	var enemies := [
		{"pos":Vector2(470,420), "type":"goblin", "radius":24.0, "attack_cd":0.08, "phase":0.4},
		{"pos":Vector2(260,360), "type":"warden", "radius":38.0, "elite":true, "slam_cd":0.12, "phase":1.2},
	]
	world.sync_runtime(
		Vector2(360,580), enemies,
		[{"pos":Vector2(390,520), "crit":true}],
		[{"pos":Vector2(440,470), "color":Color("ff606e")}],
		[{"pos":Vector2(330,650), "value":3}],
		Vector2.RIGHT, 1.25, 1.0, 1.0, 3
	)
	await process_frame

	# Move shots once so real trail geometry has a segment to render.
	world.sync_runtime(
		Vector2(370,575), enemies,
		[{"pos":Vector2(425,500), "crit":true}],
		[{"pos":Vector2(410,505), "color":Color("ff606e")}],
		[], Vector2(0.7,-0.2), 1.32, 0.0, 0.0, 3
	)
	await process_frame

	var snapshot: Dictionary = world.debug_snapshot()
	if not bool(snapshot.get("production_quality", false)):
		_fail("production-quality debug marker missing")
		return
	if int(snapshot.get("player_trails", 0)) < 1 or int(snapshot.get("enemy_trails", 0)) < 1:
		_fail("projectile trail pools missing")
		return
	if int(snapshot.get("impact_pool", 0)) < 1:
		_fail("impact pool missing")
		return

	var wanderer := world.get_node_or_null("Wanderer3D") as Node3D
	if wanderer == null or not bool(wanderer.get_meta("production_actor", false)):
		_fail("Wanderer production actor marker missing")
		return
	var first_enemy := world.get_node_or_null("EnemyActor00") as Node3D
	if first_enemy == null or first_enemy.get_node_or_null("Motion/Visual/TellRing") == null:
		_fail("enemy 3D tell geometry missing")
		return
	if world.get_node_or_null("ProductionDetails") == null:
		_fail("production chamber details missing")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	if not main.has_method("_v54_production_quality_ready"):
		_fail("main scene is not running v1.41")
		return
	if not bool(main.call("_v54_production_quality_ready")):
		_fail("main v1.41 production layer reports not ready")
		return

	print("v1.41 3D production quality smoke test passed")
	main.queue_free()
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.41 3D production quality smoke test: %s" % message)
	quit(1)
