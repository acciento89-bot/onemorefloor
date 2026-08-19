extends "res://scripts/world3d_chamber_v163_boss_dominance.gd"

# ONE MORE FLOOR v1.64 r1.1 — character lighting/material integration.
# Presentation only. Keeps the accepted v1.63 combat identity stack intact and
# fixes gameplay-distance character readability through restrained material
# midtone recovery plus the already-existing Wanderer rim/fill lights.
# No geometry, pivots, animation, gameplay, hitbox, timing or VFX semantics move.

const CHARACTER_LIGHTING_VERSION := "1.64-character-lighting-r1.1"
const CHARACTER_LIGHTING_MATERIAL_TARGET := 11

var v164_character_materials_tuned := 0
var v164_character_lighting_applied := false

func _ready() -> void:
	super._ready()
	_apply_v164_character_material_response()
	_configure_v164_player_readability_lights()

func sync_runtime(
	player_pos: Vector2,
	enemies: Array,
	player_shots: Array,
	enemy_shots: Array,
	coins: Array,
	joy: Vector2,
	elapsed_value: float,
	attack_flash: float,
	skill_flash: float,
	floor_no: int
) -> void:
	# Enemy quality r2/r3 intentionally reapplies each archetype's accepted base
	# surface during configure_enemy(). Let that complete first, then make v1.64
	# the final presentation-only material write. Meshes share these materials, so
	# no actor rebuild, geometry change or gameplay-state mutation is required.
	super.sync_runtime(
		player_pos, enemies, player_shots, enemy_shots, coins, joy,
		elapsed_value, attack_flash, skill_flash, floor_no
	)
	_apply_v164_enemy_material_response(false)

func _apply_v160_atmosphere_grade(floor_no: int) -> void:
	# v1.60 remains the realm/grade owner. r1.1 only nudges the two existing local
	# Wanderer lights after the realm has selected their colors and base energy.
	super._apply_v160_atmosphere_grade(floor_no)
	_apply_v164_player_light_grade()

func production_character_lighting_ready() -> bool:
	return production_boss_dominance_ready() \
		and v164_character_lighting_applied \
		and v164_character_materials_tuned >= CHARACTER_LIGHTING_MATERIAL_TARGET \
		and player_rim_light != null \
		and player_fill_light != null \
		and player_rim_light.omni_range >= 2.80 \
		and player_fill_light.omni_range >= 2.40

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_character_lighting_ready"] = production_character_lighting_ready()
	data["production_character_lighting_version"] = CHARACTER_LIGHTING_VERSION
	data["production_character_materials_tuned"] = v164_character_materials_tuned
	data["production_character_material_target"] = CHARACTER_LIGHTING_MATERIAL_TARGET
	data["production_character_lighting_realm"] = atmosphere_realm
	data["production_character_rim_base"] = atmosphere_player_rim_base
	data["production_character_fill_base"] = atmosphere_player_fill_base
	data["production_character_rim_range"] = player_rim_light.omni_range if player_rim_light != null else -1.0
	data["production_character_fill_range"] = player_fill_light.omni_range if player_fill_light != null else -1.0
	return data

