extends RefCounted

# Stylized low-poly actor construction for the first 3D gameplay realm.
# These are deliberately built from native Godot meshes so the repo stays
# self-contained while camera, scale, animation language and silhouettes are
# locked before external production meshes/rigs are introduced.

const EARLY_AUTHORED_TYPES := [
	"goblin", "bat", "skeleton", "ghoul", "necromancer", "warden"
]

func create_player(materials: Dictionary) -> Node3D:
	var root := Node3D.new()
	root.name = "Wanderer3D"

	var motion := Node3D.new()
	motion.name = "Motion"
	root.add_child(motion)

	# Boots / stance.
	_add_box(motion, "BootL", Vector3(0.22, 0.18, 0.36), Vector3(-0.19, 0.13, -0.05), materials["dark"])
	_add_box(motion, "BootR", Vector3(0.22, 0.18, 0.36), Vector3(0.19, 0.13, -0.05), materials["dark"])
	_add_box(motion, "ShinL", Vector3(0.18, 0.40, 0.20), Vector3(-0.18, 0.36, 0.02), materials["leather"])
	_add_box(motion, "ShinR", Vector3(0.18, 0.40, 0.20), Vector3(0.18, 0.36, 0.02), materials["leather"])

	# Tapered cloak gives the hero a readable triangular silhouette from the
	# orthographic camera, closer to the established Wanderer concept.
	var cloak := _add_cylinder(motion, "Cloak", 0.18, 0.47, 0.96, Vector3(0.0, 0.74, 0.11), materials["cloth"], 10)
	cloak.rotation.x = 0.05
	_add_box(motion, "TorsoPlate", Vector3(0.60, 0.46, 0.32), Vector3(0.0, 0.92, -0.12), materials["dark"])
	_add_box(motion, "ChestGold", Vector3(0.42, 0.07, 0.36), Vector3(0.0, 1.04, -0.29), materials["gold"])

	# Layered pauldrons.
	for side in [-1.0, 1.0]:
		var shoulder := _add_sphere(motion, "Shoulder", 0.21, Vector3(side * 0.39, 1.06, -0.02), materials["steel"], 10, 5)
		shoulder.scale = Vector3(1.25, 0.64, 1.05)
		_add_box(motion, "Arm", Vector3(0.16, 0.46, 0.17), Vector3(side * 0.43, 0.78, -0.04), materials["cloth"])

	# Hood + recessed face.
	var hood := _add_sphere(motion, "Hood", 0.33, Vector3(0.0, 1.47, 0.04), materials["dark"], 12, 6)
	hood.scale = Vector3(1.05, 1.10, 0.92)
	var face := _add_sphere(motion, "Face", 0.205, Vector3(0.0, 1.43, -0.245), materials["skin"], 10, 5)
	face.scale = Vector3(0.92, 1.02, 0.72)
	_add_box(motion, "FaceShadow", Vector3(0.28, 0.10, 0.035), Vector3(0.0, 1.50, -0.395), materials["black"])

	# Back cape panel with offset depth so movement reads in isometric view.
	var cape := _add_cylinder(motion, "Cape", 0.05, 0.40, 0.90, Vector3(0.0, 0.82, 0.28), materials["cloth_dark"], 9)
	cape.rotation.x = -0.12
	cape.scale.z = 0.55

	# Weapon pivot is animated independently.
	var weapon := Node3D.new()
	weapon.name = "WeaponPivot"
	weapon.position = Vector3(0.50, 0.98, -0.22)
	weapon.rotation = Vector3(0.10, 0.02, -0.42)
	root.add_child(weapon)
	_add_box(weapon, "Grip", Vector3(0.07, 0.07, 0.42), Vector3(0.0, 0.0, 0.04), materials["leather"])
	_add_box(weapon, "Crossguard", Vector3(0.38, 0.065, 0.08), Vector3(0.0, 0.0, -0.18), materials["gold"])
	var blade := _add_box(weapon, "Blade", Vector3(0.10, 0.055, 0.98), Vector3(0.0, 0.0, -0.68), materials["steel_bright"])
	blade.rotation.z = 0.02
	_add_box(weapon, "BladeGlow", Vector3(0.026, 0.060, 0.78), Vector3(0.0, 0.0, -0.69), materials["glow_gold"])

	# NOVA ring remains real 3D geometry and expands over the floor.
	var skill := _add_cylinder(root, "SkillRing", 0.82, 0.82, 0.025, Vector3(0.0, 0.025, 0.0), materials["glow_purple"], 40)
	skill.visible = false

	root.set_meta("authored_3d", true)
	root.set_meta("actor_kind", "wanderer")
	return root

