extends SceneTree

const EXPECTED_VERSION := "1.68-wanderer-visual-completion-r1.1"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	for _i in range(8):
		await process_frame

	if not game.has_method("_v92_character_completion_ready"):
		_fail("v1.68 main layer is not active")
		return
	if not bool(game.call("_v92_character_completion_ready")):
		_fail("v1.68 shared character completion readiness failed")
		return

	var world = game.v52_world_root
	if world == null or not world.has_method("production_character_completion_ready"):
		_fail("v1.68 gameplay world missing")
		return
	if not bool(world.call("production_character_completion_ready")):
		_fail("v1.68 gameplay Wanderer is not ready")
		return
	if String(world.player_root.get_meta("wanderer_completion_v168", "")) != EXPECTED_VERSION:
		_fail("gameplay Wanderer marker missing")
		return

	var stage = game.v70_menu_stage
	stage.set_screen("hero")
	for _i in range(3):
		await process_frame
	if stage.actor_model == null:
		_fail("Hero menu Wanderer missing")
		return
	if String(stage.actor_model.get_meta("wanderer_completion_v168", "")) != EXPECTED_VERSION:
		_fail("Hero menu is not using the corrected v1.68 gameplay Wanderer")
		return
	if not bool(stage.gameplay_actor_factory.call("wanderer_completion_v168_ready", stage.actor_model)):
		_fail("Hero menu v1.68 Wanderer contract failed")
		return

	var imported := world.player_root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		_fail("gameplay imported model missing")
		return
	for node_name in ["V168ArmorTrim", "V168Tabard"]:
		if _find_named_mesh(imported, node_name) == null:
			_fail("missing v1.68 authored piece %s" % node_name)
			return
	if String(world.player_root.get_meta("wanderer_hood_r11", "")) != "1.60-wanderer-hood-r11":
		_fail("Hood r11 regression")
		return

	print("v1.68 Wanderer visual completion smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _find_named_mesh(node: Node, target: String) -> MeshInstance3D:
	if node == null:
		return null
	if node is MeshInstance3D and String(node.name) == target:
		return node as MeshInstance3D
	for child in node.get_children():
		var found := _find_named_mesh(child, target)
		if found != null:
			return found
	return null

func _fail(message: String) -> void:
	push_error("V168_CHARACTER_COMPLETION_FAIL:%s" % message)
	quit(1)
