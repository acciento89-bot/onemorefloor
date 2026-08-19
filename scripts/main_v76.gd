extends "res://scripts/main_v75.gd"

# ONE MORE FLOOR v1.62 r1 — shared production UI foundation.
# Presentation-only layer: existing menu routes, pointer hit areas, gameplay,
# progression, saves and the validated v1.61 combat presentation remain inherited.

const V76_VERSION := "1.62.0-ui-foundation-r1"
const V76_BUILD := "49-dev"

const V76_PANEL := Color("070a10")
const V76_PANEL_INNER := Color("0b1019")
const V76_STEEL := Color("566174")
const V76_STEEL_HI := Color("8d99aa")
const V76_BRASS := Color("b88b45")
const V76_IVORY := Color("f3ede2")
const V76_MUTED := Color("969bab")

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V76_VERSION, V76_BUILD)
		telemetry.event("ui_foundation_v162_ready", _v76_ui_snapshot())
	queue_redraw()

func _v76_ui_foundation_ready() -> bool:
	return _v75_combat_presentation_ready() \
		and v51_menu_shell != null \
		and v16_title_font != null \
		and v16_body_font != null

func _v76_ui_snapshot() -> Dictionary:
	return {
		"ready": _v76_ui_foundation_ready(),
		"version": V76_VERSION,
		"build": V76_BUILD,
		"shared_panel": true,
		"shared_button": true,
		"shared_tab": true,
		"shared_badge": true,
		"shared_section": true,
		"combat_lock": "1.61-combat-presentation-r3.2",
	}

# -----------------------------------------------------------------------------
# Shared production surfaces
# -----------------------------------------------------------------------------

func _v76_cut_points(r: Rect2, cut: float = 10.0) -> PackedVector2Array:
	var c: float = minf(cut, minf(r.size.x, r.size.y) * 0.24)
	return PackedVector2Array([
		Vector2(r.position.x + c, r.position.y),
		Vector2(r.end.x - c, r.position.y),
		Vector2(r.end.x, r.position.y + c),
		Vector2(r.end.x, r.end.y - c),
		Vector2(r.end.x - c, r.end.y),
		Vector2(r.position.x + c, r.end.y),
		Vector2(r.position.x, r.end.y - c),
		Vector2(r.position.x, r.position.y + c),
	])

func _v76_shift_points(points: PackedVector2Array, offset: Vector2) -> PackedVector2Array:
	var shifted := PackedVector2Array()
	for point in points:
		shifted.append(point + offset)
	return shifted

func _v76_outline(points: PackedVector2Array, color: Color, width: float = 1.0) -> void:
	if points.size() < 2:
		return
	for index in range(points.size()):
		draw_line(points[index], points[(index + 1) % points.size()], color, width, true)

func _v76_surface(r: Rect2, accent: Color, fill: Color, emphasis: float = 0.0, selected: bool = false) -> void:
	var outer := _v76_cut_points(r, 11.0)
	var shadow := _v76_shift_points(outer, Vector2(4.0, 7.0))
	draw_colored_polygon(shadow, Color(0.0, 0.0, 0.0, 0.56))

	# Cold metal outer plate and recessed dark interior.
	draw_colored_polygon(outer, Color("151b25"))
	_v76_outline(outer, Color(V76_STEEL, 0.72), 1.4)
	var inner_r := r.grow(-3.0)
	var inner := _v76_cut_points(inner_r, 8.0)
	draw_colored_polygon(inner, fill)
	_v76_outline(inner, Color(accent, 0.28 + emphasis * 0.24), 1.0)

	# Short highlights instead of a glowing full perimeter.
	var top_y := r.position.y + 4.0
	draw_line(Vector2(r.position.x + 18.0, top_y), Vector2(r.end.x - 18.0, top_y), Color(V76_STEEL_HI, 0.16), 1.0, true)
	var accent_alpha: float = 0.52 + emphasis * 0.28
	if selected:
		accent_alpha = 0.90
	draw_line(Vector2(r.position.x + 18.0, r.position.y + 2.0), Vector2(r.end.x - 18.0, r.position.y + 2.0), Color(accent, accent_alpha), 2.0, true)

	# Small metal fasteners provide authored detail without neon clutter.
	for x in [r.position.x + 10.0, r.end.x - 10.0]:
		var p := Vector2(x, r.get_center().y)
		draw_circle(p, 2.2, Color(V76_STEEL_HI, 0.46))

func _v76_primary_plate(r: Rect2, accent: Color, enabled: bool) -> void:
	var a := accent if enabled else Color("626876")
	_v76_surface(r, a, Color(a, 0.075) if enabled else Color("11151c"), 0.78 if enabled else 0.05, enabled)
	var inset := r.grow(-9.0)
	var inset_points := _v76_cut_points(inset, 6.0)
	draw_colored_polygon(inset_points, Color(a, 0.040 if enabled else 0.012))
	# Restrained brass side shoulders make the main CTA feel forged rather than flat.
	if enabled:
		draw_line(Vector2(r.position.x + 8.0, r.get_center().y), Vector2(r.position.x + 24.0, r.get_center().y), Color(V76_BRASS, 0.80), 2.0, true)
		draw_line(Vector2(r.end.x - 24.0, r.get_center().y), Vector2(r.end.x - 8.0, r.get_center().y), Color(V76_BRASS, 0.80), 2.0, true)

