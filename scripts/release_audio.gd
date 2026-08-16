extends Node

var settings
var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_streams: Dictionary = {}
var next_sfx: int = 0

func setup(settings_ref) -> void:
	settings = settings_ref
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	for _i in range(4):
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)
	music_player.stream = load("res://assets/audio/tower_theme.wav")
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
	music_player.finished.connect(_on_music_finished)
	apply_settings()

func apply_settings() -> void:
	if settings == null:
		return
	music_player.volume_db = linear_to_db(maxf(0.001, float(settings.music_volume)))
	for p in sfx_players:
		p.volume_db = linear_to_db(maxf(0.001, float(settings.sfx_volume)))
	if bool(settings.music_enabled):
		if music_player.stream != null and not music_player.playing:
			music_player.play()
	else:
		music_player.stop()

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

func _on_music_finished() -> void:
	if settings != null and bool(settings.music_enabled) and music_player.stream != null:
		music_player.play()
