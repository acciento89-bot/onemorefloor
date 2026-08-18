extends "res://scripts/world3d_chamber_v160_actors.gd"

# ONE MORE FLOOR v1.60 — production combat VFX geometry pass.
# Keeps every v1.41-v1.52 gameplay timing and state trigger authoritative while
# replacing legacy filled-disc combat rings with true torus geometry and adding
# a directed melee slash/skill accent. Mobile GL Compatibility remains target.

const COMBAT_VFX_VERSION := "1.60-production-combat-vfx"
const STATIC_TRUE_RING_TARGET := 229

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
	_apply_v160_enemy_vfx_hierarchy(enemies)

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
	v160_attack_material = _transparent_emissive(Color("f5c86c", 0.68), 1.14)
	v160_attack_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	v160_skill_material = _transparent_emissive(Color("8b67d8", 0.48), 0.82)
	v160_tell_material = _transparent_emissive(Color("8e5fc1", 0.44), 0.62)
	v160_warden_tell_material = _transparent_emissive(Color("c95058", 0.48), 0.68)

func _upgrade_v160_legacy_combat_rings() -> void:
	v160_true_rings_replaced = 0

	# v1.46 production vertical slice: combat tells, death/loot feedback, boss
	# framing and Wanderer attack/skill pulses. Realm transition discs are kept as
	# intentional full-screen transition surfaces and are not counted here.
	for tell_value in telegraph_pool:
		_replace_with_true_ring(tell_value as MeshInstance3D, 0.56, 0.70)
	for burst_value in death_burst_pool:
		var burst := burst_value as Node3D
		if burst != null:
			_replace_with_true_ring(burst.get_node_or_null("Ring") as MeshInstance3D, 0.47, 0.58)
	for marker_value in loot_marker_pool:
		var marker := marker_value as Node3D
		if marker != null:
			_replace_with_true_ring(marker.get_node_or_null("FloorGlow") as MeshInstance3D, 0.22, 0.28)
	_replace_with_true_ring(boss_halo, 0.90, 1.08)
	_replace_with_true_ring(attack_ring, 0.58, 0.72)
	_replace_with_true_ring(skill_ring_outer, 1.03, 1.22)
	_replace_with_true_ring(skill_ring_inner, 0.47, 0.58)
	if attack_ring != null:
		attack_ring.material_override = v160_attack_material
	if skill_ring_outer != null:
		skill_ring_outer.material_override = v160_skill_material
	if skill_ring_inner != null:
		skill_ring_inner.material_override = v160_skill_material

	# v1.48 character combat VFX.
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

	# v1.41 projectile impact pool inherited through the stack.
	for impact_value in impact_pool:
		var impact := impact_value as MeshInstance3D
		if impact != null:
			_replace_with_true_ring(impact, 0.15, 0.22)

	# v1.49 production lookdev: grounding, motion echoes and boss dominance.
	for grounding_value in enemy_grounding_pool:
		_replace_with_true_ring(grounding_value as MeshInstance3D, 0.39, 0.48)
	for echo_value in move_echo_pool:
		var echo := echo_value as Node3D
		if echo != null:
			_replace_with_true_ring(echo.get_node_or_null("Ring") as MeshInstance3D, 0.27, 0.34)
	_replace_with_true_ring(boss_dominance_ring_outer, 1.08, 1.28)
	_replace_with_true_ring(boss_dominance_ring_inner, 0.69, 0.82)

	# v1.50 locomotion/contact authority feedback.
	for authority_value in authority_impact_pool:
		var authority_root := authority_value as Node3D
		if authority_root != null:
			_replace_with_true_ring(authority_root.get_node_or_null("Ring") as MeshInstance3D, 0.18, 0.24)

	# v1.51 projectile/contact authority feedback.
	for combat_value in combat_authority_impact_pool:
		var combat_root := combat_value as Node3D
		if combat_root != null:
			_replace_with_true_ring(combat_root.get_node_or_null("ImpactRing") as MeshInstance3D, 0.16, 0.22)

	# v1.52 target/NOVA/Warden geometry feedback.
	for lock_value in target_lock_pool:
		var lock_root := lock_value as Node3D
		if lock_root != null:
			_replace_with_true_ring(lock_root.get_node_or_null("LockRing") as MeshInstance3D, 0.27, 0.34)
	if nova_volume_visual != null:
		_replace_with_true_ring(nova_volume_visual.get_node_or_null("NovaBoundary") as MeshInstance3D, 0.86, 1.00)
	if warden_ring_visual != null:
		_replace_with_true_ring(warden_ring_visual.get_node_or_null("ThreatRing") as MeshInstance3D, 0.86, 1.00)

