extends "res://scripts/world3d_actor_factory_v160_polish.gd"

# ONE MORE FLOOR v1.60 — authored modular Wanderer geometry.
# Replaces the remaining rounded production primitives with imported OBJ parts
# mounted on the exact same articulated v1.55 glTF pivots. The imported glTF
# remains animation authority; gameplay roots, hitboxes, sockets and state
# selection are inherited unchanged.

const AUTHORED_WANDERER_VERSION := "1.60-authored-modular-wanderer"
const AUTHORED_ROOT := "res://assets/models/actors/v160/"
const AUTHORED_ASSETS := {
	"torso": AUTHORED_ROOT + "wanderer_torso.obj",
	"chestplate": AUTHORED_ROOT + "wanderer_chestplate.obj",
	"hood": AUTHORED_ROOT + "wanderer_hood.obj",
	"mask": AUTHORED_ROOT + "wanderer_mask.obj",
	"pauldron": AUTHORED_ROOT + "wanderer_pauldron.obj",
	"arm": AUTHORED_ROOT + "wanderer_arm.obj",
	"gauntlet": AUTHORED_ROOT + "wanderer_gauntlet.obj",
	"leg": AUTHORED_ROOT + "wanderer_leg.obj",
	"boot": AUTHORED_ROOT + "wanderer_boot.obj",
	"blade": AUTHORED_ROOT + "wanderer_blade.obj",
	"cape": AUTHORED_ROOT + "wanderer_cape.obj",
}

var authored_mesh_cache: Dictionary = {}
var authored_wanderer_instances := 0
var authored_wanderer_paths: Array[String] = []

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if imported_model_active(root):
		_mount_authored_wanderer(root)
	root.set_meta("wanderer_authored_v160", v160_authored_wanderer_ready(root))
	return root

func v160_authored_wanderer_ready(root: Node3D) -> bool:
	# The authored layer intentionally hides several visible meshes from the
	# intermediate polish stage, so readiness is anchored to the stable v1.60
	# articulated presentation contract rather than polish mesh visibility.
	if not v160_wanderer_presentation_ready(root):
		return false
	for path in AUTHORED_ASSETS.values():
		if not ResourceLoader.exists(String(path)):
			return false
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D if root != null else null
	if imported == null:
		return false
	return authored_wanderer_instances >= 16 \
		and _find_named_mesh(imported, "V160AuthoredTorso") != null \
		and _find_named_mesh(imported, "V160AuthoredHood") != null \
		and _find_named_mesh(imported, "V160AuthoredMask") != null \
		and _find_named_mesh(imported, "V160AuthoredCape") != null \
		and _find_named_mesh(imported, "V160AuthoredBlade") != null

func v160_authored_wanderer_snapshot(root: Node3D) -> Dictionary:
	return {
		"ready": v160_authored_wanderer_ready(root),
		"version": AUTHORED_WANDERER_VERSION,
		"instances": authored_wanderer_instances,
		"asset_paths": authored_wanderer_paths.duplicate(),
		"asset_count": AUTHORED_ASSETS.size(),
		"animation_authority": "v1.55-imported-gltf-pivots",
		"face_solution": "authored-mask-with-eye-slits",
	}

