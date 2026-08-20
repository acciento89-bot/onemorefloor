extends "res://scripts/world3d_actor_factory_v166_character_form.gd"

# ONE MORE FLOOR v1.68 r1 — Wanderer Visual Completion.
# Replaces the visibly coarse authored body kit with a tighter faceted set while
# preserving the proven v1.55 articulated pivots, Hood r11, sockets, animation
# state selection, hitboxes and gameplay authority.

const WANDERER_COMPLETION_V168_VERSION := "1.68-wanderer-visual-completion-r1"
const V168_ROOT := "res://assets/models/actors/v168/"
const V168_ASSET_PATHS := [
	V168_ROOT + "wanderer_torso_v168.obj",
	V168_ROOT + "wanderer_chestplate_v168.obj",
	V168_ROOT + "wanderer_pauldron_v168.obj",
	V168_ROOT + "wanderer_gauntlet_v168.obj",
	V168_ROOT + "wanderer_boot_v168.obj",
	V168_ROOT + "wanderer_blade_v168.obj",
	V168_ROOT + "wanderer_trim_v168.obj",
	V168_ROOT + "wanderer_tabard_v168.obj",
]

const WandererTorsoV168: Mesh = preload("res://assets/models/actors/v168/wanderer_torso_v168.obj")
const WandererChestplateV168: Mesh = preload("res://assets/models/actors/v168/wanderer_chestplate_v168.obj")
const WandererPauldronV168: Mesh = preload("res://assets/models/actors/v168/wanderer_pauldron_v168.obj")
const WandererGauntletV168: Mesh = preload("res://assets/models/actors/v168/wanderer_gauntlet_v168.obj")
const WandererBootV168: Mesh = preload("res://assets/models/actors/v168/wanderer_boot_v168.obj")
const WandererBladeV168: Mesh = preload("res://assets/models/actors/v168/wanderer_blade_v168.obj")
const WandererTrimV168: Mesh = preload("res://assets/models/actors/v168/wanderer_trim_v168.obj")
const WandererTabardV168: Mesh = preload("res://assets/models/actors/v168/wanderer_tabard_v168.obj")

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if root != null and imported_model_active(root):
		_apply_wanderer_completion_v168(root)
	if root != null:
		root.set_meta("wanderer_completion_v168", WANDERER_COMPLETION_V168_VERSION)
	return root

func wanderer_completion_v168_ready(root: Node3D) -> bool:
	if root == null or String(root.get_meta("wanderer_completion_v168", "")) != WANDERER_COMPLETION_V168_VERSION:
		return false
	if not v166_character_form_player_ready(root):
		return false
	for path in V168_ASSET_PATHS:
		if not ResourceLoader.exists(path):
			return false
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		return false
	for node_name in [
		"V160AuthoredTorso", "V160AuthoredChestplate",
		"V160AuthoredPauldronL", "V160AuthoredPauldronR",
		"V160AuthoredGauntletL", "V160AuthoredGauntletR",
		"V160AuthoredBootL", "V160AuthoredBootR",
		"V160AuthoredBlade", "V168ArmorTrim", "V168Tabard"
	]:
		var mesh := _find_named_mesh(imported, node_name)
		if mesh == null or String(mesh.get_meta("wanderer_completion_v168", "")) != WANDERER_COMPLETION_V168_VERSION:
			return false
	return String(root.get_meta("wanderer_hood_r11", "")) == WANDERER_HOOD_R11_VERSION

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	var data: Dictionary = super.character_quality_snapshot(root)
	data["wanderer_completion_v168_version"] = WANDERER_COMPLETION_V168_VERSION
	data["wanderer_completion_v168_ready"] = wanderer_completion_v168_ready(root) if root != null else false
	data["wanderer_completion_v168_profile"] = "authored-faceted-armour-tabard-trim-shared-menu-gameplay"
	data["wanderer_completion_v168_asset_count"] = V168_ASSET_PATHS.size()
	data["hood_r11_preserved"] = root != null and String(root.get_meta("wanderer_hood_r11", "")) == WANDERER_HOOD_R11_VERSION
	return data

