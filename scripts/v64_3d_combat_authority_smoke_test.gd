extends SceneTree

const ContactAuthority = preload("res://scripts/world3d_gameplay_authority_v151.gd")
const ProjectileAuthority = preload("res://scripts/world3d_projectile_authority_v151.gd")
const CombatWorld = preload("res://scripts/world3d_chamber_v151.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var contact = ContactAuthority.new()
	contact.name = "ContactAuthoritySmoke"
	root.add_child(contact)
	var projectiles = ProjectileAuthority.new()
	projectiles.name = "ProjectileAuthoritySmoke"
	root.add_child(projectiles)
	await process_frame
	await physics_frame

	if not contact.combat_contact_ready():
		_fail("3D contact authority did not build")
		return
	var contact_report: Dictionary = contact.resolve_frame(
		1.0 / 60.0,
		Vector2(360, 520),
		[
			{"pos":Vector2(360,520), "type":"goblin", "radius":24.0},
			{"pos":Vector2(540,520), "type":"skeleton", "radius":26.0},
		]
	)
	if String(contact_report.get("mode", "")) != "hybrid_3d_combat_authority":
		_fail("combat contact mode marker missing")
		return
	var contact_indices: Array = contact_report.get("contact_indices", [])
	if contact_indices.is_empty() or int(contact_indices[0]) != 0:
		_fail("world-space player/enemy contact did not identify the touching enemy")
		return
	if String(contact_report.get("touch_trigger_authority", "")) != "3d_contact":
		_fail("touch trigger is not marked as 3D authoritative")
		return

	if not projectiles.projectile_authority_ready():
		_fail("Area3D projectile pools did not build")
		return
	var projectile_snapshot: Dictionary = projectiles.debug_snapshot()
	if int(projectile_snapshot.get("area3d_total", 0)) != 64:
		_fail("projectile authority must preallocate 64 Area3D nodes")
		return

	var player_result: Dictionary = projectiles.resolve_player_projectiles(
		0.10,
		[
			{"pos":Vector2(250,500), "vel":Vector2(720,0), "damage":33.0, "life":1.0, "crit":true},
		],
		[
			{"pos":Vector2(300,500), "type":"goblin", "radius":24.0},
		]
	)
	if not bool(player_result.get("ready", false)):
		_fail("player projectile authority did not resolve")
		return
	if String(player_result.get("mode", "")) != "3d_sphere_sweep":
		_fail("player projectile mode is not 3D sphere sweep")
		return
	var player_hits: Array = player_result.get("hits", [])
	if player_hits.size() != 1 or int((player_hits[0] as Dictionary).get("enemy_index", -1)) != 0:
		_fail("3D player projectile sweep missed a crossed enemy")
		return
	if not (player_result.get("shots", []) as Array).is_empty():
		_fail("hit player projectile survived authoritative collision")
		return

	var enemy_result: Dictionary = projectiles.resolve_enemy_projectiles(
		0.10,
		[
			{"pos":Vector2(420,700), "vel":Vector2(-720,0), "damage":19.0, "life":1.0},
		],
		Vector2(360,700)
	)
	if (enemy_result.get("hits", []) as Array).size() != 1:
		_fail("3D enemy projectile sweep missed the Wanderer")
		return

	var world = CombatWorld.new()
	world.name = "CombatAuthorityWorldSmoke"
	root.add_child(world)
	await process_frame
	await physics_frame
	world.set_active(true)
	if not world.combat_authority_ready():
		_fail("v1.51 chamber combat authority is not ready")
		return
	var world_contact: Dictionary = world.resolve_gameplay_authority(
		1.0 / 60.0,
		Vector2(360,610),
		[
			{"pos":Vector2(360,610), "type":"ghoul", "radius":27.0},
		]
	)
	if (world_contact.get("contact_indices", []) as Array).is_empty():
		_fail("chamber did not expose 3D contact indices")
		return
	var world_projectile: Dictionary = world.resolve_player_projectiles_3d(
		0.10,
		[
			{"pos":Vector2(250,480), "vel":Vector2(720,0), "damage":40.0, "life":1.0, "crit":false},
		],
		[
			{"pos":Vector2(300,480), "type":"skeleton", "radius":25.0},
		]
	)
	if (world_projectile.get("hits", []) as Array).size() != 1:
		_fail("chamber projectile integration did not return a 3D hit")
		return
	var world_snapshot: Dictionary = world.debug_snapshot()
	if not bool(world_snapshot.get("combat_authority_ready", false)):
		_fail("combat authority readiness missing from chamber snapshot")
		return
	if int(world_snapshot.get("combat_impact_pool", 0)) != 16:
		_fail("combat authority impact pool size is wrong")
		return
	var nested_projectiles: Dictionary = world_snapshot.get("projectile_authority", {})
	if int(nested_projectiles.get("area3d_total", 0)) != 64:
		_fail("chamber lost the Area3D projectile pool")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	await physics_frame
	if not main.has_method("_v64_3d_combat_authority_ready"):
		_fail("main scene is not running v1.51")
		return
	if not bool(main.call("_v64_3d_combat_authority_ready")):
		_fail("main v1.51 combat authority reports not ready")
		return
	var main_snapshot: Dictionary = main.call("_v64_combat_authority_snapshot")
	if String(main_snapshot.get("mode", "")) != "hybrid_3d_combat_authority":
		_fail("main combat authority snapshot has wrong mode")
		return
	if String(main_snapshot.get("touch_trigger", "")) != "3d_contact":
		_fail("main snapshot did not retire legacy touch trigger")
		return
	if String(main_snapshot.get("projectile_mode", "")) != "3d_sphere_sweep":
		_fail("main snapshot did not activate 3D projectile mode")
		return

	print("v1.51 3D combat authority smoke test passed")
	main.queue_free()
	world.queue_free()
	projectiles.queue_free()
	contact.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.51 3D combat authority smoke test: %s" % message)
	quit(1)
