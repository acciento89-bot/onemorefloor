extends SceneTree

const WorldR21 = preload("res://scripts/world3d_chamber_v163_boss_dominance.gd")
const CAPTURE_DIR := "res://artifacts/v163_combined_review"

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
	if not bool(world.call("production_boss_dominance_ready")):
		_fail("r2.1 world not ready")
		return
	world.set_active(false)

	var player_pos := Vector2(360.0, 700.0)
	var boss_pos := Vector2(360.0, 330.0)

	# Boss fan exchange: accepted focus tell + r1 friendly/hostile projectile shapes
	# + one current authority impact. This is the densest directional-combat frame.
	var fan_enemies: Array = [
		_warden(boss_pos, "fan", 0.18, false),
		{"type":"skeleton", "pos":Vector2(245.0, 415.0), "radius":25.0, "phase":0.2, "attack_cd":1.2},
		{"type":"necromancer", "pos":Vector2(485.0, 405.0), "radius":27.0, "phase":0.9, "attack_cd":1.1},
	]
	_prepare_steady_state(world, fan_enemies)
	var fp0: Array = [
		{"pos":Vector2(325.0, 635.0), "crit":false},
		{"pos":Vector2(405.0, 625.0), "crit":true},
	]
	var fp1: Array = [
		{"pos":Vector2(315.0, 545.0), "crit":false},
		{"pos":Vector2(420.0, 535.0), "crit":true},
	]
	var fe0: Array = [
		{"pos":Vector2(325.0, 385.0), "color":Color("ff657d")},
		{"pos":Vector2(255.0, 430.0), "color":Color("62e6ff")},
		{"pos":Vector2(475.0, 420.0), "color":Color("a568ff")},
	]
	var fe1: Array = [
		{"pos":Vector2(340.0, 485.0), "color":Color("ff657d")},
		{"pos":Vector2(290.0, 505.0), "color":Color("62e6ff")},
		{"pos":Vector2(445.0, 500.0), "color":Color("a568ff")},
	]
	world.sync_runtime(player_pos, fan_enemies, fp0, fe0, [], Vector2.ZERO, 31.0, 0.0, 0.0, 10)
	world.sync_runtime(player_pos, fan_enemies, fp1, fe1, [], Vector2.ZERO, 31.06, 0.0, 0.0, 10)
	_clear_transition_and_signatures(world)
	world.call("_spawn_authority_impact", world.design_to_world(Vector2(390.0, 520.0)), world.authority_contact_material)
	if not await _save_frame("combined_fan_exchange"):
		return

	# Slam + loot/death pressure: the radial teeth must remain uniquely readable
	# while accepted death/loot feedback and friendly projectiles are present.
	_reset_projectile_history(world)
	var slam_enemies: Array = [_warden(boss_pos, "crown", 0.18, true)]
	var sp0: Array = [
		{"pos":Vector2(330.0, 635.0), "crit":false},
		{"pos":Vector2(395.0, 630.0), "crit":false},
	]
	var sp1: Array = [
		{"pos":Vector2(325.0, 545.0), "crit":false},
		{"pos":Vector2(405.0, 540.0), "crit":false},
	]
	var coins: Array = [{"pos":Vector2(495.0, 515.0), "value":28, "age":0.0}]
	world.sync_runtime(player_pos, slam_enemies, sp0, [], coins, Vector2.ZERO, 31.30, 0.0, 0.0, 10)
	world.sync_runtime(player_pos, slam_enemies, sp1, [], coins, Vector2.ZERO, 31.36, 0.0, 0.0, 10)
	_clear_transition_and_signatures(world)
	world.call("_spawn_death_burst", world.design_to_world(Vector2(495.0, 515.0)))
	if not await _save_frame("combined_slam_loot"):
		return

	# Non-boss mixed pressure: ensures the projectile pass still composes with
	# current spawn signatures and impacts outside the Warden presentation.
	_reset_projectile_history(world)
	var mobs: Array = [
		{"type":"goblin", "pos":Vector2(235.0, 390.0), "radius":24.0, "phase":0.1, "attack_cd":1.2},
		{"type":"skeleton", "pos":Vector2(350.0, 350.0), "radius":25.0, "phase":0.4, "attack_cd":1.1},
		{"type":"necromancer", "pos":Vector2(490.0, 405.0), "radius":27.0, "phase":1.0, "attack_cd":1.0},
	]
	_prepare_steady_state(world, mobs)
	var mp0: Array = [
		{"pos":Vector2(310.0, 625.0), "crit":false},
		{"pos":Vector2(410.0, 620.0), "crit":true},
	]
	var mp1: Array = [
		{"pos":Vector2(295.0, 535.0), "crit":false},
		{"pos":Vector2(425.0, 530.0), "crit":true},
	]
	var me0: Array = [
		{"pos":Vector2(245.0, 420.0), "color":Color("d7ff73")},
		{"pos":Vector2(360.0, 385.0), "color":Color("62e6ff")},
		{"pos":Vector2(480.0, 430.0), "color":Color("a568ff")},
	]
	var me1: Array = [
		{"pos":Vector2(280.0, 500.0), "color":Color("d7ff73")},
		{"pos":Vector2(360.0, 480.0), "color":Color("62e6ff")},
		{"pos":Vector2(445.0, 505.0), "color":Color("a568ff")},
	]
	world.sync_runtime(player_pos, mobs, mp0, me0, [], Vector2.ZERO, 31.60, 0.0, 0.0, 18)
	world.sync_runtime(player_pos, mobs, mp1, me1, [], Vector2.ZERO, 31.66, 0.0, 0.0, 18)
	world.call("_spawn_signature", world.spawn_signature_pool, "goblin", world.design_to_world(Vector2(235.0, 390.0)), true)
	world.call("_spawn_authority_impact", world.design_to_world(Vector2(375.0, 510.0)), world.authority_material)
	world.transition_timer = 0.0
	if world.transition_root != null:
		world.transition_root.visible = false
	if not await _save_frame("combined_mob_pressure"):
		return

	print("v1.63 combined combat identity visual review capture passed")
	world.queue_free()
	await process_frame
	quit(0)

func _warden(pos: Vector2, cast_kind: String, attack_cd: float, phase2: bool) -> Dictionary:
	return {
		"type":"warden", "pos":pos, "radius":32.0, "phase":0.8,
		"elite":true, "attack_cd":attack_cd, "cast_kind":cast_kind, "phase2":phase2,
	}

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
		_fail("empty combined review image: %s" % stem)
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save combined review image: %s" % stem)
		return false
	print("V163_COMBINED_REVIEW_CAPTURE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V163_COMBINED_REVIEW_CAPTURE_FAIL:%s" % message)
	quit(1)
