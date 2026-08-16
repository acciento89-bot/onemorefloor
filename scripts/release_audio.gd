extends Node

# v1.22 — combat/audio polish.
# Keeps the game dependency-free while giving every late-game realm its own
# musical identity and making repeated combat SFX less machine-gun identical.

var settings
var music_player: AudioStreamPlayer
var music_player_b: AudioStreamPlayer
var music_players: Array[AudioStreamPlayer] = []
var music_streams: Dictionary = {}
var music_context: String = "menu"
var active_music_index: int = 0
var pending_music_index: int = -1
var crossfade_time: float = 0.0
var music_intensity: float = 0.0
const CROSSFADE_DURATION := 1.15

var sfx_players: Array[AudioStreamPlayer] = []
var sfx_streams: Dictionary = {}
var next_sfx: int = 0
var event_counter: int = 0

func setup(settings_ref) -> void:
	settings = settings_ref
	music_player = AudioStreamPlayer.new()
	music_player_b = AudioStreamPlayer.new()
	add_child(music_player)
	add_child(music_player_b)
	music_players = [music_player, music_player_b]
	music_streams = {
		"menu": _make_music_stream("menu"),
		"dungeon": _make_music_stream("dungeon"),
		"crypt": _make_music_stream("crypt"),
		"castle": _make_music_stream("castle"),
		"deep": _make_music_stream("deep"),
		"spire": _make_music_stream("spire"),
		"void": _make_music_stream("void"),
		"eclipse": _make_music_stream("eclipse"),
		"bloodstar": _make_music_stream("bloodstar"),
		"celestial": _make_music_stream("celestial"),
		"boss": _make_music_stream("boss")
	}
	music_player.stream = music_streams["menu"]
	music_player_b.stream = music_streams["dungeon"]
	music_player.finished.connect(_on_music_finished.bind(0))
	music_player_b.finished.connect(_on_music_finished.bind(1))
	for _i in range(8):
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
	sfx_streams = {
		"menu": load("res://assets/audio/menu_click.wav"),
		"attack": load("res://assets/audio/attack.wav"),
		"hit": load("res://assets/audio/attack.wav"),
		"crit": load("res://assets/audio/loot.wav"),
		"coin": load("res://assets/audio/loot.wav"),
		"loot": load("res://assets/audio/loot.wav"),
		"claim": load("res://assets/audio/loot.wav"),
		"combo": load("res://assets/audio/loot.wav"),
		"elite": load("res://assets/audio/boss.wav"),
		"boss_down": load("res://assets/audio/boss.wav"),
		"milestone": load("res://assets/audio/boss.wav"),
		"nova": load("res://assets/audio/nova.wav"),
		"warden": load("res://assets/audio/boss.wav"),
		"phase2": load("res://assets/audio/boss.wav")
	}
	apply_settings()

func _process(delta: float) -> void:
	if pending_music_index < 0 or settings == null or not bool(settings.music_enabled):
		return
	crossfade_time = maxf(0.0, crossfade_time - delta)
	var t: float = 1.0 - crossfade_time / CROSSFADE_DURATION
	var target_db: float = _music_volume_db()
	music_players[active_music_index].volume_db = lerpf(target_db, -48.0, t)
	music_players[pending_music_index].volume_db = lerpf(-48.0, target_db, t)
	if crossfade_time <= 0.0:
		music_players[active_music_index].stop()
		active_music_index = pending_music_index
		pending_music_index = -1
		music_players[active_music_index].volume_db = target_db

func apply_settings() -> void:
	if settings == null:
		return
	var target_db: float = _music_volume_db()
	for p in sfx_players:
		p.volume_db = linear_to_db(maxf(0.001, float(settings.sfx_volume)))
	if bool(settings.music_enabled):
		if not music_players[active_music_index].playing:
			music_players[active_music_index].stream = music_streams.get(music_context, music_streams["menu"])
			music_players[active_music_index].volume_db = target_db
			music_players[active_music_index].play()
		elif pending_music_index < 0:
			music_players[active_music_index].volume_db = target_db
	else:
		for p in music_players:
			p.stop()
		pending_music_index = -1
		crossfade_time = 0.0

func set_music_context(context: String) -> void:
	var next_context: String = context if music_streams.has(context) else "menu"
	if next_context == music_context and music_players[active_music_index].stream != null:
		return
	music_context = next_context
	var stream = music_streams.get(music_context)
	if stream == null:
		return
	if settings == null or not bool(settings.music_enabled):
		music_players[active_music_index].stream = stream
		return
	if pending_music_index >= 0:
		music_players[pending_music_index].stop()
		pending_music_index = -1
		crossfade_time = 0.0
	if not music_players[active_music_index].playing:
		music_players[active_music_index].stream = stream
		music_players[active_music_index].volume_db = _music_volume_db()
		music_players[active_music_index].play()
		return
	pending_music_index = 1 - active_music_index
	music_players[pending_music_index].stop()
	music_players[pending_music_index].stream = stream
	music_players[pending_music_index].volume_db = -48.0
	music_players[pending_music_index].play()
	crossfade_time = CROSSFADE_DURATION

