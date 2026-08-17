extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var fx_path := "res://assets/art/combat_fx_v46.svg"
	if not FileAccess.file_exists(fx_path):
		_fail(4601, "v1.33 combat FX atlas missing")
		return
	if load(fx_path) as Texture2D == null:
		_fail(4602, "v1.33 combat FX atlas failed to import")
		return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(4603, "v1.33 main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	if not game.has_method("_v46_combat_vfx_ready") or not bool(game._v46_combat_vfx_ready()):
		_fail(4604, "v1.33 combat impact runtime is not active")
		return
	for method in ["_v46_draw_hit_fx", "_v46_draw_death_fx", "_v46_draw_slash_fx", "_v46_draw_attack_tell"]:
		if not game.has_method(method):
			_fail(4605, "v1.33 combat method missing: %s" % method)
			return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v46.gd") or not scene_text.contains("main_v45.gd"):
		_fail(4606, "v1.33 scene wiring or v1.32 compatibility baseline missing")
		return
	var renderer := FileAccess.get_file_as_string("res://scripts/main_v46.gd")
	for marker in ["COMBAT ANIMATION + IMPACT PASS", "v46_hit", "v46_death", "v46_slash", "combat_actor_defeated", "draw_coin_orb"]:
		if not renderer.to_upper().contains(marker.to_upper()):
			_fail(4607, "v1.33 renderer marker missing: %s" % marker)
			return

	print("ONE MORE FLOOR v1.33 combat VFX smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
