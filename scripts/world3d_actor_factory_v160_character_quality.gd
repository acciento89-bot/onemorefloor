extends "res://scripts/world3d_actor_factory_v160_enemy_lookdev.gd"

# ONE MORE FLOOR v1.60 — final character quality layer.
# Replaces the six blockout-like enemy body cores with imported low-poly OBJ
# silhouettes and performs a final authored Wanderer proportion/material pass.
# Animation pivots, hitboxes, sockets, tell rings, weapons and combat authority
# remain inherited unchanged.

const CHARACTER_QUALITY_VERSION := "1.60-character-quality-takeover"
const ENEMY_AUTHORED_ROOT := "res://assets/models/enemies/v160/"
const ENEMY_BODY_ASSETS := {
	"goblin": ENEMY_AUTHORED_ROOT + "goblin_body.obj",
	"bat": ENEMY_AUTHORED_ROOT + "bat_body.obj",
	"skeleton": ENEMY_AUTHORED_ROOT + "skeleton_body.obj",
	"ghoul": ENEMY_AUTHORED_ROOT + "ghoul_body.obj",
	"necromancer": ENEMY_AUTHORED_ROOT + "necromancer_body.obj",
	"warden": ENEMY_AUTHORED_ROOT + "warden_body.obj",
}
const ENEMY_KEEP_NODES := {
	"goblin": ["GoblinShoulderScrapV160", "GoblinDaggerV160", "GoblinEyeV160"],
	"bat": ["BatEyeV160"],
	"skeleton": ["SkeletonHelmBrowV160", "SkeletonEyeV160", "SkeletonSwordV160", "SkeletonShieldV160"],
	"ghoul": ["GhoulEyeV160", "GhoulClawV160"],
	"necromancer": ["NecroFaceV160", "NecroEyeV160", "NecroStaffV160", "NecroStaffCoreV160", "NecroCrownV160", "NecroRobeRuneV160"],
	"warden": ["WardenShieldV160", "WardenBladeV160", "WardenChestRuneV160", "WardenEyeV160", "WardenHornV160"],
}
const ENEMY_BODY_MATERIAL := {
	"goblin": "goblin_skin",
	"bat": "bat_body",
	"skeleton": "bone",
	"ghoul": "ghoul_flesh",
	"necromancer": "necro_robe",
	"warden": "warden_armor",
}

var enemy_body_mesh_cache: Dictionary = {}

func create_player(materials: Dictionary) -> Node3D:
	var root: Node3D = super.create_player(materials)
	if imported_model_active(root):
		_refine_authored_wanderer_quality(root)
	root.set_meta("character_quality_v160", character_quality_player_ready(root))
	return root

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	if root == null or imported_model_active(root):
		return
	_mount_authored_enemy_body(root, kind)
	root.set_meta("enemy_character_quality_v160", character_quality_enemy_ready(root))

func enemy_presentation_pipeline_ready() -> bool:
	return super.enemy_presentation_pipeline_ready() and _enemy_authored_assets_ready()

func character_quality_pipeline_ready() -> bool:
	return enemy_presentation_pipeline_ready() and _enemy_authored_assets_ready()

func character_quality_player_ready(root: Node3D) -> bool:
	if not v160_authored_wanderer_ready(root):
		return false
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D if root != null else null
	if imported == null:
		return false
	var chest := _find_named_mesh(imported, "V160AuthoredChestplate")
	var hood := _find_named_mesh(imported, "V160AuthoredHood")
	var cape := _find_named_mesh(imported, "V160AuthoredCape")
	var blade := _find_named_mesh(imported, "V160AuthoredBlade")
	return chest != null and hood != null and cape != null and blade != null \
		and String(root.get_meta("wanderer_character_quality_v160", "")) == CHARACTER_QUALITY_VERSION

