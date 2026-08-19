extends SceneTree

const WorldV160 = preload("res://scripts/world3d_chamber_v160_floor.gd")
const REQUIRED_ASSETS := [
	"res://assets/environment/v160/tower_arch.obj",
	"res://assets/environment/v160/ossuary_totem.obj",
	"res://assets/environment/v160/iron_buttress.obj",
	"res://assets/environment/v160/rift_crystal.obj",
	"res://assets/environment/v160/spire_column.obj",
]
const REALM_CASES := {
	1: "lower_halls",
	15: "ossuary",
	25: "iron_bastion",
	35: "rift_descent",
	45: "starless_spire",
}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	for path in REQUIRED_ASSETS:
		if not ResourceLoader.exists(path):
			_fail("tower asset missing: %s" % path)
			return
		var imported_mesh := load(path) as Mesh
		if imported_mesh == null or imported_mesh.get_surface_count() <= 0:
			_fail("tower asset failed import: %s" % path)
			return

	var world = WorldV160.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(6):
		await process_frame
	if not bool(world.call("authored_tower_environment_ready")):
		_fail("authored tower environment did not become ready")
		return
	if not bool(world.call("production_floor_ready")):
		_fail("production floor layer did not become ready")
		return

	var floor_snapshot: Dictionary = world.debug_snapshot()
	if int(floor_snapshot.get("prototype_grid_hidden", 0)) < 9:
		_fail("legacy prototype floor grid was not fully hidden")
		return
	if int(floor_snapshot.get("production_floor_tiles", 0)) < 55:
		_fail("production floor dressing density too low")
		return
	if _visible_legacy_grid_strip_count(world) != 0:
		_fail("legacy prototype grid strip is still visible")
		return

	for floor_no in REALM_CASES.keys():
		world.sync_runtime(Vector2(360.0, 580.0), [], [], [], [], Vector2.ZERO, 1.0, 0.0, 0.0, int(floor_no))
		await process_frame
		var snapshot: Dictionary = world.debug_snapshot()
		var expected := String(REALM_CASES[floor_no])
		if String(snapshot.get("authored_tower_realm", "")) != expected:
			_fail("floor %s expected realm %s but got %s" % [floor_no, expected, snapshot.get("authored_tower_realm", "")])
			return
		var visible_count := 0
		for key in world.authored_realm_roots.keys():
			var realm_root := world.authored_realm_roots[key] as Node3D
			if realm_root != null and realm_root.visible:
				visible_count += 1
		if visible_count != 1:
			_fail("floor %s has %s authored realm roots visible" % [floor_no, visible_count])
			return

	var final_snapshot: Dictionary = world.debug_snapshot()
	if int(final_snapshot.get("authored_tower_asset_instances", 0)) < 20:
		_fail("authored tower asset density too low")
		return
	if not bool(final_snapshot.get("real_model_intake_v154_ready", false)):
		_fail("v1.54 real-model combat regression")
		return
	if not bool(final_snapshot.get("production_floor_ready", false)):
		_fail("production floor readiness regressed during realm switching")
		return

	print("v1.60 authored tower environment smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _visible_legacy_grid_strip_count(world: Node) -> int:
	var visible_count: int = 0
	for child in world.get_children():
		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null or not mesh_instance.visible or not (mesh_instance.mesh is BoxMesh):
			continue
		var box := mesh_instance.mesh as BoxMesh
		var size: Vector3 = box.size
		if size.y <= 0.055 and (size.x >= 7.0 or size.z >= 10.0):
			visible_count += 1
	return visible_count

func _fail(message: String) -> void:
	push_error("V74_TOWER_ENV_FAIL:%s" % message)
	quit(1)
