extends RefCounted

const SAVE_PATH := "user://save.cfg"
const MAX_LEVEL := 20

var xp := 0
var claimed := {}

func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	xp = int(cfg.get_value("tower_pass", "xp", 0))
	claimed = cfg.get_value("tower_pass", "claimed", {})

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("tower_pass", "xp", xp)
	cfg.set_value("tower_pass", "claimed", claimed)
	cfg.save(SAVE_PATH)

func add_xp(amount: int) -> void:
	xp = maxi(0, xp + amount)
	save_data()

func xp_for_level(level: int) -> int:
	return level * 100 + maxi(0, level - 1) * 20

func level() -> int:
	var result := 0
	for i in range(1, MAX_LEVEL + 1):
		if xp >= xp_for_level(i):
			result = i
		else:
			break
	return result

func progress_to_next() -> Dictionary:
	var current := level()
	if current >= MAX_LEVEL:
		return {"current":100, "needed":100, "ratio":1.0}
	var prev_xp := xp_for_level(current) if current > 0 else 0
	var next_xp := xp_for_level(current + 1)
	var current_xp := xp - prev_xp
	var needed := next_xp - prev_xp
	return {"current":current_xp, "needed":needed, "ratio":clampf(float(current_xp) / float(needed), 0.0, 1.0)}

func reward_for(level_no: int) -> Dictionary:
	if level_no % 5 == 0:
		return {"coins":350 + level_no * 20, "label":"BIG COIN CACHE"}
	if level_no % 3 == 0:
		return {"coins":180 + level_no * 12, "label":"COIN CACHE"}
	return {"coins":90 + level_no * 8, "label":"COINS"}

func can_claim(level_no: int) -> bool:
	return level_no > 0 and level_no <= level() and not bool(claimed.get(str(level_no), false))

func claim(level_no: int) -> Dictionary:
	if not can_claim(level_no):
		return {}
	claimed[str(level_no)] = true
	save_data()
	return reward_for(level_no)

func next_claimable() -> int:
	for i in range(1, level() + 1):
		if can_claim(i):
			return i
	return -1
