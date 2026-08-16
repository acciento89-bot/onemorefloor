extends "res://scripts/release_audio.gd"

# Seamless-loop variant used by the v1.24 UX polish pass.
# The first short segment is an intro only. The end of the stream crossfades
# into that intro segment and then loops to the sample immediately after it,
# avoiding the hard 6-second waveform reset that could sound like a crackle.

const LOOP_RATE := 22050
const LOOP_SECONDS := 12.0
const LOOP_SEAM_SECONDS := 0.32
const INTRO_FADE_SECONDS := 0.12

func _make_music_stream(kind: String) -> AudioStreamWAV:
	var frames: int = int(float(LOOP_RATE) * LOOP_SECONDS)
	var seam_frames: int = clampi(int(float(LOOP_RATE) * LOOP_SEAM_SECONDS), 64, maxi(64, frames / 4))
	var intro_frames: int = clampi(int(float(LOOP_RATE) * INTRO_FADE_SECONDS), 32, seam_frames)
	var raw := PackedFloat32Array()
	raw.resize(frames)
	for i in range(frames):
		var t: float = float(i) / float(LOOP_RATE)
		raw[i] = clampf(_music_sample(kind, t), -0.95, 0.95)

	var mixed := raw.duplicate()
	# Smooth first-launch fade. This segment is not replayed directly after the
	# first pass because loop_begin starts after the seam bridge.
	for i in range(intro_frames):
		var u: float = float(i) / float(maxi(1, intro_frames - 1))
		var gain: float = 0.5 - 0.5 * cos(PI * u)
		mixed[i] = raw[i] * gain

	# Equal-power-ish cosine seam. At the final sample the waveform has become
	# the sample immediately before loop_begin, so the following loop sample is
	# naturally adjacent instead of a discontinuous restart at t=0.
	for j in range(seam_frames):
		var tail_index: int = frames - seam_frames + j
		var u: float = float(j) / float(maxi(1, seam_frames - 1))
		var blend: float = 0.5 - 0.5 * cos(PI * u)
		mixed[tail_index] = lerpf(raw[tail_index], raw[j], blend)

	var bytes := PackedByteArray()
	bytes.resize(frames * 2)
	for i in range(frames):
		var value: int = int(round(clampf(mixed[i], -0.95, 0.95) * 32767.0))
		if value < 0:
			value += 65536
		bytes[i * 2] = value & 0xff
		bytes[i * 2 + 1] = (value >> 8) & 0xff

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = LOOP_RATE
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = seam_frames
	stream.loop_end = frames
	stream.data = bytes
	return stream
