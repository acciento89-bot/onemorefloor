extends SceneTree

const WorldV160VFX = preload("res://scripts/world3d_chamber_v160_combat_polish.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = WorldV160VFX.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame

	if not bool(world.call("production_combat_vfx_ready")):
		_fail("production combat VFX did not become ready")
		return
	var snapshot: Dictionary = world.debug_snapshot()
	if int(snapshot.get("production_combat_vfx_true_rings", 0)) < int(snapshot.get("production_combat_vfx_static_target", 999)):
		_fail("static true-ring coverage incomplete")
		return
	if int(snapshot.get("production_combat_vfx_static_target", 0)) != 230:
		_fail("production combat VFX static ring target is not 230")
		return
	if not bool(snapshot.get("production_actor_presentation_ready", false)):
		_fail("actor presentation regression under VFX layer")
		return
	if not bool(snapshot.get("character_combat_vfx_ready", false)):
		_fail("v1.48 combat VFX regression")
		return

	# The original Wanderer SkillRing is the final known filled combat disc and
	# must be captured as ring #230 while remaining visually suppressed in v1.60.
	var legacy_player_skill := world.player_root.get_node_or_null("SkillRing") as MeshInstance3D
	if not _is_torus(legacy_player_skill):
		_fail("base Wanderer SkillRing was not upgraded to true ring geometry")
		return

	# v1.46 legacy presentation discs must now be hollow combat rings.
	if world.telegraph_pool.is_empty() or not _is_torus(world.telegraph_pool[0] as MeshInstance3D):
		_fail("v1.46 ground telegraph was not upgraded")
		return
	var death_root := world.death_burst_pool[0] as Node3D
	if death_root == null or not _is_torus(death_root.get_node_or_null("Ring") as MeshInstance3D):
		_fail("v1.46 death ring was not upgraded")
		return
	var loot_root := world.loot_marker_pool[0] as Node3D
	if loot_root == null or not _is_torus(loot_root.get_node_or_null("FloorGlow") as MeshInstance3D):
		_fail("v1.46 loot floor glow was not upgraded")
		return
	if not _is_torus(world.boss_halo) or not _is_torus(world.attack_ring) or not _is_torus(world.skill_ring_outer) or not _is_torus(world.skill_ring_inner):
		_fail("v1.46 boss/player pulse geometry was not upgraded")
		return

	# Existing v1.41/v1.48 rings remain covered.
	if world.player_chest_sigil == null or not _is_torus(world.player_chest_sigil):
		_fail("player skill sigil is not true torus geometry")
		return
	if world.impact_pool.is_empty() or not _is_torus(world.impact_pool[0] as MeshInstance3D):
		_fail("v1.41 impact ring was not upgraded")
		return
	if world.enemy_vfx_slots.is_empty():
		_fail("v1.48 enemy VFX slots missing")
		return
	var slot := world.enemy_vfx_slots[0] as Node3D
	var head_rune := slot.get_node_or_null("HeadRune") as MeshInstance3D
	var shock := slot.get_node_or_null("Shockwave0") as MeshInstance3D
	if not _is_torus(head_rune) or not _is_torus(shock):
		_fail("enemy head/shock rings were not upgraded")
		return
	var spawn_root := world.spawn_signature_pool[0] as Node3D
	var spawn_ring := spawn_root.get_node_or_null("Ring") as MeshInstance3D
	if not _is_torus(spawn_ring):
		_fail("spawn signature ring was not upgraded")
		return

	# v1.49-v1.52 presentation/authority rings must also be hollow.
	if world.enemy_grounding_pool.is_empty() or not _is_torus(world.enemy_grounding_pool[0] as MeshInstance3D):
		_fail("v1.49 enemy grounding ring was not upgraded")
		return
	if not _is_torus(world.boss_dominance_ring_outer) or not _is_torus(world.boss_dominance_ring_inner):
		_fail("v1.49 boss dominance rings were not upgraded")
		return
	var authority_root := world.authority_impact_pool[0] as Node3D
	if authority_root == null or not _is_torus(authority_root.get_node_or_null("Ring") as MeshInstance3D):
		_fail("v1.50 authority ring was not upgraded")
		return
	var combat_root := world.combat_authority_impact_pool[0] as Node3D
	if combat_root == null or not _is_torus(combat_root.get_node_or_null("ImpactRing") as MeshInstance3D):
		_fail("v1.51 combat authority ring was not upgraded")
		return
	var lock_root := world.target_lock_pool[0] as Node3D
	if lock_root == null or not _is_torus(lock_root.get_node_or_null("LockRing") as MeshInstance3D):
		_fail("v1.52 target lock ring was not upgraded")
		return
	if world.nova_volume_visual == null or not _is_torus(world.nova_volume_visual.get_node_or_null("NovaBoundary") as MeshInstance3D):
		_fail("v1.52 NOVA boundary was not upgraded")
		return
	if world.warden_ring_visual == null or not _is_torus(world.warden_ring_visual.get_node_or_null("ThreatRing") as MeshInstance3D):
		_fail("v1.52 Warden threat ring was not upgraded")
		return

	# Drive a real runtime attack + skill + Warden tell. The legacy runtime owns
	# all timing; v1.60 only changes the visible hierarchy mounted on those states.
	var enemy := {
		"type": "warden",
		"pos": Vector2(360.0, 420.0),
		"radius": 30.0,
		"phase": 0.25,
		"slam_cd": 0.08,
	}
	world.sync_runtime(Vector2(360.0, 650.0), [enemy], [], [], [], Vector2.ZERO, 2.0, 1.0, 1.0, 25)
	await process_frame
	var enemy_root := world.enemy_pool[0] as Node3D
	var tell_ring := enemy_root.get_node_or_null("Motion/Visual/TellRing") as MeshInstance3D
	if not _is_torus(tell_ring):
		_fail("runtime enemy TellRing is not true torus geometry")
		return
	if tell_ring.visible:
		_fail("duplicate attached TellRing remained visible in v1.60 hierarchy")
		return
	var primary_tell := world.telegraph_pool[0] as MeshInstance3D
	if primary_tell == null or not primary_tell.visible:
		_fail("v1.60 primary ground telegraph is not visible")
		return
	var grounding := world.enemy_grounding_pool[0] as MeshInstance3D
	if grounding != null and grounding.visible:
		_fail("duplicate v1.49 grounding remained visible during active tell")
		return
	var shock0 := slot.get_node_or_null("Shockwave0") as MeshInstance3D
	var shock1 := slot.get_node_or_null("Shockwave1") as MeshInstance3D
	var shock2 := slot.get_node_or_null("Shockwave2") as MeshInstance3D
	if shock0 == null or not shock0.visible or (shock1 != null and shock1.visible) or (shock2 != null and shock2.visible):
		_fail("Warden shockwave hierarchy is not one-primary-wave")
		return

	if world.v160_attack_arc == null or not world.v160_attack_arc.visible or not (world.v160_attack_arc.mesh is ArrayMesh):
		_fail("directed v1.60 attack arc did not activate")
		return
	var arc_arrays: Array = (world.v160_attack_arc.mesh as ArrayMesh).surface_get_arrays(0)
	var arc_normals: PackedVector3Array = arc_arrays[Mesh.ARRAY_NORMAL]
	if arc_normals.is_empty() or absf(arc_normals[0].y) <= 0.5:
		_fail("v1.60 attack arc plane normal is invalid")
		return
	var arc_material := world.v160_attack_arc.material_override as StandardMaterial3D
	if arc_material == null or arc_material.cull_mode != BaseMaterial3D.CULL_DISABLED:
		_fail("v1.60 attack arc is not double-sided for isometric view")
		return
	if world.v160_attack_arc.position.y < 0.10 or world.v160_attack_arc.position.y > 0.22 or world.v160_attack_arc.position.z >= -0.05:
		_fail("v1.60 attack arc is not on the forward floor presentation plane")
		return
	if world.v160_attack_edge == null or not world.v160_attack_edge.visible or not (world.v160_attack_edge.mesh is ArrayMesh):
		_fail("v1.60 bright attack edge did not activate")
		return

	if world.v160_skill_outer_ring == null or not world.v160_skill_outer_ring.visible or not _is_torus(world.v160_skill_outer_ring):
		_fail("v1.60 skill outer ring did not activate")
		return
	if world.v160_skill_outer_ring.position.y < 0.10:
		_fail("v1.60 skill ring is not raised above authored floor tiles")
		return
	var polished_skill_mesh := world.v160_skill_outer_ring.mesh as TorusMesh
	if polished_skill_mesh == null or polished_skill_mesh.outer_radius < 1.05:
		_fail("v1.60 skill ring is too small for the player footprint")
		return
	if world.attack_ring.visible or world.skill_ring_outer.visible or world.skill_ring_inner.visible or legacy_player_skill.visible:
		_fail("legacy player pulse duplicates remained visible in v1.60")
		return
	if world.player_chest_sigil == null or not world.player_chest_sigil.visible:
		_fail("v1.48 inner skill sigil was lost during v1.60 hierarchy pass")
		return

	if not bool(world.call("character_combat_vfx_ready")):
		_fail("v1.48 readiness changed after v1.60 runtime drive")
		return
	if not bool(world.call("production_actor_presentation_ready")):
		_fail("v1.60 actor readiness changed after VFX runtime drive")
		return

	print("v1.60 production combat VFX smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _is_torus(node: MeshInstance3D) -> bool:
	return node != null and node.mesh is TorusMesh

func _fail(message: String) -> void:
	push_error("V74_COMBAT_VFX_FAIL:%s" % message)
	quit(1)
