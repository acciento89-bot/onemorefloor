extends "res://scripts/world3d_actor_factory_v160_enemy_quality_r3.gd"

# ONE MORE FLOOR v1.60 — enemy surface/detail polish r4.
# Keeps accepted r2/r3 anatomy untouched. Adds only thin secondary production
# planes/straps/bones/trims with existing material classes so the five enemies
# stop reading as one-material clay at gameplay distance. Skeleton stays locked.

const ENEMY_SURFACE_R4_VERSION := "1.60-enemy-surface-detail-r4"
const ENEMY_SURFACE_R4_NODE := "EnemyQualityDetailR4"

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	if root == null or imported_model_active(root):
		return
	_apply_enemy_surface_r4(root, kind)
	root.set_meta("enemy_surface_detail_r4", kind != "skeleton")
	root.set_meta("enemy_surface_detail_r4_version", ENEMY_SURFACE_R4_VERSION)

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	var data: Dictionary = super.character_quality_snapshot(root)
	data["enemy_surface_detail_r4_version"] = ENEMY_SURFACE_R4_VERSION
	data["enemy_surface_detail_r4_focus"] = ["goblin", "bat", "ghoul", "necromancer", "warden"]
	data["enemy_surface_detail_profile"] = "thin-secondary-material-breakup-r4"
	return data

func _apply_enemy_surface_r4(root: Node3D, kind: String) -> void:
	var layer := root.get_node_or_null("Motion/Visual/EnemyPresentationV160") as Node3D
	if layer == null:
		return
	var previous := layer.get_node_or_null(ENEMY_SURFACE_R4_NODE)
	if previous != null:
		layer.remove_child(previous)
		previous.queue_free()
	if kind == "skeleton":
		return

	var detail := Node3D.new()
	detail.name = ENEMY_SURFACE_R4_NODE
	detail.set_meta("version", ENEMY_SURFACE_R4_VERSION)
	detail.set_meta("kind", kind)
	layer.add_child(detail)

	match kind:
		"goblin": _detail_goblin(detail)
		"bat": _detail_bat(detail)
		"ghoul": _detail_ghoul(detail)
		"necromancer": _detail_necromancer(detail)
		"warden": _detail_warden(detail)

	detail.set_meta("mesh_count", detail.get_child_count())

func _detail_goblin(detail: Node3D) -> void:
	var leather: Material = enemy_v160_materials["leather"]
	var iron: Material = enemy_v160_materials["scrap_iron"]
	# Thin crossed harness, narrow belt and one battered bracer. These are
	# deliberately flat accents, not replacement torso/arm geometry.
	_detail_bar(detail, "GoblinHarnessR4A", Vector3(-0.17, 0.93, -0.205), Vector3(0.13, 0.61, -0.205), 0.052, 0.038, leather)
	_detail_bar(detail, "GoblinHarnessR4B", Vector3(0.15, 0.88, -0.207), Vector3(-0.08, 0.66, -0.207), 0.038, 0.034, leather)
	_e_box(detail, "GoblinBeltR4", Vector3(0.35, 0.055, 0.050), Vector3(0.0, 0.54, -0.185), leather)
	var bracer := _e_box(detail, "GoblinBracerR4", Vector3(0.105, 0.16, 0.095), Vector3(-0.34, 0.61, -0.13), iron)
	bracer.rotation.z = -0.16

func _detail_bat(detail: Node3D) -> void:
	var bone: Material = enemy_v160_materials["bat_body"]
	# r3 authored membranes already own the wing silhouette. r4 adds only the
	# visible leading/finger bones so the wing reads as structure + membrane.
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var shoulder := Vector3(side * 0.16, 1.02, -0.005)
		var elbow := Vector3(side * 0.56, 1.06, 0.005)
		var wrist := Vector3(side * 0.98, 0.91, 0.020)
		var tip := Vector3(side * 1.34, 0.78, 0.038)
		_detail_bar(detail, "BatWingBoneR4A", shoulder, elbow, 0.034, 0.050, bone)
		_detail_bar(detail, "BatWingBoneR4B", elbow, wrist, 0.032, 0.048, bone)
		_detail_bar(detail, "BatWingBoneR4C", wrist, tip, 0.026, 0.044, bone)
	_e_box(detail, "BatSternumR4", Vector3(0.075, 0.30, 0.050), Vector3(0.0, 0.86, -0.135), bone)

