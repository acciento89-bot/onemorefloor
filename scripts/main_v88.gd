extends "res://scripts/main_v87.gd"

# ONE MORE FLOOR v1.66 release hardening — production monetization surface guard.
# The native StoreKit/ad provider is intentionally not wired in this release.
# Debug builds keep the existing purchase simulator for regression coverage,
# while production/TestFlight builds expose no dead Store route and grant the
# Tower Pass bonus track for free. No gameplay/economy prices are fabricated.

const V88_RELEASE_HARDENING := "1.66-release-surfaces-r1"

func _ready() -> void:
	super._ready()
	_v88_apply_release_entitlements()
	if _v88_release_surfaces_active() and home_overlay == "store":
		home_overlay = ""
	if telemetry != null:
		telemetry.event("release_surfaces_v166_ready", {
			"version": V88_RELEASE_HARDENING,
			"release_mode": _v88_release_surfaces_active(),
			"store_visible": not _v88_release_surfaces_active(),
			"bonus_track_unlocked": bool(monetization.premium_pass_unlocked()) if monetization != null else false,
		})
	queue_redraw()

func _v88_release_surfaces_active() -> bool:
	return OS.get_environment("OMF_FORCE_RELEASE_SURFACES") == "1" or not OS.is_debug_build()

func _v88_apply_release_entitlements() -> void:
	if not _v88_release_surfaces_active() or monetization == null:
		return
	# There is no native purchase path in v1.66. Instead of shipping a locked
	# premium reward track with no way to unlock it, make the bonus track part of
	# the free release until a real native provider is deliberately introduced.
	monetization.premium_pass_season = monetization.current_season_key()

func _v88_release_surface_ready() -> bool:
	if not _v87_character_form_ready():
		return false
	if not _v88_release_surfaces_active():
		return true
	return monetization != null \
		and bool(monetization.premium_pass_unlocked()) \
		and not bool(_v50_store_requests_available())

func _v51_apply_route(screen: String) -> bool:
	if _v88_release_surfaces_active() and screen == ScreenRouter.SCREEN_STORE:
		return false
	return super._v51_apply_route(screen)

func draw_home() -> void:
	if _v88_release_surfaces_active() and home_overlay == "store":
		home_overlay = ""
	super.draw_home()
	if not _v88_release_surfaces_active() or home_overlay != "" or settings_open:
		return

	# Remove the inherited STORE utility from the release-facing footer. The
	# surrounding footer remains intact and SETTINGS stays fully functional.
	draw_rect(V36_STORE_HOME, Color("030611"))
	draw_line(
		Vector2(V36_STORE_HOME.position.x, V36_STORE_HOME.position.y + 1.0),
		Vector2(V36_STORE_HOME.end.x, V36_STORE_HOME.position.y + 1.0),
		Color("252c43"),
		1.0,
		true
	)

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if _v88_release_surfaces_active() and pressed and state == State.HOME:
		if home_overlay == "store":
			home_overlay = ""
			_v51_sync_navigation(false)
			_v51_sync_shell()
			queue_redraw()
			return
		if home_overlay == "" and V36_STORE_HOME.has_point(pos):
			# Intentionally inert invisible footer region in production. There is no
			# purchase provider, so there must be no route to unfinished commerce UI.
			return
	super.pointer(pos, pressed, id)
