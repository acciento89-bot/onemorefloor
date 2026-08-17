extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	for path in [
		"res://assets/art/premium_menu_citadel_v2.svg",
		"res://assets/art/wanderer_v2.svg",
		"res://assets/art/menu_forge_v2.svg"
	]:
		if not FileAccess.file_exists(path):
			_fail(4201, "v1.29 missing production art: %s" % path)
			return
		var tex := load(path) as Texture2D
		if tex == null:
			_fail(4202, "v1.29 production art failed to import: %s" % path)
			return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(4203, "v1.29 main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame

	if not game.has_method("_v42_visual_completion_ready") or not bool(game._v42_visual_completion_ready()):
		_fail(4204, "v1.29 production art renderer is not active")
		return
	for method in ["_v42_store_card", "_v40_draw_wanderer_texture", "draw_forge_screen", "draw_home"]:
		if not game.has_method(method):
			_fail(4205, "v1.29 runtime method missing: %s" % method)
			return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v42.gd") or not scene_text.contains("main_v41.gd"):
		_fail(4206, "v1.29 scene wiring or compatibility baseline missing")
		return
	var renderer := FileAccess.get_file_as_string("res://scripts/main_v42.gd")
	for marker in ["premium_menu_citadel_v2.svg", "wanderer_v2.svg", "menu_forge_v2.svg", "BONUS CACHE", "visual_completion_ready"]:
		if not renderer.contains(marker):
			_fail(4207, "v1.29 renderer marker missing: %s" % marker)
			return
	if renderer.contains("NATIVE PROVIDER REQUIRED BEFORE RELEASE") or renderer.contains("REWARDED TEST"):
		_fail(4208, "v1.29 developer-facing Store copy regressed")
		return

	print("ONE MORE FLOOR v1.29 visual completion smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
