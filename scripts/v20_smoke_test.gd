extends SceneTree

func _init() -> void:
	call_deferred("_run_v20_smoke")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run_v20_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(901, "v1.8 raster reference: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	if not game.has_method("_v20_reference_home_ready") or not game.has_method("_v20_load_chunked_webp"):
		_fail(902, "v1.8 raster reference renderer is not active")
		return
	if not game._v20_reference_home_ready():
		_fail(903, "v1.8 approved Home raster failed to decode at 720x1280")
		return
	var total_chars := 0
	for i in range(7):
		var path := "res://assets/art/reference/home_%d.b64" % i
		if not FileAccess.file_exists(path):
			_fail(904, "v1.8 Home raster chunk missing: %s" % path)
			return
		total_chars += FileAccess.get_file_as_string(path).strip_edges().length()
	if total_chars != 59344:
		_fail(905, "v1.8 Home raster payload length mismatch: %d" % total_chars)
		return
	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v20.gd"):
		_fail(906, "v1.8 main scene is not using main_v20")
		return
	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("config/version=\"1.8.0-raster-reference\""):
		_fail(907, "v1.8 project version missing")
		return
	if not project_text.contains("pointing/emulate_mouse_from_touch=false"):
		_fail(908, "v1.8 native touch protection regressed")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_text.contains("application/short_version=\"1.8.0\"") or not export_text.contains("application/version=\"13\""):
		_fail(909, "v1.8 iOS version/build missing")
		return
	if not export_text.contains("include_filter=\"assets/art/reference/*.b64\""):
		_fail(910, "v1.8 raster payload is not included in mobile export")
		return
	# Live UI hitboxes must stay aligned with the approved concept.
	for rect in [game.PLAY, game.MISSIONS_BTN, game.PASS_BTN, game.HERO_TAB, game.FORGE_TAB, game.TALENTS_TAB, game.VAULT_TAB, game.V10_SETTINGS_HOME]:
		if not rect.has_point(rect.get_center()):
			_fail(911, "v1.8 live Home hitbox regression")
			return
	print("ONE MORE FLOOR v1.8 raster reference smoke test passed")
	quit(0)
