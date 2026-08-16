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

# Run-build depth. These values are intentionally not persisted: every tower run
# starts fresh, but combinations of upgrades can unlock one-time synergies.
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
	upgrade_counts[kind] = int(upgrade_counts.get(kind, 0)) + 1
	match kind:
		"power": damage *= 1.25
		"lifesteal": lifesteal = minf(0.30, lifesteal + 0.05)
		"multi": extra_targets = mini(4, extra_targets + 1)
		"haste": attack_delay = maxf(0.18, attack_delay * 0.82)
		"range": attack_range *= 1.22
		"vitality":
			max_hp += 25.0
			hp = minf(max_hp, hp + 25.0)
		"speed": speed *= 1.12
		"crit": crit_chance = minf(0.55, crit_chance + 0.08)
		"nova":
			nova_mult *= 1.25
			nova_radius = minf(390.0, nova_radius * 1.25)
		"armor": armor = minf(0.40, armor + 0.08)
	_evaluate_synergies()

func upgrade_count(kind: String) -> int:
	return int(upgrade_counts.get(kind, 0))

func has_synergy(id: String) -> bool:
	return bool(active_synergies.get(id, false))

func synergy_count() -> int:
	return active_synergies.size()

func consume_synergy_notice() -> String:
	var result := last_synergy_unlocked
	last_synergy_unlocked = ""
	return result

func _evaluate_synergies() -> void:
	# MULTISHOT + DEADLY EDGE: stronger crits and slightly higher base output.
	if upgrade_count("multi") > 0 and upgrade_count("crit") > 0:
		_unlock_synergy("shatter_volley", "SHATTER VOLLEY")
	# BLOOD PACT + WARDEN'S PLATE: sustain build becomes genuinely tanky.
	if upgrade_count("lifesteal") > 0 and upgrade_count("armor") > 0:
		_unlock_synergy("bloodsteel", "BLOODSTEEL")
	# NOVA CORE + QUICK HANDS: turns NOVA into a heavier room-clearing tool.
	if upgrade_count("nova") > 0 and upgrade_count("haste") > 0:
		_unlock_synergy("stormcore", "STORMCORE")
	# POWER SURGE + LONG REACH: rewards a ranged damage build.
	if upgrade_count("power") > 0 and upgrade_count("range") > 0:
		_unlock_synergy("hunters_edge", "HUNTER'S EDGE")
	# QUICK HANDS + SWIFT BOOTS: high-mobility attack build.
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
			nova_radius = minf(420.0, nova_radius + 35.0)
		"hunters_edge":
			damage *= 1.12
			attack_range *= 1.12
		"momentum":
			speed *= 1.08
			attack_delay = maxf(0.18, attack_delay * 0.92)

func next_floor() -> void:
	floor_no += 1
	hp = minf(max_hp, hp + max_hp * 0.18)

func death_secure_amount() -> int:
	return int(round(float(run_coins) * 0.60))
