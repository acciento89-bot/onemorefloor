extends Node3D

# ONE MORE FLOOR 3D Lower Halls renderer.
# Gameplay authority remains in the proven 2D runtime; this layer mirrors that
# state into real 3D presentation. v1.40 replaces capsule placeholders with
# authored stylized actor silhouettes while keeping the synchronization API.

const ActorFactory = preload("res://scripts/world3d_actor_factory.gd")
const DESIGN_ARENA := Rect2(36.0, 160.0, 648.0, 840.0)
const WORLD_HALF_WIDTH := 4.65
const WORLD_HALF_DEPTH := 6.05
const MAX_ENEMIES := 18
const MAX_PLAYER_SHOTS := 28
const MAX_ENEMY_SHOTS := 36
const MAX_COINS := 24

var camera: Camera3D
var player_root: Node3D
var actor_factory := ActorFactory.new()
var enemy_pool: Array = []
var player_shot_pool: Array = []
var enemy_shot_pool: Array = []
var coin_pool: Array = []
var last_floor := -1
var runtime_elapsed := 0.0
var attack_amount := 0.0
var skill_amount := 0.0
var move_amount := 0.0
var actor_materials: Dictionary = {}

var mat_floor: StandardMaterial3D
var mat_wall: StandardMaterial3D
var mat_trim: StandardMaterial3D
var mat_gold: StandardMaterial3D
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
	actor_factory.animate_player(player_root, runtime_elapsed, move_amount, attack_amount, skill_amount)

func set_active(value: bool) -> void:
	process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED

func world_ready() -> bool:
	return camera != null and player_root != null and enemy_pool.size() == MAX_ENEMIES and bool(player_root.get_meta("authored_3d", false))

func authored_actor_ready() -> bool:
	return world_ready() and player_root.name == "Wanderer3D" and actor_factory.is_authored_enemy("goblin") and actor_factory.is_authored_enemy("warden")

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
	move_amount = clampf(joy.length(), 0.0, 1.0)
	if attack_flash > 0.0: attack_amount = 1.0
	if skill_flash > 0.0: skill_amount = 1.0
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
		"authored_actors": authored_actor_ready(),
		"enemy_pool": enemy_pool.size(),
		"player_shot_pool": player_shot_pool.size(),
		"enemy_shot_pool": enemy_shot_pool.size(),
		"coin_pool": coin_pool.size(),
		"player_position": player_root.position if player_root != null else Vector3.ZERO,
		"camera_projection": int(camera.projection) if camera != null else -1,
	}

func _build_materials() -> void:
	mat_floor = _material(Color("151820"), 0.10, 0.86)
	mat_wall = _material(Color("252631"), 0.18, 0.72)
	mat_trim = _material(Color("66596b"), 0.38, 0.42)
	mat_gold = _material(Color("d2a653"), 0.68, 0.28)
	mat_player_shot = _emissive_material(Color("ffd77a"), 1.8)
	mat_enemy_shot = _emissive_material(Color("a568ff"), 1.45)
	mat_coin = _emissive_material(Color("e2ae45"), 1.15)
	actor_materials = {
		"cloth": _material(Color("573570"), 0.12, 0.62),
		"cloth_dark": _material(Color("342044"), 0.10, 0.70),
		"dark": _material(Color("171823"), 0.16, 0.72),
		"black": _material(Color("08090f"), 0.08, 0.82),
		"skin": _material(Color("b98769"), 0.02, 0.88),
		"gold": mat_gold,
		"steel": _material(Color("7f8691"), 0.72, 0.32),
		"steel_bright": _material(Color("bbc3ce"), 0.82, 0.20),
		"steel_dark": _material(Color("434955"), 0.66, 0.38),
		"leather": _material(Color("5a3a2b"), 0.05, 0.82),
		"bone": _material(Color("c9c2ad"), 0.02, 0.86),
		"bone_dark": _material(Color("817b6e"), 0.05, 0.82),
		"goblin": _material(Color("72944f"), 0.04, 0.82),
		"goblin_dark": _material(Color("34482c"), 0.06, 0.82),
		"undead": _material(Color("7f8d71"), 0.04, 0.84),
		"undead_dark": _material(Color("3b4638"), 0.06, 0.82),
		"purple": _material(Color("755293"), 0.12, 0.62),
		"purple_dark": _material(Color("3d2c50"), 0.12, 0.68),
		"warden": _material(Color("704052"), 0.22, 0.55),
		"glow_gold": _emissive_material(Color("ffd26b"), 2.2),
		"glow_purple": _emissive_material(Color("a76cff"), 2.0),
		"glow_red": _emissive_material(Color("ff5868"), 2.0),
	}

