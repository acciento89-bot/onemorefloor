extends SceneTree

const WorldV160Actors = preload("res://scripts/world3d_chamber_v160_actors.gd")
const CAPTURE_DIR := "res://artifacts/v160_enemies"
const ENEMY_KINDS := ["goblin", "bat", "skeleton", "ghoul", "necromancer", "warden"]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var world = WorldV160Actors.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if not bool(world.call("production_actor_presentation_ready")):
		_fail("actor stack is not ready before enemy capture")
		return

	# Establish a real realm/background first, then freeze gameplay processing so
	# manually staged enemy shells are not hidden by an empty gameplay snapshot.
	world.sync_runtime(Vector2(360.0, 580.0), [], [], [], [], Vector2.ZERO, 25.0, 0.0, 0.0, 25)
	await process_frame
	world.set_active(false)
	world.set_process(false)
	if world.player_root != null:
		world.player_root.visible = false

	var staged: Array[Node3D] = []
	var gallery_positions := [
		Vector3(-2.35, 0.0, -1.25), Vector3(0.0, 0.0, -1.25), Vector3(2.35, 0.0, -1.25),
		Vector3(-2.35, 0.0, 2.05), Vector3(0.0, 0.0, 2.05), Vector3(2.35, 0.0, 2.05),
	]
	for index in range(ENEMY_KINDS.size()):
		var kind := String(ENEMY_KINDS[index])
		var enemy := world.enemy_pool[index] as Node3D
		world.actor_factory.configure_enemy(enemy, kind, world.actor_materials)
		enemy.position = gallery_positions[index]
		enemy.visible = true
		staged.append(enemy)
	for index in range(ENEMY_KINDS.size(), world.enemy_pool.size()):
		var unused := world.enemy_pool[index] as Node3D
		if unused != null:
			unused.visible = false

	world.camera.position = Vector3(0.0, 7.2, 8.7)
	world.camera.size = 8.7
	world.camera.look_at(Vector3(0.0, 0.85, 0.55), Vector3.UP)
	for _i in range(5):
		await process_frame
	if not await _save_frame("enemy_gallery"):
		return

	# Individual front close-ups make silhouette regressions obvious even though
	# the actual game camera shows enemies much smaller.
	for index in range(ENEMY_KINDS.size()):
		var kind := String(ENEMY_KINDS[index])
		for other_index in range(staged.size()):
			staged[other_index].visible = other_index == index
		var enemy := staged[index]
		enemy.position = Vector3.ZERO
		world.camera.position = Vector3(0.0, 4.55 if kind != "warden" else 5.35, -5.3 if kind != "warden" else -6.1)
		world.camera.size = 3.45 if kind != "warden" else 4.35
		world.camera.look_at(Vector3(0.0, 0.82 if kind != "warden" else 1.02, 0.0), Vector3.UP)
		world.actor_factory.animate_enemy(enemy, 1.4, float(index) * 0.31, 0.35, 0.0, index)
		for _i in range(4):
			await process_frame
		if not await _save_frame(kind):
			return
		enemy.position = gallery_positions[index]

	print("v1.60 production enemy silhouette visual capture passed")
	world.queue_free()
	await process_frame
	quit(0)

func _save_frame(stem: String) -> bool:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty enemy capture for %s" % stem)
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save enemy capture %s" % stem)
		return false
	print("V74_ENEMY_CAPTURE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V74_ENEMY_CAPTURE_FAIL:%s" % message)
	quit(1)