func _detail_ghoul(detail: Node3D) -> void:
	var dark: Material = enemy_v160_materials["ghoul_dark"]
	var bone: Material = enemy_v160_materials["bone_dark"]
	# Shallow rib shadows and short clavicle/bone planes break the flesh mass
	# without bringing back the rejected block jaw/spine overlays from r1.
	for index in range(3):
		var width := 0.33 - float(index) * 0.045
		var rib := _e_box(detail, "GhoulRibShadowR4%d" % index, Vector3(width, 0.038, 0.040), Vector3(0.0, 0.86 - float(index) * 0.12, -0.255), dark)
		rib.rotation.z = (float(index) - 1.0) * 0.035
	_detail_bar(detail, "GhoulClavicleR4L", Vector3(-0.22, 1.02, -0.215), Vector3(-0.035, 0.94, -0.245), 0.030, 0.034, bone)
	_detail_bar(detail, "GhoulClavicleR4R", Vector3(0.22, 1.02, -0.215), Vector3(0.035, 0.94, -0.245), 0.030, 0.034, bone)

func _detail_necromancer(detail: Node3D) -> void:
	var hood: Material = enemy_v160_materials["necro_hood"]
	var robe: Material = enemy_v160_materials["necro_robe"]
	var iron: Material = enemy_v160_materials["aged_iron"]
	# Dark mantle edge, long front seams and a restrained clasp make the robe
	# read as layered cloth instead of one purple solid.
	var mantle := _e_wedge(detail, "NecroMantleR4", 0.52, 0.18, 0.045, Vector3(0.0, 1.25, -0.245), hood)
	mantle.rotation.x = -0.05
	_detail_bar(detail, "NecroRobeSeamR4L", Vector3(-0.11, 0.78, -0.205), Vector3(-0.18, 0.18, -0.175), 0.025, 0.030, hood)
	_detail_bar(detail, "NecroRobeSeamR4R", Vector3(0.11, 0.78, -0.205), Vector3(0.18, 0.18, -0.175), 0.025, 0.030, hood)
	_e_box(detail, "NecroWaistBandR4", Vector3(0.36, 0.045, 0.040), Vector3(0.0, 0.79, -0.175), robe)
	_e_box(detail, "NecroClaspR4", Vector3(0.055, 0.065, 0.030), Vector3(0.0, 1.23, -0.285), iron)

func _detail_warden(detail: Node3D) -> void:
	var iron: Material = enemy_v160_materials["warden_iron"]
	var armor: Material = enemy_v160_materials["warden_armor"]
	# Thin front plate/trim, waist line and knee caps add metal hierarchy while
	# the r2 authored body remains the sole anatomy/silhouette authority.
	var chest := _e_wedge(detail, "WardenChestPlateR4", 0.28, 0.34, 0.055, Vector3(0.0, 1.19, -0.245), iron)
	chest.rotation.x = -0.03
	_e_box(detail, "WardenBeltR4", Vector3(0.42, 0.055, 0.050), Vector3(0.0, 0.78, -0.185), armor)
	for side_value in [-1.0, 1.0]:
		var side := float(side_value)
		var knee := _e_box(detail, "WardenKneeR4", Vector3(0.13, 0.115, 0.075), Vector3(side * 0.15, 0.42, -0.195), iron)
		knee.rotation.z = side * -0.04
		_detail_bar(detail, "WardenShoulderTrimR4", Vector3(side * 0.13, 1.40, -0.205), Vector3(side * 0.31, 1.32, -0.185), 0.030, 0.038, iron)

func _detail_bar(parent: Node3D, name_value: String, start: Vector3, finish: Vector3, thickness: float, depth: float, material: Material) -> MeshInstance3D:
	var delta := finish - start
	var midpoint := (start + finish) * 0.5
	var length_xy := Vector2(delta.x, delta.y).length()
	var bar := _e_box(parent, name_value, Vector3(maxf(length_xy, 0.01), thickness, depth), midpoint, material)
	bar.rotation.z = atan2(delta.y, delta.x)
	return bar
