extends SceneTree

const WorldV160Materials = preload("res://scripts/world3d_chamber_v160_materials.gd")
const FLOORS := [1, 15, 25, 35, 45]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var shader := load("res://assets/shaders/v160_surface_depth.gdshader") as Shader
	if shader == null:
		_fail("surface depth shader failed to load")
		return

	var world = WorldV160Materials.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(8):
		await process_frame

	if not bool(world.call("production_material_depth_ready")):
		_fail("material depth layer did not become ready")
		return
	var boot_snapshot: Dictionary = world.debug_snapshot()
	var applied := int(boot_snapshot.get("production_material_depth_instances", 0))
	var target := int(boot_snapshot.get("production_material_depth_target", 0))
	if target <= 0 or applied < target:
		_fail("material depth coverage incomplete: %s/%s" % [applied, target])
		return
	if not bool(boot_snapshot.get("production_focal_ready", false)):
		_fail("focal regression under material depth layer")
		return

	for floor_no in FLOORS:
		world.sync_runtime(Vector2(360.0, 600.0), [], [], [], [], Vector2.ZERO, float(floor_no), 0.0, 0.0, floor_no)
		await process_frame
		var realm_key := "lower_halls"
		if floor_no >= 41:
			realm_key = "starless_spire"
		elif floor_no >= 31:
			realm_key = "rift_descent"
		elif floor_no >= 21:
			realm_key = "iron_bastion"
		elif floor_no >= 11:
			realm_key = "ossuary"
		var realm_root := world.authored_realm_roots.get(realm_key) as Node3D
		if realm_root == null or not realm_root.visible:
			_fail("realm %s not visible on floor %s" % [realm_key, floor_no])
			return
		var shader_materials := 0
		for child in realm_root.get_children():
			var mesh_instance := child as MeshInstance3D
			if mesh_instance != null and mesh_instance.material_override is ShaderMaterial:
				shader_materials += 1
		if shader_materials <= 0:
			_fail("no authored shader material visible on floor %s" % floor_no)
			return

	var final_snapshot: Dictionary = world.debug_snapshot()
	if not bool(final_snapshot.get("real_model_intake_v154_ready", false)):
		_fail("v1.54 real-model combat regression")
		return
	if not bool(final_snapshot.get("production_composition_grade", false)):
		_fail("v1.60 composition/lighting regression")
		return

	print("v1.60 authored material depth smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V74_MATERIAL_DEPTH_FAIL:%s" % message)
	quit(1)
