extends Node

var settings
var music_player: AudioStreamPlayer
var music_player_b: AudioStreamPlayer
var music_players: Array[AudioStreamPlayer] = []
var music_streams: Dictionary = {}
var music_context: String = "menu"
var active_music_index: int = 0
var pending_music_index: int = -1
var crossfade_time: float = 0.0
const CROSSFADE_DURATION := 1.25

var sfx_players: Array[AudioStreamPlayer] = []
var sfx_streams: Dictionary = {}
var next_sfx: int = 0

func setup(settings_ref) -> void:
	settings = settings_ref
	music_player = AudioStreamPlayer.new()
	music_player_b = AudioStreamPlayer.new()
	add_child(music_player)
	add_child(music_player_b)
	music_players = [music_player, music_player_b]
	music_streams = {
		"menu": load("res://assets/audio/tower_theme.wav"),
		"dungeon": _make_music_stream("dungeon"),
		"crypt": _make_music_stream("crypt"),
		"castle": _make_music_stream("castle"),
		"boss": _make_music_stream("boss")
	}
	music_player.stream = music_streams["menu"]
	music_player_b.stream = music_streams["dungeon"]
	music_player.finished.connect(_on_music_finished.bind(0))
	music_player_b.finished.connect(_on_music_finished.bind(1))
	for _i in range(5):
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

func event(name: String) -> void:
	if settings == null or not bool(settings.sfx_enabled):
		return
	var stream = sfx_streams.get(name)
	if stream == null or sfx_players.is_empty():
		return
	var p: AudioStreamPlayer = sfx_players[next_sfx % sfx_players.size()]
	next_sfx += 1
	p.stream = stream
	p.play()

func available_music_contexts() -> Array[String]:
	return ["menu", "dungeon", "crypt", "castle", "boss"]

func _music_volume_db() -> float:
	return linear_to_db(maxf(0.001, float(settings.music_volume))) if settings != null else -10.0

func _on_music_finished(index: int) -> void:
	if settings == null or not bool(settings.music_enabled):
		return
	if index == active_music_index and pending_music_index < 0 and music_players[index].stream != null:
		music_players[index].play()

func _make_music_stream(kind: String) -> AudioStreamWAV:
	const RATE := 16000
	const LENGTH_SECONDS := 6.0
	var frames: int = int(float(RATE) * LENGTH_SECONDS)
	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	for i in range(frames):
		var t: float = float(i) / float(RATE)
		var sample: float = _music_sample(kind, t)
		var edge: float = minf(1.0, minf(t / 0.075, (LENGTH_SECONDS - t) / 0.075))
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
		"crypt":
			return _crypt_sample(t)
		"castle":
			return _castle_sample(t)
		"boss":
			return _boss_sample(t)
	return _dungeon_sample(t)

func _dungeon_sample(t: float) -> float:
	var step: int = int(floor(t / 0.75)) % 8
	var notes := [110.00, 130.81, 146.83, 123.47, 110.00, 164.81, 146.83, 130.81]
	var note: float = notes[step]
	var pluck_env: float = exp(-fmod(t, 0.75) * 4.8)
	var pluck: float = sin(TAU * note * t) * pluck_env * 0.105
	var pad: float = sin(TAU * 55.0 * t) * 0.075 + sin(TAU * 82.41 * t + 0.6) * 0.035
	var pulse_env: float = exp(-fmod(t, 1.5) * 8.0)
	var pulse: float = sin(TAU * 73.42 * t) * pulse_env * 0.055
	return pad + pluck + pulse

func _crypt_sample(t: float) -> float:
	var step: int = int(floor(t / 1.5)) % 4
	var notes := [174.61, 155.56, 207.65, 138.59]
	var bell_env: float = exp(-fmod(t, 1.5) * 2.6)
	var bell: float = (sin(TAU * notes[step] * t) + sin(TAU * notes[step] * 2.01 * t) * 0.36) * bell_env * 0.065
	var drone: float = sin(TAU * 43.65 * t) * 0.085 + sin(TAU * 46.25 * t + 1.3) * 0.045
	var whisper: float = sin(TAU * 0.23 * t) * sin(TAU * 311.13 * t) * 0.018
	return drone + bell + whisper

func _castle_sample(t: float) -> float:
	var step: int = int(floor(t / 0.6)) % 10
	var notes := [130.81, 146.83, 164.81, 196.00, 174.61, 164.81, 146.83, 130.81, 110.00, 123.47]
	var env: float = exp(-fmod(t, 0.6) * 4.2)
	var motif: float = (sin(TAU * notes[step] * t) + sin(TAU * notes[step] * 2.0 * t) * 0.18) * env * 0.085
	var low: float = sin(TAU * 65.41 * t) * 0.085 + sin(TAU * 98.00 * t) * 0.035
	var march_env: float = exp(-fmod(t, 0.75) * 14.0)
	var march: float = sin(TAU * 52.0 * t) * march_env * 0.070
	return low + motif + march

func _boss_sample(t: float) -> float:
	var step: int = int(floor(t / 0.30)) % 8
	var notes := [146.83, 146.83, 174.61, 164.81, 146.83, 220.00, 196.00, 174.61]
	var env: float = exp(-fmod(t, 0.30) * 7.5)
	var lead: float = (sin(TAU * notes[step] * t) + sin(TAU * notes[step] * 1.5 * t) * 0.22) * env * 0.085
	var bass: float = sin(TAU * 73.42 * t) * 0.105 + sin(TAU * 55.0 * t + 0.4) * 0.045
	var hit_env: float = exp(-fmod(t, 0.6) * 18.0)
	var hit: float = sin(TAU * (45.0 + 18.0 * hit_env) * t) * hit_env * 0.095
	return bass + lead + hit
