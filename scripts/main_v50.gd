extends "res://scripts/main_v49.gd"

# ONE MORE FLOOR v1.37 — Release Candidate hardening.
# No new progression or combat mechanics live here. This layer closes release
# risks around lifecycle saves, mobile frame pacing, touch geometry and a Store
# that must fail closed until a real native purchase/reward provider is wired.

const V50_VERSION := "1.26.0-rc2"
const V50_BUILD := "23"
const V50_CANVAS := Rect2(0, 0, 720, 1280)
const V50_MAX_FPS := 60
const V50_COMBAT_VISUAL_SCALE := 1.12

var v50_background_saves := 0
var v50_last_checkpoint_msec := 0

func _ready() -> void:
	super._ready()
	if Engine.max_fps <= 0 or Engine.max_fps > V50_MAX_FPS:
		Engine.max_fps = V50_MAX_FPS
	if telemetry != null:
		telemetry.set_build_context(V50_VERSION, V50_BUILD)
		telemetry.event("release_candidate_ready", {
			"build": V50_BUILD,
			"touch_geometry": _v50_touch_geometry_safe(),
			"store_requests": _v50_store_requests_available(),
			"max_fps": Engine.max_fps,
			"screenshot_polish": true,
		})
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		_v50_checkpoint_save("application_paused")

func _v50_checkpoint_save(reason: String = "manual") -> bool:
	# Persistent systems already share user://save.cfg. Calling their normal
	# save methods here preserves ownership of each section and avoids inventing a
	# second save format during the release-candidate pass.
	for service in [meta, loot, missions, tower_pass, monetization, visual_pack]:
		if service != null and service.has_method("save_data"):
			service.call("save_data")
	if release_guard != null:
		release_guard.validate(meta, loot)
		release_guard.backup_last_good()
	v50_background_saves += 1
	v50_last_checkpoint_msec = int(Time.get_ticks_msec())
	if telemetry != null:
		telemetry.event("release_checkpoint", {
			"reason": reason,
			"count": v50_background_saves,
			"floor": int(run.floor_no) if run != null else 0,
			"state": int(state),
		})
	return true

func _v50_release_candidate_ready() -> bool:
	return meta != null \
		and loot != null \
		and missions != null \
		and tower_pass != null \
		and monetization != null \
		and release_guard != null \
		and v49_reward_atlas != null \
		and _v50_touch_geometry_safe()

# -----------------------------------------------------------------------------
# Mobile touch/safe-canvas guard.
# The interactive composition remains the tested 720x1280 portrait canvas while
# FullscreenBackdrop fills expanded iPhone/iPad aspect-ratio space behind it.
# -----------------------------------------------------------------------------

func _v50_touch_geometry_safe() -> bool:
	var critical: Array[Rect2] = [
		PLAY,
		MISSIONS_BTN,
		PASS_BTN,
		HERO_TAB,
		FORGE_TAB,
		TALENTS_TAB,
		VAULT_TAB,
		V36_STORE_HOME,
		V36_SETTINGS_HOME,
		STORE_BACK,
		STORE_REWARDED,
	]
	for r in critical:
		if not _v50_rect_inside_canvas(r):
			return false
		if r.size.x < 42.0 or r.size.y < 42.0:
			return false
	return true

func _v50_rect_inside_canvas(r: Rect2) -> bool:
	return r.position.x >= V50_CANVAS.position.x \
		and r.position.y >= V50_CANVAS.position.y \
		and r.end.x <= V50_CANVAS.end.x \
		and r.end.y <= V50_CANVAS.end.y

# -----------------------------------------------------------------------------
# Store fail-closed release behavior.
# monetization_service.gd intentionally contains only debug simulation today.
# A TestFlight/App Store build must therefore never draw an actionable BUY or
# rewarded-ad control that cannot complete. Debug builds retain their simulator.
# -----------------------------------------------------------------------------

func _v50_store_requests_available() -> bool:
	return monetization != null and monetization.is_debug_simulation()

