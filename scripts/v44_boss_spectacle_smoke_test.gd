extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var art := [
		"res://assets/art/boss_crest_void_archon_v44.svg",
		"res://assets/art/boss_crest_eclipse_regent_v44.svg",
		"res://assets/art/boss_crest_bloodstar_tyrant_v44.svg",
		"res://assets/art/boss_crest_world_eater_v44.svg",
	]
	for path in art:
		if not FileAccess.file_exists(path):
			_fail(4401, "v1.31 boss crest missing: %s" % path)
			return
		if load(path) as Texture2D == null:
			_fail(4402, "v1.31 boss crest failed to import: %s" % path)
			return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(4403, "v1.31 main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	if not game.has_method("_v44_boss_spectacle_ready") or not bool(game._v44_boss_spectacle_ready()):
		_fail(4404, "v1.31 boss spectacle runtime is not active")
		return
	if int(game._v44_boss_stage_for_ratio(0.90)) != 1 or int(game._v44_boss_stage_for_ratio(0.50)) != 2 or int(game._v44_boss_stage_for_ratio(0.20)) != 3:
		_fail(4405, "v1.31 three-phase thresholds regressed")
		return
	for variant in ["void_archon", "eclipse_regent", "bloodstar_tyrant", "world_eater"]:
		if String(game._v44_phase_name(variant, 1)).is_empty() or String(game._v44_phase_name(variant, 3)).is_empty():
			_fail(4406, "v1.31 boss phase identity missing: %s" % variant)
			return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v44.gd") or not scene_text.contains("main_v43.gd"):
		_fail(4407, "v1.31 scene wiring or v1.30 compatibility baseline missing")
		return
	var renderer := FileAccess.get_file_as_string("res://scripts/main_v44.gd")
	for marker in ["BOSS SPECTACLE", "boss_encounter_start", "boss_phase", "CITADEL UNBOUND", "BLACK SUN", "RED CROWN", "LAST STAR", "v44_boss_phase"]:
		if not renderer.to_upper().contains(marker.to_upper()):
			_fail(4408, "v1.31 renderer marker missing: %s" % marker)
			return

	print("ONE MORE FLOOR v1.31 boss spectacle smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
