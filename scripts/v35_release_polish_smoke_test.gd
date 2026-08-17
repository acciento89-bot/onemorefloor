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
	if not (scene_text.contains("main_v35.gd") or scene_text.contains("main_v36.gd") or scene_text.contains("main_v37.gd") or scene_text.contains("main_v38.gd") or scene_text.contains("main_v39.gd")):
		_fail(2404, "v1.24+ runtime: compatible release renderer missing")
		return
	var project_text := FileAccess.get_file_as_string("res://project.godot")
	if not (project_text.contains("config/version=\"1.24.0\"") or project_text.contains("config/version=\"1.25.0\"") or project_text.contains("config/version=\"1.26.0\"")):
		_fail(2405, "v1.24+ release: compatible project version missing")
		return
	var export_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	var export_ok := (
		(export_text.contains("application/version=\"16\"") and export_text.contains("application/short_version=\"1.24.0\""))
		or (export_text.contains("application/version=\"17\"") and export_text.contains("application/short_version=\"1.24.0\""))
		or (export_text.contains("application/version=\"18\"") and export_text.contains("application/short_version=\"1.25.0\""))
		or (export_text.contains("application/version=\"19\"") and export_text.contains("application/short_version=\"1.26.0\""))
		or (export_text.contains("application/version=\"20\"") and export_text.contains("application/short_version=\"1.26.0\""))
	)
	if not export_ok:
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