func draw_store_screen() -> void:
	_v16_header("STORE", "Optional support • the full tower remains playable free", V16_GOLD, 11, "arcane")
	var requests_available := _v50_store_requests_available()
	var availability := "PLAYTEST PURCHASE SIMULATION" if requests_available else "PURCHASES CURRENTLY UNAVAILABLE"
	var availability_color := V16_GREEN if requests_available else Color(V16_MUTED, 0.82)
	_v16_center(availability, 229, 11, availability_color)

	var catalog: Array = monetization.product_catalog() if monetization != null else []
	for i in range(mini(STORE_ROWS.size(), catalog.size())):
		_v50_store_card(i, STORE_ROWS[i], catalog[i], requests_available)

	var remaining := int(monetization.rewarded_remaining_today()) if monetization != null else 0
	var cooldown := int(monetization.rewarded_cooldown_remaining()) if monetization != null else 0
	var reward_enabled := requests_available and remaining > 0 and cooldown <= 0
	var reward_label := "BONUS CACHE UNAVAILABLE"
	if requests_available:
		reward_label = "BONUS CACHE  •  %d LEFT" % remaining
		if cooldown > 0:
			reward_label = "BONUS CACHE  •  READY IN %ds" % cooldown
	_v16_button(STORE_REWARDED, reward_label, V16_GREEN, 15, 11, reward_enabled)
	_v16_center("Optional reward • never required for tower progression", 1026, 11, V16_MUTED)
	_v16_button(STORE_BACK, "‹  BACK", V16_PURPLE, 17)
	if store_notice_time > 0.0:
		_v16_center(store_notice, 1108, 12, V16_GOLD_HI)

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

	var frame_accent := V16_GREEN if owned else (accent if requests_available else Color("565b69"))
	_v16_frame(r, frame_accent, Color("060912"), 0.12 if requests_available or owned else 0.05)
	_v16_medallion(Vector2(r.position.x + 50, r.get_center().y), 25, accent, icon_index)
	_v16_text(String(product.get("title", "ITEM")), r.position + Vector2(92, 37), 17, V17_IVORY if requests_available or owned else Color("a3a6af"), true)
	_v16_text(String(product.get("subtitle", "")), r.position + Vector2(92, 65), 11, V16_MUTED)
	var action := "OWNED" if owned else ("TRY" if requests_available else "UNAVAILABLE")
	var action_color := V16_GREEN if owned else (V17_GOLD_HI if requests_available else Color("777b88"))
	draw_string(v16_title_font, r.position + Vector2(r.size.x - 150, 58), action, HORIZONTAL_ALIGNMENT_CENTER, 128, 12, action_color)

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if pressed and state == State.HOME and home_overlay == "store" and not _v50_store_requests_available():
		if STORE_BACK.has_point(pos):
			home_overlay = ""
			_audio("menu")
			return
		for r in STORE_ROWS:
			if r.has_point(pos):
				_v50_store_unavailable_notice()
				return
		if STORE_REWARDED.has_point(pos):
			_v50_store_unavailable_notice()
			return
		return
	super.pointer(pos, pressed, id)

func _v50_store_unavailable_notice() -> void:
	store_notice = "PURCHASES ARE DISABLED IN THIS TEST BUILD"
	store_notice_time = 2.8
	_audio("menu")
	queue_redraw()

# -----------------------------------------------------------------------------
# Screenshot-driven final polish.
# The Build 22 device captures exposed two presentation issues: the locked
# premium badge sat on top of the reward values, and the combat Wanderer still
# read slightly smaller than the new authored enemy silhouettes. Neither change
# touches hitboxes, collision radii, reward values or progression state.
# -----------------------------------------------------------------------------

func _v50_pass_lock_badge_rect(card: Rect2) -> Rect2:
	return Rect2(card.position + Vector2(458, 8), Vector2(82, 22))

func _v41_draw_pass_level(r: Rect2, level_no: int, current_level: int, premium_unlocked: bool) -> void:
	var free_reward: Dictionary = tower_pass.reward_for(level_no, false)
	var premium_reward: Dictionary = tower_pass.reward_for(level_no, true)
	var reached := level_no <= current_level
	var free_claimable := bool(tower_pass.can_claim(level_no, false, premium_unlocked))
	var premium_claimable := bool(tower_pass.can_claim(level_no, true, premium_unlocked))
	var accent := V16_GOLD if reached else Color("52576b")
	if free_claimable or premium_claimable:
		accent = V16_PURPLE_HI

	var rail_center := Vector2(82, r.get_center().y)
	draw_circle(rail_center, 16.0, Color("050713"))
	draw_arc(rail_center, 16.0, 0.0, TAU, 32, Color(accent, 0.92), 2.0)
	_v16_center_in(Rect2(66, rail_center.y - 10, 32, 20), str(level_no), 10, V17_IVORY, true)

	var card := Rect2(112, r.position.y, 556, r.size.y)
	_v16_frame(card, accent, Color("050912"), 0.11)
	_v16_text("LV %02d" % level_no, card.position + Vector2(16, 31), 16, V17_IVORY, true)
	_v16_text("FREE", card.position + Vector2(92, 25), 9, V16_GREEN, true)
	_v41_draw_pass_reward(free_reward, card.position + Vector2(139, 49), V16_GREEN, free_claimable, reached)
	_v16_text("PREMIUM", card.position + Vector2(315, 25), 9, V16_GOLD, true)
	_v41_draw_pass_reward(premium_reward, card.position + Vector2(374, 49), V16_GOLD, premium_claimable, reached and premium_unlocked)

	if not premium_unlocked:
		# Keep the reward readable. A compact lock badge replaces the old 232x46
		# dark overlay that covered the C/S values in the device screenshot.
		var lock_badge := _v50_pass_lock_badge_rect(card)
		draw_rect(lock_badge, Color("090812", 0.94))
		draw_rect(lock_badge, Color(V16_GOLD, 0.42), false, 1.0)
		draw_string(v16_title_font, lock_badge.position + Vector2(4, 15), "LOCKED", HORIZONTAL_ALIGNMENT_CENTER, lock_badge.size.x - 8, 9, Color("b6a9c0"))

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	# Only the rendered combat sprite grows; movement/collision geometry remains
	# exactly as inherited from v1.36.
	super.draw_wanderer(pos, scale * V50_COMBAT_VISUAL_SCALE if combat else scale, combat)
