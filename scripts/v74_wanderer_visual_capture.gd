extends SceneTree

const WorldV160Actors = preload("res://scripts/world3d_chamber_v160_actors.gd")
const CAPTURE_DIR := "res://artifacts/v160_wanderer"

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
		_fail("Wanderer presentation not ready before capture")
		return

	# Real runtime framing on two visually different realms.
	for floor_no in [1, 25]:
		world.sync_runtime(Vector2(360.0, 580.0), [], [], [], [], Vector2.ZERO, float(floor_no), 0.0, 0.0, floor_no)
		for _i in range(8):
			await process_frame
		if not await _save_frame("floor%02d" % floor_no):
			return

	# Dedicated close-up gate: same world/model, only the validation camera is
	# closer so silhouette/material errors cannot hide in a full-room screenshot.
	world.sync_runtime(Vector2(360.0, 580.0), [], [], [], [], Vector2.ZERO, 25.0, 0.0, 0.0, 25)
	world.camera_base_position = Vector3(0.0, 4.85, 5.35)
	world.camera_focus = Vector3(0.0, 0.92, 0.0)
	world.camera_base_size = 4.65
	world.camera.position = world.camera_base_position
	world.camera.size = world.camera_base_size
	world.camera.look_at(world.camera_focus, Vector3.UP)
	for _i in range(6):
		await process_frame
	if not await _save_frame("wanderer_closeup_idle"):
		return

	# Attack pose verifies that the new sword/pauldrons follow the imported
	# articulation rather than becoming a static decorative shell.
	world.sync_runtime(Vector2(360.0, 580.0), [], [], [], [], Vector2.ZERO, 25.2, 1.0, 0.0, 25)
	for _i in range(3):
		await process_frame
	if not await _save_frame("wanderer_closeup_attack"):
		return

	print("v1.60 production Wanderer visual capture passed")
	world.queue_free()
	await process_frame
	quit(0)

func _save_frame(stem: String) -> bool:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty capture for %s" % stem)
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save %s" % stem)
		return false
	print("V74_WANDERER_CAPTURE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V74_WANDERER_CAPTURE_FAIL:%s" % message)
	quit(1)
