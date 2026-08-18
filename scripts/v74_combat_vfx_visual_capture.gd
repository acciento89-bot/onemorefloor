extends SceneTree

const WorldV160VFX = preload("res://scripts/world3d_chamber_v160_vfx.gd")
const CAPTURE_DIR := "res://artifacts/v160_combat_vfx"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var world = WorldV160VFX.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if not bool(world.call("production_combat_vfx_ready")):
		_fail("combat VFX layer is not ready before capture")
		return

	var enemies := [
		{"type":"goblin", "pos":Vector2(255.0, 445.0), "radius":23.0, "phase":0.2, "attack_cd":0.09},
		{"type":"skeleton", "pos":Vector2(465.0, 445.0), "radius":25.0, "phase":0.8, "attack_cd":0.12},
		{"type":"warden", "pos":Vector2(360.0, 345.0), "radius":31.0, "phase":1.1, "slam_cd":0.08},
	]
	var player_pos := Vector2(360.0, 665.0)

	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 3.0, 1.0, 0.0, 1)
	_clear_transition_for_capture(world)
	for _i in range(2):
		await process_frame
	if not await _save_frame("attack_arc"):
		return

	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 3.15, 0.0, 1.0, 1)
	_clear_transition_for_capture(world)
	for _i in range(2):
		await process_frame
	if not await _save_frame("skill_ring"):
		return

	# A tell-only frame demonstrates that enemy telegraphs are now hollow rings
	# while preserving the exact runtime warning timing.
	world.attack_amount = 0.0
	world.skill_amount = 0.0
	world.sync_runtime(player_pos, enemies, [], [], [], Vector2.ZERO, 3.30, 0.0, 0.0, 1)
	_clear_transition_for_capture(world)
	await process_frame
	if not await _save_frame("enemy_tells"):
		return

	# Closer validation view for player-only arc/skill geometry. The preceding
	# enemies are removed, so their death-signature pool is hidden only for this
	# diagnostic frame. Production timing/state is never changed by the gate.
	world.sync_runtime(Vector2(360.0, 600.0), [], [], [], [], Vector2.ZERO, 4.0, 1.0, 1.0, 1)
	_clear_transition_for_capture(world)
	_hide_signature_pool_for_capture(world.spawn_signature_pool)
	_hide_signature_pool_for_capture(world.death_signature_pool)
	world.camera.position = Vector3(0.0, 5.6, 5.9)
	world.camera.size = 6.2
	world.camera.look_at(Vector3(0.0, 0.55, 0.0), Vector3.UP)
	await process_frame
	if not await _save_frame("player_vfx_closeup"):
		return

	print("v1.60 production combat VFX visual capture passed")
	world.queue_free()
	await process_frame
	quit(0)

func _clear_transition_for_capture(world) -> void:
	# The realm-transition disc is an intentional presentation surface, not a
	# combat telegraph. Hide it only in this diagnostic so the VFX are readable.
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
		_fail("empty combat VFX capture for %s" % stem)
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save combat VFX capture %s" % stem)
		return false
	print("V74_COMBAT_VFX_CAPTURE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V74_COMBAT_VFX_CAPTURE_FAIL:%s" % message)
	quit(1)
