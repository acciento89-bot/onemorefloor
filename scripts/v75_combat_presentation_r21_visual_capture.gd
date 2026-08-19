extends SceneTree

const WorldR21 = preload("res://scripts/world3d_chamber_v161_combat_presentation_r21.gd")
const CAPTURE_DIR := "res://artifacts/v161_combat_presentation"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var world = WorldR21.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if not bool(world.call("production_combat_presentation_ready")):
		_fail("r2.1 combat presentation is not ready before capture")
		return

	# Freeze time-driven decay while keeping direct sync_runtime presentation updates.
	world.set_active(false)

	var enemies := [
		{"type":"goblin", "pos":Vector2(255.0, 445.0), "radius":23.0, "phase":0.2, "attack_cd":0.09},
		{"type":"skeleton", "pos":Vector2(465.0, 445.0), "radius":25.0, "phase":0.8, "attack_cd":0.12},
		{"type":"warden", "pos":Vector2(360.0, 345.0), "radius":31.0, "phase":1.1, "slam_cd":0.08},
	]
	var player_pos := Vector2(360.0, 665.0)

	_hide_pool(world.move_echo_pool)
	_set_player_peak_state(world, 1.0, 0.0)
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 3.0, 1.0, 0.0, 1)
	_clear_transition_for_capture(world)
	_hide_pool(world.move_echo_pool)
	if not await _save_frame("attack_blade_trail"):
		return

	_set_player_peak_state(world, 0.0, 1.0)
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 3.15, 0.0, 1.0, 1)
	_clear_transition_for_capture(world)
	_hide_pool(world.move_echo_pool)
	if not await _save_frame("skill_arcane_wave"):
		return

	_set_player_peak_state(world, 0.0, 0.0)
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 3.30, 0.0, 0.0, 1)
	_clear_transition_for_capture(world)
	_hide_pool(world.move_echo_pool)
	if not await _save_frame("enemy_segmented_tells"):
		return

	# Real motion-echo path: move the Wanderer repeatedly with a non-zero joy vector.
	_hide_combat_clutter(world, false)
	_hide_pool(world.move_echo_pool)
	world.last_player_echo_position = Vector3(9999.0, 9999.0, 9999.0)
	var movement_positions := [Vector2(285.0, 675.0), Vector2(335.0, 655.0), Vector2(385.0, 635.0), Vector2(435.0, 615.0)]
	for index in range(movement_positions.size()):
		var pos: Vector2 = movement_positions[index]
		world.sync_runtime(pos, [], [], [], [], Vector2(1.0, -0.35), 3.40 + float(index) * 0.03, 0.0, 0.0, 1)
		_clear_transition_for_capture(world)
	if not await _save_frame("movement_streaks"):
		return

	# Isolate impact geometry. Motion echoes are explicitly hidden so any large
	# violet ring here would prove another legacy source still exists.
	_set_player_peak_state(world, 0.0, 0.0)
	world.sync_runtime(player_pos, [], [], [], [], Vector2.ZERO, 3.60, 0.0, 0.0, 1)
	_clear_transition_for_capture(world)
	_hide_combat_clutter(world, true)
	world.call("_spawn_impact", Vector3(-1.15, 0.0, -0.65), true)
	world.call("_spawn_combat_authority_impact", Vector3(0.0, 0.0, -0.95), world.player_hit_material, true)
	world.call("_spawn_combat_authority_impact", Vector3(1.15, 0.0, -0.65), world.enemy_hit_material, false)
	if not await _save_frame("impact_bursts"):
		return

	_set_player_peak_state(world, 1.0, 0.0)
	world.sync_runtime(Vector2(360.0, 600.0), [], [], [], [], Vector2.ZERO, 4.0, 1.0, 0.0, 1)
	_clear_transition_for_capture(world)
	_hide_combat_clutter(world, true)
	world.camera.position = Vector3(0.0, 5.6, 5.9)
	world.camera.size = 6.2
	world.camera.look_at(Vector3(0.0, 0.55, 0.0), Vector3.UP)
	if not await _save_frame("player_blade_closeup"):
		return

	print("v1.61 combat presentation r2.1 visual capture passed")
	world.queue_free()
	await process_frame
	quit(0)

func _set_player_peak_state(world, attack_value: float, skill_value: float) -> void:
	world.attack_amount = attack_value
	world.skill_amount = skill_value

func _clear_transition_for_capture(world) -> void:
	world.transition_timer = 0.0
	if world.transition_root != null:
		world.transition_root.visible = false

func _hide_pool(pool: Array) -> void:
	for value in pool:
		var item := value as Node3D
		if item != null:
			item.visible = false

func _hide_combat_clutter(world, include_impacts: bool) -> void:
	_hide_pool(world.spawn_signature_pool)
	_hide_pool(world.death_signature_pool)
	_hide_pool(world.enemy_vfx_slots)
	_hide_pool(world.telegraph_pool)
	_hide_pool(world.target_lock_pool)
	_hide_pool(world.enemy_grounding_pool)
	_hide_pool(world.move_echo_pool)
	_hide_pool(world.hit_burst_pool)
	if world.nova_volume_visual != null:
		world.nova_volume_visual.visible = false
	if world.warden_ring_visual != null:
		world.warden_ring_visual.visible = false
	_hide_pool(world.warden_lane_visuals)
	if world.boss_dominance_root != null:
		world.boss_dominance_root.visible = false
	if include_impacts:
		_hide_pool(world.impact_pool)
		_hide_pool(world.authority_impact_pool)
		_hide_pool(world.combat_authority_impact_pool)

func _save_frame(stem: String) -> bool:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty v1.61 r2.1 capture for %s" % stem)
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save v1.61 r2.1 capture %s" % stem)
		return false
	print("V75_R21_COMBAT_CAPTURE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V75_R21_COMBAT_CAPTURE_FAIL:%s" % message)
	quit(1)
