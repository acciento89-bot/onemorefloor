extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	for path in ["res://assets/art/actors_tower_v47.svg", "res://assets/art/player_combat_v47.svg", "res://assets/art/projectiles_v47.svg"]:
		if not FileAccess.file_exists(path):
			_fail(4701, "v1.34 visual asset missing: %s" % path)
			return
		if load(path) as Texture2D == null:
			_fail(4702, "v1.34 visual asset failed to import: %s" % path)
			return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(4703, "v1.34 main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	if not game.has_method("_v47_foundation_visuals_ready") or not bool(game._v47_foundation_visuals_ready()):
		_fail(4704, "v1.34 foundation visual runtime is not active")
		return
	for method in ["_v47_draw_actor_cell", "_v47_draw_projectile_cell", "_v47_draw_death", "_v47_attack_tell_amount"]:
		if not game.has_method(method):
			_fail(4705, "v1.34 runtime method missing: %s" % method)
			return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v47.gd") or not scene_text.contains("main_v46.gd"):
		_fail(4706, "v1.34 scene wiring or v1.33 compatibility baseline missing")
		return
	var renderer := FileAccess.get_file_as_string("res://scripts/main_v47.gd")
	for marker in ["FOUNDATION-TO-ENDGAME VISUAL CONTINUITY", "V47_TOWER_SLOTS", "player_combat_v47", "projectiles_v47", "FLOOR CLEARED"]:
		if not renderer.to_upper().contains(marker.to_upper()):
			_fail(4707, "v1.34 renderer marker missing: %s" % marker)
			return
	if int(game.V47_TOWER_SLOTS.size()) != 19:
		_fail(4708, "v1.34 tower roster count mismatch")
		return

	print("ONE MORE FLOOR v1.34 foundation visuals smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