# -----------------------------------------------------------------------------
# Overrides of the established shared menu drawing API.
# Hit rectangles and pointer routing are intentionally untouched.
# -----------------------------------------------------------------------------

func _v16_frame(r: Rect2, accent: Color, fill: Color = V16_NAVY, glow: float = 0.15) -> void:
	var safe_fill := fill.lerp(V76_PANEL_INNER, 0.24)
	_v76_surface(r, accent, safe_fill, clampf(glow, 0.0, 0.35), false)

func _v16_button(r: Rect2, label: String, accent: Color, size: int, icon_index: int = -1, enabled: bool = true) -> void:
	var a := accent if enabled else Color("626876")
	var primary: bool = size >= 24 or r == PLAY
	if primary:
		_v76_primary_plate(r, a, enabled)
	else:
		_v76_surface(r, a, Color("090e16") if enabled else Color("10141b"), 0.24 if enabled else 0.02, false)

	if icon_index >= 0:
		_v16_medallion(Vector2(r.position.x + 38.0, r.get_center().y), 22.0 if primary else 19.0, a, icon_index)
		var label_color := V76_IVORY if enabled else V76_MUTED
		draw_string(v16_body_font, Vector2(r.position.x + 68.0, r.get_center().y + size * 0.31), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 82.0, size, label_color)
	else:
		var label_font: Font = v16_title_font if primary else v16_body_font
		var label_color := V16_GOLD_HI if primary and enabled else (V76_IVORY if enabled else V76_MUTED)
		draw_string(label_font, Vector2(r.position.x + 10.0, r.get_center().y + size * 0.31), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 20.0, size, label_color)

func _v16_medallion(center: Vector2, radius: float, accent: Color, icon_index: int) -> void:
	var size := Vector2(radius * 1.72, radius * 1.72)
	var r := Rect2(center - size * 0.5, size)
	var shadow := _v76_shift_points(_v76_cut_points(r, radius * 0.28), Vector2(2.0, 3.0))
	draw_colored_polygon(shadow, Color(0.0, 0.0, 0.0, 0.52))
	var plate := _v76_cut_points(r, radius * 0.28)
	draw_colored_polygon(plate, Color("101722"))
	_v76_outline(plate, Color(V76_STEEL, 0.78), 1.2)
	var inner := _v76_cut_points(r.grow(-3.0), radius * 0.20)
	draw_colored_polygon(inner, Color(accent, 0.10))
	_v76_outline(inner, Color(accent, 0.58), 1.0)
	_v12_icon(icon_index, Rect2(center - Vector2(radius * 0.58, radius * 0.58), Vector2(radius * 1.16, radius * 1.16)))
	# One restrained brass clasp replaces the old circular gem/ring language.
	draw_line(center + Vector2(-5.0, -radius * 0.76), center + Vector2(5.0, -radius * 0.76), Color(V76_BRASS, 0.82), 2.0, true)

func _v40_activity_button(r: Rect2, label: String, accent: Color, icon_index: int) -> void:
	_v76_surface(r, accent, Color("080d15"), 0.18, false)
	_v16_medallion(Vector2(r.position.x + 34.0, r.get_center().y), 17.0, accent, icon_index)
	draw_string(v16_title_font, Vector2(r.position.x + 62.0, r.get_center().y + 6.0), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 78.0, 15, V76_IVORY)

func _v40_home_tab(r: Rect2, label: String, icon_index: int, accent: Color) -> void:
	_v76_surface(r, accent, Color("070b12"), 0.12, false)
	_v16_medallion(Vector2(r.get_center().x, r.position.y + 34.0), 18.5, accent, icon_index)
	draw_string(v16_body_font, Vector2(r.position.x + 6.0, r.end.y - 18.0), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 12.0, 13, V76_IVORY)

func _v36_utility_button(r: Rect2, label: String, accent: Color, icon_index: int) -> void:
	_v76_surface(r, accent, Color("080c13"), 0.08, false)
	_v16_medallion(Vector2(r.position.x + 19.0, r.get_center().y), 11.5, accent, icon_index)
	draw_string(v16_body_font, Vector2(r.position.x + 36.0, r.get_center().y + 4.0), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 40.0, 9, V76_IVORY)

func _v16_section(label: String, y: float, accent: Color) -> void:
	_v16_text(label, Vector2(55.0, y), 17, V76_IVORY, true)
	var line_y := y + 10.0
	draw_line(Vector2(55.0, line_y), Vector2(174.0, line_y), Color(V76_STEEL, 0.54), 1.0, true)
	draw_line(Vector2(181.0, line_y), Vector2(231.0, line_y), Color(accent, 0.64), 2.0, true)
	var p := Vector2(178.0, line_y)
	draw_colored_polygon(PackedVector2Array([
		p + Vector2(0.0, -4.0), p + Vector2(4.0, 0.0), p + Vector2(0.0, 4.0), p + Vector2(-4.0, 0.0)
	]), Color(V76_BRASS, 0.92))
