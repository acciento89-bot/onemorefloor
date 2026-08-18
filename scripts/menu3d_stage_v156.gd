class_name Menu3DStageV156
extends Node3D

const WANDERER_ASSET := "res://assets/models/actors/wanderer.gltf"
const MENU_SCREENS := ["home", "hero", "forge", "talents", "vault", "missions", "pass", "store"]

var camera: Camera3D
var environment_node: WorldEnvironment
var stage_root: Node3D
var actor_anchor: Node3D
var current_screen := ""
var elapsed := 0.0
var actor_model: Node3D
var actor_animation: AnimationPlayer

var mat_void: StandardMaterial3D
var mat_stone: StandardMaterial3D
var mat_stone_hi: StandardMaterial3D
var mat_gold: StandardMaterial3D
var mat_purple: StandardMaterial3D
var mat_blue: StandardMaterial3D
var mat_green: StandardMaterial3D
var mat_orange: StandardMaterial3D
var mat_red: StandardMaterial3D
var mat_dark_metal: StandardMaterial3D

func _ready() -> void:
	_build_materials()
	_build_world()
	set_screen("home")

func _process(delta: float) -> void:
	elapsed += delta
	if camera == null:
		return
	var base := _camera_position_for(current_screen)
	camera.position = base + Vector3(sin(elapsed * 0.23) * 0.07, sin(elapsed * 0.17) * 0.035, 0.0)
	camera.look_at(_camera_target_for(current_screen), Vector3.UP)
	if actor_anchor != null and actor_anchor.visible:
		actor_anchor.rotation.y = PI + sin(elapsed * 0.31) * 0.035

func set_screen(screen: String) -> void:
	if screen == current_screen and stage_root != null:
		return
	if screen not in MENU_SCREENS:
		return
	current_screen = screen
	_rebuild_stage()

func stage_ready() -> bool:
	return camera != null \
		and environment_node != null \
		and stage_root != null \
		and actor_anchor != null \
		and current_screen in MENU_SCREENS

func debug_snapshot() -> Dictionary:
	return {
		"ready": stage_ready(),
		"screen": current_screen,
		"stage_children": stage_root.get_child_count() if stage_root != null else 0,
		"actor_present": actor_model != null,
		"actor_animation": String(actor_animation.current_animation) if actor_animation != null else "",
		"camera": camera.position if camera != null else Vector3.ZERO,
	}

func _build_materials() -> void:
	mat_void = _material(Color("050712"), 0.0, 0.96)
	mat_stone = _material(Color("171b2a"), 0.04, 0.78)
	mat_stone_hi = _material(Color("343b52"), 0.12, 0.60)
	mat_gold = _material(Color("b9852f"), 0.74, 0.26, Color("ffb83e"), 0.25)
	mat_purple = _material(Color("4b2588"), 0.12, 0.42, Color("8c4cff"), 0.95)
	mat_blue = _material(Color("173e6e"), 0.18, 0.40, Color("2f8fff"), 0.70)
	mat_green = _material(Color("174936"), 0.10, 0.52, Color("38e88e"), 0.62)
	mat_orange = _material(Color("78351c"), 0.08, 0.46, Color("ff702f"), 1.25)
	mat_red = _material(Color("651d2d"), 0.08, 0.50, Color("ff3f63"), 0.70)
	mat_dark_metal = _material(Color("111722"), 0.72, 0.30)

func _build_world() -> void:
	environment_node = WorldEnvironment.new()
	environment_node.name = "MenuWorldEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("03040b")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("433963")
	env.ambient_light_energy = 0.48
	environment_node.environment = env
	add_child(environment_node)

	camera = Camera3D.new()
	camera.name = "MenuCamera"
	camera.fov = 39.0
	camera.near = 0.08
	camera.far = 80.0
	add_child(camera)
	camera.current = true

	var moon := DirectionalLight3D.new()
	moon.name = "MoonKey"
	moon.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	moon.light_color = Color("a990ff")
	moon.light_energy = 1.35
	moon.shadow_enabled = true
	add_child(moon)

	var rim := DirectionalLight3D.new()
	rim.name = "WarmRim"
	rim.rotation_degrees = Vector3(-32.0, 152.0, 0.0)
	rim.light_color = Color("ffd276")
	rim.light_energy = 0.72
	add_child(rim)

	stage_root = Node3D.new()
	stage_root.name = "StageRoot"
	add_child(stage_root)

