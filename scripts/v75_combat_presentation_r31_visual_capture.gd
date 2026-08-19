extends SceneTree

const WorldR31 = preload("res://scripts/world3d_chamber_v161_combat_presentation_r31.gd")
const CAPTURE_DIR := "res://artifacts/v161_combat_presentation"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var world = WorldR31.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if not bool(world.call("production_combat_presentation_ready")):
		_fail("r3.1 combat presentation is not ready before capture")
		return
	world.set_active(false)

	var player_pos := Vector2(360.0, 665.0)
	var enemies: Array = [
		{"type":"goblin", "pos":Vector2(252.0, 505.0), "radius":23.0, "phase":0.2, "attack_cd":0.08},
		{"type":"skeleton", "pos":Vector2(468.0, 485.0), "radius":25.0, "phase":0.8, "attack_cd":0.16},
		{"type":"necromancer", "pos":Vector2(285.0, 370.0), "radius":27.0, "phase":1.3, "attack_cd":0.05},
		{"type":"warden", "pos":Vector2(438.0, 350.0), "radius":31.0, "phase":1.1, "attack_cd":0.11, "elite":true},
	]

	# Deliberately capture the true spawn moment so r3.1 signature language is
	# reviewed rather than accidentally treating it as steady-state grounding.
	world.previous_enemy_signatures = []
	world.previous_enemy_positions = []
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 10.0, 0.0, 0.0, 7)
	_clear_transition(world)
	if not await _save_frame("r31_spawn_signatures"):
		return

	# Steady combat: clear only transient spawn/death signatures, keeping enemy
	# grounding and danger telegraphs visible. This separates the two languages.
	_hide_pool(world.spawn_signature_pool)
	_hide_pool(world.death_signature_pool)
	world.call("_capture_signature_state", enemies)
	world.previous_enemy_positions.clear()
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2(0.18, -0.55), 10.2, 1.0, 0.0, 7)
	_clear_transition(world)
	world.call("_spawn_impact", world.design_to_world(Vector2(300.0, 495.0)), true)
	if not await _save_frame("r31_steady_attack_pressure"):
		return

	# Kill + loot keeps the real death signature active and the r3 loot glints
	# visible together, which is the previously cluttered moment we need to judge.
	_hide_pool(world.spawn_signature_pool)
	_hide_pool(world.death_signature_pool)
	world.call("_capture_signature_state", enemies)
	world.previous_enemy_positions.clear()
	var survivors: Array = [enemies[1], enemies[2], enemies[3]]
	var coins: Array = [
		{"pos":Vector2(255.0, 505.0), "value":1},
		{"pos":Vector2(302.0, 525.0), "value":8},
	]
	world.sync_runtime(player_pos, survivors, [], [], coins, Vector2(0.10, -0.20), 10.38, 0.0, 0.0, 7)
	_clear_transition(world)
	if not await _save_frame("r31_kill_loot_signatures"):
		return

	print("v1.61 combat presentation r3.1 visual capture passed")
	world.queue_free()
	await process_frame
	quit(0)

func _hide_pool(pool: Array) -> void:
	for value in pool:
		var item := value as Node3D
		if item != null:
			item.visible = false

func _clear_transition(world) -> void:
	world.transition_timer = 0.0
	if world.transition_root != null:
		world.transition_root.visible = false

func _save_frame(stem: String) -> bool:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty r3.1 capture for %s" % stem)
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save r3.1 capture %s" % stem)
		return false
	print("V75_R31_COMBAT_CAPTURE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V75_R31_COMBAT_CAPTURE_FAIL:%s" % message)
	quit(1)
