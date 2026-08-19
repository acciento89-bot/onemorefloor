extends "res://scripts/world3d_chamber_v160_atmosphere.gd"

# ONE MORE FLOOR v1.61 — combat presentation upgrade.
# Presentation-only layer on top of the fully validated v1.60 milestone.
# Replaces the visible "neon tube / flat fan" read with mobile-safe authored
# ribbon and segmented-wave geometry. Gameplay timing, radii, hitboxes,
# targeting, saves, input and the v1.60 actor/environment baselines stay inherited.

const COMBAT_PRESENTATION_VERSION := "1.61-combat-presentation-r1.1"

var v161_attack_trail: MeshInstance3D
var v161_attack_hot_edge: MeshInstance3D
var v161_attack_contact: MeshInstance3D
var v161_skill_wave_outer: MeshInstance3D
var v161_skill_wave_inner: MeshInstance3D
var v161_skill_runes: MeshInstance3D

var v161_attack_trail_material: StandardMaterial3D
var v161_attack_hot_material: StandardMaterial3D
var v161_attack_contact_material: StandardMaterial3D
var v161_skill_wave_material: StandardMaterial3D
var v161_skill_inner_material: StandardMaterial3D
var v161_skill_rune_material: StandardMaterial3D
var v161_enemy_tell_material: StandardMaterial3D
var v161_warden_tell_material: StandardMaterial3D

var v161_enemy_tell_mesh: ArrayMesh
var v161_head_rune_mesh: ArrayMesh
var v161_warden_shock_mesh: ArrayMesh

func _ready() -> void:
	super._ready()
	_build_v161_combat_materials()
	_build_v161_player_presentation()
	_upgrade_v161_enemy_presentation()
	_sync_v161_combat_presentation()

func _process(delta: float) -> void:
	super._process(delta)
	_sync_v161_combat_presentation()

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
	super.sync_runtime(
		player_pos, enemies, player_shots, enemy_shots, coins, joy,
		elapsed_value, attack_flash, skill_flash, floor_no
	)
	_apply_v161_enemy_presentation(enemies)
	_sync_v161_combat_presentation()

func production_combat_presentation_ready() -> bool:
	var tell_ready := not telegraph_pool.is_empty() \
		and telegraph_pool[0] is MeshInstance3D \
		and (telegraph_pool[0] as MeshInstance3D).mesh is ArrayMesh
	var shock_ready := false
	if not enemy_vfx_slots.is_empty():
		var slot := enemy_vfx_slots[0] as Node3D
		var shock: MeshInstance3D = null
		if slot != null:
			shock = slot.get_node_or_null("Shockwave0") as MeshInstance3D
		shock_ready = shock != null and shock.mesh is ArrayMesh
	return production_atmosphere_ready() \
		and v161_attack_trail != null \
		and v161_attack_trail.mesh is ArrayMesh \
		and v161_attack_hot_edge != null \
		and v161_attack_hot_edge.mesh is ArrayMesh \
		and v161_attack_contact != null \
		and v161_attack_contact.mesh is ArrayMesh \
		and v161_skill_wave_outer != null \
		and v161_skill_wave_outer.mesh is ArrayMesh \
		and v161_skill_wave_inner != null \
		and v161_skill_wave_inner.mesh is ArrayMesh \
		and v161_skill_runes != null \
		and v161_skill_runes.mesh is ArrayMesh \
		and tell_ready \
		and shock_ready

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["combat_presentation_v161_ready"] = production_combat_presentation_ready()
	data["combat_presentation_v161_version"] = COMBAT_PRESENTATION_VERSION
	data["combat_presentation_v161_attack_ribbon"] = v161_attack_trail != null
	data["combat_presentation_v161_skill_wave"] = v161_skill_wave_outer != null and v161_skill_wave_inner != null
	data["combat_presentation_v161_segmented_tells"] = not telegraph_pool.is_empty() \
		and telegraph_pool[0] is MeshInstance3D \
		and (telegraph_pool[0] as MeshInstance3D).mesh is ArrayMesh
	return data