func _rebuild_stage() -> void:
	if stage_root == null:
		return
	for child in stage_root.get_children():
		stage_root.remove_child(child)
		child.free()
	actor_anchor = null
	actor_model = null
	actor_animation = null

	_build_common_floor()
	match current_screen:
		"home": _build_home_stage()
		"hero": _build_hero_stage()
		"forge": _build_forge_stage()
		"talents": _build_talents_stage()
		"vault": _build_vault_stage()
		"missions": _build_missions_stage()
		"pass": _build_pass_stage()
		"store": _build_store_stage()
		_: _build_home_stage()
	camera.position = _camera_position_for(current_screen)
	camera.look_at(_camera_target_for(current_screen), Vector3.UP)

func _build_common_floor() -> void:
	_make_box(stage_root, "Floor", Vector3(11.0, 0.20, 10.0), mat_stone, Vector3(0.0, -0.12, 0.2))
	_make_box(stage_root, "BackWall", Vector3(10.5, 7.2, 0.32), mat_void, Vector3(0.0, 3.35, -3.1))
	for x in [-4.4, 4.4]:
		_make_box(stage_root, "SideColumn", Vector3(0.55, 6.4, 0.62), mat_stone_hi, Vector3(x, 2.95, -2.72))
		_make_box(stage_root, "ColumnCap", Vector3(0.86, 0.34, 0.86), mat_gold, Vector3(x, 6.05, -2.72))

func _build_home_stage() -> void:
	# Real 3D citadel facade replacing the flat Home illustration.
	_make_box(stage_root, "Keep", Vector3(5.7, 4.8, 1.2), mat_stone, Vector3(0.0, 2.55, -2.25))
	for x in [-3.25, 3.25]:
		_make_box(stage_root, "Tower", Vector3(1.45, 5.8, 1.45), mat_stone_hi, Vector3(x, 2.95, -2.1))
		for tooth in range(3):
			_make_box(stage_root, "Crenel", Vector3(0.34, 0.45, 1.55), mat_stone_hi, Vector3(x - 0.43 + tooth * 0.43, 6.05, -2.1))
	for x in [-1.75, -0.88, 0.0, 0.88, 1.75]:
		_make_box(stage_root, "KeepCrenel", Vector3(0.42, 0.52, 1.30), mat_stone_hi, Vector3(x, 5.18, -2.25))

	_make_box(stage_root, "GateVoid", Vector3(1.9, 3.25, 1.24), mat_void, Vector3(0.0, 1.52, -1.56))
	_make_box(stage_root, "GateTop", Vector3(2.55, 0.55, 1.35), mat_dark_metal, Vector3(0.0, 3.23, -1.57))
	for x in [-2.0, 2.0]:
		_make_box(stage_root, "Banner", Vector3(0.62, 2.35, 0.08), mat_red, Vector3(x, 2.25, -1.54))
		_make_box(stage_root, "BannerSigil", Vector3(0.28, 0.46, 0.11), mat_gold, Vector3(x, 2.32, -1.47), Vector3(0.0, 0.0, deg_to_rad(45.0)))

	for x in [-2.75, 2.75]:
		_add_torch(Vector3(x, 1.05, -0.92), Color("ff9c46"), 3.2)
	for x in [-1.15, 1.15]:
		_add_torch(Vector3(x, 3.92, -1.58), Color("c56dff"), 2.2)

	_make_box(stage_root, "Bridge", Vector3(4.4, 0.28, 4.8), mat_stone_hi, Vector3(0.0, 0.02, 0.05))
	_add_actor(Vector3(0.0, 0.26, 0.80), 1.16)

func _build_hero_stage() -> void:
	_make_cylinder(stage_root, "HeroDais", 1.65, 0.42, mat_dark_metal, Vector3(0.0, 0.20, 0.40))
	_make_cylinder(stage_root, "HeroRing", 1.38, 0.08, mat_purple, Vector3(0.0, 0.46, 0.40))
	for x in [-2.65, 2.65]:
		_make_box(stage_root, "HeroPillar", Vector3(0.72, 4.9, 0.72), mat_stone_hi, Vector3(x, 2.40, -1.58))
		_add_torch(Vector3(x, 3.62, -1.10), Color("8d52ff"), 2.8)
	for y in [1.6, 2.7, 3.8]:
		_make_box(stage_root, "RuneBar", Vector3(4.4 - y * 0.42, 0.035, 0.04), mat_purple, Vector3(0.0, y, -2.88))
	_add_actor(Vector3(0.0, 0.56, 0.40), 1.55)

