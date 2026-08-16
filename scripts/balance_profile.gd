extends RefCounted

func multipliers(floor_no: int, boss: bool) -> Dictionary:
	var hp_mult := 1.0
	var damage_mult := 1.0
	var speed_mult := 1.0

	# The old release curve flattened almost completely after Floor 25. That made
	# later runs collapse into ten-second rooms once a build stacked attack speed,
	# multishot and damage. This curve keeps the opening readable, then ramps hard
	# enough to keep pace with accumulated run upgrades.
	if floor_no <= 3:
		hp_mult = 1.15
		damage_mult = 0.82
		speed_mult = 0.96
	elif floor_no <= 5:
		hp_mult = 1.45
		damage_mult = 0.92
		speed_mult = 0.98
	elif floor_no <= 10:
		hp_mult = 2.15
		damage_mult = 1.03
		speed_mult = 1.00
	elif floor_no <= 15:
		hp_mult = 2.75
		damage_mult = 1.12
		speed_mult = 1.02
	elif floor_no <= 20:
		hp_mult = 3.40
		damage_mult = 1.22
		speed_mult = 1.04
	elif floor_no <= 25:
		hp_mult = 4.20
		damage_mult = 1.34
		speed_mult = 1.06
	elif floor_no <= 30:
		hp_mult = 5.00
		damage_mult = 1.46
		speed_mult = 1.08
	elif floor_no <= 40:
		var depth := float(floor_no - 30)
		hp_mult = 5.00 * pow(1.05, depth)
		damage_mult = 1.46 * pow(1.024, depth)
		speed_mult = minf(1.18, 1.08 + depth * 0.008)
	elif floor_no <= 50:
		var depth := float(floor_no - 40)
		hp_mult = 8.15 * pow(1.06, depth)
		damage_mult = 1.85 * pow(1.030, depth)
		speed_mult = minf(1.26, 1.16 + depth * 0.010)
	else:
		var depth := float(floor_no - 50)
		hp_mult = 14.60 * pow(1.065, depth)
		damage_mult = 2.50 * pow(1.032, depth)
		speed_mult = minf(1.38, 1.26 + depth * 0.006)

	if boss:
		hp_mult *= 1.45
		damage_mult *= 1.12
		speed_mult *= 1.03
	return {"hp": hp_mult, "damage": damage_mult, "speed": speed_mult}

func apply_enemy(enemy: Dictionary, floor_no: int) -> Dictionary:
	if bool(enemy.get("release_balanced", false)):
		return enemy
	var is_boss := String(enemy.get("type", "")) == "warden"
	var m := multipliers(floor_no, is_boss)
	var hp := float(enemy.get("max_hp", enemy.get("hp", 1.0))) * float(m["hp"])
	enemy["max_hp"] = hp
	enemy["hp"] = minf(float(enemy.get("hp", hp)), hp)
	enemy["touch_damage"] = float(enemy.get("touch_damage", 0.0)) * float(m["damage"])
	enemy["speed"] = float(enemy.get("speed", 0.0)) * float(m["speed"])
	enemy["release_balanced"] = true
	return enemy

func target_room_seconds(floor_no: int) -> int:
	if floor_no <= 3:
		return 24
	if floor_no <= 10:
		return 35
	if floor_no <= 20:
		return 45
	if floor_no <= 40:
		return 55
	if floor_no <= 50:
		return 65
	return 72

func profile_label(floor_no: int) -> String:
	if floor_no <= 5:
		return "ENTRY CURVE"
	if floor_no <= 15:
		return "RISING PRESSURE"
	if floor_no <= 30:
		return "HARD TOWER"
	if floor_no <= 49:
		return "ENDURANCE"
	return "ASCENSION"
