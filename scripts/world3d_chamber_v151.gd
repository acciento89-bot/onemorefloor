extends "res://scripts/world3d_chamber_v150.gd"

# ONE MORE FLOOR v1.51 — 3D combat authority integration.
# Keeps the complete v1.49/v1.50 visual + locomotion stack, upgrades contact
# reporting to explicit 3D touch triggers and adds pooled Area3D projectile
# authority with world-space sphere sweeps.

const GameplayAuthorityV151 = preload("res://scripts/world3d_gameplay_authority_v151.gd")
const ProjectileAuthorityV151 = preload("res://scripts/world3d_projectile_authority_v151.gd")
const COMBAT_IMPACT_POOL := 16
const COMBAT_IMPACT_DURATION := 0.30

var projectile_authority: Node3D
var combat_authority_fx_root: Node3D
var combat_authority_impact_pool: Array = []
var combat_authority_impact_cursor := 0
var player_hit_material: StandardMaterial3D
var enemy_hit_material: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_build_projectile_authority()
	_build_combat_authority_feedback()

# v1.50 calls this build hook from its _ready(). Dynamic dispatch lets v1.51
# replace the contact reporter without duplicating the rest of the chamber boot.
func _build_gameplay_authority() -> void:
	gameplay_authority = GameplayAuthorityV151.new()
	gameplay_authority.name = "GameplayAuthority3D"
	add_child(gameplay_authority)

func combat_authority_ready() -> bool:
	return gameplay_authority_ready() \
		and gameplay_authority.has_method("combat_contact_ready") \
		and bool(gameplay_authority.call("combat_contact_ready")) \
		and projectile_authority != null \
		and projectile_authority.has_method("projectile_authority_ready") \
		and bool(projectile_authority.call("projectile_authority_ready")) \
		and combat_authority_impact_pool.size() == COMBAT_IMPACT_POOL

func resolve_player_projectiles_3d(delta: float, shots: Array, enemies: Array) -> Dictionary:
	if not combat_authority_ready():
		return {"ready": false, "shots": shots.duplicate(true), "hits": [], "mode": "3d_sphere_sweep"}
	var result_value: Variant = projectile_authority.call("resolve_player_projectiles", delta, shots, enemies)
	if not (result_value is Dictionary):
		return {"ready": false, "shots": shots.duplicate(true), "hits": [], "mode": "3d_sphere_sweep"}
	var result: Dictionary = result_value
	if bool(result.get("ready", false)):
		_spawn_projectile_hit_feedback(result.get("hits", []), true)
	return result

func resolve_enemy_projectiles_3d(delta: float, shots: Array, player_pos: Vector2) -> Dictionary:
	if not combat_authority_ready():
		return {"ready": false, "shots": shots.duplicate(true), "hits": [], "mode": "3d_sphere_sweep"}
	var result_value: Variant = projectile_authority.call("resolve_enemy_projectiles", delta, shots, player_pos)
	if not (result_value is Dictionary):
		return {"ready": false, "shots": shots.duplicate(true), "hits": [], "mode": "3d_sphere_sweep"}
	var result: Dictionary = result_value
	if bool(result.get("ready", false)):
		_spawn_projectile_hit_feedback(result.get("hits", []), false)
	return result

func reset_gameplay_authority() -> void:
	super.reset_gameplay_authority()
	if projectile_authority != null and projectile_authority.has_method("reset_authority"):
		projectile_authority.call("reset_authority")

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["combat_authority_ready"] = combat_authority_ready()
	data["combat_authority_mode"] = "3d_touch_and_projectile_sweep"
	data["combat_impact_pool"] = combat_authority_impact_pool.size()
	if projectile_authority != null and projectile_authority.has_method("debug_snapshot"):
		data["projectile_authority"] = projectile_authority.call("debug_snapshot")
	if gameplay_authority != null and gameplay_authority.has_method("debug_snapshot"):
		var contact_snapshot: Dictionary = gameplay_authority.call("debug_snapshot")
		data["touch_trigger_authority"] = contact_snapshot.get("touch_trigger_authority", "")
		data["contact_indices"] = contact_snapshot.get("contact_indices", []).duplicate()
	return data

