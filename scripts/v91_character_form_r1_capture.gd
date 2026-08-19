extends SceneTree

const AcceptedWorld = preload("res://scripts/world3d_chamber_v165_environment_depth_r13.gd")
const CandidateWorld = preload("res://scripts/world3d_chamber_v166_character_form.gd")
const CAPTURE_DIR := "res://artifacts/v166_character_form_r1"
const CAPTURE_SIZE := Vector2i(720, 1280)

var capture_viewport: SubViewport

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	capture_viewport = SubViewport.new()
	capture_viewport.name = "V166CaptureViewport"
	capture_viewport.size = CAPTURE_SIZE
	capture_viewport.own_world_3d = true
	capture_viewport.transparent_bg = false
	capture_viewport.disable_3d = false
	capture_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(capture_viewport)

	if not await _capture_world(AcceptedWorld, "before"):
		return
	if not await _capture_world(CandidateWorld, "after"):
		return

	print("v1.66 character form r1 matched visual capture passed")
	quit(0)

func _capture_world(world_script: Script, prefix: String) -> bool:
	var world = world_script.new()
	capture_viewport.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if prefix == "after" and not bool(world.call("production_character_form_ready")):
		_fail("candidate v1.66 world is not ready")
		return false
	if prefix == "before" and not bool(world.call("production_environment_depth_ready")):
		_fail("accepted v1.65 world is not ready")
		return false
	world.set_active(false)

	var player_pos := Vector2(360.0, 700.0)
	var lower: Array = [
		{"type":"goblin", "pos":Vector2(245.0, 405.0), "radius":24.0, "phase":0.15, "attack_cd":1.3},
		{"type":"skeleton", "pos":Vector2(365.0, 355.0), "radius":25.0, "phase":0.45, "attack_cd":1.2},
		{"type":"necromancer", "pos":Vector2(490.0, 415.0), "radius":27.0, "phase":0.85, "attack_cd":1.1},
	]
	if not await _capture_realm(world, prefix, "lower_halls", 6, 40.0, player_pos, lower): return false

	var ossuary: Array = [
		{"type":"skeleton", "pos":Vector2(245.0, 405.0), "radius":25.0, "phase":0.25, "attack_cd":1.3},
		{"type":"ghoul", "pos":Vector2(365.0, 355.0), "radius":26.0, "phase":0.55, "attack_cd":1.2},
		{"type":"necromancer", "pos":Vector2(490.0, 415.0), "radius":27.0, "phase":0.95, "attack_cd":1.1},
	]
	if not await _capture_realm(world, prefix, "ossuary", 16, 41.0, player_pos, ossuary): return false

	var iron: Array = [
		{"type":"warden", "pos":Vector2(360.0, 335.0), "radius":32.0, "phase":0.8, "elite":true, "attack_cd":1.4, "cast_kind":"fan", "phase2":false},
		{"type":"skeleton", "pos":Vector2(245.0, 430.0), "radius":25.0, "phase":0.3, "attack_cd":1.3},
	]
	if not await _capture_realm(world, prefix, "iron_warden", 30, 42.0, player_pos, iron): return false

	var rift: Array = [
		{"type":"bat", "pos":Vector2(245.0, 405.0), "radius":23.0, "phase":0.2, "attack_cd":1.25},
		{"type":"ghoul", "pos":Vector2(365.0, 350.0), "radius":26.0, "phase":0.6, "attack_cd":1.15},
		{"type":"necromancer", "pos":Vector2(490.0, 420.0), "radius":27.0, "phase":1.0, "attack_cd":1.1},
	]
	if not await _capture_realm(world, prefix, "rift_descent", 36, 43.0, player_pos, rift): return false

	var spire: Array = [
		{"type":"skeleton", "pos":Vector2(250.0, 410.0), "radius":25.0, "phase":0.3, "attack_cd":1.25},
		{"type":"bat", "pos":Vector2(365.0, 350.0), "radius":23.0, "phase":0.7, "attack_cd":1.1},
		{"type":"necromancer", "pos":Vector2(485.0, 420.0), "radius":27.0, "phase":1.1, "attack_cd":1.0},
	]
	if not await _capture_realm(world, prefix, "starless_spire", 46, 44.0, player_pos, spire): return false

	capture_viewport.remove_child(world)
	world.queue_free()
	await process_frame
	await process_frame
	return true

func _capture_realm(world, prefix: String, stem: String, floor_no: int, time_value: float, player_pos: Vector2, enemies: Array) -> bool:
	world.previous_enemy_positions.clear()
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, time_value, 0.0, 0.0, floor_no)
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, time_value + 0.06, 0.0, 0.0, floor_no)
	_clear_transients(world)
	for _i in range(3):
		await process_frame
	return await _save_frame("%s_%s" % [prefix, stem])

func _clear_transients(world) -> void:
	world.transition_timer = 0.0
	if world.transition_root != null:
		world.transition_root.visible = false
	_hide_pool(world.spawn_signature_pool)
	_hide_pool(world.death_signature_pool)
	_hide_pool(world.authority_impact_pool)
	_hide_pool(world.death_burst_pool)
	_hide_pool(world.player_trail_pool)
	_hide_pool(world.enemy_trail_pool)

func _hide_pool(pool: Array) -> void:
	for value in pool:
		var node := value as Node3D
		if node != null:
			node.visible = false

func _save_frame(stem: String) -> bool:
	await RenderingServer.frame_post_draw
	var image := capture_viewport.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty v1.66 image: %s" % stem)
		return false
	if image.get_width() != CAPTURE_SIZE.x or image.get_height() != CAPTURE_SIZE.y:
		_fail("invalid capture size for %s: %dx%d" % [stem, image.get_width(), image.get_height()])
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save v1.66 image: %s" % stem)
		return false
	print("V166_CHARACTER_FORM_R1:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V166_CHARACTER_FORM_R1_CAPTURE_FAIL:%s" % message)
	quit(1)
