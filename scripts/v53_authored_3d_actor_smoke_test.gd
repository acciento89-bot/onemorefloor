extends SceneTree

const World3DChamber = preload("res://scripts/world3d_chamber.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = World3DChamber.new()
	root.add_child(world)
	await process_frame
	if not world.world_ready() or not world.authored_actor_ready():
		_fail("authored 3D world did not finish building")
		return

	var enemies := [
		{"pos":Vector2(470,420),"type":"goblin","radius":24.0,"hp":30.0,"max_hp":30.0,"phase":0.1},
		{"pos":Vector2(300,390),"type":"skeleton","radius":24.0,"hp":35.0,"max_hp":35.0,"phase":0.7},
		{"pos":Vector2(250,330),"type":"warden","boss_variant":"warden","radius":38.0,"elite":true,"phase":1.1},
	]
	world.sync_runtime(Vector2(360,580), enemies, [], [], [], Vector2.RIGHT, 2.0, 1.0, 1.0, 5)
	await process_frame
	var snapshot: Dictionary = world.debug_snapshot()
	if not bool(snapshot.get("authored_actors", false)):
		_fail("debug snapshot does not report authored actors")
		return
	var player = world.get_node_or_null("Wanderer3D")
	if player == null or player.get_node_or_null("Motion/Hood") == null or player.get_node_or_null("WeaponPivot/Blade") == null:
		_fail("Wanderer authored silhouette is incomplete")
		return
	var enemy0 = world.get_node_or_null("EnemyActor00")
	if enemy0 == null or String(enemy0.get_meta("actor_kind", "")) != "goblin":
		_fail("goblin authored actor was not configured")
		return
	if enemy0.get_node_or_null("Motion/Visual/HeadPivot/Ear") == null:
		_fail("goblin authored silhouette details are missing")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	if not main.has_method("_v53_authored_3d_ready") or not bool(main.call("_v53_authored_3d_ready")):
		_fail("main scene is not running v1.40 authored 3D layer")
		return

	print("v1.40 authored 3D actor smoke test passed")
	main.queue_free()
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.40 authored 3D actor smoke test: %s" % message)
	quit(1)
