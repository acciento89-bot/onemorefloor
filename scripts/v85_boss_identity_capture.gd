extends SceneTree

const WorldR2 = preload("res://scripts/world3d_chamber_v163_boss_identity.gd")
const CAPTURE_DIR := "res://artifacts/v163_boss_identity"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var world = WorldR2.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if not bool(world.call("production_boss_identity_ready")):
		_fail("v1.63 r2 boss identity world not ready")
		return
	world.set_active(false)

	var player_pos := Vector2(360.0, 700.0)
	var boss_pos := Vector2(360.0, 330.0)

	var intro_boss := _warden(boss_pos, "ring", 0.90, false)
	world.sync_runtime(player_pos, [intro_boss], [], [], [], Vector2.ZERO, 24.0, 0.0, 0.0, 10)
	_clear_non_boss_transients(world)
	world.boss_intro_timer = 1.08
	world.call("_animate_boss_frame")
	if not await _save_frame("r2_boss_intro"):
		return

	var fan_boss := _warden(boss_pos, "fan", 0.18, false)
	var fan0: Array = [
		{"pos":boss_pos + Vector2(-34.0, 52.0), "color":Color("ff657d")},
		{"pos":boss_pos + Vector2(0.0, 58.0), "color":Color("ff657d")},
		{"pos":boss_pos + Vector2(34.0, 52.0), "color":Color("ff657d")},
	]
	var fan1: Array = [
		{"pos":Vector2(305.0, 470.0), "color":Color("ff657d")},
		{"pos":Vector2(360.0, 490.0), "color":Color("ff657d")},
		{"pos":Vector2(415.0, 470.0), "color":Color("ff657d")},
	]
	_reset_projectile_history(world)
	world.sync_runtime(player_pos, [fan_boss], [], fan0, [], Vector2.ZERO, 24.20, 0.0, 0.0, 10)
	world.sync_runtime(player_pos, [fan_boss], [], fan1, [], Vector2.ZERO, 24.26, 0.0, 0.0, 10)
	_clear_non_boss_transients(world)
	world.boss_intro_timer = 0.0
	world.call("_animate_boss_frame")
	if not await _save_frame("r2_boss_fan"):
		return

	var crown_boss := _warden(boss_pos, "crown", 0.18, true)
	_reset_projectile_history(world)
	world.sync_runtime(player_pos, [crown_boss], [], [], [], Vector2.ZERO, 24.52, 0.0, 0.0, 10)
	_clear_non_boss_transients(world)
	world.boss_intro_timer = 0.0
	world.call("_animate_boss_frame")
	if not await _save_frame("r2_boss_crown_slam"):
		return

	print("v1.63 boss identity r2 visual capture passed")
	world.queue_free()
	await process_frame
	quit(0)

func _warden(pos: Vector2, cast_kind: String, attack_cd: float, phase2: bool) -> Dictionary:
	return {
		"type":"warden",
		"pos":pos,
		"radius":32.0,
		"phase":0.8,
		"elite":true,
		"attack_cd":attack_cd,
		"cast_kind":cast_kind,
		"phase2":phase2,
	}

func _clear_non_boss_transients(world) -> void:
	world.transition_timer = 0.0
	if world.transition_root != null:
		world.transition_root.visible = false
	_hide_pool(world.spawn_signature_pool)
	_hide_pool(world.death_signature_pool)
	_hide_pool(world.death_burst_pool)
	_hide_pool(world.loot_marker_pool)

func _reset_projectile_history(world) -> void:
	for i in range(world.player_prev_valid.size()):
		world.player_prev_valid[i] = false
	for i in range(world.enemy_prev_valid.size()):
		world.enemy_prev_valid[i] = false
	_hide_pool(world.player_trail_pool)
	_hide_pool(world.enemy_trail_pool)

func _hide_pool(pool: Array) -> void:
	for value in pool:
		var node := value as Node3D
		if node != null:
			node.visible = false

func _save_frame(stem: String) -> bool:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty boss r2 image: %s" % stem)
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save boss r2 image: %s" % stem)
		return false
	print("V163_BOSS_R2_CAPTURE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V163_BOSS_R2_CAPTURE_FAIL:%s" % message)
	quit(1)
