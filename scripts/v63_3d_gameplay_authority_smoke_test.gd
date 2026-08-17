extends SceneTree

const GameplayAuthority = preload("res://scripts/world3d_gameplay_authority_v150.gd")
const AuthorityWorld = preload("res://scripts/world3d_chamber_v150.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var authority = GameplayAuthority.new()
	authority.name = "AuthoritySmoke"
	root.add_child(authority)
	await process_frame
	await physics_frame
	if not authority.authority_ready():
		_fail("CharacterBody3D authority bridge did not finish building")
		return

	var physics_snapshot: Dictionary = authority.debug_snapshot()
	if int(physics_snapshot.get("character_bodies", 0)) != 19:
		_fail("authority must expose one player plus 18 enemy CharacterBody3D bodies")
		return
	if int(physics_snapshot.get("static_bounds", 0)) != 4:
		_fail("authority arena must have four StaticBody3D bounds")
		return
	if String(physics_snapshot.get("player_body_type", "")) != "CharacterBody3D":
		_fail("player authority is not a CharacterBody3D")
		return

	var overlap_enemies: Array = [
		{"pos":Vector2(360,520), "type":"goblin", "radius":24.0},
		{"pos":Vector2(360,520), "type":"skeleton", "radius":26.0},
		{"pos":Vector2(410,520), "type":"ghoul", "radius":27.0},
	]
	var report: Dictionary = authority.resolve_frame(1.0 / 60.0, Vector2(0,120), overlap_enemies)
	if not bool(report.get("ready", false)):
		_fail("authority frame did not resolve")
		return
	if String(report.get("mode", "")) != "hybrid_3d_collision_authority":
		_fail("authority mode marker missing")
		return
	if int(report.get("wall_hits", 0)) <= 0:
		_fail("out-of-bounds player target was not corrected by 3D authority")
		return
	if int(report.get("separation_hits", 0)) <= 0:
		_fail("overlapping enemy bodies were not separated in world space")
		return
	var resolved_player: Vector2 = report.get("player_pos", Vector2.ZERO)
	if not Rect2(36,160,648,840).grow(-18.0).has_point(resolved_player):
		_fail("resolved player endpoint escaped gameplay arena")
		return
	var enemy_positions: Array = report.get("enemy_positions", [])
	if enemy_positions.size() != 3:
		_fail("resolved enemy position count is wrong")
		return
	if (enemy_positions[0] as Vector2).distance_to(enemy_positions[1] as Vector2) <= 4.0:
		_fail("enemy separation did not produce distinct authoritative endpoints")
		return

	# Second frame verifies persistent body motion rather than spawn-only clamping.
	overlap_enemies[0]["pos"] = Vector2(374,520)
	overlap_enemies[1]["pos"] = Vector2(372,520)
	var second_report: Dictionary = authority.resolve_frame(1.0 / 60.0, Vector2(365,690), overlap_enemies)
	if int(second_report.get("frame", 0)) < 2:
		_fail("authority frame counter did not advance")
		return

	var world = AuthorityWorld.new()
	world.name = "AuthorityWorldSmoke"
	root.add_child(world)
	await process_frame
	await physics_frame
	world.set_active(true)
	if not world.gameplay_authority_ready():
		_fail("v1.50 chamber authority integration is not ready")
		return
	var world_report: Dictionary = world.resolve_gameplay_authority(
		1.0 / 60.0,
		Vector2(360,610),
		[
			{"pos":Vector2(300,420), "type":"goblin", "radius":23.0},
			{"pos":Vector2(301,420), "type":"skeleton", "radius":25.0},
			{"pos":Vector2(455,445), "type":"warden", "boss_variant":"warden", "radius":35.0, "elite":true},
		]
	)
	if not bool(world_report.get("ready", false)):
		_fail("v1.50 chamber did not return an authority report")
		return
	world.sync_runtime(
		world_report.get("player_pos", Vector2(360,610)),
		[
			{"pos":Vector2(300,420), "type":"goblin", "radius":23.0, "attack_cd":0.05, "phase":0.1},
			{"pos":Vector2(330,420), "type":"skeleton", "radius":25.0, "attack_cd":0.05, "phase":0.2},
			{"pos":Vector2(455,445), "type":"warden", "boss_variant":"warden", "radius":35.0, "elite":true, "slam_cd":0.02, "phase":0.8},
		],
		[], [], [], Vector2(0.2,-0.1), 4.0, 0.0, 0.0, 50
	)
	await process_frame
	var world_snapshot: Dictionary = world.debug_snapshot()
	if not bool(world_snapshot.get("gameplay_authority_ready", false)):
		_fail("v1.50 readiness missing from world debug snapshot")
		return
	if int(world_snapshot.get("authority_impact_pool", 0)) != 10:
		_fail("authority feedback pool size is wrong")
		return
	var nested_physics: Dictionary = world_snapshot.get("authority_physics", {})
	if int(nested_physics.get("character_bodies", 0)) != 19:
		_fail("world authority debug snapshot lost CharacterBody3D capacity")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	await physics_frame
	if not main.has_method("_v63_3d_gameplay_authority_ready"):
		_fail("main scene is not running v1.50")
		return
	if not bool(main.call("_v63_3d_gameplay_authority_ready")):
		_fail("main v1.50 gameplay authority reports not ready")
		return
	var main_snapshot: Dictionary = main.call("_v63_authority_snapshot")
	if String(main_snapshot.get("mode", "")) != "hybrid_3d_collision_authority":
		_fail("main authority snapshot has wrong mode")
		return

	print("v1.50 3D gameplay authority smoke test passed")
	main.queue_free()
	world.queue_free()
	authority.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.50 3D gameplay authority smoke test: %s" % message)
	quit(1)