func _build_v161_combat_materials() -> void:
	v161_attack_trail_material = _transparent_emissive(Color("e3ad55", 0.24), 0.68)
	v161_attack_trail_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	v161_attack_hot_material = _transparent_emissive(Color("fff2bd", 0.78), 1.62)
	v161_attack_hot_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	v161_attack_contact_material = _transparent_emissive(Color("d8893f", 0.14), 0.42)
	v161_attack_contact_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	v161_skill_wave_material = _transparent_emissive(Color("8f63d2", 0.28), 0.74)
	v161_skill_wave_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	v161_skill_inner_material = _transparent_emissive(Color("c7a5ff", 0.22), 0.62)
	v161_skill_inner_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	v161_skill_rune_material = _transparent_emissive(Color("e2d2ff", 0.54), 1.06)
	v161_skill_rune_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	v161_enemy_tell_material = _transparent_emissive(Color("e96c58", 0.24), 0.54)
	v161_enemy_tell_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	v161_warden_tell_material = _transparent_emissive(Color("ff4d43", 0.32), 0.72)
	v161_warden_tell_material.cull_mode = BaseMaterial3D.CULL_DISABLED

func _build_v161_player_presentation() -> void:
	if player_root == null:
		return

	v161_attack_trail = MeshInstance3D.new()
	v161_attack_trail.name = "V161AttackBladeTrail"
	v161_attack_trail.mesh = _build_v161_blade_ribbon(1.30, 0.30, -0.88, 0.88, 36, 0.08, 0.26)
	v161_attack_trail.material_override = v161_attack_trail_material
	v161_attack_trail.position = Vector3(0.0, 0.22, -0.40)
	v161_attack_trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	v161_attack_trail.visible = false
	player_root.add_child(v161_attack_trail)

	v161_attack_hot_edge = MeshInstance3D.new()
	v161_attack_hot_edge.name = "V161AttackHotEdge"
	v161_attack_hot_edge.mesh = _build_v161_blade_ribbon(1.48, 0.065, -0.86, 0.86, 38, 0.17, 0.33)
	v161_attack_hot_edge.material_override = v161_attack_hot_material
	v161_attack_hot_edge.position = Vector3(0.0, 0.24, -0.40)
	v161_attack_hot_edge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	v161_attack_hot_edge.visible = false
	player_root.add_child(v161_attack_hot_edge)

	v161_attack_contact = MeshInstance3D.new()
	v161_attack_contact.name = "V161AttackGroundContact"
	v161_attack_contact.mesh = _build_v161_arc_strip(1.18, 1.38, -0.84, 0.84, 28)
	v161_attack_contact.material_override = v161_attack_contact_material
	v161_attack_contact.position = Vector3(0.0, 0.075, -0.36)
	v161_attack_contact.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	v161_attack_contact.visible = false
	player_root.add_child(v161_attack_contact)

	v161_skill_wave_outer = MeshInstance3D.new()
	v161_skill_wave_outer.name = "V161SkillWaveOuter"
	v161_skill_wave_outer.mesh = _build_v161_segmented_ring(1.46, 1.64, 14, 0.48)
	v161_skill_wave_outer.material_override = v161_skill_wave_material
	v161_skill_wave_outer.position = Vector3(0.0, 0.085, 0.0)
	v161_skill_wave_outer.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	v161_skill_wave_outer.visible = false
	player_root.add_child(v161_skill_wave_outer)

	v161_skill_wave_inner = MeshInstance3D.new()
	v161_skill_wave_inner.name = "V161SkillWaveInner"
	v161_skill_wave_inner.mesh = _build_v161_segmented_ring(0.90, 1.02, 10, 0.42)
	v161_skill_wave_inner.material_override = v161_skill_inner_material
	v161_skill_wave_inner.position = Vector3(0.0, 0.105, 0.0)
	v161_skill_wave_inner.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	v161_skill_wave_inner.visible = false
	player_root.add_child(v161_skill_wave_inner)

	v161_skill_runes = MeshInstance3D.new()
	v161_skill_runes.name = "V161SkillRunes"
	v161_skill_runes.mesh = _build_v161_radial_runes(8, 1.20, 0.075, 0.21)
	v161_skill_runes.material_override = v161_skill_rune_material
	v161_skill_runes.position = Vector3(0.0, 0.135, 0.0)
	v161_skill_runes.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	v161_skill_runes.visible = false
	player_root.add_child(v161_skill_runes)

