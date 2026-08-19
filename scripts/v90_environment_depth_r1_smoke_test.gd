extends SceneTree

const AcceptedWorld = preload("res://scripts/world3d_chamber_v164_character_lighting.gd")
const CandidateWorld = preload("res://scripts/world3d_chamber_v165_environment_depth.gd")
const MainV86 = preload("res://scripts/main_v86.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if MainV86 == null:
		_fail("main_v86 did not compile")
		return

	var accepted = AcceptedWorld.new()
	root.add_child(accepted)
	accepted.set_active(true)
	for _i in range(8):
		await process_frame
	if not bool(accepted.call("production_character_lighting_ready")):
		_fail("accepted v1.64 r1.1 parent is not ready")
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

	if not bool(world.call("production_environment_depth_ready")):
		_fail("v1.65 environment depth r1 world is not ready")
		return
	if not bool(world.call("production_character_lighting_ready")):
		_fail("accepted v1.64 character lighting was not preserved")
		return
	if int(world.v165_surface_instances) < 50:
		_fail("expected at least 50 environment surface instances")
		return
	if int(world.v165_depth_details) < 50:
		_fail("expected at least 50 low-profile environment details")
		return
	if not _vec3_close(world.camera_base_position, accepted_camera_position):
		_fail("v1.65 changed accepted camera position")
		return
	if not _vec3_close(world.camera_focus, accepted_camera_focus):
		_fail("v1.65 changed accepted camera focus")
		return
	if absf(float(world.camera_base_size) - accepted_camera_size) > 0.001:
		_fail("v1.65 changed accepted orthographic camera size")
		return
	if String(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")) != "gl_compatibility":
		_fail("renderer moved away from GL Compatibility")
		return

	var lower_floor := _find_named_mesh(world.authored_realm_roots.get("lower_halls") as Node, "LowerFlagstone")
	var rift_floor := _find_named_mesh(world.authored_realm_roots.get("rift_descent") as Node, "RiftBrokenSlab")
	var iron_floor := _find_named_mesh(world.authored_realm_roots.get("iron_bastion") as Node, "IronDeckPlate")
	if not _uses_v165_shader(lower_floor) or not _uses_v165_shader(rift_floor) or not _uses_v165_shader(iron_floor):
		_fail("realm floor slabs are not using the v1.65 environment shader")
		return

	for key_value in ["lower_halls", "ossuary", "iron_bastion", "rift_descent", "starless_spire"]:
		var realm_root := world.authored_realm_roots.get(String(key_value)) as Node
		if realm_root == null:
			_fail("missing authored realm root: %s" % String(key_value))
			return
		if _contains_v165_collision(realm_root):
			_fail("v1.65 dressing introduced collision/navigation authority in %s" % String(key_value))
			return

	for floor_no in [6, 16, 30, 36, 46]:
		world.sync_runtime(Vector2(360.0, 700.0), [], [], [], [], Vector2.ZERO, 80.0 + float(floor_no), 0.0, 0.0, floor_no)
		await process_frame
		if not bool(world.call("production_environment_depth_ready")):
			_fail("v1.65 readiness failed after realm switch %d" % floor_no)
			return

	print("v1.65 environment surface and depth r1 smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _find_named_mesh(node: Node, prefix: String) -> MeshInstance3D:
	if node == null:
		return null
	var mesh := node as MeshInstance3D
	if mesh != null and String(mesh.name).begins_with(prefix):
		return mesh
	for child_value in node.get_children():
		var found := _find_named_mesh(child_value as Node, prefix)
		if found != null:
			return found
	return null

func _uses_v165_shader(mesh: MeshInstance3D) -> bool:
	if mesh == null:
		return false
	var material := mesh.material_override as ShaderMaterial
	if material == null or material.shader == null:
		return false
	return material.shader.resource_path == "res://assets/shaders/v165_environment_surface.gdshader"

func _contains_v165_collision(node: Node) -> bool:
	if node == null:
		return false
	if String(node.name).begins_with("V165") and (node is CollisionShape3D or node is CollisionObject3D or node is NavigationRegion3D):
		return true
	for child_value in node.get_children():
		if _contains_v165_collision(child_value as Node):
			return true
	return false

func _vec3_close(a: Vector3, b: Vector3) -> bool:
	return a.distance_to(b) < 0.001

func _fail(message: String) -> void:
	push_error("V165_ENVIRONMENT_DEPTH_R1_FAIL:%s" % message)
	quit(1)