func create_enemy_shell(index: int) -> Node3D:
	var root := Node3D.new()
	root.name = "EnemyActor%02d" % index
	var motion := Node3D.new()
	motion.name = "Motion"
	root.add_child(motion)
	var visual := Node3D.new()
	visual.name = "Visual"
	motion.add_child(visual)
	root.set_meta("actor_kind", "")
	root.set_meta("authored_3d", true)
	return root

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	if String(root.get_meta("actor_kind", "")) == kind:
		return
	var visual := root.get_node_or_null("Motion/Visual") as Node3D
	if visual == null:
		return
	for child in visual.get_children():
		child.queue_free()
	root.set_meta("actor_kind", kind)

	match kind:
		"goblin": _build_goblin(visual, materials)
		"bat": _build_bat(visual, materials)
		"skeleton": _build_skeleton(visual, materials)
		"ghoul": _build_ghoul(visual, materials)
		"necromancer": _build_necromancer(visual, materials)
		"warden": _build_warden(visual, materials)
		_:
			_build_armored_fallback(visual, materials, kind)

func animate_player(root: Node3D, elapsed: float, move_amount: float, attack_amount: float, skill_amount: float) -> void:
	var motion := root.get_node_or_null("Motion") as Node3D
	if motion != null:
		var stride := sin(elapsed * 8.2) * clampf(move_amount, 0.0, 1.0)
		motion.position.y = 0.025 + absf(stride) * 0.035 + sin(elapsed * 2.6) * 0.018
		motion.rotation.z = -stride * 0.025
		var boot_l := motion.get_node_or_null("BootL") as Node3D
		var boot_r := motion.get_node_or_null("BootR") as Node3D
		if boot_l != null: boot_l.position.z = -0.05 + stride * 0.10
		if boot_r != null: boot_r.position.z = -0.05 - stride * 0.10
		var cape := motion.get_node_or_null("Cape") as Node3D
		if cape != null: cape.rotation.x = -0.12 - clampf(move_amount, 0.0, 1.0) * 0.18 + sin(elapsed * 4.0) * 0.025
	var weapon := root.get_node_or_null("WeaponPivot") as Node3D
	if weapon != null:
		weapon.rotation.z = -0.42 - attack_amount * 1.10
		weapon.rotation.x = 0.10 + attack_amount * 0.32
	var skill := root.get_node_or_null("SkillRing") as MeshInstance3D
	if skill != null:
		skill.visible = skill_amount > 0.01
		if skill.visible:
			var progress := 1.0 - skill_amount
			var s := 1.0 + progress * 3.0
			skill.scale = Vector3(s, 1.0, s)
			skill.rotation.y = elapsed * 1.5

func animate_enemy(root: Node3D, elapsed: float, phase: float, tell: float, hit: float, index: int) -> void:
	var motion := root.get_node_or_null("Motion") as Node3D
	if motion == null:
		return
	var kind := String(root.get_meta("actor_kind", ""))
	var cadence := 3.2
	if kind == "bat": cadence = 5.4
	elif kind == "warden": cadence = 1.9
	elif kind == "skeleton": cadence = 3.7
	var pulse := sin(elapsed * cadence + phase + float(index) * 0.37)
	motion.position.y = (0.14 + pulse * 0.10) if kind == "bat" else absf(pulse) * 0.025
	motion.rotation.z = pulse * (0.055 if kind == "bat" else 0.018)
	motion.scale = Vector3.ONE * (1.0 + tell * 0.045 - hit * 0.06)
	var weapon := motion.get_node_or_null("Visual/WeaponPivot") as Node3D
	if weapon != null:
		weapon.rotation.z = -0.30 - tell * 0.82 + hit * 0.16
	var head := motion.get_node_or_null("Visual/HeadPivot") as Node3D
	if head != null:
		head.rotation.x = -tell * 0.10 + hit * 0.08
	var wing_l := motion.get_node_or_null("Visual/WingL") as Node3D
	var wing_r := motion.get_node_or_null("Visual/WingR") as Node3D
	if wing_l != null: wing_l.rotation.z = 0.45 + pulse * 0.52
	if wing_r != null: wing_r.rotation.z = -0.45 - pulse * 0.52

func is_authored_enemy(kind: String) -> bool:
	return EARLY_AUTHORED_TYPES.has(kind)

# -----------------------------------------------------------------------------
# Enemy silhouettes
# -----------------------------------------------------------------------------

