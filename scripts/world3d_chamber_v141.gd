extends "res://scripts/world3d_chamber.gd"

# ONE MORE FLOOR v1.41 — 3D Production Quality Pass.
# Keeps the v1.39/v1.40 gameplay bridge intact and improves only presentation:
# stronger materials/light composition, grounded actors, projectile trails,
# impact flashes, combat tells and denser Lower Halls architecture.

const ProductionActorFactory = preload("res://scripts/world3d_actor_factory_v141.gd")
const TRAIL_LENGTH := 0.58
const IMPACT_POOL_SIZE := 16

var player_trail_pool: Array = []
var enemy_trail_pool: Array = []
var player_prev_positions: Array = []
var enemy_prev_positions: Array = []
var player_prev_valid: Array = []
var enemy_prev_valid: Array = []
var impact_pool: Array = []
var impact_state: Array = []
var impact_cursor := 0
var production_details_root: Node3D

func _ready() -> void:
	actor_factory = ProductionActorFactory.new()
	super._ready()
	_upgrade_environment_grade()
	_upgrade_actor_grounding()
	_build_projectile_trails()
	_build_impact_pool()
	_build_production_details()

func _process(delta: float) -> void:
	super._process(delta)
	_animate_impacts(delta)
	_animate_room_details()

func production_quality_ready() -> bool:
	return world_ready() \
		and authored_actor_ready() \
		and actor_factory.has_method("production_actor_ready") \
		and bool(actor_factory.call("production_actor_ready", player_root)) \
		and player_trail_pool.size() == MAX_PLAYER_SHOTS \
		and enemy_trail_pool.size() == MAX_ENEMY_SHOTS \
		and impact_pool.size() == IMPACT_POOL_SIZE \
		and production_details_root != null

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_quality"] = production_quality_ready()
	data["player_trails"] = player_trail_pool.size()
	data["enemy_trails"] = enemy_trail_pool.size()
	data["impact_pool"] = impact_pool.size()
	data["production_details"] = production_details_root != null
	return data

func _upgrade_environment_grade() -> void:
	var world_env := get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_env != null and world_env.environment != null:
		var env: Environment = world_env.environment
		env.background_color = Color("02040a")
		env.ambient_light_color = Color("6e6784")
		env.ambient_light_energy = 0.29
		env.adjustment_enabled = true
		env.adjustment_brightness = 1.02
		env.adjustment_contrast = 1.10
		env.adjustment_saturation = 0.94

	var moon := get_node_or_null("MoonKey") as DirectionalLight3D
	if moon != null:
		moon.light_energy = 1.52
		moon.light_color = Color("d4d7ff")

	# Rim light separates silhouettes from the dark floor without adding another
	# expensive shadow caster.
	var rim := DirectionalLight3D.new()
	rim.name = "ProductionRim"
	rim.rotation_degrees = Vector3(-48.0, 148.0, 0.0)
	rim.light_color = Color("8c6bd6")
	rim.light_energy = 0.48
	rim.shadow_enabled = false
	add_child(rim)

	# Local gold pool around the gate creates a destination/readable focal point.
	_add_omni("GateGoldPool", Vector3(0.0, 2.15, -5.85), Color("ffc76b"), 2.2, 4.8, false)

func _upgrade_actor_grounding() -> void:
	var shadow_material: StandardMaterial3D = _shadow_material()
	_add_contact_shadow(player_root, 0.48, shadow_material)
	for enemy_value in enemy_pool:
		var enemy := enemy_value as Node3D
		_add_contact_shadow(enemy, 0.43, shadow_material)

func _add_contact_shadow(root: Node3D, radius: float, material: Material) -> void:
	if root == null or root.get_node_or_null("ContactShadow") != null:
		return
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.012
	mesh.radial_segments = 24
	var shadow := MeshInstance3D.new()
	shadow.name = "ContactShadow"
	shadow.mesh = mesh
	shadow.position = Vector3(0.0, 0.012, 0.08)
	shadow.scale = Vector3(1.18, 1.0, 0.72)
	shadow.material_override = material
	shadow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(shadow)

