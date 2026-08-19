extends SceneTree

const WorldV160Materials = preload("res://scripts/world3d_chamber_v160_materials.gd")
const CAPTURE_DIR := "res://artifacts/v160_materials"
const FLOORS := [1, 15, 25, 35, 45]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var world = WorldV160Materials.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame
	if not bool(world.call("production_material_depth_ready")):
		_fail("material depth layer is not ready before capture")
		return

	for floor_no in FLOORS:
		world.sync_runtime(Vector2(360.0, 600.0), [], [], [], [], Vector2.ZERO, float(floor_no), 0.0, 0.0, floor_no)
		for _i in range(10):
			await process_frame
		await RenderingServer.frame_post_draw
		var image := root.get_texture().get_image()
		if image == null or image.is_empty():
			_fail("empty material capture on floor %s" % floor_no)
			return
		var output := "%s/floor%02d.png" % [CAPTURE_DIR, floor_no]
		if image.save_png(ProjectSettings.globalize_path(output)) != OK:
			_fail("could not save material floor %s" % floor_no)
			return
		print("V74_MATERIAL_CAPTURE:%02d:%s:%dx%d" % [floor_no, output, image.get_width(), image.get_height()])

	print("v1.60 authored material depth visual capture passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V74_MATERIAL_CAPTURE_FAIL:%s" % message)
	quit(1)
