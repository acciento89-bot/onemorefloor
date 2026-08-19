extends SceneTree

const AcceptedWorld = preload("res://scripts/world3d_chamber_v163_boss_dominance.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = AcceptedWorld.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame

	if not bool(world.call("production_boss_dominance_ready")):
		_fail("accepted v1.63 r2.1 world is not ready")
		return
	if world.atmosphere_world == null or world.atmosphere_world.environment == null:
		_fail("WorldEnvironment / Environment missing")
		return
	if world.atmosphere_key == null or world.atmosphere_warm == null or world.atmosphere_arcane == null:
		_fail("shared key/warm/arcane lighting path missing")
		return
	if world.player_rim_light == null or world.player_fill_light == null:
		_fail("Wanderer rim/fill lighting path missing")
		return
	if world.actor_factory == null or not world.actor_factory.has_method("v160_authored_wanderer_ready"):
		_fail("authored Wanderer factory contract missing")
		return
	if not bool(world.actor_factory.call("v160_authored_wanderer_ready", world.player_root)):
		_fail("authored Wanderer is not ready")
		return
	if String(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")) != "gl_compatibility":
		_fail("baseline must remain on GL Compatibility")
		return

	print("v1.64 character lighting baseline smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V164_CHARACTER_LIGHTING_BASELINE_FAIL:%s" % message)
	quit(1)
