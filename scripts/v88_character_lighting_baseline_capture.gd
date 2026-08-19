extends SceneTree

const AcceptedWorld = preload("res://scripts/world3d_chamber_v163_boss_dominance.gd")
const CAPTURE_DIR := "res://artifacts/v164_character_lighting_baseline"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var world = AcceptedWorld.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if not bool(world.call("production_boss_dominance_ready")):
		_fail("accepted v1.63 r2.1 world is not ready")
		return
	world.set_active(false)

	var player_pos := Vector2(360.0, 700.0)

	# Neutral Lower Halls gameplay-distance frame. No transient combat flash is
	# allowed to hide the current Wanderer cloth/steel midtone problem.
	var lower_enemies: Array = [
		{"type":"goblin", "pos":Vector2(245.0, 405.0), "radius":24.0, "phase":0.15, "attack_cd":1.3},
		{"type":"skeleton", "pos":Vector2(365.0, 355.0), "radius":25.0, "phase":0.45, "attack_cd":1.2},
		{"type":"necromancer", "pos":Vector2(490.0, 415.0), "radius":27.0, "phase":0.85, "attack_cd":1.1},
	]
	_prepare_steady_state(world, lower_enemies)
	world.sync_runtime(player_pos, lower_enemies, [], [], [], Vector2.ZERO, 40.0, 0.0, 0.0, 6)
	world.sync_runtime(player_pos, lower_enemies, [], [], [], Vector2.ZERO, 40.06, 0.0, 0.0, 6)
	_clear_transients(world)
	if not await _save_frame("baseline_lower_halls_mobs"):
		return

	# Cool Ossuary frame tests dark cloth/steel against pale bone and teal realm
	# response without changing camera, geometry, actor scale or animation pivots.
	var ossuary_enemies: Array = [
		{"type":"skeleton", "pos":Vector2(245.0, 405.0), "radius":25.0, "phase":0.25, "attack_cd":1.3},
		{"type":"ghoul", "pos":Vector2(365.0, 355.0), "radius":26.0, "phase":0.55, "attack_cd":1.2},
		{"type":"necromancer", "pos":Vector2(490.0, 415.0), "radius":27.0, "phase":0.95, "attack_cd":1.1},
	]
	_prepare_steady_state(world, ossuary_enemies)
	world.sync_runtime(player_pos, ossuary_enemies, [], [], [], Vector2.ZERO, 41.0, 0.0, 0.0, 16)
	world.sync_runtime(player_pos, ossuary_enemies, [], [], [], Vector2.ZERO, 41.06, 0.0, 0.0, 16)
	_clear_transients(world)
	if not await _save_frame("baseline_ossuary_mobs"):
		return

	# Warm Iron Bastion boss frame keeps the accepted r2.1 dominance layer visible
	# while judging Wanderer vs Warden readability under the warmest realm grade.
	var boss_enemies: Array = [
		{"type":"warden", "pos":Vector2(360.0, 335.0), "radius":32.0, "phase":0.8, "elite":true, "attack_cd":1.4, "cast_kind":"fan", "phase2":false},
		{"type":"skeleton", "pos":Vector2(245.0, 430.0), "radius":25.0, "phase":0.3, "attack_cd":1.3},
	]
	_prepare_steady_state(world, boss_enemies)
	world.sync_runtime(player_pos, boss_enemies, [], [], [], Vector2.ZERO, 42.0, 0.0, 0.0, 30)
	world.sync_runtime(player_pos, boss_enemies, [], [], [], Vector2.ZERO, 42.06, 0.0, 0.0, 30)
	_clear_transition_and_signatures(world)
	if not await _save_frame("baseline_iron_warden"):
		return

	print("v1.64 character lighting baseline visual capture passed")
	world.queue_free()
	await process_frame
	quit(0)

func _prepare_steady_state(world, enemies: Array) -> void:
	world.call("_capture_signature_state", enemies)
	world.previous_enemy_positions.clear()
	_hide_pool(world.spawn_signature_pool)
	_hide_pool(world.death_signature_pool)
	_hide_pool(world.player_trail_pool)
	_hide_pool(world.enemy_trail_pool)

func _clear_transients(world) -> void:
	_clear_transition_and_signatures(world)
	_hide_pool(world.authority_impact_pool)
	_hide_pool(world.death_burst_pool)
	_hide_pool(world.player_trail_pool)
	_hide_pool(world.enemy_trail_pool)

func _clear_transition_and_signatures(world) -> void:
	world.transition_timer = 0.0
	if world.transition_root != null:
		world.transition_root.visible = false
	_hide_pool(world.spawn_signature_pool)
	_hide_pool(world.death_signature_pool)

func _hide_pool(pool: Array) -> void:
	for value in pool:
		var node := value as Node3D
		if node != null:
			node.visible = false

func _save_frame(stem: String) -> bool:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty lighting baseline image: %s" % stem)
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save lighting baseline image: %s" % stem)
		return false
	print("V164_CHARACTER_LIGHTING_BASELINE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V164_CHARACTER_LIGHTING_BASELINE_CAPTURE_FAIL:%s" % message)
	quit(1)
