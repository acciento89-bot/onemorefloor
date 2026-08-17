extends Node3D

# First real 3D combat presentation for ONE MORE FLOOR.
# Gameplay still belongs to the proven 2D runtime. This node only mirrors the
# runtime's positions into a lightweight 3D chamber so movement/combat can be
# migrated incrementally without touching balance, save data or input geometry.

const DESIGN_ARENA := Rect2(36.0, 160.0, 648.0, 840.0)
const WORLD_HALF_WIDTH := 4.65
const WORLD_HALF_DEPTH := 6.05
const MAX_ENEMIES := 18
const MAX_PLAYER_SHOTS := 28
const MAX_ENEMY_SHOTS := 36
const MAX_COINS := 24

var camera: Camera3D
var player_root: Node3D
var enemy_pool: Array = []
var player_shot_pool: Array = []
var enemy_shot_pool: Array = []
var coin_pool: Array = []
var enemy_materials: Dictionary = {}
var last_floor := -1
var runtime_elapsed := 0.0
var attack_amount := 0.0
var skill_amount := 0.0

var mat_floor: StandardMaterial3D
var mat_wall: StandardMaterial3D
var mat_trim: StandardMaterial3D
var mat_gold: StandardMaterial3D
var mat_player: StandardMaterial3D
var mat_player_dark: StandardMaterial3D
var mat_player_skin: StandardMaterial3D
var mat_player_shot: StandardMaterial3D
var mat_enemy_shot: StandardMaterial3D
var mat_coin: StandardMaterial3D

func _ready() -> void:
	_build_materials()
	_build_environment()
	_build_chamber()
	_build_player()
	_build_pools()
	process_mode = Node.PROCESS_MODE_INHERIT

func _process(delta: float) -> void:
	if player_root == null:
		return
	attack_amount = maxf(0.0, attack_amount - delta * 6.5)
	skill_amount = maxf(0.0, skill_amount - delta * 4.0)
	var body := player_root.get_node_or_null("Body") as Node3D
	if body != null:
		body.position.y = 0.76 + sin(runtime_elapsed * 4.6) * 0.025
	var sword := player_root.get_node_or_null("Sword") as Node3D
	if sword != null:
		sword.rotation.z = -0.38 - attack_amount * 1.18
		sword.rotation.x = 0.12 + attack_amount * 0.24
	var skill_ring := player_root.get_node_or_null("SkillRing") as MeshInstance3D
	if skill_ring != null:
		skill_ring.visible = skill_amount > 0.01
		if skill_ring.visible:
			var s := 1.0 + (1.0 - skill_amount) * 2.6
			skill_ring.scale = Vector3(s, 1.0, s)

func set_active(value: bool) -> void:
	process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED

func world_ready() -> bool:
	return camera != null and player_root != null and enemy_pool.size() == MAX_ENEMIES

func design_to_world(pos: Vector2) -> Vector3:
	var nx := clampf((pos.x - DESIGN_ARENA.get_center().x) / (DESIGN_ARENA.size.x * 0.5), -1.12, 1.12)
	var nz := clampf((pos.y - DESIGN_ARENA.get_center().y) / (DESIGN_ARENA.size.y * 0.5), -1.12, 1.12)
	return Vector3(nx * WORLD_HALF_WIDTH, 0.0, nz * WORLD_HALF_DEPTH)

func sync_runtime(
	player_pos: Vector2,
	enemies: Array,
	player_shots: Array,
	enemy_shots: Array,
	coins: Array,
	joy: Vector2,
	elapsed_value: float,
	attack_flash: float,
	skill_flash: float,
	floor_no: int
) -> void:
	if not world_ready():
		return
	runtime_elapsed = elapsed_value
	if attack_flash > 0.0:
		attack_amount = 1.0
	if skill_flash > 0.0:
		skill_amount = 1.0
	if floor_no != last_floor:
		last_floor = floor_no
		_apply_floor_identity(floor_no)

	var player_world := design_to_world(player_pos)
	player_root.position = player_world
	if joy.length_squared() > 0.03:
		var facing := Vector3(joy.x, 0.0, joy.y)
		if facing.length_squared() > 0.001:
			player_root.look_at(player_world + facing.normalized(), Vector3.UP)

	_sync_enemies(enemies, player_world)
	_sync_projectiles(player_shots, player_shot_pool, true)
	_sync_projectiles(enemy_shots, enemy_shot_pool, false)
	_sync_coins(coins)