func set_combat_intensity(value: float) -> void:
	music_intensity = clampf(value, 0.0, 1.0)
	if settings == null or pending_music_index >= 0:
		return
	music_players[active_music_index].volume_db = _music_volume_db()

func event(name: String) -> void:
	if settings == null or not bool(settings.sfx_enabled):
		return
	var stream = sfx_streams.get(name)
	if stream == null or sfx_players.is_empty():
		return
	var p: AudioStreamPlayer = sfx_players[next_sfx % sfx_players.size()]
	next_sfx += 1
	event_counter += 1
	p.stream = stream
	p.pitch_scale = _event_pitch(name, event_counter)
	p.volume_db = linear_to_db(maxf(0.001, float(settings.sfx_volume))) + _event_gain_db(name)
	p.play()

func _event_pitch(name: String, sequence: int) -> float:
	var wobble := sin(float(sequence) * 1.731) * 0.035
	match name:
		"attack": return 1.00 + wobble
		"hit": return 0.93 + wobble * 0.7
		"crit": return 1.14 + wobble
		"coin": return 1.10 + wobble
		"loot": return 1.02 + wobble * 0.5
		"claim": return 1.08
		"combo": return 1.18 + minf(0.10, float(sequence % 5) * 0.018)
		"elite": return 0.86
		"warden": return 0.82
		"phase2": return 0.74
		"boss_down": return 0.68
		"milestone": return 0.62
		"nova": return 0.92
	return 1.0

func _event_gain_db(name: String) -> float:
	match name:
		"attack": return -5.0
		"hit": return -7.0
		"coin": return -4.0
		"crit", "combo": return 1.0
		"elite", "warden", "phase2": return 1.5
		"boss_down", "milestone": return 2.5
	return 0.0

func available_music_contexts() -> Array[String]:
	return ["menu", "dungeon", "crypt", "castle", "deep", "spire", "void", "eclipse", "bloodstar", "celestial", "boss"]

func _music_volume_db() -> float:
	if settings == null:
		return -10.0
	var base := linear_to_db(maxf(0.001, float(settings.music_volume)))
	return base + lerpf(0.0, 1.6, music_intensity)

func _on_music_finished(index: int) -> void:
	if settings == null or not bool(settings.music_enabled):
		return
	if index == active_music_index and pending_music_index < 0 and music_players[index].stream != null:
		music_players[index].play()

