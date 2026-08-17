extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(1001,"v1.9 runtime UI: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame

	if not game.has_method("_v21_runtime_ui_ready") or not game._v21_runtime_ui_ready():
		_fail(1002,"v1.9 runtime UI renderer compatibility is not active")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	var live_renderer := (
		scene_text.contains("main_v21.gd")
		or scene_text.contains("main_v22.gd")
		or scene_text.contains("main_v23.gd")
		or scene_text.contains("main_v35.gd")
		or scene_text.contains("main_v36.gd")
		or scene_text.contains("main_v37.gd")
		or scene_text.contains("main_v38.gd")
		or scene_text.contains("main_v39.gd")
	)
	if not live_renderer or scene_text.contains("main_v20.gd"):
		_fail(1003,"v1.9+ main scene is not using the live UI renderer")
		return

	var renderer := FileAccess.get_file_as_string("res://scripts/main_v21.gd")
	for forbidden in ["home_0.b64","_v20_load_chunked_webp","draw_texture_rect(tex_v20_home"]:
		if renderer.contains(forbidden):
			_fail(1004,"v1.9 raster overlay regression: %s" % forbidden)
			return
	for required in ["func _v21_live_medallion","func _v21_home_tab","func _v21_action_button","func draw_home"]:
		if not renderer.contains(required):
			_fail(1005,"v1.9 live UI component missing: %s" % required)
			return

	var project_text := FileAccess.get_file_as_string("res://project.godot")
	var version_ok := (
		project_text.contains("config/version=\"1.9.0-runtime-ui\"")
		or project_text.contains("config/version=\"1.10.0-premium-components\"")
		or project_text.contains("config/version=\"1.24.0\"")
		or project_text.contains("config/version=\"1.25.0\"")
		or project_text.contains("config/version=\"1.26.0\"")
	)
	if not version_ok:
		_fail(1006,"v1.9+ project version missing")
		return

	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	var ios_ok := (
		(export_text.contains("application/short_version=\"1.9.0\"") and export_text.contains("application/version=\"14\""))
		or (export_text.contains("application/short_version=\"1.10.0\"") and export_text.contains("application/version=\"15\""))
		or (export_text.contains("application/short_version=\"1.24.0\"") and (export_text.contains("application/version=\"16\"") or export_text.contains("application/version=\"17\"")))
		or (export_text.contains("application/short_version=\"1.25.0\"") and export_text.contains("application/version=\"18\""))
		or (export_text.contains("application/short_version=\"1.26.0\"") and (export_text.contains("application/version=\"19\"") or export_text.contains("application/version=\"20\"")))
	)
	if not ios_ok:
		_fail(1007,"v1.9+ iOS version/build missing")
		return
	if export_text.contains("include_filter=\"assets/art/reference/*.b64\""):
		_fail(1008,"v1.9+ raster reference payload is still included in mobile export")
		return

	game.tutorial_active = false
	game.settings_open = false
	game.state = game.State.HOME
	game.home_overlay = ""

	game.pointer(game.MISSIONS_BTN.get_center(),true,201)
	if game.home_overlay != "missions":
		_fail(1009,"v1.9 Missions button is not wired")
		return
	game.pointer(game.OVERLAY_BACK.get_center(),true,202)
	if game.home_overlay != "":
		_fail(1010,"v1.9 Missions BACK does not return Home")
		return

	game.pointer(game.PASS_BTN.get_center(),true,203)
	if game.home_overlay != "pass":
		_fail(1011,"v1.9 Tower Pass button is not wired")
		return
	game.pointer(game.OVERLAY_BACK.get_center(),true,204)
	if game.home_overlay != "":
		_fail(1012,"v1.9 Tower Pass BACK does not return Home")
		return

	for rect in [game.HERO_TAB,game.FORGE_TAB,game.TALENTS_TAB,game.VAULT_TAB]:
		if not rect.has_point(rect.get_center()):
			_fail(1013,"v1.9 bottom tab hitbox regression")
			return

	print("ONE MORE FLOOR v1.9 runtime UI smoke test passed")
	quit(0)
