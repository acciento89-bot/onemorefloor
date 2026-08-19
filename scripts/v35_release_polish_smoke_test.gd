extends SceneTree

const ReleaseAudio = preload("res://scripts/release_audio.gd")
const Telemetry = preload("res://scripts/telemetry.gd")
const ReleaseGuard = preload("res://scripts/release_guard.gd")

func _init() -> void:
	var audio = ReleaseAudio.new()
	var contexts: Array[String] = audio.available_music_contexts()
	for required in ["deep", "spire", "void", "eclipse", "bloodstar", "celestial", "boss"]:
		if not required in contexts:
			_fail(2401, "v1.22 audio: missing realm context %s" % required)
			return

	var telemetry = Telemetry.new()
	telemetry.begin_session(false)
	telemetry.set_build_context("1.24.0-polish-release", "16")
	var snapshot: Dictionary = telemetry.diagnostic_snapshot()
	if int(snapshot.get("schema", 0)) < 2 or String(snapshot.get("build", "")) != "16":
		_fail(2402, "v1.24 telemetry: schema/build context failed")
		return
	telemetry.end_session()

	var guard = ReleaseGuard.new()
	if not guard.has_method("validate") or not guard.has_method("backup_last_good"):
		_fail(2403, "v1.24 release guard API missing")
		return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not (scene_text.contains("main_v35.gd") or scene_text.contains("main_v36.gd") or scene_text.contains("main_v37.gd") or scene_text.contains("main_v38.gd") or scene_text.contains("main_v39.gd") or scene_text.contains("baseline retained: res://scripts/main_v35.gd")):
		_fail(2404, "v1.24+ runtime: compatible release renderer missing")
		return
	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not (project_text.contains("config/version=\"1.24.0\"") or project_text.contains("config/version=\"1.25.0\"") or project_text.contains("config/version=\"1.26.0\"")):
		_fail(2405, "v1.24+ release: compatible project version missing")
		return

	# This gate used to enumerate build 16/17/18/19/20 one by one. That made an
	# otherwise valid legacy regression fail as soon as TestFlight moved past 20.
	# Validate the actual preset contract instead: supported short version and a
	# monotonically advanced numeric iOS build number.
	var export_cfg := ConfigFile.new()
	if export_cfg.load("res://export_presets.cfg") != OK:
		_fail(2406, "v1.24+ release: could not read iOS export preset")
		return
	var ios_short_version := String(export_cfg.get_value("preset.0.options", "application/short_version", ""))
	var ios_build_text := String(export_cfg.get_value("preset.0.options", "application/version", "0"))
	var ios_build := int(ios_build_text)
	var supported_short_version := ios_short_version in ["1.24.0", "1.25.0", "1.26.0"]
	if not supported_short_version or ios_build < 16:
		_fail(2406, "v1.24+ release: compatible iOS build/version missing")
		return

	var main_text := FileAccess.get_file_as_string("res://scripts/main_v35.gd")
	for marker in ["_v35_draw_enemy_identity", "_v35_draw_boss_identity", "record_run_summary", "CELESTIAL GRAVE", "set_combat_intensity"]:
		if not main_text.contains(marker):
			_fail(2407, "v1.23-v1.24 runtime marker missing: %s" % marker)
			return

	print("ONE MORE FLOOR v1.24 polish/release smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)