func _build_projectile_trails() -> void:
	var player_mat: StandardMaterial3D = _transparent_emissive(Color("ffd978", 0.62), 2.35)
	var enemy_mat: StandardMaterial3D = _transparent_emissive(Color("9b65ff", 0.54), 2.10)
	for i in range(MAX_PLAYER_SHOTS):
		player_trail_pool.append(_make_trail("PlayerTrail%02d" % i, player_mat))
		player_prev_positions.append(Vector3.ZERO)
		player_prev_valid.append(false)
	for i in range(MAX_ENEMY_SHOTS):
		enemy_trail_pool.append(_make_trail("EnemyTrail%02d" % i, enemy_mat))
		enemy_prev_positions.append(Vector3.ZERO)
		enemy_prev_valid.append(false)

func _make_trail(name_value: String, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.055, 0.055, TRAIL_LENGTH)
	var trail := MeshInstance3D.new()
	trail.name = name_value
	trail.mesh = mesh
	trail.material_override = material
	trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	trail.visible = false
	add_child(trail)
	return trail

func _sync_projectiles(shots: Array, pool: Array, friendly: bool) -> void:
	super._sync_projectiles(shots, pool, friendly)
	var trails: Array = player_trail_pool if friendly else enemy_trail_pool
	var prev_positions: Array = player_prev_positions if friendly else enemy_prev_positions
	var prev_valid: Array = player_prev_valid if friendly else enemy_prev_valid
	if trails.is_empty():
		return

	for i in range(pool.size()):
		var trail := trails[i] as MeshInstance3D
		if i >= shots.size():
			trail.visible = false
			if bool(prev_valid[i]):
				var final_position: Vector3 = prev_positions[i]
				_spawn_impact(final_position, friendly)
			prev_valid[i] = false
			continue

		var projectile := pool[i] as MeshInstance3D
		var current: Vector3 = projectile.position
		if bool(prev_valid[i]):
			var previous: Vector3 = prev_positions[i]
			var distance: float = current.distance_to(previous)
			if distance > 0.015:
				trail.visible = true
				trail.position = (previous + current) * 0.5
				trail.scale = Vector3(1.0, 1.0, clampf(distance / TRAIL_LENGTH, 0.28, 2.2))
				trail.look_at(current, Vector3.UP)
			else:
				trail.visible = false
		else:
			trail.visible = false
		prev_positions[i] = current
		prev_valid[i] = true

	if friendly:
		player_prev_positions = prev_positions
		player_prev_valid = prev_valid
	else:
		enemy_prev_positions = prev_positions
		enemy_prev_valid = prev_valid

func _build_impact_pool() -> void:
	for i in range(IMPACT_POOL_SIZE):
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.22
		mesh.bottom_radius = 0.22
		mesh.height = 0.018
		mesh.radial_segments = 20
		var ring := MeshInstance3D.new()
		ring.name = "Impact%02d" % i
		ring.mesh = mesh
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		ring.visible = false
		impact_pool.append(ring)
		impact_state.append({"age": 99.0, "friendly": true})
		add_child(ring)

func _spawn_impact(pos: Vector3, friendly: bool) -> void:
	if impact_pool.is_empty():
		return
	var index: int = impact_cursor % impact_pool.size()
	impact_cursor += 1
	var ring := impact_pool[index] as MeshInstance3D
	ring.position = Vector3(pos.x, 0.035, pos.z)
	ring.scale = Vector3.ONE * 0.55
	ring.material_override = _transparent_emissive(Color("ffd66b", 0.72) if friendly else Color("aa6bff", 0.68), 2.6)
	ring.visible = true
	impact_state[index] = {"age": 0.0, "friendly": friendly}

func _animate_impacts(delta: float) -> void:
	for i in range(impact_pool.size()):
		var state: Dictionary = impact_state[i]
		var age: float = float(state.get("age", 99.0))
		if age >= 0.22:
			(impact_pool[i] as MeshInstance3D).visible = false
			continue
		age += delta
		state["age"] = age
		impact_state[i] = state
		var ring := impact_pool[i] as MeshInstance3D
		ring.visible = true
		var p: float = clampf(age / 0.22, 0.0, 1.0)
		var scale_value: float = 0.55 + p * 2.35
		ring.scale = Vector3(scale_value, 1.0, scale_value)
		ring.rotation.y += delta * 4.0

