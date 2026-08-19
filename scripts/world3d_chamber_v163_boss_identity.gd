extends "res://scripts/world3d_chamber_v163_projectile_identity.gd"

# ONE MORE FLOOR v1.63 r2 — boss presentation identity.
# Presentation-only replacement of the persistent inherited boss frame.
# Warden cast authority, r3.2 danger tells, projectile authority, damage/timing,
# hit radii, input and save/progression behavior remain inherited and untouched.

const V163_BOSS_IDENTITY_VERSION := "1.63-boss-identity-r2"

var v163_boss_anchor_mesh: ArrayMesh
var v163_boss_spire_mesh: ArrayMesh
var v163_boss_crown_mesh: ArrayMesh
var v163_boss_anchor_material: StandardMaterial3D
var v163_boss_spire_material: StandardMaterial3D
var v163_boss_crown_material: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_v163_install_boss_identity()

func production_boss_identity_ready() -> bool:
	if not production_projectile_identity_ready():
		return false
	if boss_root == null or boss_halo == null or boss_beam == null or boss_crown == null or boss_light == null:
		return false
	if boss_halo.mesh != v163_boss_anchor_mesh or boss_beam.mesh != v163_boss_spire_mesh:
		return false
	if boss_halo.mesh is TorusMesh or boss_beam.mesh is CylinderMesh:
		return false
	var shard_count := 0
	for value in boss_crown.get_children():
		var shard := value as MeshInstance3D
		if shard == null:
			continue
		if shard.mesh != v163_boss_crown_mesh or shard.mesh is BoxMesh:
			return false
		shard_count += 1
	return shard_count == 4

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["boss_identity_ready"] = production_boss_identity_ready()
	data["boss_identity_version"] = V163_BOSS_IDENTITY_VERSION
	data["boss_floor_language"] = "broken_anchors"
	data["boss_spire_language"] = "fractured_spire"
	data["boss_crown_language"] = "faceted_shards"
	data["boss_light_range"] = boss_light.omni_range if boss_light != null else -1.0
	return data

func _v163_install_boss_identity() -> void:
	if boss_halo == null or boss_beam == null or boss_crown == null or boss_light == null:
		return

	v163_boss_anchor_mesh = _v163_make_boss_anchor_mesh()
	v163_boss_spire_mesh = _v163_make_boss_spire_mesh()
	v163_boss_crown_mesh = _v163_make_crown_shard_mesh()
	v163_boss_anchor_material = _transparent_emissive(Color(1.0, 0.27, 0.18, 0.30), 2.05)
	v163_boss_spire_material = _transparent_emissive(Color(1.0, 0.44, 0.24, 0.20), 1.72)
	v163_boss_crown_material = _transparent_emissive(Color(1.0, 0.58, 0.30, 0.34), 2.20)

	boss_halo.mesh = v163_boss_anchor_mesh
	boss_halo.material_override = v163_boss_anchor_material
	boss_halo.set_meta("v163_boss_identity", "broken_anchors")

	boss_beam.mesh = v163_boss_spire_mesh
	boss_beam.material_override = v163_boss_spire_material
	boss_beam.set_meta("v163_boss_identity", "fractured_spire")

	var index := 0
	for value in boss_crown.get_children():
		var shard := value as MeshInstance3D
		if shard == null:
			continue
		var angle := TAU * float(index) / 4.0 + PI * 0.25
		shard.mesh = v163_boss_crown_mesh
		shard.material_override = v163_boss_crown_material
		shard.position = Vector3(cos(angle) * 0.26, sin(float(index) * 1.7) * 0.035, sin(angle) * 0.26)
		shard.rotation = Vector3(0.0, -angle, sin(angle) * 0.12)
		shard.scale = Vector3(0.88, 1.0 + (0.07 if index % 2 == 0 else -0.04), 0.88)
		shard.set_meta("v163_boss_identity", "crown_shard")
		index += 1

	boss_crown.position.y = 2.18
	boss_light.light_color = Color("ff7658")
	boss_light.omni_range = 3.15
	boss_light.light_energy = 0.72

