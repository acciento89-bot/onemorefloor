extends "res://scripts/main_v78.gd"

# ONE MORE FLOOR v1.62 r2.1 — active Store action path correction.
# Keeps the accepted r2 Vault hierarchy and targets the actual release-facing
# main_v50 Store renderer. Monetization, ownership checks, pointer hitboxes and
# fail-closed behavior remain inherited and unchanged.

const V79_VERSION := "1.62.0-ui-foundation-r2.1"
const V79_BUILD := "49-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V79_VERSION, V79_BUILD)
		telemetry.event("ui_foundation_v162_r21_ready", _v79_ui_snapshot())
	queue_redraw()

func _v79_ui_store_ready() -> bool:
	return _v78_ui_secondary_ready()

func _v79_ui_snapshot() -> Dictionary:
	var data: Dictionary = _v78_ui_snapshot()
	data["ready"] = _v79_ui_store_ready()
	data["version"] = V79_VERSION
	data["build"] = V79_BUILD
	data["active_store_action_path"] = "_v50_store_card"
	data["store_action_chip_live"] = true
	data["vault_r2_preserved"] = true
	data["r2_fallback"] = "1.62.0-ui-foundation-r2"
	return data

func _v50_store_card(index: int, r: Rect2, product: Dictionary, requests_available: bool) -> void:
	var accents := [V16_GOLD, V16_ORANGE, V16_BLUE, V16_GOLD, V16_PURPLE]
	var icons := [6, 11, 9, 11, 10]
	var accent: Color = accents[index % accents.size()]
	var icon_index: int = icons[index % icons.size()]
	var owned := false
	var product_id := String(product.get("id", ""))
	if monetization != null:
		if product_id == monetization.PRODUCT_REMOVE_ADS:
			owned = bool(monetization.remove_ads)
		elif product_id == monetization.PRODUCT_STARTER:
			owned = bool(monetization.starter_claimed)
		elif product_id == monetization.PRODUCT_PREMIUM_PASS:
			owned = bool(monetization.premium_pass_unlocked())

	var frame_accent: Color = V16_GREEN if owned else (accent if requests_available else Color("565b69"))
	_v16_frame(r, frame_accent, Color("060912"), 0.12 if requests_available or owned else 0.05)
	_v16_medallion(Vector2(r.position.x + 50.0, r.get_center().y), 25.0, accent, icon_index)
	_v16_text(
		String(product.get("title", "ITEM")),
		r.position + Vector2(92.0, 37.0),
		17,
		V17_IVORY if requests_available or owned else Color("a3a6af"),
		true
	)
	_v16_text(String(product.get("subtitle", "")), r.position + Vector2(92.0, 65.0), 11, V16_MUTED)

	var action := "OWNED" if owned else ("TRY" if requests_available else "UNAVAILABLE")
	var action_accent: Color = V16_GREEN if owned else (V16_GOLD if requests_available else Color("626876"))
	var action_rect := Rect2(r.end.x - 150.0, r.position.y + 25.0, 122.0, 46.0)
	_v79_store_action_chip(action_rect, action, action_accent, requests_available and not owned, owned)

func _v79_store_action_chip(r: Rect2, label: String, accent: Color, actionable: bool, owned: bool) -> void:
	var outer := _v76_cut_points(r, 7.0)
	var shadow := _v76_shift_points(outer, Vector2(2.0, 3.0))
	draw_colored_polygon(shadow, Color(0.0, 0.0, 0.0, 0.48))
	draw_colored_polygon(outer, Color("111722"))
	_v76_outline(outer, Color(V76_STEEL, 0.58), 1.0)

	var inner_r := r.grow(-2.0)
	var inner := _v76_cut_points(inner_r, 5.0)
	var inner_fill := Color("08110f") if owned else (Color("0b1018") if actionable else Color("0a0d13"))
	draw_colored_polygon(inner, inner_fill)
	_v76_outline(inner, Color(accent, 0.64 if actionable or owned else 0.20), 1.0)
	draw_line(
		Vector2(r.position.x + 13.0, r.position.y + 2.0),
		Vector2(r.end.x - 13.0, r.position.y + 2.0),
		Color(accent, 0.78 if actionable or owned else 0.22),
		2.0,
		true
	)

	var text_size: int = 10 if label.length() > 7 else 12
	var text_color: Color = V16_GREEN if owned else (V76_IVORY if actionable else Color(V76_MUTED, 0.66))
	var text_width: float = r.size.x - (24.0 if actionable else 10.0)
	draw_string(
		v16_title_font,
		Vector2(r.position.x + 5.0, r.get_center().y + float(text_size) * 0.34),
		label,
		HORIZONTAL_ALIGNMENT_CENTER,
		text_width,
		text_size,
		text_color
	)

	if actionable:
		var chevron_x := r.end.x - 13.0
		var cy := r.get_center().y
		draw_line(Vector2(chevron_x - 4.0, cy - 4.0), Vector2(chevron_x, cy), Color(accent, 0.82), 1.5, true)
		draw_line(Vector2(chevron_x, cy), Vector2(chevron_x - 4.0, cy + 4.0), Color(accent, 0.82), 1.5, true)
