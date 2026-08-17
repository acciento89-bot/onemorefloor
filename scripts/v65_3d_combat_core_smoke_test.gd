extends SceneTree

const CombatQueryAuthority = preload("res://scripts/world3d_combat_query_authority_v152.gd")
const CombatCoreWorld = preload("res://scripts/world3d_chamber_v152.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var authority = CombatQueryAuthority.new()
	authority.name = "CombatQuerySmoke"
	root.add_child(authority)
	await process_frame
	await physics_frame
	if not authority.combat_query_ready():
		_fail("3D combat query authority did not finish building")
		return

	var snap: Dictionary = authority.debug_snapshot()
	if int(snap.get("warden_lane_areas", 0)) != 7:
		_fail("Warden authority must expose seven pooled threat lanes")
		return
	if not bool(snap.get("attack_sensor", false)) or not bool(snap.get("nova_sensor", false)):
		_fail("attack/NOVA Area3D sensors are missing")
		return

	var enemies: Array = [
		{"pos":Vector2(390,700), "type":"goblin", "radius":23.0, "hp":100.0},
		{"pos":Vector2(500,700), "type":"skeleton", "radius":25.0, "hp":100.0},
		{"pos":Vector2(360,420), "type":"warden", "radius":35.0, "hp":500.0},
	]
	var target_report: Dictionary = authority.query_targets(Vector2(360,700), enemies, 180.0, [], 2)
	if not bool(target_report.get("ready", false)):
		_fail("3D target query did not resolve")
		return
	if String(target_report.get("mode", "")) != "3d_world_range":
		_fail("3D target mode marker missing")
		return
	var target_indices: Array = target_report.get("indices", [])
	if target_indices.is_empty() or int(target_indices[0]) != 0:
		_fail("nearest target was not selected from world-space range")
		return
	if 2 in target_indices:
		_fail("out-of-range Warden was incorrectly acquired")
		return

	var shots: Array = [
		{"pos":Vector2(382,700), "vel":Vector2.ZERO, "damage":8.0, "life":1.0},
		{"pos":Vector2(620,300), "vel":Vector2.ZERO, "damage":8.0, "life":1.0},
	]
	var nova_report: Dictionary = authority.query_nova(Vector2(360,700), enemies, shots, 100.0)
	if not bool(nova_report.get("ready", false)):
		_fail("3D NOVA query did not resolve")
		return
	var nova_enemies: Array = nova_report.get("enemy_indices", [])
	var nova_shots: Array = nova_report.get("projectile_indices", [])
	if not (0 in nova_enemies):
		_fail("near enemy was not captured by NOVA volume")
		return
	if not (0 in nova_shots) or 1 in nova_shots:
		_fail("NOVA projectile purge volume selected wrong hostile shots")
		return

	var fan_report: Dictionary = authority.plan_warden_cast(Vector2(360,420), Vector2(360,700), true, "fan", 3)
	if not bool(fan_report.get("ready", false)):
		_fail("Warden fan geometry did not resolve")
		return
	if (fan_report.get("directions", []) as Array).size() != 7:
		_fail("Warden fan must produce seven world-space lanes")
		return
	var ring_report: Dictionary = authority.plan_warden_cast(Vector2(360,420), Vector2(360,700), true, "ring", 4)
	if (ring_report.get("directions", []) as Array).size() != 14:
		_fail("phase-2 Warden ring must produce fourteen 3D launch directions")
		return

	var world = CombatCoreWorld.new()
	world.name = "CombatCoreWorldSmoke"
	root.add_child(world)
	await process_frame
	await physics_frame
	world.set_active(true)
	if not world.combat_core_authority_ready():
		_fail("v1.52 chamber combat core authority is not ready")
		return
	var world_targets: Dictionary = world.query_targets_3d(Vector2(360,700), enemies, 180.0, [], 1)
	if not bool(world_targets.get("ready", false)):
		_fail("v1.52 chamber target bridge failed")
		return
	var world_nova: Dictionary = world.query_nova_3d(Vector2(360,700), enemies, shots, 100.0)
	if not bool(world_nova.get("ready", false)):
		_fail("v1.52 chamber NOVA bridge failed")
		return
	var world_warden: Dictionary = world.plan_warden_cast_3d(Vector2(360,420), Vector2(360,700), true, "fan", 3)
	if not bool(world_warden.get("ready", false)):
		_fail("v1.52 chamber Warden bridge failed")
		return
	await process_frame
	var world_snap: Dictionary = world.debug_snapshot()
	if not bool(world_snap.get("combat_core_authority_ready", false)):
		_fail("combat core readiness missing from world snapshot")
		return
	if int(world_snap.get("target_lock_pool", 0)) != 4:
		_fail("target lock feedback pool size is wrong")
		return
	if int(world_snap.get("warden_lane_visuals", 0)) != 7:
		_fail("Warden threat visual pool size is wrong")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	await physics_frame
	if not main.has_method("_v65_3d_combat_core_ready"):
		_fail("main scene is not running v1.52")
		return
	if not bool(main.call("_v65_3d_combat_core_ready")):
		_fail("main v1.52 combat core reports not ready")
		return
	var main_snap: Dictionary = main.call("_v65_combat_core_snapshot")
	if String(main_snap.get("mode", "")) != "hybrid_3d_combat_core_authority":
		_fail("main v1.52 mode marker is wrong")
		return

	print("v1.52 3D combat core smoke test passed")
	main.queue_free()
	world.queue_free()
	authority.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.52 3D combat core smoke test: %s" % message)
	quit(1)
