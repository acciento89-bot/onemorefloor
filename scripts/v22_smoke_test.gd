extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(1101,"v1.10 premium components: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame

	if not game.has_method("_v22_runtime_component_ready") or not game._v22_runtime_component_ready():
		_fail(1102,"v1.10 premium component renderer is not active")
		return
	if game.tex_v22_skins == null or game.tex_v22_skins.get_width() < 360 or game.tex_v22_skins.get_height() < 576:
		_fail(1103,"v1.10 button/frame skin sheet failed to import")
		return
	if game.tex_v22_icons == null or game.tex_v22_icons.get_width() < 512 or game.tex_v22_icons.get_height() < 256:
		_fail(1104,"v1.10 icon atlas failed to import")
		return
	if game.tex_v22_medallion == null or game.tex_v22_medallion.get_width() < 128 or game.tex_v22_medallion.get_height() < 128:
		_fail(1105,"v1.10 medallion component failed to import")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	var component_renderer := scene_text.contains("main_v22.gd") or scene_text.contains("main_v23.gd")
	if not component_renderer or scene_text.contains("main_v20.gd"):
		_fail(1106,"v1.10+ main scene is not using component runtime renderer")
		return

	var renderer := FileAccess.get_file_as_string("res://scripts/main_v22.gd")
	for required in ["concept_button_skins.svg","ui_icon_atlas_v22.svg","ui_medallion_shell_v22.svg","func _v22_nine_slice","func _v16_frame","func _v16_button","func _v16_medallion"]:
		if not renderer.contains(required):
			_fail(1107,"v1.10 component renderer missing %s" % required)
			return
	for forbidden in ["home_0.b64","_v20_load_chunked_webp","tex_v20_home"]:
		if renderer.contains(forbidden):
			_fail(1108,"v1.10 full-screen raster regression: %s" % forbidden)
			return

	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("config/version=\"1.10.0-premium-components\""):
		_fail(1109,"v1.10 project version missing")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_text.contains("application/short_version=\"1.10.0\"") or not export_text.contains("application/version=\"15\""):
		_fail(1110,"v1.10 iOS version/build missing")
		return
	if not export_text.contains("version/name=\"1.10.0\"") or not export_text.contains("version/code=15"):
		_fail(1111,"v1.10 Android version/build missing")
		return
	if not export_text.contains("exclude_filter=\"assets/art/reference/*.b64\""):
		_fail(1112,"v1.10 old reference raster payload is not excluded")
		return

	game.tutorial_active = false
	game.settings_open = false
	game.state = game.State.HOME
	game.home_overlay = ""
	game.pointer(game.MISSIONS_BTN.get_center(),true,301)
	if game.home_overlay != "missions":
		_fail(1113,"v1.10 Missions navigation regressed")
		return
	game.pointer(game.OVERLAY_BACK.get_center(),true,302)
	if game.home_overlay != "":
		_fail(1114,"v1.10 Missions BACK regressed")
		return
	game.pointer(game.PASS_BTN.get_center(),true,303)
	if game.home_overlay != "pass":
		_fail(1115,"v1.10 Tower Pass navigation regressed")
		return
	game.pointer(game.OVERLAY_BACK.get_center(),true,304)
	if game.home_overlay != "":
		_fail(1116,"v1.10 Tower Pass BACK regressed")
		return

	var tabs: Array = [
		[game.HERO_TAB,game.State.HERO],
		[game.FORGE_TAB,game.State.FORGE],
		[game.TALENTS_TAB,game.State.TALENTS],
		[game.VAULT_TAB,game.State.VAULT],
	]
	for entry in tabs:
		game.state = game.State.HOME
		game.home_overlay = ""
		game.pointer((entry[0] as Rect2).get_center(),true,400+tabs.find(entry))
		if game.state != entry[1]:
			_fail(1117,"v1.10 bottom navigation tab is not wired")
			return

	print("ONE MORE FLOOR v1.10 premium component UI smoke test passed")
	quit(0)