func _upgrade_v161_enemy_presentation() -> void:
	v161_enemy_tell_mesh = _build_v161_segmented_ring(0.54, 0.68, 12, 0.46)
	v161_head_rune_mesh = _build_v161_segmented_ring(0.27, 0.33, 8, 0.44)
	v161_warden_shock_mesh = _build_v161_segmented_ring(0.62, 0.76, 14, 0.42)

	for value in telegraph_pool:
		var tell := value as MeshInstance3D
		if tell == null:
			continue
		tell.mesh = v161_enemy_tell_mesh
		tell.material_override = v161_enemy_tell_material
		tell.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	for value in enemy_vfx_slots:
		var slot := value as Node3D
		if slot == null:
			continue
		var head_rune := slot.get_node_or_null("HeadRune") as MeshInstance3D
		if head_rune != null:
			head_rune.mesh = v161_head_rune_mesh
		for wave_index in range(3):
			var wave := slot.get_node_or_null("Shockwave%d" % wave_index) as MeshInstance3D
			if wave != null:
				wave.mesh = v161_warden_shock_mesh
				wave.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _apply_v161_enemy_presentation(enemies: Array) -> void:
	for index in range(telegraph_pool.size()):
		var tell := telegraph_pool[index] as MeshInstance3D
		if tell == null:
			continue
		var kind := ""
		if index < enemies.size():
			var enemy: Dictionary = enemies[index]
			kind = String(enemy.get("type", ""))
		tell.material_override = v161_warden_tell_material if kind == "warden" else v161_enemy_tell_material
		# Preserve the inherited gameplay-owned footprint/scale; only keep the
		# new warning surface almost flush with the authored floor.
		tell.position.y = maxf(tell.position.y, 0.055)

	for index in range(mini(enemy_vfx_slots.size(), enemies.size())):
		var enemy: Dictionary = enemies[index]
		if String(enemy.get("type", "")) != "warden":
			continue
		var slot := enemy_vfx_slots[index] as Node3D
		if slot == null:
			continue
		var shock := slot.get_node_or_null("Shockwave0") as MeshInstance3D
		if shock != null:
			shock.material_override = v161_warden_tell_material

func _sync_v161_combat_presentation() -> void:
	# The v1.60 geometry remains instantiated for its regression contract, but the
	# new top presentation layer owns what the player actually sees.
	if v160_attack_arc != null:
		v160_attack_arc.visible = false
	if v160_attack_edge != null:
		v160_attack_edge.visible = false
	if v160_skill_outer_ring != null:
		v160_skill_outer_ring.visible = false
	if player_chest_sigil != null:
		player_chest_sigil.visible = false
	if player_skill_crown != null:
		player_skill_crown.visible = false

	var attack_visible := attack_amount > 0.025
	var attack_progress := clampf(attack_amount, 0.0, 1.0)
	for node_value in [v161_attack_trail, v161_attack_hot_edge, v161_attack_contact]:
		var node := node_value as MeshInstance3D
		if node != null:
			node.visible = attack_visible
	if attack_visible:
		var sweep := (1.0 - attack_progress) * 0.20
		var attack_scale := 0.94 + attack_progress * 0.10
		v161_attack_trail.scale = Vector3(attack_scale, 1.0, attack_scale)
		v161_attack_hot_edge.scale = Vector3(attack_scale, 1.0, attack_scale)
		v161_attack_contact.scale = Vector3(0.96 + attack_progress * 0.08, 1.0, 0.96 + attack_progress * 0.08)
		v161_attack_trail.rotation.y = sweep
		v161_attack_hot_edge.rotation.y = sweep
		v161_attack_contact.rotation.y = sweep * 0.72

	var skill_visible := skill_amount > 0.025
	for node_value in [v161_skill_wave_outer, v161_skill_wave_inner, v161_skill_runes]:
		var node := node_value as MeshInstance3D
		if node != null:
			node.visible = skill_visible
	if skill_visible:
		var skill_progress := clampf(skill_amount, 0.0, 1.0)
		var wave_scale := 0.96 + (1.0 - skill_progress) * 0.42
		v161_skill_wave_outer.scale = Vector3(wave_scale, 1.0, wave_scale)
		v161_skill_wave_inner.scale = Vector3(0.92 + (1.0 - skill_progress) * 0.30, 1.0, 0.92 + (1.0 - skill_progress) * 0.30)
		v161_skill_runes.scale = Vector3(0.94 + (1.0 - skill_progress) * 0.18, 1.0, 0.94 + (1.0 - skill_progress) * 0.18)
		v161_skill_wave_outer.rotation.y = runtime_elapsed * 0.88
		v161_skill_wave_inner.rotation.y = -runtime_elapsed * 1.12
		v161_skill_runes.rotation.y = runtime_elapsed * 0.42

