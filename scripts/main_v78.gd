extends "res://scripts/main_v77.gd"

# ONE MORE FLOOR v1.62 r2 — secondary-menu action hierarchy.
# Presentation only: Vault controls are visually compacted inside their existing
# hit rectangles and Store product actions gain explicit forged chips. Routing,
# hit areas, economy, monetization, crafting and progression logic stay inherited.

const V78_VERSION := "1.62.0-ui-foundation-r2"
const V78_BUILD := "49-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V78_VERSION, V78_BUILD)
		telemetry.event("ui_foundation_v162_r2_ready", _v78_ui_snapshot())
	queue_redraw()

func _v78_ui_secondary_ready() -> bool:
	return _v77_ui_balance_ready()

func _v78_ui_snapshot() -> Dictionary:
	var data: Dictionary = _v77_ui_snapshot()
	data["ready"] = _v78_ui_secondary_ready()
	data["version"] = V78_VERSION
	data["build"] = V78_BUILD
	data["vault_compact_controls"] = true
	data["store_action_chips"] = true
	data["missions_preserved"] = true
	data["tower_pass_preserved"] = true
	data["r11_fallback"] = "1.62.0-ui-foundation-r1.1"
	return data

# -----------------------------------------------------------------------------
# Vault — compact the visible controls without changing their input rectangles.
# -----------------------------------------------------------------------------

func _v16_button(r: Rect2, label: String, accent: Color, size: int, icon_index: int = -1, enabled: bool = true) -> void:
	if state == State.VAULT and _v78_is_vault_compact_control(r):
		_v78_draw_vault_compact_control(r, label, accent, size, icon_index, enabled)
		return
	super._v16_button(r, label, accent, size, icon_index, enabled)

func _v78_is_vault_compact_control(r: Rect2) -> bool:
	return r == V8_FILTER \
		or r == V8_SORT \
		or r == V8_LOCK \
		or r == V8_CRAFT_WEAPON \
		or r == V8_CRAFT_ARMOR \
		or r == V8_CRAFT_RELIC \
		or r == V31_ENHANCE \
		or r == V31_ENCHANT \
		or r == V31_AWAKEN

func _v78_vault_control_family(r: Rect2) -> String:
	if r == V8_FILTER or r == V8_SORT or r == V8_LOCK:
		return "toolbar"
	if r == V8_CRAFT_WEAPON or r == V8_CRAFT_ARMOR or r == V8_CRAFT_RELIC:
		return "craft"
	return "progression"

func _v78_draw_vault_compact_control(r: Rect2, label: String, accent: Color, size: int, icon_index: int, enabled: bool) -> void:
	var family := _v78_vault_control_family(r)
	var inset_y: float = 5.0 if family == "toolbar" else 8.0
	var visual := Rect2(
		r.position + Vector2(5.0, inset_y),
		Vector2(maxf(1.0, r.size.x - 10.0), maxf(1.0, r.size.y - inset_y * 2.0))
	)
	var live_accent: Color = accent if enabled else Color("565d6b")
	var fill := Color("080d15") if enabled else Color("090c12")
	var emphasis: float = 0.20 if enabled else 0.01
	_v76_surface(visual, live_accent, fill, emphasis, false)

	# Short category marker creates hierarchy without filling the whole control.
	var marker_len: float = 32.0 if family == "toolbar" else 46.0
	draw_line(
		Vector2(visual.position.x + 13.0, visual.position.y + 2.0),
		Vector2(visual.position.x + 13.0 + marker_len, visual.position.y + 2.0),
		Color(live_accent, 0.78 if enabled else 0.22),
		2.0,
		true
	)

	var label_color: Color = V76_IVORY if enabled else Color(V76_MUTED, 0.68)
	if icon_index >= 0:
		var badge_radius: float = 14.0 if family == "craft" else 12.0
		_v16_medallion(Vector2(visual.position.x + 31.0, visual.get_center().y), badge_radius, live_accent, icon_index)
		draw_string(
			v16_body_font,
			Vector2(visual.position.x + 52.0, visual.get_center().y + float(size) * 0.31),
			label,
			HORIZONTAL_ALIGNMENT_CENTER,
			visual.size.x - 64.0,
			size,
			label_color
		)
	else:
		draw_string(
			v16_body_font,
			Vector2(visual.position.x + 8.0, visual.get_center().y + float(size) * 0.31),
			label,
			HORIZONTAL_ALIGNMENT_CENTER,
			visual.size.x - 16.0,
			size,
			label_color
		)

	# Disabled progression actions remain legible but no longer compete with live controls.
	if not enabled and family != "toolbar":
		draw_line(
			Vector2(visual.position.x + 22.0, visual.end.y - 5.0),
			Vector2(visual.end.x - 22.0, visual.end.y - 5.0),
			Color(V76_STEEL, 0.12),
			1.0,
			true
		)

