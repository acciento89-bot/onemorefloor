extends RefCounted

# v1.21 — Economy / Balance 2.0
# Permanent upgrades must feel useful, but an overgeared character should not be
# able to delete an entire realm forever. This adds a soft adaptive pressure band:
# only players far above the recommended persistent Power receive extra enemy HP
# and damage, with a smaller reward increase in return.

func recommended_power(floor_no: int) -> int:
	var floor_value := maxi(1, floor_no)
	var base := 180.0 + float(floor_value) * 58.0 + pow(float(floor_value), 1.34) * 8.0
	if floor_value >= 50:
		base *= 1.08
	if floor_value >= 100:
		base *= 1.10
	if floor_value >= 150:
		base *= 1.12
	if floor_value >= 200:
		base *= 1.15
	return int(round(base))

func power_ratio(player_power: int, floor_no: int) -> float:
	return float(maxi(1, player_power)) / float(maxi(1, recommended_power(floor_no)))

func adaptive_pressure(player_power: int, floor_no: int) -> Dictionary:
	var ratio := power_ratio(player_power, floor_no)
	if ratio <= 1.15:
		return {"active":false, "ratio":ratio, "hp":1.0, "damage":1.0, "reward":1.0, "label":"BALANCED"}
	var excess := clampf((ratio - 1.15) / 1.60, 0.0, 1.0)
	var hp_mult := 1.0 + excess * 0.62
	var damage_mult := 1.0 + excess * 0.28
	var reward_mult := 1.0 + excess * 0.22
	var label := "HIGH THREAT" if excess < 0.55 else "OVERGEARED THREAT"
	return {"active":true, "ratio":ratio, "hp":hp_mult, "damage":damage_mult, "reward":reward_mult, "label":label}

func mission_coin_multiplier(best_floor: int) -> float:
	if best_floor >= 200: return 1.85
	if best_floor >= 150: return 1.65
	if best_floor >= 100: return 1.45
	if best_floor >= 50: return 1.25
	if best_floor >= 25: return 1.12
	return 1.0

func pass_coin_multiplier(best_floor: int) -> float:
	if best_floor >= 200: return 1.55
	if best_floor >= 100: return 1.35
	if best_floor >= 50: return 1.18
	return 1.0

func deep_reward_bonus(floor_no: int) -> float:
	if floor_no >= 250: return 1.55
	if floor_no >= 200: return 1.42
	if floor_no >= 150: return 1.32
	if floor_no >= 100: return 1.22
	if floor_no >= 50: return 1.12
	return 1.0

func economy_band(player_power: int, floor_no: int) -> String:
	var ratio := power_ratio(player_power, floor_no)
	if ratio < 0.75: return "UNDERGEARED"
	if ratio <= 1.15: return "ON CURVE"
	if ratio <= 1.65: return "AHEAD"
	return "OVERGEARED"
