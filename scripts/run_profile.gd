extends RefCounted

var floor_no := 1
var run_coins := 0
var saved_after_death := 0

var hp := 100.0
var max_hp := 100.0
var speed := 285.0
var damage := 27.0
var attack_delay := 0.48
var attack_timer := 0.0
var attack_range := 225.0
var lifesteal := 0.0
var extra_targets := 0
var crit_chance := 0.08
var crit_mult := 1.75
var armor := 0.0
var nova_mult := 2.8
var nova_radius := 250.0
var skill_cd := 0.0

# Every run starts fresh. Upgrade counts form synergies while the new scaled
# application path lets the same upgrade roll at Common/Rare/Epic/Legendary
# strength without duplicating four separate upgrade pools.
var upgrade_counts: Dictionary = {}
var active_synergies: Dictionary = {}
var last_synergy_unlocked := ""

func reset(meta) -> void:
	floor_no = 1
	run_coins = 0
	saved_after_death = 0
	max_hp = 100.0 + meta.hp_bonus()
	hp = max_hp
	speed = 285.0
	damage = 27.0 * meta.damage_multiplier()
	attack_delay = 0.48
	attack_timer = 0.12
	attack_range = 225.0
	lifesteal = 0.0
	extra_targets = 0
	crit_chance = minf(0.55, 0.08 + meta.crit_bonus())
	crit_mult = 1.75
	armor = 0.0
	nova_mult = 2.8
	nova_radius = 250.0
	skill_cd = 0.0
	upgrade_counts.clear()
	active_synergies.clear()
	last_synergy_unlocked = ""

func apply_upgrade(kind: String) -> void:
	apply_upgrade_scaled(kind, 1.0)

func apply_upgrade_scaled(kind: String, strength: float) -> void:
	strength = clampf(strength, 0.5, 3.0)
	upgrade_counts[kind] = int(upgrade_counts.get(kind, 0)) + 1
	match kind:
		"power":
			damage *= 1.0 + 0.25 * strength
		"lifesteal":
			lifesteal = minf(0.36, lifesteal + 0.05 * strength)
		"multi":
			var shots := 2 if strength >= 2.0 else 1
			extra_targets = mini(5, extra_targets + shots)
		"haste":
			attack_delay = maxf(0.16, attack_delay * maxf(0.54, 1.0 - 0.18 * strength))
		"range":
			attack_range *= 1.0 + 0.22 * strength
		"vitality":
			var hp_gain := 25.0 * strength
			max_hp += hp_gain
			hp = minf(max_hp, hp + hp_gain)
		"speed":
			speed *= 1.0 + 0.12 * strength
		"crit":
			crit_chance = minf(0.68, crit_chance + 0.08 * strength)
		"nova":
			nova_mult *= 1.0 + 0.25 * strength
			nova_radius = minf(440.0, nova_radius * (1.0 + 0.25 * strength))
		"armor":
			armor = minf(0.55, armor + 0.08 * strength)
	_evaluate_synergies()

func upgrade_count(kind: String) -> int:
	return int(upgrade_counts.get(kind, 0))

func has_synergy(id: String) -> bool:
	return bool(active_synergies.get(id, false))

func synergy_count() -> int:
	return active_synergies.size()

func synergy_label(id: String) -> String:
	match id:
		"shatter_volley": return "SHATTER VOLLEY"
		"bloodsteel": return "BLOODSTEEL"
		"stormcore": return "STORMCORE"
		"hunters_edge": return "HUNTER'S EDGE"
		"momentum": return "MOMENTUM"
	return id.to_upper()

func active_synergy_names() -> Array[String]:
	var names: Array[String] = []
	for id in ["shatter_volley", "bloodsteel", "stormcore", "hunters_edge", "momentum"]:
		if has_synergy(id):
			names.append(synergy_label(id))
	return names

func consume_synergy_notice() -> String:
	var result := last_synergy_unlocked
	last_synergy_unlocked = ""
	return result

func _evaluate_synergies() -> void:
	if upgrade_count("multi") > 0 and upgrade_count("crit") > 0:
		_unlock_synergy("shatter_volley", "SHATTER VOLLEY")
	if upgrade_count("lifesteal") > 0 and upgrade_count("armor") > 0:
		_unlock_synergy("bloodsteel", "BLOODSTEEL")
	if upgrade_count("nova") > 0 and upgrade_count("haste") > 0:
		_unlock_synergy("stormcore", "STORMCORE")
	if upgrade_count("power") > 0 and upgrade_count("range") > 0:
		_unlock_synergy("hunters_edge", "HUNTER'S EDGE")
	if upgrade_count("haste") > 0 and upgrade_count("speed") > 0:
		_unlock_synergy("momentum", "MOMENTUM")

func _unlock_synergy(id: String, display_name: String) -> void:
	if bool(active_synergies.get(id, false)):
		return
	active_synergies[id] = true
	last_synergy_unlocked = display_name
	match id:
		"shatter_volley":
			crit_mult += 0.35
			damage *= 1.08
		"bloodsteel":
			max_hp += 25.0
			hp = minf(max_hp, hp + 25.0)
			armor = minf(0.48, armor + 0.04)
		"stormcore":
			nova_mult *= 1.30
			nova_radius = minf(440.0, nova_radius + 35.0)
		"hunters_edge":
			damage *= 1.12
			attack_range *= 1.12
		"momentum":
			speed *= 1.08
			attack_delay = maxf(0.16, attack_delay * 0.92)

func next_floor() -> void:
	floor_no += 1
	hp = minf(max_hp, hp + max_hp * 0.18)

func death_secure_amount() -> int:
	return int(round(float(run_coins) * 0.60))
