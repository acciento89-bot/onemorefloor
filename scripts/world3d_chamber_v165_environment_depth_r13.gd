extends "res://scripts/world3d_chamber_v165_environment_depth_r12.gd"

# ONE MORE FLOOR v1.65 r1.3 — restraint/finalization pass.
# r1.2 made the environment material response meaningfully visible and fixed
# Rift/Starless, but large pale/rust faceted patches in Ossuary/Iron read like
# applied low-poly plates. r1.3 keeps the successful shader and endgame realms,
# while shrinking/darkening Lower/Ossuary/Iron wear into believable patina.

const ENVIRONMENT_DEPTH_R13_VERSION := "1.65-environment-depth-r1.3"

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_environment_depth_version"] = ENVIRONMENT_DEPTH_R13_VERSION
	data["production_environment_r13"] = true
	return data

func _build_v165_materials() -> void:
	# Keep r1.2's successful material-first response across all five realms.
	v165_lower_stone = _v165_surface(Color("171a22"), Color("505c70"), 0.10, 0.88, 1.58, 0.38, 0.050, 0.11)
	v165_lower_brass = _v165_surface(Color("51351b"), Color("936432"), 0.70, 0.44, 2.45, 0.22, 0.042, 0.08)
	v165_ossuary_stone = _v165_surface(Color("13191a"), Color("4b5b5e"), 0.04, 0.94, 1.78, 0.37, 0.042, 0.14)
	v165_ossuary_bone = _v165_surface(Color("504e48"), Color("8c8576"), 0.02, 0.97, 2.65, 0.20, 0.026, 0.08)
	v165_iron_plate = _v165_surface(Color("1d2229"), Color("6b7788"), 0.78, 0.40, 1.95, 0.36, 0.052, 0.12)
	v165_iron_oxidized = _v165_surface(Color("322821"), Color("8a5b40"), 0.56, 0.58, 2.65, 0.34, 0.040, 0.12)
	v165_rift_stone = _v165_surface(Color("090a11"), Color("4b305d"), 0.10, 0.92, 2.08, 0.38, 0.042, 0.10)
	v165_rift_crystal = _v165_surface(Color("302046"), Color("8053aa"), 0.20, 0.38, 2.85, 0.24, 0.050, 0.05, Color("5e3d8a"), 0.12)
	v165_spire_stone = _v165_surface(Color("080c15"), Color("40577d"), 0.32, 0.70, 1.78, 0.38, 0.050, 0.10)
	v165_spire_inlay = _v165_surface(Color("151e34"), Color("506b9e"), 0.42, 0.44, 3.05, 0.22, 0.046, 0.04, Color("405f95"), 0.08)

	# r1.3 stain materials sit much closer to the host surface than r1.2. Their
	# purpose is local patina/soot/dust, not a second visible floor tile layer.
	v165_lower_wear = _v165_surface(Color("14171e"), Color("2b323e"), 0.04, 0.96, 2.90, 0.20, 0.018, 0.14)
	v165_ossuary_dust = _v165_surface(Color("202624"), Color("3c4843"), 0.01, 0.99, 3.20, 0.16, 0.015, 0.10)
	v165_iron_rust = _v165_surface(Color("261b18"), Color("503328"), 0.32, 0.82, 3.15, 0.24, 0.020, 0.14)
	v165_rift_scorch = _v165_surface(Color("08070d"), Color("25182e"), 0.02, 0.98, 2.75, 0.26, 0.020, 0.16)
	v165_spire_wear = _v165_surface(Color("080b12"), Color("27364f"), 0.16, 0.88, 2.85, 0.26, 0.022, 0.14)

func _build_v165_lower_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	_add_v165_box(root_node, "V165LowerCurbL", Vector3(0.18, 0.10, 10.9), Vector3(-4.28, 0.015, 0.05), v165_lower_stone)
	_add_v165_box(root_node, "V165LowerCurbR", Vector3(0.18, 0.10, 10.9), Vector3(4.28, 0.015, 0.05), v165_lower_stone)
	for index in range(10):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.72 + float(index) * 1.05
		var x := side * (3.02 + 0.20 * float(index % 3))
		_add_v165_box(root_node, "V165LowerChipR13_%02d" % index, Vector3(0.17 + 0.035 * float(index % 3), 0.050, 0.13 + 0.025 * float(index % 2)), Vector3(x, 0.013, z), v165_lower_stone, side * (0.20 + 0.10 * float(index)))
	for index in range(7):
		var x := -2.45 + float(index % 4) * 1.58 + 0.13 * float(index % 2)
		var z := -4.05 + float(index / 4) * 5.20 + 0.42 * float(index % 3)
		_add_v165_patch(root_node, "V165LowerWearR13_%02d" % index, 0.31 + 0.045 * float(index % 3), Vector3(x, 0.007, z), v165_lower_wear, Vector2(1.35 + 0.12 * float(index % 2), 0.42 + 0.06 * float(index % 3)), 0.22 * float(index - 3))
	for index in range(6):
		var side := -1.0 if index % 2 == 0 else 1.0
		_add_v165_patch(root_node, "V165LowerBrassChipR13_%02d" % index, 0.095 + 0.012 * float(index % 2), Vector3(side * (1.55 + 0.34 * float(index % 3)), 0.009, -3.75 + float(index) * 1.48), v165_lower_brass, Vector2(1.25, 0.56), side * (0.20 + 0.08 * float(index)))

