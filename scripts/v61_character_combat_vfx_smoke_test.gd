extends SceneTree

const CharacterCombatWorld = preload("res://scripts/world3d_chamber_v148.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = CharacterCombatWorld.new()
	world.name = "CharacterCombatVFXSmokeWorld"
	root.add_child(world)
	await process_frame
	world.set_active(true)

	if not world.character_combat_vfx_ready():
		_fail("character combat VFX world did not finish building")
		return

	var enemies: Array = [
		{"pos":Vector2(245,390), "type":"goblin", "radius":23.0, "attack_cd":0.05, "phase":0.1},
		{"pos":Vector2(325,350), "type":"bat", "radius":21.0, "dive_cd":0.04, "phase":0.4},
		{"pos":Vector2(405,385), "type":"skeleton", "radius":25.0, "attack_cd":0.06, "phase":0.8},
		{"pos":Vector2(270,500), "type":"ghoul", "radius":26.0, "lunge_cd":0.05, "phase":1.1},
		{"pos":Vector2(370,490), "type":"necromancer", "radius":28.0, "summon_cd":0.03, "phase":1.4},
		{"pos":Vector2(455,445), "type":"warden", "boss_variant":"warden", "radius":35.0, "elite":true, "slam_cd":0.02, "phase":1.8, "v47_hit_stamp":2.94},
	]
	world.sync_runtime(
		Vector2(360,610), enemies,
		[{"pos":Vector2(392,545), "crit":true}],
		[{"pos":Vector2(430,490), "color":Color("a568ff")}],
		[], Vector2(0.45,-0.25), 3.0, 1.0, 1.0, 50
	)
	await process_frame

	var snapshot: Dictionary = world.debug_snapshot()
	if not bool(snapshot.get("character_combat_vfx_ready", false)):
		_fail("v1.48 readiness missing from debug snapshot")
		return
	if int(snapshot.get("enemy_combat_vfx_slots", 0)) != 18:
		_fail("enemy combat VFX pool size is wrong")
		return
	if int(snapshot.get("spawn_signature_pool", 0)) != 12 or int(snapshot.get("death_signature_pool", 0)) != 12:
		_fail("spawn/death signature pools are wrong")
		return

	var goblin_arc := world.get_node_or_null("CharacterCombatVFX/EnemyArchetypeVFX/EnemyVFX00/WeaponArc") as MeshInstance3D
	if goblin_arc == null or not goblin_arc.visible:
		_fail("goblin weapon-socket attack arc did not activate")
		return
	var bat_rune := world.get_node_or_null("CharacterCombatVFX/EnemyArchetypeVFX/EnemyVFX01/HeadRune") as MeshInstance3D
	if bat_rune == null or not bat_rune.visible:
		_fail("bat head-socket attack rune did not activate")
		return
	var necro_orb := world.get_node_or_null("CharacterCombatVFX/EnemyArchetypeVFX/EnemyVFX04/OrbitOrb0") as MeshInstance3D
	if necro_orb == null or not necro_orb.visible:
		_fail("necromancer orbiting spell focus did not activate")
		return
	var warden_wave := world.get_node_or_null("CharacterCombatVFX/EnemyArchetypeVFX/EnemyVFX05/Shockwave0") as MeshInstance3D
	if warden_wave == null or not warden_wave.visible:
		_fail("warden multi-wave telegraph did not activate")
		return

	var player_flare := world.get_node_or_null("CharacterCombatVFX/WandererSocketVFX/WeaponFlare") as MeshInstance3D
	var skill_crown := world.get_node_or_null("CharacterCombatVFX/WandererSocketVFX/SkillCrown") as Node3D
	if player_flare == null or not player_flare.visible:
		_fail("Wanderer weapon socket flare did not activate")
		return
	if skill_crown == null or not skill_crown.visible:
		_fail("Wanderer skill crown did not activate")
		return

	var spawn_root := world.get_node_or_null("CharacterCombatVFX/SpawnDeathSignatures") as Node3D
	var spawn_visible := false
	if spawn_root != null:
		for child_value in spawn_root.get_children():
			var child := child_value as Node3D
			if child != null and child.name.begins_with("SpawnSignature") and child.visible:
				spawn_visible = true
				break
	if not spawn_visible:
		_fail("archetype spawn signature did not activate")
		return

	# Removing the warden must emit a separate archetype-colored death signature.
	var reduced: Array = enemies.duplicate()
	reduced.pop_back()
	world.sync_runtime(
		Vector2(360,610), reduced, [], [], [], Vector2.ZERO,
		3.12, 0.0, 0.0, 50
	)
	await process_frame
	var death_visible := false
	if spawn_root != null:
		for child_value in spawn_root.get_children():
			var child := child_value as Node3D
			if child != null and child.name.begins_with("DeathSignature") and child.visible:
				death_visible = true
				break
	if not death_visible:
		_fail("archetype death signature did not activate")
		return

	var scene := load("res://scenes/main.tscn") as PackedScene
	if scene == null:
		_fail("main scene failed to load")
		return
	var main = scene.instantiate()
	root.add_child(main)
	await process_frame
	if not main.has_method("_v61_character_combat_vfx_ready"):
		_fail("main scene is not running v1.48")
		return
	if not bool(main.call("_v61_character_combat_vfx_ready")):
		_fail("main v1.48 character combat VFX reports not ready")
		return

	print("v1.48 character combat VFX smoke test passed")
	main.queue_free()
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("v1.48 character combat VFX smoke test: %s" % message)
	quit(1)
