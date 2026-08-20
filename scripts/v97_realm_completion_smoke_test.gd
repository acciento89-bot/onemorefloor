extends SceneTree

const AcceptedWorld = preload("res://scripts/world3d_chamber_v169_enemy_completion.gd")
const CandidateWorld = preload("res://scripts/world3d_chamber_v170_realm_completion.gd")
const MainV94 = preload("res://scripts/main_v94.gd")
const REALMS := ["lower_halls", "ossuary", "iron_bastion", "rift_descent", "starless_spire"]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if MainV94 == null:
		_fail("main_v94 did not compile")
		return

	var accepted = AcceptedWorld.new()
	root.add_child(accepted)
	accepted.set_active(true)
	for _i in range(8):
		await process_frame
	if not bool(accepted.call("production_enemy_completion_ready")):
		_fail("accepted v1.69 world is not ready")
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

	if not bool(world.call("production_realm_completion_ready")):
		_fail("v1.70 realm completion pipeline is not ready")
		return
	if not bool(world.call("production_enemy_completion_ready")):
		_fail("accepted v1.69 enemy/boss lock was not preserved")
		return
	if not bool(world.call("production_character_completion_ready")):
		_fail("accepted v1.68 Wanderer lock was not preserved")
		return
	if not bool(world.call("production_environment_depth_ready")):
		_fail("accepted v1.65 environment depth was not preserved")
		return
	if not _vec3_close(world.camera_base_position, accepted_camera_position):
		_fail("v1.70 changed accepted camera position")
		return
	if not _vec3_close(world.camera_focus, accepted_camera_focus):
		_fail("v1.70 changed accepted camera focus")
		return
	if absf(float(world.camera_base_size) - accepted_camera_size) > 0.001:
		_fail("v1.70 changed accepted orthographic camera size")
		return
	if String(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")) != "gl_compatibility":
		_fail("renderer moved away from GL Compatibility")
		return

	if world.v170_instances.size() != REALMS.size():
		_fail("v1.70 did not mount exactly five realm kits")
		return
	for realm_value in REALMS:
		var realm := String(realm_value)
		var instance := world.v170_instances.get(realm) as MeshInstance3D
		if instance == null or instance.mesh == null:
			_fail("missing authored v1.70 realm mesh for %s" % realm)
			return
		if _contains_authority_node(instance):
			_fail("v1.70 introduced collision/navigation authority in %s" % realm)
			return
		if not bool(instance.get_meta("visual_only", false)):
			_fail("v1.70 realm mesh lost visual-only contract for %s" % realm)
			return

	# Re-prove the accepted character locks while the new world layer is active.
	var enemies: Array = [
		{"type":"goblin", "pos":Vector2(215.0, 405.0), "radius":24.0, "phase":0.10, "attack_cd":1.3},
		{"type":"skeleton", "pos":Vector2(315.0, 360.0), "radius":25.0, "phase":0.30, "attack_cd":1.2},
		{"type":"necromancer", "pos":Vector2(490.0, 410.0), "radius":27.0, "phase":0.50, "attack_cd":1.1},
		{"type":"warden", "pos":Vector2(360.0, 285.0), "radius":32.0, "phase":0.60, "elite":true, "attack_cd":1.4, "cast_kind":"fan", "phase2":false},
	]
	world.sync_runtime(Vector2(360.0, 700.0), enemies, [], [], [], Vector2.ZERO, 80.0, 0.0, 0.0, 30)
	world.sync_runtime(Vector2(360.0, 700.0), enemies, [], [], [], Vector2.ZERO, 80.06, 0.0, 0.0, 30)
	await process_frame
	for index in range(enemies.size()):
		var enemy_root := world.enemy_pool[index] as Node3D
		if enemy_root == null or not bool(world.actor_factory.call("enemy_completion_v169_ready", enemy_root)):
			_fail("v1.69 enemy lock failed inside v1.70 at index %d" % index)
			return
	if not bool(world.actor_factory.call("wanderer_completion_v168_ready", world.player_root)):
		_fail("v1.68 Wanderer lock failed inside v1.70")
		return

	print("v1.70 realm and endgame visual completion smoke test passed")
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
	push_error("V170_REALM_COMPLETION_FAIL:%s" % message)
	quit(1)
