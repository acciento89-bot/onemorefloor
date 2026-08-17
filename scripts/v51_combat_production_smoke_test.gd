extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(5101, "v1.38 main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	for method in [
		"_v51_combat_presentation_ready",
		"_v51_draw_contact_shadow",
		"_v51_draw_rank_presence",
		"draw_enemy",
		"draw_wanderer",
		"draw_player_projectile",
		"draw_enemy_projectile",
	]:
		if not game.has_method(method):
			_fail(5102, "v1.38 combat presentation method missing: %s" % method)
			return

	if not bool(game._v51_combat_presentation_ready()):
		_fail(5103, "v1.38 combat presentation runtime not ready")
		return
	if not bool(game._v50_release_candidate_ready()):
		_fail(5104, "v1.38 lost the v1.37 release-candidate baseline")
		return
	if Engine.max_fps != 60:
		_fail(5105, "v1.38 changed the proven 60 fps mobile cap")
		return

	var renderer := FileAccess.get_file_as_string("res://scripts/main_v51.gd")
	for marker in [
		"1.38.0-combat-production-pass",
		"24-dev",
		"visual[\"radius\"]",
		"draw_player_projectile",
		"draw_enemy_projectile",
		"_v51_draw_contact_shadow",
	]:
		if not renderer.contains(marker):
			_fail(5106, "v1.38 renderer marker missing: %s" % marker)
			return

	# This pass must remain presentation-only. Reject accidental direct writes to
	# the combat values that define balance or collision.
	for forbidden in [
		"run.damage =",
		"run.max_hp =",
		"run.attack_speed =",
		"run.move_speed =",
		"e[\"hp\"] =",
		"e[\"speed\"] =",
		"e[\"damage\"] =",
	]:
		if renderer.contains(forbidden):
			_fail(5107, "v1.38 presentation pass mutates gameplay: %s" % forbidden)
			return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("path=\"res://scripts/main_v51.gd\""):
		_fail(5108, "v1.38 runtime is not active in main.tscn")
		return
	if not scene_text.contains("main_v50.gd"):
		_fail(5109, "v1.37 compatibility baseline marker missing")
		return

	print("ONE MORE FLOOR v1.38 combat production smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
