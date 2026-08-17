extends Control

# Full-viewport shell for tall phones/tablets.
# The playable/UI composition intentionally stays on the proven 720x1280 canvas,
# while this layer fills any expanded aspect-ratio area behind it so iPhone safe
# areas never read as black letterbox bars. It is decorative only and ignores input.

var _elapsed := 0.0
var _redraw_accum := 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	z_index = -100
	_sync_to_viewport()
	get_viewport().size_changed.connect(_sync_to_viewport)
	set_process(true)

func _process(delta: float) -> void:
	_elapsed += delta
	_redraw_accum += delta
	# 20 fps is plenty for the almost-static ambience and keeps mobile cost tiny.
	if _redraw_accum >= 0.05:
		_redraw_accum = 0.0
		queue_redraw()

func _sync_to_viewport() -> void:
	position = Vector2.ZERO
	size = get_viewport_rect().size
	queue_redraw()

func _game() -> Node:
	return get_parent()

func _primary() -> Color:
	var game := _game()
	if game != null and game.has_method("_v38_primary"):
		var value: Variant = game.call("_v38_primary")
		if value is Color:
			return value
	return Color("9b5cff")

func _secondary() -> Color:
	var game := _game()
	if game != null and game.has_method("_v38_secondary"):
		var value: Variant = game.call("_v38_secondary")
		if value is Color:
			return value
	return Color("e7b84d")

func _draw() -> void:
	if size.x < 2.0 or size.y < 2.0:
		return
	var p := _primary()
	var s := _secondary()
	var w := size.x
	var h := size.y

	# Deep vertical sky gradient. It remains visible only outside the 720x1280
	# content canvas, but also prevents flashes of black during resize/rotation.
	var top := Color("03040d")
	var middle := Color("07091b")
	var bottom := Color("01030a")
	var bands := 44
	for i in range(bands):
		var t0 := float(i) / float(bands)
		var t1 := float(i + 1) / float(bands)
		var tmid := (t0 + t1) * 0.5
		var c: Color
		if tmid < 0.5:
			c = top.lerp(middle, tmid * 2.0)
		else:
			c = middle.lerp(bottom, (tmid - 0.5) * 2.0)
		draw_rect(Rect2(0.0, h * t0, w, h * (t1 - t0) + 1.0), c)

	# Pack-coloured atmospheric bloom at the top/bottom continuation zones.
	draw_circle(Vector2(w * 0.50, h * 0.10), w * 0.62, Color(p, 0.025))
	draw_circle(Vector2(w * 0.50, h * 0.94), w * 0.72, Color(p, 0.018))
	draw_arc(Vector2(w * 0.50, h * 0.12), w * 0.34, PI * 0.10, PI * 0.90, 64, Color(p, 0.10), 1.2)
	draw_arc(Vector2(w * 0.50, h * 0.92), w * 0.38, PI * 1.10, PI * 1.90, 64, Color(s, 0.065), 1.0)

	# Deterministic star/dust field. No RNG means particles never jump between frames.
	for i in range(34):
		var fx := fmod(float(i * 137 + 41), maxf(1.0, w - 24.0)) + 12.0
		var fy := fmod(float(i * 233 + 97), maxf(1.0, h - 24.0)) + 12.0
		var twinkle := 0.42 + 0.28 * sin(_elapsed * (0.55 + float(i % 4) * 0.11) + float(i) * 1.73)
		var radius := 0.8 + float(i % 3) * 0.45
		draw_circle(Vector2(fx, fy), radius, Color(Color("d9d2ff"), clampf(twinkle, 0.12, 0.72)))

	# Tall-phone edge architecture so the extension feels intentional rather than
	# merely a stretched background.
	var rail_alpha := 0.12
	draw_line(Vector2(20, 0), Vector2(20, h), Color(p, rail_alpha), 1.0)
	draw_line(Vector2(w - 20, 0), Vector2(w - 20, h), Color(p, rail_alpha), 1.0)
	for y_ratio in [0.14, 0.50, 0.86]:
		var y := h * float(y_ratio)
		var gem_l := Vector2(20, y)
		var gem_r := Vector2(w - 20, y)
		_draw_diamond(gem_l, 4.5, Color(p, 0.42))
		_draw_diamond(gem_r, 4.5, Color(p, 0.42))
		draw_line(gem_l + Vector2(7, 0), gem_l + Vector2(28, 0), Color(s, 0.12), 1.0)
		draw_line(gem_r - Vector2(7, 0), gem_r - Vector2(28, 0), Color(s, 0.12), 1.0)

	# Soft edge grading keeps attention in the playable centre on very wide tablets.
	draw_rect(Rect2(0, 0, maxf(12.0, w * 0.055), h), Color(0, 0, 0, 0.26))
	draw_rect(Rect2(w - maxf(12.0, w * 0.055), 0, maxf(12.0, w * 0.055), h), Color(0, 0, 0, 0.26))

func _draw_diamond(center: Vector2, radius: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius, 0)
	]), color)