# -----------------------------------------------------------------------------
# Store — product card remains the exact interaction target; the inherited naked
# TRY/BUY/OWNED label becomes a compact action chip inside the same card.
# -----------------------------------------------------------------------------

func _v42_store_card(index: int, r: Rect2, product: Dictionary, debug: bool) -> void:
	var accents := [V16_GOLD, V16_ORANGE, V16_BLUE, V16_GOLD, V16_PURPLE]
	var icons := [6, 11, 9, 11, 10]
	var accent: Color = accents[index % accents.size()]
	var icon_index: int = icons[index % icons.size()]
	var owned := false
	var product_id := String(product.get("id", ""))
	if product_id == "com.kamilunavo.onemorefloor.removeads":
		owned = bool(monetization.remove_ads)
	elif product_id == "com.kamilunavo.onemorefloor.starterpack":
		owned = bool(monetization.starter_claimed)
	elif product_id == "com.kamilunavo.onemorefloor.premiumpass":
		owned = bool(monetization.premium_pass_unlocked())

	var card_accent: Color = V16_GREEN if owned else accent
	_v16_frame(r, card_accent, Color("060912"), 0.12)
	_v16_medallion(Vector2(r.position.x + 50.0, r.get_center().y), 25.0, accent, icon_index)
	_v16_text(String(product.get("title", "ITEM")), r.position + Vector2(92.0, 37.0), 17, V17_IVORY, true)
	_v16_text(String(product.get("subtitle", "")), r.position + Vector2(92.0, 65.0), 11, V16_MUTED)

	var action := "OWNED" if owned else ("TRY" if debug else "BUY")
	var action_accent: Color = V16_GREEN if owned else V16_GOLD
	var action_rect := Rect2(r.end.x - 116.0, r.position.y + 25.0, 88.0, 46.0)
	_v78_store_action_chip(action_rect, action, action_accent, not owned)

func _v78_store_action_chip(r: Rect2, label: String, accent: Color, actionable: bool) -> void:
	var live_accent: Color = accent if actionable else V16_GREEN
	var fill := Color("0b1018") if actionable else Color("08110f")
	_v76_surface(r, live_accent, fill, 0.34 if actionable else 0.10, actionable)

	# Small forward chevron reads as action intent without creating a second large CTA.
	if actionable:
		var chevron_x := r.end.x - 13.0
		var cy := r.get_center().y
		draw_line(Vector2(chevron_x - 4.0, cy - 4.0), Vector2(chevron_x, cy), Color(live_accent, 0.78), 1.5, true)
		draw_line(Vector2(chevron_x, cy), Vector2(chevron_x - 4.0, cy + 4.0), Color(live_accent, 0.78), 1.5, true)

	var text_width: float = r.size.x - (20.0 if actionable else 10.0)
	draw_string(
		v16_title_font,
		Vector2(r.position.x + 5.0, r.get_center().y + 5.0),
		label,
		HORIZONTAL_ALIGNMENT_CENTER,
		text_width,
		12,
		V76_IVORY if actionable else V16_GREEN
	)
