extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(4101, "v1.28 progression UI: main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame

	if not game.has_method("_v41_progression_ui_ready") or not bool(game._v41_progression_ui_ready()):
		_fail(4102, "v1.28 progression UI renderer is not active")
		return
	for method in ["_v41_draw_mastery_branch", "_v41_draw_pass_level", "_v41_draw_pass_reward", "_v41_draw_vault_comparison", "_v41_draw_vault_action_panel"]:
		if not game.has_method(method):
			_fail(4103, "v1.28 progression UI missing %s" % method)
			return

	# New art direction must remain wired to the existing live interaction map.
	if not game.V31_MASTERY_RECTS[0].has_point(game.V31_MASTERY_RECTS[0].get_center()):
		_fail(4104, "v1.28 mastery hitbox invalid")
		return
	if not game.PASS_FREE.has_point(game.PASS_FREE.get_center()) or not game.PASS_PREMIUM.has_point(game.PASS_PREMIUM.get_center()):
		_fail(4105, "v1.28 Tower Pass claim hitboxes invalid")
		return
	for rect in [game.V8_EQUIP, game.V8_DISMANTLE, game.V8_CRAFT_WEAPON, game.V8_CRAFT_ARMOR, game.V8_CRAFT_RELIC, game.V31_ENHANCE, game.V31_ENCHANT, game.V31_AWAKEN]:
		if not rect.has_point(rect.get_center()):
			_fail(4106, "v1.28 Vault workshop hitbox invalid")
			return

	# Mastery remains genuinely interactive, not decorative. Preserve the user's
	# save values so this regression test cannot pollute later smoke tests.
	var original_sigils := int(game.meta.ascension_sigils)
	var original_warpath := int(game.meta.mastery_level("warpath"))
	game.meta.ascension_sigils = maxi(original_sigils, int(game.meta.mastery_cost("warpath")) + 3)
	game.state = game.State.TALENTS
	game.tutorial_active = false
	game.settings_open = false
	game.v31_mastery_open = true
	game.pointer((game.V31_MASTERY_RECTS[0] as Rect2).get_center(), true, 41001)
	if int(game.meta.mastery_level("warpath")) != original_warpath + 1:
		_fail(4107, "v1.28 mastery tree tap did not reach live progression logic")
		return
	game.meta.mastery_levels["warpath"] = original_warpath
	game.meta.ascension_sigils = original_sigils
	game.meta.save_data()

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v41.gd") or not scene_text.contains("main_v40.gd"):
		_fail(4108, "v1.28 scene wiring/compatibility baseline missing")
		return
	var renderer := FileAccess.get_file_as_string("res://scripts/main_v41.gd")
	for marker in ["ASCENSION MASTERY", "WORKSHOP", "ITEM PROGRESSION", "Season %s", "comparison_delta"]:
		if not renderer.contains(marker):
			_fail(4109, "v1.28 progression UI marker missing: %s" % marker)
			return
	for forbidden in ["home_0.b64", "assets/art/reference/", "_v20_load_chunked_webp"]:
		if renderer.contains(forbidden):
			_fail(4110, "v1.28 screenshot/reference payload regression: %s" % forbidden)
			return

	print("ONE MORE FLOOR v1.28 progression UI art pass smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
