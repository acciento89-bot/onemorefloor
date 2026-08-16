extends SceneTree

func _init() -> void:
	call_deferred("_run_v16_smoke")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run_v16_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(601, "v1.5 smoke: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	if not game.has_method("_v16_frame") or not game.has_method("_v16_button") or not game.has_method("_v16_header"):
		_fail(602, "v1.5 smoke: final premium menu renderer is not active")
		return
	if game.tex_v16_home == null or game.tex_v16_home.get_width() < 720 or game.tex_v16_home.get_height() < 1280:
		_fail(603, "v1.5 smoke: final home artwork missing or undersized")
		return
	if game.tex_v16_arcane == null or game.tex_v16_arcane.get_width() < 720 or game.tex_v16_arcane.get_height() < 1280:
		_fail(604, "v1.5 smoke: final arcane menu artwork missing or undersized")
		return
	if game.tex_v16_forge == null or game.tex_v16_forge.get_width() < 720 or game.tex_v16_forge.get_height() < 1280:
		_fail(605, "v1.5 smoke: final forge artwork missing or undersized")
		return
	if game.v16_title_font == null or game.v16_body_font == null:
		_fail(606, "v1.5 smoke: premium system typography missing")
		return

	# Every player-facing menu that existed before v1.5 must now use the v1.5 renderer.
	var renderer_text := FileAccess.get_file_as_string("res://scripts/main_v16.gd")
	var required_methods := [
		"func draw_home()", "func _draw_settings_overlay()", "func _draw_pause_overlay()",
		"func draw_hero_screen()", "func draw_forge_screen()", "func draw_talents_screen()",
		"func draw_missions_screen()", "func draw_pass_screen()", "func draw_vault_screen()"
	]
	for signature in required_methods:
		if not renderer_text.contains(signature):
			_fail(607, "v1.5 smoke: menu override missing: %s" % signature)
			return

	# Preserve the exact Settings BACK input regression protection proven on iPhone.
	game.tutorial_active = false
	game.state = game.State.HOME
	game.settings_open = true
	game.settings_return_to_pause = false
	var back_pos: Vector2 = game.V10_SET_BACK.get_center()
	game.pointer(back_pos, true, 251)
	game.pointer(back_pos, true, -99)
	game.pointer(back_pos, false, 251)
	if game.state != game.State.HOME or game.settings_open:
		_fail(608, "v1.5 smoke: Settings BACK regression returned")
		return

	# All legacy menu hitboxes remain intact, so the redesign cannot silently break touch navigation.
	if not game.PLAY.has_point(game.PLAY.get_center()):
		_fail(609, "v1.5 smoke: PLAY hitbox invalid")
		return
	if not game.HERO_TAB.has_point(game.HERO_TAB.get_center()) or not game.FORGE_TAB.has_point(game.FORGE_TAB.get_center()):
		_fail(610, "v1.5 smoke: home meta tab hitboxes invalid")
		return
	if not game.V10_SET_BACK.has_point(game.V10_SET_BACK.get_center()):
		_fail(611, "v1.5 smoke: settings back hitbox invalid")
		return
	if not game.V8_EQUIP.has_point(game.V8_EQUIP.get_center()) or not game.V8_CRAFT_RELIC.has_point(game.V8_CRAFT_RELIC.get_center()):
		_fail(612, "v1.5 smoke: vault action hitboxes invalid")
		return

	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("config/version=\"1.5.0-rc1\""):
		_fail(613, "v1.5 smoke: project version missing")
		return
	if not project_text.contains("pointing/emulate_mouse_from_touch=false"):
		_fail(614, "v1.5 smoke: native touch hardening regressed")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_text.contains("application/short_version=\"1.5.0\"") or not export_text.contains("version/name=\"1.5.0\""):
		_fail(615, "v1.5 smoke: mobile visible version missing")
		return
	if not export_text.contains("application/version=\"8\"") or not export_text.contains("version/code=8"):
		_fail(616, "v1.5 smoke: mobile build number 8 missing")
		return

	print("ONE MORE FLOOR v1.5 final premium menus smoke test passed")
	quit(0)
