extends SceneTree

const AcceptedWorld = preload("res://scripts/world3d_chamber_v163_boss_dominance.gd")
const CandidateWorld = preload("res://scripts/world3d_chamber_v164_character_lighting.gd")
const MainV85 = preload("res://scripts/main_v85.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	if MainV85 == null:
		_fail("main_v85 did not compile")
		return

	var accepted = AcceptedWorld.new()
	root.add_child(accepted)
	accepted.set_active(true)
	for _i in range(8):
		await process_frame
	if not bool(accepted.call("production_boss_dominance_ready")):
		_fail("accepted v1.63 r2.1 parent world is not ready")
		return
	var accepted_skeleton := _material_color(accepted.actor_factory.character_enemy_materials, "skeleton", "base_color")
	accepted.queue_free()
	await process_frame

	var world = CandidateWorld.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame

	if not bool(world.call("production_character_lighting_ready")):
		_fail("v1.64 character lighting r1 world is not ready")
		return
	if not bool(world.call("production_boss_dominance_ready")):
		_fail("accepted v1.63 boss dominance was not preserved")
		return
	if int(world.v164_character_materials_tuned) < 11:
		_fail("expected 11 tuned character materials")
		return

	if not _color_close(_material_color(world.actor_factory.wanderer_materials, "cloth", "base_color"), Color("293750")):
		_fail("Wanderer cloth r1 base color missing")
		return
	if not _color_close(_material_color(world.actor_factory.wanderer_materials, "steel_dark", "base_color"), Color("36465b")):
		_fail("Wanderer dark steel r1 base color missing")
		return
	if not _color_close(_material_color(world.actor_factory.character_enemy_materials, "necromancer", "base_color"), Color("2d203b")):
		_fail("Necromancer r1 midtone recovery missing")
		return
	if not _color_close(_material_color(world.actor_factory.character_enemy_materials, "skeleton", "base_color"), accepted_skeleton):
		_fail("Skeleton visual lock changed")
		return

	# Exercise the three frozen comparison realms and verify the existing player
	# lights receive only the intended restrained r1 energy/range adjustment.
	for floor_no in [6, 16, 30]:
		world.sync_runtime(Vector2(360.0, 700.0), [], [], [], [], Vector2.ZERO, 50.0 + float(floor_no), 0.0, 0.0, floor_no)
		await process_frame
		if world.player_rim_light == null or world.player_fill_light == null:
			_fail("existing Wanderer rim/fill lights missing")
			return
		if world.player_rim_light.omni_range < 2.80 or world.player_fill_light.omni_range < 2.40:
			_fail("v1.64 r1 local light ranges not applied")
			return
		if world.atmosphere_player_fill_base < 0.28 or world.atmosphere_player_rim_base < 0.53:
			_fail("v1.64 r1 local light grade not applied")
			return

	if String(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")) != "gl_compatibility":
		_fail("renderer moved away from GL Compatibility")
		return

	print("v1.64 character lighting r1 smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _material_color(materials: Dictionary, key: String, parameter: String) -> Color:
	var material := materials.get(key) as ShaderMaterial
	if material == null:
		return Color(-1.0, -1.0, -1.0, -1.0)
	var value: Variant = material.get_shader_parameter(parameter)
	return value as Color if value is Color else Color(-1.0, -1.0, -1.0, -1.0)

func _color_close(a: Color, b: Color) -> bool:
	return absf(a.r - b.r) < 0.002 and absf(a.g - b.g) < 0.002 and absf(a.b - b.b) < 0.002

func _fail(message: String) -> void:
	push_error("V164_CHARACTER_LIGHTING_R1_FAIL:%s" % message)
	quit(1)
