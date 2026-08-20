extends "res://scripts/release_audio_v2.gd"

# ONE MORE FLOOR v1.72 — priority-aware mobile audio mixer.
# Keeps the accepted generated realm music and existing five authored SFX files,
# but prevents low-priority attack/hit chatter from stealing boss/reward feedback.

const V172_AUDIO_VERSION := "1.72-priority-audio-r1"
const V172_VOICE_LIMIT := 8
const V172_EVENT_PRIORITY := {
	"menu": 1,
	"attack": 1,
	"hit": 1,
	"coin": 2,
	"loot": 3,
	"crit": 3,
	"combo": 3,
	"claim": 4,
	"elite": 4,
	"nova": 5,
	"warden": 5,
	"phase2": 6,
	"boss_down": 7,
	"milestone": 7,
}
const V172_EVENT_COOLDOWN_MSEC := {
	"menu": 18,
	"attack": 24,
	"hit": 30,
	"coin": 36,
	"crit": 48,
	"combo": 60,
	"loot": 72,
	"claim": 110,
	"nova": 180,
	"warden": 220,
	"phase2": 320,
	"boss_down": 420,
	"milestone": 420,
}

var v172_voice_priority: Array[int] = []
var v172_last_event_msec: Dictionary = {}
var v172_events_played := 0
var v172_events_rate_limited := 0
var v172_events_priority_dropped := 0
var v172_priority_preemptions := 0

func setup(settings_ref) -> void:
	super.setup(settings_ref)
	v172_voice_priority.resize(sfx_players.size())
	for index in range(v172_voice_priority.size()):
		v172_voice_priority[index] = 0

func event(name: String) -> void:
	if settings == null or not bool(settings.sfx_enabled):
		return
	var stream = sfx_streams.get(name)
	if stream == null or sfx_players.is_empty():
		return

	var now := int(Time.get_ticks_msec())
	var cooldown := int(V172_EVENT_COOLDOWN_MSEC.get(name, 0))
	var last := int(v172_last_event_msec.get(name, -1000000))
	if cooldown > 0 and now - last < cooldown:
		v172_events_rate_limited += 1
		return

	var priority := v172_event_priority(name)
	var voice_index := _v172_pick_voice(priority)
	if voice_index < 0:
		v172_events_priority_dropped += 1
		return

	var player := sfx_players[voice_index] as AudioStreamPlayer
	if player == null:
		return
	if player.playing:
		player.stop()
		v172_priority_preemptions += 1

	event_counter += 1
	player.stream = stream
	player.pitch_scale = _event_pitch(name, event_counter)
	player.volume_db = linear_to_db(maxf(0.001, float(settings.sfx_volume))) + _event_gain_db(name)
	player.play()
	v172_voice_priority[voice_index] = priority
	v172_last_event_msec[name] = now
	v172_events_played += 1

func v172_event_priority(name: String) -> int:
	return int(V172_EVENT_PRIORITY.get(name, 2))

func v172_active_voice_count() -> int:
	var active := 0
	for value in sfx_players:
		var player := value as AudioStreamPlayer
		if player != null and player.playing:
			active += 1
	return active

func v172_audio_policy_ready() -> bool:
	return sfx_players.size() == V172_VOICE_LIMIT \
		and v172_voice_priority.size() == V172_VOICE_LIMIT \
		and v172_event_priority("attack") < v172_event_priority("claim") \
		and v172_event_priority("claim") < v172_event_priority("boss_down") \
		and int(V172_EVENT_COOLDOWN_MSEC.get("attack", 0)) > 0 \
		and int(V172_EVENT_COOLDOWN_MSEC.get("boss_down", 0)) > int(V172_EVENT_COOLDOWN_MSEC.get("attack", 0))

func v172_audio_snapshot() -> Dictionary:
	return {
		"ready": v172_audio_policy_ready(),
		"version": V172_AUDIO_VERSION,
		"voice_limit": V172_VOICE_LIMIT,
		"active_voices": v172_active_voice_count(),
		"events_played": v172_events_played,
		"rate_limited": v172_events_rate_limited,
		"priority_dropped": v172_events_priority_dropped,
		"priority_preemptions": v172_priority_preemptions,
		"attack_priority": v172_event_priority("attack"),
		"claim_priority": v172_event_priority("claim"),
		"boss_priority": v172_event_priority("boss_down"),
	}

func _v172_pick_voice(priority: int) -> int:
	if v172_voice_priority.size() != sfx_players.size():
		v172_voice_priority.resize(sfx_players.size())
		for index in range(v172_voice_priority.size()):
			v172_voice_priority[index] = 0

	for index in range(sfx_players.size()):
		var player := sfx_players[index] as AudioStreamPlayer
		if player != null and not player.playing:
			return index

	var lowest_index := -1
	var lowest_priority := 999
	for index in range(v172_voice_priority.size()):
		var current := int(v172_voice_priority[index])
		if current < lowest_priority:
			lowest_priority = current
			lowest_index = index

	# Equal/low importance events are dropped under saturation. Only a genuinely
	# more important event may preempt an already-playing voice.
	if lowest_index < 0 or priority <= lowest_priority:
		return -1
	return lowest_index
