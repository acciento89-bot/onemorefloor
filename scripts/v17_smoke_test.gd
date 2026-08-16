extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(701, "v1.6 concept smoke: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	if not game.has_method("_v17_button_skin") or not game.has_method("_v17_panel_skin"):
		_fail(702, "v1.6 concept smoke: concept renderer not active")
		return
	var textures := [game.tex_v17_home, game.tex_v17_arcane, game.tex_v17_forge, game.tex_v17_btn_gold, game.tex_v17_btn_purple, game.tex_v17_btn_green, game.tex_v17_btn_blue, game.tex_v17_panel_gold, game.tex_v17_panel_purple, game.tex_v17_panel_green]
	for texture in textures:
		if texture == null:
			_fail(703, "v1.6 concept smoke: concept texture failed to import")
			return
	if game.tex_v17_home.get_width() < 720 or game.tex_v17_home.get_height() < 1280:
		_fail(704, "v1.6 concept smoke: home environment undersized")
		return
	if game.tex_v17_btn_gold.get_width() < 500 or game.tex_v17_panel_gold.get_width() < 600:
		_fail(705, "v1.6 concept smoke: UI skin undersized")
		return
	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v17.gd"):
		_fail(706, "v1.6 concept smoke: main scene renderer mismatch")
		return
	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("config/version=\"1.6.0-concept-lock\""):
		_fail(707, "v1.6 concept smoke: project version missing")
		return
	if not project_text.contains("pointing/emulate_mouse_from_touch=false"):
		_fail(708, "v1.6 concept smoke: touch hardening regressed")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_text.contains("application/short_version=\"1.6.0\"") or not export_text.contains("application/version=\"9\""):
		_fail(709, "v1.6 concept smoke: iOS version/build missing")
		return
	print("ONE MORE FLOOR v1.6 concept-locked menu smoke test passed")
	quit(0)