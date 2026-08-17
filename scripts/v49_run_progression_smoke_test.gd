extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var art_path := "res://assets/art/progression_rewards_v49.svg"
	if not FileAccess.file_exists(art_path):
		_fail(4901, "v1.36 progression reward atlas missing")
		return
	if load(art_path) as Texture2D == null:
		_fail(4902, "v1.36 progression reward atlas failed to import")
		return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(4903, "v1.36 main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	if not game.has_method("_v49_run_progression_ready") or not bool(game._v49_run_progression_ready()):
		_fail(4904, "v1.36 run progression presentation is not active")
		return

	var expected_icons := {
		"power":0, "crit":0, "vitality":1, "armor":1, "nova":2,
	}
	for kind in expected_icons.keys():
		if int(game._v49_upgrade_icon_for_kind(String(kind))) != int(expected_icons[kind]):
			_fail(4905, "v1.36 upgrade art mapping mismatch: %s" % String(kind))
			return

	if int(game._v49_event_icon("blood_altar")) != 0 or int(game._v49_event_icon("arcane_shrine")) != 2 or int(game._v49_event_icon("lost_merchant")) != 3:
		_fail(4906, "v1.36 room-event art mapping mismatch")
		return

	for method in ["draw_upgrade", "_v49_draw_upgrade_card", "_v49_draw_room_event", "_v49_draw_event_choice", "draw_coin_orb"]:
		if not game.has_method(method):
			_fail(4907, "v1.36 presentation method missing: %s" % method)
			return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v49.gd") or not scene_text.contains("main_v48.gd"):
		_fail(4908, "v1.36 scene wiring or v1.35 compatibility baseline missing")
		return

	var renderer := FileAccess.get_file_as_string("res://scripts/main_v49.gd")
	for marker in ["RUN PROGRESSION PRESENTATION", "FLOOR %d CLEARED", "TAP TO CLAIM", "EVENT_RECTS", "NOT ENOUGH COINS", "RUN COINS"]:
		if not renderer.to_upper().contains(marker.to_upper()):
			_fail(4909, "v1.36 renderer marker missing: %s" % marker)
			return

	print("ONE MORE FLOOR v1.36 run progression presentation smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