func _build_environment() -> void:
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("04060b")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("77708e")
	env.ambient_light_energy = 0.34
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = env
	add_child(world_env)

	var key := DirectionalLight3D.new()
	key.name = "MoonKey"
	key.rotation_degrees = Vector3(-56.0, -28.0, 0.0)
	key.light_color = Color("c7c5e9")
	key.light_energy = 1.35
	key.shadow_enabled = true
	add_child(key)

	_add_omni("WarmTorchLight", Vector3(-3.75,2.25,0.8), Color("ffae62"), 4.2, 7.4, true)
	_add_omni("ArcaneLight", Vector3(3.8,2.1,-2.1), Color("9868ff"), 3.4, 7.0, false)

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
	_add_box(self,"Floor",Vector3(10.5,0.22,14.2),Vector3(0,-0.16,0),mat_floor)
	_add_box(self,"BackWall",Vector3(10.7,3.1,0.32),Vector3(0,1.38,-7.0),mat_wall)
	_add_box(self,"LeftWall",Vector3(0.32,2.0,14.2),Vector3(-5.22,0.84,0),mat_wall)
	_add_box(self,"RightWall",Vector3(0.32,2.0,14.2),Vector3(5.22,0.84,0),mat_wall)
	_add_box(self,"BackTrim",Vector3(10.2,0.16,0.42),Vector3(0,2.73,-6.82),mat_trim)

	# Repeating stone bays + inset metallic strips make the chamber feel built,
	# not like an empty prototype rectangle.
	for side in [-1.0,1.0]:
		for z in [-5.35,-1.85,1.65,5.15]:
			_add_pillar(Vector3(side*4.42,0,z))
	for z in [-4.5,-1.5,1.5,4.5]:
		_add_box(self,"FloorBand",Vector3(8.2,0.035,0.10),Vector3(0,-0.02,z),mat_trim)
	for x in [-3.35,-1.65,0.0,1.65,3.35]:
		_add_box(self,"FloorSeam",Vector3(0.045,0.028,12.0),Vector3(x,-0.015,0),_material(Color("34313a"),0.20,0.76))

	# Raised gate and side buttresses.
	_add_box(self,"GateLeft",Vector3(1.15,3.35,0.56),Vector3(-2.05,1.5,-6.52),mat_wall)
	_add_box(self,"GateRight",Vector3(1.15,3.35,0.56),Vector3(2.05,1.5,-6.52),mat_wall)
	_add_box(self,"GateHeader",Vector3(5.25,0.75,0.60),Vector3(0,2.95,-6.52),mat_trim)
	_add_box(self,"GateInset",Vector3(2.75,2.55,0.18),Vector3(0,1.2,-6.68),actor_materials["black"])
	for x in [-0.72,0.0,0.72]:
		_add_box(self,"GateBar",Vector3(0.09,2.20,0.12),Vector3(x,1.18,-6.78),mat_gold)
	_add_box(self,"Threshold",Vector3(3.4,0.16,0.80),Vector3(0,0.0,-6.20),mat_trim)

