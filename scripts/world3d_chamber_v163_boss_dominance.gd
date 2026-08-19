extends "res://scripts/world3d_chamber_v163_boss_identity.gd"

# ONE MORE FLOOR v1.63 r2.1 — active boss-dominance correction.
# r2 correctly cleaned the older v1.46 boss frame, but screenshot review proved
# the dominant circular language actually comes from v1.49 BossDominanceLookdev.
# This layer changes only that persistent decorative lookdev. Warden casts,
# r3.2 danger tells, projectile authority and gameplay math remain inherited.

const V163_BOSS_DOMINANCE_VERSION := "1.63-boss-dominance-r2.1"

var v163_dominance_outer_mesh: ArrayMesh
var v163_dominance_inner_mesh: ArrayMesh
var v163_dominance_marker_mesh: ArrayMesh
var v163_dominance_outer_material: StandardMaterial3D
var v163_dominance_inner_material: StandardMaterial3D
var v163_dominance_marker_material: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_v163_install_boss_dominance_identity()

func production_boss_dominance_ready() -> bool:
	if not production_boss_identity_ready():
		return false
	if boss_dominance_root == null or boss_dominance_ring_outer == null or boss_dominance_ring_inner == null or boss_dominance_light == null:
		return false
	if boss_dominance_ring_outer.mesh != v163_dominance_outer_mesh:
		return false
	if boss_dominance_ring_inner.mesh != v163_dominance_inner_mesh:
		return false
	if boss_dominance_ring_outer.mesh is TorusMesh or boss_dominance_ring_inner.mesh is TorusMesh:
		return false
	var marker_count := 0
	var visible_marker_count := 0
	for value in boss_dominance_root.get_children():
		var marker := value as MeshInstance3D
		if marker == null or not String(marker.name).begins_with("DominanceMark"):
			continue
		marker_count += 1
		if marker.visible:
			visible_marker_count += 1
		if marker.mesh != v163_dominance_marker_mesh or marker.mesh is BoxMesh:
			return false
	return marker_count == 8 and visible_marker_count == 4

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["boss_dominance_ready"] = production_boss_dominance_ready()
	data["boss_dominance_version"] = V163_BOSS_DOMINANCE_VERSION
	data["boss_dominance_outer"] = "four_open_brackets"
	data["boss_dominance_inner"] = "four_inward_chevrons"
	data["boss_dominance_visible_markers"] = 4
	data["boss_dominance_light_range"] = boss_dominance_light.omni_range if boss_dominance_light != null else -1.0
	return data

func _v163_install_boss_dominance_identity() -> void:
	if boss_dominance_root == null or boss_dominance_ring_outer == null or boss_dominance_ring_inner == null or boss_dominance_light == null:
		return

	v163_dominance_outer_mesh = _v163_make_dominance_outer_mesh()
	v163_dominance_inner_mesh = _v163_make_dominance_inner_mesh()
	v163_dominance_marker_mesh = _v163_make_dominance_marker_mesh()
	v163_dominance_outer_material = _transparent_emissive(Color(1.0, 0.25, 0.18, 0.17), 1.15)
	v163_dominance_inner_material = _transparent_emissive(Color(1.0, 0.46, 0.26, 0.13), 0.92)
	v163_dominance_marker_material = _transparent_emissive(Color(1.0, 0.58, 0.34, 0.21), 1.38)

	boss_dominance_ring_outer.mesh = v163_dominance_outer_mesh
	boss_dominance_ring_outer.material_override = v163_dominance_outer_material
	boss_dominance_ring_outer.set_meta("v163_boss_dominance", "open_brackets")

	boss_dominance_ring_inner.mesh = v163_dominance_inner_mesh
	boss_dominance_ring_inner.material_override = v163_dominance_inner_material
	boss_dominance_ring_inner.set_meta("v163_boss_dominance", "inward_chevrons")

	var marker_index := 0
	for value in boss_dominance_root.get_children():
		var marker := value as MeshInstance3D
		if marker == null or not String(marker.name).begins_with("DominanceMark"):
			continue
		marker.mesh = v163_dominance_marker_mesh
		marker.material_override = v163_dominance_marker_material
		var keep_visible := marker_index % 2 == 0
		marker.visible = keep_visible
		var angle := TAU * float(marker_index) / 8.0
		marker.position = Vector3(cos(angle) * 0.91, 0.095, sin(angle) * 0.91)
		marker.rotation = Vector3(0.0, -angle, 0.0)
		marker.scale = Vector3.ONE * (0.78 if keep_visible else 0.001)
		marker.set_meta("v163_boss_dominance", "signature_shard")
		marker_index += 1

	boss_dominance_light.light_color = Color("ff7658")
	boss_dominance_light.omni_range = 2.85
	boss_dominance_light.light_energy = 0.42

