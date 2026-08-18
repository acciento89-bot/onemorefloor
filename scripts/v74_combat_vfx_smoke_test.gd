extends SceneTree

const WorldV160VFX = preload("res://scripts/world3d_chamber_v160_vfx.gd")

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
	if not bool(snapshot.get("production_actor_presentation_ready", false)):
		_fail("actor presentation regression under VFX layer")
		return
	if not bool(snapshot.get("character_combat_vfx", false)):
		_fail("v1.48 combat VFX regression")
		return

	if world.player_chest_sigil == null or not (world.player_chest_sigil.mesh is TorusMesh):
		_fail("player skill sigil is not true torus geometry")
		return
	if world.impact_pool.is_empty() or not ((world.impact_pool[0] as MeshInstance3D).mesh is TorusMesh):
		_fail("v1.41 impact ring was not upgraded")
		return
	if world.enemy_vfx_slots.is_empty():
		_fail("v1.48 enemy VFX slots missing")
		return
	var slot := world.enemy_vfx_slots[0] as Node3D
	var head_rune := slot.get_node_or_null("HeadRune") as MeshInstance3D
	var shock := slot.get_node_or_null("Shockwave0") as MeshInstance3D
	if head_rune == null or not (head_rune.mesh is TorusMesh) or shock == null or not (shock.mesh is TorusMesh):
		_fail("enemy head/shock rings were not upgraded")
		return
	var spawn_root := world.spawn_signature_pool[0] as Node3D
	var spawn_ring := spawn_root.get_node_or_null("Ring") as MeshInstance3D
	if spawn_ring == null or not (spawn_ring.mesh is TorusMesh):
		_fail("spawn signature ring was not upgraded")
		return

	# Drive a real runtime attack + skill + Warden tell. The legacy runtime owns
	# all timing; v1.60 only changes the visible geometry mounted on those states.
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
	if tell_ring == null or not (tell_ring.mesh is TorusMesh):
		_fail("runtime enemy TellRing is not true torus geometry")
		return
	if world.v160_attack_arc == null or not world.v160_attack_arc.visible or not (world.v160_attack_arc.mesh is ArrayMesh):
		_fail("directed v1.60 attack arc did not activate")
		return
	if world.v160_skill_outer_ring == null or not world.v160_skill_outer_ring.visible or not (world.v160_skill_outer_ring.mesh is TorusMesh):
		_fail("v1.60 skill outer ring did not activate")
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

func _fail(message: String) -> void:
	push_error("V74_COMBAT_VFX_FAIL:%s" % message)
	quit(1)
