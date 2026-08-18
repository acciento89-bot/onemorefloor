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
	for _i in range(8): await process_frame
	if not world.production_atmosphere_ready(): return _fail("production atmosphere structure did not become ready")
	if not world.production_combat_vfx_ready(): return _fail("combat VFX readiness regressed under atmosphere layer")

	for floor_value in REALM_FLOORS.keys():
		var floor_no := int(floor_value)
		world.sync_runtime(Vector2(360.0,650.0), [], [], [], [], Vector2.ZERO, 2.0 + float(floor_no)*0.01, 0.0, 0.0, floor_no)
		await process_frame
		var snapshot: Dictionary = world.debug_snapshot()
		var realm := String(REALM_FLOORS[floor_no])
		if String(snapshot.get("production_atmosphere_realm", "")) != realm: return _fail("wrong atmosphere realm for floor %d" % floor_no)
		var expected: Dictionary = EXPECTED_GRADE[realm]
		var ambient := float(snapshot.get("production_atmosphere_ambient_energy",9.0))
		var key := float(snapshot.get("production_atmosphere_key_energy",9.0))
		var warm := float(snapshot.get("production_atmosphere_warm_energy",9.0))
		var arcane := float(snapshot.get("production_atmosphere_arcane_energy",9.0))
		print("V74_ATMOSPHERE_SAMPLE:floor=%d:realm=%s:ambient=%.4f:key=%.4f:warm=%.4f:arcane=%.4f" % [floor_no,realm,ambient,key,warm,arcane])
		if not _near(ambient,float(expected["ambient"])): return _fail("ambient grade mismatch")
		if not _near(key,float(expected["key"])): return _fail("key grade mismatch")
		if not _near(warm,float(expected["warm"])): return _fail("warm grade mismatch")
		if not _near(arcane,float(expected["arcane"])): return _fail("arcane grade mismatch")
		if not world.production_actor_presentation_ready() or not world.production_material_depth_ready(): return _fail("actor/material readiness regressed")

	var passive_enemies: Array = [
		{"type":"goblin", "pos":Vector2(285.0,425.0), "radius":25.0, "phase":0.25},
		{"type":"bat", "pos":Vector2(435.0,410.0), "radius":27.0, "phase":0.85},
	]
	world.sync_runtime(Vector2(360.0,660.0), passive_enemies, [], [], [], Vector2.ZERO, 5.0, 0.0, 0.0, 1)
	await process_frame
	for enemy_index in range(2):
		var enemy_root := world.enemy_pool[enemy_index] as Node3D
		if enemy_root == null: continue
		print("V74_PASSIVE_ENEMY_ROOT:%d:%s:pos=%s" % [enemy_index, enemy_root.get_path(), enemy_root.global_position])
		_trace_floor_meshes(enemy_root, enemy_root.global_position)
	_trace_nearby_world_meshes(world, (world.enemy_pool[0] as Node3D).global_position, "goblin")
	_trace_nearby_world_meshes(world, (world.enemy_pool[1] as Node3D).global_position, "bat")

	var env := world.atmosphere_world.environment as Environment
	if env == null or not env.adjustment_enabled: return _fail("production environment adjustment is disabled")
	if not _near(env.adjustment_brightness,0.99) or not _near(env.adjustment_contrast,1.13): return _fail("production grading differs from locked grade")
	if world.camera == null or absf(world.camera_base_size-15.85)>0.02: return _fail("production portrait camera composition missing")
	if world.player_rim_light.omni_range>2.70 or world.player_fill_light.omni_range>2.25: return _fail("player lookdev lights still have oversized range")
	print("v1.60 production atmosphere smoke test passed")
	world.queue_free(); await process_frame; quit(0)

func _trace_floor_meshes(node: Node, enemy_pos: Vector3) -> void:
	if node is MeshInstance3D:
		var mesh_node := node as MeshInstance3D
		if _effective_visible(mesh_node):
			var mesh_kind := mesh_node.mesh.get_class() if mesh_node.mesh != null else "none"
			var mat := mesh_node.material_override as StandardMaterial3D
			var color := mat.albedo_color if mat != null else Color.WHITE
			print("V74_ACTOR_MESH:%s:type=%s:local=%s:global=%s:color=%s" % [mesh_node.get_path(),mesh_kind,mesh_node.position,mesh_node.global_position,color])
	for child in node.get_children(): _trace_floor_meshes(child as Node, enemy_pos)

func _trace_nearby_world_meshes(node: Node, enemy_pos: Vector3, label: String) -> void:
	if node is MeshInstance3D:
		var mesh_node := node as MeshInstance3D
		if _effective_visible(mesh_node):
			var delta := Vector2(mesh_node.global_position.x-enemy_pos.x, mesh_node.global_position.z-enemy_pos.z).length()
			if delta < 0.78 and mesh_node.global_position.y < 0.35:
				var mesh_kind := mesh_node.mesh.get_class() if mesh_node.mesh != null else "none"
				var mat := mesh_node.material_override as StandardMaterial3D
				var color := mat.albedo_color if mat != null else Color.WHITE
				print("V74_NEAR_%s:%s:type=%s:global=%s:color=%s" % [label,mesh_node.get_path(),mesh_kind,mesh_node.global_position,color])
	for child in node.get_children(): _trace_nearby_world_meshes(child as Node, enemy_pos, label)

func _effective_visible(node: Node) -> bool:
	var current: Node = node
	while current != null:
		if current is Node3D and not (current as Node3D).visible: return false
		current = current.get_parent()
	return true

func _near(actual: float, expected: float) -> bool: return absf(actual-expected)<=0.005
func _fail(message: String) -> void:
	push_error("V74_ATMOSPHERE_FAIL:%s" % message)
	quit(1)
