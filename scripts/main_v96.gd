extends "res://scripts/main_v95.gd"

# ONE MORE FLOOR v1.72 r1 — Audio / Haptics / Device Performance Polish.
# Prioritizes existing feedback and enforces mobile runtime budgets without
# changing combat, progression, camera, actor geometry or accepted visual locks.

const ReleaseAudioV3 = preload("res://scripts/release_audio_v3.gd")
const V96_POLISH_VERSION := "1.72-feedback-performance-r1"
const V96_HAPTIC_LIGHT_MAX := 24
const V96_HAPTIC_MEDIUM_MAX := 69
const V96_HAPTIC_LIGHT_COOLDOWN := 42
const V96_HAPTIC_MEDIUM_COOLDOWN := 68
const V96_HAPTIC_STRONG_COOLDOWN := 110
const V96_EXPECTED_POOLS := {
	"enemy_pool": 18,
	"player_shot_pool": 28,
	"enemy_shot_pool": 36,
	"coin_pool": 24,
}

var v172_last_haptic_msec := -1000000
var v172_last_haptic_strength := 0
var v172_haptics_played := 0
var v172_haptics_rate_limited := 0
var v172_semantic_haptics := 0

func _ready() -> void:
	super._ready()
	# Upgrade only the feedback service. Realm music composition, user settings
	# and all existing event call sites remain inherited.
	var old_audio := release_audio as Node
	if old_audio != null and is_instance_valid(old_audio):
		if old_audio.get_parent() == self:
			remove_child(old_audio)
		old_audio.free()
	release_audio = ReleaseAudioV3.new()
	add_child(release_audio)
	release_audio.setup(settings)
	_sync_music_context(true)
	if telemetry != null:
		telemetry.event("feedback_performance_v172_ready", _v96_polish_snapshot())

func _audio(name: String) -> void:
	if release_audio != null:
		release_audio.event(name)
	else:
		super._audio(name)

	# Reward/completion beats were previously audio-only. Keep combat spam silent
	# haptically and add touch feedback only to infrequent, meaningful outcomes.
	match name:
		"loot":
			v172_semantic_haptics += 1
			haptic(16)
		"claim":
			v172_semantic_haptics += 1
			haptic(28)
		"boss_down":
			v172_semantic_haptics += 1
			haptic(78)
		"milestone":
			v172_semantic_haptics += 1
			haptic(58)

func haptic(duration_ms: int) -> void:
	if settings == null or not bool(settings.haptics_enabled):
		return
	var duration := clampi(duration_ms, 8, 140)
	var strength := _v172_haptic_strength(duration)
	var cooldown := _v172_haptic_cooldown(strength)
	var now := int(Time.get_ticks_msec())
	var elapsed_since := now - v172_last_haptic_msec

	# A stronger beat may break through a lighter recent beat, but equal/lower
	# feedback is rate-limited so dense combat never turns into continuous buzz.
	if elapsed_since < cooldown and strength <= v172_last_haptic_strength:
		v172_haptics_rate_limited += 1
		return

	Input.vibrate_handheld(duration)
	v172_last_haptic_msec = now
	v172_last_haptic_strength = strength
	v172_haptics_played += 1

func _v172_haptic_strength(duration_ms: int) -> int:
	if duration_ms <= V96_HAPTIC_LIGHT_MAX:
		return 1
	if duration_ms <= V96_HAPTIC_MEDIUM_MAX:
		return 2
	return 3

func _v172_haptic_cooldown(strength: int) -> int:
	match strength:
		1: return V96_HAPTIC_LIGHT_COOLDOWN
		2: return V96_HAPTIC_MEDIUM_COOLDOWN
		_: return V96_HAPTIC_STRONG_COOLDOWN

func _v172_world_budget_ready() -> bool:
	if v52_world_root == null or not v52_world_root.has_method("debug_snapshot"):
		return false
	var snapshot: Dictionary = v52_world_root.call("debug_snapshot")
	for key_value in V96_EXPECTED_POOLS.keys():
		var key := String(key_value)
		if int(snapshot.get(key, -1)) != int(V96_EXPECTED_POOLS[key]):
			return false
	return true

func _v172_audio_budget_ready() -> bool:
	return release_audio != null \
		and release_audio.has_method("v172_audio_policy_ready") \
		and bool(release_audio.call("v172_audio_policy_ready")) \
		and int(release_audio.call("v172_active_voice_count")) <= 8

func _v172_mobile_budget_ready() -> bool:
	if Engine.max_fps != 60:
		return false
	if String(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")) != "gl_compatibility":
		return false
	if v52_world_viewport == null or v52_world_viewport.msaa_3d != Viewport.MSAA_2X:
		return false
	return _v172_world_budget_ready() and _v172_audio_budget_ready()

func _v96_polish_ready() -> bool:
	return _v95_ux_completion_ready() \
		and _v172_mobile_budget_ready() \
		and _v172_haptic_strength(16) == 1 \
		and _v172_haptic_strength(38) == 2 \
		and _v172_haptic_strength(90) == 3

func _v96_polish_snapshot() -> Dictionary:
	var audio_snapshot: Dictionary = {}
	if release_audio != null and release_audio.has_method("v172_audio_snapshot"):
		audio_snapshot = release_audio.call("v172_audio_snapshot")
	var world_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("debug_snapshot"):
		world_snapshot = v52_world_root.call("debug_snapshot")
	return {
		"ready": _v96_polish_ready(),
		"version": V96_POLISH_VERSION,
		"ux_v171_preserved": _v95_ux_completion_ready(),
		"max_fps": Engine.max_fps,
		"renderer": String(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")),
		"msaa_3d": int(v52_world_viewport.msaa_3d) if v52_world_viewport != null else -1,
		"world_budget_ready": _v172_world_budget_ready(),
		"audio_budget_ready": _v172_audio_budget_ready(),
		"haptics_played": v172_haptics_played,
		"haptics_rate_limited": v172_haptics_rate_limited,
		"semantic_haptics": v172_semantic_haptics,
		"audio": audio_snapshot,
		"world": world_snapshot,
	}
