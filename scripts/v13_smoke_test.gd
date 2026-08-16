extends SceneTree

func _init() -> void:
	call_deferred("_run_v13_smoke")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run_v13_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(301, "v1.2 rc3 smoke: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	if not game.has_method("_v13_actor_texture"):
		_fail(302, "v1.2 rc3 smoke: premium actor controller is not active")
		return
	if game.v13_actor_textures.size() != 12:
		_fail(303, "v1.2 rc3 smoke: expected 12 premium actor textures")
		return
	for i in range(12):
		var tex = game._v13_actor_texture(i)
		if tex == null:
			_fail(304, "v1.2 rc3 smoke: actor texture %d failed to load" % i)
			return
		if tex.get_width() < 300 or tex.get_height() < 450:
			_fail(305, "v1.2 rc3 smoke: actor texture %d is not production resolution" % i)
			return
	if game.tex_v12_environment == null or game.tex_v12_environment.get_width() < 648 or game.tex_v12_environment.get_height() < 3360:
		_fail(306, "v1.2 rc3 smoke: premium environment texture missing")
		return

	# Reproduce the real-device Settings BACK bug: the BACK center overlaps PLAY.
	# iOS can also emit a mouse event for the same physical touch, so exercise
	# both event types while the modal is disappearing.
	game.tutorial_active = false
	game.state = game.State.HOME
	game.settings_open = true
	game.settings_return_to_pause = false
	var back_pos: Vector2 = game.V10_SET_BACK.get_center()
	if not game.PLAY.has_point(back_pos):
		_fail(307, "v1.2 rc3 smoke: regression geometry changed; test no longer reproduces overlap")
		return

	game.pointer(back_pos, true, 77)
	if game.settings_open:
		_fail(308, "v1.2 rc3 smoke: Settings BACK did not close settings")
		return
	if game.state != game.State.HOME:
		_fail(309, "v1.2 rc3 smoke: Settings BACK changed state on touch press")
		return
	if not game.v13_pointer_sequence_locked:
		_fail(310, "v1.2 rc3 smoke: Settings touch sequence was not captured")
		return

	# Simulate a duplicate pointer press even without relying on Godot's device
	# tagging. The sequence lock must keep it away from PLAY.
	game.pointer(back_pos, true, -99)
	if game.state != game.State.HOME:
		_fail(311, "v1.2 rc3 smoke: duplicate pointer press leaked into PLAY")
		return

	# Simulate Godot's actual touch-generated mouse event. The most-derived input
	# handler must reject DEVICE_ID_EMULATION before it reaches the pointer stack.
	var ghost_mouse := InputEventMouseButton.new()
	ghost_mouse.button_index = MOUSE_BUTTON_LEFT
	ghost_mouse.position = back_pos + game.v11_layout_offset
	ghost_mouse.pressed = true
	ghost_mouse.device = InputEvent.DEVICE_ID_EMULATION
	game._unhandled_input(ghost_mouse)
	if game.state != game.State.HOME:
		_fail(312, "v1.2 rc3 smoke: emulated mouse press leaked into PLAY")
		return

	game.pointer(back_pos, false, 77)
	if game.state != game.State.HOME:
		_fail(313, "v1.2 rc3 smoke: Settings BACK touch release leaked into PLAY")
		return
	if game.v13_pointer_sequence_locked:
		_fail(314, "v1.2 rc3 smoke: Settings touch capture remained locked after release")
		return

	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("config/version=\"1.2.0-rc3\""):
		_fail(315, "v1.2 rc3 smoke: project version missing")
		return
	if not project_text.contains("pointing/emulate_mouse_from_touch=false"):
		_fail(316, "v1.2 rc3 smoke: touch-to-mouse emulation is not disabled")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_text.contains("application/version=\"5\""):
		_fail(317, "v1.2 rc3 smoke: iOS build number 5 missing")
		return
	if not export_text.contains("version/code=5"):
		_fail(318, "v1.2 rc3 smoke: Android build code 5 missing")
		return

	print("ONE MORE FLOOR v1.2 rc3 premium art/mobile input smoke test passed")
	quit(0)
