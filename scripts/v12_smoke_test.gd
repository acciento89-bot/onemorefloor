extends SceneTree

func _init() -> void:
	call_deferred("_run_v12_smoke")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run_v12_smoke() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(301, "v1.2 smoke: main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)

	if not game.has_method("_v12_actor_index") or not game.has_method("_v12_icon") or not game.has_method("_v12_meta_header"):
		_fail(302, "v1.2 smoke: production art controller is not active")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("res://scripts/main_v12.gd") and not scene_text.contains("res://scripts/main_v13.gd"):
		_fail(303, "v1.2 smoke: main scene is not using a v1.2 production renderer")
		return

	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("config/version=\"1.2.0-"):
		_fail(304, "v1.2 smoke: project version is not in the 1.2.0 release line")
		return

	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_text.contains("application/short_version=\"1.2.0\""):
		_fail(305, "v1.2 smoke: iOS short version is not 1.2.0")
		return
	if not export_text.contains("version/name=\"1.2.0\""):
		_fail(306, "v1.2 smoke: Android version name is not 1.2.0")
		return

	if game.tex_v12_environment == null:
		_fail(307, "v1.2 smoke: production environment atlas failed to load")
		return
	if game.tex_v12_icons == null:
		_fail(308, "v1.2 smoke: production icon atlas failed to load")
		return
	if game.tex_v12_actors == null:
		_fail(309, "v1.2 smoke: compatibility actor atlas failed to load")
		return

	if game.tex_v12_environment.get_width() < 648 or game.tex_v12_environment.get_height() < 3360:
		_fail(310, "v1.2 smoke: environment atlas dimensions are invalid")
		return
	if game.tex_v12_icons.get_width() < 512 or game.tex_v12_icons.get_height() < 512:
		_fail(311, "v1.2 smoke: icon atlas dimensions are invalid")
		return
	if game.tex_v12_actors.get_width() < 512 or game.tex_v12_actors.get_height() < 576:
		_fail(312, "v1.2 smoke: compatibility actor atlas dimensions are invalid")
		return

	var expected := {
		"goblin": 1,
		"bat": 2,
		"skeleton": 3,
		"ghoul": 4,
		"necromancer": 5,
		"gargoyle": 8,
		"sentinel": 9,
		"hexer": 10,
	}
	for kind in expected.keys():
		if int(game._v12_actor_index(String(kind), "warden")) != int(expected[kind]):
			_fail(313, "v1.2 smoke: actor mapping is wrong for %s" % String(kind))
			return
	if int(game._v12_actor_index("warden", "warden")) != 6:
		_fail(314, "v1.2 smoke: Warden actor mapping is wrong")
		return
	if int(game._v12_actor_index("warden", "crypt_keeper")) != 7:
		_fail(315, "v1.2 smoke: Crypt Keeper actor mapping is wrong")
		return
	if int(game._v12_actor_index("warden", "hollow_king")) != 11:
		_fail(316, "v1.2 smoke: Hollow King actor mapping is wrong")
		return

	var controller_text := FileAccess.get_file_as_string("res://scripts/main_v12.gd")
	for required in ["VAULT + FORGE", "TOWER PASS", "FLOOR CLEARED!", "Permanent passive bonuses", "Permanent Wanderer training"]:
		if not controller_text.contains(required):
			_fail(317, "v1.2 smoke: production screen text missing: %s" % required)
			return
	if not controller_text.contains("environment_production.svg") or not controller_text.contains("ui_icons_production.svg"):
		_fail(318, "v1.2 smoke: production art resources are not wired into controller")
		return

	if not game.has_method("screen_to_design") or not game.has_method("_sync_music_context"):
		_fail(319, "v1.2 smoke: responsive/audio v1.1 layer regressed")
		return
	var translated: Vector2 = game.screen_to_design(game.v11_layout_offset + Vector2(360, 640))
	if translated.distance_to(Vector2(360, 640)) > 0.01:
		_fail(320, "v1.2 smoke: touch translation regressed")
		return

	print("ONE MORE FLOOR v1.2 production art smoke test passed")
	quit(0)
