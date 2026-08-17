extends "res://scripts/main_v68.gd"

# ONE MORE FLOOR v1.55 — production Wanderer model pilot.
# v1.54 automatically resolves assets/models/actors/wanderer.gltf, mounts it
# into the existing RigMount and leaves all combat/touch authority unchanged.

const V69_VERSION := "1.55.0-wanderer-production-pilot"
const V69_BUILD := "42-dev"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V69_VERSION, V69_BUILD)
		telemetry.event("wanderer_production_model_ready", _v69_wanderer_snapshot())

func _v69_wanderer_production_ready() -> bool:
	if not _v68_real_model_intake_ready() or v52_world_root == null:
		return false
	var player_root: Node3D = v52_world_root.player_root
	if player_root == null:
		return false
	var model_source := String(player_root.get_meta("model_source", ""))
	var asset_path := String(player_root.get_meta("model_asset_path", ""))
	var model := player_root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	return model_source == "imported-glb" \
		and asset_path == "res://assets/models/actors/wanderer.gltf" \
		and model != null

func _v69_wanderer_snapshot() -> Dictionary:
	var source := ""
	var asset_path := ""
	var imported_model_present := false
	if v52_world_root != null and v52_world_root.player_root != null:
		var player_root: Node3D = v52_world_root.player_root
		source = String(player_root.get_meta("model_source", ""))
		asset_path = String(player_root.get_meta("model_asset_path", ""))
		imported_model_present = player_root.get_node_or_null("Motion/RigMount/ImportedModel") != null
	return {
		"ready": _v69_wanderer_production_ready(),
		"version": V69_VERSION,
		"build": V69_BUILD,
		"model_source": source,
		"asset_path": asset_path,
		"imported_model_present": imported_model_present,
		"combat_authority_ready": _v65_3d_combat_core_ready(),
		"input_flow": _v66_input_flow_snapshot(),
	}
