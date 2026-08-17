extends "res://scripts/world3d_actor_factory_v148.gd"

# ONE MORE FLOOR v1.49 — production art / asset gate actor factory.
# Strengthens the visible native art today and adds a measurable contract for
# real imported GLB characters tomorrow. Gameplay timing remains untouched.

const AssetQualityGate = preload("res://scripts/world3d_asset_quality_v149.gd")

var asset_quality := AssetQualityGate.new()

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if not imported_model_active(root):
		_upgrade_player_art_v149(root, materials)
	root.set_meta("actor_art_v149", true)
	root.set_meta("asset_quality_report", production_asset_report(root))
	return root

func create_enemy_shell(index: int) -> Node3D:
	var root: Node3D = super.create_enemy_shell(index)
	root.set_meta("actor_art_v149", true)
	return root

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	if not imported_model_active(root):
		_upgrade_enemy_art_v149(root, kind, materials)
	root.set_meta("actor_art_v149", true)
	root.set_meta("asset_quality_report", production_asset_report(root))

func animate_player(root: Node3D, elapsed: float, move_amount: float, attack_amount: float, skill_amount: float) -> void:
	super.animate_player(root, elapsed, move_amount, attack_amount, skill_amount)
	if root == null or imported_model_active(root):
		return
	var art := root.get_node_or_null("Motion/ProductionArtV149") as Node3D
	if art == null:
		return
	art.rotation.z = sin(elapsed * 4.6) * 0.008 * clampf(move_amount, 0.0, 1.0)
	var emblem := art.get_node_or_null("HeroEmblem") as MeshInstance3D
	if emblem != null:
		var pulse: float = 1.0 + sin(elapsed * 5.2) * 0.05 + skill_amount * 0.18
		emblem.scale = Vector3.ONE * pulse
	for index in range(5):
		var hem := art.get_node_or_null("CapeHem%d" % index) as MeshInstance3D
		if hem != null:
			hem.rotation.x = -0.16 - move_amount * 0.10 + sin(elapsed * 5.6 + float(index) * 0.55) * 0.045
	var weapon := root.get_node_or_null("WeaponPivot") as Node3D
	if weapon != null:
		var edge := weapon.get_node_or_null("V149BladeEdge") as MeshInstance3D
		if edge != null:
			var edge_pulse: float = 1.0 + attack_amount * 0.30 + skill_amount * 0.42
			edge.scale = Vector3(edge_pulse, 1.0, 1.0)

func animate_enemy(root: Node3D, elapsed: float, phase: float, tell: float, hit: float, index: int) -> void:
	super.animate_enemy(root, elapsed, phase, tell, hit, index)
	if root == null or imported_model_active(root):
		return
	var art := root.get_node_or_null("Motion/Visual/ProductionArtV149") as Node3D
	if art == null:
		return
	var kind: String = String(root.get_meta("actor_kind", "enemy"))
	var tell_drive: float = clampf(tell, 0.0, 1.0)
	var hit_drive: float = clampf(hit, 0.0, 1.0)
	var wave: float = sin(elapsed * 4.0 + phase + float(index) * 0.33)
	art.position = Vector3.ZERO
	art.rotation = Vector3.ZERO
	match kind:
		"goblin":
			art.rotation.y = tell_drive * 0.10 + wave * 0.018
		"bat":
			art.rotation.z = wave * 0.08
		"skeleton":
			art.rotation.x = -tell_drive * 0.04
		"ghoul":
			art.position.z = -tell_drive * 0.04
		"necromancer":
			art.position.y = sin(elapsed * 3.0 + phase) * 0.025
			art.rotation.y = elapsed * 0.10
		"warden":
			art.scale = Vector3.ONE * (1.0 + tell_drive * 0.018)
		_:
			pass
	if kind != "warden":
		art.scale = Vector3.ONE
	if hit_drive > 0.02:
		art.rotation.z += sin(elapsed * 38.0 + float(index)) * 0.025 * hit_drive

func production_asset_report(root: Node3D) -> Dictionary:
	return asset_quality.inspect_actor(root, model_registry)

func asset_quality_snapshot() -> Dictionary:
	var data: Dictionary = asset_quality.snapshot()
	data["registry"] = production_registry_snapshot()
	return data

func production_art_ready(root: Node3D) -> bool:
	if root == null or not bool(root.get_meta("actor_art_v149", false)):
		return false
	var report: Dictionary = production_asset_report(root)
	return bool(report.get("ready", false))

