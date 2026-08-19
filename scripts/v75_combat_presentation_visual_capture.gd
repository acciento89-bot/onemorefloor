extends SceneTree

const WorldV161 = preload("res://scripts/world3d_chamber_v161_combat_presentation.gd")
const CAPTURE_DIR := "res://artifacts/v161_combat_presentation"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var world = WorldV161.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if not bool(world.call("production_combat_presentation_ready")):
		_fail("combat presentation layer is not ready before capture")
		return

	world.set_active(false)

	var enemies := [
		{"type":"goblin", "pos":Vector2(255.0, 445.0), "radius":23.0, "phase":0.2, "attack_cd":0.09},
		{"type":"skeleton", "pos":Vector2(465.0, 445.0), "radius":25.0, "phase":0.8, "attack_cd":0.12},
		{"type":"warden", "pos":Vector2(360.0, 345.0), "radius":31.0, "phase":1.1, "slam_cd":0.08},
	]
	var player_pos := Vector2(360.0, 665.0)

	_set_player_peak_state(world, 1.0, 0.0)
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 3.0, 1.0, 0.0, 1)
	_clear_transition_for_capture(world)
	if not await _save_frame("attack_blade_trail"):
		return

	_set_player_peak_state(world, 0.0, 1.0)
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 3.15, 0.0, 1.0, 1)
	_clear_transition_for_capture(world)
	if not await _save_frame("skill_arcane_wave"):
		return

	_set_player_peak_state(world, 0.0, 0.0)
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 3.30, 0.0, 0.0, 1)
	_clear_transition_for_capture(world)
	if not await _save_frame("enemy_segmented_tells"):
		return

	_set_player_peak_state(world, 0.0, 0.0)
	world.sync_runtime(player_pos, [], [], [], [], Vector2.ZERO, 3.45, 0.0, 0.0, 1)
	_clear_transition_for_capture(world)
	_hide_signature_pool_for_capture(world.spawn_signature_pool)
	_hide_signature_pool_for_capture(world.death_signature_pool)
	_hide_signature_pool_for_capture(world.enemy_vfx_slots)
	_hide_signature_pool_for_capture(world.telegraph_pool)
	_hide_signature_pool_for_capture(world.target_lock_pool)
	_hide_signature_pool_for_capture(world.enemy_grounding_pool)
	world.call("_spawn_impact", Vector3(-1.15, 0.0, -0.65), true)
	world.call("_spawn_combat_authority_impact", Vector3(0.0, 0.0, -0.95), world.player_hit_material, true)
	world.call("_spawn_combat_authority_impact", Vector3(1.15, 0.0, -0.65), world.enemy_hit_material, false)
	if not await _save_frame("impact_bursts"):
		return

	_set_player_peak_state(world, 1.0, 0.0)
	world.sync_runtime(Vector2(360.0, 600.0), [], [], [], [], Vector2.ZERO, 4.0, 1.0, 0.0, 1)
	_clear_transition_for_capture(world)
	_hide_signature_pool_for_capture(world.spawn_signature_pool)
	_hide_signature_pool_for_capture(world.death_signature_pool)
	_hide_signature_pool_for_capture(world.enemy_vfx_slots)
	_hide_signature_pool_for_capture(world.telegraph_pool)
	_hide_signature_pool_for_capture(world.target_lock_pool)
	_hide_signature_pool_for_capture(world.enemy_grounding_pool)
	_hide_signature_pool_for_capture(world.impact_pool)
	_hide_signature_pool_for_capture(world.authority_impact_pool)
	_hide_signature_pool_for_capture(world.combat_authority_impact_pool)
	world.camera.position = Vector3(0.0, 5.6, 5.9)
	world.camera.size = 6.2
	world.camera.look_at(Vector3(0.0, 0.55, 0.0), Vector3.UP)
	if not await _save_frame("player_blade_closeup"):
		return

	print("v1.61 combat presentation visual capture passed")
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

func _hide_signature_pool_for_capture(pool: Array) -> void:
	for value in pool:
		var item := value as Node3D
		if item != null:
			item.visible = false

func _save_frame(stem: String) -> bool:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty v1.61 capture for %s" % stem)
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save v1.61 capture %s" % stem)
		return false
	print("V75_COMBAT_CAPTURE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V75_COMBAT_CAPTURE_FAIL:%s" % message)
	quit(1)
