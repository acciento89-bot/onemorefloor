extends SceneTree

func _init() -> void:
	call_deferred("_run_v14_smoke")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run_v14_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(401, "v1.3 smoke: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	if not game.has_method("_v14_vfx") or not game.has_method("_v14_room_index"):
		_fail(402, "v1.3 smoke: high-fidelity controller is not active")
		return
	if game.tex_v14_environment == null:
		_fail(403, "v1.3 smoke: high-fidelity environment texture missing")
		return
	if game.tex_v14_environment.get_width() < 648 or game.tex_v14_environment.get_height() < 3360:
		_fail(404, "v1.3 smoke: high-fidelity environment texture has wrong resolution")
		return
	if game.tex_v14_vfx == null or game.tex_v14_vfx.get_width() < 512 or game.tex_v14_vfx.get_height() < 512:
		_fail(405, "v1.3 smoke: high-fidelity VFX atlas missing or undersized")
		return
	if game.tex_v14_ui == null or game.tex_v14_ui.get_width() < 512 or game.tex_v14_ui.get_height() < 256:
		_fail(406, "v1.3 smoke: high-fidelity UI atlas missing or undersized")
		return
	if game.tex_v14_menu == null or game.tex_v14_menu.get_width() < 720 or game.tex_v14_menu.get_height() < 1280:
		_fail(407, "v1.3 smoke: high-fidelity menu backdrop missing or undersized")
		return
	if game.v13_actor_textures.size() != 12:
		_fail(408, "v1.3 smoke: premium actor fallback pipeline regressed")
		return
	if int(game._v14_room_index("DUNGEON")) != 0 or int(game._v14_room_index("CRYPT")) != 1:
		_fail(409, "v1.3 smoke: dungeon/crypt environment mapping is wrong")
		return
	if int(game._v14_room_index("FORGOTTEN CASTLE")) != 2 or int(game._v14_room_index("DEEP TOWER")) != 3:
		_fail(410, "v1.3 smoke: castle/deep tower environment mapping is wrong")
		return

	# Keep the native iOS Settings BACK regression protected in the new renderer.
	game.tutorial_active = false
	game.state = game.State.HOME
	game.settings_open = true
	game.settings_return_to_pause = false
	var back_pos: Vector2 = game.V10_SET_BACK.get_center()
	game.pointer(back_pos, true, 91)
	game.pointer(back_pos, true, -99)
	game.pointer(back_pos, false, 91)
	if game.state != game.State.HOME or game.settings_open:
		_fail(411, "v1.3 smoke: Settings BACK regression returned")
		return

	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("config/version=\"1.3.0-rc1\""):
		_fail(412, "v1.3 smoke: project version missing")
		return
	if not project_text.contains("pointing/emulate_mouse_from_touch=false"):
		_fail(413, "v1.3 smoke: mobile pointer hardening regressed")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_text.contains("application/short_version=\"1.3.0\""):
		_fail(414, "v1.3 smoke: iOS visible version missing")
		return
	if not export_text.contains("application/version=\"6\"") or not export_text.contains("version/code=6"):
		_fail(415, "v1.3 smoke: mobile build number 6 missing")
		return

	print("ONE MORE FLOOR v1.3 high-fidelity art smoke test passed")
	quit(0)
