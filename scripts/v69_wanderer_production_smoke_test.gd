extends SceneTree

const EXPECTED_ASSET := "res://assets/models/actors/wanderer.gltf"
const REQUIRED_CLIPS := ["Idle", "Run", "Attack", "Hit", "Skill"]

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

	if not game.has_method("_v69_wanderer_snapshot"):
		_fail("main scene is not running v1.55 Wanderer pilot")
		return
	if not bool(game.call("_v69_wanderer_production_ready")):
		_fail("production Wanderer did not replace the fallback")
		return
	if not bool(game.call("_v68_real_model_intake_ready")):
		_fail("v1.54 real-model intake regressed")
		return
	if not bool(game.call("_v65_3d_combat_core_ready")):
		_fail("v1.52 3D combat authority regressed")
		return

	var world = game.v52_world_root
	var player_root: Node3D = world.player_root
	if String(player_root.get_meta("model_source", "")) != "imported-glb":
		_fail("player is not marked as imported model")
		return
	if String(player_root.get_meta("model_asset_path", "")) != EXPECTED_ASSET:
		_fail("wrong production Wanderer asset path")
		return

	var rig_mount := player_root.get_node_or_null("Motion/RigMount") as Node3D
	var imported := player_root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if rig_mount == null or imported == null or not rig_mount.visible:
		_fail("production Wanderer RigMount is not active/visible")
		return
	# Godot is allowed to collapse/reparent the glTF scene root on import. Validate
	# the authored model by its resulting mesh composition instead of a brittle
	# assumption that WandererRoot must survive as a direct child node.
	if _mesh_count(imported) < 10:
		_fail("production Wanderer mesh composition is incomplete")
		return

	# Imported assets must suppress both legacy and v1.53 native fallback geometry.
	var presentation := player_root.get_node_or_null("Motion/PresentationV153")
	if presentation != null:
		_fail("v1.53 fallback presentation was created despite imported Wanderer")
		return
	if _visible_mesh_count_excluding(rig_mount.get_parent(), rig_mount) > 0:
		_fail("native player geometry is still visible beside the imported model")
		return

	var animation_player := _find_animation_player(imported)
	if animation_player == null:
		_fail("imported Wanderer has no AnimationPlayer")
		return
	for clip in REQUIRED_CLIPS:
		if not animation_player.has_animation(clip):
			_fail("missing production animation clip: %s" % clip)
			return

	# Exercise the exact runtime animation path used by gameplay.
	for state in ["idle", "run", "attack", "hit", "skill"]:
		if not world.actor_factory.model_registry.drive_animation(imported, state, 1.0):
			_fail("runtime could not drive imported animation state: %s" % state)
			return
		await process_frame

	var snapshot: Dictionary = game.call("_v69_wanderer_snapshot")
	if not bool(snapshot.get("ready", false)):
		_fail("v1.55 snapshot reports Wanderer not ready")
		return
	if String(snapshot.get("version", "")) != "1.55.0-wanderer-production-pilot":
		_fail("v1.55 version marker is wrong")
		return

	print("v1.55 production Wanderer model takeover smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null

func _mesh_count(node: Node) -> int:
	var count := 1 if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _mesh_count(child)
	return count

func _visible_mesh_count_excluding(node: Node, excluded: Node) -> int:
	if node == excluded:
		return 0
	var count := 0
	if node is MeshInstance3D and (node as MeshInstance3D).visible:
		count = 1
	for child in node.get_children():
		count += _visible_mesh_count_excluding(child, excluded)
	return count

func _fail(message: String) -> void:
	push_error("V69_WANDERER_FAIL: %s" % message)
	quit(1)
