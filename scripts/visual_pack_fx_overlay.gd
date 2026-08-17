extends Node2D

# Live atmospheric polish layer for Graphics Packs 2.0.
# This node never replaces menu/game UI with screenshots. It reads the selected
# pack from the parent runtime and adds cheap mobile-friendly particles, glints,
# edge grading and theme motifs on top of the existing interactive renderer.

const CANVAS := Vector2(720.0, 1280.0)
const FULL_RECT := Rect2(Vector2.ZERO, CANVAS)
const REDRAW_INTERVAL := 1.0 / 30.0

var game: Node = null
var fx_time: float = 0.0
var last_pack: String = ""
var transition: float = 0.0
var redraw_accum: float = 0.0

func _ready() -> void:
	game = get_parent()
	last_pack = _pack_id()
	queue_redraw()

func _process(delta: float) -> void:
	fx_time += delta
	var current := _pack_id()
	if current != last_pack:
		last_pack = current
		transition = 1.0
	transition = maxf(0.0, transition - delta * 1.15)
	# Decorative particles do not need a redraw for every gameplay frame. Keeping
	# their time continuous but painting at 30 fps halves CanvasItem draw pressure
	# on 60 Hz mobile displays while combat/input remain fully 60 fps.
	redraw_accum += delta
	if redraw_accum >= REDRAW_INTERVAL:
		redraw_accum = 0.0
		queue_redraw()

func _draw() -> void:
	var packs := _pack_manager()
	if packs == null:
		return
	var pack := String(packs.get("selected"))
	var primary := Color(packs.call("primary"))
	var secondary := Color(packs.call("secondary"))
	var settings_open := bool(game.get("settings_open")) if game != null else false

	_draw_edge_grade(primary, settings_open)
	_draw_corner_metal(primary, secondary)
	_draw_ambient_motes(pack, primary, secondary, settings_open)
	match pack:
		"void":
			_draw_void_wisps(primary, secondary)
		"eclipse":
			_draw_eclipse_crown(primary, secondary)
		"bloodstar":
			_draw_bloodstar_embers(primary, secondary)
		"celestial":
			_draw_celestial_field(primary, secondary)
		_:
			_draw_citadel_sparks(primary, secondary)

	if transition > 0.0:
		var pulse := 0.045 * transition
		draw_rect(FULL_RECT.grow(-8.0), Color(primary, pulse), false, 3.0)
		draw_arc(Vector2(360, 640), 310.0 - transition * 42.0, 0.0, TAU, 72, Color(secondary, pulse * 1.6), 1.5)

func _pack_manager() -> Object:
	if game == null or not is_instance_valid(game):
		return null
	return game.get("visual_pack") as Object

func _pack_id() -> String:
	var packs := _pack_manager()
	if packs == null:
		return "citadel"
	return String(packs.get("selected"))

func _draw_edge_grade(primary: Color, settings_open: bool) -> void:
	var strength := 0.23 if settings_open else 0.14
	draw_rect(Rect2(0, 0, 720, 34), Color(0.0, 0.0, 0.0, strength))
	draw_rect(Rect2(0, 1240, 720, 40), Color(0.0, 0.0, 0.0, strength + 0.05))
	draw_rect(Rect2(0, 0, 18, 1280), Color(primary, 0.018))
	draw_rect(Rect2(702, 0, 18, 1280), Color(primary, 0.018))
	for i in range(4):
		var inset := 7.0 + float(i) * 5.0
		var alpha := 0.026 - float(i) * 0.004
		draw_rect(Rect2(inset, inset, 720.0 - inset * 2.0, 1280.0 - inset * 2.0), Color(primary, alpha), false, 1.0)

func _draw_corner_metal(primary: Color, secondary: Color) -> void:
	var corners: Array[Vector2] = [Vector2(30, 54), Vector2(690, 54), Vector2(30, 1226), Vector2(690, 1226)]
	for i in range(corners.size()):
		var c: Vector2 = corners[i]
		var sx := 1.0 if i % 2 == 0 else -1.0
		var sy := 1.0 if i < 2 else -1.0
		draw_line(c, c + Vector2(20.0 * sx, 0), Color(secondary, 0.20), 1.4)
		draw_line(c, c + Vector2(0, 20.0 * sy), Color(primary, 0.26), 1.4)
		_draw_diamond(c, 3.5, Color(primary, 0.48))

func _draw_ambient_motes(pack: String, primary: Color, secondary: Color, settings_open: bool) -> void:
	var count := 12 if settings_open else 20
	for i in range(count):
		var seed := float(i * 157 + 41)
		var x := 24.0 + fmod(seed, 672.0)
		var speed := 5.0 + float((i * 11) % 13)
		var travel := fmod(seed * 0.71 + fx_time * speed * 3.2, 1180.0)
		var y := 1224.0 - travel
		var sway := sin(fx_time * (0.28 + float(i % 4) * 0.05) + float(i) * 0.77) * (4.0 + float(i % 5))
		var pos := Vector2(x + sway, y)
		var twinkle := 0.55 + 0.45 * sin(fx_time * 1.15 + float(i) * 0.63)
		var col := primary if i % 3 != 0 else secondary
		var alpha := 0.045 + 0.035 * twinkle
		if pack == "bloodstar":
			alpha *= 0.68
		draw_circle(pos, 1.0 + float(i % 3) * 0.45, Color(col, alpha))
		if i % 5 == 0:
			draw_circle(pos, 4.0, Color(col, alpha * 0.16))