func _upgrade_player_art_v149(root: Node3D, materials: Dictionary) -> void:
	if root == null or bool(root.get_meta("v149_player_art", false)):
		return
	var motion := root.get_node_or_null("Motion") as Node3D
	if motion == null:
		return
	var art := Node3D.new()
	art.name = "ProductionArtV149"
	motion.add_child(art)

	# Layered torso armor and bright readable centerline.
	_add_box(art, "Breastplate", Vector3(0.54, 0.46, 0.18), Vector3(0.0, 0.96, -0.19), materials["steel_dark"])
	_add_box(art, "BreastplateInset", Vector3(0.30, 0.30, 0.055), Vector3(0.0, 0.98, -0.305), materials["cloth_dark"])
	_add_box(art, "GoldCenterline", Vector3(0.055, 0.42, 0.04), Vector3(0.0, 0.98, -0.345), materials["gold"])
	_add_box(art, "HeroEmblem", Vector3(0.16, 0.16, 0.045), Vector3(0.0, 1.04, -0.375), materials["glow_purple"])

	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		_add_box(art, "UpperArmPlate", Vector3(0.16, 0.32, 0.18), Vector3(side * 0.36, 0.94, -0.02), materials["steel"])
		_add_box(art, "BracerGold", Vector3(0.12, 0.20, 0.13), Vector3(side * 0.42, 0.67, -0.05), materials["gold"])
		_add_box(art, "BootCap", Vector3(0.22, 0.12, 0.30), Vector3(side * 0.18, 0.12, -0.08), materials["steel_dark"])

	# Segmented cape hem gives the low-poly fallback a more authored silhouette.
	for index in range(5):
		var x: float = (float(index) - 2.0) * 0.14
		var hem: MeshInstance3D = _add_box(art, "CapeHem%d" % index, Vector3(0.13, 0.42, 0.055), Vector3(x, 0.50, 0.34), materials["cloth"])
		hem.rotation.x = -0.16
		if index == 0 or index == 4:
			hem.rotation.z = -0.08 if index == 0 else 0.08

	var weapon := root.get_node_or_null("WeaponPivot") as Node3D
	if weapon != null:
		_add_box(weapon, "V149BladeEdge", Vector3(0.020, 0.075, 0.94), Vector3(0.034, 0.0, -0.70), materials["steel_bright"])
		_add_box(weapon, "V149Crossguard", Vector3(0.42, 0.07, 0.07), Vector3(0.0, 0.0, -0.18), materials["gold"])
		_add_sphere(weapon, "V149PommelRune", 0.075, Vector3(0.0, 0.0, 0.10), materials["glow_purple"], 8, 4)
	root.set_meta("v149_player_art", true)

func _upgrade_enemy_art_v149(root: Node3D, kind: String, materials: Dictionary) -> void:
	if root == null or String(root.get_meta("v149_enemy_art_kind", "")) == kind:
		return
	var visual := root.get_node_or_null("Motion/Visual") as Node3D
	if visual == null:
		return
	var old := visual.get_node_or_null("ProductionArtV149")
	if old != null:
		old.queue_free()
	var art := Node3D.new()
	art.name = "ProductionArtV149"
	visual.add_child(art)
	match kind:
		"goblin": _art_goblin_v149(art, visual, materials)
		"bat": _art_bat_v149(art, materials)
		"skeleton": _art_skeleton_v149(art, visual, materials)
		"ghoul": _art_ghoul_v149(art, materials)
		"necromancer": _art_necromancer_v149(art, materials)
		"warden": _art_warden_v149(art, visual, materials)
		_: _art_generic_v149(art, materials)
	root.set_meta("v149_enemy_art_kind", kind)

func _art_goblin_v149(art: Node3D, visual: Node3D, materials: Dictionary) -> void:
	_add_box(art, "BrowPlate", Vector3(0.38, 0.10, 0.16), Vector3(0.0, 1.05, -0.20), materials["steel_dark"])
	_add_box(art, "ChestScrap", Vector3(0.42, 0.28, 0.12), Vector3(0.0, 0.67, -0.20), materials["leather"])
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		var spike: MeshInstance3D = _add_box(art, "ShoulderSpike", Vector3(0.08, 0.28, 0.08), Vector3(side * 0.34, 0.78, 0.0), materials["steel_bright"])
		spike.rotation.z = side * 0.45
	var weapon := visual.get_node_or_null("WeaponPivot") as Node3D
	if weapon != null:
		_add_box(weapon, "V149GoblinEdge", Vector3(0.035, 0.07, 0.54), Vector3(0.02, 0.0, -0.40), materials["glow_gold"])

func _art_bat_v149(art: Node3D, materials: Dictionary) -> void:
	_add_sphere(art, "HeartCore", 0.105, Vector3(0.0, 0.70, -0.17), materials["glow_purple"], 8, 4)
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		for index in range(3):
			var rib: MeshInstance3D = _add_box(art, "WingRib", Vector3(0.06, 0.06, 0.58), Vector3(side * (0.38 + float(index) * 0.18), 0.72 - float(index) * 0.05, 0.02), materials["purple"])
			rib.rotation.y = side * (0.50 + float(index) * 0.10)
			rib.rotation.z = side * -0.14

