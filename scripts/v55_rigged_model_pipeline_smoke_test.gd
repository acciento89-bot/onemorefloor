extends SceneTree

const RigWorld = preload("res://scripts/world3d_chamber_v142.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = RigWorld.new()
	world.name = "RigPipelineSmokeWorld"
	root.add_child(world)
	await process_frame

	if not world.rig_pipeline_ready():
		_fail("rig pipeline chamber did not finish building")
		return

	var registry: Dictionary = world.model_registry_snapshot()
	var known: Array = registry.get("known", [])
	var available_count := int(registry.get("available_count", -1))
	var fallback_count := int(registry.get("fallback_count", -1))
	if known.size() != 7:
		_fail("expected seven production actor model slots")
		return
	if available_count + fallback_count != known.size():
		_fail("model availability/fallback accounting is inconsistent")
		return

	var wanderer := world.get_node_or_null("Wanderer3D") as Node3D
	if wanderer == null or wanderer.get_node_or_null("Motion/RigMount") == null:
		_fail("Wanderer rig mount missing")
		return
	if not bool(wanderer.get_meta("model_pipeline_ready", false)):
		_fail("Wanderer model pipeline marker missing")
		return

	var enemies := [
		{"pos":Vector2(470,420), "type":"goblin", "radius":24.0, "attack_cd":0.08, "phase":0.4},
		{"pos":Vector2(260,360), "type":"warden", "radius":38.0, "elite":true, "slam_cd":0.12, "phase":1.2},
	]
	world.sync_runtime(
		Vector2(360,580), enemies,
		[{"pos":Vector2(390,520), "crit":true}],
		[{"pos":Vector2(440,470), "color":Color("ff606e")}],
		[], Vector2.RIGHT, 1.25, 1.0, 0.0, 3
	)
	await process_frame

	var first_enemy := world.get_node_or_null("EnemyActor00") as Node3D
	if first_enemy == null or first_enemy.get_node_or_null("Motion/RigMount") == null:
		_fail("enemy rig mount missing after runtime configuration")
		return
	if not bool(first_enemy.get_meta("model_pipeline_ready", false)):
		_fail("enemy model pipeline marker missing")
		return
	var source := String(first_enemy.get_meta("model_source", ""))
	if source != "native-fallback" and source != "imported-glb":
		_fail("enemy model source is not a supported pipeline source")
		return

	var snapshot: Dictionary = world.debug_snapshot()
	if not bool(snapshot.get("rig_pipeline", false)):
		_fail("rig pipeline debug marker missing")
		return
	if int(snapshot.get("model_known_count", 0)) != 7:
		_fail("debug snapshot model slot count mismatch")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	if not main.has_method("_v55_rig_pipeline_ready"):
		_fail("main scene is not running v1.42")
		return
	if not bool(main.call("_v55_rig_pipeline_ready")):
		_fail("main v1.42 rig pipeline reports not ready")
		return

	print("v1.42 rigged model pipeline smoke test passed")
	main.queue_free()
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.42 rigged model pipeline smoke test: %s" % message)
	quit(1)
