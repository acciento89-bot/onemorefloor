extends SceneTree

const ProductionArtWorld = preload("res://scripts/world3d_chamber_v149.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = ProductionArtWorld.new()
	world.name = "ProductionArtLookdevSmokeWorld"
	root.add_child(world)
	await process_frame
	world.set_active(true)

	if not world.production_art_lookdev_ready():
		_fail("production art/lookdev world did not finish building")
		return

	var enemies: Array = [
		{"pos":Vector2(245,390), "type":"goblin", "radius":23.0, "elite":true, "attack_cd":0.05, "phase":0.1, "v47_hit_stamp":4.94},
		{"pos":Vector2(325,350), "type":"bat", "radius":21.0, "dive_cd":0.04, "phase":0.4},
		{"pos":Vector2(405,385), "type":"skeleton", "radius":25.0, "attack_cd":0.06, "phase":0.8},
		{"pos":Vector2(270,500), "type":"ghoul", "radius":26.0, "lunge_cd":0.05, "phase":1.1},
		{"pos":Vector2(370,490), "type":"necromancer", "radius":28.0, "summon_cd":0.03, "phase":1.4},
		{"pos":Vector2(455,445), "type":"warden", "boss_variant":"warden", "radius":35.0, "elite":true, "slam_cd":0.02, "phase":1.8, "v47_hit_stamp":4.94},
	]
	world.sync_runtime(
		Vector2(360,610), enemies,
		[{"pos":Vector2(392,545), "crit":true}],
		[{"pos":Vector2(430,490), "color":Color("a568ff")}],
		[], Vector2(0.65,-0.25), 5.0, 1.0, 1.0, 50
	)
	await process_frame

	var snapshot: Dictionary = world.debug_snapshot()
	if not bool(snapshot.get("production_art_lookdev_ready", false)):
		_fail("v1.49 readiness missing from debug snapshot")
		return
	if int(snapshot.get("grounding_slots", 0)) != 18:
		_fail("enemy grounding pool size is wrong")
		return
	if int(snapshot.get("hit_burst_pool", 0)) != 14:
		_fail("hit burst pool size is wrong")
		return
	if int(snapshot.get("move_echo_pool", 0)) != 6:
		_fail("move echo pool size is wrong")
		return
	if String(snapshot.get("lookdev_realm", "")) != "starless_spire":
		_fail("floor 50 did not select starless-spire lookdev")
		return

	var quality: Dictionary = snapshot.get("asset_quality", {})
	if int(quality.get("profiles", 0)) != 7:
		_fail("asset quality gate does not expose seven actor profiles")
		return
	var player_report: Dictionary = snapshot.get("player_asset_report", {})
	if String(player_report.get("source", "")) != "native_fallback":
		_fail("player asset report should truthfully identify native fallback without GLB")
		return
	if not bool(player_report.get("ready", false)):
		_fail("native production fallback should remain fail-safe ready")
		return

	var hero_art := world.get_node_or_null("Wanderer3D/Motion/ProductionArtV149") as Node3D
	if hero_art == null:
		_fail("Wanderer v1.49 production art layer is missing")
		return
	if hero_art.get_node_or_null("Breastplate") == null or hero_art.get_node_or_null("HeroEmblem") == null:
		_fail("Wanderer armor/emblem production pieces are missing")
		return

	var goblin_art := world.get_node_or_null("Enemy00/Motion/Visual/ProductionArtV149") as Node3D
	if goblin_art == null:
		# Enemy pool naming is allowed to differ; validate through the pool instead.
		var enemy_pool: Array = world.enemy_pool
		if enemy_pool.is_empty():
			_fail("enemy pool missing")
			return
		var first_enemy := enemy_pool[0] as Node3D
		goblin_art = first_enemy.get_node_or_null("Motion/Visual/ProductionArtV149") as Node3D
	if goblin_art == null or goblin_art.get_node_or_null("BrowPlate") == null:
		_fail("goblin v1.49 authored fallback details are missing")
		return

	var rim := world.get_node_or_null("ProductionArtLookdev/WandererRim") as OmniLight3D
	var fill := world.get_node_or_null("ProductionArtLookdev/WandererFill") as OmniLight3D
	if rim == null or fill == null or rim.light_energy <= 0.0:
		_fail("Wanderer lookdev light rig is missing")
		return

	var grounding := world.get_node_or_null("ProductionArtLookdev/ActorGrounding/EnemyGround00") as MeshInstance3D
	if grounding == null or not grounding.visible:
		_fail("elite enemy grounding ring did not activate")
		return

	var hit_root := world.get_node_or_null("ProductionArtLookdev/ActorHitShards") as Node3D
	var hit_visible := false
	if hit_root != null:
		for child_value in hit_root.get_children():
			var child := child_value as Node3D
			if child != null and child.visible:
				hit_visible = true
				break
	if not hit_visible:
		_fail("archetype hit shard burst did not activate")
		return

	var boss_root := world.get_node_or_null("ProductionArtLookdev/BossDominanceLookdev") as Node3D
	if boss_root == null or not boss_root.visible:
		_fail("floor-50 Warden dominance layer did not activate")
		return

	# Exercise all five realm lookdev identities without changing gameplay state.
	for floor_no in [5, 15, 25, 35, 45]:
		world.sync_runtime(Vector2(360,610), [], [], [], [], Vector2.ZERO, 6.0 + float(floor_no), 0.0, 0.0, floor_no)
		await process_frame
	var after_realms: Dictionary = world.debug_snapshot()
	if String(after_realms.get("lookdev_realm", "")) != "starless_spire":
		_fail("realm lookdev switching did not end on starless spire")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	if not main.has_method("_v62_production_art_lookdev_ready"):
		_fail("main scene is not running v1.49")
		return
	if not bool(main.call("_v62_production_art_lookdev_ready")):
		_fail("main v1.49 production art/lookdev reports not ready")
		return

	print("v1.49 production art/lookdev smoke test passed")
	main.queue_free()
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.49 production art/lookdev smoke test: %s" % message)
	quit(1)
