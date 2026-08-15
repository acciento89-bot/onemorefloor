extends Node

var player: AudioStreamPlayer
var generator: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback
var enabled := true

func _ready() -> void:
	player = AudioStreamPlayer.new()
	generator = AudioStreamGenerator.new()
	generator.mix_rate = 22050.0
	generator.buffer_length = 0.35
	player.stream = generator
	player.volume_db = -12.0
	add_child(player)
	player.play()
	playback = player.get_stream_playback() as AudioStreamGeneratorPlayback

func event(name: String) -> void:
	if not enabled or playback == null:
		return
	match name:
		"attack": _tone(520.0, 0.025, 0.05)
		"crit": _tone(880.0, 0.055, 0.12)
		"hit": _tone(180.0, 0.025, 0.05)
		"coin": _tone(740.0, 0.035, 0.08)
		"nova": _sweep(260.0, 760.0, 0.11, 0.10)
		"warden": _tone(95.0, 0.12, 0.13)
		"phase2": _sweep(120.0, 55.0, 0.18, 0.14)
		"loot": _sweep(480.0, 980.0, 0.10, 0.10)
		"claim": _sweep(620.0, 1040.0, 0.08, 0.08)
		"menu": _tone(410.0, 0.025, 0.04)

func _tone(freq: float, duration: float, amplitude: float) -> void:
	_push_wave(freq, freq, duration, amplitude)

func _sweep(from_freq: float, to_freq: float, duration: float, amplitude: float) -> void:
	_push_wave(from_freq, to_freq, duration, amplitude)

func _push_wave(from_freq: float, to_freq: float, duration: float, amplitude: float) -> void:
	if playback == null:
		return
	var frames := int(generator.mix_rate * duration)
	var phase := 0.0
	for i in range(frames):
		if playback.get_frames_available() <= 0:
			break
		var t := float(i) / float(maxi(1, frames - 1))
		var freq := lerpf(from_freq, to_freq, t)
		phase += TAU * freq / generator.mix_rate
		var envelope := 1.0 - t
		var sample := sin(phase) * amplitude * envelope
		playback.push_frame(Vector2(sample, sample))
