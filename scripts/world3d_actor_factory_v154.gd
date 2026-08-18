extends "res://scripts/world3d_actor_factory_v153.gd"

# ONE MORE FLOOR v1.54 — imported real-model intake on top of the v1.53
# presentation fallback. Once a wanderer/enemy .glb or .gltf exists, the
# inherited rig mount hides the native fallback automatically.

const RealModelRegistryV154 = preload("res://scripts/world3d_model_registry_v154.gd")
const MODEL_INTAKE_VERSION := "1.54.0-real-model-intake"

func _init() -> void:
	super._init()
	model_registry = RealModelRegistryV154.new()

func animate_player(root: Node3D, elapsed: float, move_amount: float, attack_amount: float, skill_amount: float) -> void:
	super.animate_player(root, elapsed, move_amount, attack_amount, skill_amount)
	_drive_current_imported_state(root)

func animate_enemy(root: Node3D, elapsed: float, phase: float, tell: float, hit: float, index: int) -> void:
	super.animate_enemy(root, elapsed, phase, tell, hit, index)
	_drive_current_imported_state(root)

func _drive_current_imported_state(root: Node3D) -> void:
	if root == null or not is_instance_valid(root) or not imported_model_active(root):
		return
	var state := String(root.get_meta("production_animation_state", "idle"))
	_drive_imported(root, state, 1.0)

# v1.47 builds the production socket contract while actor roots are still being
# assembled off-tree. Reading/writing global transforms at that point is invalid
# in Godot 4.7 and can poison readiness checks. The inherited animation loop
# calls this method again once actors are live, so simply defer synchronization
# until every participating Node3D is inside the SceneTree.
func _sync_socket_targets(root: Node3D) -> void:
	if root == null or not is_instance_valid(root) or not root.is_inside_tree():
		return
	for logical_value in SOCKET_DEFAULTS.keys():
		var logical_name: String = String(logical_value)
		var socket: Node3D = actor_socket(root, logical_name)
		if socket == null or not is_instance_valid(socket) or not socket.is_inside_tree():
			continue
		if not socket.has_meta("target_node"):
			continue
		var target_value: Variant = socket.get_meta("target_node")
		if not (target_value is Node3D) or not is_instance_valid(target_value):
			continue
		var target: Node3D = target_value as Node3D
		if not target.is_inside_tree():
			continue
		socket.global_transform = target.global_transform

# v1.49's original quality gate intentionally expects a Skeleton3D for imported
# production assets. The v1.55 pilot is a different, still legitimate glTF form:
# it is an articulated node hierarchy with authored transform animations. Keep
# skeleton_ok truthful, but expose a separate production tier when the actual
# runtime contract is complete instead of inventing a dummy skeleton.
func production_asset_report(root: Node3D) -> Dictionary:
	var report: Dictionary = super.production_asset_report(root)
	if bool(report.get("ready", false)):
		report["rig_strategy"] = "skeleton" if bool(report.get("skeleton_ok", false)) else "native_fallback"
		return report
	if not imported_model_active(root):
		return report
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	var mesh_count := _v154_imported_mesh_count(imported)
	var required_animation_states_ok := _v154_required_animation_states_ready(imported)
	var production_sockets_ok := actor_production_ready(root)
	var articulated_ready := imported != null \
		and model_pipeline_ready(root) \
		and production_sockets_ok \
		and mesh_count >= 6 \
		and required_animation_states_ok
	report["rig_strategy"] = "node_transform_animation"
	report["v154_articulated_ready"] = articulated_ready
	report["v154_mesh_count"] = mesh_count
	report["v154_required_animation_states_ok"] = required_animation_states_ok
	report["v154_production_sockets_ok"] = production_sockets_ok
	if articulated_ready:
		report["ready"] = true
		report["tier"] = "animated_articulated_candidate"
	return report

func production_art_ready(root: Node3D) -> bool:
	if root == null or not bool(root.get_meta("actor_art_v149", false)):
		return false
	var report: Dictionary = production_asset_report(root)
	return bool(report.get("ready", false))

func _v154_required_animation_states_ready(imported: Node3D) -> bool:
	var player := _v154_find_animation_player(imported)
	if player == null:
		return false
	for state in ["idle", "run", "attack"]:
		if not _v154_animation_state_available(player, state):
			return false
	return true

func _v154_animation_state_available(player: AnimationPlayer, state: String) -> bool:
	var aliases: Array = []
	match state:
		"idle": aliases = ["idle", "stand"]
		"run": aliases = ["run", "jog", "locomotion", "walk"]
		"attack": aliases = ["attack", "slash", "melee", "swing"]
		_: aliases = [state]
	for animation_name_value in player.get_animation_list():
		var animation_name := String(animation_name_value).to_lower()
		for alias_value in aliases:
			var alias := String(alias_value).to_lower()
			if animation_name == alias or animation_name.contains(alias):
				return true
	return false

func _v154_find_animation_player(node: Node) -> AnimationPlayer:
	if node == null:
		return null
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _v154_find_animation_player(child)
		if found != null:
			return found
	return null

func _v154_imported_mesh_count(node: Node) -> int:
	if node == null:
		return 0
	var count := 1 if node is MeshInstance3D else 0
	for child in node.get_children():
		count += _v154_imported_mesh_count(child)
	return count

func real_model_intake_ready() -> bool:
	return model_registry != null \
		and model_registry.has_method("candidate_paths") \
		and model_registry.has_method("resolved_asset_path")

func real_model_intake_snapshot() -> Dictionary:
	var registry_snapshot: Dictionary = {}
	if model_registry != null:
		registry_snapshot = model_registry.snapshot()
	return {
		"ready": real_model_intake_ready(),
		"version": MODEL_INTAKE_VERSION,
		"registry": registry_snapshot,
		"fallback": "v1.53-smooth-pbr",
	}