func _add_pillar(pos: Vector3) -> void:
	var root := Node3D.new()
	root.position = pos
	root.name = "Pillar"
	add_child(root)
	_add_box(root,"Base",Vector3(0.92,0.28,0.92),Vector3(0,0.02,0),mat_trim)
	_add_box(root,"Column",Vector3(0.62,2.65,0.62),Vector3(0,1.43,0),mat_wall)
	_add_box(root,"Cap",Vector3(0.90,0.24,0.90),Vector3(0,2.82,0),mat_trim)
	_add_box(root,"Rune",Vector3(0.20,0.45,0.03),Vector3(0,1.55,-0.325),mat_gold)
	_add_omni_to(root,"PillarLight",Vector3(0,2.25,0),Color("ff9c4a") if pos.x < 0.0 else Color("9060ff"),1.2,2.9)

func _build_player() -> void:
	player_root = actor_factory.create_player(actor_materials)
	add_child(player_root)

func _build_pools() -> void:
	for i in range(MAX_ENEMIES):
		var proxy := actor_factory.create_enemy_shell(i)
		enemy_pool.append(proxy)
		add_child(proxy)
		_set_actor_visible(proxy,false)

	var player_sphere := SphereMesh.new()
	player_sphere.radius=0.095; player_sphere.height=0.19; player_sphere.radial_segments=8; player_sphere.rings=4
	for i in range(MAX_PLAYER_SHOTS):
		var shot:=MeshInstance3D.new(); shot.name="PlayerShot%02d"%i; shot.mesh=player_sphere; shot.material_override=mat_player_shot; shot.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF; shot.visible=false; player_shot_pool.append(shot); add_child(shot)

	var enemy_sphere := SphereMesh.new()
	enemy_sphere.radius=0.105; enemy_sphere.height=0.21; enemy_sphere.radial_segments=8; enemy_sphere.rings=4
	for i in range(MAX_ENEMY_SHOTS):
		var shot:=MeshInstance3D.new(); shot.name="EnemyShot%02d"%i; shot.mesh=enemy_sphere; shot.material_override=mat_enemy_shot; shot.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF; shot.visible=false; enemy_shot_pool.append(shot); add_child(shot)

	var coin_mesh:=CylinderMesh.new(); coin_mesh.top_radius=0.16; coin_mesh.bottom_radius=0.16; coin_mesh.height=0.055; coin_mesh.radial_segments=12
	for i in range(MAX_COINS):
		var coin:=MeshInstance3D.new(); coin.name="Coin%02d"%i; coin.mesh=coin_mesh; coin.material_override=mat_coin; coin.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF; coin.visible=false; coin_pool.append(coin); add_child(coin)

func _sync_enemies(enemies: Array, player_world: Vector3) -> void:
	for i in range(enemy_pool.size()):
		var proxy:Node3D=enemy_pool[i]
		if i>=enemies.size():
			_set_actor_visible(proxy,false)
			continue
		var e:Dictionary=enemies[i]
		var kind:=String(e.get("type","enemy"))
		var variant:=String(e.get("boss_variant",""))
		var visual_kind:=variant if kind=="warden" and variant!="" else kind
		if kind=="warden" and not actor_factory.is_authored_enemy(visual_kind): visual_kind="warden"
		actor_factory.configure_enemy(proxy,visual_kind,actor_materials)
		_set_actor_visible(proxy,true)
		var p:=design_to_world(e.get("pos",DESIGN_ARENA.get_center()))
		proxy.position=p
		var radius:=float(e.get("radius",24.0))
		var scale_value:=clampf(radius/24.0,0.78,1.65)
		if kind=="warden": scale_value*=1.28
		if bool(e.get("elite",false)): scale_value*=1.08
		proxy.scale=Vector3.ONE*scale_value
		if p.distance_squared_to(player_world)>0.001: proxy.look_at(Vector3(player_world.x,p.y,player_world.z),Vector3.UP)
		var tell:=_enemy_tell(e)
		var hit_age:=runtime_elapsed-float(e.get("v47_hit_stamp",-99.0))
		var hit:=clampf(1.0-hit_age/0.16,0.0,1.0) if hit_age>=0.0 else 0.0
		actor_factory.animate_enemy(proxy,runtime_elapsed,float(e.get("phase",0.0)),tell,hit,i)

