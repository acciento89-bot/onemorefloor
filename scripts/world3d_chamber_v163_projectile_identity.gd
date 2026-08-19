extends "res://scripts/world3d_chamber_v161_combat_presentation_r32.gd"

# ONE MORE FLOOR v1.63 r1 — projectile / trail identity.
# Presentation-only layer over the accepted v1.61 r3.2 combat world. The pooled
# v1.51 projectile collision authority, shot dictionaries, timing, damage,
# targeting, hit radii and lifetime remain inherited and untouched.

const V163_PROJECTILE_IDENTITY_VERSION := "1.63-projectile-identity-r1"

var v163_player_head_mesh: ArrayMesh
var v163_enemy_head_mesh: ArrayMesh
var v163_player_trail_mesh: ArrayMesh
var v163_enemy_trail_mesh: ArrayMesh
var v163_enemy_trail_material_cache: Dictionary = {}

func _ready() -> void:
	super._ready()
	_v163_install_projectile_identity()

func production_projectile_identity_ready() -> bool:
	if not production_combat_presentation_ready():
		return false
	if projectile_authority == null or not projectile_authority.has_method("projectile_authority_ready"):
		return false
	if not bool(projectile_authority.call("projectile_authority_ready")):
		return false
	if player_shot_pool.is_empty() or enemy_shot_pool.is_empty():
		return false
	if player_trail_pool.is_empty() or enemy_trail_pool.is_empty():
		return false
	var player_head := player_shot_pool[0] as MeshInstance3D
	var enemy_head := enemy_shot_pool[0] as MeshInstance3D
	var player_trail := player_trail_pool[0] as MeshInstance3D
	var enemy_trail := enemy_trail_pool[0] as MeshInstance3D
	return player_head != null \
		and enemy_head != null \
		and player_trail != null \
		and enemy_trail != null \
		and player_head.mesh == v163_player_head_mesh \
		and enemy_head.mesh == v163_enemy_head_mesh \
		and player_trail.mesh == v163_player_trail_mesh \
		and enemy_trail.mesh == v163_enemy_trail_mesh

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["projectile_identity_ready"] = production_projectile_identity_ready()
	data["projectile_identity_version"] = V163_PROJECTILE_IDENTITY_VERSION
	data["player_projectile_shape"] = "blade_shard"
	data["enemy_projectile_shape"] = "thorn_dart"
	data["trail_shape"] = "tapered_prism"
	data["collision_authority_preserved"] = projectile_authority != null and bool(projectile_authority.call("projectile_authority_ready"))
	return data

func _v163_install_projectile_identity() -> void:
	v163_player_head_mesh = _v163_make_player_head_mesh()
	v163_enemy_head_mesh = _v163_make_enemy_head_mesh()
	v163_player_trail_mesh = _v163_make_tapered_trail_mesh(0.048, 0.010, 0.016, 0.004)
	v163_enemy_trail_mesh = _v163_make_tapered_trail_mesh(0.041, 0.008, 0.026, 0.006)

	for value in player_shot_pool:
		var shot := value as MeshInstance3D
		if shot == null:
			continue
		shot.mesh = v163_player_head_mesh
		shot.set_meta("v163_projectile_identity", "blade_shard")

	for value in enemy_shot_pool:
		var shot := value as MeshInstance3D
		if shot == null:
			continue
		shot.mesh = v163_enemy_head_mesh
		shot.set_meta("v163_projectile_identity", "thorn_dart")

	var player_trail_material := _transparent_emissive(Color(1.0, 0.78, 0.30, 0.48), 2.10)
	for value in player_trail_pool:
		var trail := value as MeshInstance3D
		if trail == null:
			continue
		trail.mesh = v163_player_trail_mesh
		trail.material_override = player_trail_material
		trail.set_meta("v163_projectile_identity", "blade_wake")

	for value in enemy_trail_pool:
		var trail := value as MeshInstance3D
		if trail == null:
			continue
		trail.mesh = v163_enemy_trail_mesh
		trail.set_meta("v163_projectile_identity", "thorn_wake")

