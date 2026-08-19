extends "res://scripts/world3d_chamber_v161_combat_presentation_r21.gd"

# ONE MORE FLOOR v1.61 r2.2 — death-feedback cleanup.
# Replaces the inherited v1.46 expanding death ring + shard glyph with a compact
# radial dissolve burst. Death detection/timing/pooling stay inherited; only the
# visible geometry and animation response change.

const COMBAT_PRESENTATION_R22_VERSION := "1.61-combat-presentation-r2.2"

var v161_death_burst_mesh: ArrayMesh
var v161_death_burst_material: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_upgrade_v161_death_feedback()

func production_combat_presentation_ready() -> bool:
	return super.production_combat_presentation_ready() and _v161_death_feedback_ready()

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["combat_presentation_v161_version"] = COMBAT_PRESENTATION_R22_VERSION
	data["combat_presentation_v161_death_bursts"] = _v161_death_feedback_ready()
	return data

func _upgrade_v161_death_feedback() -> void:
	v161_death_burst_material = _transparent_emissive(Color("a47bd8", 0.22), 0.64)
	v161_death_burst_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	v161_death_burst_mesh = _build_v161_impact_burst(10, 0.11, 0.64, 0.044, 0.012)

	for value in death_burst_pool:
		var burst := value as Node3D
		if burst == null:
			continue
		var ring := burst.get_node_or_null("Ring") as MeshInstance3D
		if ring != null:
			ring.mesh = v161_death_burst_mesh
			ring.material_override = v161_death_burst_material
			ring.position = Vector3(0.0, 0.070, 0.0)
			ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for shard_index in range(4):
			var shard := burst.get_node_or_null("Shard%d" % shard_index) as MeshInstance3D
			if shard != null:
				shard.material_override = v161_death_burst_material
				shard.scale = Vector3(0.50, 0.70, 0.50)
				shard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _v161_death_feedback_ready() -> bool:
	if death_burst_pool.is_empty():
		return false
	var burst := death_burst_pool[0] as Node3D
	if burst == null:
		return false
	var ring := burst.get_node_or_null("Ring") as MeshInstance3D
	return ring != null and ring.mesh is ArrayMesh

func _animate_death_bursts(delta: float) -> void:
	for burst_value in death_burst_pool:
		var burst := burst_value as Node3D
		if burst == null or not burst.visible:
			continue
		var age: float = float(burst.get_meta("age", 0.0)) + delta
		burst.set_meta("age", age)
		if age >= DEATH_BURST_DURATION:
			burst.visible = false
			continue
		var t: float = clampf(age / DEATH_BURST_DURATION, 0.0, 1.0)
		# A short expanding dissolve rather than the old giant spinning glyph.
		var planar_scale := lerpf(0.72, 1.18, t)
		burst.scale = Vector3(planar_scale, 0.90 + t * 0.30, planar_scale)
		burst.position.y += delta * 0.24
		burst.rotation.y += delta * 1.05
