extends "res://scripts/world3d_actor_factory_v168_character_completion.gd"

# ONE MORE FLOOR v1.69 r1 — Enemy + Boss Visual Completion.
# Capture-driven replacement of the v1.66 BoxMesh secondary armour layer with
# authored OBJ silhouette kits. The accepted v1.60 enemy body cores, Skeleton
# reference geometry, weapons, tells, animation, hitboxes and combat authority
# remain inherited and unchanged. The accepted v1.68 r1.1 Wanderer is inherited
# unchanged as the player authority.

const ENEMY_COMPLETION_V169_VERSION := "1.69-enemy-boss-visual-completion-r1"
const ENEMY_COMPLETION_V169_NODE := "EnemyCompletionV169"
const V169_ROOT := "res://assets/models/enemies/v169/"
const V169_ASSET_PATHS := {
	"goblin": V169_ROOT + "goblin_kit_v169.obj",
	"bat": V169_ROOT + "bat_kit_v169.obj",
	"ghoul": V169_ROOT + "ghoul_kit_v169.obj",
	"necromancer": V169_ROOT + "necromancer_kit_v169.obj",
	"warden": V169_ROOT + "warden_kit_v169.obj",
}
const V169_MATERIAL_KEYS := {
	"goblin": "scrap_iron",
	"bat": "bat_body",
	"ghoul": "bone_dark",
	"necromancer": "necro_hood",
	"warden": "warden_iron",
}

const GoblinKitV169: Mesh = preload("res://assets/models/enemies/v169/goblin_kit_v169.obj")
const BatKitV169: Mesh = preload("res://assets/models/enemies/v169/bat_kit_v169.obj")
const GhoulKitV169: Mesh = preload("res://assets/models/enemies/v169/ghoul_kit_v169.obj")
const NecromancerKitV169: Mesh = preload("res://assets/models/enemies/v169/necromancer_kit_v169.obj")
const WardenKitV169: Mesh = preload("res://assets/models/enemies/v169/warden_kit_v169.obj")

const V169_MESHES := {
	"goblin": GoblinKitV169,
	"bat": BatKitV169,
	"ghoul": GhoulKitV169,
	"necromancer": NecromancerKitV169,
	"warden": WardenKitV169,
}

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	if root == null or imported_model_active(root):
		return
	_apply_enemy_completion_v169(root, kind)
	root.set_meta("enemy_completion_v169", ENEMY_COMPLETION_V169_VERSION)

func enemy_completion_pipeline_v169_ready() -> bool:
	if not character_quality_pipeline_ready():
		return false
	for path_value in V169_ASSET_PATHS.values():
		if not ResourceLoader.exists(String(path_value)):
			return false
	return true

func enemy_completion_v169_ready(root: Node3D) -> bool:
	if root == null or String(root.get_meta("enemy_completion_v169", "")) != ENEMY_COMPLETION_V169_VERSION:
		return false
	var kind := String(root.get_meta("enemy_presentation_v160_kind", ""))
	if kind == "skeleton":
		return v166_character_form_enemy_ready(root)
	if kind not in V169_ASSET_PATHS:
		return false
	var layer := root.get_node_or_null("Motion/Visual/EnemyPresentationV160") as Node3D
	if layer == null:
		return false
	var legacy_form := layer.get_node_or_null(CHARACTER_FORM_V166_NODE) as Node3D
	if legacy_form != null and legacy_form.visible:
		return false
	var completion := layer.get_node_or_null(ENEMY_COMPLETION_V169_NODE) as MeshInstance3D
	return completion != null \
		and completion.visible \
		and completion.mesh != null \
		and String(completion.get_meta("enemy_completion_v169", "")) == ENEMY_COMPLETION_V169_VERSION

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	var data: Dictionary = super.character_quality_snapshot(root)
	data["enemy_completion_v169_version"] = ENEMY_COMPLETION_V169_VERSION
	data["enemy_completion_v169_assets_ready"] = enemy_completion_pipeline_v169_ready()
	data["enemy_completion_v169_profile"] = "authored-obj-secondary-silhouette-no-boxmesh-overlay"
	data["enemy_completion_v169_asset_count"] = V169_ASSET_PATHS.size()
	data["enemy_completion_v169_skeleton_locked"] = true
	data["wanderer_v168_preserved"] = root != null and wanderer_completion_v168_ready(root)
	return data

func _apply_enemy_completion_v169(root: Node3D, kind: String) -> void:
	var layer := root.get_node_or_null("Motion/Visual/EnemyPresentationV160") as Node3D
	if layer == null:
		return

	var previous := layer.get_node_or_null(ENEMY_COMPLETION_V169_NODE)
	if previous != null:
		layer.remove_child(previous)
		previous.queue_free()

	# Skeleton is the accepted readability benchmark: no new geometry.
	if kind == "skeleton":
		root.set_meta("enemy_completion_v169", ENEMY_COMPLETION_V169_VERSION)
		return
	if kind not in V169_MESHES:
		return

	# v1.66's secondary form used BoxMesh plates. Keep the authored base body and
	# weapon/eye accents from v1.60, but remove that blockout-looking overlay from
	# the final visible composition.
	var legacy_form := layer.get_node_or_null(CHARACTER_FORM_V166_NODE) as Node3D
	if legacy_form != null:
		legacy_form.visible = false

	var completion := MeshInstance3D.new()
	completion.name = ENEMY_COMPLETION_V169_NODE
	completion.mesh = V169_MESHES[kind] as Mesh
	completion.material_override = enemy_v160_materials.get(String(V169_MATERIAL_KEYS[kind])) as Material
	completion.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	completion.set_meta("enemy_completion_v169", ENEMY_COMPLETION_V169_VERSION)
	completion.set_meta("enemy_completion_kind", kind)
	completion.set_meta("profile", "authored-secondary-obj")
	layer.add_child(completion)

	# Tight, gameplay-scale silhouette tuning only. No collision or combat data.
	match kind:
		"goblin":
			completion.scale = Vector3(0.96, 0.96, 0.96)
			completion.rotation.z = -0.025
		"bat":
			completion.scale = Vector3(0.96, 0.94, 0.94)
		"ghoul":
			completion.scale = Vector3(0.94, 0.96, 0.94)
			completion.rotation.z = 0.018
		"necromancer":
			completion.scale = Vector3(0.95, 0.97, 0.95)
		"warden":
			completion.scale = Vector3(0.96, 0.98, 0.96)
			# Preserve the accepted boss weapon/shield dominance while making the
			# torso read as one authored armoured mass instead of stacked boxes.
			_scale_layer_mesh(layer, "WardenShieldV160", Vector3(1.04, 1.04, 1.04))
			_scale_layer_mesh(layer, "WardenBladeV160", Vector3(1.04, 1.04, 1.04))

	root.set_meta("enemy_completion_v169", ENEMY_COMPLETION_V169_VERSION)
