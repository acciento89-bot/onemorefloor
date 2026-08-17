extends "res://scripts/world3d_chamber_v149.gd"

# ONE MORE FLOOR v1.50 — 3D gameplay authority integration.
# Presentation remains inherited from v1.49. The new authority bridge resolves
# final locomotion endpoints with CharacterBody3D bodies and real world bounds.

const GameplayAuthority = preload("res://scripts/world3d_gameplay_authority_v150.gd")
const AUTHORITY_IMPACT_POOL := 10
const AUTHORITY_IMPACT_DURATION := 0.28

var gameplay_authority: Node3D
var authority_fx_root: Node3D
var authority_impact_pool: Array = []
var authority_impact_cursor := 0
var authority_last_report: Dictionary = {}
var authority_last_visual_frame := -1
var authority_material: StandardMaterial3D
var authority_contact_material: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_build_gameplay_authority()
	_build_authority_feedback()

func _process(delta: float) -> void:
	super._process(delta)
	_animate_authority_impacts(delta)

func gameplay_authority_ready() -> bool:
	return production_art_lookdev_ready() \
		and gameplay_authority != null \
		and gameplay_authority.has_method("authority_ready") \
		and bool(gameplay_authority.call("authority_ready")) \
		and authority_impact_pool.size() == AUTHORITY_IMPACT_POOL

func resolve_gameplay_authority(delta: float, player_design: Vector2, enemies: Array) -> Dictionary:
	if not gameplay_authority_ready():
		return {
			"ready": false,
			"player_pos": player_design,
			"enemy_positions": [],
			"mode": "hybrid_3d_collision_authority",
		}
	authority_last_report = gameplay_authority.call("resolve_frame", delta, player_design, enemies)
	return authority_last_report

func reset_gameplay_authority() -> void:
	if gameplay_authority != null and gameplay_authority.has_method("reset_authority"):
		gameplay_authority.call("reset_authority")
	authority_last_report = {}
	authority_last_visual_frame = -1

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["gameplay_authority_ready"] = gameplay_authority_ready()
	data["authority_impact_pool"] = authority_impact_pool.size()
	data["authority_mode"] = String(authority_last_report.get("mode", "hybrid_3d_collision_authority"))
	data["authority_frame"] = int(authority_last_report.get("frame", -1))
	data["authority_wall_hits"] = int(authority_last_report.get("wall_hits", 0))
	data["authority_separation_hits"] = int(authority_last_report.get("separation_hits", 0))
	data["authority_contact_pairs"] = int(authority_last_report.get("contact_pairs", 0))
	data["authority_corrected_bodies"] = int(authority_last_report.get("corrected_bodies", 0))
	if gameplay_authority != null and gameplay_authority.has_method("debug_snapshot"):
		data["authority_physics"] = gameplay_authority.call("debug_snapshot")
	return data

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
	_sync_authority_feedback()

func _build_gameplay_authority() -> void:
	gameplay_authority = GameplayAuthority.new()
	gameplay_authority.name = "GameplayAuthority3D"
	add_child(gameplay_authority)

func _build_authority_feedback() -> void:
	authority_material = _transparent_emissive(Color(0.42, 0.78, 1.0, 0.20), 1.35)
	authority_contact_material = _transparent_emissive(Color(1.0, 0.43, 0.30, 0.20), 1.55)
	authority_fx_root = Node3D.new()
	authority_fx_root.name = "GameplayAuthorityFeedback"
	add_child(authority_fx_root)
	for index in range(AUTHORITY_IMPACT_POOL):
		var root := Node3D.new()
		root.name = "AuthorityImpact%02d" % index
		root.visible = false
		root.set_meta("age", AUTHORITY_IMPACT_DURATION + 1.0)
		authority_fx_root.add_child(root)
		var ring: MeshInstance3D = _make_ring(root, "Ring", 0.24, authority_material, 24)
		ring.position.y = 0.035
		for shard_index in range(4):
			var angle: float = TAU * float(shard_index) / 4.0
			var shard: MeshInstance3D = _make_box(root, "Tick%d" % shard_index, Vector3(0.035, 0.04, 0.18), authority_material)
			shard.position = Vector3(cos(angle) * 0.26, 0.055, sin(angle) * 0.26)
			shard.rotation.y = -angle
		authority_impact_pool.append(root)

func _sync_authority_feedback() -> void:
	if authority_last_report.is_empty():
		return
	var frame: int = int(authority_last_report.get("frame", -1))
	if frame < 0 or frame == authority_last_visual_frame:
		return
	authority_last_visual_frame = frame
	var points: Array = authority_last_report.get("collision_points", [])
	var contact_pairs: int = int(authority_last_report.get("contact_pairs", 0))
	var material: Material = authority_contact_material if contact_pairs > 0 else authority_material
	for point_value in points:
		_spawn_authority_impact(point_value, material)

func _spawn_authority_impact(position_value: Vector3, material: Material) -> void:
	if authority_impact_pool.is_empty():
		return
	var root: Node3D = authority_impact_pool[authority_impact_cursor] as Node3D
	authority_impact_cursor = (authority_impact_cursor + 1) % authority_impact_pool.size()
	if root == null:
		return
	root.visible = true
	root.position = position_value + Vector3(0.0, 0.025, 0.0)
	root.scale = Vector3.ONE * 0.72
	root.rotation = Vector3.ZERO
	root.set_meta("age", 0.0)
	_apply_material_recursive(root, material)

func _animate_authority_impacts(delta: float) -> void:
	for item_value in authority_impact_pool:
		var item: Node3D = item_value as Node3D
		if item == null or not item.visible:
			continue
		var age: float = float(item.get_meta("age", 0.0)) + delta
		item.set_meta("age", age)
		if age >= AUTHORITY_IMPACT_DURATION:
			item.visible = false
			continue
		var t: float = clampf(age / AUTHORITY_IMPACT_DURATION, 0.0, 1.0)
		var scale_value: float = lerpf(0.72, 1.46, t)
		item.scale = Vector3(scale_value, 1.0, scale_value)
		item.rotation.y += delta * 5.4