func debug_snapshot() -> Dictionary:
	return {
		"ready": world_ready(),
		"enemy_pool": enemy_pool.size(),
		"player_shot_pool": player_shot_pool.size(),
		"enemy_shot_pool": enemy_shot_pool.size(),
		"coin_pool": coin_pool.size(),
		"player_position": player_root.position if player_root != null else Vector3.ZERO,
		"camera_projection": int(camera.projection) if camera != null else -1,
	}

func _build_materials() -> void:
	mat_floor = _material(Color("171a22"), 0.08, 0.88)
	mat_wall = _material(Color("252632"), 0.16, 0.76)
	mat_trim = _material(Color("5b5166"), 0.34, 0.48)
	mat_gold = _material(Color("c89b4b"), 0.62, 0.32)
	mat_player = _material(Color("56356f"), 0.18, 0.58)
	mat_player_dark = _material(Color("171824"), 0.10, 0.78)
	mat_player_skin = _material(Color("b98667"), 0.02, 0.92)
	mat_player_shot = _emissive_material(Color("ffd77a"), 1.8)
	mat_enemy_shot = _emissive_material(Color("a568ff"), 1.45)
	mat_coin = _emissive_material(Color("e2ae45"), 1.15)

func _build_environment() -> void:
	var environment_node := WorldEnvironment.new()
	environment_node.name = "WorldEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("05070d")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("77708e")
	environment.ambient_light_energy = 0.38
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment_node.environment = environment
	add_child(environment_node)

	var key := DirectionalLight3D.new()
	key.name = "MoonKey"
	key.rotation_degrees = Vector3(-56.0, -28.0, 0.0)
	key.light_color = Color("c7c5e9")
	key.light_energy = 1.35
	key.shadow_enabled = true
	add_child(key)

	var warm := OmniLight3D.new()
	warm.name = "WarmTorchLight"
	warm.position = Vector3(-3.75, 2.25, 0.8)
	warm.light_color = Color("ffae62")
	warm.light_energy = 4.2
	warm.omni_range = 7.4
	warm.shadow_enabled = true
	add_child(warm)

	var arcane := OmniLight3D.new()
	arcane.name = "ArcaneLight"
	arcane.position = Vector3(3.8, 2.1, -2.1)
	arcane.light_color = Color("9868ff")
	arcane.light_energy = 3.4
	arcane.omni_range = 7.0
	add_child(arcane)

	camera = Camera3D.new()
	camera.name = "IsometricCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 15.8
	camera.near = 0.2
	camera.far = 60.0
	camera.position = Vector3(0.0, 10.8, 9.6)
	add_child(camera)
	camera.look_at(Vector3(0.0, 0.0, -0.25), Vector3.UP)
	camera.current = true

func _build_chamber() -> void:
	_add_box("Floor", Vector3(10.5, 0.22, 14.2), Vector3(0.0, -0.16, 0.0), mat_floor)
	_add_box("BackWall", Vector3(10.7, 3.1, 0.32), Vector3(0.0, 1.38, -7.0), mat_wall)
	_add_box("LeftWall", Vector3(0.32, 2.0, 14.2), Vector3(-5.22, 0.84, 0.0), mat_wall)
	_add_box("RightWall", Vector3(0.32, 2.0, 14.2), Vector3(5.22, 0.84, 0.0), mat_wall)
	_add_box("BackTrim", Vector3(10.2, 0.16, 0.42), Vector3(0.0, 2.73, -6.82), mat_trim)

	for side in [-1.0, 1.0]:
		for z in [-5.35, -1.85, 1.65, 5.15]:
			_add_pillar(Vector3(side * 4.42, 0.0, z))

	# Raised gate structure at the far end gives the camera a real destination.
	_add_box("GateLeft", Vector3(1.15, 3.35, 0.56), Vector3(-2.05, 1.5, -6.52), mat_wall)
	_add_box("GateRight", Vector3(1.15, 3.35, 0.56), Vector3(2.05, 1.5, -6.52), mat_wall)
	_add_box("GateHeader", Vector3(5.25, 0.75, 0.60), Vector3(0.0, 2.95, -6.52), mat_trim)
	_add_box("GateInset", Vector3(2.75, 2.55, 0.18), Vector3(0.0, 1.2, -6.68), mat_player_dark)

	# A few metallic floor strips make the perspective immediately readable.
	for z in [-4.5, -1.5, 1.5, 4.5]:
		_add_box("FloorBand", Vector3(8.2, 0.035, 0.10), Vector3(0.0, -0.02, z), mat_trim)

