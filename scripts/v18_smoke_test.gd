extends SceneTree

func _init() -> void:
	call_deferred("_run_v18_smoke")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run_v18_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(801, "v1.6.2 premium reference: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	if not game.has_method("_v18_reward_chest") or not game.has_method("draw_pass_screen") or not game.has_method("draw_vault_screen"):
		_fail(802, "v1.6.2 premium reference: renderer is not active")
		return

	var full_textures: Array = [game.tex_v18_hifi, game.tex_v18_forge]
	for texture in full_textures:
		if texture == null:
			_fail(803, "v1.6.2 premium reference: full-screen environment failed to import")
			return
		if texture.get_width() < 720 or texture.get_height() < 1280:
			_fail(804, "v1.6.2 premium reference: full-screen environment is undersized")
			return
	if game.tex_v18_citadel == null or game.tex_v18_citadel.get_width() < 720 or game.tex_v18_citadel.get_height() < 640:
		_fail(805, "v1.6.2 premium reference: citadel hero art failed to import")
		return
	if game.tex_v18_room == null or game.tex_v18_room.get_width() < 720 or game.tex_v18_room.get_height() < 3360:
		_fail(806, "v1.6.2 premium reference: room foreground atlas failed to import")
		return

	var renderer := FileAccess.get_file_as_string("res://scripts/main_v18.gd")
	for asset in ["hifi_menu_backdrop.svg", "premium_menu_citadel.svg", "premium_room_foreground.svg", "menu_forge_final.svg"]:
		if not renderer.contains(asset):
			_fail(807, "v1.6.2 premium reference: renderer missing %s" % asset)
			return
	for signature in ["func _v16_backdrop", "func _v16_button", "func _v18_reward_chest", "func draw_pass_screen", "func draw_vault_screen"]:
		if not renderer.contains(signature):
			_fail(808, "v1.6.2 premium reference: override missing %s" % signature)
			return
	if not renderer.contains("_v16_header(\"VAULT\"") or renderer.contains("_v16_header(\"VAULT + FORGE\""):
		_fail(809, "v1.6.2 premium reference: Vault title is not exact")
		return

	game.tutorial_active = false
	game.state = game.State.HOME
	game.settings_open = true
	game.settings_return_to_pause = false
	var back_pos: Vector2 = game.V10_SET_BACK.get_center()
	game.pointer(back_pos, true, 451)
	game.pointer(back_pos, true, -99)
	game.pointer(back_pos, false, 451)
	if game.state != game.State.HOME or game.settings_open:
		_fail(810, "v1.6.2 premium reference: Settings BACK regression returned")
		return

	# Successor renderers inherit the v1.6 premium layer. This regression protects
	# retained behaviour/assets, not one particular active renderer generation.
	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	var compatible_renderer := (
		scene_text.contains("main_v18.gd")
		or scene_text.contains("main_v19.gd")
		or scene_text.contains("main_v20.gd")
		or scene_text.contains("main_v21.gd")
		or scene_text.contains("main_v22.gd")
	)
	if not compatible_renderer:
		_fail(811, "v1.6.2 premium reference: compatible main renderer is not active")
		return
	var project_text := FileAccess.get_file_as_string("res://project.godot")
	var compatible_version := (
		project_text.contains("config/version=\"1.6.2-premium-reference\"")
		or project_text.contains("config/version=\"1.7.0-reference-menus\"")
		or project_text.contains("config/version=\"1.8.0-raster-reference\"")
		or project_text.contains("config/version=\"1.9.0-runtime-ui\"")
		or project_text.contains("config/version=\"1.10.0-premium-components\"")
	)
	if not compatible_version:
		_fail(812, "v1.6.2 premium reference: compatible project version missing")
		return
	if not project_text.contains("pointing/emulate_mouse_from_touch=false"):
		_fail(813, "v1.6.2 premium reference: native touch hardening regressed")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	var compatible_mobile := (
		(export_text.contains("application/short_version=\"1.6.2\"") and export_text.contains("version/name=\"1.6.2\""))
		or (export_text.contains("application/short_version=\"1.7.0\"") and export_text.contains("version/name=\"1.7.0\""))
		or (export_text.contains("application/short_version=\"1.8.0\"") and export_text.contains("version/name=\"1.8.0\""))
		or (export_text.contains("application/short_version=\"1.9.0\"") and export_text.contains("version/name=\"1.9.0\""))
		or (export_text.contains("application/short_version=\"1.10.0\"") and export_text.contains("version/name=\"1.10.0\""))
	)
	if not compatible_mobile:
		_fail(814, "v1.6.2 premium reference: compatible mobile version missing")
		return
	var compatible_build := (
		(export_text.contains("application/version=\"11\"") and export_text.contains("version/code=11"))
		or (export_text.contains("application/version=\"12\"") and export_text.contains("version/code=12"))
		or (export_text.contains("application/version=\"13\"") and export_text.contains("version/code=13"))
		or (export_text.contains("application/version=\"14\"") and export_text.contains("version/code=14"))
		or (export_text.contains("application/version=\"15\"") and export_text.contains("version/code=15"))
	)
	if not compatible_build:
		_fail(815, "v1.6.2 premium reference: compatible build missing")
		return

	print("ONE MORE FLOOR v1.6.2 premium reference smoke test passed")
	quit(0)
