extends "res://scripts/world3d_chamber_v165_environment_depth.gd"

# ONE MORE FLOOR v1.65 r1.1 — visual correction.
# r1 proved the surface/depth path technically, but long bright floor strips in
# Lower Halls / Rift / Starless read like prototype debug bars. r1.1 keeps the
# same presentation-only architecture while replacing those strips with short,
# broken, asymmetric details and slightly stronger dark material variation.

const ENVIRONMENT_DEPTH_R11_VERSION := "1.65-environment-depth-r1.1"

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_environment_depth_version"] = ENVIRONMENT_DEPTH_R11_VERSION
	data["production_environment_r11"] = true
	return data

func _build_v165_materials() -> void:
	v165_lower_stone = _v165_surface(Color("181b23"), Color("465064"), 0.10, 0.88, 1.70, 0.31, 0.048, 0.11)
	v165_lower_brass = _v165_surface(Color("5b3b1d"), Color("9a6b35"), 0.70, 0.42, 2.30, 0.18, 0.045, 0.08)
	v165_ossuary_stone = _v165_surface(Color("151a1b"), Color("405055"), 0.04, 0.94, 1.95, 0.30, 0.040, 0.14)
	v165_ossuary_bone = _v165_surface(Color("56534c"), Color("817b6e"), 0.02, 0.97, 2.70, 0.16, 0.026, 0.08)
	v165_iron_plate = _v165_surface(Color("20242b"), Color("626d7c"), 0.78, 0.38, 2.10, 0.28, 0.052, 0.12)
	v165_iron_oxidized = _v165_surface(Color("352a24"), Color("80543d"), 0.58, 0.55, 2.80, 0.27, 0.042, 0.12)
	v165_rift_stone = _v165_surface(Color("0b0a12"), Color("40284f"), 0.10, 0.91, 2.30, 0.30, 0.042, 0.10)
	v165_rift_crystal = _v165_surface(Color("34204b"), Color("8759b5"), 0.20, 0.36, 3.00, 0.22, 0.052, 0.05, Color("67419a"), 0.24)
	v165_spire_stone = _v165_surface(Color("090d16"), Color("354a6c"), 0.32, 0.68, 1.95, 0.30, 0.050, 0.10)
	v165_spire_inlay = _v165_surface(Color("172037"), Color("526eaa"), 0.42, 0.42, 3.20, 0.19, 0.048, 0.04, Color("4868a6"), 0.14)

func _build_v165_lower_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	_add_v165_box(root_node, "V165LowerCurbL", Vector3(0.18, 0.10, 10.9), Vector3(-4.28, 0.015, 0.05), v165_lower_stone)
	_add_v165_box(root_node, "V165LowerCurbR", Vector3(0.18, 0.10, 10.9), Vector3(4.28, 0.015, 0.05), v165_lower_stone)
	for index in range(6):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.65 + float(index) * 1.78
		var x := side * (3.08 + 0.24 * float(index % 3))
		_add_v165_box(
			root_node,
			"V165LowerRubbleR11_%02d" % index,
			Vector3(0.28 + 0.06 * float(index % 3), 0.075, 0.20 + 0.04 * float(index % 2)),
			Vector3(x, 0.018, z),
			v165_lower_stone,
			side * (0.19 + 0.08 * float(index))
		)
	for index in range(8):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.25 + float(index / 2) * 2.45 + 0.18 * float(index % 3)
		var x := side * (1.85 + 0.34 * float(index % 2))
		var length := 0.62 + 0.14 * float(index % 4)
		_add_v165_box(
			root_node,
			"V165LowerBrokenInset_%02d" % index,
			Vector3(length, 0.018, 0.045),
			Vector3(x, 0.006, z),
			v165_lower_brass,
			side * (0.08 + 0.045 * float(index % 3))
		)

func _build_v165_ossuary_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	_add_v165_box(root_node, "V165OssuaryCurbL", Vector3(0.16, 0.085, 10.7), Vector3(-4.05, 0.012, 0.0), v165_ossuary_stone)
	_add_v165_box(root_node, "V165OssuaryCurbR", Vector3(0.16, 0.085, 10.7), Vector3(4.05, 0.012, 0.0), v165_ossuary_stone)
	for index in range(8):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.75 + float(index / 2) * 3.0 + 0.22 * float(index % 3)
		_add_v165_box(
			root_node,
			"V165BoneFragmentR11_%02d" % index,
			Vector3(0.23 + 0.04 * float(index % 3), 0.050, 0.085),
			Vector3(side * (3.12 + 0.16 * float(index % 2)), 0.015, z),
			v165_ossuary_bone,
			side * (0.31 + 0.09 * float(index))
		)
	for index in range(6):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -3.55 + float(index / 2) * 3.45 + 0.14 * float(index % 2)
		var x := side * (0.38 + 0.22 * float(index % 3))
		_add_v165_box(
			root_node,
			"V165GraveSeamR11_%02d" % index,
			Vector3(0.48 + 0.10 * float(index % 3), 0.018, 0.050),
			Vector3(x, 0.006, z),
			v165_ossuary_bone,
			side * 0.08
		)

func _build_v165_rift_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	for index in range(12):
		var side := -1.0 if index % 2 == 0 else 1.0
		var row := int(index / 2)
		var z := -4.72 + float(row) * 1.72 + 0.16 * float(index % 3)
		var x := side * (0.55 + 0.34 * float((index + row) % 4))
		var length := 0.34 + 0.11 * float(index % 5)
		_add_v165_box(
			root_node,
			"V165RiftFractureR11_%02d" % index,
			Vector3(length, 0.014, 0.040),
			Vector3(x, 0.007, z),
			v165_rift_crystal,
			side * (0.18 + 0.09 * float(index % 4))
		)
	for index in range(8):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.35 + float(index) * 1.18
		var x := side * (2.82 + 0.20 * float(index % 3))
		_add_v165_box(
			root_node,
			"V165RiftShardR11_%02d" % index,
			Vector3(0.18 + 0.035 * float(index % 3), 0.080, 0.25 + 0.04 * float(index % 2)),
			Vector3(x, 0.018, z),
			v165_rift_stone,
			side * (0.34 + 0.10 * float(index))
		)

func _build_v165_spire_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	for index in range(12):
		var side := -1.0 if index % 2 == 0 else 1.0
		var row := int(index / 2)
		var z := -4.55 + float(row) * 1.72 + 0.12 * float(index % 3)
		var x := side * (0.72 + 0.38 * float((index + 1) % 4))
		var length := 0.36 + 0.12 * float(index % 4)
		_add_v165_box(
			root_node,
			"V165SpireInlayR11_%02d" % index,
			Vector3(length, 0.014, 0.040),
			Vector3(x, 0.008, z),
			v165_spire_inlay,
			side * (0.10 + 0.055 * float(index % 4))
		)
	for index in range(8):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.7 + float(index / 2) * 2.85 + 0.16 * float(index % 3)
		_add_v165_box(
			root_node,
			"V165SpireGlyphR11_%02d" % index,
			Vector3(0.14, 0.040, 0.14),
			Vector3(side * 3.28, 0.018, z),
			v165_spire_inlay,
			0.785 + side * 0.08
		)
	_add_v165_box(root_node, "V165SpireRailL", Vector3(0.12, 0.075, 10.6), Vector3(-3.63, 0.012, 0.10), v165_spire_stone)
	_add_v165_box(root_node, "V165SpireRailR", Vector3(0.12, 0.075, 10.6), Vector3(3.63, 0.012, 0.10), v165_spire_stone)