func _build_goblin(v: Node3D, m: Dictionary) -> void:
	_add_box(v, "BootL", Vector3(0.20,0.14,0.30), Vector3(-0.17,0.10,-0.04), m["leather"])
	_add_box(v, "BootR", Vector3(0.20,0.14,0.30), Vector3(0.17,0.10,-0.04), m["leather"])
	_add_cylinder(v, "Body", 0.22, 0.34, 0.62, Vector3(0,0.50,0.02), m["goblin_dark"], 9)
	_add_box(v, "Vest", Vector3(0.54,0.34,0.28), Vector3(0,0.61,-0.12), m["leather"])
	var hp := Node3D.new(); hp.name = "HeadPivot"; hp.position = Vector3(0,0.96,-0.05); v.add_child(hp)
	var head := _add_sphere(hp, "Head", 0.29, Vector3.ZERO, m["goblin"], 10, 5); head.scale = Vector3(1.08,0.90,0.94)
	for side in [-1.0,1.0]:
		var ear := _add_box(hp, "Ear", Vector3(0.30,0.08,0.15), Vector3(side*0.30,0.04,0.0), m["goblin"])
		ear.rotation.z = side * 0.32
		_add_box(v, "Arm", Vector3(0.14,0.45,0.14), Vector3(side*0.34,0.55,-0.03), m["goblin"])
	_add_box(hp, "EyeL", Vector3(0.055,0.035,0.025), Vector3(-0.09,0.04,-0.265), m["glow_gold"])
	_add_box(hp, "EyeR", Vector3(0.055,0.035,0.025), Vector3(0.09,0.04,-0.265), m["glow_gold"])
	var wp := Node3D.new(); wp.name = "WeaponPivot"; wp.position = Vector3(0.43,0.67,-0.06); wp.rotation.z = -0.30; v.add_child(wp)
	_add_box(wp, "Handle", Vector3(0.07,0.07,0.52), Vector3(0,0,-0.10), m["leather"])
	var cleaver := _add_box(wp, "Cleaver", Vector3(0.28,0.07,0.44), Vector3(0,0,-0.45), m["steel"]); cleaver.rotation.y = -0.12

func _build_bat(v: Node3D, m: Dictionary) -> void:
	var body := _add_sphere(v, "Body", 0.28, Vector3(0,0.72,0), m["purple"], 10, 5); body.scale = Vector3(0.82,1.25,0.82)
	var hp := Node3D.new(); hp.name = "HeadPivot"; hp.position = Vector3(0,1.08,-0.10); v.add_child(hp)
	_add_sphere(hp, "Head", 0.21, Vector3.ZERO, m["purple_dark"], 9, 5)
	for side in [-1.0,1.0]:
		var ear := _add_cylinder(hp, "Ear", 0.0,0.10,0.30,Vector3(side*0.10,0.23,0.01),m["purple_dark"],6)
		ear.rotation.z = side*0.20
	var wl := Node3D.new(); wl.name="WingL"; wl.position=Vector3(-0.22,0.82,0.04); v.add_child(wl)
	var wr := Node3D.new(); wr.name="WingR"; wr.position=Vector3(0.22,0.82,0.04); v.add_child(wr)
	var wing_l := _add_box(wl,"Wing",Vector3(0.72,0.055,0.48),Vector3(-0.33,0,0),m["purple"]); wing_l.rotation.y=0.18
	var wing_r := _add_box(wr,"Wing",Vector3(0.72,0.055,0.48),Vector3(0.33,0,0),m["purple"]); wing_r.rotation.y=-0.18
	_add_box(hp,"EyeL",Vector3(0.045,0.04,0.025),Vector3(-0.07,0.02,-0.195),m["glow_purple"])
	_add_box(hp,"EyeR",Vector3(0.045,0.04,0.025),Vector3(0.07,0.02,-0.195),m["glow_purple"])

