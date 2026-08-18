extends SceneTree

const AtmosphereWorld = preload("res://scripts/world3d_chamber_v160_atmosphere.gd")
const REALM_FLOORS := {
	1: "lower_halls",
	15: "ossuary",
	25: "iron_bastion",
	35: "rift_descent",
	45: "starless_spire",
}
const EXPECTED_GRADE := {
	"lower_halls": {"ambient":0.22, "key":1.00, "warm":1.25, "arcane":0.55},
	"ossuary": {"ambient":0.18, "key":0.94, "warm":0.38, "arcane":1.00},
	"iron_bastion": {"ambient":0.23, "key":1.04, "warm":1.48, "arcane":0.20},
	"rift_descent": {"ambient":0.17, "key":0.88, "warm":0.16, "arcane":1.20},
	"starless_spire": {"ambient":0.16, "key":0.82, "warm":0.08, "arcane":0.82},
}

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = AtmosphereWorld.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(8):
		await process_frame

	if not world.production_atmosphere_ready():
		_fail("production atmosphere structure did not become ready")
		return
	if not world.production_combat_vfx_ready():
		_fail("combat VFX readiness regressed under atmosphere layer")
		return

	for floor_value in REALM_FLOORS.keys():
		var floor_no := int(floor_value)
		world.sync_runtime(Vector2(360.0, 650.0), [], [], [], [], Vector2.ZERO, 2.0 + float(floor_no) * 0.01, 0.0, 0.0, floor_no)
		await process_frame
		var snapshot: Dictionary = world.debug_snapshot()
		var expected_realm: String = String(REALM_FLOORS[floor_no])
		if String(snapshot.get("production_atmosphere_realm", "")) != expected_realm:
			_fail("wrong atmosphere realm for floor %d" % floor_no)
			return

		var expected: Dictionary = EXPECTED_GRADE[expected_realm]
		var ambient := float(snapshot.get("production_atmosphere_ambient_energy", 9.0))
		var key_energy := float(snapshot.get("production_atmosphere_key_energy", 9.0))
		var warm_energy := float(snapshot.get("production_atmosphere_warm_energy", 9.0))
		var arcane_energy := float(snapshot.get("production_atmosphere_arcane_energy", 9.0))
		print("V74_ATMOSPHERE_SAMPLE:floor=%d:realm=%s:ambient=%.4f:key=%.4f:warm=%.4f:arcane=%.4f" % [floor_no, expected_realm, ambient, key_energy, warm_energy, arcane_energy])
		if not _near(ambient, float(expected["ambient"])):
			_fail("ambient %.4f != expected %.4f on floor %d" % [ambient, float(expected["ambient"]), floor_no])
			return
		if not _near(key_energy, float(expected["key"])):
			_fail("key %.4f != expected %.4f on floor %d" % [key_energy, float(expected["key"]), floor_no])
			return
		if not _near(warm_energy, float(expected["warm"])):
			_fail("warm %.4f != expected %.4f on floor %d" % [warm_energy, float(expected["warm"]), floor_no])
			return
		if not _near(arcane_energy, float(expected["arcane"])):
			_fail("arcane %.4f != expected %.4f on floor %d" % [arcane_energy, float(expected["arcane"]), floor_no])
			return
		if not world.production_actor_presentation_ready() or not world.production_material_depth_ready():
			_fail("actor/material readiness regressed on floor %d" % floor_no)
			return

	var env := world.atmosphere_world.environment as Environment
	if env == null or not env.adjustment_enabled:
		_fail("production environment adjustment is disabled")
		return
	if not _near(env.adjustment_brightness, 0.99) or not _near(env.adjustment_contrast, 1.13):
		_fail("production grading brightness=%.4f contrast=%.4f differs from locked grade" % [env.adjustment_brightness, env.adjustment_contrast])
		return
	if world.camera == null or absf(world.camera_base_size - 15.85) > 0.02:
		_fail("production portrait camera composition %.4f was not applied" % world.camera_base_size)
		return
	if world.player_rim_light.omni_range > 2.70 or world.player_fill_light.omni_range > 2.25:
		_fail("player lookdev lights still have oversized range")
		return

	print("v1.60 production atmosphere smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _near(actual: float, expected: float) -> bool:
	return absf(actual - expected) <= 0.005

func _fail(message: String) -> void:
	push_error("V74_ATMOSPHERE_FAIL:%s" % message)
	quit(1)
