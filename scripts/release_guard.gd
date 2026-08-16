extends RefCounted

# Lightweight release safety net. It never invents progress: it only clamps
# impossible negative/corrupt values after the normal save loaders have run, then
# keeps one last-known-good copy of save.cfg for support/recovery diagnostics.

const SAVE_PATH := "user://save.cfg"
const BACKUP_PATH := "user://save_last_good.cfg"

func validate(meta, loot) -> Dictionary:
	var repairs: Array[String] = []
	if meta != null:
		if int(meta.best_floor) < 1:
			meta.best_floor = 1
			repairs.append("best_floor")
		if int(meta.checkpoint_floor) > 1 and int(meta.checkpoint_floor) < 50:
			meta.checkpoint_floor = 1
			repairs.append("checkpoint_floor")
		if int(meta.checkpoint_floor) > int(meta.best_floor):
			meta.checkpoint_floor = maxi(1, int(meta.best_floor))
			if int(meta.checkpoint_floor) > 1 and int(meta.checkpoint_floor) < 50:
				meta.checkpoint_floor = 1
			repairs.append("checkpoint_ahead_of_best")
		for prop in ["coins", "hero_level", "forge_level", "vitality_level", "precision_level", "fortune_level"]:
			var value := int(meta.get(prop))
			var minimum := 1 if prop == "hero_level" else 0
			if value < minimum:
				meta.set(prop, minimum)
				repairs.append(prop)
		if not repairs.is_empty():
			meta.save_data()
	if loot != null:
		if int(loot.shards) < 0:
			loot.shards = 0
			repairs.append("shards")
			loot.save_data()
	return {"ok": repairs.is_empty(), "repairs": repairs}

func backup_last_good() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var src := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if src == null:
		return false
	var bytes := src.get_buffer(src.get_length())
	var dst := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
	if dst == null:
		return false
	dst.store_buffer(bytes)
	return true

func backup_exists() -> bool:
	return FileAccess.file_exists(BACKUP_PATH)