func _add_pillar(pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	root.name = "Pillar"
	add_child(root)
	_add_box_to(root, "Base", Vector3(0.92, 0.28, 0.92), Vector3(0.0, 0.02, 0.0), mat_trim)
	_add_box_to(root, "Column", Vector3(0.62, 2.65, 0.62), Vector3(0.0, 1.43, 0.0), mat_wall)
	_add_box_to(root, "Cap", Vector3(0.90, 0.24, 0.90), Vector3(0.0, 2.82, 0.0), mat_trim)
	var ember := OmniLight3D.new()
	ember.position = Vector3(0.0, 2.25, 0.0)
	ember.light_color = Color("ff9c4a") if pos.x < 0.0 else Color("9060ff")
	ember.light_energy = 1.35
	ember.omni_range = 3.0
	root.add_child(ember)

func _build_player() -> void:
	player_root = Node3D.new()
	player_root.name = "PlayerProxy"
	add_child(player_root)

	var body_root := Node3D.new()
	body_root.name = "Body"
	body_root.position.y = 0.76
	player_root.add_child(body_root)

	var cloak_mesh := CapsuleMesh.new()
	cloak_mesh.radius = 0.34
	cloak_mesh.height = 1.18
	cloak_mesh.radial_segments = 12
	cloak_mesh.rings = 5
	var cloak := MeshInstance3D.new()
	cloak.name = "Cloak"
	cloak.mesh = cloak_mesh
	cloak.material_override = mat_player
	body_root.add_child(cloak)

	var chest_mesh := BoxMesh.new()
	chest_mesh.size = Vector3(0.58, 0.52, 0.34)
	var chest := MeshInstance3D.new()
	chest.name = "Armor"
	chest.mesh = chest_mesh
	chest.position = Vector3(0.0, 0.12, -0.10)
	chest.material_override = mat_player_dark
	body_root.add_child(chest)

	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.235
	head_mesh.height = 0.47
	head_mesh.radial_segments = 12
	head_mesh.rings = 6
	var head := MeshInstance3D.new()
	head.name = "Head"
	head.mesh = head_mesh
	head.position = Vector3(0.0, 0.73, 0.0)
	head.material_override = mat_player_skin
	body_root.add_child(head)

	var hood_mesh := SphereMesh.new()
	hood_mesh.radius = 0.285
	hood_mesh.height = 0.56
	hood_mesh.radial_segments = 12
	hood_mesh.rings = 5
	var hood := MeshInstance3D.new()
	hood.name = "Hood"
	hood.mesh = hood_mesh
	hood.position = Vector3(0.0, 0.78, 0.08)
	hood.scale = Vector3(1.0, 1.08, 0.86)
	hood.material_override = mat_player_dark
	body_root.add_child(hood)
	# Face remains slightly forward of the hood shell.
	head.position.z = -0.18

	var sword_root := Node3D.new()
	sword_root.name = "Sword"
	sword_root.position = Vector3(0.48, 0.88, -0.30)
	player_root.add_child(sword_root)
	var blade_mesh := BoxMesh.new()
	blade_mesh.size = Vector3(0.085, 0.085, 0.96)
	var blade := MeshInstance3D.new()
	blade.mesh = blade_mesh
	blade.position = Vector3(0.0, 0.0, -0.35)
	blade.material_override = mat_gold
	sword_root.add_child(blade)
	var hilt_mesh := BoxMesh.new()
	hilt_mesh.size = Vector3(0.42, 0.08, 0.10)
	var hilt := MeshInstance3D.new()
	hilt.mesh = hilt_mesh
	hilt.material_override = mat_trim
	sword_root.add_child(hilt)

	var skill_mesh := CylinderMesh.new()
	skill_mesh.top_radius = 0.72
	skill_mesh.bottom_radius = 0.72
	skill_mesh.height = 0.025
	skill_mesh.radial_segments = 36
	var skill_ring := MeshInstance3D.new()
	skill_ring.name = "SkillRing"
	skill_ring.mesh = skill_mesh
	skill_ring.position = Vector3(0.0, 0.02, 0.0)
	skill_ring.material_override = _emissive_material(Color("8f62ff"), 0.95)
	skill_ring.visible = false
	player_root.add_child(skill_ring)

func _build_pools() -> void:
	for i in range(MAX_ENEMIES):
		var proxy := _make_enemy_proxy(i)
		enemy_pool.append(proxy)
		add_child(proxy)
		_set_enemy_visible(proxy, false)

	var player_sphere := SphereMesh.new()
	player_sphere.radius = 0.095
	player_sphere.height = 0.19
	player_sphere.radial_segments = 8
	player_sphere.rings = 4
	for i in range(MAX_PLAYER_SHOTS):
		var shot := MeshInstance3D.new()
		shot.name = "PlayerShot%02d" % i
		shot.mesh = player_sphere
		shot.material_override = mat_player_shot
		shot.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		shot.visible = false
		player_shot_pool.append(shot)
		add_child(shot)

	var enemy_sphere := SphereMesh.new()
	enemy_sphere.radius = 0.105
	enemy_sphere.height = 0.21
	enemy_sphere.radial_segments = 8
	enemy_sphere.rings = 4
	for i in range(MAX_ENEMY_SHOTS):
		var shot := MeshInstance3D.new()
		shot.name = "EnemyShot%02d" % i
		shot.mesh = enemy_sphere
		shot.material_override = mat_enemy_shot
		shot.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		shot.visible = false
		enemy_shot_pool.append(shot)
		add_child(shot)

	var coin_mesh := CylinderMesh.new()
	coin_mesh.top_radius = 0.16
	coin_mesh.bottom_radius = 0.16
	coin_mesh.height = 0.055
	coin_mesh.radial_segments = 12
	for i in range(MAX_COINS):
		var coin := MeshInstance3D.new()
		coin.name = "Coin%02d" % i
		coin.mesh = coin_mesh
		coin.material_override = mat_coin
		coin.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		coin.visible = false
		coin_pool.append(coin)
		add_child(coin)

func _make_enemy_proxy(index: int) -> Node3D:
	var root := Node3D.new()
	root.name = "EnemyProxy%02d" % index
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.31
	body_mesh.height = 1.02
	body_mesh.radial_segments = 10
	body_mesh.rings = 4
	var body := MeshInstance3D.new()
	body.name = "Body"
	body.mesh = body_mesh
	body.position = Vector3(0.0, 0.57, 0.0)
	body.material_override = _enemy_material("default")
	root.add_child(body)

	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.225
	head_mesh.height = 0.45
	head_mesh.radial_segments = 10
	head_mesh.rings = 5
	var head := MeshInstance3D.new()
	head.name = "Head"
	head.mesh = head_mesh
	head.position = Vector3(0.0, 1.23, -0.03)
	head.material_override = body.material_override
	root.add_child(head)

	var weapon_mesh := BoxMesh.new()
	weapon_mesh.size = Vector3(0.08, 0.08, 0.68)
	var weapon := MeshInstance3D.new()
	weapon.name = "Weapon"
	weapon.mesh = weapon_mesh
	weapon.position = Vector3(0.38, 0.72, -0.18)
	weapon.rotation_degrees = Vector3(0.0, 0.0, -18.0)
	weapon.material_override = mat_trim
	root.add_child(weapon)
	return root

func _sync_enemies(enemies: Array, player_world: Vector3) -> void:
	for i in range(enemy_pool.size()):
		var proxy: Node3D = enemy_pool[i]
		if i >= enemies.size():
			_set_enemy_visible(proxy, false)
			continue
		var e: Dictionary = enemies[i]
		_set_enemy_visible(proxy, true)
		var p := design_to_world(e.get("pos", DESIGN_ARENA.get_center()))
		proxy.position = p
		var kind := String(e.get("type", "enemy"))
		var variant := String(e.get("boss_variant", ""))
		var visual_kind := variant if kind == "warden" and variant != "" else kind
		var material := _enemy_material(visual_kind)
		var body := proxy.get_node("Body") as MeshInstance3D
		var head := proxy.get_node("Head") as MeshInstance3D
		body.material_override = material
		head.material_override = material
		var radius := float(e.get("radius", 24.0))
		var scale_value := clampf(radius / 24.0, 0.78, 1.65)
		if kind == "warden":
			scale_value *= 1.28
		if bool(e.get("elite", false)):
			scale_value *= 1.08
		proxy.scale = Vector3.ONE * scale_value
		if p.distance_squared_to(player_world) > 0.001:
			proxy.look_at(Vector3(player_world.x, p.y, player_world.z), Vector3.UP)
		proxy.position.y = sin(runtime_elapsed * 3.1 + float(i) * 0.9) * 0.025

func _sync_projectiles(shots: Array, pool: Array, friendly: bool) -> void:
	for i in range(pool.size()):
		var proxy := pool[i] as MeshInstance3D
		if i >= shots.size():
			proxy.visible = false
			continue
		var shot: Dictionary = shots[i]
		proxy.visible = true
		proxy.position = design_to_world(shot.get("pos", DESIGN_ARENA.get_center())) + Vector3(0.0, 0.42, 0.0)
		var crit := bool(shot.get("crit", false)) if friendly else false
		var size := 1.55 if crit else 1.0
		proxy.scale = Vector3.ONE * size
		if not friendly:
			var c: Color = shot.get("color", Color("a568ff"))
			proxy.material_override = _emissive_material(c, 1.35)

func _sync_coins(coins: Array) -> void:
	for i in range(coin_pool.size()):
		var coin := coin_pool[i] as MeshInstance3D
		if i >= coins.size():
			coin.visible = false
			continue
		coin.visible = true
		var orb: Dictionary = coins[i]
		coin.position = design_to_world(orb.get("pos", DESIGN_ARENA.get_center())) + Vector3(0.0, 0.20 + 0.06 * sin(runtime_elapsed * 7.0 + float(i)), 0.0)
		coin.rotation.y = runtime_elapsed * 3.2 + float(i)
		coin.rotation.z = 0.42

func _apply_floor_identity(floor_no: int) -> void:
	# Phase 1 covers the Lower Halls. Subtle warmth increases toward floor 10 so
	# even placeholder geometry already communicates climbing through a place.
	var t := clampf(float(maxi(1, floor_no) - 1) / 9.0, 0.0, 1.0)
	mat_floor.albedo_color = Color("171a22").lerp(Color("231914"), t * 0.34)
	mat_wall.albedo_color = Color("252632").lerp(Color("34261f"), t * 0.22)

func _enemy_material(kind: String) -> StandardMaterial3D:
	if enemy_materials.has(kind):
		return enemy_materials[kind]
	var color := Color("8f765f")
	match kind:
		"goblin", "ghoul": color = Color("66834f")
		"bat": color = Color("695184")
		"skeleton": color = Color("bdb7a4")
		"necromancer", "hexer": color = Color("71508d")
		"gargoyle", "sentinel": color = Color("77808d")
		"warden": color = Color("8d4b69")
		"crypt_keeper", "hollow_king": color = Color("76508e")
		_: pass
	var material := _material(color, 0.18, 0.68)
	enemy_materials[kind] = material
	return material

func _add_box(name_value: String, size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	return _add_box_to(self, name_value, size, pos, material)

func _add_box_to(parent: Node, name_value: String, size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = name_value
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	parent.add_child(node)
	return node

func _set_enemy_visible(root: Node3D, value: bool) -> void:
	for child in root.get_children():
		if child is GeometryInstance3D:
			(child as GeometryInstance3D).visible = value

func _material(color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = roughness
	return material

func _emissive_material(color: Color, energy: float) -> StandardMaterial3D:
	var material := _material(color, 0.08, 0.32)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material
