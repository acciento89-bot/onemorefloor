extends SceneTree

const AcceptedWorld = preload("res://scripts/world3d_chamber_v166_character_form.gd")
const CandidateWorld = preload("res://scripts/world3d_chamber_v168_character_completion.gd")
const CAPTURE_DIR := "res://artifacts/v168_character_completion"
const CAPTURE_SIZE := Vector2i(720, 1280)

var capture_viewport: SubViewport

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = CAPTURE_SIZE
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))

	# Capture the real current Hero screen first. This is the view that exposed
	# the Wanderer as the next quality bottleneck after frontend r1.2.
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	for _i in range(8):
		await process_frame
	game.tutorial_active = false
	game.settings_open = false
	game.release_paused = false
	if not bool(game.call("_v51_route_to", "hero", false)):
		_fail("could not route to Hero")
		return
	game.call("_v70_sync_menu_3d", true)
	game.queue_redraw()
	for _i in range(14):
		await process_frame
	await RenderingServer.frame_post_draw
	if not _save_image(root.get_texture().get_image(), "hero_v168"):
		return
	game.queue_free()
	await process_frame
	await process_frame

	capture_viewport = SubViewport.new()
	capture_viewport.name = "V168CharacterCaptureViewport"
	capture_viewport.size = CAPTURE_SIZE
	capture_viewport.own_world_3d = true
	capture_viewport.transparent_bg = false
	capture_viewport.disable_3d = false
	capture_viewport.msaa_3d = Viewport.MSAA_2X
	capture_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(capture_viewport)
	await process_frame

	if not await _capture_world(AcceptedWorld, "before_v166"):
		return
	if not await _capture_world(CandidateWorld, "after_v168"):
		return

	print("v1.68 Wanderer matched visual capture passed")
	capture_viewport.queue_free()
	await process_frame
	quit(0)

func _capture_world(world_script: Script, stem: String) -> bool:
	var world = world_script.new()
	capture_viewport.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if stem == "after_v168":
		if not world.has_method("production_character_completion_ready") or not bool(world.call("production_character_completion_ready")):
			_fail("v1.68 candidate world not ready")
			return false
	else:
		if not world.has_method("production_character_form_ready") or not bool(world.call("production_character_form_ready")):
			_fail("v1.66 accepted world not ready")
			return false

	var enemies: Array = [
		{"type":"skeleton", "pos":Vector2(230.0, 390.0), "radius":25.0, "phase":0.3, "attack_cd":1.3},
		{"type":"necromancer", "pos":Vector2(505.0, 405.0), "radius":27.0, "phase":0.8, "attack_cd":1.2},
	]
	var player_pos := Vector2(360.0, 710.0)
	world.call("_capture_signature_state", enemies)
	world.previous_enemy_positions.clear()
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 42.0, 0.0, 0.0, 6)
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 42.06, 0.0, 0.0, 6)
	_clear_transients(world)
	for _i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	if not _save_image(capture_viewport.get_texture().get_image(), stem):
		return false
	world.queue_free()
	await process_frame
	await process_frame
	return true

func _clear_transients(world) -> void:
	world.transition_timer = 0.0
	if world.transition_root != null:
		world.transition_root.visible = false
	for pool in [world.spawn_signature_pool, world.death_signature_pool, world.authority_impact_pool, world.death_burst_pool, world.player_trail_pool, world.enemy_trail_pool]:
		for value in pool:
			var node := value as Node3D
			if node != null:
				node.visible = false

func _save_image(image: Image, stem: String) -> bool:
	if image == null or image.is_empty():
		_fail("empty image for %s" % stem)
		return false
	if image.get_width() != CAPTURE_SIZE.x or image.get_height() != CAPTURE_SIZE.y:
		_fail("invalid capture size for %s: %dx%d" % [stem, image.get_width(), image.get_height()])
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save %s" % output)
		return false
	print("V168_CHARACTER_CAPTURE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V168_CHARACTER_CAPTURE_FAIL:%s" % message)
	quit(1)
