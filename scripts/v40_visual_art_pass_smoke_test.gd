extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(4001, "v1.27 art pass: main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame

	if not game.has_method("_v40_visual_art_pass_ready") or not bool(game._v40_visual_art_pass_ready()):
		_fail(4002, "v1.27 art pass: authored art textures failed to load")
		return
	for method in ["_v40_home_lighting", "_v40_draw_wanderer_texture", "_v40_draw_forge_heat", "draw_hero_screen", "draw_forge_screen"]:
		if not game.has_method(method):
			_fail(4003, "v1.27 art pass: missing renderer method %s" % method)
			return

	var shell := game.get_node_or_null("FullscreenBackdrop")
	if shell == null:
		_fail(4004, "v1.27 art pass: fullscreen backdrop shell is not mounted")
		return
	if not shell.has_method("_sync_to_viewport") or not shell.has_method("_draw_diamond"):
		_fail(4005, "v1.27 art pass: fullscreen shell implementation incomplete")
		return

	if game.tex_v40_hifi == null or game.tex_v40_hifi.get_width() < 720 or game.tex_v40_hifi.get_height() < 1280:
		_fail(4006, "v1.27 art pass: hifi backdrop asset invalid")
		return
	if game.tex_v40_citadel == null or game.tex_v40_citadel.get_width() < 720 or game.tex_v40_citadel.get_height() < 640:
		_fail(4007, "v1.27 art pass: citadel asset invalid")
		return
	if game.tex_v40_wanderer == null or game.tex_v40_wanderer.get_width() < 320 or game.tex_v40_wanderer.get_height() < 480:
		_fail(4008, "v1.27 art pass: Wanderer asset invalid")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v40.gd") or not scene_text.contains("fullscreen_backdrop.gd"):
		_fail(4009, "v1.27 art pass: scene wiring missing")
		return
	var renderer := FileAccess.get_file_as_string("res://scripts/main_v40.gd")
	for asset in ["hifi_menu_backdrop.svg", "premium_menu_citadel.svg", "wanderer.svg"]:
		if not renderer.contains(asset):
			_fail(4010, "v1.27 art pass: authored asset missing from renderer %s" % asset)
			return
	for forbidden in ["home_0.b64", "_v20_load_chunked_webp", "assets/art/reference/"]:
		if renderer.contains(forbidden):
			_fail(4011, "v1.27 art pass: screenshot/reference payload regression %s" % forbidden)
			return

	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	var ios_ok := export_text.contains("application/short_version=\"1.26.0\"") and (export_text.contains("application/version=\"20\"") or export_text.contains("application/version=\"21\""))
	if not ios_ok:
		_fail(4012, "v1.27 art pass: compatible iOS build config missing")
		return
	var android_ok := export_text.contains("version/name=\"1.26.0\"") and (export_text.contains("version/code=20") or export_text.contains("version/code=21"))
	if not android_ok:
		_fail(4013, "v1.27 art pass: compatible Android build config missing")
		return

	print("ONE MORE FLOOR v1.27 fullscreen/home/hero/forge art pass smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
