extends "res://scripts/main_v97.gd"

# ONE MORE FLOOR v1.74 r1.1 — Branding + Product Identity Completion.
# r1.1 is the capture-driven Home correction: the accepted icon stays locked,
# while the matching crest is reduced into the clear top-center safe band.
# Gameplay, input, progression, saves and StoreKit stay inherited.

const V98_BRAND_IDENTITY_VERSION := "1.74-branding-product-identity-r1.1"
const V98_APP_ICON_PATH := "res://assets/art/app_icon_v174.svg"
const V98_LEGACY_ICON_PATH := "res://assets/art/wanderer.svg"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.event("brand_identity_v174_ready", _v98_brand_identity_snapshot())
	queue_redraw()

func _v98_brand_identity_ready() -> bool:
	if not _v97_run_flow_ready():
		return false
	if String(ProjectSettings.get_setting("application/config/icon", "")) != V98_APP_ICON_PATH:
		return false
	if String(ProjectSettings.get_setting("application/config/icon", "")) == V98_LEGACY_ICON_PATH:
		return false
	var icon_texture := load(V98_APP_ICON_PATH) as Texture2D
	if icon_texture == null:
		return false
	return icon_texture.get_width() == 1024 and icon_texture.get_height() == 1024

func _v98_brand_identity_snapshot() -> Dictionary:
	var icon_texture := load(V98_APP_ICON_PATH) as Texture2D
	return {
		"ready": _v98_brand_identity_ready(),
		"version": V98_BRAND_IDENTITY_VERSION,
		"v173_preserved": _v97_run_flow_ready(),
		"app_icon": String(ProjectSettings.get_setting("application/config/icon", "")),
		"legacy_icon_active": String(ProjectSettings.get_setting("application/config/icon", "")) == V98_LEGACY_ICON_PATH,
		"icon_width": icon_texture.get_width() if icon_texture != null else 0,
		"icon_height": icon_texture.get_height() if icon_texture != null else 0,
		"home_brand_crest": true,
		"home_crest_compact_r11": true,
		"input_override": false,
	}

func draw_home() -> void:
	super.draw_home()
	if home_overlay == "" and not settings_open and not tutorial_active:
		_v174_draw_home_brand()

func _v174_draw_home_brand() -> void:
	# r1 overlapped the title. r1.1 uses the empty top-center gap between the
	# Best Floor and coin panels and deliberately contains no duplicate wordmark.
	var c := Vector2(360.0, 68.0)
	var s := 0.50
	var gold := Color("d9ad4d")
	var gold_hi := Color("f8e8a4")
	var violet := Color("a47cff")
	var steel := Color("65758c")

	var outer := PackedVector2Array([
		c + Vector2(-58, 48) * s,
		c + Vector2(-58, -12) * s,
		c + Vector2(-42, -36) * s,
		c + Vector2(-24, -56) * s,
		c + Vector2(0, -72) * s,
		c + Vector2(24, -56) * s,
		c + Vector2(42, -36) * s,
		c + Vector2(58, -12) * s,
		c + Vector2(58, 48) * s,
	])
	draw_colored_polygon(outer, Color("0b101c", 0.94))
	draw_polyline(outer, Color(gold, 0.62), 1.5, true)
	draw_line(c + Vector2(-42, 49) * s, c + Vector2(42, 49) * s, Color(gold, 0.74), 1.5)

	var hood := PackedVector2Array([
		c + Vector2(-30, 2) * s,
		c + Vector2(-22, -30) * s,
		c + Vector2(0, -50) * s,
		c + Vector2(22, -30) * s,
		c + Vector2(30, 2) * s,
		c + Vector2(16, -5) * s,
		c + Vector2(0, 1) * s,
		c + Vector2(-16, -5) * s,
	])
	draw_colored_polygon(hood, Color("111827"))
	draw_polyline(hood, Color(steel, 0.78), 1.5, true)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-35, 11) * s,
		c + Vector2(0, -1) * s,
		c + Vector2(35, 11) * s,
		c + Vector2(26, 42) * s,
		c + Vector2(-26, 42) * s,
	]), Color("202b3e"))

	draw_colored_polygon(PackedVector2Array([
		c + Vector2(0, 12) * s,
		c + Vector2(10, 27) * s,
		c + Vector2(0, 42) * s,
		c + Vector2(-10, 27) * s,
	]), gold)
	draw_line(c + Vector2(26, 27) * s, c + Vector2(69, -43) * s, Color("3a2850"), 4.0, true)
	draw_line(c + Vector2(29, 23) * s, c + Vector2(75, -52) * s, violet, 2.5, true)
	draw_line(c + Vector2(68, -42) * s, c + Vector2(80, -34) * s, gold_hi, 2.0, true)