func _animate_boss_dominance() -> void:
	if boss_dominance_root == null or not boss_dominance_root.visible:
		if boss_dominance_light != null:
			boss_dominance_light.light_energy = 0.0
		return
	var pulse := 1.0 + sin(runtime_elapsed * 3.2) * 0.018
	if boss_dominance_ring_outer != null:
		boss_dominance_ring_outer.scale = Vector3(pulse, 1.0, pulse)
		boss_dominance_ring_outer.rotation.y = runtime_elapsed * 0.075
	if boss_dominance_ring_inner != null:
		boss_dominance_ring_inner.scale = Vector3(1.0 + (pulse - 1.0) * 0.45, 1.0, 1.0 + (pulse - 1.0) * 0.45)
		boss_dominance_ring_inner.rotation.y = -runtime_elapsed * 0.095
	boss_dominance_root.rotation.y = sin(runtime_elapsed * 0.82) * 0.018
	if boss_dominance_light != null:
		boss_dominance_light.light_energy = 0.40 + sin(runtime_elapsed * 3.7) * 0.055

func _v163_make_dominance_outer_mesh() -> ArrayMesh:
	# Four open L-like floor brackets. Each quadrant has a radial foot and short
	# tangent cap, but there is no arc connecting one quadrant to another.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(4):
		var angle := TAU * float(i) / 4.0
		var radial := Vector3(cos(angle), 0.0, sin(angle))
		var tangent := Vector3(-sin(angle), 0.0, cos(angle))
		_v163_add_floor_trapezoid(surface, radial, tangent, 0.73, 1.02, 0.045, 0.105, 0.0)
		var cap_center := radial * 0.98
		var a := cap_center - tangent * 0.18 - radial * 0.045
		var b := cap_center + tangent * 0.18 - radial * 0.045
		var c := cap_center + tangent * 0.18 + radial * 0.045
		var d := cap_center - tangent * 0.18 + radial * 0.045
		_v163_add_double_quad(surface, a, b, c, d)
	return surface.commit()

func _v163_make_dominance_inner_mesh() -> ArrayMesh:
	# Four small inward chevrons at diagonal bearings. Their silhouette is a set
	# of pointers toward the Warden, not a closed or dashed perimeter.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(4):
		var angle := TAU * (float(i) + 0.5) / 4.0
		var radial := Vector3(cos(angle), 0.0, sin(angle))
		var tangent := Vector3(-sin(angle), 0.0, cos(angle))
		var tip := radial * 0.47
		var back := radial * 0.66
		var left := back - tangent * 0.095
		var right := back + tangent * 0.095
		_v163_add_double_triangle(surface, tip, left, right)
	return surface.commit()

func _v163_make_dominance_marker_mesh() -> ArrayMesh:
	# Tiny faceted floor shard. Four of the inherited eight marker nodes remain
	# visible; the other four stay structurally present but visually suppressed.
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var tip := Vector3(0.0, 0.10, -0.11)
	var tail := Vector3(0.0, 0.018, 0.08)
	var left := Vector3(-0.045, 0.025, 0.015)
	var right := Vector3(0.045, 0.025, 0.015)
	_v163_add_double_triangle(surface, tip, left, right)
	_v163_add_double_triangle(surface, tail, right, left)
	return surface.commit()
