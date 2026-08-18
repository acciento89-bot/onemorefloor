extends "res://scripts/world3d_chamber_v160_vfx.gd"

# ONE MORE FLOOR v1.60 — final combat readability/polish layer.
# Keeps the fully validated 229-ring takeover intact, captures the original
# Wanderer SkillRing as ring #230, and moves player attack/skill accents onto a
# readable floor plane for the isometric camera. No combat authority changes.

const COMBAT_POLISH_VERSION := "1.60-production-combat-vfx-polish"
const COMBAT_POLISH_TRUE_RING_TARGET := 230

var v160_attack_edge: MeshInstance3D
var v160_attack_edge_material: StandardMaterial3D
var v160_legacy_player_skill_ring: MeshInstance3D

func _ready() -> void:
	super._ready()
	_upgrade_v160_player_legacy_skill_ring()
	_polish_v160_player_combat_geometry()
	_sync_v160_combat_polish()

func _process(delta: float) -> void:
	super._process(delta)
	_sync_v160_combat_polish()

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
	_sync_v160_combat_polish()

func production_combat_vfx_ready() -> bool:
	return super.production_combat_vfx_ready() \
		and v160_true_rings_replaced >= COMBAT_POLISH_TRUE_RING_TARGET \
		and v160_legacy_player_skill_ring != null \
		and v160_legacy_player_skill_ring.mesh is TorusMesh \
		and v160_attack_edge != null \
		and v160_attack_edge.mesh is ArrayMesh

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_combat_vfx_ready"] = production_combat_vfx_ready()
	data["production_combat_vfx_version"] = COMBAT_POLISH_VERSION
	data["production_combat_vfx_true_rings"] = v160_true_rings_replaced
	data["production_combat_vfx_static_target"] = COMBAT_POLISH_TRUE_RING_TARGET
	data["production_combat_vfx_attack_edge"] = v160_attack_edge != null
	data["production_combat_vfx_legacy_skill_ring_captured"] = v160_legacy_player_skill_ring != null
	return data

func _upgrade_v160_player_legacy_skill_ring() -> void:
	if player_root == null:
		return
	v160_legacy_player_skill_ring = player_root.get_node_or_null("SkillRing") as MeshInstance3D
	if v160_legacy_player_skill_ring == null:
		return
	_replace_with_true_ring(v160_legacy_player_skill_ring, 0.74, 0.86)
	v160_legacy_player_skill_ring.material_override = v160_skill_material
	v160_legacy_player_skill_ring.visible = false

func _polish_v160_player_combat_geometry() -> void:
	if player_root == null or v160_attack_arc == null or v160_skill_outer_ring == null:
		return

	# Gameplay camera readability: place the slash well in front of the Wanderer
	# instead of letting the cloak/body occlude most of it from the isometric view.
	v160_attack_arc.mesh = _build_v160_slash_arc_mesh(0.62, 1.58, -1.10, 1.10, 28)
	v160_attack_arc.position = Vector3(0.0, 0.150, -0.72)
	v160_attack_arc.material_override = v160_attack_material

	# A thin bright outer lip gives the broad translucent crescent a readable
	# weapon edge without adding texture samples or screen-space effects.
	v160_attack_edge_material = _transparent_emissive(Color("fff0b0", 0.88), 1.55)
	v160_attack_edge_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	v160_attack_edge = MeshInstance3D.new()
	v160_attack_edge.name = "V160AttackEdge"
	v160_attack_edge.mesh = _build_v160_slash_arc_mesh(1.42, 1.62, -1.10, 1.10, 28)
	v160_attack_edge.material_override = v160_attack_edge_material
	v160_attack_edge.position = Vector3(0.0, 0.164, -0.72)
	v160_attack_edge.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	v160_attack_edge.visible = false
	player_root.add_child(v160_attack_edge)

	# The skill boundary must sit clearly outside the hero silhouette at gameplay
	# zoom. The earlier ~1.1 radius was technically visible but visually swallowed
	# by the cape/pauldrons in the orthographic projection.
	v160_skill_material.albedo_color = Color("a879ea", 0.68)
	v160_skill_material.emission = Color("a879ea")
	v160_skill_material.emission_energy_multiplier = 1.12
	var skill_mesh := TorusMesh.new()
	skill_mesh.inner_radius = 1.38
	skill_mesh.outer_radius = 1.58
	skill_mesh.rings = 40
	skill_mesh.ring_segments = 10
	v160_skill_outer_ring.mesh = skill_mesh
	v160_skill_outer_ring.position = Vector3(0.0, 0.165, 0.0)

func _sync_v160_combat_polish() -> void:
	# The original actor-factory SkillRing remains structurally present for legacy
	# compatibility, but the v1.60 presentation owns the visible skill boundary.
	if v160_legacy_player_skill_ring != null:
		v160_legacy_player_skill_ring.visible = false

	if v160_attack_arc != null:
		var attack_visible := attack_amount > 0.025
		v160_attack_arc.visible = attack_visible
		if attack_visible:
			var attack_scale := 0.96 + attack_amount * 0.14
			v160_attack_arc.scale = Vector3(attack_scale, 1.0, attack_scale)
			v160_attack_arc.rotation.y = (1.0 - attack_amount) * 0.18
	if v160_attack_edge != null:
		v160_attack_edge.visible = v160_attack_arc != null and v160_attack_arc.visible
		if v160_attack_edge.visible:
			v160_attack_edge.scale = v160_attack_arc.scale
			v160_attack_edge.rotation.y = v160_attack_arc.rotation.y

	if v160_skill_outer_ring != null:
		var skill_visible := skill_amount > 0.025
		v160_skill_outer_ring.visible = skill_visible
		if skill_visible:
			var skill_scale := 0.98 + (1.0 - skill_amount) * 0.50
			v160_skill_outer_ring.scale = Vector3(skill_scale, 1.0, skill_scale)
			v160_skill_outer_ring.rotation.y = runtime_elapsed * 1.45