func _build_v161_blade_ribbon(
	center_radius: float,
	max_width: float,
	start_angle: float,
	end_angle: float,
	segments: int,
	inner_height: float,
	outer_height: float
) -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(segments):
		var t0 := float(index) / float(segments)
		var t1 := float(index + 1) / float(segments)
		var a0 := lerpf(start_angle, end_angle, t0)
		var a1 := lerpf(start_angle, end_angle, t1)
		var envelope0 := 0.08 + pow(maxf(sin(PI * t0), 0.0), 0.72) * 0.92
		var envelope1 := 0.08 + pow(maxf(sin(PI * t1), 0.0), 0.72) * 0.92
		var width0 := max_width * envelope0
		var width1 := max_width * envelope1
		var lift0 := pow(maxf(sin(PI * t0), 0.0), 0.85)
		var lift1 := pow(maxf(sin(PI * t1), 0.0), 0.85)
		var center0 := center_radius + lift0 * 0.08
		var center1 := center_radius + lift1 * 0.08
		var inner0 := _v161_polar_point(a0, center0 - width0 * 0.5, inner_height + lift0 * 0.08)
		var outer0 := _v161_polar_point(a0, center0 + width0 * 0.5, outer_height + lift0 * 0.20)
		var inner1 := _v161_polar_point(a1, center1 - width1 * 0.5, inner_height + lift1 * 0.08)
		var outer1 := _v161_polar_point(a1, center1 + width1 * 0.5, outer_height + lift1 * 0.20)
		_v161_add_quad(tool, inner0, outer0, outer1, inner1)
	return tool.commit()

func _build_v161_arc_strip(
	inner_radius: float,
	outer_radius: float,
	start_angle: float,
	end_angle: float,
	segments: int
) -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(segments):
		var t0 := float(index) / float(segments)
		var t1 := float(index + 1) / float(segments)
		var a0 := lerpf(start_angle, end_angle, t0)
		var a1 := lerpf(start_angle, end_angle, t1)
		var taper0 := 0.18 + pow(maxf(sin(PI * t0), 0.0), 0.62) * 0.82
		var taper1 := 0.18 + pow(maxf(sin(PI * t1), 0.0), 0.62) * 0.82
		var center_radius := (inner_radius + outer_radius) * 0.5
		var half_width := (outer_radius - inner_radius) * 0.5
		var i0 := _v161_polar_point(a0, center_radius - half_width * taper0, 0.0)
		var o0 := _v161_polar_point(a0, center_radius + half_width * taper0, 0.0)
		var i1 := _v161_polar_point(a1, center_radius - half_width * taper1, 0.0)
		var o1 := _v161_polar_point(a1, center_radius + half_width * taper1, 0.0)
		_v161_add_quad(tool, i0, o0, o1, i1)
	return tool.commit()

func _build_v161_segmented_ring(
	inner_radius: float,
	outer_radius: float,
	segment_count: int,
	fill_ratio: float
) -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var step := TAU / float(segment_count)
	var half_span := step * clampf(fill_ratio, 0.10, 0.95) * 0.5
	for index in range(segment_count):
		var center := float(index) * step
		var a0 := center - half_span
		var a1 := center + half_span
		var i0 := _v161_polar_point(a0, inner_radius, 0.0)
		var o0 := _v161_polar_point(a0, outer_radius, 0.0)
		var i1 := _v161_polar_point(a1, inner_radius, 0.0)
		var o1 := _v161_polar_point(a1, outer_radius, 0.0)
		_v161_add_quad(tool, i0, o0, o1, i1)
	return tool.commit()

func _build_v161_radial_runes(count: int, radius: float, half_width: float, half_length: float) -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(count):
		var angle := TAU * float(index) / float(count)
		var radial := Vector3(sin(angle), 0.0, -cos(angle))
		var tangent := Vector3(cos(angle), 0.0, sin(angle))
		var center := radial * radius
		var front := center + radial * half_length
		var back := center - radial * half_length
		var left := center - tangent * half_width
		var right := center + tangent * half_width
		_v161_add_triangle(tool, front, right, back)
		_v161_add_triangle(tool, front, back, left)
	return tool.commit()

func _v161_polar_point(angle: float, radius: float, height: float) -> Vector3:
	return Vector3(sin(angle) * radius, height, -cos(angle) * radius)

func _v161_add_quad(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, d: Vector3) -> void:
	_v161_add_triangle(tool, a, b, c)
	_v161_add_triangle(tool, a, c, d)

func _v161_add_triangle(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	for point in [a, b, c]:
		tool.set_normal(Vector3.UP)
		tool.add_vertex(point)
