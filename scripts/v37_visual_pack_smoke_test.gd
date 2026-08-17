extends SceneTree

const VisualPackManager = preload("res://scripts/visual_pack_manager.gd")

func _init() -> void:
	var packs = VisualPackManager.new()
	packs.best_floor = 1
	if packs.unlocked_count() != 1 or packs.highest_unlocked() != "citadel":
		_fail(2501, "v1.25 packs: starter pack unlock state broken")
		return
	packs.best_floor = 50
	if packs.unlocked_count() != 2 or not packs.is_unlocked("void"):
		_fail(2502, "v1.25 packs: Floor 50 Void unlock missing")
		return
	packs.best_floor = 100
	if not packs.is_unlocked("eclipse"):
		_fail(2503, "v1.25 packs: Floor 100 Eclipse unlock missing")
		return
	packs.best_floor = 150
	if not packs.is_unlocked("bloodstar"):
		_fail(2504, "v1.25 packs: Floor 150 Bloodstar unlock missing")
		return
	packs.best_floor = 200
	if packs.unlocked_count() != 5 or packs.highest_unlocked() != "celestial":
		_fail(2505, "v1.25 packs: Floor 200 Celestial unlock missing")
		return
	packs.selected = "citadel"
	if packs.cycle(1) != "void":
		_fail(2506, "v1.25 packs: cycle order broken")
		return
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(2507, "v1.25 runtime: main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	if not game.has_method("_v37_corner_runes") or not game.has_method("_pointer_settings"):
		_fail(2508, "v1.25 runtime: visual pack renderer not active")
		return
	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not (scene_text.contains("main_v37.gd") or scene_text.contains("main_v38.gd")):
		_fail(2509, "v1.25+ runtime: visual pack successor is not active")
		return
	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not (project_text.contains("config/version=\"1.25.0\"") or project_text.contains("config/version=\"1.26.0\"")):
		_fail(2510, "v1.25+ project version missing")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	var mobile_ok := (
		(export_text.contains("application/short_version=\"1.25.0\"") and export_text.contains("application/version=\"18\""))
		or (export_text.contains("application/short_version=\"1.26.0\"") and export_text.contains("application/version=\"19\""))
	)
	if not mobile_ok:
		_fail(2511, "v1.25+ mobile build config missing")
		return
	print("ONE MORE FLOOR v1.25 visual pack smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
