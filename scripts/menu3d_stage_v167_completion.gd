class_name Menu3DStageV167Completion
extends "res://scripts/menu3d_stage_v160.gd"

# ONE MORE FLOOR v1.67 — Frontend Completion r1.1.
# Home/Hero instantiate the exact gameplay Wanderer authority. r1.1 responds to
# real 720x1280 captures: the Wanderer gets more visual authority and Forge gets
# a true authored focal engine instead of reading like a loose blockout scene.

const FRONTEND_COMPLETION_VERSION := "1.67-frontend-completion-r1.1"
const GameplayActorFactoryV166 = preload("res://scripts/world3d_actor_factory_v166_character_form.gd")
const COMPLETION_FORGE_ENGINE := "res://assets/environment/v160/forge_engine.obj"

var gameplay_actor_factory = GameplayActorFactoryV166.new()
var menu_actor_materials: Dictionary = {}
var completion_mesh_cache: Dictionary = {}
var completion_asset_instances := 0

func _rebuild_stage() -> void:
	completion_asset_instances = 0
	super._rebuild_stage()

func _build_materials() -> void:
	super._build_materials()
	menu_actor_materials = {
		"cloth": _material(Color("2a203c"), 0.08, 0.72),
		"cloth_dark": _material(Color("171522"), 0.06, 0.82),
		"dark": _material(Color("141923"), 0.22, 0.70),
		"black": _material(Color("05070c"), 0.02, 0.94),
		"skin": _material(Color("a97d66"), 0.02, 0.90),
		"gold": mat_brass,
		"steel": _material(Color("5f6c7b"), 0.72, 0.34),
		"steel_bright": _material(Color("aebdcc"), 0.82, 0.24),
		"steel_dark": _material(Color("303946"), 0.66, 0.42),
		"leather": _material(Color("3a281e"), 0.04, 0.86),
		"bone": _material(Color("b9b19e"), 0.02, 0.88),
		"bone_dark": _material(Color("6c675c"), 0.04, 0.86),
		"goblin": _material(Color("687f4a"), 0.04, 0.84),
		"goblin_dark": _material(Color("31402b"), 0.05, 0.86),
		"undead": _material(Color("71806a"), 0.03, 0.86),
		"undead_dark": _material(Color("343d32"), 0.05, 0.86),
		"purple": _material(Color("64467f"), 0.10, 0.66),
		"purple_dark": _material(Color("332640"), 0.10, 0.72),
		"warden": _material(Color("64404e"), 0.20, 0.58),
		"glow_gold": _material(Color("b98a34"), 0.18, 0.42, Color("f5c766"), 0.72),
		"glow_purple": _material(Color("4f3180"), 0.08, 0.44, Color("9b6be6"), 0.66),
		"glow_red": _material(Color("632738"), 0.08, 0.48, Color("e8566e"), 0.58),
	}

func _process(delta: float) -> void:
	super._process(delta)
	if actor_model != null and is_instance_valid(actor_model):
		gameplay_actor_factory.animate_player(actor_model, elapsed, 0.0, 0.0, 0.0)

func _add_actor(pos: Vector3, scale_value: float) -> void:
	actor_anchor = Node3D.new()
	actor_anchor.name = "WandererShowcase"
	actor_anchor.position = pos
	actor_anchor.rotation.y = PI
	stage_root.add_child(actor_anchor)

	actor_model = gameplay_actor_factory.create_player(menu_actor_materials)
	if actor_model == null:
		return
	actor_model.name = "GameplayWandererV166"
	actor_model.scale = Vector3.ONE * scale_value
	actor_anchor.add_child(actor_model)
	actor_animation = _find_animation_player(actor_model)
	gameplay_actor_factory.animate_player(actor_model, elapsed, 0.0, 0.0, 0.0)

func _load_completion_mesh(path: String) -> Mesh:
	if completion_mesh_cache.has(path):
		return completion_mesh_cache[path] as Mesh
	var mesh := load(path) as Mesh
	if mesh != null:
		completion_mesh_cache[path] = mesh
	return mesh