func _art_skeleton_v149(art: Node3D, visual: Node3D, materials: Dictionary) -> void:
	for index in range(4):
		_add_box(art, "RibPlate", Vector3(0.42 - float(index) * 0.045, 0.055, 0.10), Vector3(0.0, 0.91 - float(index) * 0.10, -0.16), materials["bone"])
	_add_box(art, "HelmBrow", Vector3(0.42, 0.09, 0.15), Vector3(0.0, 1.34, -0.16), materials["steel_dark"])
	_add_box(art, "SternumRune", Vector3(0.10, 0.22, 0.035), Vector3(0.0, 0.86, -0.235), materials["glow_gold"])
	var offhand := visual.get_node_or_null("OffhandPivot") as Node3D
	if offhand != null:
		_add_box(offhand, "V149ShieldMark", Vector3(0.18, 0.20, 0.04), Vector3(0.0, 0.0, -0.08), materials["glow_gold"])

func _art_ghoul_v149(art: Node3D, materials: Dictionary) -> void:
	for index in range(4):
		_add_box(art, "SpinePlate", Vector3(0.16, 0.10, 0.24), Vector3(0.0, 1.08 - float(index) * 0.18, 0.20), materials["bone_dark"])
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		var claw: MeshInstance3D = _add_box(art, "ClawEdge", Vector3(0.07, 0.06, 0.46), Vector3(side * 0.43, 0.52, -0.20), materials["glow_red"])
		claw.rotation.y = side * 0.22
	_add_box(art, "ToxicCore", Vector3(0.16, 0.20, 0.04), Vector3(0.0, 0.82, -0.29), materials["glow_purple"])

func _art_necromancer_v149(art: Node3D, materials: Dictionary) -> void:
	for index in range(5):
		var angle: float = TAU * float(index) / 5.0
		var crown: MeshInstance3D = _add_box(art, "CrownSpike", Vector3(0.055, 0.34, 0.055), Vector3(cos(angle) * 0.25, 1.52 + sin(angle) * 0.03, sin(angle) * 0.20), materials["gold"])
		crown.rotation.z = cos(angle) * 0.22
	_add_box(art, "ArcaneTome", Vector3(0.34, 0.08, 0.44), Vector3(-0.42, 0.78, -0.10), materials["leather"])
	_add_box(art, "TomeRune", Vector3(0.16, 0.035, 0.20), Vector3(-0.42, 0.735, -0.10), materials["glow_purple"])
	_add_box(art, "RobeGoldLine", Vector3(0.055, 0.58, 0.035), Vector3(0.0, 0.72, -0.31), materials["gold"])

func _art_warden_v149(art: Node3D, visual: Node3D, materials: Dictionary) -> void:
	_add_box(art, "BossBreastplate", Vector3(0.82, 0.54, 0.18), Vector3(0.0, 1.10, -0.26), materials["steel_dark"])
	_add_box(art, "BossChestInset", Vector3(0.46, 0.34, 0.055), Vector3(0.0, 1.11, -0.38), materials["warden"])
	_add_box(art, "BossSigil", Vector3(0.20, 0.28, 0.04), Vector3(0.0, 1.13, -0.42), materials["glow_red"])
	for side_value in [-1.0, 1.0]:
		var side: float = float(side_value)
		_add_box(art, "BossPauldron", Vector3(0.34, 0.20, 0.34), Vector3(side * 0.58, 1.24, -0.02), materials["steel"])
		var horn_band: MeshInstance3D = _add_box(art, "HornBand", Vector3(0.10, 0.18, 0.10), Vector3(side * 0.25, 1.63, -0.03), materials["gold"])
		horn_band.rotation.z = side * 0.28
	_add_box(art, "BackBanner", Vector3(0.70, 0.78, 0.055), Vector3(0.0, 0.92, 0.40), materials["warden"])
	var weapon := visual.get_node_or_null("WeaponPivot") as Node3D
	if weapon != null:
		_add_box(weapon, "V149WardenEdge", Vector3(0.028, 0.085, 0.86), Vector3(0.045, 0.0, -0.57), materials["steel_bright"])
		_add_box(weapon, "V149WardenRune", Vector3(0.10, 0.08, 0.16), Vector3(0.0, 0.0, -0.28), materials["glow_red"])

func _art_generic_v149(art: Node3D, materials: Dictionary) -> void:
	_add_box(art, "GenericArmor", Vector3(0.42, 0.28, 0.12), Vector3(0.0, 0.78, -0.20), materials["steel_dark"])
	_add_box(art, "GenericRune", Vector3(0.12, 0.16, 0.035), Vector3(0.0, 0.80, -0.28), materials["glow_purple"])
