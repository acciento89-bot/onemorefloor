extends SceneTree

const EXPECTED_ASSET := "res://assets/models/actors/wanderer.gltf"
const REQUIRED_CLIPS := ["Idle", "Run", "Attack", "Hit", "Skill"]

var _current_stage := "boot"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_stage("load-main")
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame

	_stage("version-gate")
	if not game.has_method("_v69_wanderer_snapshot"):
		_fail("main scene is not running v1.55 Wanderer pilot")
		return

	_stage("production-ready")
	if not bool(game.call("_v69_wanderer_production_ready")):
		var gate_snapshot: Dictionary = game.call("_v69_wanderer_snapshot")
		var v68_ready := bool(game.call("_v68_real_model_intake_ready"))
		var v65_ready := bool(game.call("_v65_3d_combat_core_ready"))
		_fail("production Wanderer did not replace the fallback; v68_ready=%s v65_ready=%s snapshot=%s" % [v68_ready, v65_ready, JSON.stringify(gate_snapshot)])
		return

	_stage("regression-gates")
	if not bool(game.call("_v68_real_model_intake_ready")):
		_fail("v1.54 real-model intake regressed")
		return
	if not bool(game.call("_v65_3d_combat_core_ready")):
		_fail("v1.52 3D combat authority regressed")
		return

	_stage("player-metadata")
	var world = game.v52_world_root
	var player_root: Node3D = world.player_root
	if player_root == null:
		_fail("player root is null")
		return
	var model_source := String(player_root.get_meta("model_source", ""))
	var model_asset_path := String(player_root.get_meta("model_asset_path", ""))
	print("V69_PLAYER:source=%s asset=%s root=%s" % [model_source, model_asset_path, str(player_root.get_path())])
	if model_source != "imported-glb":
		_fail("player is not marked as imported model")
		return
	if model_asset_path != EXPECTED_ASSET:
		_fail("wrong production Wanderer asset path")
		return

	_stage("imported-rig")
	var rig_mount := player_root.get_node_or_null("Motion/RigMount") as Node3D
	var imported := player_root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	print("V69_RIG:rig=%s imported=%s" % [str(rig_mount), str(imported)])
	if rig_mount == null or imported == null or not rig_mount.visible:
		_fail("production Wanderer RigMount is not active/visible")
		return

	_stage("mesh-composition")
	var imported_mesh_count := _mesh_count(imported)
	print("V69_MESH_COUNT:%d" % imported_mesh_count)
	if imported_mesh_count < 10:
		_fail("production Wanderer mesh composition is incomplete")
		return

	_stage("fallback-suppression")
	var presentation := player_root.get_node_or_null("Motion/PresentationV153")
	if presentation != null:
		_fail("v1.53 fallback presentation was created despite imported Wanderer")
		return
	var visible_native_meshes := _visible_mesh_count_excluding(rig_mount.get_parent(), rig_mount)
	print("V69_NATIVE_VISIBLE_MESHES:%d" % visible_native_meshes)
	if visible_native_meshes > 0:
		_fail("native player geometry is still visible beside the imported model")
		return

	_stage("animation-player")
	var animation_player := _find_animation_player(imported)
	if animation_player == null:
		_fail("imported Wanderer has no AnimationPlayer")
		return
	var clip_names := PackedStringArray()
	for animation_name in animation_player.get_animation_list():
		clip_names.append(String(animation_name))
	print("V69_ANIMATION_PLAYER:path=%s clips=%s" % [str(animation_player.get_path()), ",".join(clip_names)])

	_stage("required-clips")
	for clip in REQUIRED_CLIPS:
		if not animation_player.has_animation(clip):
			_fail("missing production animation clip: %s" % clip)
			return

	_stage("registry")
	var registry = world.actor_factory.model_registry
	if registry == null:
		_fail("actor factory model registry is null")
		return
	var registry_script = registry.get_script()
	var registry_path := "<no-script>"
	if registry_script != null:
		registry_path = String(registry_script.resource_path)
	print("V69_REGISTRY:%s" % registry_path)
	if not registry.has_method("drive_animation"):
		_fail("actor factory model registry has no drive_animation method")
		return

	for state in ["idle", "run", "attack", "hit", "skill"]:
		_stage("drive-%s" % state)
		var driven := bool(registry.drive_animation(imported, state, 1.0))
		print("V69_DRIVE:state=%s result=%s current=%s playing=%s speed=%s" % [state, str(driven), String(animation_player.current_animation), str(animation_player.is_playing()), str(animation_player.speed_scale)])
		if not driven:
			_fail("runtime could not drive imported animation state: %s" % state)
			return
		await process_frame

	_stage("snapshot")
	var snapshot: Dictionary = game.call("_v69_wanderer_snapshot")
	print("V69_SNAPSHOT:%s" % JSON.stringify(snapshot))
	if not bool(snapshot.get("ready", false)):
		_fail("v1.55 snapshot reports Wanderer not ready")
		return
	if String(snapshot.get("version", "")) != "1.55.0-wanderer-production-pilot":
		_fail("v1.55 version marker is wrong")
		return

	_stage("complete")
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

func _stage(name: String, details: String = "") -> void:
	_current_stage = name
	if details.is_empty():
		print("V69_STAGE:%s" % name)
	else:
		print("V69_STAGE:%s:%s" % [name, details])

func _fail(message: String) -> void:
	push_error("V69_WANDERER_FAIL:%s:%s" % [_current_stage, message])
	quit(1)