func _build_forge_stage() -> void:
	_make_box(stage_root, "ForgeWall", Vector3(7.2, 4.6, 0.7), mat_stone, Vector3(0.0, 2.45, -2.42))
	_make_box(stage_root, "Furnace", Vector3(2.1, 2.8, 1.25), mat_dark_metal, Vector3(-2.45, 1.38, -1.72))
	_make_box(stage_root, "FurnaceGlow", Vector3(1.25, 1.35, 0.12), mat_orange, Vector3(-2.45, 1.22, -1.02))
	_make_box(stage_root, "AnvilTop", Vector3(1.65, 0.34, 0.68), mat_dark_metal, Vector3(1.15, 1.08, 0.06))
	_make_box(stage_root, "AnvilStem", Vector3(0.54, 1.15, 0.52), mat_dark_metal, Vector3(1.15, 0.55, 0.06))
	for x in [-3.7, -2.45, -1.25]:
		_add_torch(Vector3(x, 3.28, -1.28), Color("ff6f2f"), 3.6)
	for i in range(5):
		_make_box(stage_root, "Weapon%d" % i, Vector3(0.08, 1.55, 0.08), mat_gold if i % 2 == 0 else mat_stone_hi, Vector3(2.4 + i * 0.36, 1.52, -1.45), Vector3(0.0, 0.0, -0.18 + i * 0.09))

func _build_talents_stage() -> void:
	_make_cylinder(stage_root, "ArcaneDais", 2.1, 0.30, mat_dark_metal, Vector3(0.0, 0.15, 0.20))
	for i in range(8):
		var a := TAU * float(i) / 8.0
		var p := Vector3(cos(a) * 2.5, 1.45 + 0.35 * sin(a * 2.0), -0.40 + sin(a) * 1.3)
		_make_box(stage_root, "Rune%d" % i, Vector3(0.20, 0.58, 0.08), mat_purple if i % 2 == 0 else mat_blue, p, Vector3(0.0, 0.0, a))
	_add_torch(Vector3(-3.2, 2.0, -1.2), Color("8c4cff"), 2.6)
	_add_torch(Vector3(3.2, 2.0, -1.2), Color("2f8fff"), 2.6)

func _build_vault_stage() -> void:
	_make_box(stage_root, "VaultDoor", Vector3(4.4, 4.4, 0.62), mat_dark_metal, Vector3(0.0, 2.38, -2.32))
	_make_cylinder(stage_root, "VaultHub", 0.82, 0.28, mat_gold, Vector3(0.0, 2.35, -1.92), Vector3(PI * 0.5, 0.0, 0.0))
	for x in [-2.85, -1.35, 1.35, 2.85]:
		_make_box(stage_root, "Chest", Vector3(1.05, 0.76, 0.82), mat_gold if abs(x) < 2.0 else mat_stone_hi, Vector3(x, 0.42, -0.55))
		_make_box(stage_root, "ChestLid", Vector3(1.12, 0.20, 0.90), mat_dark_metal, Vector3(x, 0.86, -0.55))
	_add_torch(Vector3(-3.4, 2.6, -1.35), Color("ffc75a"), 3.0)
	_add_torch(Vector3(3.4, 2.6, -1.35), Color("ffc75a"), 3.0)

func _build_missions_stage() -> void:
	_make_box(stage_root, "MissionTable", Vector3(5.6, 0.34, 2.9), mat_stone_hi, Vector3(0.0, 0.88, -0.25))
	for x in [-1.8, 0.0, 1.8]:
		_make_box(stage_root, "MapPanel", Vector3(1.28, 1.9, 0.12), mat_green, Vector3(x, 2.42, -2.70), Vector3(0.0, 0.0, x * 0.035))
	_add_torch(Vector3(-3.45, 2.2, -1.2), Color("56f0a3"), 2.5)
	_add_torch(Vector3(3.45, 2.2, -1.2), Color("56f0a3"), 2.5)

