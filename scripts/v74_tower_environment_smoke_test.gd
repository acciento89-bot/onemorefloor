extends SceneTree

const WorldV160 = preload("res://scripts/world3d_chamber_v160.gd")
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
		if not ResourceLoader.exists(path) or load(path) as Mesh == null:
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

	print("v1.60 authored tower environment smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V74_TOWER_ENV_FAIL:%s" % message)
	quit(1)