func _draw_citadel_sparks(primary: Color, secondary: Color) -> void:
	for i in range(10):
		var lane := -1.0 if i % 2 == 0 else 1.0
		var x := 360.0 + lane * (185.0 + float((i * 23) % 72))
		var rise := fmod(float(i * 97) + fx_time * (22.0 + float(i % 4) * 4.0), 420.0)
		var y := 1080.0 - rise
		var drift := sin(fx_time * 0.9 + float(i)) * 7.0
		var pos := Vector2(x + drift, y)
		draw_circle(pos, 1.2, Color(secondary, 0.20))
		draw_line(pos + Vector2(0, 8), pos + Vector2(0, 1), Color(primary, 0.09), 1.0)
	draw_colored_polygon(PackedVector2Array([Vector2(58, 220), Vector2(138, 220), Vector2(214, 880), Vector2(150, 880)]), Color(secondary, 0.016))
	draw_colored_polygon(PackedVector2Array([Vector2(662, 220), Vector2(582, 220), Vector2(506, 880), Vector2(570, 880)]), Color(secondary, 0.016))

func _draw_void_wisps(primary: Color, secondary: Color) -> void:
	for i in range(8):
		var side := -1.0 if i % 2 == 0 else 1.0
		var base_x := 360.0 + side * (250.0 + float((i * 13) % 32))
		var y := 230.0 + float(i) * 118.0 + sin(fx_time * 0.33 + float(i)) * 18.0
		var p0 := Vector2(base_x, y)
		var p1 := p0 + Vector2(-side * 16.0, -28.0)
		var p2 := p1 + Vector2(side * 9.0, -25.0)
		draw_line(p0, p1, Color(primary, 0.13), 1.4)
		draw_line(p1, p2, Color(secondary, 0.08), 1.0)
		draw_circle(p2, 2.0, Color(primary, 0.18))

func _draw_eclipse_crown(primary: Color, secondary: Color) -> void:
	var c := Vector2(596, 232)
	draw_circle(c, 48.0, Color(0.0, 0.0, 0.0, 0.08))
	draw_arc(c, 55.0, -1.15, 1.15, 36, Color(secondary, 0.16), 2.2)
	draw_arc(c, 67.0, -0.55 + fx_time * 0.015, 0.55 + fx_time * 0.015, 28, Color(primary, 0.09), 1.0)
	for i in range(7):
		var a := -0.75 + float(i) * 0.25
		var p0 := c + Vector2(cos(a), sin(a)) * 62.0
		var p1 := c + Vector2(cos(a), sin(a)) * 78.0
		draw_line(p0, p1, Color(secondary, 0.075), 1.0)

func _draw_bloodstar_embers(primary: Color, secondary: Color) -> void:
	for i in range(18):
		var seed := float(i * 73 + 19)
		var x := 28.0 + fmod(seed * 1.67, 664.0)
		var rise := fmod(seed + fx_time * (35.0 + float(i % 5) * 6.0), 620.0)
		var y := 1240.0 - rise
		var pos := Vector2(x + sin(fx_time * 1.2 + i) * 5.0, y)
		var len := 5.0 + float(i % 4) * 2.0
		draw_line(pos + Vector2(0, len), pos, Color(primary, 0.18), 1.2)
		if i % 3 == 0:
			draw_circle(pos, 1.7, Color(secondary, 0.15))

func _draw_celestial_field(primary: Color, secondary: Color) -> void:
	var stars: Array[Vector2] = []
	for i in range(16):
		var x := 42.0 + fmod(float(i * 131 + 29), 636.0)
		var y := 150.0 + fmod(float(i * 89 + 61), 890.0)
		stars.append(Vector2(x, y))
	for i in range(stars.size()):
		var p: Vector2 = stars[i]
		var twinkle := 0.45 + 0.55 * sin(fx_time * (0.7 + float(i % 3) * 0.18) + float(i))
		draw_circle(p, 1.1 + maxf(0.0, twinkle) * 0.9, Color(secondary, 0.11 + maxf(0.0, twinkle) * 0.10))
		if i % 4 == 0:
			draw_line(p - Vector2(5, 0), p + Vector2(5, 0), Color(primary, 0.055), 1.0)
			draw_line(p - Vector2(0, 5), p + Vector2(0, 5), Color(primary, 0.055), 1.0)
	for i in range(0, stars.size() - 1, 3):
		draw_line(stars[i], stars[i + 1], Color(primary, 0.035), 1.0)

func _draw_diamond(center: Vector2, radius: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(0, -radius), center + Vector2(radius, 0),
		center + Vector2(0, radius), center + Vector2(-radius, 0)
	]), color)
