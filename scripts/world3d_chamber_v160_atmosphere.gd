extends "res://scripts/world3d_chamber_v160_combat_polish.gd"

# ONE MORE FLOOR v1.60 — mobile-safe atmosphere / lighting grade.
# Rebalances the existing lights instead of adding post-process, fog or extra
# shadow casters. The goal is clearer material volume, realm identity and actor
# separation under GL Compatibility without touching gameplay authority.

const ATMOSPHERE_VERSION := "1.60-production-atmosphere"
const ATMOSPHERE_REALMS := ["lower_halls", "ossuary", "iron_bastion", "rift_descent", "starless_spire"]

var atmosphere_world: WorldEnvironment
var atmosphere_key: DirectionalLight3D
var atmosphere_warm: OmniLight3D
var atmosphere_arcane: OmniLight3D
var atmosphere_realm := ""
var atmosphere_rim_color := Color("9078b7")
var atmosphere_fill_color := Color("c39a70")
var atmosphere_player_rim_base := 0.48
var atmosphere_player_fill_base := 0.24

func _ready() -> void:
	super._ready()
	_resolve_v160_atmosphere_lights()
	_configure_v160_atmosphere_structure()
	_retire_v160_legacy_floor_signals()

func _process(delta: float) -> void:
	super._process(delta)
	_limit_v160_dynamic_light_energy()

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
	# Let the complete legacy/v1.60 runtime stack update first. v1.49 intentionally
	# re-applies its own realm lookdev near the end of that chain, including the old
	# 0.34/0.30 ambient level. The final v1.60 grade therefore has to own the last
	# presentation write after super returns, while gameplay/state stays inherited.
	super.sync_runtime(
		player_pos, enemies, player_shots, enemy_shots, coins, joy,
		elapsed_value, attack_flash, skill_flash, floor_no
	)
	_apply_v160_atmosphere_grade(floor_no)
	_update_player_lighting()
	_limit_v160_dynamic_light_energy()

func _apply_floor_identity(floor_no: int) -> void:
	super._apply_floor_identity(floor_no)
	_apply_v160_atmosphere_grade(floor_no)

func production_atmosphere_ready() -> bool:
	return super.production_combat_vfx_ready() \
		and atmosphere_world != null \
		and atmosphere_world.environment != null \
		and atmosphere_key != null \
		and atmosphere_warm != null \
		and atmosphere_arcane != null \
		and player_rim_light != null \
		and player_fill_light != null \
		and camera != null

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["production_atmosphere_ready"] = production_atmosphere_ready()
	data["production_atmosphere_version"] = ATMOSPHERE_VERSION
	data["production_atmosphere_realm"] = atmosphere_realm
	data["production_atmosphere_key_energy"] = atmosphere_key.light_energy if atmosphere_key != null else -1.0
	data["production_atmosphere_warm_energy"] = atmosphere_warm.light_energy if atmosphere_warm != null else -1.0
	data["production_atmosphere_arcane_energy"] = atmosphere_arcane.light_energy if atmosphere_arcane != null else -1.0
	data["production_atmosphere_ambient_energy"] = atmosphere_world.environment.ambient_light_energy if atmosphere_world != null and atmosphere_world.environment != null else -1.0
	data["production_atmosphere_camera_size"] = camera_base_size
	return data

func _resolve_v160_atmosphere_lights() -> void:
	atmosphere_world = get_node_or_null("WorldEnvironment") as WorldEnvironment
	atmosphere_key = get_node_or_null("MoonKey") as DirectionalLight3D
	atmosphere_warm = get_node_or_null("WarmTorchLight") as OmniLight3D
	atmosphere_arcane = get_node_or_null("ArcaneLight") as OmniLight3D

func _configure_v160_atmosphere_structure() -> void:
	if atmosphere_warm != null:
		atmosphere_warm.omni_range = 6.25
		atmosphere_warm.shadow_enabled = false
	if atmosphere_arcane != null:
		atmosphere_arcane.omni_range = 5.80
		atmosphere_arcane.shadow_enabled = false
	if player_rim_light != null:
		player_rim_light.omni_range = 2.65
	if player_fill_light != null:
		player_fill_light.omni_range = 2.20
	if player_combat_light != null:
		player_combat_light.omni_range = 2.55
	# Preserve the v1.60 isometric angle, but trim a little empty floor from the
	# portrait composition so actors/materials read more clearly on phone screens.
	if camera != null:
		camera_base_size = 15.85
		camera.size = camera_base_size

func _retire_v160_legacy_floor_signals() -> void:
	# Lower Halls and Ossuary still inherit the bright v1.41/v1.43 decorative
	# lane sigils. In the authored v1.60 floor composition those permanent rings
	# compete with real telegraphs, impacts and spawn/death VFX. Keep the historic
	# realm kits intact for their own regression tests and suppress only their
	# always-on presentation here at the final v1.60 layer.
	if production_details_root != null:
		for child_value in production_details_root.get_children():
			var child := child_value as Node3D
			if child != null and child.name == "FloorSigil":
				child.visible = false
	if ossuary_root != null:
		for child_value in ossuary_root.get_children():
			var child := child_value as Node3D
			if child != null and child.name == "OssuarySigil":
				child.visible = false

