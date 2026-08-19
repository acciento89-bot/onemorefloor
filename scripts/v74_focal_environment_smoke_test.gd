extends SceneTree

const WorldV160Focals = preload("res://scripts/world3d_chamber_v160_focals.gd")
const REQUIRED_FOCALS := [
	"res://assets/environment/v160/ossuary_altar.obj",
	"res://assets/environment/v160/forge_engine.obj",
	"res://assets/environment/v160/rift_anchor.obj",
	"res://assets/environment/v160/starwell_dais.obj",
]
const CASES := {
	15: ["ossuary", "OssuaryReliquaryAltarV160"],
	25: ["iron_bastion", "IronForgeEngineV160"],
	35: ["rift_descent", "RiftAnchorGateV160"],
	45: ["starless_spire", "StarwellDaisV160"],
}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	for path in REQUIRED_FOCALS:
		if not ResourceLoader.exists(path):
			_fail("missing focal asset: %s" % path)
			return
		var mesh := load(path) as Mesh
		if mesh == null or mesh.get_surface_count() <= 0:
			_fail("focal asset failed import: %s" % path)
			return

	var world = WorldV160Focals.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(8):
		await process_frame

	if not bool(world.call("production_focal_ready")):
		_fail("authored focal layer did not become ready")
		return
	var boot_snapshot: Dictionary = world.debug_snapshot()
	if int(boot_snapshot.get("production_focal_instances", 0)) != 4:
		_fail("expected exactly four focal asset instances")
		return
	if not bool(boot_snapshot.get("production_floor_ready", false)):
		_fail("production floor regression under focal layer")
		return

	for floor_no in CASES.keys():
		world.sync_runtime(Vector2(360.0, 600.0), [], [], [], [], Vector2.ZERO, float(floor_no), 0.0, 0.0, int(floor_no))
		await process_frame
		var expected: Array = CASES[floor_no]
		var realm_key := String(expected[0])
		var focal_name := String(expected[1])
		var realm_root := world.authored_realm_roots.get(realm_key) as Node3D
		if realm_root == null or not realm_root.visible:
			_fail("realm %s not visible on floor %s" % [realm_key, floor_no])
			return
		var focal := realm_root.get_node_or_null(focal_name) as MeshInstance3D
		if focal == null or focal.mesh == null or not focal.visible:
			_fail("missing visible focal %s on floor %s" % [focal_name, floor_no])
			return

	var final_snapshot: Dictionary = world.debug_snapshot()
	if not bool(final_snapshot.get("real_model_intake_v154_ready", false)):
		_fail("v1.54 real-model combat regression")
		return
	if not bool(final_snapshot.get("production_composition_grade", false)):
		_fail("v1.60 composition/lighting regression")
		return

	print("v1.60 authored focal environment smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V74_FOCAL_ENV_FAIL:%s" % message)
	quit(1)