func _mount_authored_wanderer(root: Node3D) -> void:
	authored_wanderer_instances = 0
	authored_wanderer_paths.clear()
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		return

	var hips := _find_named_node3d(imported, "Hips")
	var head := _find_named_node3d(imported, "HeadPivot")
	var left_shoulder := _find_named_node3d(imported, "LeftShoulder")
	var right_shoulder := _find_named_node3d(imported, "RightShoulder")
	var left_arm := _find_named_node3d(imported, "LeftArm")
	var right_arm := _find_named_node3d(imported, "RightArm")
	var left_leg := _find_named_node3d(imported, "LeftLeg")
	var right_leg := _find_named_node3d(imported, "RightLeg")
	var sword := _find_named_node3d(imported, "SwordPivot")
	if hips == null or head == null or left_shoulder == null or right_shoulder == null \
		or left_arm == null or right_arm == null or left_leg == null or right_leg == null or sword == null:
		return

	# Retire the large rounded prototype/polish surfaces. Small readable details
	# such as belt hardware, sword grip and ArcaneCore stay on the same pivots.
	_hide_named_meshes(imported, [
		"V160Torso", "V160ChestArmor", "V160LowerArmor",
		"V160Hood", "V160HoodRim", "V160Brow", "V160FaceShadow",
		"V160Pauldron", "V160PauldronCap",
		"V160Arm", "V160Gauntlet",
		"V160Leg", "V160Knee", "V160Boot", "V160Toe",
		"V160Blade", "V160ProductionCape", "V160CapeHem",
	])

	_place_authored(hips, "V160AuthoredTorso", "torso", wanderer_materials["cloth"], Vector3(0.0, 0.12, 0.0), Vector3(0.96, 1.0, 0.92))
	_place_authored(hips, "V160AuthoredChestplate", "chestplate", wanderer_materials["steel_dark"], Vector3(0.0, -0.02, 0.02), Vector3(0.90, 0.92, 0.90))
	var cape := _place_authored(hips, "V160AuthoredCape", "cape", wanderer_materials["cape"], Vector3(0.0, 0.02, 0.25), Vector3(0.94, 1.0, 0.94))
	if cape != null:
		cape.rotation.x = -0.055

	var hood := _place_authored(head, "V160AuthoredHood", "hood", wanderer_materials["cloth"], Vector3(0.0, 0.0, 0.0), Vector3(0.92, 0.94, 0.92))
	if hood != null:
		hood.rotation.y = 0.0
	_place_authored(head, "V160AuthoredMask", "mask", wanderer_materials["void"], Vector3(0.0, -0.015, 0.0), Vector3(0.94, 0.94, 0.94))
	var eye_l := _box(head, "V160EyeSlitL", Vector3(0.066, 0.018, 0.012), Vector3(-0.067, -0.008, -0.282), wanderer_materials["arcane"])
	var eye_r := _box(head, "V160EyeSlitR", Vector3(0.066, 0.018, 0.012), Vector3(0.067, -0.008, -0.282), wanderer_materials["arcane"])
	eye_l.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	eye_r.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	# The pauldron asset is authored outward on +X. Right uses it directly;
	# left rotates 180° instead of negative scaling so triangle winding/culling
	# stays valid under GL Compatibility. Reduced scale avoids the prior robot read.
	var left_pauldron := _place_authored(left_shoulder, "V160AuthoredPauldronL", "pauldron", wanderer_materials["steel_dark"], Vector3.ZERO, Vector3(0.68, 0.80, 0.82))
	if left_pauldron != null:
		left_pauldron.rotation.y = PI
	var right_pauldron := _place_authored(right_shoulder, "V160AuthoredPauldronR", "pauldron", wanderer_materials["steel_dark"], Vector3.ZERO, Vector3(0.68, 0.80, 0.82))
	if right_pauldron != null:
		right_pauldron.rotation.y = 0.0

	for arm_data in [[left_arm, "L"], [right_arm, "R"]]:
		var arm_root := arm_data[0] as Node3D
		var suffix := String(arm_data[1])
		_place_authored(arm_root, "V160AuthoredArm%s" % suffix, "arm", wanderer_materials["cloth"], Vector3.ZERO, Vector3(0.90, 1.0, 0.90))
		_place_authored(arm_root, "V160AuthoredGauntlet%s" % suffix, "gauntlet", wanderer_materials["steel_dark"], Vector3(0.0, -0.34, -0.01), Vector3(0.88, 0.92, 0.88))

	for leg_data in [[left_leg, "L"], [right_leg, "R"]]:
		var leg_root := leg_data[0] as Node3D
		var suffix := String(leg_data[1])
		_place_authored(leg_root, "V160AuthoredLeg%s" % suffix, "leg", wanderer_materials["cloth"], Vector3.ZERO, Vector3(0.88, 1.0, 0.90))
		_place_authored(leg_root, "V160AuthoredBoot%s" % suffix, "boot", wanderer_materials["leather"], Vector3(0.0, -0.38, -0.055), Vector3(0.90, 0.92, 0.92))

	_place_authored(sword, "V160AuthoredBlade", "blade", wanderer_materials["blade"], Vector3(0.0, -0.02, 0.0), Vector3(0.94, 1.0, 0.94))

	var chest_sigil := _find_named_mesh(imported, "V160ChestSigil")
	if chest_sigil != null:
		chest_sigil.scale = Vector3(0.55, 0.72, 0.22)
	var belt := _find_named_mesh(imported, "V160Belt")
	if belt != null:
		belt.scale = Vector3(0.94, 0.68, 0.76)
	var clasp := _find_named_mesh(imported, "V160CapeClasp")
	if clasp != null:
		clasp.scale = Vector3(0.82, 0.52, 0.48)

	root.set_meta("wanderer_authored_geometry_v160", AUTHORED_WANDERER_VERSION)
	root.set_meta("wanderer_authored_instances_v160", authored_wanderer_instances)

func _load_authored_mesh(asset_key: String) -> Mesh:
	var path := String(AUTHORED_ASSETS.get(asset_key, ""))
	if path.is_empty():
		return null
	if authored_mesh_cache.has(path):
		return authored_mesh_cache[path] as Mesh
	var mesh := load(path) as Mesh
	if mesh != null:
		authored_mesh_cache[path] = mesh
	return mesh

func _place_authored(
	parent: Node3D,
	node_name: String,
	asset_key: String,
	material: Material,
	pos: Vector3,
	scale_value: Vector3
) -> MeshInstance3D:
	var mesh := _load_authored_mesh(asset_key)
	if mesh == null:
		push_warning("v1.60 authored Wanderer asset failed to load: %s" % asset_key)
		return null
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.scale = scale_value
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	instance.set_meta("wanderer_v160_authored_piece", true)
	parent.add_child(instance)
	authored_wanderer_instances += 1
	var path := String(AUTHORED_ASSETS.get(asset_key, ""))
	if path not in authored_wanderer_paths:
		authored_wanderer_paths.append(path)
	return instance

func _hide_named_meshes(node: Node, names: Array) -> void:
	if node == null:
		return
	if node is MeshInstance3D and names.has(String(node.name)):
		(node as MeshInstance3D).visible = false
	for child in node.get_children():
		_hide_named_meshes(child, names)
