extends SceneTree

const VisualPackManager = preload("res://scripts/visual_pack_manager.gd")

func _init() -> void:
	var packs = VisualPackManager.new()
	packs.best_floor = 200
	if packs.unlocked_count() != 5:
		_fail(2601,"v1.26 graphics packs: unlock set incomplete")
		return
	if packs.primary_for("void") == packs.primary_for("bloodstar"):
		_fail(2602,"v1.26 graphics packs: pack palettes collapsed")
		return
	if packs.unlock_floor_for("celestial") != 200:
		_fail(2603,"v1.26 graphics packs: Celestial unlock milestone changed")
		return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(2604,"v1.26 runtime: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	for method in ["_v38_draw_pack_halo","_v38_frame_motif","_v38_draw_arena_skin","_v38_diamond"]:
		if not game.has_method(method):
			_fail(2605,"v1.26 runtime: missing %s" % method)
			return
	if not game.has_method("_v22_runtime_component_ready") or not game._v22_runtime_component_ready():
		_fail(2606,"v1.26 runtime: live component renderer regressed")
		return

	var renderer := FileAccess.get_file_as_string("res://scripts/main_v38.gd")
	for required in ["func _v16_frame","func _v16_button","func _v16_medallion","func _v16_backdrop","func draw_game"]:
		if not renderer.contains(required):
			_fail(2607,"v1.26 renderer missing override %s" % required)
			return
	for forbidden in ["home_0.b64","_v20_load_chunked_webp","tex_v20_home"]:
		if renderer.contains(forbidden):
			_fail(2608,"v1.26 screenshot/raster UI regression: %s" % forbidden)
			return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v38.gd"):
		_fail(2609,"v1.26 runtime: main_v38 is not active")
		return
	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("config/version=\"1.26.0\""):
		_fail(2610,"v1.26 project version missing")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_text.contains("application/short_version=\"1.26.0\"") or not export_text.contains("application/version=\"19\""):
		_fail(2611,"v1.26 iOS build 19 config missing")
		return
	if not export_text.contains("version/name=\"1.26.0\"") or not export_text.contains("version/code=19"):
		_fail(2612,"v1.26 Android build 19 config missing")
		return

	print("ONE MORE FLOOR v1.26 graphics packs 2 smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
