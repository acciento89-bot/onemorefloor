extends "res://scripts/main_v76.gd"

# ONE MORE FLOOR v1.62 r1.1 — shared panel balance pass.
# Keeps the r1 component geometry and only removes the oversized solid color-card
# read from large panels. Existing hit areas, routes and all gameplay remain inherited.

const V77_VERSION := "1.62.0-ui-foundation-r1.1"
const V77_BUILD := "49-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V77_VERSION, V77_BUILD)
		telemetry.event("ui_foundation_v162_r11_ready", _v77_ui_snapshot())
	queue_redraw()

func _v77_ui_balance_ready() -> bool:
	return _v76_ui_foundation_ready()

func _v77_ui_snapshot() -> Dictionary:
	var data: Dictionary = _v76_ui_snapshot()
	data["ready"] = _v77_ui_balance_ready()
	data["version"] = V77_VERSION
	data["build"] = V77_BUILD
	data["dark_panel_balance"] = true
	data["r1_fallback"] = "1.62.0-ui-foundation-r1"
	return data

func _v16_frame(r: Rect2, accent: Color, fill: Color = V16_NAVY, glow: float = 0.15) -> void:
	# Preserve the source hue as a restrained material tint, but always establish
	# an opaque dark plate first. This prevents Talents/offer cards from becoming
	# giant green/purple/gold mobile tiles while keeping their identity on edges.
	var source_rgb := Color(fill.r, fill.g, fill.b, 1.0)
	var tint_strength: float = 0.14 if fill.a < 0.50 else 0.24
	var safe_fill: Color = V76_PANEL_INNER.lerp(source_rgb, tint_strength)
	safe_fill.a = 0.96
	_v76_surface(r, accent, safe_fill, clampf(glow, 0.0, 0.35), false)

	# Low-alpha source cards get only a whisper of their original accent inside.
	if fill.a < 0.50:
		var tint_r := r.grow(-6.0)
		draw_colored_polygon(_v76_cut_points(tint_r, 6.0), Color(accent, 0.018 + fill.a * 0.10))