func _sync_projectiles(shots: Array, pool: Array, friendly: bool) -> void:
	# The inherited sync remains authoritative for position, active slots, crit
	# scale, history and trail length. v1.63 only aligns the new visible head to
	# that already-computed direction and gives hostile wakes their shot color.
	super._sync_projectiles(shots, pool, friendly)
	var trails: Array = player_trail_pool if friendly else enemy_trail_pool
	if trails.is_empty():
		return

	var count: int = mini(shots.size(), pool.size())
	for i in range(count):
		var projectile := pool[i] as MeshInstance3D
		var trail := trails[i] as MeshInstance3D
		if projectile == null or trail == null or not projectile.visible:
			continue
		if trail.visible:
			projectile.rotation = trail.rotation
		if not friendly and trail.visible:
			var shot: Dictionary = shots[i]
			var shot_color: Color = shot.get("color", Color("a568ff"))
			trail.material_override = _v163_enemy_trail_material(shot_color)

func _v163_enemy_trail_material(color: Color) -> StandardMaterial3D:
	var key: String = color.to_html(false)
	if not v163_enemy_trail_material_cache.has(key):
		v163_enemy_trail_material_cache[key] = _transparent_emissive(
			Color(color.r, color.g, color.b, 0.40),
			1.82
		)
	return v163_enemy_trail_material_cache[key] as StandardMaterial3D

func _v163_make_player_head_mesh() -> ArrayMesh:
	# Flat forged blade shard: long axis is local -Z, matching Node3D.look_at().
	# The small Y thickness keeps it blade-like rather than another glowing orb.
	var tip := Vector3(0.0, 0.0, -0.255)
	var tail := Vector3(0.0, 0.0, 0.135)
	var top := Vector3(0.0, 0.030, -0.030)
	var right := Vector3(0.078, 0.0, -0.030)
	var bottom := Vector3(0.0, -0.030, -0.030)
	var left := Vector3(-0.078, 0.0, -0.030)
	return _v163_make_bipyramid(tip, tail, [top, right, bottom, left])

func _v163_make_enemy_head_mesh() -> ArrayMesh:
	# Chunkier hostile thorn: visibly wider/deeper than the player blade while
	# retaining the runtime-provided hostile color on the existing material path.
	var tip := Vector3(0.0, 0.0, -0.220)
	var tail := Vector3(0.0, 0.0, 0.115)
	var top := Vector3(0.0, 0.078, -0.010)
	var right := Vector3(0.095, 0.0, -0.010)
	var bottom := Vector3(0.0, -0.078, -0.010)
	var left := Vector3(-0.095, 0.0, -0.010)
	return _v163_make_bipyramid(tip, tail, [top, right, bottom, left])

func _v163_make_bipyramid(tip: Vector3, tail: Vector3, ring: Array) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(ring.size()):
		var a: Vector3 = ring[i]
		var b: Vector3 = ring[(i + 1) % ring.size()]
		_v163_add_double_triangle(surface, tip, a, b)
		_v163_add_double_triangle(surface, tail, b, a)
	surface.generate_normals()
	return surface.commit()

func _v163_make_tapered_trail_mesh(head_half_width: float, tail_half_width: float, head_half_height: float, tail_half_height: float) -> ArrayMesh:
	# Existing v1.41 history scales this mesh along local Z. -Z is the current
	# projectile/head side, +Z the fading history/tail side.
	var half_length: float = TRAIL_LENGTH * 0.5
	var f0 := Vector3(-head_half_width, -head_half_height, -half_length)
	var f1 := Vector3(head_half_width, -head_half_height, -half_length)
	var f2 := Vector3(head_half_width, head_half_height, -half_length)
	var f3 := Vector3(-head_half_width, head_half_height, -half_length)
	var b0 := Vector3(-tail_half_width, -tail_half_height, half_length)
	var b1 := Vector3(tail_half_width, -tail_half_height, half_length)
	var b2 := Vector3(tail_half_width, tail_half_height, half_length)
	var b3 := Vector3(-tail_half_width, tail_half_height, half_length)

	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	_v163_add_quad(surface, f0, f1, f2, f3)
	_v163_add_quad(surface, b1, b0, b3, b2)
	_v163_add_quad(surface, f1, b1, b2, f2)
	_v163_add_quad(surface, b0, f0, f3, b3)
	_v163_add_quad(surface, f3, f2, b2, b3)
	_v163_add_quad(surface, b0, b1, f1, f0)
	surface.generate_normals()
	return surface.commit()

func _v163_add_quad(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	surface.add_vertex(a)
	surface.add_vertex(b)
	surface.add_vertex(c)
	surface.add_vertex(a)
	surface.add_vertex(c)
	surface.add_vertex(d)

func _v163_add_double_triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	surface.add_vertex(a)
	surface.add_vertex(b)
	surface.add_vertex(c)
	surface.add_vertex(c)
	surface.add_vertex(b)
	surface.add_vertex(a)
