extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var atlases := [
		"res://assets/art/actors_void_v45.svg",
		"res://assets/art/actors_eclipse_v45.svg",
		"res://assets/art/actors_bloodstar_v45.svg",
		"res://assets/art/actors_celestial_v45.svg",
	]
	for path in atlases:
		if not FileAccess.file_exists(path):
			_fail(4501, "v1.32 actor atlas missing: %s" % path)
			return
		if load(path) as Texture2D == null:
			_fail(4502, "v1.32 actor atlas failed to import: %s" % path)
			return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(4503, "v1.32 main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	if not game.has_method("_v45_actor_art_ready") or not bool(game._v45_actor_art_ready()):
		_fail(4504, "v1.32 actor art runtime is not active")
		return
	var ids := [
		"void_lancer","rift_hound","soul_cannon","void_archon",
		"eclipse_oracle","shade_duelist","sunless_guard","eclipse_regent",
		"blood_seraph","chain_titan","hemomancer","bloodstar_tyrant",
		"star_devourer","crownless","cosmic_eye","world_eater",
	]
	for actor_id in ids:
		if not bool(game._v45_has_actor(actor_id)):
			_fail(4505, "v1.32 actor mapping missing: %s" % actor_id)
			return
		if game._v45_actor_texture(actor_id) == null:
			_fail(4506, "v1.32 actor texture missing: %s" % actor_id)
			return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v45.gd") or not scene_text.contains("main_v44.gd"):
		_fail(4507, "v1.32 scene wiring or v1.31 compatibility baseline missing")
		return
	var renderer := FileAccess.get_file_as_string("res://scripts/main_v45.gd")
	for marker in ["Dedicated endgame actor art", "V45_ACTOR_SLOTS", "void_lancer", "eclipse_oracle", "blood_seraph", "world_eater", "_v45_draw_actor", "_v45_draw_intro_actor"]:
		if not renderer.contains(marker):
			_fail(4508, "v1.32 renderer marker missing: %s" % marker)
			return

	print("ONE MORE FLOOR v1.32 dedicated actor art smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