func character_quality_enemy_ready(root: Node3D) -> bool:
	if root == null or not v160_enemy_presentation_ready(root):
		return false
	var kind := String(root.get_meta("enemy_presentation_v160_kind", ""))
	var layer := root.get_node_or_null("Motion/Visual/EnemyPresentationV160") as Node3D
	if layer == null:
		return false
	var authored := layer.get_node_or_null("AuthoredBodyV160") as MeshInstance3D
	return authored != null \
		and authored.visible \
		and authored.mesh != null \
		and String(authored.mesh.resource_path) == String(ENEMY_BODY_ASSETS.get(kind, "")) \
		and String(root.get_meta("enemy_character_quality_version_v160", "")) == CHARACTER_QUALITY_VERSION

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	return {
		"ready": character_quality_pipeline_ready(),
		"version": CHARACTER_QUALITY_VERSION,
		"enemy_asset_count": ENEMY_BODY_ASSETS.size(),
		"enemy_assets_ready": _enemy_authored_assets_ready(),
		"wanderer_ready": character_quality_player_ready(root) if root != null else false,
		"silhouette_profile": "authored-obj-body-cores",
		"material_profile": "controlled-layered-mobile",
	}

func _enemy_authored_assets_ready() -> bool:
	for path_value in ENEMY_BODY_ASSETS.values():
		var path := String(path_value)
		if not ResourceLoader.exists(path):
			return false
	return true

func _refine_authored_wanderer_quality(root: Node3D) -> void:
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		return

	# Break the broad robot silhouette: narrow the center mass and make the
	# shoulder treatment deliberately asymmetric while preserving all pivots.
	_tune_named_mesh(imported, "V160AuthoredTorso", Vector3(0.86, 1.04, 0.80), Vector3(0.0, 0.10, 0.015))
	_tune_named_mesh(imported, "V160AuthoredChestplate", Vector3(0.79, 0.86, 0.76), Vector3(0.0, -0.055, -0.005))
	_tune_named_mesh(imported, "V160AuthoredCape", Vector3(0.84, 1.10, 0.90), Vector3(0.0, 0.015, 0.28))
	_tune_named_mesh(imported, "V160AuthoredHood", Vector3(0.84, 0.90, 0.86), Vector3(0.0, -0.015, -0.018))
	_tune_named_mesh(imported, "V160AuthoredMask", Vector3(0.82, 0.86, 0.76), Vector3(0.0, -0.035, -0.018))
	_tune_named_mesh(imported, "V160AuthoredPauldronL", Vector3(0.52, 0.62, 0.66), Vector3(-0.018, -0.025, 0.025))
	_tune_named_mesh(imported, "V160AuthoredPauldronR", Vector3(0.67, 0.74, 0.76), Vector3(0.025, 0.005, -0.005))
	for suffix in ["L", "R"]:
		_tune_named_mesh(imported, "V160AuthoredArm%s" % suffix, Vector3(0.76, 1.03, 0.78))
		_tune_named_mesh(imported, "V160AuthoredGauntlet%s" % suffix, Vector3(0.74, 0.84, 0.76), Vector3(0.0, -0.355, -0.015))
		_tune_named_mesh(imported, "V160AuthoredLeg%s" % suffix, Vector3(0.74, 1.06, 0.78))
		_tune_named_mesh(imported, "V160AuthoredBoot%s" % suffix, Vector3(0.76, 0.88, 0.86), Vector3(0.0, -0.395, -0.072))
	_tune_named_mesh(imported, "V160AuthoredBlade", Vector3(0.84, 1.10, 0.82), Vector3(0.0, -0.045, -0.01))

	var eye_l := _find_named_mesh(imported, "V160EyeSlitL")
	var eye_r := _find_named_mesh(imported, "V160EyeSlitR")
	for eye in [eye_l, eye_r]:
		if eye != null:
			eye.scale = Vector3(0.78, 0.72, 0.80)

	# Materials move away from black plastic: cooler cloth, readable blue steel,
	# restrained brass and a smaller but cleaner arcane accent.
	_tune_wanderer_shader("cloth", Color("222b3a"), Color("687891"), 0.76, 0.22)
	_tune_wanderer_shader("cape", Color("201827"), Color("654b68"), 0.84, 0.18)
	_tune_wanderer_shader("steel_dark", Color("38424f"), Color("93a5b8"), 0.50, 0.31)
	_tune_wanderer_shader("leather", Color("35271f"), Color("765440"), 0.88, 0.18)
	_tune_wanderer_shader("gold", Color("6b4d29"), Color("c69b57"), 0.48, 0.30)
	_tune_wanderer_shader("blade", Color("647387"), Color("d4e0eb"), 0.26, 0.44)
	var arcane := wanderer_materials.get("arcane") as ShaderMaterial
	if arcane != null:
		arcane.set_shader_parameter("base_color", Color("4a2d73"))
		arcane.set_shader_parameter("edge_color", Color("ad83d8"))
		arcane.set_shader_parameter("emission_color", Color("7f4eb2"))
		arcane.set_shader_parameter("emission_strength", 0.26)

	root.set_meta("wanderer_character_quality_v160", CHARACTER_QUALITY_VERSION)

