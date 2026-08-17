extends "res://scripts/main_v50.gd"

# ONE MORE FLOOR v1.38 — 3D pivot, phase 1: menu/navigation foundation.
# The existing production menu rendering stays visually unchanged in this pass.
# What changes is ownership: top-level screen routing is centralized so the
# future Node3D combat world can be mounted/unmounted behind a stable UI shell
# without teaching every menu button about the gameplay renderer.

const ScreenRouter = preload("res://scripts/screen_router.gd")
const V51_VERSION := "1.38.0-3d-menu-foundation"
const V51_BUILD := "24-dev"

var v51_navigation
var v51_explicit_routes := 0

func _ready() -> void:
	super._ready()
	v51_navigation = ScreenRouter.new()
	_v51_sync_navigation(false)
	if telemetry != null:
		telemetry.set_build_context(V51_VERSION, V51_BUILD)
		telemetry.event("menu_navigation_foundation_ready", {
			"screen": _v51_screen_from_legacy(),
			"menu_shell": true,
			"world_layer_requested": _v51_world_layer_requested(),
		})
	queue_redraw()

func _process(delta: float) -> void:
	super._process(delta)
	_v51_sync_navigation(false)

# -----------------------------------------------------------------------------
# Canonical route mapping.
# Legacy State/home_overlay values remain the rendering source of truth for this
# compatibility pass. ScreenRouter becomes the stable API that the upcoming
# CanvasLayer menu shell and Node3D world will share.
# -----------------------------------------------------------------------------

func _v51_screen_from_legacy() -> String:
	if state == State.HOME:
		match home_overlay:
			"missions": return ScreenRouter.SCREEN_MISSIONS
			"pass": return ScreenRouter.SCREEN_PASS
			"store": return ScreenRouter.SCREEN_STORE
			_: return ScreenRouter.SCREEN_HOME
	match state:
		State.HERO: return ScreenRouter.SCREEN_HERO
		State.FORGE: return ScreenRouter.SCREEN_FORGE
		State.TALENTS: return ScreenRouter.SCREEN_TALENTS
		State.VAULT: return ScreenRouter.SCREEN_VAULT
		State.RUNNING: return ScreenRouter.SCREEN_RUN
		State.UPGRADE: return ScreenRouter.SCREEN_UPGRADE
		State.DECISION: return ScreenRouter.SCREEN_DECISION
		State.GAME_OVER: return ScreenRouter.SCREEN_GAME_OVER
	return ScreenRouter.SCREEN_HOME

func _v51_apply_route(screen: String) -> bool:
	if v51_navigation == null or not v51_navigation.is_known_screen(screen):
		return false
	match screen:
		ScreenRouter.SCREEN_HOME:
			state = State.HOME
			home_overlay = ""
		ScreenRouter.SCREEN_HERO:
			state = State.HERO
			home_overlay = ""
		ScreenRouter.SCREEN_FORGE:
			state = State.FORGE
			home_overlay = ""
		ScreenRouter.SCREEN_TALENTS:
			state = State.TALENTS
			home_overlay = ""
		ScreenRouter.SCREEN_VAULT:
			state = State.VAULT
			home_overlay = ""
		ScreenRouter.SCREEN_MISSIONS:
			state = State.HOME
			home_overlay = "missions"
		ScreenRouter.SCREEN_PASS:
			state = State.HOME
			home_overlay = "pass"
		ScreenRouter.SCREEN_STORE:
			state = State.HOME
			home_overlay = "store"
		_:
			# Runtime-only states are synchronized from gameplay. Menu input never
			# fabricates RUNNING/UPGRADE/DECISION/GAME_OVER directly.
			return false
	return true

func _v51_route_to(screen: String, play_audio: bool = true) -> bool:
	if not _v51_apply_route(screen):
		return false
	var previous := v51_navigation.current_screen
	var changed: bool = bool(v51_navigation.navigate(screen))
	if changed:
		v51_explicit_routes += 1
		if play_audio:
			_audio("menu")
		if telemetry != null:
			telemetry.event("menu_route", {
				"from": previous,
				"to": screen,
				"count": v51_explicit_routes,
			})
	queue_redraw()
	return true

func _v51_route_home(play_audio: bool = true) -> bool:
	return _v51_route_to(ScreenRouter.SCREEN_HOME, play_audio)

func _v51_sync_navigation(emit_telemetry: bool = false) -> void:
	if v51_navigation == null:
		return
	var desired := _v51_screen_from_legacy()
	if desired == v51_navigation.current_screen:
		return
	var previous := v51_navigation.current_screen
	v51_navigation.replace(desired)
	if emit_telemetry and telemetry != null:
		telemetry.event("screen_sync", {"from": previous, "to": desired})

func _v51_world_layer_requested() -> bool:
	if v51_navigation == null:
		return state in [State.RUNNING, State.UPGRADE, State.DECISION, State.GAME_OVER]
	return bool(v51_navigation.is_world_screen())

func _v51_menu_foundation_ready() -> bool:
	return v51_navigation != null \
		and v51_navigation.is_known_screen(_v51_screen_from_legacy()) \
		and _v50_release_candidate_ready()

# -----------------------------------------------------------------------------
# High-level navigation input.
# Content actions (buy/claim/train/equip/etc.) continue through the proven
# inherited pointer chain. Only screen changes are intercepted here.
# -----------------------------------------------------------------------------

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if not pressed:
		super.pointer(pos, pressed, id)
		return

	# Modal and run-pause input must retain their established ordering.
	if settings_open or tutorial_active or release_paused:
		super.pointer(pos, pressed, id)
		_v51_sync_navigation(false)
		return

	if state == State.HOME:
		if home_overlay == "":
			if MISSIONS_BTN.has_point(pos):
				_v51_route_to(ScreenRouter.SCREEN_MISSIONS)
				return
			if PASS_BTN.has_point(pos):
				_v51_route_to(ScreenRouter.SCREEN_PASS)
				return
			if HERO_TAB.has_point(pos):
				_v51_route_to(ScreenRouter.SCREEN_HERO)
				return
			if FORGE_TAB.has_point(pos):
				_v51_route_to(ScreenRouter.SCREEN_FORGE)
				return
			if TALENTS_TAB.has_point(pos):
				_v51_route_to(ScreenRouter.SCREEN_TALENTS)
				return
			if VAULT_TAB.has_point(pos):
				_v51_route_to(ScreenRouter.SCREEN_VAULT)
				return
			if V36_STORE_HOME.has_point(pos):
				_v51_route_to(ScreenRouter.SCREEN_STORE)
				return
		elif home_overlay == "store" and STORE_BACK.has_point(pos):
			_v51_route_home()
			return
		elif home_overlay in ["missions", "pass"] and OVERLAY_BACK.has_point(pos):
			_v51_route_home()
			return

	if state in [State.HERO, State.FORGE, State.VAULT] and META_BACK.has_point(pos):
		_v51_route_home()
		return
	if state == State.TALENTS and not v31_mastery_open and META_BACK.has_point(pos):
		_v51_route_home()
		return

	# PLAY, gameplay, progression actions and modal internals remain owned by the
	# existing runtime. Synchronize after it runs so automatic transitions (run
	# start, cash-out, death, premium-pass redirect, pause-home) enter the router.
	super.pointer(pos, pressed, id)
	_v51_sync_navigation(false)
