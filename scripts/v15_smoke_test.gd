extends SceneTree

func _init() -> void:
	call_deferred("_run_v15_smoke")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run_v15_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(501, "v1.4 smoke: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	if not game.has_method("_v15_premium_panel") or not game.has_method("_v15_home_tab"):
		_fail(502, "v1.4 smoke: premium renderer is not active")
		return
	if game.tex_v15_citadel == null or game.tex_v15_citadel.get_width() < 720 or game.tex_v15_citadel.get_height() < 640:
		_fail(503, "v1.4 smoke: premium menu citadel missing or undersized")
		return
	if game.tex_v15_foreground == null or game.tex_v15_foreground.get_width() < 720 or game.tex_v15_foreground.get_height() < 3360:
		_fail(504, "v1.4 smoke: premium biome foreground missing or undersized")
		return
	if game.v13_actor_textures.size() != 12:
		_fail(505, "v1.4 smoke: actor production pipeline regressed")
		return

	# Protect the exact HUD layout issue found on a real iPhone in build 6.
	var renderer_text := FileAccess.get_file_as_string("res://scripts/main_v15.gd")
	if not renderer_text.contains("Rect2(144,982,432,34)"):
		_fail(506, "v1.4 smoke: isolated HP status rail missing")
		return
	if not renderer_text.contains("Vector2(132,1138)"):
		_fail(507, "v1.4 smoke: lowered joystick default origin missing")
		return
	if not renderer_text.contains("clampf(joy_origin.y,1102.0,1160.0)"):
		_fail(508, "v1.4 smoke: joystick safe-zone clamp missing")
		return

	# The prior Settings BACK iOS regression remains mandatory.
	game.tutorial_active = false
	game.state = game.State.HOME
	game.settings_open = true
	game.settings_return_to_pause = false
	var back_pos: Vector2 = game.V10_SET_BACK.get_center()
	game.pointer(back_pos, true, 151)
	game.pointer(back_pos, true, -99)
	game.pointer(back_pos, false, 151)
	if game.state != game.State.HOME or game.settings_open:
		_fail(509, "v1.4 smoke: Settings BACK regression returned")
		return

	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("config/version=\"1.4.0-rc1\""):
		_fail(510, "v1.4 smoke: project version missing")
		return
	if not project_text.contains("pointing/emulate_mouse_from_touch=false"):
		_fail(511, "v1.4 smoke: native touch hardening regressed")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_text.contains("application/short_version=\"1.4.0\"") or not export_text.contains("version/name=\"1.4.0\""):
		_fail(512, "v1.4 smoke: mobile visible version missing")
		return
	if not export_text.contains("application/version=\"7\"") or not export_text.contains("version/code=7"):
		_fail(513, "v1.4 smoke: mobile build number 7 missing")
		return

	print("ONE MORE FLOOR v1.4 premium overhaul smoke test passed")
	quit(0)