func _build_v165_ossuary_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	_add_v165_box(root_node, "V165OssuaryCurbL", Vector3(0.16, 0.085, 10.7), Vector3(-4.05, 0.012, 0.0), v165_ossuary_stone)
	_add_v165_box(root_node, "V165OssuaryCurbR", Vector3(0.16, 0.085, 10.7), Vector3(4.05, 0.012, 0.0), v165_ossuary_stone)
	for index in range(12):
		var side := -1.0 if index % 2 == 0 else 1.0
		var z := -4.78 + float(index / 2) * 1.83 + 0.13 * float(index % 3)
		_add_v165_box(root_node, "V165BoneFragmentR13_%02d" % index, Vector3(0.16 + 0.03 * float(index % 3), 0.044, 0.065), Vector3(side * (3.00 + 0.17 * float(index % 2)), 0.013, z), v165_ossuary_bone, side * (0.30 + 0.09 * float(index)))
	for index in range(8):
		var x := -2.35 + float(index % 4) * 1.52 + 0.12 * float(index % 2)
		var z := -4.00 + float(index / 4) * 4.90 + 0.38 * float(index % 3)
		_add_v165_patch(root_node, "V165OssuaryDustR13_%02d" % index, 0.29 + 0.045 * float(index % 3), Vector3(x, 0.007, z), v165_ossuary_dust, Vector2(1.30 + 0.10 * float(index % 2), 0.38 + 0.055 * float(index % 3)), 0.25 * float(index - 3))
	for index in range(6):
		var side := -1.0 if index % 2 == 0 else 1.0
		_add_v165_patch(root_node, "V165OssuaryChipWearR13_%02d" % index, 0.22, Vector3(side * (0.92 + 0.30 * float(index % 2)), 0.008, -3.45 + float(index) * 1.42), v165_ossuary_stone, Vector2(1.20, 0.40), side * 0.22)

func _build_v165_iron_depth(root_node: Node3D) -> void:
	if root_node == null:
		return
	_add_v165_box(root_node, "V165IronRailL", Vector3(0.16, 0.09, 10.8), Vector3(-4.18, 0.015, 0.05), v165_iron_oxidized)
	_add_v165_box(root_node, "V165IronRailR", Vector3(0.16, 0.09, 10.8), Vector3(4.18, 0.015, 0.05), v165_iron_oxidized)
	for row in range(4):
		var z := -4.55 + float(row) * 3.02
		for side_value in [-1.0, 1.0]:
			var side := float(side_value)
			for rivet in range(2):
				var x := side * (2.50 + float(rivet) * 0.62)
				_add_v165_box(root_node, "V165IronRivetR13_%d_%d_%d" % [row, int(side), rivet], Vector3(0.10, 0.060, 0.10), Vector3(x, 0.018, z), v165_iron_plate, 0.785)
	for index in range(9):
		var x := -2.40 + float(index % 5) * 1.18 + 0.10 * float(index % 2)
		var z := -4.00 + float(index / 5) * 5.00 + 0.34 * float(index % 3)
		_add_v165_patch(root_node, "V165IronRustR13_%02d" % index, 0.27 + 0.04 * float(index % 3), Vector3(x, 0.008, z), v165_iron_rust, Vector2(1.25 + 0.10 * float(index % 2), 0.38 + 0.05 * float(index % 3)), 0.27 * float(index - 4))
	for index in range(8):
		var side := -1.0 if index % 2 == 0 else 1.0
		_add_v165_box(root_node, "V165IronScrapR13_%02d" % index, Vector3(0.24 + 0.04 * float(index % 3), 0.045, 0.12 + 0.025 * float(index % 2)), Vector3(side * 3.28, 0.013, -3.75 + float(index) * 1.12), v165_iron_oxidized, side * (0.18 + 0.08 * float(index)))
