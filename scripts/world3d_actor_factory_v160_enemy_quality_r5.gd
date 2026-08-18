extends "res://scripts/world3d_actor_factory_v160_enemy_quality_r4.gd"

# ONE MORE FLOOR v1.60 — character body surface sophistication r5.
# Keeps r2/r3 anatomy and r4 secondary detail geometry fixed. Only the six
# authored body-core ShaderMaterials move to the character-only mobile shader.
# Skeleton uses zero extra breakup to preserve its locked visual baseline.

const CHARACTER_SURFACE_R5_SHADER: Shader = preload("res://assets/shaders/v160_character_surface_r5.gdshader")
const ENEMY_SURFACE_R5_VERSION := "1.60-enemy-character-surface-r5"

func _init() -> void:
	super._init()
	_upgrade_character_body_materials_r5()

func configure_enemy(root: Node3D, kind: String, materials: Dictionary) -> void:
	super.configure_enemy(root, kind, materials)
	if root == null or imported_model_active(root):
		return
	root.set_meta("enemy_character_surface_r5", kind != "skeleton")
	root.set_meta("enemy_character_surface_r5_version", ENEMY_SURFACE_R5_VERSION)

func character_quality_snapshot(root: Node3D = null) -> Dictionary:
	var data: Dictionary = super.character_quality_snapshot(root)
	data["enemy_character_surface_r5_version"] = ENEMY_SURFACE_R5_VERSION
	data["enemy_character_surface_r5_profile"] = "character-only-procedural-tonal-roughness-breakup"
	data["enemy_character_surface_r5_skeleton_extra_breakup"] = false
	return data

func _upgrade_character_body_materials_r5() -> void:
	for kind_value in character_enemy_materials.keys():
		_upgrade_character_body_material_r5(String(kind_value))

func _upgrade_character_body_material_r5(kind: String) -> void:
	var material := character_enemy_materials.get(kind) as ShaderMaterial
	if material == null:
		return

	# Preserve the established r2/r3 body color/lighting values while swapping
	# only the shader implementation. Matching standard uniforms are restored
	# explicitly so the upgrade cannot silently reset the approved palette.
	var standard := {
		"base_color": material.get_shader_parameter("base_color"),
		"edge_color": material.get_shader_parameter("edge_color"),
		"metallic": material.get_shader_parameter("metallic"),
		"roughness": material.get_shader_parameter("roughness"),
		"specular_level": material.get_shader_parameter("specular_level"),
		"edge_strength": material.get_shader_parameter("edge_strength"),
		"height_strength": material.get_shader_parameter("height_strength"),
		"variation_strength": material.get_shader_parameter("variation_strength"),
		"emission_color": material.get_shader_parameter("emission_color"),
		"emission_strength": material.get_shader_parameter("emission_strength"),
	}
	material.shader = CHARACTER_SURFACE_R5_SHADER
	for key_value in standard.keys():
		var value: Variant = standard[key_value]
		if value != null:
			material.set_shader_parameter(StringName(key_value), value)

	match kind:
		"goblin":
			_set_body_detail(material, Color("5a613f"), 0.080, 7.0, 0.10, 0.16)
		"bat":
			_set_body_detail(material, Color("32233f"), 0.070, 9.5, 0.08, 0.08)
		"skeleton":
			# Locked baseline: use the compatible character shader but zero extra
			# r5 pattern/roughness breakup so the accepted Skeleton look is stable.
			_set_body_detail(material, Color("858071"), 0.000, 8.0, 0.00, 0.00)
		"ghoul":
			_set_body_detail(material, Color("465442"), 0.075, 6.2, 0.11, 0.20)
		"necromancer":
			# Strong directional bias creates subtle fabric-like vertical tonal
			# variation across the large r3 robe panels without UVs/textures.
			_set_body_detail(material, Color("382745"), 0.070, 11.5, 0.09, 0.78)
		"warden":
			# Metal stays low in color breakup but gets more roughness variation,
			# producing controlled worn-steel response rather than painted plastic.
			_set_body_detail(material, Color("465669"), 0.045, 13.0, 0.15, 0.10)

func _set_body_detail(
	material: ShaderMaterial,
	detail_color_value: Color,
	detail_strength_value: float,
	detail_scale_value: float,
	roughness_variation_value: float,
	directional_detail_value: float
) -> void:
	material.set_shader_parameter("detail_color", detail_color_value)
	material.set_shader_parameter("detail_strength", detail_strength_value)
	material.set_shader_parameter("detail_scale", detail_scale_value)
	material.set_shader_parameter("roughness_variation", roughness_variation_value)
	material.set_shader_parameter("directional_detail", directional_detail_value)
