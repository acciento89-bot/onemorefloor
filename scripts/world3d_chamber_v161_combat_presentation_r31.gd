extends "res://scripts/world3d_chamber_v161_combat_presentation_r3.gd"

# ONE MORE FLOOR v1.61 r3.1 — spawn/death signature language pass.
# Replaces the inherited v1.48 archetype-colored ring + five rods with compact
# broken brackets and tapered shards. Signature triggers/duration stay inherited.

const COMBAT_PRESENTATION_R31_VERSION := "1.61-combat-presentation-r3.1"

var v161_signature_bracket_mesh: ArrayMesh
var v161_signature_shard_mesh: ArrayMesh

func _ready() -> void:
	super._ready()
	_upgrade_v161_signature_language()

func production_combat_presentation_ready() -> bool:
	return super.production_combat_presentation_ready() and _v161_signature_language_ready()

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["combat_presentation_v161_version"] = COMBAT_PRESENTATION_R31_VERSION
	data["combat_presentation_v161_signatures"] = _v161_signature_language_ready()
	return data

func _upgrade_v161_signature_language() -> void:
	v161_signature_bracket_mesh = _build_v161_signature_brackets()
	v161_signature_shard_mesh = _build_v161_loot_shard()
	for pool_value in [spawn_signature_pool, death_signature_pool]:
		var pool: Array = pool_value
		for root_value in pool:
			var signature := root_value as Node3D
			if signature == null:
				continue
			var ring := signature.get_node_or_null("Ring") as MeshInstance3D
			if ring != null:
				ring.mesh = v161_signature_bracket_mesh
				ring.position.y = 0.055
				ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			for shard_index in range(5):
				var shard := signature.get_node_or_null("Shard%d" % shard_index) as MeshInstance3D
				if shard == null:
					continue
				var angle := TAU * float(shard_index) / 5.0
				shard.mesh = v161_signature_shard_mesh
				shard.position = Vector3(cos(angle) * 0.30, 0.14, sin(angle) * 0.30)
				shard.scale = Vector3(0.34, 0.40, 0.34)
				shard.rotation = Vector3(0.0, -angle, 0.0)
				shard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _animate_signature_pool(pool: Array, delta: float, spawning: bool) -> void:
	for item_value in pool:
		var item := item_value as Node3D
		if item == null or not item.visible:
			continue
		var age := float(item.get_meta("age", 0.0)) + delta
		item.set_meta("age", age)
		if age >= SIGNATURE_DURATION:
			item.visible = false
			continue
		var t := clampf(age / SIGNATURE_DURATION, 0.0, 1.0)
		var scale_value := lerpf(1.10, 0.74, t) if spawning else lerpf(0.74, 1.35, t)
		item.scale = Vector3(scale_value, 1.0 + t * 0.18, scale_value)
		item.rotation.y += delta * (0.82 if spawning else -1.05)
		item.position.y += delta * (0.04 if spawning else 0.20)

func _v161_signature_language_ready() -> bool:
	if spawn_signature_pool.is_empty() or death_signature_pool.is_empty():
		return false
	for pool_value in [spawn_signature_pool, death_signature_pool]:
		var pool: Array = pool_value
		var signature := pool[0] as Node3D
		if signature == null:
			return false
		var ring := signature.get_node_or_null("Ring") as MeshInstance3D
		if ring == null or not (ring.mesh is ArrayMesh):
			return false
		for shard_index in range(5):
			var shard := signature.get_node_or_null("Shard%d" % shard_index) as MeshInstance3D
			if shard == null or not (shard.mesh is ArrayMesh):
				return false
	return true

func _build_v161_signature_brackets() -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(5):
		var center_angle := TAU * float(index) / 5.0
		var radial := Vector3(sin(center_angle), 0.0, -cos(center_angle))
		var tangent := Vector3(cos(center_angle), 0.0, sin(center_angle))
		var inner_center := radial * 0.30
		var outer_center := radial * 0.55
		var inner_left := inner_center - tangent * 0.070
		var inner_right := inner_center + tangent * 0.070
		var outer_left := outer_center - tangent * 0.025
		var outer_right := outer_center + tangent * 0.025
		_v161_add_quad(tool, inner_left, outer_left, outer_right, inner_right)
		# Short tangential hook gives each segment a deliberate bracket silhouette
		# instead of reading as another incomplete circular ring.
		var hook_center := inner_center - radial * 0.025
		var hook_a := hook_center - tangent * 0.13 - radial * 0.025
		var hook_b := hook_center + tangent * 0.13 - radial * 0.025
		var hook_c := hook_center + tangent * 0.13 + radial * 0.025
		var hook_d := hook_center - tangent * 0.13 + radial * 0.025
		_v161_add_quad(tool, hook_a, hook_b, hook_c, hook_d)
	return tool.commit()
