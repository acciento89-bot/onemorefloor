extends SceneTree

const WorldR32 = preload("res://scripts/world3d_chamber_v161_combat_presentation_r32.gd")
const CAPTURE_DIR := "res://artifacts/v161_combat_presentation"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var world = WorldR32.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if not bool(world.call("production_combat_presentation_ready")):
		_fail("r3.2 combat presentation is not ready before capture")
		return
	world.set_active(false)

	var player_pos := Vector2(360.0, 665.0)

	# Focused attack tells: arcs and aim spears should point toward the Wanderer
	# instead of rotating as universal circles.
	var focus_enemies: Array = [
		{"type":"goblin", "pos":Vector2(235.0, 490.0), "radius":23.0, "phase":0.2, "attack_cd":0.08},
		{"type":"skeleton", "pos":Vector2(485.0, 475.0), "radius":25.0, "phase":0.8, "attack_cd":0.12},
		{"type":"necromancer", "pos":Vector2(285.0, 345.0), "radius":27.0, "phase":1.3, "attack_cd":0.06},
		{"type":"warden", "pos":Vector2(455.0, 330.0), "radius":31.0, "phase":1.1, "attack_cd":0.10, "elite":true},
	]
	_prepare_steady_state(world, focus_enemies)
	world.sync_runtime(player_pos, focus_enemies, [], [], [], Vector2(0.12, -0.38), 12.0, 1.0, 0.0, 17)
	_clear_transients(world)
	if not await _save_frame("r32_focus_pressure"):
		return

	# Mobility and phase language. Authored actor silhouettes stay unchanged; the
	# cooldown keys are isolated here so the warning silhouettes can be compared.
	var mobility_enemies: Array = [
		{"type":"ghoul", "pos":Vector2(235.0, 475.0), "radius":24.0, "phase":0.3, "lunge_cd":0.07},
		{"type":"bat", "pos":Vector2(485.0, 465.0), "radius":22.0, "phase":0.9, "dive_cd":0.11},
		{"type":"necromancer", "pos":Vector2(300.0, 335.0), "radius":27.0, "phase":1.4, "attack_cd":1.0, "blink_cd":0.09},
		{"type":"goblin", "pos":Vector2(445.0, 320.0), "radius":23.0, "phase":1.0, "dash_cd":0.13},
	]
	_prepare_steady_state(world, mobility_enemies)
	world.sync_runtime(player_pos, mobility_enemies, [], [], [], Vector2.ZERO, 12.2, 0.0, 0.0, 17)
	_clear_transients(world)
	if not await _save_frame("r32_mobility_phase"):
		return

	# Radial slam versus ritual cast: both retain the same inherited radius scale,
	# but now have distinct perimeter teeth / inward ritual markers.
	var cast_enemies: Array = [
		{"type":"warden", "pos":Vector2(275.0, 410.0), "radius":31.0, "phase":0.4, "slam_cd":0.08, "elite":true},
		{"type":"necromancer", "pos":Vector2(445.0, 395.0), "radius":27.0, "phase":1.2, "attack_cd":1.0, "summon_cd":0.10},
		{"type":"skeleton", "pos":Vector2(360.0, 295.0), "radius":25.0, "phase":0.7, "attack_cd":0.14},
	]
	_prepare_steady_state(world, cast_enemies)
	world.sync_runtime(player_pos, cast_enemies, [], [], [], Vector2.ZERO, 12.4, 0.0, 0.0, 17)
	_clear_transients(world)
	if not await _save_frame("r32_slam_ritual"):
		return

	print("v1.61 combat presentation r3.2 visual capture passed")
	world.queue_free()
	await process_frame
	quit(0)

func _prepare_steady_state(world, enemies: Array) -> void:
	world.call("_capture_signature_state", enemies)
	world.previous_enemy_positions.clear()
	_hide_pool(world.spawn_signature_pool)
	_hide_pool(world.death_signature_pool)

func _clear_transients(world) -> void:
	_hide_pool(world.spawn_signature_pool)
	_hide_pool(world.death_signature_pool)
	world.transition_timer = 0.0
	if world.transition_root != null:
		world.transition_root.visible = false

func _hide_pool(pool: Array) -> void:
	for value in pool:
		var item := value as Node3D
		if item != null:
			item.visible = false

func _save_frame(stem: String) -> bool:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty r3.2 capture for %s" % stem)
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save r3.2 capture %s" % stem)
		return false
	print("V75_R32_COMBAT_CAPTURE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V75_R32_COMBAT_CAPTURE_FAIL:%s" % message)
	quit(1)
