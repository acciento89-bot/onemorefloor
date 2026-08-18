extends SceneTree

const ENEMY_KINDS := ["goblin", "bat", "skeleton", "ghoul", "necromancer", "warden"]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene did not load")
		return

	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame

	if not game.has_method("_v67_visual_presentation_snapshot"):
		_fail("main scene is not running v1.53 visual presentation")
		return
	if not bool(game.call("_v65_3d_combat_core_ready")):
		_fail("v1.52 3D combat authority regressed under v1.53")
		return
	if not bool(game.call("_v67_3d_visual_presentation_ready")):
		_fail("v1.53 visual presentation chamber is not ready")
		return

	var snapshot: Dictionary = game.call("_v67_visual_presentation_snapshot")
	if String(snapshot.get("version", "")) != "1.53.0-3d-visual-presentation":
		_fail("v1.53 version marker is wrong")
		return
	if not bool(snapshot.get("gameplay_authority_ready", false)):
		_fail("v1.52 gameplay authority is not preserved")
		return

	var world_value: Variant = snapshot.get("world", {})
	if not (world_value is Dictionary):
		_fail("v1.53 world snapshot is missing")
		return
	var world_snapshot: Dictionary = world_value
	if not bool(world_snapshot.get("ready", false)):
		_fail("v1.53 world presentation reports not ready")
		return
	if int(world_snapshot.get("directional_shadow_lights", 0)) < 1:
		_fail("v1.53 did not enable a directional shadow light")
		return

	var player_value: Variant = world_snapshot.get("player", {})
	if not (player_value is Dictionary):
		_fail("player presentation snapshot is missing")
		return
	var player_snapshot: Dictionary = player_value
	if not bool(player_snapshot.get("ready", false)):
		_fail("player smooth presentation is not ready")
		return
	if int(player_snapshot.get("shared_material_count", 0)) < 12:
		_fail("shared PBR material library is incomplete")
		return

	var world = game.v52_world_root
	if world == null or world.actor_factory == null:
		_fail("v1.53 actor factory is unavailable")
		return
	var factory = world.actor_factory
	if not factory.has_method("visual_presentation_snapshot"):
		_fail("v1.53 actor factory presentation contract is missing")
		return

	# v1.53's native fallback is intentionally a multi-piece smooth PBR actor.
	# Later model-intake layers replace that fallback with a real imported model,
	# where counting the hidden v1.53 primitive pieces is no longer meaningful.
	var player_model_source := String(player_snapshot.get("model_source", ""))
	if player_model_source == "imported-glb":
		var imported := world.player_root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
		if imported == null:
			_fail("imported player model source is active but no model is mounted")
			return
		if _mesh_instance_count(imported) < 1:
			_fail("imported player model contains no renderable mesh")
			return
		if not factory.has_method("model_pipeline_ready") or not bool(factory.call("model_pipeline_ready", world.player_root)):
			_fail("imported player model pipeline is not ready")
			return
	else:
		if int(player_snapshot.get("mesh_count", 0)) < 10:
			_fail("native player presentation does not contain enough authored 3D pieces")
			return
		if int(player_snapshot.get("shadow_mesh_count", 0)) < 8:
			_fail("native player presentation is not shadow-casting")
			return
		if not _has_smooth_mesh(world.player_root):
			_fail("native player presentation has no CapsuleMesh/SphereMesh surface")
			return

	for index in range(ENEMY_KINDS.size()):
		var kind: String = String(ENEMY_KINDS[index])
		var enemy: Node3D = factory.create_enemy_shell(index)
		factory.configure_enemy(enemy, kind, world.actor_materials)
		var enemy_snapshot: Dictionary = factory.visual_presentation_snapshot(enemy)
		if not bool(enemy_snapshot.get("ready", false)):
			enemy.free()
			_fail("%s presentation is not ready" % kind)
			return
		var enemy_model_source := String(enemy_snapshot.get("model_source", ""))
		if enemy_model_source == "imported-glb":
			var imported_enemy := enemy.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
			if imported_enemy == null or _mesh_instance_count(imported_enemy) < 1:
				enemy.free()
				_fail("%s imported presentation contains no renderable mesh" % kind)
				return
		else:
			if int(enemy_snapshot.get("mesh_count", 0)) < 6:
				enemy.free()
				_fail("%s native presentation is still too primitive" % kind)
				return
			if not _has_smooth_mesh(enemy):
				enemy.free()
				_fail("%s native presentation has no smooth primitive surface" % kind)
				return
		enemy.free()

	print("v1.53 3D visual presentation smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _mesh_instance_count(node: Node) -> int:
	if node == null:
		return 0
	var count := 1 if node is MeshInstance3D and (node as MeshInstance3D).mesh != null else 0
	for child in node.get_children():
		count += _mesh_instance_count(child)
	return count

func _has_smooth_mesh(node: Node) -> bool:
	if node == null:
		return false
	if node is MeshInstance3D:
		var mesh_value: Mesh = (node as MeshInstance3D).mesh
		if mesh_value is CapsuleMesh or mesh_value is SphereMesh or mesh_value is CylinderMesh:
			return true
	for child in node.get_children():
		if _has_smooth_mesh(child):
			return true
	return false

func _fail(message: String) -> void:
	push_error("V67_PRESENTATION_FAIL: %s" % message)
	quit(1)
