extends "res://scripts/world3d_chamber_v160_actors.gd"

# ONE MORE FLOOR v1.60 — production combat VFX geometry pass.
# Keeps every v1.41/v1.48 gameplay timing and state trigger authoritative while
# replacing filled disc "rings" with true torus geometry and adding a directed
# melee slash/skill accent. Mobile GL Compatibility remains the target.

const COMBAT_VFX_VERSION := "1.60-production-combat-vfx"
const STATIC_TRUE_RING_TARGET := 113

var v160_true_rings_replaced := 0
var v160_attack_arc: MeshInstance3D
var v160_skill_outer_ring: MeshInstance3D
var v160_attack_material: StandardMaterial3D
var v160_skill_material: StandardMaterial3D
var v160_tell_material: StandardMaterial3D
var v160_warden_tell_material: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_build_v160_combat_materials()
	_upgrade_v160_legacy_combat_rings()
	_build_v160_player_combat_accents()

func _process(delta: float) -> void:
	super._process(delta)
	_sync_v160_player_combat_accents()

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
	super.sync_runtime(player_pos, enemies, player_shots, enemy_shots, coins, joy, elapsed_value, attack_flash, skill_flash, floor_no)
	_upgrade_v160_enemy_tell_rings()
	_sync_v160_player_combat_accents()

func production_combat_vfx_ready() -> bool:
	return production_actor_presentation_ready() \
		and character_combat_vfx_ready() \
		and v160_true_rings_replaced >= STATIC_TRUE_RING_TARGET \
		and v160_attack_arc != null \
		and v160_attack_arc.mesh is ArrayMesh \
		and v160_skill_outer_ring != null \
		and v160_skill_outer_ring.mesh is TorusMesh

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_combat_vfx_ready"] = production_combat_vfx_ready()
	data["production_combat_vfx_version"] = COMBAT_VFX_VERSION
	data["production_combat_vfx_true_rings"] = v160_true_rings_replaced
	data["production_combat_vfx_static_target"] = STATIC_TRUE_RING_TARGET
	data["production_combat_vfx_attack_arc"] = v160_attack_arc != null
	data["production_combat_vfx_skill_ring"] = v160_skill_outer_ring != null
	return data

func _build_v160_combat_materials() -> void:
	v160_attack_material = _transparent_emissive(Color("f5c86c", 0.62), 1.05)
	v160_skill_material = _transparent_emissive(Color("8b67d8", 0.48), 0.82)
	v160_tell_material = _transparent_emissive(Color("8e5fc1", 0.44), 0.62)
	v160_warden_tell_material = _transparent_emissive(Color("c95058", 0.48), 0.68)

func _upgrade_v160_legacy_combat_rings() -> void:
	v160_true_rings_replaced = 0

	if player_chest_sigil != null:
		_replace_with_true_ring(player_chest_sigil, 0.50, 0.62)
		player_chest_sigil.material_override = v160_skill_material

	for slot_value in enemy_vfx_slots:
		var slot := slot_value as Node3D
		if slot == null:
			continue
		var head_rune := slot.get_node_or_null("HeadRune") as MeshInstance3D
		if head_rune != null:
			_replace_with_true_ring(head_rune, 0.27, 0.34)
		for index in range(3):
			var shock := slot.get_node_or_null("Shockwave%d" % index) as MeshInstance3D
			if shock != null:
				_replace_with_true_ring(shock, 0.55, 0.68)

	for pool_value in [spawn_signature_pool, death_signature_pool]:
		var signature_pool: Array = pool_value
		for item_value in signature_pool:
			var item := item_value as Node3D
			if item == null:
				continue
			var ring := item.get_node_or_null("Ring") as MeshInstance3D
			if ring != null:
				_replace_with_true_ring(ring, 0.42, 0.52)

	for impact_value in impact_pool:
		var impact := impact_value as MeshInstance3D
		if impact != null:
			_replace_with_true_ring(impact, 0.15, 0.22)

