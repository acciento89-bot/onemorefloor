class_name ScreenRouter
extends RefCounted

signal route_changed(previous: String, current: String, revision: int)

const SCREEN_HOME := "home"
const SCREEN_HERO := "hero"
const SCREEN_FORGE := "forge"
const SCREEN_TALENTS := "talents"
const SCREEN_VAULT := "vault"
const SCREEN_MISSIONS := "missions"
const SCREEN_PASS := "pass"
const SCREEN_STORE := "store"
const SCREEN_RUN := "run"
const SCREEN_UPGRADE := "upgrade"
const SCREEN_DECISION := "decision"
const SCREEN_GAME_OVER := "game_over"

const MENU_SCREENS := [
	SCREEN_HOME,
	SCREEN_HERO,
	SCREEN_FORGE,
	SCREEN_TALENTS,
	SCREEN_VAULT,
	SCREEN_MISSIONS,
	SCREEN_PASS,
	SCREEN_STORE,
]

const WORLD_SCREENS := [
	SCREEN_RUN,
	SCREEN_UPGRADE,
	SCREEN_DECISION,
	SCREEN_GAME_OVER,
]

const KNOWN_SCREENS := [
	SCREEN_HOME,
	SCREEN_HERO,
	SCREEN_FORGE,
	SCREEN_TALENTS,
	SCREEN_VAULT,
	SCREEN_MISSIONS,
	SCREEN_PASS,
	SCREEN_STORE,
	SCREEN_RUN,
	SCREEN_UPGRADE,
	SCREEN_DECISION,
	SCREEN_GAME_OVER,
]

# Today every persistent/meta menu returns to Home. Keeping that relationship in
# one place means future nested menus can gain real parent routes without adding
# another chain of hitbox-specific special cases to the gameplay renderer.
const PARENT_SCREEN := {
	SCREEN_HERO: SCREEN_HOME,
	SCREEN_FORGE: SCREEN_HOME,
	SCREEN_TALENTS: SCREEN_HOME,
	SCREEN_VAULT: SCREEN_HOME,
	SCREEN_MISSIONS: SCREEN_HOME,
	SCREEN_PASS: SCREEN_HOME,
	SCREEN_STORE: SCREEN_HOME,
	SCREEN_GAME_OVER: SCREEN_HOME,
}

var current_screen := SCREEN_HOME
var previous_screen := ""
var revision := 0
var history: Array[String] = [SCREEN_HOME]

func is_known_screen(screen: String) -> bool:
	return screen in KNOWN_SCREENS

func is_menu_screen(screen: String = current_screen) -> bool:
	return screen in MENU_SCREENS

func is_world_screen(screen: String = current_screen) -> bool:
	return screen in WORLD_SCREENS

func navigate(screen: String, remember: bool = true) -> bool:
	if not is_known_screen(screen):
		return false
	if screen == current_screen:
		return false
	var old := current_screen
	previous_screen = old
	current_screen = screen
	revision += 1
	if remember:
		if history.is_empty() or history[history.size() - 1] != screen:
			history.append(screen)
			while history.size() > 16:
				history.pop_front()
	route_changed.emit(old, current_screen, revision)
	return true

func replace(screen: String) -> bool:
	if not is_known_screen(screen):
		return false
	if screen == current_screen:
		return false
	var old := current_screen
	previous_screen = old
	current_screen = screen
	revision += 1
	if history.is_empty():
		history.append(screen)
	else:
		history[history.size() - 1] = screen
	route_changed.emit(old, current_screen, revision)
	return true

func parent_for(screen: String = current_screen) -> String:
	return String(PARENT_SCREEN.get(screen, SCREEN_HOME))

func reset_to_home() -> bool:
	var changed := navigate(SCREEN_HOME, false)
	history.clear()
	history.append(SCREEN_HOME)
	return changed

func snapshot() -> Dictionary:
	return {
		"current": current_screen,
		"previous": previous_screen,
		"revision": revision,
		"menu": is_menu_screen(),
		"world": is_world_screen(),
		"history": history.duplicate(),
	}
