extends "res://scripts/world3d_chamber_v169_enemy_completion.gd"

# ONE MORE FLOOR v1.70 r1.1 — Realm + Endgame Visual Completion.
# Adds authored physical framing and foreground/midground depth to all five
# accepted realms. r1.1 is the capture-driven Iron correction: the stage remains,
# but uses dark plate response and a tighter dais instead of a broad rust plane.
# v1.65 materials, v1.68 Wanderer, v1.69 enemies/boss, camera, collision,
# navigation, combat timing, input, saves and progression remain inherited.

const REALM_COMPLETION_V170_VERSION := "1.70-realm-endgame-visual-completion-r1.1"
const V170_ROOT := "res://assets/environment/v170/"
const V170_ASSETS := {
	"lower_halls": V170_ROOT + "lower_halls_frame_v170.obj",
	"ossuary": V170_ROOT + "ossuary_frame_v170.obj",
	"iron_bastion": V170_ROOT + "iron_boss_stage_v170.obj",
	"rift_descent": V170_ROOT + "rift_frame_v170.obj",
	"starless_spire": V170_ROOT + "spire_frame_v170.obj",
}

const LowerFrameV170: Mesh = preload("res://assets/environment/v170/lower_halls_frame_v170.obj")
const OssuaryFrameV170: Mesh = preload("res://assets/environment/v170/ossuary_frame_v170.obj")
const IronStageV170: Mesh = preload("res://assets/environment/v170/iron_boss_stage_v170.obj")
const RiftFrameV170: Mesh = preload("res://assets/environment/v170/rift_frame_v170.obj")
const SpireFrameV170: Mesh = preload("res://assets/environment/v170/spire_frame_v170.obj")

var v170_realm_root: Node3D
var v170_instances: Dictionary = {}

func _ready() -> void:
	super._ready()
	_build_v170_realm_completion()

func production_realm_completion_ready() -> bool:
	if not production_enemy_completion_ready() or v170_realm_root == null:
		return false
	if v170_instances.size() != V170_ASSETS.size():
		return false
	for path_value in V170_ASSETS.values():
		if not ResourceLoader.exists(String(path_value)):
			return false
	for realm_value in V170_ASSETS.keys():
		var realm := String(realm_value)
		var instance := v170_instances.get(realm) as MeshInstance3D
		if instance == null or instance.mesh == null:
			return false
		if String(instance.get_meta("realm_completion_v170", "")) != REALM_COMPLETION_V170_VERSION:
			return false
	return true

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_realm_completion_ready"] = production_realm_completion_ready()
	data["production_realm_completion_version"] = REALM_COMPLETION_V170_VERSION
	data["production_realm_completion_instances"] = v170_instances.size()
	data["production_realm_completion_profile"] = "authored-edge-framing-foreground-depth-restrained-boss-dais-r1.1"
	data["production_realm_completion_gameplay_geometry_changed"] = false
	return data

func _build_v170_realm_completion() -> void:
	v170_realm_root = Node3D.new()
	v170_realm_root.name = "RealmCompletionV170"
	add_child(v170_realm_root)
	v170_instances.clear()

	_mount_v170("lower_halls", LowerFrameV170, v165_lower_stone, Vector3.ONE)
	_mount_v170("ossuary", OssuaryFrameV170, v165_ossuary_stone, Vector3.ONE)
	# r1 visual review: oxidized orange made the dais compete with the boss.
	# Dark iron preserves the stage silhouette while letting the Warden dominate.
	_mount_v170("iron_bastion", IronStageV170, v165_iron_plate, Vector3(1.0, 0.24, 1.0))
	_mount_v170("rift_descent", RiftFrameV170, v165_rift_stone, Vector3.ONE)
	_mount_v170("starless_spire", SpireFrameV170, v165_spire_stone, Vector3.ONE)

func _mount_v170(realm: String, mesh_value: Mesh, material: Material, scale_value: Vector3) -> void:
	var parent := authored_realm_roots.get(realm) as Node3D
	if parent == null or mesh_value == null:
		return
	var old := parent.get_node_or_null("RealmFrameV170")
	if old != null:
		parent.remove_child(old)
		old.queue_free()
	var instance := MeshInstance3D.new()
	instance.name = "RealmFrameV170"
	instance.mesh = mesh_value
	instance.material_override = material
	instance.scale = scale_value
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	instance.set_meta("realm_completion_v170", REALM_COMPLETION_V170_VERSION)
	instance.set_meta("realm", realm)
	instance.set_meta("visual_only", true)
	parent.add_child(instance)
	v170_instances[realm] = instance
