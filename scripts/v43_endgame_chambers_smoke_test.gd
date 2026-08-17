extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var art_paths := [
		"res://assets/art/realm_void_citadel_v43.svg",
		"res://assets/art/realm_eclipse_sanctum_v43.svg",
		"res://assets/art/realm_bloodstar_keep_v43.svg",
		"res://assets/art/realm_celestial_grave_v43.svg",
	]
	for path in art_paths:
		if not FileAccess.file_exists(path):
			_fail(4301, "v1.30 missing endgame environment art: %s" % path)
			return
		var tex := load(path) as Texture2D
		if tex == null:
			_fail(4302, "v1.30 endgame environment failed to import: %s" % path)
			return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(4303, "v1.30 main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	if not game.has_method("_v43_endgame_chambers_ready") or not bool(game._v43_endgame_chambers_ready()):
		_fail(4304, "v1.30 endgame chamber renderer is not active")
		return

	var expected := {
		"VOID CITADEL": [51, "RIFT BRIDGE", 52, "SOUL FOUNDRY", 53, "THRONE APPROACH"],
		"ECLIPSE SANCTUM": [100, "SUNLESS NAVE", 101, "UMBRA CLOISTER", 102, "CORONA ALTAR"],
		"BLOODSTAR KEEP": [150, "CHAIN HALL", 151, "CRIMSON COURT", 152, "WAR ALTAR"],
		"CELESTIAL GRAVE": [200, "ASTRAL OSSUARY", 201, "GRAVITY CHOIR", 202, "WORLDWOUND"],
	}
	for area in expected.keys():
		var checks: Array = expected[area]
		for i in range(0, checks.size(), 2):
			var floor_no := int(checks[i])
			var chamber := String(checks[i + 1])
			if String(game._v43_chamber_for(String(area), floor_no)) != chamber:
				_fail(4305, "v1.30 chamber mapping mismatch for %s floor %d" % [area, floor_no])
				return

	for method in ["_v43_fire_chamber_pulse", "_v43_chamber_reward_multiplier", "_draw_room_floor", "_draw_room_architecture"]:
		if not game.has_method(method):
			_fail(4306, "v1.30 runtime method missing: %s" % method)
			return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v43.gd") or not scene_text.contains("main_v42.gd"):
		_fail(4307, "v1.30 scene wiring or v1.29 compatibility baseline missing")
		return
	var renderer := FileAccess.get_file_as_string("res://scripts/main_v43.gd")
	for marker in ["RIFT BRIDGE", "CORONA ALTAR", "WAR ALTAR", "WORLDWOUND", "v43_chamber_timer", "v43_chamber_reward"]:
		if not renderer.contains(marker):
			_fail(4308, "v1.30 chamber marker missing: %s" % marker)
			return

	print("ONE MORE FLOOR v1.30 endgame chambers smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
