extends SceneTree

# v1.72 feedback/performance smoke: policy, haptic throttling and mobile runtime
# budgets. No subjective audio waveform judgment is attempted in CI.

const MainScene = preload("res://scenes/main.tscn")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var app = MainScene.instantiate()
	root.add_child(app)
	for _i in range(14):
		await process_frame

	if not bool(app.call("_v96_polish_ready")):
		_fail("v1.72 readiness contract failed")
		return
	if Engine.max_fps != 60:
		_fail("mobile frame cap is not 60")
		return
	if String(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")) != "gl_compatibility":
		_fail("renderer is not GL Compatibility")
		return

	var audio = app.get("release_audio")
	if audio == null or not audio.has_method("v172_audio_policy_ready"):
		_fail("priority audio service is missing")
		return
	if not bool(audio.call("v172_audio_policy_ready")):
		_fail("priority audio policy is not ready")
		return
	if int(audio.call("v172_event_priority", "attack")) >= int(audio.call("v172_event_priority", "claim")):
		_fail("claim audio is not above attack priority")
		return
	if int(audio.call("v172_event_priority", "claim")) >= int(audio.call("v172_event_priority", "boss_down")):
		_fail("boss audio is not above claim priority")
		return
	if int(audio.call("v172_active_voice_count")) > 8:
		_fail("active audio voice budget exceeded")
		return

	# Rate limiting is deterministic even when the headless runner cannot produce
	# a physical vibration. A stronger beat must still be allowed through.
	var settings = app.get("settings")
	settings.haptics_enabled = true
	var played_before := int(app.get("v172_haptics_played"))
	var dropped_before := int(app.get("v172_haptics_rate_limited"))
	app.call("haptic", 10)
	app.call("haptic", 10)
	if int(app.get("v172_haptics_played")) < played_before + 1:
		_fail("light haptic was not accepted")
		return
	if int(app.get("v172_haptics_rate_limited")) < dropped_before + 1:
		_fail("repeated light haptic was not rate-limited")
		return
	var played_mid := int(app.get("v172_haptics_played"))
	app.call("haptic", 90)
	if int(app.get("v172_haptics_played")) < played_mid + 1:
		_fail("strong haptic could not break through a light cooldown")
		return

	# Low-priority audio spam should be throttled at the event-policy layer.
	settings.sfx_enabled = true
	var audio_before: Dictionary = audio.call("v172_audio_snapshot")
	audio.call("event", "attack")
	audio.call("event", "attack")
	var audio_after: Dictionary = audio.call("v172_audio_snapshot")
	if int(audio_after.get("events_played", 0)) < int(audio_before.get("events_played", 0)) + 1:
		_fail("attack audio was not accepted")
		return
	if int(audio_after.get("rate_limited", 0)) < int(audio_before.get("rate_limited", 0)) + 1:
		_fail("attack audio spam was not rate-limited")
		return

	var snapshot: Dictionary = app.call("_v96_polish_snapshot")
	var world: Dictionary = snapshot.get("world", {})
	for entry in [
		["enemy_pool", 18],
		["player_shot_pool", 28],
		["enemy_shot_pool", 36],
		["coin_pool", 24],
	]:
		if int(world.get(String(entry[0]), -1)) != int(entry[1]):
			_fail("world pool budget mismatch for %s" % String(entry[0]))
			return
	if not bool(snapshot.get("world_budget_ready", false)) or not bool(snapshot.get("audio_budget_ready", false)):
		_fail("mobile runtime budget is not ready")
		return

	print("V172_FEEDBACK_SNAPSHOT:%s" % JSON.stringify(snapshot))
	print("v1.72 feedback performance smoke test passed")
	app.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V172_FEEDBACK_PERFORMANCE_FAIL:%s" % message)
	quit(1)
