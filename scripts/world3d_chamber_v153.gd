extends "res://scripts/world3d_chamber_v152.gd"

# ONE MORE FLOOR v1.53 — visible 3D presentation chamber.
# Keeps v1.50-v1.52 gameplay authority intact and swaps only the native actor
# presentation factory. Existing directional lights are upgraded to cast shadows.

const VisualPresentationFactoryV153 = preload("res://scripts/world3d_actor_factory_v153.gd")
const V153_PRESENTATION_MODE := "smooth_pbr_native_fallback"

var v153_shadow_lights := 0

func _ready() -> void:
	super._ready()
	v153_shadow_lights = _enable_directional_shadows(self)

# v1.49 introduced this factory hook. Override it here so every inherited 3D
# authority layer continues to use the exact same actor roots and synchronization.
func _build_player() -> void:
	actor_factory = VisualPresentationFactoryV153.new()
	player_root = actor_factory.create_player(actor_materials)
	add_child(player_root)

func visual_presentation_ready() -> bool:
	return combat_core_authority_ready() \
		and actor_factory != null \
		and actor_factory.has_method("visual_presentation_ready") \
		and bool(actor_factory.call("visual_presentation_ready", player_root)) \
		and v153_shadow_lights >= 1

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["visual_presentation_v153_ready"] = visual_presentation_ready()
	data["visual_presentation_mode"] = V153_PRESENTATION_MODE
	data["directional_shadow_lights"] = v153_shadow_lights
	if actor_factory != null and actor_factory.has_method("visual_presentation_snapshot"):
		data["player_visual_presentation"] = actor_factory.call("visual_presentation_snapshot", player_root)
	if actor_factory != null and actor_factory.has_method("presentation_quality_snapshot"):
		data["presentation_quality"] = actor_factory.call("presentation_quality_snapshot")
	return data

func visual_presentation_snapshot() -> Dictionary:
	var player_snapshot: Dictionary = {}
	if actor_factory != null and actor_factory.has_method("visual_presentation_snapshot"):
		player_snapshot = actor_factory.call("visual_presentation_snapshot", player_root)
	return {
		"ready": visual_presentation_ready(),
		"mode": V153_PRESENTATION_MODE,
		"directional_shadow_lights": v153_shadow_lights,
		"player": player_snapshot,
	}

func _enable_directional_shadows(node: Node) -> int:
	if node == null:
		return 0
	var count := 0
	if node is DirectionalLight3D:
		var light := node as DirectionalLight3D
		light.shadow_enabled = true
		count += 1
	for child in node.get_children():
		count += _enable_directional_shadows(child)
	return count
