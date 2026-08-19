extends SceneTree

const WorldR22 = preload("res://scripts/world3d_chamber_v161_combat_presentation_r22.gd")
const CAPTURE_DIR := "res://artifacts/v161_combat_presentation"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var world = WorldR22.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if not bool(world.call("production_combat_presentation_ready")):
		_fail("r2.2 combat presentation is not ready before capture")
		return
	world.set_active(false)

	var enemies := [
		{"type":"goblin", "pos":Vector2(255.0, 445.0), "radius":23.0, "phase":0.2},
		{"type":"skeleton", "pos":Vector2(465.0, 445.0), "radius":25.0, "phase":0.8},
		{"type":"warden", "pos":Vector2(360.0, 345.0), "radius":31.0, "phase":1.1},
	]
	var player_pos := Vector2(360.0, 665.0)

	# Real inherited death-detection path: three enemies disappear between frames.
	world.previous_enemy_positions = []
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 5.0, 0.0, 0.0, 1)
	_clear_transition(world)
	world.sync_runtime(player_pos, [], [], [], [], Vector2.ZERO, 5.05, 0.0, 0.0, 1)
	_clear_transition(world)
	_hide_all_except_death(world)
	if not await _save_frame("death_bursts"):
		return

	# Isolated motion-streak capture with all death/signature feedback hidden.
	_hide_everything(world)
	world.last_player_echo_position = Vector3(9999.0, 9999.0, 9999.0)
	var movement_positions := [Vector2(300.0, 675.0), Vector2(350.0, 655.0), Vector2(400.0, 635.0), Vector2(450.0, 615.0)]
	for index in range(movement_positions.size()):
		world.sync_runtime(movement_positions[index], [], [], [], [], Vector2(1.0, -0.35), 5.20 + float(index) * 0.03, 0.0, 0.0, 1)
		_clear_transition(world)
		_hide_pool(world.death_burst_pool)
		_hide_pool(world.spawn_signature_pool)
		_hide_pool(world.death_signature_pool)
		_hide_pool(world.authority_impact_pool)
	if not await _save_frame("movement_streaks"):
		return

	# Isolated r2 impact bursts. Any large circular glyph here is a regression.
	world.sync_runtime(player_pos, [], [], [], [], Vector2.ZERO, 5.50, 0.0, 0.0, 1)
	_clear_transition(world)
	_hide_everything(world)
	world.call("_spawn_impact", Vector3(-1.15, 0.0, -0.65), true)
	world.call("_spawn_combat_authority_impact", Vector3(0.0, 0.0, -0.95), world.player_hit_material, true)
	world.call("_spawn_combat_authority_impact", Vector3(1.15, 0.0, -0.65), world.enemy_hit_material, false)
	if not await _save_frame("impact_bursts"):
		return

	print("v1.61 combat presentation r2.2 visual capture passed")
	world.queue_free()
	await process_frame
	quit(0)

func _clear_transition(world) -> void:
	world.transition_timer = 0.0
	if world.transition_root != null:
		world.transition_root.visible = false

func _hide_pool(pool: Array) -> void:
	for value in pool:
		var item := value as Node3D
		if item != null:
			item.visible = false

func _hide_all_except_death(world) -> void:
	_hide_pool(world.spawn_signature_pool)
	_hide_pool(world.death_signature_pool)
	_hide_pool(world.enemy_vfx_slots)
	_hide_pool(world.telegraph_pool)
	_hide_pool(world.target_lock_pool)
	_hide_pool(world.enemy_grounding_pool)
	_hide_pool(world.move_echo_pool)
	_hide_pool(world.hit_burst_pool)
	_hide_pool(world.impact_pool)
	_hide_pool(world.authority_impact_pool)
	_hide_pool(world.combat_authority_impact_pool)
	_hide_pool(world.loot_marker_pool)
	if world.boss_dominance_root != null:
		world.boss_dominance_root.visible = false
	if world.boss_root != null:
		world.boss_root.visible = false
	if world.nova_volume_visual != null:
		world.nova_volume_visual.visible = false
	if world.warden_ring_visual != null:
		world.warden_ring_visual.visible = false
	_hide_pool(world.warden_lane_visuals)

func _hide_everything(world) -> void:
	_hide_all_except_death(world)
	_hide_pool(world.death_burst_pool)

func _save_frame(stem: String) -> bool:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty v1.61 r2.2 capture for %s" % stem)
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save v1.61 r2.2 capture %s" % stem)
		return false
	print("V75_R22_COMBAT_CAPTURE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V75_R22_COMBAT_CAPTURE_FAIL:%s" % message)
	quit(1)