func _process(delta: float) -> void:
	super._process(delta)
	_animate_combat_authority_feedback(delta)

func _build_projectile_authority() -> void:
	projectile_authority = ProjectileAuthorityV151.new()
	projectile_authority.name = "ProjectileAuthority3D"
	add_child(projectile_authority)

func _build_combat_authority_feedback() -> void:
	player_hit_material = _transparent_emissive(Color(1.0, 0.79, 0.34, 0.22), 1.65)
	enemy_hit_material = _transparent_emissive(Color(1.0, 0.26, 0.36, 0.22), 1.70)
	combat_authority_fx_root = Node3D.new()
	combat_authority_fx_root.name = "CombatAuthorityFeedback"
	add_child(combat_authority_fx_root)
	for index in range(COMBAT_IMPACT_POOL):
		var root := Node3D.new()
		root.name = "CombatAuthorityImpact%02d" % index
		root.visible = false
		root.set_meta("age", COMBAT_IMPACT_DURATION + 1.0)
		combat_authority_fx_root.add_child(root)
		var ring: MeshInstance3D = _make_ring(root, "ImpactRing", 0.22, player_hit_material, 28)
		ring.position.y = 0.04
		var core: MeshInstance3D = _make_sphere(root, "ImpactCore", 0.08, player_hit_material)
		core.position.y = 0.12
		for shard_index in range(6):
			var angle: float = TAU * float(shard_index) / 6.0
			var shard: MeshInstance3D = _make_box(root, "ImpactShard%d" % shard_index, Vector3(0.04, 0.15, 0.04), player_hit_material)
			shard.position = Vector3(cos(angle) * 0.18, 0.12, sin(angle) * 0.18)
			shard.rotation = Vector3(angle * 0.18, -angle, angle * 0.12)
		combat_authority_impact_pool.append(root)

func _spawn_projectile_hit_feedback(hit_values: Variant, from_player: bool) -> void:
	if not (hit_values is Array):
		return
	var hits: Array = hit_values
	var material: Material = player_hit_material if from_player else enemy_hit_material
	for hit_value in hits:
		if not (hit_value is Dictionary):
			continue
		var hit: Dictionary = hit_value
		var world_pos: Vector3 = hit.get("world_pos", Vector3.ZERO)
		_spawn_combat_authority_impact(world_pos, material, bool(hit.get("crit", false)))

func _spawn_combat_authority_impact(world_pos: Vector3, material: Material, critical: bool) -> void:
	if combat_authority_impact_pool.is_empty():
		return
	var root: Node3D = combat_authority_impact_pool[combat_authority_impact_cursor] as Node3D
	combat_authority_impact_cursor = (combat_authority_impact_cursor + 1) % combat_authority_impact_pool.size()
	if root == null:
		return
	root.visible = true
	root.position = world_pos + Vector3(0.0, 0.02, 0.0)
	root.scale = Vector3.ONE * (1.22 if critical else 0.92)
	root.rotation = Vector3.ZERO
	root.set_meta("age", 0.0)
	_apply_material_recursive(root, material)

func _animate_combat_authority_feedback(delta: float) -> void:
	for item_value in combat_authority_impact_pool:
		var item: Node3D = item_value as Node3D
		if item == null or not item.visible:
			continue
		var age: float = float(item.get_meta("age", 0.0)) + delta
		item.set_meta("age", age)
		if age >= COMBAT_IMPACT_DURATION:
			item.visible = false
			continue
		var t: float = clampf(age / COMBAT_IMPACT_DURATION, 0.0, 1.0)
		var scale_value: float = lerpf(0.86, 1.62, t)
		item.scale = Vector3(scale_value, 1.0 + t * 0.35, scale_value)
		item.rotation.y += delta * 6.2