func _build_v160_player_combat_accents() -> void:
	if player_root == null:
		return
	v160_attack_arc = MeshInstance3D.new()
	v160_attack_arc.name = "V160AttackArc"
	v160_attack_arc.mesh = _build_v160_slash_arc_mesh(0.38, 0.96, -1.05, 1.05, 20)
	v160_attack_arc.material_override = v160_attack_material
	v160_attack_arc.position = Vector3(0.0, 0.68, -0.02)
	v160_attack_arc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	v160_attack_arc.visible = false
	player_root.add_child(v160_attack_arc)

	v160_skill_outer_ring = MeshInstance3D.new()
	v160_skill_outer_ring.name = "V160SkillOuterRing"
	var skill_mesh := TorusMesh.new()
	skill_mesh.inner_radius = 0.72
	skill_mesh.outer_radius = 0.84
	skill_mesh.rings = 32
	skill_mesh.ring_segments = 10
	v160_skill_outer_ring.mesh = skill_mesh
	v160_skill_outer_ring.material_override = v160_skill_material
	v160_skill_outer_ring.position = Vector3(0.0, 0.055, 0.0)
	v160_skill_outer_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	v160_skill_outer_ring.visible = false
	player_root.add_child(v160_skill_outer_ring)

func _sync_v160_player_combat_accents() -> void:
	if v160_attack_arc != null:
		v160_attack_arc.visible = attack_amount > 0.025
		if v160_attack_arc.visible:
			var attack_scale := 0.82 + attack_amount * 0.28
			v160_attack_arc.scale = Vector3(attack_scale, 1.0, attack_scale)
			v160_attack_arc.rotation.y = (1.0 - attack_amount) * 0.24
	if v160_skill_outer_ring != null:
		v160_skill_outer_ring.visible = skill_amount > 0.025
		if v160_skill_outer_ring.visible:
			var skill_scale := 0.78 + (1.0 - skill_amount) * 0.56
			v160_skill_outer_ring.scale = Vector3(skill_scale, 1.0, skill_scale)
			v160_skill_outer_ring.rotation.y = runtime_elapsed * 1.65

func _upgrade_v160_enemy_tell_rings() -> void:
	for enemy_value in enemy_pool:
		var enemy := enemy_value as Node3D
		if enemy == null:
			continue
		var tell_ring := enemy.get_node_or_null("Motion/Visual/TellRing") as MeshInstance3D
		if tell_ring == null:
			continue
		if not (tell_ring.mesh is TorusMesh):
			var mesh := TorusMesh.new()
			mesh.inner_radius = 0.42
			mesh.outer_radius = 0.52
			mesh.rings = 32
			mesh.ring_segments = 10
			tell_ring.mesh = mesh
		var kind := String(enemy.get_meta("enemy_presentation_v160_kind", ""))
		tell_ring.material_override = v160_warden_tell_material if kind == "warden" else v160_tell_material

func _replace_with_true_ring(node: MeshInstance3D, inner_radius: float, outer_radius: float) -> void:
	if node == null:
		return
	if node.mesh is TorusMesh:
		return
	var mesh := TorusMesh.new()
	mesh.inner_radius = inner_radius
	mesh.outer_radius = outer_radius
	mesh.rings = 32
	mesh.ring_segments = 10
	node.mesh = mesh
	v160_true_rings_replaced += 1

func _build_v160_slash_arc_mesh(inner_radius: float, outer_radius: float, start_angle: float, end_angle: float, segments: int) -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(segments):
		var t0 := float(index) / float(segments)
		var t1 := float(index + 1) / float(segments)
		var a0 := lerpf(start_angle, end_angle, t0)
		var a1 := lerpf(start_angle, end_angle, t1)
		var inner0 := Vector3(sin(a0) * inner_radius, 0.0, -cos(a0) * inner_radius)
		var outer0 := Vector3(sin(a0) * outer_radius, 0.0, -cos(a0) * outer_radius)
		var inner1 := Vector3(sin(a1) * inner_radius, 0.0, -cos(a1) * inner_radius)
		var outer1 := Vector3(sin(a1) * outer_radius, 0.0, -cos(a1) * outer_radius)
		tool.add_vertex(inner0)
		tool.add_vertex(outer0)
		tool.add_vertex(outer1)
		tool.add_vertex(inner0)
		tool.add_vertex(outer1)
		tool.add_vertex(inner1)
	tool.generate_normals()
	return tool.commit()