func _build_production_details() -> void:
	production_details_root = Node3D.new()
	production_details_root.name = "ProductionDetails"
	add_child(production_details_root)

	var stone_dark: StandardMaterial3D = _material(Color("11141b"), 0.08, 0.92)
	var stone_edge: StandardMaterial3D = _material(Color("3d3945"), 0.24, 0.66)
	var ember: StandardMaterial3D = _emissive_material(Color("ff8e47"), 2.5)
	var rune: StandardMaterial3D = _emissive_material(Color("9f68ff"), 1.9)

	# Side-wall buttresses and arch-like lintels make the room read as a tower,
	# not a flat rectangle, while staying cheap enough for mobile.
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		for z_value in [-4.9, -1.7, 1.5, 4.7]:
			var z: float = float(z_value)
			var x: float = side * 4.90
			_add_box(production_details_root, "Buttress", Vector3(0.42, 2.25, 0.72), Vector3(x, 0.95, z), stone_dark)
			_add_box(production_details_root, "ButtressCap", Vector3(0.58, 0.20, 0.92), Vector3(x, 2.02, z), stone_edge)

	# Four braziers define depth lanes and provide emissive landmarks.
	for pos_value in [Vector3(-3.65, 0.0, -3.6), Vector3(3.65, 0.0, -3.6), Vector3(-3.65, 0.0, 3.4), Vector3(3.65, 0.0, 3.4)]:
		var pos: Vector3 = pos_value
		_add_brazier(pos, stone_edge, ember)

	# Floor sigils guide the eye to the gate and reinforce the arcane tower ID.
	for z_value in [-4.8, -0.2, 4.2]:
		var z: float = float(z_value)
		var sigil := _add_cylinder_local(production_details_root, "FloorSigil", 0.68, 0.68, 0.018, Vector3(0.0, 0.018, z), rune, 28)
		sigil.scale = Vector3(1.0, 1.0, 0.46)

	# Sparse rubble breaks perfect symmetry without turning the room into clutter.
	for rubble_value in [Vector3(-4.0,0.07,-5.4), Vector3(4.1,0.06,-0.8), Vector3(-3.9,0.06,2.2), Vector3(3.8,0.07,5.1), Vector3(-2.9,0.05,5.5), Vector3(2.8,0.05,-5.6)]:
		var rubble: Vector3 = rubble_value
		var rock := _add_box(production_details_root, "Rubble", Vector3(0.34, 0.18, 0.28), rubble, stone_edge)
		rock.rotation = Vector3(0.08, rubble.x * 0.17, 0.12)

func _add_brazier(pos: Vector3, metal: Material, flame_material: Material) -> void:
	var root := Node3D.new()
	root.name = "Brazier"
	root.position = pos
	production_details_root.add_child(root)
	_add_cylinder_local(root, "Stem", 0.10, 0.14, 0.62, Vector3(0.0, 0.31, 0.0), metal, 10)
	_add_cylinder_local(root, "Bowl", 0.34, 0.22, 0.14, Vector3(0.0, 0.66, 0.0), metal, 12)
	var flame := _add_sphere_local(root, "Flame", 0.17, Vector3(0.0, 0.86, 0.0), flame_material, 8, 4)
	flame.scale = Vector3(0.72, 1.55, 0.72)
	_add_omni_to(root, "FireLight", Vector3(0.0, 0.92, 0.0), Color("ff9d55"), 1.15, 2.65)

func _animate_room_details() -> void:
	if production_details_root == null:
		return
	var brazier_index := 0
	for child_value in production_details_root.get_children():
		var child := child_value as Node3D
		if child == null or child.name != "Brazier":
			continue
		var flame := child.get_node_or_null("Flame") as MeshInstance3D
		if flame != null:
			var pulse: float = 1.0 + sin(runtime_elapsed * 8.0 + float(brazier_index) * 1.7) * 0.10
			flame.scale = Vector3(0.72 * pulse, 1.55 + (pulse - 1.0) * 1.2, 0.72 * pulse)
		brazier_index += 1

func _add_cylinder_local(parent: Node, name_value: String, top_radius: float, bottom_radius: float, height: float, pos: Vector3, material: Material, radial: int) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = height
	mesh.radial_segments = radial
	var node := MeshInstance3D.new()
	node.name = name_value
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	parent.add_child(node)
	return node

func _add_sphere_local(parent: Node, name_value: String, radius: float, pos: Vector3, material: Material, radial: int, rings: int) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = radial
	mesh.rings = rings
	var node := MeshInstance3D.new()
	node.name = name_value
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	parent.add_child(node)
	return node

func _shadow_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.0, 0.0, 0.0, 0.34)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material

func _transparent_emissive(color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = energy
	return material
