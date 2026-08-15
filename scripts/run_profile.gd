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

func apply_upgrade(kind: String) -> void:
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

func next_floor() -> void:
	floor_no += 1
	hp = minf(max_hp, hp + max_hp * 0.18)

func death_secure_amount() -> int:
	return int(round(float(run_coins) * 0.60))
