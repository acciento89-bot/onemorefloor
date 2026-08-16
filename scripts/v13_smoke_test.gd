extends SceneTree

func _init() -> void:
	call_deferred("_run_v13_smoke")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run_v13_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(301, "v1.2 rc2 smoke: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	if not game.has_method("_v13_actor_texture"):
		_fail(302, "v1.2 rc2 smoke: premium actor controller is not active")
		return
	if game.v13_actor_textures.size() != 12:
		_fail(303, "v1.2 rc2 smoke: expected 12 premium actor textures")
		return
	for i in range(12):
		var tex = game._v13_actor_texture(i)
		if tex == null:
			_fail(304, "v1.2 rc2 smoke: actor texture %d failed to load" % i)
			return
		if tex.get_width() < 300 or tex.get_height() < 450:
			_fail(305, "v1.2 rc2 smoke: actor texture %d is not production resolution" % i)
			return
	if game.tex_v12_environment == null or game.tex_v12_environment.get_width() < 648 or game.tex_v12_environment.get_height() < 3360:
		_fail(306, "v1.2 rc2 smoke: premium environment texture missing")
		return

	# Reproduce the real-device Settings BACK bug: the BACK center overlaps PLAY.
	game.tutorial_active = false
	game.state = game.State.HOME
	game.settings_open = true
	game.settings_return_to_pause = false
	var back_pos: Vector2 = game.V10_SET_BACK.get_center()
	if not game.PLAY.has_point(back_pos):
		_fail(307, "v1.2 rc2 smoke: regression geometry changed; test no longer reproduces overlap")
		return
	game.pointer(back_pos, true, 77)
	if game.settings_open:
		_fail(308, "v1.2 rc2 smoke: Settings BACK did not close settings")
		return
	if game.state != game.State.HOME:
		_fail(309, "v1.2 rc2 smoke: Settings BACK changed state on press")
		return
	game.pointer(back_pos, false, 77)
	if game.state != game.State.HOME:
		_fail(310, "v1.2 rc2 smoke: Settings BACK release leaked into PLAY")
		return

	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("config/version=\"1.2.0-rc2\""):
		_fail(311, "v1.2 rc2 smoke: project version missing")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_text.contains("application/version=\"4\""):
		_fail(312, "v1.2 rc2 smoke: iOS build number 4 missing")
		return
	if not export_text.contains("version/code=4"):
		_fail(313, "v1.2 rc2 smoke: Android build code 4 missing")
		return

	print("ONE MORE FLOOR v1.2 rc2 premium art/input smoke test passed")
	quit(0)