func _place_completion_mesh(node_name: String, path: String, material: Material, pos: Vector3, scale_value: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh := _load_completion_mesh(path)
	if mesh == null:
		push_warning("v1.67 completion asset failed to load: %s" % path)
		return null
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = pos
	instance.scale = scale_value
	instance.rotation = rot
	stage_root.add_child(instance)
	completion_asset_instances += 1
	return instance

func frontend_completion_ready() -> bool:
	if not meta_environment_assets_ready() or gameplay_actor_factory == null:
		return false
	if not gameplay_actor_factory.has_method("v166_character_form_player_ready"):
		return false
	if current_screen in ["home", "hero"]:
		return actor_model != null \
			and bool(gameplay_actor_factory.call("v166_character_form_player_ready", actor_model)) \
			and String(actor_model.get_meta("character_form_v166", "")) == "1.66-character-form-r1.1"
	if current_screen == "forge":
		return completion_asset_instances >= 1 and ResourceLoader.exists(COMPLETION_FORGE_ENGINE)
	return true

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["frontend_completion_version"] = FRONTEND_COMPLETION_VERSION
	data["frontend_profile"] = "shared-gameplay-wanderer-authored-meta-stage"
	data["gameplay_wanderer_shared"] = actor_model != null \
		and String(actor_model.get_meta("character_form_v166", "")) == "1.66-character-form-r1.1"
	data["completion_asset_instances"] = completion_asset_instances
	data["forge_engine_authored"] = current_screen != "forge" or completion_asset_instances >= 1
	data["frontend_completion_ready"] = frontend_completion_ready()
	return data

func _build_home_stage() -> void:
	super._build_home_stage()
	if actor_anchor != null:
		actor_anchor.position = Vector3(0.0, 1.40, 0.02)
	if actor_model != null:
		actor_model.scale = Vector3.ONE * 1.02
	_make_rune_ring(Vector3(0.0, 1.55, -0.10), 1.02, 20, mat_floor_trim)
	_add_environment_light("HomeCompletionKey", Vector3(-1.35, 3.05, 1.75), Color("cfc8ff"), 0.66, 4.2)
	_add_environment_light("HomeCompletionRim", Vector3(1.85, 2.35, 0.70), Color("d8a45f"), 0.42, 3.5)

func _build_hero_stage() -> void:
	super._build_hero_stage()
	if actor_anchor != null:
		actor_anchor.position = Vector3(0.0, 2.96, 0.04)
	if actor_model != null:
		actor_model.scale = Vector3.ONE * 1.00
	_make_rune_ring(Vector3(0.0, 2.96, -0.10), 1.14, 22, mat_purple)
	_add_environment_light("HeroCompletionKey", Vector3(-1.25, 4.35, 1.85), Color("e0d8ff"), 0.86, 4.6)
	_add_environment_light("HeroCompletionRim", Vector3(1.65, 3.70, 0.65), Color("9c78dc"), 0.48, 3.5)

func _build_forge_stage() -> void:
	super._build_forge_stage()
	# The capture exposed the old forge focal as a collection of readable assets
	# but no single authored silhouette. Reuse the production Iron Bastion engine
	# as the menu's dominant machine so Forge and tower art speak the same language.
	var ember := stage_root.get_node_or_null("ForgeEmberVFX") as Node3D
	if ember != null:
		ember.visible = false
	var anvil := stage_root.get_node_or_null("ForgeAnvilAsset") as Node3D
	if anvil != null:
		anvil.position = Vector3(0.32, 1.58, -1.42)
		anvil.scale = Vector3.ONE * 1.02
	var rack := stage_root.get_node_or_null("ForgeRackAsset") as Node3D
	if rack != null:
		rack.position = Vector3(2.18, 1.18, -2.82)
	_place_completion_mesh("ForgeEngineCompletionAsset", COMPLETION_FORGE_ENGINE, mat_dark_metal, Vector3(-0.62, 0.22, -2.92), Vector3(0.74, 0.74, 0.74))
	_place_environment_asset(stage_root, "ForgeCompletionBannerAsset", "banner", mat_cloth, Vector3(2.58, 2.44, -2.74), Vector3(0.58, 0.58, 0.58))
	_add_environment_light("ForgeCompletionFireKey", Vector3(-0.50, 1.78, -1.30), Color("ff8b43"), 0.78, 3.8)
	_add_environment_light("ForgeCompletionFill", Vector3(1.45, 2.65, -0.55), Color("d3c2aa"), 0.30, 3.2)

func _build_talents_stage() -> void:
	super._build_talents_stage()
	_make_rune_ring(Vector3(0.0, 0.10, -0.80), 1.62, 24, mat_purple)
	_add_environment_light("TalentCompletionRim", Vector3(0.0, 3.45, 0.20), Color("b591ff"), 0.28, 3.5)

func _build_vault_stage() -> void:
	super._build_vault_stage()
	_place_environment_asset(stage_root, "VaultCompletionBannerL", "banner", mat_cloth, Vector3(-2.34, 2.85, -2.92), Vector3(0.52, 0.52, 0.52))
	_place_environment_asset(stage_root, "VaultCompletionBannerR", "banner", mat_cloth, Vector3(2.34, 2.85, -2.92), Vector3(0.52, 0.52, 0.52))
	_add_environment_light("VaultCompletionFill", Vector3(0.0, 3.05, 0.10), Color("d9c7a0"), 0.28, 3.5)

func _build_missions_stage() -> void:
	super._build_missions_stage()
	_place_environment_asset(stage_root, "MissionCompletionBannerL", "banner", mat_cloth, Vector3(-2.72, 2.55, -2.92), Vector3(0.48, 0.48, 0.48))
	_place_environment_asset(stage_root, "MissionCompletionBannerR", "banner", mat_cloth, Vector3(2.72, 2.55, -2.92), Vector3(0.48, 0.48, 0.48))
	_add_environment_light("MissionCompletionFill", Vector3(0.0, 2.95, 0.20), Color("a8c8b5"), 0.24, 3.3)

func _build_pass_stage() -> void:
	super._build_pass_stage()
	_make_rune_ring(Vector3(0.0, 0.12, -1.25), 1.48, 22, mat_floor_trim)
	_add_environment_light("PassCompletionFill", Vector3(0.0, 3.65, 0.25), Color("d9c7ff"), 0.30, 3.7)

func _camera_position_for(screen: String) -> Vector3:
	match screen:
		"home": return Vector3(0.0, 2.74, 9.20)
		"hero": return Vector3(0.0, 3.04, 8.72)
		"forge": return Vector3(0.0, 2.72, 9.52)
		"talents": return Vector3(0.0, 2.92, 9.95)
		"vault": return Vector3(0.0, 2.86, 10.05)
		"missions": return Vector3(0.0, 2.96, 10.15)
		"pass": return Vector3(0.0, 2.94, 9.90)
		_: return super._camera_position_for(screen)

func _camera_target_for(screen: String) -> Vector3:
	match screen:
		"home": return Vector3(0.0, 2.30, -0.18)
		"hero": return Vector3(0.0, 2.96, -0.04)
		"forge": return Vector3(0.0, 1.94, -1.52)
		"talents": return Vector3(0.0, 2.12, -1.08)
		"vault": return Vector3(0.0, 2.18, -1.46)
		"missions": return Vector3(0.0, 2.08, -1.12)
		"pass": return Vector3(0.0, 2.22, -1.22)
		_: return super._camera_target_for(screen)
