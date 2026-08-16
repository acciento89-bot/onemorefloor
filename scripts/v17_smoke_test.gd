extends SceneTree

func _init() -> void:
	call_deferred("_run_v17_smoke")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run_v17_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(701, "v1.6 smoke: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	if not game.has_method("_v17_skin") or not game.has_method("_v16_frame") or not game.has_method("_v16_button"):
		_fail(702, "v1.6 smoke: exact concept menu renderer inheritance is not active")
		return
	if game.tex_v17_skins == null or game.tex_v17_skins.get_width() < 360 or game.tex_v17_skins.get_height() < 576:
		_fail(703, "v1.6 smoke: concept button skin atlas missing or undersized")
		return
	if game.tex_v16_home == null or game.tex_v16_arcane == null or game.tex_v16_forge == null:
		_fail(704, "v1.6 smoke: inherited concept environment layers are missing")
		return

	var renderer_text := FileAccess.get_file_as_string("res://scripts/main_v17.gd")
	var required := [
		"func _v16_frame", "func _v16_button", "func _v16_medallion",
		"func _v16_title", "func _v16_currency", "func _v16_header",
		"func _v16_home_tab", "func draw_home"
	]
	for signature in required:
		if not renderer_text.contains(signature):
			_fail(705, "v1.6 smoke: concept override missing: %s" % signature)
			return

	game.tutorial_active = false
	game.state = game.State.HOME
	game.settings_open = true
	game.settings_return_to_pause = false
	var back_pos: Vector2 = game.V10_SET_BACK.get_center()
	game.pointer(back_pos, true, 351)
	game.pointer(back_pos, true, -99)
	game.pointer(back_pos, false, 351)
	if game.state != game.State.HOME or game.settings_open:
		_fail(706, "v1.6 smoke: Settings BACK regression returned")
		return

	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("pointing/emulate_mouse_from_touch=false"):
		_fail(707, "v1.6 smoke: native touch hardening regressed")
		return

	print("ONE MORE FLOOR v1.6 exact concept menus smoke test passed")
	quit(0)
