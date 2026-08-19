extends SceneTree

const WorldV161 = preload("res://scripts/world3d_chamber_v161_combat_presentation.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = WorldV161.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame

	if not bool(world.call("production_combat_presentation_ready")):
		_fail("v1.61 combat presentation did not become ready")
		return
	if not bool(world.call("production_atmosphere_ready")):
		_fail("v1.60 atmosphere regression under v1.61")
		return
	if not bool(world.call("production_combat_vfx_ready")):
		_fail("v1.60 combat VFX regression under v1.61")
		return
	if not bool(world.call("production_actor_presentation_ready")):
		_fail("v1.60 actor regression under v1.61")
		return

	var snapshot: Dictionary = world.debug_snapshot()
	if String(snapshot.get("combat_presentation_v161_version", "")) != "1.61-combat-presentation-r2":
		_fail("v1.61 presentation marker missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_attack_ribbon", false)):
		_fail("v1.61 attack ribbon missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_skill_wave", false)):
		_fail("v1.61 skill wave missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_segmented_tells", false)):
		_fail("v1.61 segmented enemy tells missing")
		return
	if not bool(snapshot.get("combat_presentation_v161_impact_bursts", false)):
		_fail("v1.61 impact-burst geometry missing")
		return

	var enemies := [
		{"type":"goblin", "pos":Vector2(255.0, 445.0), "radius":23.0, "phase":0.2, "attack_cd":0.09},
		{"type":"skeleton", "pos":Vector2(465.0, 445.0), "radius":25.0, "phase":0.8, "attack_cd":0.12},
		{"type":"warden", "pos":Vector2(360.0, 345.0), "radius":31.0, "phase":1.1, "slam_cd":0.08},
	]
	var player_pos := Vector2(360.0, 665.0)

	world.attack_amount = 1.0
	world.skill_amount = 0.0
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 3.0, 1.0, 0.0, 1)
	await process_frame
	if world.v161_attack_trail == null or not world.v161_attack_trail.visible or not (world.v161_attack_trail.mesh is ArrayMesh):
		_fail("v1.61 blade trail did not activate")
		return
	if world.v161_attack_hot_edge == null or not world.v161_attack_hot_edge.visible:
		_fail("v1.61 hot blade edge did not activate")
		return
	if world.v161_attack_contact == null or not world.v161_attack_contact.visible:
		_fail("v1.61 ground contact did not activate")
		return
	if (world.v160_attack_arc != null and world.v160_attack_arc.visible) or (world.v160_attack_edge != null and world.v160_attack_edge.visible):
		_fail("v1.60 flat attack fan remained visible under v1.61")
		return

	world.attack_amount = 0.0
	world.skill_amount = 1.0
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 3.15, 0.0, 1.0, 1)
	await process_frame
	if world.v161_skill_wave_outer == null or not world.v161_skill_wave_outer.visible:
		_fail("v1.61 outer skill wave did not activate")
		return
	if world.v161_skill_wave_inner == null or not world.v161_skill_wave_inner.visible:
		_fail("v1.61 inner skill wave did not activate")
		return
	if world.v161_skill_runes == null or not world.v161_skill_runes.visible:
		_fail("v1.61 skill runes did not activate")
		return
	if world.v160_skill_outer_ring != null and world.v160_skill_outer_ring.visible:
		_fail("v1.60 neon skill torus remained visible under v1.61")
		return
	if world.player_chest_sigil != null and world.player_chest_sigil.visible:
		_fail("legacy chest-sigil ground ring remained visible under v1.61")
		return
	if world.player_skill_crown != null and world.player_skill_crown.visible:
		_fail("legacy box-spike skill crown remained visible under v1.61")
		return

	world.attack_amount = 0.0
	world.skill_amount = 0.0
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 3.30, 0.0, 0.0, 1)
	await process_frame
	if world.telegraph_pool.is_empty():
		_fail("enemy telegraph pool missing")
		return
	var primary_tell := world.telegraph_pool[0] as MeshInstance3D
	if primary_tell == null or not (primary_tell.mesh is ArrayMesh):
		_fail("v1.61 primary tell is not segmented planar geometry")
		return
	var warden_slot := world.enemy_vfx_slots[2] as Node3D
	var warden_shock: MeshInstance3D = null
	if warden_slot != null:
		warden_shock = warden_slot.get_node_or_null("Shockwave0") as MeshInstance3D
	if warden_shock == null or not (warden_shock.mesh is ArrayMesh):
		_fail("v1.61 Warden shock is not segmented planar geometry")
		return

	if world.impact_pool.is_empty() or not ((world.impact_pool[0] as MeshInstance3D).mesh is ArrayMesh):
		_fail("legacy projectile impact was not upgraded to v1.61 burst geometry")
		return
	if world.combat_authority_impact_pool.is_empty():
		_fail("combat-authority impact pool missing")
		return
	var combat_impact_root := world.combat_authority_impact_pool[0] as Node3D
	var combat_impact_mesh := combat_impact_root.get_node_or_null("ImpactRing") as MeshInstance3D
	if combat_impact_mesh == null or not (combat_impact_mesh.mesh is ArrayMesh):
		_fail("combat-authority impact ring was not upgraded to burst geometry")
		return
	world.camera_kick = 0.0
	world.call("_spawn_combat_authority_impact", Vector3.ZERO, world.player_hit_material, true)
	if world.camera_kick < 0.20:
		_fail("critical impact did not add restrained camera response")
		return

	print("v1.61 combat presentation smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V75_COMBAT_PRESENTATION_FAIL:%s" % message)
	quit(1)
