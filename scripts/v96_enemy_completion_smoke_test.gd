extends SceneTree

const AcceptedWorld = preload("res://scripts/world3d_chamber_v168_character_completion.gd")
const CandidateWorld = preload("res://scripts/world3d_chamber_v169_enemy_completion.gd")
const MainV93 = preload("res://scripts/main_v93.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if MainV93 == null:
		_fail("main_v93 did not compile")
		return

	var accepted = AcceptedWorld.new()
	root.add_child(accepted)
	accepted.set_active(true)
	for _i in range(8):
		await process_frame
	if not bool(accepted.call("production_character_completion_ready")):
		_fail("accepted v1.68 r1.1 world is not ready")
		return
	var accepted_camera_position: Vector3 = accepted.camera_base_position
	var accepted_camera_focus: Vector3 = accepted.camera_focus
	var accepted_camera_size: float = accepted.camera_base_size
	accepted.queue_free()
	await process_frame

	var world = CandidateWorld.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame

	if not bool(world.call("production_enemy_completion_ready")):
		_fail("v1.69 enemy completion pipeline is not ready")
		return
	if not bool(world.call("production_character_completion_ready")):
		_fail("accepted v1.68 Wanderer was not preserved")
		return
	if not _vec3_close(world.camera_base_position, accepted_camera_position):
		_fail("v1.69 changed accepted camera position")
		return
	if not _vec3_close(world.camera_focus, accepted_camera_focus):
		_fail("v1.69 changed accepted camera focus")
		return
	if absf(float(world.camera_base_size) - accepted_camera_size) > 0.001:
		_fail("v1.69 changed accepted orthographic camera size")
		return
	if String(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")) != "gl_compatibility":
		_fail("renderer moved away from GL Compatibility")
		return

	var enemies: Array = [
		{"type":"goblin", "pos":Vector2(175.0, 405.0), "radius":24.0, "phase":0.10, "attack_cd":1.3},
		{"type":"bat", "pos":Vector2(255.0, 345.0), "radius":23.0, "phase":0.20, "attack_cd":1.2},
		{"type":"skeleton", "pos":Vector2(335.0, 410.0), "radius":25.0, "phase":0.30, "attack_cd":1.2},
		{"type":"ghoul", "pos":Vector2(415.0, 345.0), "radius":26.0, "phase":0.40, "attack_cd":1.1},
		{"type":"necromancer", "pos":Vector2(500.0, 415.0), "radius":27.0, "phase":0.50, "attack_cd":1.1},
		{"type":"warden", "pos":Vector2(360.0, 285.0), "radius":32.0, "phase":0.60, "elite":true, "attack_cd":1.4, "cast_kind":"fan", "phase2":false},
	]
	world.sync_runtime(Vector2(360.0, 700.0), enemies, [], [], [], Vector2.ZERO, 70.0, 0.0, 0.0, 30)
	world.sync_runtime(Vector2(360.0, 700.0), enemies, [], [], [], Vector2.ZERO, 70.06, 0.0, 0.0, 30)
	await process_frame

	if world.enemy_pool.size() < enemies.size():
		_fail("enemy pool did not expose all six v1.69 archetypes")
		return
	for index in range(enemies.size()):
		var enemy_root := world.enemy_pool[index] as Node3D
		var kind := String(enemies[index].get("type", ""))
		if enemy_root == null or not bool(world.actor_factory.call("enemy_completion_v169_ready", enemy_root)):
			_fail("v1.69 enemy readiness failed for %s" % kind)
			return
		var layer := enemy_root.get_node_or_null("Motion/Visual/EnemyPresentationV160") as Node3D
		var legacy_form := layer.get_node_or_null("CharacterFormV166") as Node3D if layer != null else null
		var completion := layer.get_node_or_null("EnemyCompletionV169") as MeshInstance3D if layer != null else null
		if kind == "skeleton":
			if completion != null:
				_fail("Skeleton geometry lock was violated")
				return
		else:
			if completion == null or completion.mesh == null:
				_fail("missing authored v1.69 OBJ layer for %s" % kind)
				return
			if legacy_form != null and legacy_form.visible:
				_fail("legacy v1.66 BoxMesh layer still visible for %s" % kind)
				return
			if _contains_authority_node(completion):
				_fail("v1.69 introduced collision/navigation authority for %s" % kind)
				return

	if not bool(world.actor_factory.call("wanderer_completion_v168_ready", world.player_root)):
		_fail("accepted v1.68 r1.1 Wanderer readiness failed")
		return

	print("v1.69 enemy and boss visual completion smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _contains_authority_node(node: Node) -> bool:
	if node is CollisionShape3D or node is CollisionObject3D or node is NavigationRegion3D:
		return true
	for child_value in node.get_children():
		if _contains_authority_node(child_value as Node):
			return true
	return false

func _vec3_close(a: Vector3, b: Vector3) -> bool:
	return a.distance_to(b) < 0.001

func _fail(message: String) -> void:
	push_error("V169_ENEMY_COMPLETION_FAIL:%s" % message)
	quit(1)
