extends SceneTree

const AtmosphereWorld = preload("res://scripts/world3d_chamber_v160_atmosphere.gd")
const CAPTURE_DIR := "res://artifacts/v160_atmosphere"
const CAPTURES := [
	{"floor":1, "name":"lower_halls", "enemies":["goblin", "bat"]},
	{"floor":15, "name":"ossuary", "enemies":["skeleton", "ghoul"]},
	{"floor":25, "name":"iron_bastion", "enemies":["skeleton", "warden"]},
	{"floor":35, "name":"rift_descent", "enemies":["necromancer", "bat"]},
	{"floor":45, "name":"starless_spire", "enemies":["warden", "necromancer"]},
]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))
	var world = AtmosphereWorld.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(8):
		await process_frame
	if not world.production_atmosphere_ready():
		_fail("atmosphere world not ready before visual capture")
		return

	# Freeze time-driven animation for deterministic realm comparisons. Spawn and
	# death signatures are short-lived gameplay VFX (0.52 s in v1.48); because a
	# frozen capture cannot age them out, they are explicitly suppressed here.
	world.set_active(false)

	for capture_value in CAPTURES:
		var capture: Dictionary = capture_value
		var floor_no := int(capture["floor"])
		var kinds: Array = capture["enemies"]
		var enemies: Array = [
			{"type":String(kinds[0]), "pos":Vector2(285.0, 425.0), "radius":25.0, "phase":0.25},
			{"type":String(kinds[1]), "pos":Vector2(435.0, 410.0), "radius":27.0, "phase":0.85},
		]
		world.attack_amount = 0.0
		world.skill_amount = 0.0
		world.sync_runtime(Vector2(360.0, 660.0), enemies, [], [], [], Vector2.ZERO, 5.0, 0.0, 0.0, floor_no)
		_suppress_transient_signatures(world)
		world.transition_timer = 0.0
		if world.transition_root != null:
			world.transition_root.visible = false
		world.call("_update_player_lighting")
		world.call("_limit_v160_dynamic_light_energy")
		if not await _save_frame("%02d_%s" % [floor_no, String(capture["name"])]):
			return

	print("v1.60 production atmosphere visual capture passed")
	world.queue_free()
	await process_frame
	quit(0)

func _suppress_transient_signatures(world: Node) -> void:
	for pool_name in ["spawn_signature_pool", "death_signature_pool"]:
		var pool_value: Variant = world.get(pool_name)
		if not (pool_value is Array):
			continue
		for item_value in pool_value:
			var item := item_value as Node3D
			if item == null:
				continue
			item.visible = false
			item.set_meta("age", 999.0)

func _save_frame(stem: String) -> bool:
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty atmosphere capture for %s" % stem)
		return false
	var output := "%s/%s.png" % [CAPTURE_DIR, stem]
	if image.save_png(ProjectSettings.globalize_path(output)) != OK:
		_fail("could not save atmosphere capture %s" % stem)
		return false
	print("V74_ATMOSPHERE_CAPTURE:%s:%s:%dx%d" % [stem, output, image.get_width(), image.get_height()])
	return true

func _fail(message: String) -> void:
	push_error("V74_ATMOSPHERE_CAPTURE_FAIL:%s" % message)
	quit(1)