func _enemy_tell(e: Dictionary) -> float:
	var best:=99.0
	for key in ["attack_cd","dash_cd","dive_cd","blink_cd","lunge_cd","phase_cd","slam_cd","summon_cd","teleport_cd"]:
		var value:=float(e.get(key,0.0))
		if value>0.001: best=minf(best,value)
	if best==99.0 or best>0.34: return 0.0
	return clampf(1.0-best/0.34,0.0,1.0)

func _sync_projectiles(shots:Array,pool:Array,friendly:bool)->void:
	for i in range(pool.size()):
		var proxy:=pool[i] as MeshInstance3D
		if i>=shots.size(): proxy.visible=false; continue
		var shot:Dictionary=shots[i]
		proxy.visible=true
		proxy.position=design_to_world(shot.get("pos",DESIGN_ARENA.get_center()))+Vector3(0,0.42,0)
		var crit:=bool(shot.get("crit",false)) if friendly else false
		proxy.scale=Vector3.ONE*(1.55 if crit else 1.0)
		if not friendly:
			var c:Color=shot.get("color",Color("a568ff")); proxy.material_override=_emissive_material(c,1.35)

func _sync_coins(coins:Array)->void:
	for i in range(coin_pool.size()):
		var coin:=coin_pool[i] as MeshInstance3D
		if i>=coins.size(): coin.visible=false; continue
		coin.visible=true
		var orb:Dictionary=coins[i]
		coin.position=design_to_world(orb.get("pos",DESIGN_ARENA.get_center()))+Vector3(0,0.20+0.06*sin(runtime_elapsed*7.0+float(i)),0)
		coin.rotation.y=runtime_elapsed*3.2+float(i); coin.rotation.z=0.42

func _apply_floor_identity(floor_no:int)->void:
	var t:=clampf(float(maxi(1,floor_no)-1)/9.0,0.0,1.0)
	mat_floor.albedo_color=Color("151820").lerp(Color("231914"),t*0.34)
	mat_wall.albedo_color=Color("252631").lerp(Color("34261f"),t*0.22)

func _set_actor_visible(root:Node3D,value:bool)->void:
	root.visible=value

func _add_box(parent:Node,name_value:String,size:Vector3,pos:Vector3,material:Material)->MeshInstance3D:
	var mesh:=BoxMesh.new(); mesh.size=size
	var node:=MeshInstance3D.new(); node.name=name_value; node.mesh=mesh; node.position=pos; node.material_override=material; parent.add_child(node); return node

func _add_omni(name_value:String,pos:Vector3,color:Color,energy:float,range_value:float,shadows:bool)->void:
	var light:=OmniLight3D.new(); light.name=name_value; light.position=pos; light.light_color=color; light.light_energy=energy; light.omni_range=range_value; light.shadow_enabled=shadows; add_child(light)

func _add_omni_to(parent:Node,name_value:String,pos:Vector3,color:Color,energy:float,range_value:float)->void:
	var light:=OmniLight3D.new(); light.name=name_value; light.position=pos; light.light_color=color; light.light_energy=energy; light.omni_range=range_value; parent.add_child(light)

func _material(color:Color,metallic:float,roughness:float)->StandardMaterial3D:
	var material:=StandardMaterial3D.new(); material.albedo_color=color; material.metallic=metallic; material.roughness=roughness; return material

func _emissive_material(color:Color,energy:float)->StandardMaterial3D:
	var material:=_material(color,0.08,0.32); material.emission_enabled=true; material.emission=color; material.emission_energy_multiplier=energy; return material