func _apply_v160_atmosphere_grade(floor_no: int) -> void:
	if not production_atmosphere_ready():
		return
	var realm := _realm_for_floor_v149(floor_no)
	atmosphere_realm = realm

	# Lower Halls establishes the baseline: darker than the legacy 0.34 wash, but
	# still bright enough for stone/material read on a phone-sized viewport.
	var background := Color("02040a")
	var ambient := Color("3d3943")
	var ambient_energy := 0.22
	var key_color := Color("cbc8d7")
	var key_energy := 1.00
	var warm_color := Color("df8854")
	var warm_energy := 1.25
	var arcane_color := Color("74669b")
	var arcane_energy := 0.55
	var saturation := 0.86
	atmosphere_rim_color = Color("8e78b5")
	atmosphere_fill_color = Color("c9a27c")
	atmosphere_player_rim_base = 0.48
	atmosphere_player_fill_base = 0.24

	match realm:
		"ossuary":
			background = Color("010506")
			ambient = Color("304344")
			ambient_energy = 0.18
			key_color = Color("aec8c7")
			key_energy = 0.94
			warm_color = Color("93614c")
			warm_energy = 0.38
			arcane_color = Color("5ba6a4")
			arcane_energy = 1.00
			saturation = 0.80
			atmosphere_rim_color = Color("76b8b5")
			atmosphere_fill_color = Color("adc5ba")
			atmosphere_player_rim_base = 0.45
			atmosphere_player_fill_base = 0.21
		"iron_bastion":
			background = Color("070302")
			ambient = Color("534036")
			ambient_energy = 0.23
			key_color = Color("d3b49d")
			key_energy = 1.04
			warm_color = Color("e6743c")
			warm_energy = 1.48
			arcane_color = Color("806b70")
			arcane_energy = 0.20
			saturation = 0.84
			atmosphere_rim_color = Color("ba8058")
			atmosphere_fill_color = Color("e0ad7a")
			atmosphere_player_rim_base = 0.48
			atmosphere_player_fill_base = 0.25
		"rift_descent":
			background = Color("030106")
			ambient = Color("362747")
			ambient_energy = 0.17
			key_color = Color("afa0c6")
			key_energy = 0.88
			warm_color = Color("795056")
			warm_energy = 0.16
			arcane_color = Color("7d4eae")
			arcane_energy = 1.20
			saturation = 0.86
			atmosphere_rim_color = Color("9968bd")
			atmosphere_fill_color = Color("7293a4")
			atmosphere_player_rim_base = 0.46
			atmosphere_player_fill_base = 0.20
		"starless_spire":
			background = Color("010207")
			ambient = Color("293348")
			ambient_energy = 0.16
			key_color = Color("8ea4ca")
			key_energy = 0.82
			warm_color = Color("625058")
			warm_energy = 0.08
			arcane_color = Color("5d73a8")
			arcane_energy = 0.82
			saturation = 0.76
			atmosphere_rim_color = Color("7189bb")
			atmosphere_fill_color = Color("b0bdd3")
			atmosphere_player_rim_base = 0.42
			atmosphere_player_fill_base = 0.18
		_:
			pass

	var env := atmosphere_world.environment
	env.background_color = background
	env.ambient_light_color = ambient
	env.ambient_light_energy = ambient_energy
	env.adjustment_enabled = true
	env.adjustment_brightness = 0.99
	env.adjustment_contrast = 1.13
	env.adjustment_saturation = saturation

	atmosphere_key.light_color = key_color
	atmosphere_key.light_energy = key_energy
	atmosphere_warm.light_color = warm_color
	atmosphere_warm.light_energy = warm_energy
	atmosphere_arcane.light_color = arcane_color
	atmosphere_arcane.light_energy = arcane_energy

	if player_rim_light != null:
		player_rim_light.light_color = atmosphere_rim_color
	if player_fill_light != null:
		player_fill_light.light_color = atmosphere_fill_color
	if player_combat_light != null:
		player_combat_light.light_color = atmosphere_rim_color

func _update_player_lighting() -> void:
	if player_root == null or player_rim_light == null or player_fill_light == null:
		return
	var chest_socket: Node3D = actor_factory.call("actor_socket", player_root, "chest") as Node3D
	var target: Vector3 = chest_socket.global_position if chest_socket != null else player_root.global_position + Vector3(0.0, 0.9, 0.0)
	player_rim_light.global_position = target + Vector3(-0.82, 0.86, 0.48)
	player_fill_light.global_position = target + Vector3(0.68, 0.42, -0.36)
	player_rim_light.light_color = atmosphere_rim_color
	player_fill_light.light_color = atmosphere_fill_color
	player_rim_light.light_energy = atmosphere_player_rim_base + move_amount * 0.07 + attack_amount * 0.14 + skill_amount * 0.28
	player_fill_light.light_energy = atmosphere_player_fill_base + attack_amount * 0.09 + skill_amount * 0.13
	if player_combat_light != null:
		var vfx_socket: Node3D = actor_factory.call("actor_socket", player_root, "vfx") as Node3D
		player_combat_light.global_position = vfx_socket.global_position if vfx_socket != null else target
		player_combat_light.light_color = atmosphere_rim_color
		player_combat_light.light_energy = attack_amount * 0.28 + skill_amount * 0.72

func _limit_v160_dynamic_light_energy() -> void:
	if boss_dominance_light != null:
		boss_dominance_light.light_energy = minf(boss_dominance_light.light_energy, 0.62)
	for slot_value in enemy_vfx_slots:
		var slot := slot_value as Node3D
		if slot == null:
			continue
		var light := slot.get_node_or_null("CombatAccentLight") as OmniLight3D
		if light != null:
			light.light_energy = minf(light.light_energy, 0.68)