func _build_skeleton(v: Node3D, m: Dictionary) -> void:
	_add_box(v,"ShinL",Vector3(0.10,0.48,0.10),Vector3(-0.15,0.28,0),m["bone"])
	_add_box(v,"ShinR",Vector3(0.10,0.48,0.10),Vector3(0.15,0.28,0),m["bone"])
	_add_box(v,"Pelvis",Vector3(0.40,0.16,0.24),Vector3(0,0.55,0),m["bone_dark"])
	_add_box(v,"Spine",Vector3(0.09,0.55,0.09),Vector3(0,0.84,0.03),m["bone"])
	for y in [0.72,0.82,0.92,1.02]:
		_add_box(v,"Rib",Vector3(0.52-(y-0.72)*0.35,0.055,0.18),Vector3(0,y,-0.02),m["bone"])
	for side in [-1.0,1.0]:
		_add_box(v,"Arm",Vector3(0.09,0.58,0.09),Vector3(side*0.34,0.83,-0.02),m["bone"])
	var hp:=Node3D.new(); hp.name="HeadPivot"; hp.position=Vector3(0,1.28,-0.04); v.add_child(hp)
	var skull:=_add_sphere(hp,"Skull",0.24,Vector3.ZERO,m["bone"],10,5); skull.scale=Vector3(0.92,1.02,0.88)
	_add_box(hp,"EyeL",Vector3(0.055,0.055,0.025),Vector3(-0.08,0.04,-0.21),m["black"])
	_add_box(hp,"EyeR",Vector3(0.055,0.055,0.025),Vector3(0.08,0.04,-0.21),m["black"])
	var wp:=Node3D.new(); wp.name="WeaponPivot"; wp.position=Vector3(0.45,0.88,-0.08); wp.rotation.z=-0.30; v.add_child(wp)
	_add_box(wp,"Blade",Vector3(0.08,0.06,0.82),Vector3(0,0,-0.35),m["steel"])
	_add_box(wp,"Guard",Vector3(0.32,0.06,0.08),Vector3(0,0,0.03),m["steel"])

func _build_ghoul(v: Node3D, m: Dictionary) -> void:
	var torso:=_add_cylinder(v,"Body",0.24,0.38,0.74,Vector3(0,0.62,0.08),m["undead_dark"],9); torso.rotation.x=0.18
	var hp:=Node3D.new(); hp.name="HeadPivot"; hp.position=Vector3(0,1.07,-0.18); v.add_child(hp)
	var head:=_add_sphere(hp,"Head",0.25,Vector3.ZERO,m["undead"],9,5); head.scale=Vector3(0.92,1.0,0.88)
	for side in [-1.0,1.0]:
		var arm:=_add_box(v,"Arm",Vector3(0.13,0.72,0.13),Vector3(side*0.38,0.60,-0.22),m["undead"])
		arm.rotation.x=0.35; arm.rotation.z=side*0.10
		_add_box(v,"Claw",Vector3(0.16,0.10,0.30),Vector3(side*0.40,0.26,-0.46),m["bone"])
	_add_box(hp,"EyeL",Vector3(0.05,0.04,0.025),Vector3(-0.08,0.04,-0.22),m["glow_purple"])
	_add_box(hp,"EyeR",Vector3(0.05,0.04,0.025),Vector3(0.08,0.04,-0.22),m["glow_purple"])

func _build_necromancer(v: Node3D, m: Dictionary) -> void:
	_add_cylinder(v,"Robe",0.18,0.48,1.18,Vector3(0,0.62,0.08),m["purple_dark"],10)
	_add_box(v,"Belt",Vector3(0.58,0.09,0.32),Vector3(0,0.76,-0.08),m["gold"])
	var hp:=Node3D.new(); hp.name="HeadPivot"; hp.position=Vector3(0,1.36,-0.03); v.add_child(hp)
	var hood:=_add_sphere(hp,"Hood",0.31,Vector3.ZERO,m["black"],10,5); hood.scale=Vector3(1.0,1.08,0.92)
	_add_box(hp,"FaceVoid",Vector3(0.28,0.20,0.035),Vector3(0,-0.02,-0.285),m["black"])
	_add_box(hp,"EyeL",Vector3(0.04,0.03,0.025),Vector3(-0.075,0.02,-0.31),m["glow_purple"])
	_add_box(hp,"EyeR",Vector3(0.04,0.03,0.025),Vector3(0.075,0.02,-0.31),m["glow_purple"])
	var wp:=Node3D.new(); wp.name="WeaponPivot"; wp.position=Vector3(0.48,0.86,-0.02); wp.rotation.z=-0.12; v.add_child(wp)
	_add_cylinder(wp,"Staff",0.035,0.035,1.45,Vector3(0,0.25,0),m["leather"],8)
	_add_sphere(wp,"Orb",0.18,Vector3(0,1.02,0),m["glow_purple"],10,5)