func _animate_boss_frame() -> void:
	# Keep the inherited boss-root visibility/position and intro timer, but make
	# the decorative frame subordinate to gameplay-significant r3.2 tells.
	if boss_root == null or not boss_root.visible:
		return
	var intro_strength := clampf(boss_intro_timer / BOSS_INTRO_DURATION, 0.0, 1.0)
	var pulse := 1.0 + sin(runtime_elapsed * 3.6) * 0.025
	boss_halo.scale = Vector3(
		pulse * (0.94 + intro_strength * 0.08),
		1.0,
		pulse * (0.94 + intro_strength * 0.08)
	)
	boss_halo.rotation.y = runtime_elapsed * 0.18

	boss_beam.scale = Vector3(
		0.92 + intro_strength * 0.06,
		0.72 + intro_strength * 0.24,
		0.92 + intro_strength * 0.06
	)
	boss_beam.rotation.y = -runtime_elapsed * 0.20

	boss_crown.rotation.y = -runtime_elapsed * 0.38
	boss_crown.position.y = 2.18 + sin(runtime_elapsed * 2.9) * 0.035
	boss_light.light_energy = 0.68 + intro_strength * 0.82 + sin(runtime_elapsed * 4.2) * 0.055

func _v163_make_boss_anchor_mesh() -> ArrayMesh:
	# Four separated floor anchors + four smaller diagonal ticks. No continuous
	# perimeter exists, so the persistent boss identity cannot masquerade as a
	# radial danger tell.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(4):
		var angle := TAU * float(i) / 4.0
		var radial := Vector3(cos(angle), 0.0, sin(angle))
		var tangent := Vector3(-sin(angle), 0.0, cos(angle))
		_v163_add_floor_trapezoid(surface, radial, tangent, 0.57, 0.82, 0.075, 0.155, 0.0)
	for i in range(4):
		var angle := TAU * (float(i) + 0.5) / 4.0
		var radial := Vector3(cos(angle), 0.0, sin(angle))
		var tangent := Vector3(-sin(angle), 0.0, cos(angle))
		_v163_add_floor_trapezoid(surface, radial, tangent, 0.66, 0.80, 0.035, 0.075, 0.004)
	return surface.commit()

func _v163_add_floor_trapezoid(
	surface: SurfaceTool,
	radial: Vector3,
	tangent: Vector3,
	inner_radius: float,
	outer_radius: float,
	inner_half: float,
	outer_half: float,
	y: float
) -> void:
	var lift := Vector3(0.0, y, 0.0)
	var a := radial * inner_radius - tangent * inner_half + lift
	var b := radial * outer_radius - tangent * outer_half + lift
	var c := radial * outer_radius + tangent * outer_half + lift
	var d := radial * inner_radius + tangent * inner_half + lift
	_v163_add_double_quad(surface, a, b, c, d)

func _v163_make_boss_spire_mesh() -> ArrayMesh:
	# Three disconnected vertical crystals: enough intro presence to frame the
	# boss without the old opaque 2.75-high light column.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	_v163_add_vertical_shard(surface, Vector3(0.0, 0.0, 0.0), -0.58, 0.72, 0.065)
	_v163_add_vertical_shard(surface, Vector3(0.115, -0.02, 0.045), -0.42, 0.44, 0.042)
	_v163_add_vertical_shard(surface, Vector3(-0.105, 0.03, -0.055), -0.38, 0.50, 0.040)
	return surface.commit()

func _v163_make_crown_shard_mesh() -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	_v163_add_vertical_shard(surface, Vector3.ZERO, -0.18, 0.24, 0.062)
	return surface.commit()

func _v163_add_vertical_shard(surface: SurfaceTool, center: Vector3, bottom_y: float, top_y: float, width: float) -> void:
	var mid_y := lerpf(bottom_y, top_y, 0.47)
	var top := center + Vector3(0.0, top_y, 0.0)
	var bottom := center + Vector3(0.0, bottom_y, 0.0)
	var ring := [
		center + Vector3(width, mid_y, 0.0),
		center + Vector3(0.0, mid_y, width),
		center + Vector3(-width, mid_y, 0.0),
		center + Vector3(0.0, mid_y, -width),
	]
	for i in range(ring.size()):
		var a: Vector3 = ring[i]
		var b: Vector3 = ring[(i + 1) % ring.size()]
		_v163_add_double_triangle(surface, top, a, b)
		_v163_add_double_triangle(surface, bottom, b, a)

func _v163_add_double_quad(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	surface.add_vertex(a)
	surface.add_vertex(b)
	surface.add_vertex(c)
	surface.add_vertex(a)
	surface.add_vertex(c)
	surface.add_vertex(d)
	surface.add_vertex(c)
	surface.add_vertex(b)
	surface.add_vertex(a)
	surface.add_vertex(d)
	surface.add_vertex(c)
	surface.add_vertex(a)
