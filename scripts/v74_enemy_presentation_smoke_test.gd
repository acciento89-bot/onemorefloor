extends SceneTree

const WorldV160Actors = preload("res://scripts/world3d_chamber_v160_actors.gd")
const ENEMY_KINDS := ["goblin", "bat", "skeleton", "ghoul", "necromancer", "warden"]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = WorldV160Actors.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame

	if not bool(world.call("production_actor_presentation_ready")):
		_fail("v1.60 actor presentation stack is not ready")
		return
	if not world.actor_factory.has_method("v160_enemy_presentation_ready"):
		_fail("v1.60 enemy presentation API missing")
		return
	if world.enemy_pool.size() < ENEMY_KINDS.size():
		_fail("enemy pool is too small for six-archetype gate")
		return

	for index in range(ENEMY_KINDS.size()):
		var kind := String(ENEMY_KINDS[index])
		var enemy := world.enemy_pool[index] as Node3D
		if enemy == null:
			_fail("enemy shell %s missing" % index)
			return
		world.actor_factory.configure_enemy(enemy, kind, world.actor_materials)
		enemy.visible = true
		if not bool(world.actor_factory.call("v160_enemy_presentation_ready", enemy)):
			_fail("v1.60 enemy presentation not ready for %s" % kind)
			return
		var snapshot: Dictionary = world.actor_factory.call("v160_enemy_presentation_snapshot", enemy)
		if String(snapshot.get("kind", "")) != kind or int(snapshot.get("mesh_count", 0)) < 7:
			_fail("enemy snapshot incomplete for %s: %s" % [kind, JSON.stringify(snapshot)])
			return
		var layer := enemy.get_node_or_null("Motion/Visual/EnemyPresentationV160") as Node3D
		var legacy := enemy.get_node_or_null("Motion/Visual/PresentationV153") as Node3D
		if layer == null or not layer.visible:
			_fail("production enemy layer missing for %s" % kind)
			return
		if legacy == null or legacy.visible:
			_fail("legacy v1.53 enemy surface is still visible for %s" % kind)
			return
		if not bool(world.actor_factory.call("visual_presentation_ready", enemy)):
			_fail("v1.53 presentation contract regressed for %s" % kind)
			return
		world.actor_factory.animate_enemy(enemy, 1.25, 0.35, 0.72, 0.0, index)
		if layer.get_child_count() < 7:
			_fail("enemy geometry disappeared after animation for %s" % kind)
			return

	# Reconfigure one shell to prove repeated runtime kind changes replace the
	# layer cleanly instead of stacking duplicate presentation geometry.
	var recycle := world.enemy_pool[0] as Node3D
	world.actor_factory.configure_enemy(recycle, "warden", world.actor_materials)
	if not bool(world.actor_factory.call("v160_enemy_presentation_ready", recycle)):
		_fail("enemy layer did not survive shell reuse")
		return
	var recycled_layer := recycle.get_node_or_null("Motion/Visual/EnemyPresentationV160") as Node3D
	if recycled_layer == null or String(recycled_layer.get_meta("kind", "")) != "warden":
		_fail("enemy shell reuse retained stale archetype")
		return

	var final_snapshot: Dictionary = world.debug_snapshot()
	if not bool(final_snapshot.get("production_actor_presentation_ready", false)):
		_fail("Wanderer regression under enemy presentation layer")
		return
	if not bool(final_snapshot.get("production_material_depth_ready", false)):
		_fail("material-depth regression under enemy presentation layer")
		return
	if not bool(final_snapshot.get("real_model_intake_v154_ready", false)):
		_fail("v1.54 real-model regression under enemy presentation layer")
		return

	print("v1.60 production enemy silhouette smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V74_ENEMY_PRESENTATION_FAIL:%s" % message)
	quit(1)
