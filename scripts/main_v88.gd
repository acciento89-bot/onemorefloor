extends "res://scripts/main_v87.gd"

# ONE MORE FLOOR v1.66 release hardening — production monetization/legal guard.
# The native StoreKit/ad provider is intentionally not wired in this release.
# Debug builds keep the existing purchase simulator for regression coverage,
# while production/TestFlight builds expose no dead Store route and grant the
# Tower Pass bonus track for free. The Privacy Policy remains reachable from
# Settings in every build.

const V88_RELEASE_HARDENING := "1.66-release-surfaces-r1"
const V88_PRIVACY_URL := "https://kamilunavo.com/privacy"
const V88_PRIVACY := Rect2(170, 864, 380, 44)

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
			"privacy_link": _v88_privacy_link_ready(),
		})
	queue_redraw()

func spawn_floor() -> void:
	super.spawn_floor()
	_v88_ensure_realm_signature_enemy()

func _v88_ensure_realm_signature_enemy() -> void:
	# A realm introduction must actually read as that realm. Forgotten Castle
	# intentionally keeps Skeleton in its mixed pool, but pure RNG could roll an
	# all-Skeleton room on floor 21 and visually erase the transition. Preserve
	# the generated room/count while guaranteeing one Castle-signature actor.
	if current_room.is_empty() or String(current_room.get("type", "")) == "BOSS":
		return
	if String(current_room.get("area", "")) != "FORGOTTEN CASTLE":
		return
	for enemy in enemies:
		if String(enemy.get("type", "")) in ["gargoyle", "sentinel", "hexer"]:
			return

	var replacement: Dictionary = EnemyFactory.make_enemy("gargoyle", int(run.floor_no), rng, player_pos)
	var room_type := String(current_room.get("type", "COMBAT"))
	if room_type == "ELITE":
		replacement = EnemyFactory.empower_elite(replacement)
	elif room_type == "AMBUSH":
		replacement["speed"] = float(replacement["speed"]) * 1.12
	if enemies.is_empty():
		enemies.append(replacement)
	else:
		enemies[0] = replacement

func _v88_release_surfaces_active() -> bool:
	return OS.get_environment("OMF_FORCE_RELEASE_SURFACES") == "1" or not OS.is_debug_build()

func _v50_store_requests_available() -> bool:
	# A headless release-surface smoke still runs inside a debug Godot binary.
	# Force the same fail-closed provider state that a signed production export
	# receives so CI cannot mistake the editor purchase simulator for StoreKit.
	if _v88_release_surfaces_active():
		return false
	return super._v50_store_requests_available()

func _v88_apply_release_entitlements() -> void:
	if not _v88_release_surfaces_active() or monetization == null:
		return
	# There is no native purchase path in v1.66. Instead of shipping a locked
	# premium reward track with no way to unlock it, make the bonus track part of
	# the free release until a real native provider is deliberately introduced.
	monetization.premium_pass_season = monetization.current_season_key()

func _v88_privacy_link_ready() -> bool:
	return V88_PRIVACY_URL.begins_with("https://") \
		and _v50_rect_inside_canvas(V88_PRIVACY) \
		and V88_PRIVACY.size.x >= 42.0 \
		and V88_PRIVACY.size.y >= 42.0

func _v88_release_surface_ready() -> bool:
	if not _v87_character_form_ready() or not _v88_privacy_link_ready():
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

func _draw_settings_overlay() -> void:
	super._draw_settings_overlay()
	# The legacy analytics note occupies this footer band. Cover it with the
	# release-facing legal action so Privacy is a real 44pt touch target instead
	# of tiny footer text.
	draw_rect(Rect2(92, 860, 536, 52), Color("10162b"))
	button(V88_PRIVACY, "PRIVACY POLICY", C_BLUE, 14)

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if pressed and settings_open and V88_PRIVACY.has_point(pos):
		OS.shell_open(V88_PRIVACY_URL)
		_audio("menu")
		return
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
