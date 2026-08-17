extends "res://scripts/world3d_actor_factory_v141.gd"

# ONE MORE FLOOR v1.42 — rig-aware actor factory.
# Imported GLB scenes are optional. When absent, the v1.41 production actors
# remain fully active. When present, they are mounted into the same actor roots
# so gameplay positions, scale, tells, hit flashes and contact shadows survive.

const ModelRegistry = preload("res://scripts/world3d_model_registry.gd")

var model_registry := ModelRegistry.new()

func create_player(materials: Dictionary) -> Node3D:
	var root := super.create_player(materials)
	_ensure_rig_mount(root, "wanderer", true)
	root.set_meta("model_pipeline_ready", true)
	return root

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	_ensure_rig_mount(root, kind, false)
	root.set_meta("model_pipeline_ready", true)

func animate_player(root: Node3D, elapsed: float, move_amount: float, attack_amount: float, skill_amount: float) -> void:
	super.animate_player(root, elapsed, move_amount, attack_amount, skill_amount)
	var state := "idle"
	if skill_amount > 0.04:
		state = "skill"
	elif attack_amount > 0.04:
		state = "attack"
	elif move_amount > 0.10:
		state = "run"
	_drive_imported(root, state, 1.0 + clampf(move_amount, 0.0, 1.0) * 0.12)

func animate_enemy(root: Node3D, elapsed: float, phase: float, tell: float, hit: float, index: int) -> void:
	super.animate_enemy(root, elapsed, phase, tell, hit, index)
	var state := _enemy_locomotion_state(root)
	if hit > 0.05:
		state = "hit"
	elif tell > 0.18:
		state = "attack"
	_drive_imported(root, state, 1.0)

func model_pipeline_ready(root: Node3D) -> bool:
	if root == null or not bool(root.get_meta("model_pipeline_ready", false)):
		return false
	var motion := root.get_node_or_null("Motion") as Node3D
	return motion != null and motion.get_node_or_null("RigMount") != null

func model_registry_snapshot() -> Dictionary:
	return model_registry.snapshot()

func imported_model_active(root: Node3D) -> bool:
	return root != null and String(root.get_meta("model_source", "")) == "imported-glb"

func _ensure_rig_mount(root: Node3D, kind: String, is_player: bool) -> void:
	if root == null:
		return
	var motion := root.get_node_or_null("Motion") as Node3D
	if motion == null:
		return
	var mount := motion.get_node_or_null("RigMount") as Node3D
	if mount == null:
		mount = Node3D.new()
		mount.name = "RigMount"
		motion.add_child(mount)

	var mounted_kind := String(mount.get_meta("model_kind", ""))
	if mounted_kind == kind:
		return

	_set_native_visuals(root, is_player, true)
	for child in mount.get_children():
		child.queue_free()
	mount.set_meta("model_kind", kind)
	mount.visible = false

	var imported := model_registry.instantiate_model(kind)
	if imported != null:
		mount.add_child(imported)
		mount.visible = true
		root.set_meta("model_source", "imported-glb")
		root.set_meta("model_asset_path", model_registry.asset_path(kind))
		_set_native_visuals(root, is_player, false)
	else:
		root.set_meta("model_source", "native-fallback")
		root.set_meta("model_asset_path", model_registry.asset_path(kind))

func _drive_imported(root: Node3D, state: String, speed: float) -> void:
	if not imported_model_active(root):
		return
	var model := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if model != null:
		model_registry.drive_animation(model, state, speed)

func _enemy_locomotion_state(root: Node3D) -> String:
	var previous: Vector3 = root.get_meta("rig_prev_position", root.position)
	var distance := root.position.distance_to(previous)
	root.set_meta("rig_prev_position", root.position)
	return "run" if distance > 0.008 else "idle"

func _set_native_visuals(root: Node3D, is_player: bool, value: bool) -> void:
	if is_player:
		var motion := root.get_node_or_null("Motion") as Node3D
		if motion != null:
			_set_geometry_recursive(motion, value, ["RigMount"])
		var weapon := root.get_node_or_null("WeaponPivot") as Node3D
		if weapon != null:
			_set_geometry_recursive(weapon, value, [])
	else:
		var visual := root.get_node_or_null("Motion/Visual") as Node3D
		if visual != null:
			_set_geometry_recursive(visual, value, ["TellRing", "HitSpark", "RankCrest"])

func _set_geometry_recursive(node: Node, value: bool, protected_names: Array) -> void:
	for child in node.get_children():
		if protected_names.has(String(child.name)):
			continue
		if child is GeometryInstance3D:
			(child as GeometryInstance3D).visible = value
		_set_geometry_recursive(child, value, protected_names)
