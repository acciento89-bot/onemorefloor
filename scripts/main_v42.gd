extends "res://scripts/main_v41.gd"

# v1.29 — visual completion pass.
# This pass changes the actual authored graphics used at runtime (citadel,
# Wanderer and forge), then tightens the Store presentation so the production
# art and UI hierarchy finally read as one game rather than a polished frame
# surrounding prototype illustrations.

const V42_VERSION := "1.29.0-visual-completion"
const V42_BUILD := "22"
const V42_CITADEL_ART := "res://assets/art/premium_menu_citadel_v2.svg"
const V42_WANDERER_ART := "res://assets/art/wanderer_v2.svg"
const V42_FORGE_ART := "res://assets/art/menu_forge_v2.svg"

var tex_v42_citadel: Texture2D
var tex_v42_wanderer: Texture2D
var tex_v42_forge: Texture2D

func _ready() -> void:
	super._ready()
	tex_v42_citadel = load(V42_CITADEL_ART) as Texture2D
	tex_v42_wanderer = load(V42_WANDERER_ART) as Texture2D
	tex_v42_forge = load(V42_FORGE_ART) as Texture2D
	if telemetry != null:
		telemetry.set_build_context(V42_VERSION, V42_BUILD)
		telemetry.event("visual_completion_ready", {
			"build": V42_BUILD,
			"citadel_v2": tex_v42_citadel != null,
			"wanderer_v2": tex_v42_wanderer != null,
			"forge_v2": tex_v42_forge != null
		})
	queue_redraw()

func _v42_visual_completion_ready() -> bool:
	return tex_v42_citadel != null and tex_v42_wanderer != null and tex_v42_forge != null

# -----------------------------------------------------------------------------
# ACTUAL ART REPLACEMENT
# -----------------------------------------------------------------------------

func _v16_backdrop(kind: String = "arcane", dim: float = 0.0) -> void:
	if kind == "home" and tex_v42_citadel != null:
		if tex_v40_hifi != null:
			draw_texture_rect(tex_v40_hifi, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)
		else:
			super._v16_backdrop("arcane", 0.0)
		var p := _v38_primary()
		var s := _v38_secondary()
		_v15_soft_glow(Vector2(360, 520), 300, p, 0.20)
		if visual_pack != null:
			_v38_draw_pack_halo(Vector2(360, 520), 288.0, p, s)
		draw_texture_rect(tex_v42_citadel, Rect2(0, 282, 720, 660), false, Color.WHITE)
		_v40_home_lighting(p, s)
		if visual_pack != null:
			_v37_corner_runes(p, s)
		if dim > 0.0:
			draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0, 0, 0, dim))
		return
	if kind == "forge" and tex_v42_forge != null:
		draw_texture_rect(tex_v42_forge, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)
		if dim > 0.0:
			draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0, 0, 0, dim))
		return
	super._v16_backdrop(kind, dim)

func _v40_draw_wanderer_texture(r: Rect2, alpha: float = 1.0) -> void:
	if tex_v42_wanderer == null:
		super._v40_draw_wanderer_texture(r, alpha)
		return
	var shadow_center := Vector2(r.get_center().x, r.end.y - 5.0)
	draw_ellipse_safe(shadow_center, Vector2(r.size.x * 0.40, maxf(7.0, r.size.y * 0.025)), Color(0, 0, 0, 0.62 * alpha))
	_v15_soft_glow(r.get_center(), r.size.x * 0.70, _v38_primary(), 0.20 * alpha)
	draw_texture_rect(tex_v42_wanderer, r, false, Color(1, 1, 1, alpha))

# -----------------------------------------------------------------------------
# HOME / HERO / FORGE FINISHING TOUCHES
# -----------------------------------------------------------------------------

func draw_home() -> void:
	super.draw_home()
	if home_overlay != "" or settings_open:
		return
	var p := _v38_primary()
	for i in range(9):
		var x := 70.0 + float(i) * 72.0
		var y := 885.0 + sin(elapsed * 0.42 + float(i)) * 9.0
		draw_circle(Vector2(x, y), 1.2 + float(i % 2), Color(p, 0.10))

func draw_hero_screen() -> void:
	super.draw_hero_screen()
	var p := _v38_primary()
	draw_arc(Vector2(360, 452), 185.0, -2.65, -0.49, 72, Color(p, 0.26), 2.0)

func draw_forge_screen() -> void:
	super.draw_forge_screen()
	for i in range(5):
		var yy := 576.0 - float(i) * 28.0 + sin(elapsed * 1.7 + float(i)) * 5.0
		draw_arc(Vector2(360, yy), 84.0 + float(i) * 17.0, PI + 0.25, TAU - 0.25, 28, Color(V16_ORANGE, 0.055), 1.2)

# -----------------------------------------------------------------------------
# STORE — release-facing visual hierarchy. Existing STORE_ROWS and pointer logic
# remain untouched; only the presentation changes.
# -----------------------------------------------------------------------------

func draw_store_screen() -> void:
	_v16_header("STORE", "Optional support • the full tower remains playable free", V16_GOLD, 11, "arcane")
	var debug: bool = monetization != null and monetization.is_debug_simulation()
	var availability := "PLAYTEST PURCHASES" if debug else "PURCHASES TEMPORARILY UNAVAILABLE"
	_v16_center(availability, 229, 11, Color(V16_MUTED, 0.76))
	var catalog: Array = monetization.product_catalog()
	for i in range(mini(STORE_ROWS.size(), catalog.size())):
		_v42_store_card(i, STORE_ROWS[i], catalog[i], debug)

	var remaining := int(monetization.rewarded_remaining_today())
	var cooldown := int(monetization.rewarded_cooldown_remaining())
	var reward_enabled := remaining > 0 and cooldown <= 0
	var reward_label := "BONUS CACHE  •  %d LEFT" % remaining
	if cooldown > 0:
		reward_label = "BONUS CACHE  •  READY IN %ds" % cooldown
	_v16_button(STORE_REWARDED, reward_label, V16_GREEN, 15, 11, reward_enabled)
	_v16_center("Watch an optional rewarded spot for 140 coins + 8 Soul Shards", 1026, 11, V16_MUTED)
	_v16_button(STORE_BACK, "‹  BACK", V16_PURPLE, 17)
	if store_notice_time > 0.0:
		_v16_center(store_notice, 1108, 12, V16_GOLD_HI)

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

	_v16_frame(r, accent if not owned else V16_GREEN, Color("060912"), 0.12)
	_v16_medallion(Vector2(r.position.x + 50, r.get_center().y), 25, accent, icon_index)
	_v16_text(String(product.get("title", "ITEM")), r.position + Vector2(92, 37), 17, V17_IVORY, true)
	_v16_text(String(product.get("subtitle", "")), r.position + Vector2(92, 65), 11, V16_MUTED)
	var action := "OWNED" if owned else ("TRY" if debug else "BUY")
	var action_color := V16_GREEN if owned else V17_GOLD_HI
	draw_string(v16_title_font, r.position + Vector2(r.size.x - 130, 58), action, HORIZONTAL_ALIGNMENT_CENTER, 104, 14, action_color)
