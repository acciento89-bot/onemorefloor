extends "res://scripts/main_v79.gd"

# ONE MORE FLOOR v1.62 r3 — runtime decision/result CTA presentation.
# Presentation-only: redraws four existing action rectangles after the inherited
# screens render. Pointer ownership, hit rectangles, run/economy logic and input
# flow remain entirely inherited.

const V80_VERSION := "1.62.0-ui-foundation-r3"
const V80_BUILD := "49-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V80_VERSION, V80_BUILD)
		telemetry.event("ui_foundation_v162_r3_ready", _v80_ui_snapshot())
	queue_redraw()

func _v80_runtime_cta_ready() -> bool:
	return _v79_ui_store_ready()

func _v80_ui_snapshot() -> Dictionary:
	var data: Dictionary = _v79_ui_snapshot()
	data["ready"] = _v80_runtime_cta_ready()
	data["version"] = V80_VERSION
	data["build"] = V80_BUILD
	data["decision_cta_surfaces"] = true
	data["game_over_cta_surfaces"] = true
	data["input_override"] = false
	data["r21_fallback"] = "1.62.0-ui-foundation-r2.1"
	return data

func draw_decision() -> void:
	super.draw_decision()
	# CASH / NEXT are the inherited interaction rectangles. Only their final
	# visible surfaces are replaced here.
	_v80_runtime_cta(CASH, "CASH OUT", V16_GREEN, false)
	_v80_runtime_cta(NEXT, "ONE MORE FLOOR", V16_GOLD, true)

func draw_game_over() -> void:
	super.draw_game_over()
	# RETRY / HOME_BTN remain the inherited input authority.
	_v80_runtime_cta(RETRY, "RETRY", V16_GOLD, true)
	_v80_runtime_cta(HOME_BTN, "HOME", V16_PURPLE, false)

func _v80_runtime_cta(r: Rect2, label: String, accent: Color, primary: bool) -> void:
	if primary:
		_v76_primary_plate(r, accent, true)
	else:
		_v76_surface(r, accent, Color("080d15"), 0.18, false)

	# A small side key gives the action authored hierarchy without restoring a
	# full saturated fill. Primary actions receive the stronger brass key.
	var key_color: Color = V76_BRASS if primary else accent
	var cy: float = r.get_center().y
	draw_line(
		Vector2(r.position.x + 18.0, cy),
		Vector2(r.position.x + 32.0, cy),
		Color(key_color, 0.88 if primary else 0.58),
		2.0,
		true
	)

	var text_color: Color = V16_GOLD_HI if primary else V76_IVORY
	var font_size: int = 22 if label.length() <= 7 else 19
	draw_string(
		v16_title_font,
		Vector2(r.position.x + 34.0, cy + float(font_size) * 0.34),
		label,
		HORIZONTAL_ALIGNMENT_CENTER,
		r.size.x - 68.0,
		font_size,
		text_color
	)

	if primary:
		var x: float = r.end.x - 22.0
		draw_line(Vector2(x - 5.0, cy - 5.0), Vector2(x, cy), Color(accent, 0.88), 1.6, true)
		draw_line(Vector2(x, cy), Vector2(x - 5.0, cy + 5.0), Color(accent, 0.88), 1.6, true)