func _build_warden(v: Node3D, m: Dictionary) -> void:
	_add_box(v,"BootL",Vector3(0.30,0.24,0.43),Vector3(-0.24,0.15,-0.02),m["dark"])
	_add_box(v,"BootR",Vector3(0.30,0.24,0.43),Vector3(0.24,0.15,-0.02),m["dark"])
	_add_cylinder(v,"Body",0.36,0.48,1.08,Vector3(0,0.78,0.05),m["warden"],10)
	_add_box(v,"Breastplate",Vector3(0.82,0.62,0.38),Vector3(0,0.92,-0.16),m["steel_dark"])
	_add_box(v,"GoldRidge",Vector3(0.11,0.52,0.40),Vector3(0,0.94,-0.35),m["gold"])
	for side in [-1.0,1.0]:
		var shoulder:=_add_sphere(v,"Shoulder",0.30,Vector3(side*0.52,1.12,0),m["steel_dark"],10,5); shoulder.scale=Vector3(1.25,0.66,1.05)
		_add_box(v,"Arm",Vector3(0.22,0.64,0.22),Vector3(side*0.52,0.77,-0.02),m["warden"])
	var hp:=Node3D.new(); hp.name="HeadPivot"; hp.position=Vector3(0,1.55,-0.04); v.add_child(hp)
	var helm:=_add_sphere(hp,"Helmet",0.34,Vector3.ZERO,m["steel_dark"],10,5); helm.scale=Vector3(1.0,1.08,0.90)
	_add_box(hp,"Visor",Vector3(0.42,0.12,0.06),Vector3(0,0.01,-0.315),m["black"])
	_add_box(hp,"EyeGlow",Vector3(0.28,0.035,0.025),Vector3(0,0.01,-0.35),m["glow_red"])
	for side in [-1.0,1.0]:
		var horn:=_add_cylinder(hp,"Horn",0.0,0.08,0.46,Vector3(side*0.25,0.30,0.02),m["gold"],7); horn.rotation.z=side*0.40
	var wp:=Node3D.new(); wp.name="WeaponPivot"; wp.position=Vector3(0.64,1.02,-0.10); wp.rotation.z=-0.30; v.add_child(wp)
	_add_cylinder(wp,"AxeShaft",0.045,0.045,1.32,Vector3(0,0,-0.20),m["leather"],8)
	var axe:=_add_box(wp,"AxeHead",Vector3(0.56,0.13,0.44),Vector3(0,0,-0.82),m["steel_bright"]); axe.rotation.y=0.08
	_add_box(wp,"AxeRune",Vector3(0.18,0.04,0.24),Vector3(0,0,-0.89),m["glow_red"])

func _build_armored_fallback(v: Node3D, m: Dictionary, kind: String) -> void:
	var accent: Material = m["purple"] if kind.contains("mage") or kind.contains("hex") else m["steel_dark"]
	_add_cylinder(v,"Body",0.28,0.38,0.90,Vector3(0,0.62,0.03),accent,9)
	_add_box(v,"Chest",Vector3(0.62,0.42,0.32),Vector3(0,0.75,-0.14),m["dark"])
	var hp:=Node3D.new(); hp.name="HeadPivot"; hp.position=Vector3(0,1.18,-0.03); v.add_child(hp)
	_add_sphere(hp,"Head",0.27,Vector3.ZERO,accent,9,5)
	_add_box(hp,"Eyes",Vector3(0.25,0.04,0.025),Vector3(0,0.02,-0.25),m["glow_purple"])
	var wp:=Node3D.new(); wp.name="WeaponPivot"; wp.position=Vector3(0.44,0.78,-0.05); wp.rotation.z=-0.30; v.add_child(wp)
	_add_box(wp,"Weapon",Vector3(0.08,0.07,0.78),Vector3(0,0,-0.30),m["steel"])

# -----------------------------------------------------------------------------
# Mesh helpers
# -----------------------------------------------------------------------------

func _add_box(parent: Node, name_value: String, size: Vector3, pos: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.name = name_value
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	parent.add_child(node)
	return node

func _add_sphere(parent: Node, name_value: String, radius: float, pos: Vector3, material: Material, radial: int, rings: int) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = radial
	mesh.rings = rings
	var node := MeshInstance3D.new()
	node.name = name_value
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	parent.add_child(node)
	return node

func _add_cylinder(parent: Node, name_value: String, top_radius: float, bottom_radius: float, height: float, pos: Vector3, material: Material, radial: int) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = height
	mesh.radial_segments = radial
	mesh.rings = 1
	var node := MeshInstance3D.new()
	node.name = name_value
	node.mesh = mesh
	node.position = pos
	node.material_override = material
	parent.add_child(node)
	return node
