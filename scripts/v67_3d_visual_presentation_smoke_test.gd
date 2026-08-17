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
	if int(player_snapshot.get("mesh_count", 0)) < 10:
		_fail("player presentation does not contain enough authored 3D pieces")
		return
	if int(player_snapshot.get("shadow_mesh_count", 0)) < 8:
		_fail("player presentation is not shadow-casting")
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

	for index in range(ENEMY_KINDS.size()):
		var kind: String = String(ENEMY_KINDS[index])
		var enemy: Node3D = factory.create_enemy_shell(index)
		factory.configure_enemy(enemy, kind, world.actor_materials)
		var enemy_snapshot: Dictionary = factory.visual_presentation_snapshot(enemy)
		if not bool(enemy_snapshot.get("ready", false)):
			enemy.free()
			_fail("%s presentation is not ready" % kind)
			return
		if int(enemy_snapshot.get("mesh_count", 0)) < 6:
			enemy.free()
			_fail("%s presentation is still too primitive" % kind)
			return
		if not _has_smooth_mesh(enemy):
			enemy.free()
			_fail("%s presentation has no smooth primitive surface" % kind)
			return
		enemy.free()

	if not _has_smooth_mesh(world.player_root):
		_fail("player presentation has no CapsuleMesh/SphereMesh surface")
		return

	print("v1.53 3D visual presentation smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

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
