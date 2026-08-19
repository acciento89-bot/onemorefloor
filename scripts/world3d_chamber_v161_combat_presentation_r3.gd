extends "res://scripts/world3d_chamber_v161_combat_presentation_r22.gd"

# ONE MORE FLOOR v1.61 r3 — grounding + loot language pass.
# Replaces the remaining secondary prototype circles under enemies and pickups
# while preserving danger telegraphs, loot values, pools, triggers and gameplay.

const COMBAT_PRESENTATION_R3_VERSION := "1.61-combat-presentation-r3"

var v161_enemy_ground_mesh: ArrayMesh
var v161_loot_floor_mesh: ArrayMesh
var v161_loot_shard_mesh: ArrayMesh
var v161_ground_neutral_material: StandardMaterial3D
var v161_ground_arcane_material: StandardMaterial3D
var v161_ground_elite_material: StandardMaterial3D
var v161_loot_glint_material: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_upgrade_v161_grounding_and_loot()

func production_combat_presentation_ready() -> bool:
	return super.production_combat_presentation_ready() and _v161_ground_loot_ready()

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["combat_presentation_v161_version"] = COMBAT_PRESENTATION_R3_VERSION
	data["combat_presentation_v161_ground_anchors"] = _v161_enemy_ground_ready()
	data["combat_presentation_v161_loot_glints"] = _v161_loot_ready()
	return data

func _upgrade_v161_grounding_and_loot() -> void:
	v161_ground_neutral_material = _transparent_emissive(Color("8a8395", 0.070), 0.18)
	v161_ground_arcane_material = _transparent_emissive(Color("8b72aa", 0.085), 0.24)
	v161_ground_elite_material = _transparent_emissive(Color("b46e62", 0.095), 0.30)
	v161_loot_glint_material = _transparent_emissive(Color("ffe6a6", 0.26), 1.34)
	for material_value in [v161_ground_neutral_material, v161_ground_arcane_material, v161_ground_elite_material, v161_loot_glint_material]:
		var material := material_value as StandardMaterial3D
		if material != null:
			material.cull_mode = BaseMaterial3D.CULL_DISABLED

	v161_enemy_ground_mesh = _build_v161_ground_anchor()
	for value in enemy_grounding_pool:
		var ground := value as MeshInstance3D
		if ground == null:
			continue
		ground.mesh = v161_enemy_ground_mesh
		ground.material_override = v161_ground_neutral_material
		ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	v161_loot_floor_mesh = _build_v161_impact_burst(4, 0.045, 0.30, 0.052, 0.014)
	v161_loot_shard_mesh = _build_v161_loot_shard()
	for value in loot_marker_pool:
		var marker := value as Node3D
		if marker == null:
			continue
		var beam := marker.get_node_or_null("Beam") as MeshInstance3D
		if beam != null:
			beam.mesh = v161_loot_shard_mesh
			beam.material_override = v161_loot_glint_material
			beam.position = Vector3(0.0, 0.30, 0.0)
			beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var floor_glow := marker.get_node_or_null("FloorGlow") as MeshInstance3D
		if floor_glow != null:
			floor_glow.mesh = v161_loot_floor_mesh
			floor_glow.material_override = v161_loot_glint_material
			floor_glow.position = Vector3(0.0, 0.045, 0.0)
			floor_glow.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _sync_actor_grounding(enemies: Array) -> void:
	super._sync_actor_grounding(enemies)
	for index in range(enemy_grounding_pool.size()):
		var ground := enemy_grounding_pool[index] as MeshInstance3D
		if ground == null or not ground.visible:
			continue
		var kind := ""
		var elite := false
		if index < enemies.size():
			var enemy: Dictionary = enemies[index]
			kind = String(enemy.get("type", ""))
			elite = bool(enemy.get("elite", false)) or kind == "warden"
		if elite:
			ground.material_override = v161_ground_elite_material
		elif kind == "necromancer" or kind == "bat":
			ground.material_override = v161_ground_arcane_material
		else:
			ground.material_override = v161_ground_neutral_material
		var scale_factor := 0.72 if elite else 0.64
		ground.scale = Vector3(ground.scale.x * scale_factor, 1.0, ground.scale.z * scale_factor)
		ground.rotation.y = runtime_elapsed * (0.055 if elite else -0.035)
		ground.position.y = maxf(ground.position.y, 0.040)

func _v161_ground_loot_ready() -> bool:
	return _v161_enemy_ground_ready() and _v161_loot_ready()

func _v161_enemy_ground_ready() -> bool:
	if enemy_grounding_pool.is_empty():
		return false
	var ground := enemy_grounding_pool[0] as MeshInstance3D
	return ground != null and ground.mesh is ArrayMesh

func _v161_loot_ready() -> bool:
	if loot_marker_pool.is_empty():
		return false
	var marker := loot_marker_pool[0] as Node3D
	if marker == null:
		return false
	var beam := marker.get_node_or_null("Beam") as MeshInstance3D
	var floor_glow := marker.get_node_or_null("FloorGlow") as MeshInstance3D
	return beam != null and beam.mesh is ArrayMesh and floor_glow != null and floor_glow.mesh is ArrayMesh

func _build_v161_ground_anchor() -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(4):
		var angle := TAU * float(index) / 4.0 + PI * 0.25
		var radial := Vector3(sin(angle), 0.0, -cos(angle))
		var tangent := Vector3(cos(angle), 0.0, sin(angle))
		var inner_center := radial * 0.18
		var outer_center := radial * (0.42 if index % 2 == 0 else 0.36)
		var inner_left := inner_center - tangent * 0.060
		var inner_right := inner_center + tangent * 0.060
		var outer_left := outer_center - tangent * 0.020
		var outer_right := outer_center + tangent * 0.020
		_v161_add_quad(tool, inner_left, outer_left, outer_right, inner_right)
	return tool.commit()

func _build_v161_loot_shard() -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var top := Vector3(0.0, 0.30, 0.0)
	var bottom := Vector3(0.0, -0.24, 0.0)
	var right := Vector3(0.085, 0.025, 0.0)
	var left := Vector3(-0.085, 0.025, 0.0)
	_r3_add_triangle(tool, top, right, bottom)
	_r3_add_triangle(tool, top, bottom, left)
	var front := Vector3(0.0, 0.025, 0.085)
	var back := Vector3(0.0, 0.025, -0.085)
	_r3_add_triangle(tool, top, front, bottom)
	_r3_add_triangle(tool, top, bottom, back)
	return tool.commit()

func _r3_add_triangle(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	var normal := (b - a).cross(c - a).normalized()
	if normal.length_squared() < 0.001:
		normal = Vector3.UP
	for point in [a, b, c]:
		tool.set_normal(normal)
		tool.add_vertex(point)
