extends "res://scripts/main_v19.gd"

# ONE MORE FLOOR v1.8 — raster reference skin.
# The approved high-fidelity concept is rendered as the actual Home surface.
# Gameplay, progression, navigation and touch hitboxes remain live underneath.

const V20_VERSION := "1.8.0-raster-reference"
const V20_HOME_CHUNKS := 7
const V20_REF_DIR := "res://assets/art/reference"

var tex_v20_home: Texture2D
var v20_home_decode_ok := false

func _ready() -> void:
	super._ready()
	tex_v20_home = _v20_load_chunked_webp("home", V20_HOME_CHUNKS)
	v20_home_decode_ok = tex_v20_home != null
	if not v20_home_decode_ok:
		push_error("v1.8 raster reference: approved Home texture failed to decode")
	queue_redraw()

func _v20_load_chunked_webp(stem: String, chunk_count: int) -> Texture2D:
	var encoded := ""
	for i in range(chunk_count):
		var path := "%s/%s_%d.b64" % [V20_REF_DIR, stem, i]
		if not FileAccess.file_exists(path):
			push_error("v1.8 raster reference: missing chunk %s" % path)
			return null
		encoded += FileAccess.get_file_as_string(path).strip_edges()
	if encoded.is_empty():
		return null
	var bytes: PackedByteArray = Marshalls.base64_to_raw(encoded)
	if bytes.is_empty():
		push_error("v1.8 raster reference: base64 decode returned no bytes")
		return null
	var image := Image.new()
	var err := image.load_webp_from_buffer(bytes)
	if err != OK:
		push_error("v1.8 raster reference: WebP decode error %d" % err)
		return null
	if image.get_width() != 720 or image.get_height() != 1280:
		push_error("v1.8 raster reference: Home texture has unexpected size %dx%d" % [image.get_width(), image.get_height()])
		return null
	return ImageTexture.create_from_image(image)

func _v20_mask_value(r: Rect2, color: Color = Color("050711")) -> void:
	# Only the changing number is repainted; the approved frame/art stays untouched.
	draw_rect(r, color)

func _v20_dynamic_home_values() -> void:
	# BEST FLOOR
	_v20_mask_value(Rect2(66, 58, 88, 47), Color("050711"))
	draw_string(v16_title_font, Vector2(68, 94), str(meta.best_floor), HORIZONTAL_ALIGNMENT_CENTER, 84, 31, Color("fff1ca"))

	# COINS — preserve the rendered coin crest and gold frame.
	_v20_mask_value(Rect2(571, 48, 91, 43), Color("050711"))
	draw_string(v16_title_font, Vector2(568, 82), str(meta.coins), HORIZONTAL_ALIGNMENT_CENTER, 98, 28, Color("fff1ca"))

	# POWER — preserve footer ornament and studio mark.
	_v20_mask_value(Rect2(132, 1193, 80, 34), Color("060817"))
	draw_string(v16_title_font, Vector2(132, 1218), str(meta.power_score()), HORIZONTAL_ALIGNMENT_LEFT, 88, 22, Color("f3c965"))

func draw_home() -> void:
	if tex_v20_home == null:
		super.draw_home()
		return
	# This is the approved concept itself, not a vector approximation.
	draw_texture_rect(tex_v20_home, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)
	_v20_dynamic_home_values()
	if meta_notice_time > 0.0:
		var notice_color := C_GREEN if meta_notice.begins_with("UPGRADE") else C_RED
		draw_rect(Rect2(198, 744, 324, 42), Color(0, 0, 0, 0.82))
		draw_string(v16_body_font, Vector2(205, 772), meta_notice, HORIZONTAL_ALIGNMENT_CENTER, 310, 18, notice_color)

func _v20_reference_home_ready() -> bool:
	return v20_home_decode_ok and tex_v20_home != null and tex_v20_home.get_width() == 720 and tex_v20_home.get_height() == 1280
