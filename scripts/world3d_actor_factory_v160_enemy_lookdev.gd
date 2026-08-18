extends "res://scripts/world3d_actor_factory_v160_enemies.gd"

# ONE MORE FLOOR v1.60 — enemy material/lookdev refinement.
# Keeps all six silhouette meshes untouched and only controls surface response:
# less mirror-like metal, rougher organic materials and restrained emission so
# shapes remain readable under the mobile GL Compatibility lighting stack.

const ENEMY_LOOKDEV_VERSION := "1.60-production-enemy-lookdev"
const LOOKDEV_KEYS := [
	"goblin_skin", "leather", "scrap_iron", "bat_body", "bat_wing",
	"bone", "bone_dark", "aged_iron", "ghoul_flesh", "ghoul_dark",
	"necro_robe", "necro_hood", "warden_armor", "warden_iron",
	"old_gold", "void", "amber_glow", "violet_glow", "red_glow",
]

func _init() -> void:
	super._init()
	_apply_enemy_lookdev_v160()

func enemy_presentation_pipeline_ready() -> bool:
	return super.enemy_presentation_pipeline_ready() and enemy_lookdev_pipeline_ready()

func enemy_lookdev_pipeline_ready() -> bool:
	for key_value in LOOKDEV_KEYS:
		var key := String(key_value)
		var material := enemy_v160_materials.get(key) as StandardMaterial3D
		if material == null or String(material.get_meta("v160_enemy_lookdev", "")) != ENEMY_LOOKDEV_VERSION:
			return false
	return true

func enemy_lookdev_snapshot() -> Dictionary:
	return {
		"ready": enemy_lookdev_pipeline_ready(),
		"version": ENEMY_LOOKDEV_VERSION,
		"material_count": LOOKDEV_KEYS.size(),
		"surface_profile": "rough-controlled-mobile",
	}

func _apply_enemy_lookdev_v160() -> void:
	_tune_enemy_material("goblin_skin", Color("46563c"), 0.00, 0.92)
	_tune_enemy_material("leather", Color("35231c"), 0.00, 0.94)
	_tune_enemy_material("scrap_iron", Color("3d4348"), 0.34, 0.72)
	_tune_enemy_material("bat_body", Color("191529"), 0.00, 0.96)
	_tune_enemy_material("bat_wing", Color("2b203b"), 0.00, 0.98)
	_tune_enemy_material("bone", Color("8f8978"), 0.00, 0.96)
	_tune_enemy_material("bone_dark", Color("5f5a50"), 0.00, 0.98)
	_tune_enemy_material("aged_iron", Color("32373d"), 0.42, 0.68)
	_tune_enemy_material("ghoul_flesh", Color("3f4a40"), 0.00, 0.96)
	_tune_enemy_material("ghoul_dark", Color("18221d"), 0.00, 0.99)
	_tune_enemy_material("necro_robe", Color("1d152a"), 0.00, 0.94)
	_tune_enemy_material("necro_hood", Color("090812"), 0.00, 0.99)
	_tune_enemy_material("warden_armor", Color("30252a"), 0.24, 0.72)
	_tune_enemy_material("warden_iron", Color("3d4046"), 0.52, 0.58)
	_tune_enemy_material("old_gold", Color("74582c"), 0.48, 0.60)
	_tune_enemy_material("void", Color("030407"), 0.00, 1.00)
	_tune_enemy_material("amber_glow", Color("663519"), 0.00, 0.72, 0.58)
	_tune_enemy_material("violet_glow", Color("41276d"), 0.00, 0.70, 0.54)
	_tune_enemy_material("red_glow", Color("5d2424"), 0.00, 0.72, 0.58)

func _tune_enemy_material(key: String, albedo: Color, metallic_value: float, roughness_value: float, emission_energy: float = -1.0) -> void:
	var material := enemy_v160_materials.get(key) as StandardMaterial3D
	if material == null:
		return
	material.albedo_color = albedo
	material.metallic = metallic_value
	material.roughness = roughness_value
	if material.emission_enabled and emission_energy >= 0.0:
		material.emission_energy_multiplier = emission_energy
	material.set_meta("v160_enemy_lookdev", ENEMY_LOOKDEV_VERSION)
