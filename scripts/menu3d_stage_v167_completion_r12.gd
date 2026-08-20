class_name Menu3DStageV167CompletionR12
extends "res://scripts/menu3d_stage_v167_completion.gd"

# ONE MORE FLOOR v1.67 — Frontend Completion r1.2.
# Capture-driven final frontend environment pass. Forge receives a dedicated
# authored workshop kit instead of reusing the coarse Iron Bastion focal. Home
# and Hero keep the exact shared v1.66 gameplay Wanderer authority.

const FRONTEND_R12_VERSION := "1.67-frontend-completion-r1.2"
const R12_FORGE_STRUCTURE := "res://assets/environment/v167/forge_workshop_structure.obj"
const R12_FORGE_TRIM := "res://assets/environment/v167/forge_workshop_trim.obj"
const R12_FORGE_EMBER := "res://assets/environment/v167/forge_workshop_ember.obj"

var r12_mesh_cache: Dictionary = {}
var r12_asset_instances := 0

func _rebuild_stage() -> void:
	r12_asset_instances = 0
	super._rebuild_stage()

func _load_r12_mesh(path: String) -> Mesh:
	if r12_mesh_cache.has(path):
		return r12_mesh_cache[path] as Mesh
	var mesh := load(path) as Mesh
	if mesh != null:
		r12_mesh_cache[path] = mesh
	return mesh

func _place_r12_mesh(
	node_name: String,
	path: String,
	material: Material,
	pos: Vector3,
	scale_value: Vector3 = Vector3.ONE,
	rot: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh := _load_r12_mesh(path)
	if mesh == null:
		push_warning("v1.67 r1.2 menu asset failed to load: %s" % path)
		return null
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.scale = scale_value
	instance.rotation = rot
	stage_root.add_child(instance)
	r12_asset_instances += 1
	return instance

func _build_forge_stage() -> void:
	super._build_forge_stage()

	# Retire the coarse focal cluster revealed by the r1.1 portrait capture.
	for node_name in [
		"ForgeHearthAsset",
		"ForgeEmberVFX",
		"ForgeEngineCompletionAsset",
		"ForgeAnvilAsset",
	]:
		var old_node := stage_root.get_node_or_null(node_name) as Node3D
		if old_node != null:
			old_node.visible = false

	# Keep the authored rack / columns as side dressing, but let the dedicated
	# three-material workshop kit own the center silhouette.
	var rack := stage_root.get_node_or_null("ForgeRackAsset") as Node3D
	if rack != null:
		rack.position = Vector3(2.55, 1.08, -3.02)
		rack.scale = Vector3.ONE * 0.58

	var focal_pos := Vector3(0.0, 0.26, -2.72)
	var focal_scale := Vector3.ONE * 0.88
	_place_r12_mesh("ForgeWorkshopR12", R12_FORGE_STRUCTURE, mat_stone_hi, focal_pos, focal_scale)
	_place_r12_mesh("ForgeWorkshopTrimR12", R12_FORGE_TRIM, mat_brass, focal_pos, focal_scale)
	_place_r12_mesh("ForgeWorkshopEmberR12", R12_FORGE_EMBER, mat_ember, focal_pos, focal_scale)

	_add_environment_light("ForgeR12FireKey", Vector3(-0.78, 2.22, -1.15), Color("ff8640"), 1.00, 4.2)
	_add_environment_light("ForgeR12WarmFill", Vector3(1.65, 2.75, 0.20), Color("e1c7a0"), 0.38, 3.8)
	_add_environment_light("ForgeR12SteelRim", Vector3(-2.10, 3.15, 0.05), Color("8aa0bd"), 0.20, 3.4)

func frontend_completion_ready() -> bool:
	if not super.frontend_completion_ready():
		return false
	if current_screen == "forge":
		return r12_asset_instances >= 3 \
			and ResourceLoader.exists(R12_FORGE_STRUCTURE) \
			and ResourceLoader.exists(R12_FORGE_TRIM) \
			and ResourceLoader.exists(R12_FORGE_EMBER)
	return true

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["frontend_completion_version"] = FRONTEND_R12_VERSION
	data["frontend_profile"] = "shared-gameplay-wanderer-authored-menu-r12"
	data["r12_asset_instances"] = r12_asset_instances
	data["forge_workshop_r12"] = current_screen != "forge" or r12_asset_instances >= 3
	data["frontend_completion_ready"] = frontend_completion_ready()
	return data

func _camera_position_for(screen: String) -> Vector3:
	match screen:
		"home": return Vector3(0.0, 2.72, 9.10)
		"hero": return Vector3(0.0, 3.02, 8.62)
		"forge": return Vector3(0.0, 2.55, 8.95)
		_: return super._camera_position_for(screen)

func _camera_target_for(screen: String) -> Vector3:
	match screen:
		"home": return Vector3(0.0, 2.28, -0.12)
		"hero": return Vector3(0.0, 2.94, -0.02)
		"forge": return Vector3(0.0, 1.98, -1.76)
		_: return super._camera_target_for(screen)
