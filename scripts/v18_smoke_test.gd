extends SceneTree

func _init() -> void:
	call_deferred("_run_v18_smoke")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run_v18_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(801, "v1.6.1 concept final: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	if not game.has_method("_v18_reward_chest") or not game.has_method("draw_pass_screen"):
		_fail(802, "v1.6.1 concept final: final renderer is not active")
		return
	var textures: Array = [game.tex_v18_home, game.tex_v18_arcane, game.tex_v18_forge]
	for texture in textures:
		if texture == null:
			_fail(803, "v1.6.1 concept final: concept environment failed to import")
			return
		if texture.get_width() < 720 or texture.get_height() < 1280:
			_fail(804, "v1.6.1 concept final: concept environment is undersized")
			return

	var renderer := FileAccess.get_file_as_string("res://scripts/main_v18.gd")
	for asset in ["concept_home_v16.svg", "concept_arcane_v16.svg", "concept_forge_v16.svg"]:
		if not renderer.contains(asset):
			_fail(805, "v1.6.1 concept final: renderer missing %s" % asset)
			return
	for signature in ["func _v16_backdrop", "func _v18_reward_chest", "func draw_pass_screen"]:
		if not renderer.contains(signature):
			_fail(806, "v1.6.1 concept final: override missing %s" % signature)
			return

	# Keep the proven iPhone Settings -> Back fix intact.
	game.tutorial_active = false
	game.state = game.State.HOME
	game.settings_open = true
	game.settings_return_to_pause = false
	var back_pos: Vector2 = game.V10_SET_BACK.get_center()
	game.pointer(back_pos, true, 451)
	game.pointer(back_pos, true, -99)
	game.pointer(back_pos, false, 451)
	if game.state != game.State.HOME or game.settings_open:
		_fail(807, "v1.6.1 concept final: Settings BACK regression returned")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v18.gd"):
		_fail(808, "v1.6.1 concept final: main scene is not using main_v18")
		return
	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("config/version=\"1.6.1-concept-final\""):
		_fail(809, "v1.6.1 concept final: project version missing")
		return
	if not project_text.contains("pointing/emulate_mouse_from_touch=false"):
		_fail(810, "v1.6.1 concept final: native touch hardening regressed")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_text.contains("application/short_version=\"1.6.1\"") or not export_text.contains("version/name=\"1.6.1\""):
		_fail(811, "v1.6.1 concept final: mobile version missing")
		return
	if not export_text.contains("application/version=\"10\"") or not export_text.contains("version/code=10"):
		_fail(812, "v1.6.1 concept final: Build 10 missing")
		return

	print("ONE MORE FLOOR v1.6.1 final concept environment smoke test passed")
	quit(0)