func _build_pass_stage() -> void:
	_make_box(stage_root, "PassStairA", Vector3(6.4, 0.35, 1.2), mat_stone, Vector3(0.0, 0.18, 1.3))
	_make_box(stage_root, "PassStairB", Vector3(5.3, 0.35, 1.2), mat_stone_hi, Vector3(0.0, 0.54, 0.55))
	_make_box(stage_root, "PassStairC", Vector3(4.2, 0.35, 1.2), mat_dark_metal, Vector3(0.0, 0.90, -0.2))
	for x in [-1.8, 0.0, 1.8]:
		_make_box(stage_root, "Relic", Vector3(0.30, 1.25, 0.30), mat_gold if x == 0.0 else mat_purple, Vector3(x, 2.05, -1.72), Vector3(0.0, 0.0, deg_to_rad(45.0)))
	_add_torch(Vector3(-3.2, 2.8, -1.15), Color("d27cff"), 2.5)
	_add_torch(Vector3(3.2, 2.8, -1.15), Color("ffd15d"), 2.5)

func _build_store_stage() -> void:
	for x in [-2.6, 0.0, 2.6]:
		_make_cylinder(stage_root, "StoreDais", 0.92, 0.34, mat_dark_metal, Vector3(x, 0.17, -0.2))
		_make_box(stage_root, "StoreRelic", Vector3(0.48, 1.25, 0.48), mat_gold if x == 0.0 else mat_purple, Vector3(x, 1.22, -0.2), Vector3(0.0, elapsed, deg_to_rad(45.0)))
	for x in [-3.3, 3.3]:
		_add_torch(Vector3(x, 2.7, -1.30), Color("ffc65a"), 3.0)

func _add_actor(pos: Vector3, scale_value: float) -> void:
	actor_anchor = Node3D.new()
	actor_anchor.name = "WandererShowcase"
	actor_anchor.position = pos
	actor_anchor.rotation.y = PI
	stage_root.add_child(actor_anchor)
	var packed := load(WANDERER_ASSET) as PackedScene
	if packed == null:
		return
	actor_model = packed.instantiate() as Node3D
	if actor_model == null:
		return
	actor_model.name = "ImportedWanderer"
	actor_model.scale = Vector3.ONE * scale_value
	actor_anchor.add_child(actor_model)
	actor_animation = _find_animation_player(actor_model)
	if actor_animation != null and actor_animation.has_animation("Idle"):
		actor_animation.play("Idle")

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null

func _add_torch(pos: Vector3, color: Color, energy: float) -> void:
	_make_box(stage_root, "TorchBracket", Vector3(0.12, 0.42, 0.12), mat_dark_metal, pos + Vector3(0.0, -0.22, 0.0))
	var flame_mat := _material(Color(color, 1.0), 0.0, 0.28, color, 2.8)
	_make_sphere(stage_root, "Flame", 0.16, flame_mat, pos)
	var light := OmniLight3D.new()
	light.name = "TorchLight"
	light.position = pos
	light.light_color = color
	light.light_energy = energy
	light.omni_range = 4.8
	light.shadow_enabled = false
	stage_root.add_child(light)

func _camera_position_for(screen: String) -> Vector3:
	match screen:
		"hero": return Vector3(0.0, 2.85, 7.2)
		"forge": return Vector3(0.0, 3.0, 8.5)
		"vault": return Vector3(0.0, 2.9, 8.3)
		_: return Vector3(0.0, 3.25, 9.6)

func _camera_target_for(screen: String) -> Vector3:
	match screen:
		"hero": return Vector3(0.0, 1.75, 0.1)
		"forge": return Vector3(0.0, 1.75, -0.5)
		_: return Vector3(0.0, 2.05, -0.55)

func _material(color: Color, metallic: float, roughness: float, emission: Color = Color.BLACK, emission_energy: float = 0.0) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.metallic = metallic
	mat.roughness = roughness
	if emission_energy > 0.0:
		mat.emission_enabled = true
		mat.emission = emission
		mat.emission_energy_multiplier = emission_energy
	return mat

func _make_box(parent: Node3D, node_name: String, size: Vector3, material: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.rotation = rot
	parent.add_child(instance)
	return instance

func _make_cylinder(parent: Node3D, node_name: String, radius: float, height: float, material: Material, pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 32
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.rotation = rot
	parent.add_child(instance)
	return instance

func _make_sphere(parent: Node3D, node_name: String, radius: float, material: Material, pos: Vector3) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 18
	mesh.rings = 10
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	parent.add_child(instance)
	return instance
