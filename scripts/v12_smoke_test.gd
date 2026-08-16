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

	if not game.has_method("_f12_panel") or not game.has_method("_f12_draw_actor_region"):
		_fail(302, "v1.2 smoke: production fantasy controller is not active")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("res://scripts/main_v12.gd"):
		_fail(303, "v1.2 smoke: main scene does not point to main_v12.gd")
		return

	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not project_text.contains("config/version=\"1.2.0-rc1\""):
		_fail(304, "v1.2 smoke: project version is not 1.2.0-rc1")
		return
	if not project_text.contains("window/stretch/aspect=\"expand\""):
		_fail(305, "v1.2 smoke: responsive expand canvas was lost")
		return

	if game.tex_fantasy_actors == null:
		_fail(306, "v1.2 smoke: fantasy actor atlas did not import")
		return
	if game.tex_fantasy_actors.get_width() < 1600 or game.tex_fantasy_actors.get_height() < 1200:
		_fail(307, "v1.2 smoke: fantasy actor atlas dimensions are invalid")
		return
	if game.tex_fantasy_biomes == null:
		_fail(308, "v1.2 smoke: fantasy biome atlas did not import")
		return
	if game.tex_fantasy_biomes.get_width() < 2592 or game.tex_fantasy_biomes.get_height() < 840:
		_fail(309, "v1.2 smoke: fantasy biome atlas dimensions are invalid")
		return

	var controller_text := FileAccess.get_file_as_string("res://scripts/main_v12.gd")
	for required in [
		"fantasy_actor_atlas.svg",
		"fantasy_biomes.svg",
		"func draw_home()",
		"func draw_hero_screen()",
		"func draw_forge_screen()",
		"func draw_talents_screen()",
		"func draw_vault_screen()",
		"func draw_missions_screen()",
		"func draw_pass_screen()",
		"func draw_upgrade()",
		"func draw_decision()",
		"func draw_game_over()",
		"func _draw_combat_hud()"
	]:
		if not controller_text.contains(required):
			_fail(310, "v1.2 smoke: missing production visual surface %s" % required)
			return

	for legacy_label in [
		"v0.3 META PROGRESSION",
		"v0.4 LOOT + MISSIONS",
		"v0.6 VISUAL PRODUCTION",
		"v0.8 ANIMATION + VAULT",
		"v0.9 FORGOTTEN CASTLE",
		"v1.0 RC1"
	]:
		if controller_text.contains(legacy_label):
			_fail(311, "v1.2 smoke: legacy development label leaked into production skin")
			return

	var expected_rows := {
		"goblin": 1,
		"bat": 2,
		"skeleton": 3,
		"ghoul": 4,
		"necromancer": 5,
		"gargoyle": 8,
		"sentinel": 9,
		"hexer": 10
	}
	for kind in expected_rows:
		if int(game._motion_row(kind)) != int(expected_rows[kind]):
			_fail(312, "v1.2 smoke: actor row mismatch for %s" % kind)
			return
	if int(game._motion_row("warden", "crypt_keeper")) != 7:
		_fail(313, "v1.2 smoke: Crypt Keeper row mismatch")
		return
	if int(game._motion_row("warden", "hollow_king")) != 11:
		_fail(314, "v1.2 smoke: Hollow King row mismatch")
		return

	if game.release_audio == null:
		_fail(315, "v1.2 smoke: release audio regression")
		return
	for context in ["menu", "dungeon", "crypt", "castle", "boss"]:
		if not game.release_audio.available_music_contexts().has(context):
			_fail(316, "v1.2 smoke: missing music context %s" % context)
			return

	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	if not export_text.contains("application/short_version=\"1.2.0\"") or not export_text.contains("application/version=\"3\""):
		_fail(317, "v1.2 smoke: iOS version/build metadata is wrong")
		return
	if not export_text.contains("version/code=3") or not export_text.contains("version/name=\"1.2.0\""):
		_fail(318, "v1.2 smoke: Android version/build metadata is wrong")
		return

	print("ONE MORE FLOOR v1.2 production art smoke test passed")
	quit(0)
