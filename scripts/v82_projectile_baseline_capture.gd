extends SceneTree

const WorldR32 = preload("res://scripts/world3d_chamber_v161_combat_presentation_r32.gd")
const CAPTURE_DIR := "res://artifacts/v163_projectile_baseline"

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
		_fail("r3.2 world not ready before v1.63 projectile baseline")
		return
	world.set_active(false)

	var player_pos := Vector2(360.0, 665.0)
	var enemies: Array = [
		{"type":"skeleton", "pos":Vector2(245.0, 405.0), "radius":25.0, "phase":0.3, "attack_cd":1.0},
		{"type":"necromancer", "pos":Vector2(480.0, 385.0), "radius":27.0, "phase":1.1, "attack_cd":1.0},
		{"type":"warden", "pos":Vector2(360.0, 285.0), "radius":31.0, "phase":0.8, "attack_cd":1.0, "elite":true},
	]
	_prepare_steady_state(world, enemies)

	# Player volley: two normal bolts plus one critical bolt. Two sync samples are
	# intentional so the inherited v1.41 history produces its real BoxMesh trails.
	var p0: Array = [
		{"pos":Vector2(300.0, 625.0), "crit":false},
		{"pos":Vector2(370.0, 610.0), "crit":true},
		{"pos":Vector2(430.0, 625.0), "crit":false},
	]
	var p1: Array = [
		{"pos":Vector2(275.0, 555.0), "crit":false},
		{"pos":Vector2(365.0, 525.0), "crit":true},
		{"pos":Vector2(450.0, 550.0), "crit":false},
	]
	world.sync_runtime(player_pos, enemies, p0, [], [], Vector2.ZERO, 18.00, 0.0, 0.0, 18)
	world.sync_runtime(player_pos, enemies, p1, [], [], Vector2.ZERO, 18.06, 0.0, 0.0, 18)
	_clear_transients(world)
	if not await _save_frame("baseline_player_projectiles"):
		return

	# Enemy volley: keep the current runtime color semantics but expose the same
	# generic SphereMesh + rectangular trail language from hostile fire.
	_reset_projectile_history(world)
	var e0: Array = [
		{"pos":Vector2(250.0, 420.0), "color":Color("62e6ff")},
		{"pos":Vector2(470.0, 400.0), "color":Color("a568ff")},
		{"pos":Vector2(360.0, 310.0), "color":Color("ff657d")},
	]
	var e1: Array = [
		{"pos":Vector2(285.0, 485.0), "color":Color("62e6ff")},
		{"pos":Vector2(440.0, 475.0), "color":Color("a568ff")},
		{"pos":Vector2(360.0, 405.0), "color":Color("ff657d")},
	]
	world.sync_runtime(player_pos, enemies, [], e0, [], Vector2.ZERO, 18.20, 0.0, 0.0, 18)
	world.sync_runtime(player_pos, enemies, [], e1, [], Vector2.ZERO, 18.26, 0.0, 0.0, 18)
	_clear_transients(world)
	if not await _save_frame("baseline_enemy_projectiles"):
		return

	# Mixed pressure is the decisive gameplay-distance baseline: friendly gold
	# balls/bars and hostile colored balls/bars share the authored 3D chamber.
	_reset_projectile_history(world)
	var mp0: Array = [
		{"pos":Vector2(315.0, 620.0), "crit":false},
		{"pos":Vector2(405.0, 620.0), "crit":true},
	]
	var mp1: Array = [
		{"pos":Vector2(300.0, 535.0), "crit":false},
		{"pos":Vector2(420.0, 525.0), "crit":true},
	]
	var me0: Array = [
		{"pos":Vector2(245.0, 410.0), "color":Color("62e6ff")},
		{"pos":Vector2(480.0, 395.0), "color":Color("a568ff")},
		{"pos":Vector2(360.0, 305.0), "color":Color("ff657d")},
	]
	var me1: Array = [
		{"pos":Vector2(280.0, 485.0), "color":Color("62e6ff")},
		{"pos":Vector2(445.0, 470.0), "color":Color("a568ff")},
		{"pos":Vector2(360.0, 400.0), "color":Color("ff657d")},
	]
	world.sync_runtime(player_pos, enemies, mp0, me0, [], Vector2.ZERO, 18.40, 0.0, 0.0, 18)
	world.sync_runtime(player_pos, enemies, mp1, me1, [], Vector2.ZERO, 18.46, 0.0, 0.0, 18)
	_clear_transients(world)
	if not await _save_frame("baseline_mixed_projectiles"):
		return

	print("v1.63 projectile gameplay baseline capture passed")
	world.queue_free()
	await process_frame
	quit(0)

func _prepare_steady_state(world, enemies: Array) -> void:
	world.call("_capture_signature_state", enemies)
	world.previous_enemy_positions.clear()
	_hide_pool(world.spawn_signature_pool)
	_hide_pool(world.death_signature_pool)

func _reset_projectile_history(world) -> void:
	for i in range(world.player_prev_valid.size()):
		world.player_prev_valid[i] = false
	for i in range(world.enemy_prev_valid.size()):
		world.enemy_prev_valid[i] = false
	_hide_pool(world.player_trail_pool)
	_hide_pool(world.enemy_trail_pool)

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
		_fail("empty projectile baseline capture for %s" % stem)
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save projectile baseline %s" % stem)
		return false
	print("V163_PROJECTILE_BASELINE_CAPTURE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V163_PROJECTILE_BASELINE_CAPTURE_FAIL:%s" % message)
	quit(1)
