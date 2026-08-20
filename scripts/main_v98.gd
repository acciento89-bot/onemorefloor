extends "res://scripts/main_v97.gd"

# ONE MORE FLOOR v1.74 r1 — Branding + Product Identity Completion.
# Aligns the shipping app icon and Home identity with the accepted dark-fantasy
# Wanderer/tower direction. Gameplay, input, progression, saves and StoreKit stay inherited.

const V98_BRAND_IDENTITY_VERSION := "1.74-branding-product-identity-r1"
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
		"input_override": false,
	}

func draw_home() -> void:
	super.draw_home()
	if home_overlay == "" and not settings_open and not tutorial_active:
		_v174_draw_home_brand()

func _v174_draw_home_brand() -> void:
	# Compact crest in the safe top band: same tower / faceless hood / gold-core /
	# ascending-violet-blade grammar as the shipping app icon.
	var c := Vector2(360.0, 126.0)
	var gold := Color("d9ad4d")
	var gold_hi := Color("f8e8a4")
	var violet := Color("a47cff")
	var steel := Color("65758c")
	var ink := Color("060913")

	# Gothic arch / tower seal.
	var outer := PackedVector2Array([
		c + Vector2(-58, 48),
		c + Vector2(-58, -12),
		c + Vector2(-42, -36),
		c + Vector2(-24, -56),
		c + Vector2(0, -72),
		c + Vector2(24, -56),
		c + Vector2(42, -36),
		c + Vector2(58, -12),
		c + Vector2(58, 48),
	])
	draw_colored_polygon(outer, Color("0b101c", 0.94))
	draw_polyline(outer, Color(gold, 0.56), 2.0, true)
	draw_line(c + Vector2(-42, 49), c + Vector2(42, 49), Color(gold, 0.70), 2.0)

	# Hood and armored chest; no face geometry.
	var hood := PackedVector2Array([
		c + Vector2(-30, 2),
		c + Vector2(-22, -30),
		c + Vector2(0, -50),
		c + Vector2(22, -30),
		c + Vector2(30, 2),
		c + Vector2(16, -5),
		c + Vector2(0, 1),
		c + Vector2(-16, -5),
	])
	draw_colored_polygon(hood, Color("111827"))
	draw_polyline(hood, Color(steel, 0.74), 2.0, true)
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(-35, 11), c + Vector2(0, -1), c + Vector2(35, 11),
		c + Vector2(26, 42), c + Vector2(-26, 42)
	]), Color("202b3e"))

	# Gold core and violet blade are the two small-size identity anchors.
	draw_colored_polygon(PackedVector2Array([
		c + Vector2(0, 12), c + Vector2(10, 27), c + Vector2(0, 42), c + Vector2(-10, 27)
	]), gold)
	draw_line(c + Vector2(26, 27), c + Vector2(69, -43), Color("3a2850"), 8.0, true)
	draw_line(c + Vector2(29, 23), c + Vector2(75, -52), violet, 4.0, true)
	draw_line(c + Vector2(68, -42), c + Vector2(80, -34), gold_hi, 4.0, true)

	_v16_center("KAMILUNAVO GAMES", 192, 8, Color(V16_MUTED, 0.72), true)
