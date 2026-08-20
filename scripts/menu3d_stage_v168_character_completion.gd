class_name Menu3DStageV168CharacterCompletion
extends "res://scripts/menu3d_stage_v167_completion_r12.gd"

# ONE MORE FLOOR v1.68 r1.1 — same corrected Wanderer in frontend and gameplay.

const GameplayActorFactoryV168 = preload("res://scripts/world3d_actor_factory_v168_character_completion.gd")
const FRONTEND_CHARACTER_COMPLETION_VERSION := "1.68-wanderer-visual-completion-r1.1"

func _init() -> void:
	gameplay_actor_factory = GameplayActorFactoryV168.new()

func frontend_completion_ready() -> bool:
	if not super.frontend_completion_ready():
		return false
	if current_screen in ["home", "hero"]:
		return actor_model != null \
			and gameplay_actor_factory.has_method("wanderer_completion_v168_ready") \
			and bool(gameplay_actor_factory.call("wanderer_completion_v168_ready", actor_model))
	return true

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["frontend_character_completion_version"] = FRONTEND_CHARACTER_COMPLETION_VERSION
	data["gameplay_wanderer_v168_shared"] = actor_model != null \
		and String(actor_model.get_meta("wanderer_completion_v168", "")) == FRONTEND_CHARACTER_COMPLETION_VERSION
	data["frontend_completion_ready"] = frontend_completion_ready()
	return data