func _tune_named_mesh(
	root: Node,
	node_name: String,
	scale_value: Vector3,
	position_value: Vector3 = Vector3(999.0, 999.0, 999.0)
) -> void:
	var mesh := _find_named_mesh(root, node_name)
	if mesh == null:
		return
	mesh.scale = scale_value
	if position_value.x < 900.0:
		mesh.position = position_value

func _tune_wanderer_shader(
	key: String,
	base_color: Color,
	edge_color: Color,
	roughness_value: float,
	edge_strength_value: float
) -> void:
	var material := wanderer_materials.get(key) as ShaderMaterial
	if material == null:
		return
	material.set_shader_parameter("base_color", base_color)
	material.set_shader_parameter("edge_color", edge_color)
	material.set_shader_parameter("roughness", roughness_value)
	material.set_shader_parameter("edge_strength", edge_strength_value)

func _mount_authored_enemy_body(root: Node3D, kind: String) -> void:
	if kind not in ENEMY_BODY_ASSETS:
		return
	var layer := root.get_node_or_null("Motion/Visual/EnemyPresentationV160") as Node3D
	if layer == null:
		return

	var previous := layer.get_node_or_null("AuthoredBodyV160")
	if previous != null:
		previous.queue_free()

	var keep_nodes: Array = ENEMY_KEEP_NODES.get(kind, [])
	for child_value in layer.get_children():
		var child := child_value as MeshInstance3D
		if child == null:
			continue
		if String(child.name) == "AuthoredBodyV160":
			continue
		child.visible = keep_nodes.has(String(child.name))

	var path := String(ENEMY_BODY_ASSETS[kind])
	var mesh := _load_enemy_body_mesh(path)
	if mesh == null:
		push_warning("v1.60 character quality enemy asset failed: %s" % path)
		return
	var authored := MeshInstance3D.new()
	authored.name = "AuthoredBodyV160"
	authored.mesh = mesh
	var material_key := String(ENEMY_BODY_MATERIAL.get(kind, ""))
	authored.material_override = enemy_v160_materials.get(material_key) as Material
	authored.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	authored.set_meta("character_quality_v160", CHARACTER_QUALITY_VERSION)
	layer.add_child(authored)

	# Per-archetype silhouette tuning at gameplay scale.
	match kind:
		"goblin":
			authored.scale = Vector3(1.02, 1.00, 0.96)
			authored.rotation.z = -0.025
		"bat":
			authored.scale = Vector3(1.08, 0.96, 1.00)
			authored.position.y = 0.02
		"skeleton":
			authored.scale = Vector3(0.98, 1.02, 0.96)
		"ghoul":
			authored.scale = Vector3(1.04, 1.00, 1.00)
			authored.rotation.x = 0.025
		"necromancer":
			authored.scale = Vector3(0.96, 1.02, 0.96)
		"warden":
			authored.scale = Vector3(1.02, 1.02, 0.98)

	root.set_meta("enemy_character_quality_version_v160", CHARACTER_QUALITY_VERSION)

func _load_enemy_body_mesh(path: String) -> Mesh:
	if enemy_body_mesh_cache.has(path):
		return enemy_body_mesh_cache[path] as Mesh
	var mesh := load(path) as Mesh
	if mesh != null:
		enemy_body_mesh_cache[path] = mesh
	return mesh
