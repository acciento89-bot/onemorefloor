extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(901,"v1.7 menus: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	if not game.has_method("draw_home") or not game.has_method("draw_vault_screen") or not game.has_method("draw_pass_screen"):
		_fail(902,"v1.7 menus: renderer methods missing")
		return
	if not game.has_method("_v19_mission_row") or not game.has_method("_v19_vault_item"):
		_fail(903,"v1.7 menus: reference menu renderer not active")
		return
	for texture in [game.tex_v19_home,game.tex_v19_arcane,game.tex_v19_forge]:
		if texture == null:
			_fail(904,"v1.7 menus: premium menu art failed to import")
			return
		if texture.get_width() < 720 or texture.get_height() < 1280:
			_fail(905,"v1.7 menus: premium menu art undersized")
			return
	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	var compatible_renderer := (
		scene_text.contains("main_v19.gd")
		or scene_text.contains("main_v20.gd")
		or scene_text.contains("main_v21.gd")
		or scene_text.contains("main_v22.gd")
	)
	if not compatible_renderer:
		_fail(906,"v1.7 menus: compatible v19+ main renderer is not active")
		return
	var project_text := FileAccess.get_file_as_string("res://project.godot")
	var compatible_version := (
		project_text.contains("config/version=\"1.7.0-reference-menus\"")
		or project_text.contains("config/version=\"1.8.0-raster-reference\"")
		or project_text.contains("config/version=\"1.9.0-runtime-ui\"")
		or project_text.contains("config/version=\"1.10.0-premium-components\"")
	)
	if not compatible_version:
		_fail(907,"v1.7 menus: compatible project version missing")
		return
	if not project_text.contains("pointing/emulate_mouse_from_touch=false"):
		_fail(908,"v1.7 menus: touch hardening regressed")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	var ios_ok := (
		(export_text.contains("application/short_version=\"1.7.0\"") and export_text.contains("application/version=\"12\""))
		or (export_text.contains("application/short_version=\"1.8.0\"") and export_text.contains("application/version=\"13\""))
		or (export_text.contains("application/short_version=\"1.9.0\"") and export_text.contains("application/version=\"14\""))
		or (export_text.contains("application/short_version=\"1.10.0\"") and export_text.contains("application/version=\"15\""))
	)
	if not ios_ok:
		_fail(909,"v1.7 menus: compatible iOS version/build missing")
		return
	var android_ok := (
		(export_text.contains("version/name=\"1.7.0\"") and export_text.contains("version/code=12"))
		or (export_text.contains("version/name=\"1.8.0\"") and export_text.contains("version/code=13"))
		or (export_text.contains("version/name=\"1.9.0\"") and export_text.contains("version/code=14"))
		or (export_text.contains("version/name=\"1.10.0\"") and export_text.contains("version/code=15"))
	)
	if not android_ok:
		_fail(910,"v1.7 menus: compatible Android version/build missing")
		return
	# Prove the moved Hero and Forge buttons still reach the real progression system.
	game.tutorial_active = false
	game.state = game.State.HERO
	var hero_before := int(game.meta.hero_level)
	game.meta.coins = maxi(int(game.meta.coins),int(game.meta.hero_cost())+100)
	game.pointer(game.V19_HERO_BUY.get_center(),true,71)
	if int(game.meta.hero_level) != hero_before + 1:
		_fail(911,"v1.7 menus: Hero TRAIN visual hitbox is not wired")
		return
	game.state = game.State.FORGE
	var forge_before := int(game.meta.forge_level)
	game.meta.coins = maxi(int(game.meta.coins),int(game.meta.forge_cost())+100)
	game.pointer(game.V19_FORGE_BUY.get_center(),true,72)
	if int(game.meta.forge_level) != forge_before + 1:
		_fail(912,"v1.7 menus: Forge TEMPER visual hitbox is not wired")
		return
	print("ONE MORE FLOOR v1.7 reference menu smoke test passed")
	quit(0)