func _apply_v164_character_material_response() -> void:
	v164_character_materials_tuned = 0
	if actor_factory == null:
		return

	# Wanderer: recover cloth/plate separation without bleaching the dark-fantasy
	# palette. Blade/arcane/gold stay on the accepted v1.60 response because they
	# already read correctly in the frozen v1.63/v1.64 baseline frames.
	var wanderer_materials: Dictionary = actor_factory.wanderer_materials
	_tune_character_material(wanderer_materials, "cloth", Color("293750"), Color("8299cb"))
	_tune_character_material(wanderer_materials, "cape", Color("352444"), Color("8b64a0"))
	_tune_character_material(wanderer_materials, "steel_dark", Color("36465b"), Color("8298b3"))
	_tune_character_material(wanderer_materials, "leather", Color("553425"), Color("a97351"))
	_tune_character_material(wanderer_materials, "void", Color("0d1320"), Color("384460"))

	# Count the initial enemy integration for the readiness contract. The same
	# five shared materials are re-applied after runtime enemy configuration with
	# count_tuning=false so the counter remains stable instead of growing per tick.
	_apply_v164_enemy_material_response(true)

	# Hood r11 intentionally owns a duplicated cloth material, so it needs the
	# same controlled recovery independently of the shared Wanderer cloth entry.
	var imported := player_root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D if player_root != null else null
	var hood := _find_v164_mesh(imported, "V160AuthoredHood")
	if hood != null:
		var hood_material := hood.material_override as ShaderMaterial
		if hood_material != null:
			hood_material.set_shader_parameter("base_color", Color("26364a"))
			hood_material.set_shader_parameter("edge_color", Color("63778d"))
			hood_material.set_shader_parameter("roughness", 0.92)
			hood_material.set_shader_parameter("specular_level", 0.16)
			hood_material.set_shader_parameter("edge_strength", 0.15)
			v164_character_materials_tuned += 1

	v164_character_lighting_applied = v164_character_materials_tuned >= CHARACTER_LIGHTING_MATERIAL_TARGET

func _apply_v164_enemy_material_response(count_tuning: bool) -> void:
	if actor_factory == null:
		return
	# Skeleton remains an explicit visual lock. These five authored body cores use
	# the r5.1 character shader and receive the smallest useful midtone recovery.
	var enemy_materials: Dictionary = actor_factory.character_enemy_materials
	_tune_character_material(enemy_materials, "goblin", Color("3d563b"), Color("7d9476"), count_tuning)
	_tune_character_material(enemy_materials, "bat", Color("241c30"), Color("735d87"), count_tuning)
	_tune_character_material(enemy_materials, "ghoul", Color("354b40"), Color("708779"), count_tuning)
	_tune_character_material(enemy_materials, "necromancer", Color("2d203b"), Color("81699a"), count_tuning)
	_tune_character_material(enemy_materials, "warden", Color("334357"), Color("879db5"), count_tuning)

func _tune_character_material(
	materials: Dictionary,
	key: String,
	base: Color,
	edge: Color,
	count_tuning: bool = true
) -> void:
	var material := materials.get(key) as ShaderMaterial
	if material == null:
		return
	material.set_shader_parameter("base_color", base)
	material.set_shader_parameter("edge_color", edge)
	if count_tuning:
		v164_character_materials_tuned += 1

func _configure_v164_player_readability_lights() -> void:
	# Re-use the two accepted mobile-safe Omni lights; no new light sources or
	# screen-space effects are introduced by v1.64 r1.1.
	if player_rim_light != null:
		player_rim_light.omni_range = 2.85
	if player_fill_light != null:
		player_fill_light.omni_range = 2.45
	_apply_v164_player_light_grade()

func _apply_v164_player_light_grade() -> void:
	match atmosphere_realm:
		"ossuary":
			atmosphere_player_rim_base = 0.53
			atmosphere_player_fill_base = 0.28
		"iron_bastion":
			atmosphere_player_rim_base = 0.54
			atmosphere_player_fill_base = 0.31
		"rift_descent":
			atmosphere_player_rim_base = 0.57
			atmosphere_player_fill_base = 0.30
		"starless_spire":
			atmosphere_player_rim_base = 0.56
			atmosphere_player_fill_base = 0.30
		_:
			atmosphere_player_rim_base = 0.54
			atmosphere_player_fill_base = 0.30

func _find_v164_mesh(root_node: Node, target_name: String) -> MeshInstance3D:
	if root_node == null:
		return null
	if root_node is MeshInstance3D and String(root_node.name) == target_name:
		return root_node as MeshInstance3D
	for child_value in root_node.get_children():
		var found := _find_v164_mesh(child_value as Node, target_name)
		if found != null:
			return found
	return null
