extends RefCounted

const SAVE_PATH := "user://visual_pack.cfg"

const PACK_ORDER: Array[String] = ["citadel", "void", "eclipse", "bloodstar", "celestial"]
const PACKS := {
	"citadel": {
		"label": "CITADEL",
		"unlock_floor": 1,
		"primary": Color("9b5cff"),
		"secondary": Color("e7b84d"),
		"surface": Color("07101d"),
		"glow": Color("9b5cff"),
	},
	"void": {
		"label": "VOID",
		"unlock_floor": 50,
		"primary": Color("8357ff"),
		"secondary": Color("55d8ff"),
		"surface": Color("060817"),
		"glow": Color("6b42ff"),
	},
	"eclipse": {
		"label": "ECLIPSE",
		"unlock_floor": 100,
		"primary": Color("f1b956"),
		"secondary": Color("b05cff"),
		"surface": Color("100817"),
		"glow": Color("f1a84d"),
	},
	"bloodstar": {
		"label": "BLOODSTAR",
		"unlock_floor": 150,
		"primary": Color("ef5968"),
		"secondary": Color("f0a04b"),
		"surface": Color("16070d"),
		"glow": Color("e83d63"),
	},
	"celestial": {
		"label": "CELESTIAL",
		"unlock_floor": 200,
		"primary": Color("54d9ff"),
		"secondary": Color("d395ff"),
		"surface": Color("06111a"),
		"glow": Color("4fcfff"),
	},
}

var selected := "citadel"
var best_floor := 1

func load_data(current_best_floor: int) -> void:
	best_floor = maxi(1, current_best_floor)
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		selected = String(cfg.get_value("visual", "selected", "citadel"))
	if not is_unlocked(selected):
		selected = highest_unlocked()
	save_data()

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("visual", "selected", selected)
	cfg.set_value("visual", "best_floor_seen", best_floor)
	cfg.save(SAVE_PATH)

func refresh_unlocks(current_best_floor: int) -> void:
	best_floor = maxi(best_floor, current_best_floor)
	if not is_unlocked(selected):
		selected = highest_unlocked()
		save_data()

func is_unlocked(pack_id: String) -> bool:
	if not PACKS.has(pack_id):
		return false
	return best_floor >= int(PACKS[pack_id]["unlock_floor"])

func unlocked_ids() -> Array[String]:
	var result: Array[String] = []
	for pack_id in PACK_ORDER:
		if is_unlocked(pack_id):
			result.append(pack_id)
	return result

func unlocked_count() -> int:
	return unlocked_ids().size()

func highest_unlocked() -> String:
	var result := "citadel"
	for pack_id in PACK_ORDER:
		if is_unlocked(pack_id):
			result = pack_id
	return result

func cycle(direction: int = 1) -> String:
	var ids := unlocked_ids()
	if ids.is_empty():
		selected = "citadel"
		return selected
	var index := ids.find(selected)
	if index < 0:
		index = 0
	index = posmod(index + direction, ids.size())
	selected = ids[index]
	save_data()
	return selected

func data() -> Dictionary:
	return Dictionary(PACKS.get(selected, PACKS["citadel"]))

func label() -> String:
	return String(data().get("label", "CITADEL"))

func primary() -> Color:
	return Color(data().get("primary", Color("9b5cff")))

func secondary() -> Color:
	return Color(data().get("secondary", Color("e7b84d")))

func surface() -> Color:
	return Color(data().get("surface", Color("07101d")))

func glow() -> Color:
	return Color(data().get("glow", Color("9b5cff")))

func next_unlock_floor() -> int:
	for pack_id in PACK_ORDER:
		var floor_no := int(PACKS[pack_id]["unlock_floor"])
		if floor_no > best_floor:
			return floor_no
	return 0

func next_unlock_label() -> String:
	for pack_id in PACK_ORDER:
		var floor_no := int(PACKS[pack_id]["unlock_floor"])
		if floor_no > best_floor:
			return String(PACKS[pack_id]["label"])
	return "ALL UNLOCKED"
