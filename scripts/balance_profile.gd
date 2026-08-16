extends RefCounted

func multipliers(floor_no: int, boss: bool) -> Dictionary:
	var hp_mult: float = 1.0
	var damage_mult: float = 1.0
	var speed_mult: float = 1.0
	if floor_no <= 3:
		hp_mult = 0.78
		damage_mult = 0.72
		speed_mult = 0.94
	elif floor_no <= 5:
		hp_mult = 0.86
		damage_mult = 0.80
		speed_mult = 0.96
	elif floor_no <= 10:
		hp_mult = 0.92
		damage_mult = 0.87
	elif floor_no <= 15:
		hp_mult = 0.96
		damage_mult = 0.92
	elif floor_no <= 20:
		hp_mult = 1.00
		damage_mult = 0.97
	elif floor_no <= 25:
		hp_mult = 1.03
		damage_mult = 1.01
	else:
		hp_mult = 1.07
		damage_mult = 1.05
	if boss:
		hp_mult *= 0.96 if floor_no < 20 else 1.02
		damage_mult *= 0.94 if floor_no < 20 else 1.00
	return {"hp": hp_mult, "damage": damage_mult, "speed": speed_mult}

func apply_enemy(enemy: Dictionary, floor_no: int) -> Dictionary:
	if bool(enemy.get("release_balanced", false)):
		return enemy
	var is_boss: bool = String(enemy.get("type", "")) == "warden"
	var m: Dictionary = multipliers(floor_no, is_boss)
	var hp: float = float(enemy.get("max_hp", enemy.get("hp", 1.0))) * float(m["hp"])
	enemy["max_hp"] = hp
	enemy["hp"] = minf(float(enemy.get("hp", hp)), hp)
	enemy["touch_damage"] = float(enemy.get("touch_damage", 0.0)) * float(m["damage"])
	enemy["speed"] = float(enemy.get("speed", 0.0)) * float(m["speed"])
	enemy["release_balanced"] = true
	return enemy

func target_room_seconds(floor_no: int) -> int:
	if floor_no <= 5:
		return 24
	if floor_no <= 10:
		return 30
	if floor_no <= 20:
		return 36
	return 42

func profile_label(floor_no: int) -> String:
	if floor_no <= 10:
		return "ENTRY CURVE"
	if floor_no <= 20:
		return "MID TOWER"
	return "CASTLE CURVE"