func _apply_wanderer_completion_v168(root: Node3D) -> void:
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		return

	_swap_v168(imported, "V160AuthoredTorso", WandererTorsoV168)
	_swap_v168(imported, "V160AuthoredChestplate", WandererChestplateV168)
	_swap_v168(imported, "V160AuthoredPauldronL", WandererPauldronV168)
	_swap_v168(imported, "V160AuthoredPauldronR", WandererPauldronV168)
	_swap_v168(imported, "V160AuthoredGauntletL", WandererGauntletV168)
	_swap_v168(imported, "V160AuthoredGauntletR", WandererGauntletV168)
	_swap_v168(imported, "V160AuthoredBootL", WandererBootV168)
	_swap_v168(imported, "V160AuthoredBootR", WandererBootV168)
	_swap_v168(imported, "V160AuthoredBlade", WandererBladeV168)

	# Keep the accepted right-handed orientation contract. Left pauldron is still
	# rotated by the authored layer instead of mirrored with negative scaling.
	var chest := _find_named_mesh(imported, "V160AuthoredChestplate")
	if chest != null:
		chest.scale = Vector3(0.98, 0.98, 0.96)
	var torso := _find_named_mesh(imported, "V160AuthoredTorso")
	if torso != null:
		torso.scale = Vector3(0.98, 1.00, 0.94)
	for name_value in ["V160AuthoredPauldronL", "V160AuthoredPauldronR"]:
		var p := _find_named_mesh(imported, name_value)
		if p != null:
			p.scale = Vector3(0.78, 0.84, 0.84)
	for name_value in ["V160AuthoredGauntletL", "V160AuthoredGauntletR"]:
		var g := _find_named_mesh(imported, name_value)
		if g != null:
			g.scale = Vector3(0.94, 0.96, 0.94)
	for name_value in ["V160AuthoredBootL", "V160AuthoredBootR"]:
		var b := _find_named_mesh(imported, name_value)
		if b != null:
			b.scale = Vector3(0.94, 0.96, 0.96)
	var blade := _find_named_mesh(imported, "V160AuthoredBlade")
	if blade != null:
		blade.scale = Vector3(1.08, 1.04, 1.10)

	# Stronger material separation at portrait distance without adding glow spam.
	_refine_mesh_material(imported, "V160AuthoredChestplate", Color("3b4654"), Color("c5d0dc"), 0.40, 0.42, 0.28)
	_refine_mesh_material(imported, "V160AuthoredPauldronL", Color("35414f"), Color("b8c6d4"), 0.43, 0.38, 0.24)
	_refine_mesh_material(imported, "V160AuthoredPauldronR", Color("35414f"), Color("b8c6d4"), 0.43, 0.38, 0.24)
	_refine_mesh_material(imported, "V160AuthoredBlade", Color("7e91a6"), Color("edf4fa"), 0.22, 0.58, 0.38)

	var hips := _find_named_node3d(imported, "Hips")
	if hips != null:
		_remove_named_child(hips, "V168ArmorTrim")
		_remove_named_child(hips, "V168Tabard")
		_add_v168_piece(hips, "V168ArmorTrim", WandererTrimV168, wanderer_materials["gold"], Vector3(0.0, -0.015, 0.015))
		var tabard := _add_v168_piece(hips, "V168Tabard", WandererTabardV168, wanderer_materials["cape"], Vector3(0.0, -0.02, -0.015))
		if tabard != null:
			tabard.rotation.x = -0.035

	root.set_meta("wanderer_completion_v168", WANDERER_COMPLETION_V168_VERSION)

func _swap_v168(imported: Node, node_name: String, mesh_value: Mesh) -> void:
	var node := _find_named_mesh(imported, node_name)
	if node == null:
		return
	node.mesh = mesh_value
	node.set_meta("wanderer_completion_v168", WANDERER_COMPLETION_V168_VERSION)

func _add_v168_piece(parent: Node3D, node_name: String, mesh_value: Mesh, material: Material, pos: Vector3) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	node.mesh = mesh_value
	node.material_override = material
	node.position = pos
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	node.set_meta("wanderer_completion_v168", WANDERER_COMPLETION_V168_VERSION)
	parent.add_child(node)
	return node

func _remove_named_child(parent: Node, node_name: String) -> void:
	var old := parent.get_node_or_null(node_name)
	if old != null:
		parent.remove_child(old)
		old.queue_free()
