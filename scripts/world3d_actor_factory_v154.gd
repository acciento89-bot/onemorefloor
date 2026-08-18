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
