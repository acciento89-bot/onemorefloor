extends SceneTree

const AtmosphereWorld = preload("res://scripts/world3d_chamber_v160_atmosphere.gd")
const REALM_FLOORS := {
	1: "lower_halls",
	15: "ossuary",
	25: "iron_bastion",
	35: "rift_descent",
	45: "starless_spire",
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
		var ambient := float(snapshot.get("production_atmosphere_ambient_energy", 9.0))
		var key_energy := float(snapshot.get("production_atmosphere_key_energy", 9.0))
		var warm_energy := float(snapshot.get("production_atmosphere_warm_energy", 9.0))
		var arcane_energy := float(snapshot.get("production_atmosphere_arcane_energy", 9.0))
		print("V74_ATMOSPHERE_SAMPLE:floor=%d:realm=%s:ambient=%.4f:key=%.4f:warm=%.4f:arcane=%.4f" % [floor_no, expected_realm, ambient, key_energy, warm_energy, arcane_energy])
		if ambient < 0.08 or ambient > 0.18:
			_fail("ambient energy %.4f outside production range on floor %d" % [ambient, floor_no])
			return
		if key_energy < 0.70 or key_energy > 1.05:
			_fail("key energy %.4f outside production range on floor %d" % [key_energy, floor_no])
			return
		if warm_energy < 0.0 or warm_energy > 1.70 or arcane_energy < 0.0 or arcane_energy > 1.45:
			_fail("realm omni energy warm=%.4f arcane=%.4f outside production range on floor %d" % [warm_energy, arcane_energy, floor_no])
			return
		if not world.production_actor_presentation_ready() or not world.production_material_depth_ready():
			_fail("actor/material readiness regressed on floor %d" % floor_no)
			return

	var env := world.atmosphere_world.environment as Environment
	if env == null or not env.adjustment_enabled:
		_fail("production environment adjustment is disabled")
		return
	if env.adjustment_contrast < 1.15 or env.adjustment_contrast > 1.21:
		_fail("production contrast %.4f is outside controlled range" % env.adjustment_contrast)
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

func _fail(message: String) -> void:
	push_error("V74_ATMOSPHERE_FAIL:%s" % message)
	quit(1)
