class_name Menu3DStageV167Completion
extends "res://scripts/menu3d_stage_v160.gd"

# ONE MORE FLOOR v1.67 — Frontend Completion r1.
# The menu no longer owns a separate legacy Wanderer. Home/Hero now instantiate
# the exact same v1.66 gameplay actor authority used inside the tower. The pass
# also tightens composition and lighting across every visible meta screen while
# preserving the authored v1.59/v1.60 environment assets.

const FRONTEND_COMPLETION_VERSION := "1.67-frontend-completion-r1"
const GameplayActorFactoryV166 = preload("res://scripts/world3d_actor_factory_v166_character_form.gd")

var gameplay_actor_factory = GameplayActorFactoryV166.new()
var menu_actor_materials: Dictionary = {}

func _build_materials() -> void:
	super._build_materials()
	# The imported gameplay model replaces this fallback immediately, but the
	# actor factory still builds its root/socket contract from these materials.
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
		# Same animation authority as gameplay, held in idle for the showcase.
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

func frontend_completion_ready() -> bool:
	if not meta_environment_assets_ready() or gameplay_actor_factory == null:
		return false
	if not gameplay_actor_factory.has_method("v166_character_form_player_ready"):
		return false
	if current_screen in ["home", "hero"]:
		return actor_model != null \
			and bool(gameplay_actor_factory.call("v166_character_form_player_ready", actor_model)) \
			and String(actor_model.get_meta("character_form_v166", "")) == "1.66-character-form-r1.1"
	return true

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["frontend_completion_version"] = FRONTEND_COMPLETION_VERSION
	data["frontend_profile"] = "shared-gameplay-wanderer-authored-meta-stage"
	data["gameplay_wanderer_shared"] = actor_model != null \
		and String(actor_model.get_meta("character_form_v166", "")) == "1.66-character-form-r1.1"
	data["frontend_completion_ready"] = frontend_completion_ready()
	return data

func _build_home_stage() -> void:
	super._build_home_stage()
	# Make the actual gameplay Wanderer the focal point instead of a decorative
	# legacy glTF. Architecture remains behind the presentation plane.
	if actor_anchor != null:
		actor_anchor.position = Vector3(0.0, 1.48, -0.02)
	if actor_model != null:
		actor_model.scale = Vector3.ONE * 0.82
	_make_rune_ring(Vector3(0.0, 1.63, -0.10), 0.90, 18, mat_floor_trim)
	_add_environment_light("HomeCompletionKey", Vector3(-1.35, 3.05, 1.75), Color("cfc8ff"), 0.58, 4.0)
	_add_environment_light("HomeCompletionRim", Vector3(1.85, 2.35, 0.70), Color("d8a45f"), 0.34, 3.3)

func _build_hero_stage() -> void:
	super._build_hero_stage()
	if actor_anchor != null:
		actor_anchor.position = Vector3(0.0, 3.05, -0.02)
	if actor_model != null:
		actor_model.scale = Vector3.ONE * 0.78
	_make_rune_ring(Vector3(0.0, 3.02, -0.10), 1.02, 20, mat_purple)
	_add_environment_light("HeroCompletionKey", Vector3(-1.25, 4.35, 1.85), Color("e0d8ff"), 0.74, 4.3)
	_add_environment_light("HeroCompletionRim", Vector3(1.65, 3.70, 0.65), Color("9c78dc"), 0.38, 3.2)

func _build_forge_stage() -> void:
	super._build_forge_stage()
	_place_environment_asset(stage_root, "ForgeCompletionBannerAsset", "banner", mat_cloth, Vector3(2.58, 2.44, -2.74), Vector3(0.58, 0.58, 0.58))
	_add_environment_light("ForgeCompletionFill", Vector3(0.65, 2.65, -0.75), Color("d3c2aa"), 0.24, 3.0)

func _build_talents_stage() -> void:
	super._build_talents_stage()
	_make_rune_ring(Vector3(0.0, 0.10, -0.80), 1.62, 24, mat_purple)
	_add_environment_light("TalentCompletionRim", Vector3(0.0, 3.45, 0.20), Color("b591ff"), 0.28, 3.5)

func _build_vault_stage() -> void:
	super._build_vault_stage()
	_place_environment_asset(stage_root, "VaultCompletionBannerL", "banner", mat_cloth, Vector3(-2.34, 2.85, -2.92), Vector3(0.52, 0.52, 0.52))
	_place_environment_asset(stage_root, "VaultCompletionBannerR", "banner", mat_cloth, Vector3(2.34, 2.85, -2.92), Vector3(0.52, 0.52, 0.52))
	_add_environment_light("VaultCompletionFill", Vector3(0.0, 3.05, 0.10), Color("d9c7a0"), 0.24, 3.4)

func _build_missions_stage() -> void:
	super._build_missions_stage()
	_place_environment_asset(stage_root, "MissionCompletionBannerL", "banner", mat_cloth, Vector3(-2.72, 2.55, -2.92), Vector3(0.48, 0.48, 0.48))
	_place_environment_asset(stage_root, "MissionCompletionBannerR", "banner", mat_cloth, Vector3(2.72, 2.55, -2.92), Vector3(0.48, 0.48, 0.48))
	_add_environment_light("MissionCompletionFill", Vector3(0.0, 2.95, 0.20), Color("a8c8b5"), 0.22, 3.2)

func _build_pass_stage() -> void:
	super._build_pass_stage()
	_make_rune_ring(Vector3(0.0, 0.12, -1.25), 1.48, 22, mat_floor_trim)
	_add_environment_light("PassCompletionFill", Vector3(0.0, 3.65, 0.25), Color("d9c7ff"), 0.28, 3.6)

func _camera_position_for(screen: String) -> Vector3:
	match screen:
		"home": return Vector3(0.0, 2.76, 9.55)
		"hero": return Vector3(0.0, 3.06, 9.05)
		"forge": return Vector3(0.0, 2.84, 10.20)
		"talents": return Vector3(0.0, 2.92, 9.95)
		"vault": return Vector3(0.0, 2.86, 10.05)
		"missions": return Vector3(0.0, 2.96, 10.15)
		"pass": return Vector3(0.0, 2.94, 9.90)
		_: return super._camera_position_for(screen)

func _camera_target_for(screen: String) -> Vector3:
	match screen:
		"home": return Vector3(0.0, 2.36, -0.38)
		"hero": return Vector3(0.0, 3.04, -0.18)
		"forge": return Vector3(0.0, 2.18, -1.62)
		"talents": return Vector3(0.0, 2.12, -1.08)
		"vault": return Vector3(0.0, 2.18, -1.46)
		"missions": return Vector3(0.0, 2.08, -1.12)
		"pass": return Vector3(0.0, 2.22, -1.22)
		_: return super._camera_target_for(screen)