func _build_v160_player_combat_accents() -> void:
	if player_root == null:
		return
	v160_attack_arc = MeshInstance3D.new()
	v160_attack_arc.name = "V160AttackArc"
	v160_attack_arc.mesh = _build_v160_slash_arc_mesh(0.38, 0.98, -1.05, 1.05, 20)
	v160_attack_arc.material_override = v160_attack_material
	v160_attack_arc.position = Vector3(0.0, 0.78, -0.02)
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
	# v1.46 direct tests keep their own attack/skill pulses. In the v1.60 world
	# these three duplicate ground signals are suppressed so the authored slash +
	# v1.48 inner sigil + v1.60 outer skill ring form one readable hierarchy.
	if attack_ring != null:
		attack_ring.visible = false
	if skill_ring_outer != null:
		skill_ring_outer.visible = false
	if skill_ring_inner != null:
		skill_ring_inner.visible = false

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

func _apply_v160_enemy_vfx_hierarchy(enemies: Array) -> void:
	# v1.46 owns the primary ground warning. Hide the older attached TellRing and
	# transient v1.49 grounding whenever the same enemy is actively telegraphing.
	# Warden keeps one v1.48 shockwave instead of three simultaneous ground rings.
	for index in range(enemy_pool.size()):
		var proxy := enemy_pool[index] as Node3D
		if proxy != null:
			var attached_tell := proxy.get_node_or_null("Motion/Visual/TellRing") as MeshInstance3D
			if attached_tell != null:
				attached_tell.visible = false
		if index >= enemies.size():
			continue
		var enemy: Dictionary = enemies[index]
		var tell := _enemy_tell(enemy)
		if tell > 0.05 and index < enemy_grounding_pool.size():
			var grounding := enemy_grounding_pool[index] as MeshInstance3D
			if grounding != null:
				grounding.visible = false
		if index < enemy_vfx_slots.size() and String(enemy.get("type", "")) == "warden" and tell > 0.10:
			var slot := enemy_vfx_slots[index] as Node3D
			if slot != null:
				for wave_index in [1, 2]:
					var wave := slot.get_node_or_null("Shockwave%d" % wave_index) as MeshInstance3D
					if wave != null:
						wave.visible = false

	# v1.49 boss dominance remains as the boss identity layer. During an active
	# Warden tell, drop its inner ring so the primary warning and one shockwave own
	# the floor. v1.46's boss halo is redundant in v1.60 and stays hidden.
	if boss_halo != null:
		boss_halo.visible = false
	var boss_telling := false
	for enemy_value in enemies:
		var enemy: Dictionary = enemy_value
		if String(enemy.get("type", "")) == "warden" and _enemy_tell(enemy) > 0.05:
			boss_telling = true
			break
	if boss_dominance_ring_outer != null:
		boss_dominance_ring_outer.visible = boss_dominance_root != null and boss_dominance_root.visible
	if boss_dominance_ring_inner != null:
		boss_dominance_ring_inner.visible = boss_dominance_root != null and boss_dominance_root.visible and not boss_telling

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
		# Top-facing winding: the isometric camera sees +Y, not the culled underside.
		tool.add_vertex(inner0)
		tool.add_vertex(outer1)
		tool.add_vertex(outer0)
		tool.add_vertex(inner0)
		tool.add_vertex(inner1)
		tool.add_vertex(outer1)
	tool.generate_normals()
	return tool.commit()