func _make_music_stream(kind: String) -> AudioStreamWAV:
	const RATE := 22050
	const LENGTH_SECONDS := 6.0
	var frames: int = int(float(RATE) * LENGTH_SECONDS)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	for i in range(frames):
		var t: float = float(i) / float(RATE)
		var sample: float = _music_sample(kind, t)
		var edge: float = minf(1.0, minf(t / 0.055, (LENGTH_SECONDS - t) / 0.055))
		sample = clampf(sample * maxf(0.0, edge), -0.95, 0.95)
		var value: int = int(round(sample * 32767.0))
		if value < 0:
			value += 65536
		bytes[i * 2] = value & 0xff
		bytes[i * 2 + 1] = (value >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = frames
	stream.data = bytes
	return stream

func _music_sample(kind: String, t: float) -> float:
	match kind:
		"menu": return _menu_sample(t)
		"crypt": return _crypt_sample(t)
		"castle": return _castle_sample(t)
		"deep": return _deep_sample(t)
		"spire": return _spire_sample(t)
		"void": return _void_sample(t)
		"eclipse": return _eclipse_sample(t)
		"bloodstar": return _bloodstar_sample(t)
		"celestial": return _celestial_sample(t)
		"boss": return _boss_sample(t)
	return _dungeon_sample(t)

func _menu_sample(t: float) -> float:
	var chord_step: int = int(floor(t / 1.5)) % 4
	var roots := [65.41, 73.42, 82.41, 61.74]
	var root: float = roots[chord_step]
	var swell: float = 0.72 + 0.28 * sin(TAU * 0.083 * t - PI * 0.5)
	var pad: float = sin(TAU * root * t) * 0.065
	pad += sin(TAU * root * 1.5 * t + 0.35) * 0.034
	pad += sin(TAU * root * 2.0 * t + 0.8) * 0.020
	var sparkle_step: int = int(floor(t / 0.75)) % 8
	var sparkle_notes := [261.63, 329.63, 392.00, 329.63, 293.66, 369.99, 440.00, 369.99]
	var sparkle_env: float = exp(-fmod(t, 0.75) * 6.0)
	var sparkle: float = sin(TAU * float(sparkle_notes[sparkle_step]) * t) * sparkle_env * 0.028
	return pad * swell + sparkle

func _dungeon_sample(t: float) -> float:
	var step: int = int(floor(t / 0.75)) % 8
	var notes := [110.00, 130.81, 146.83, 123.47, 110.00, 164.81, 146.83, 130.81]
	var note: float = notes[step]
	var env: float = exp(-fmod(t, 0.75) * 4.8)
	return sin(TAU * note * t) * env * 0.10 + sin(TAU * 55.0 * t) * 0.075 + sin(TAU * 82.41 * t + 0.6) * 0.035

func _crypt_sample(t: float) -> float:
	var step: int = int(floor(t / 1.5)) % 4
	var notes := [174.61, 155.56, 207.65, 138.59]
	var env: float = exp(-fmod(t, 1.5) * 2.6)
	var bell: float = (sin(TAU * notes[step] * t) + sin(TAU * notes[step] * 2.01 * t) * 0.36) * env * 0.065
	return sin(TAU * 43.65 * t) * 0.085 + sin(TAU * 46.25 * t + 1.3) * 0.045 + bell

func _castle_sample(t: float) -> float:
	var step: int = int(floor(t / 0.6)) % 10
	var notes := [130.81, 146.83, 164.81, 196.00, 174.61, 164.81, 146.83, 130.81, 110.00, 123.47]
	var env: float = exp(-fmod(t, 0.6) * 4.2)
	var motif: float = (sin(TAU * notes[step] * t) + sin(TAU * notes[step] * 2.0 * t) * 0.18) * env * 0.085
	return sin(TAU * 65.41 * t) * 0.085 + sin(TAU * 98.00 * t) * 0.035 + motif

func _deep_sample(t: float) -> float:
	var pulse := exp(-fmod(t, 0.5) * 8.0)
	return sin(TAU * 49.0 * t) * 0.10 + sin(TAU * 73.42 * t + 0.4) * 0.04 + sin(TAU * 196.0 * t) * pulse * 0.035

func _spire_sample(t: float) -> float:
	var step := int(floor(t / 0.5)) % 6
	var notes := [220.0, 246.94, 293.66, 329.63, 293.66, 246.94]
	var env := exp(-fmod(t, 0.5) * 5.2)
	return sin(TAU * 55.0 * t) * 0.075 + sin(TAU * 82.41 * t + 1.1) * 0.035 + sin(TAU * notes[step] * t) * env * 0.055

func _void_sample(t: float) -> float:
	var step := int(floor(t / 0.375)) % 8
	var notes := [146.83, 174.61, 220.0, 196.0, 146.83, 233.08, 220.0, 174.61]
	var env := exp(-fmod(t, 0.375) * 6.2)
	var wobble := sin(TAU * 0.21 * t)
	return sin(TAU * (41.2 + wobble * 1.8) * t) * 0.10 + sin(TAU * notes[step] * t) * env * 0.055

func _eclipse_sample(t: float) -> float:
	var bright := maxf(0.0, sin(TAU * 0.165 * t))
	var dark := maxf(0.0, -sin(TAU * 0.165 * t))
	var bell_env := exp(-fmod(t, 0.75) * 5.4)
	return sin(TAU * 61.74 * t) * (0.055 + dark * 0.05) + sin(TAU * 246.94 * t) * bell_env * (0.025 + bright * 0.05)

func _bloodstar_sample(t: float) -> float:
	var beat := exp(-fmod(t, 0.50) * 16.0)
	var offbeat := exp(-fmod(t + 0.25, 0.50) * 11.0)
	return sin(TAU * 49.0 * t) * 0.105 + sin(TAU * 73.42 * t) * 0.03 + sin(TAU * 38.0 * t) * beat * 0.10 + sin(TAU * 110.0 * t) * offbeat * 0.035

func _celestial_sample(t: float) -> float:
	var step := int(floor(t / 0.75)) % 8
	var notes := [293.66, 369.99, 440.0, 587.33, 440.0, 369.99, 329.63, 493.88]
	var env := exp(-fmod(t, 0.75) * 3.8)
	return sin(TAU * 36.71 * t) * 0.065 + sin(TAU * notes[step] * t) * env * 0.052 + sin(TAU * notes[step] * 2.0 * t) * env * 0.016

func _boss_sample(t: float) -> float:
	var step: int = int(floor(t / 0.30)) % 8
	var notes := [146.83, 146.83, 174.61, 164.81, 146.83, 220.00, 196.00, 174.61]
	var env: float = exp(-fmod(t, 0.30) * 7.5)
	var lead: float = (sin(TAU * notes[step] * t) + sin(TAU * notes[step] * 1.5 * t) * 0.22) * env * 0.085
	var bass: float = sin(TAU * 73.42 * t) * 0.105 + sin(TAU * 55.0 * t + 0.4) * 0.045
	var hit_env: float = exp(-fmod(t, 0.6) * 18.0)
	var hit: float = sin(TAU * (45.0 + 18.0 * hit_env) * t) * hit_env * 0.095
	return bass + lead + hit
