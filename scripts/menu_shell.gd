class_name MenuShell
extends CanvasLayer

signal shell_screen_changed(previous: String, current: String, menu_visible: bool)

var active_screen := "home"
var previous_screen := ""
var menu_visible := true
var revision := 0

func set_screen(screen: String, is_menu: bool) -> void:
	if screen == active_screen and is_menu == menu_visible:
		return
	var old := active_screen
	previous_screen = old
	active_screen = screen
	menu_visible = is_menu
	revision += 1
	shell_screen_changed.emit(old, active_screen, menu_visible)

func snapshot() -> Dictionary:
	return {
		"active_screen": active_screen,
		"previous_screen": previous_screen,
		"menu_visible": menu_visible,
		"revision": revision,
	}
