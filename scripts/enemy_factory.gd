extends RefCounted

static func make_enemy(kind: String, floor_no: int, rng: RandomNumberGenerator, player_pos: Vector2) -> Dictionary:
	var pos := random_spawn_pos(rng, player_pos)
	var base_hp := 42.0 + float(floor_no) * 10.0
	if kind == "goblin":
		return {
			"type":"goblin","pos":pos,"hp":base_hp,"max_hp":base_hp,
			"speed":80.0 + floor_no * 1.4,"radius":22.0,
			"touch_damage":9.0 + floor_no * 0.55,"reward":4 + floor_no,
			"touch_cd":0.0,"attack_cd":0.0,"phase":rng.randf_range(0.0, TAU),
			"cast_timer":0.0,"cast_kind":"","phase2":false,"attack_index":0
		}
	if kind == "bat":
		var bat_hp := base_hp * 0.66
		return {
			"type":"bat","pos":pos,"hp":bat_hp,"max_hp":bat_hp,
			"speed":132.0 + floor_no * 1.7,"radius":17.0,
			"touch_damage":7.0 + floor_no * 0.45,"reward":3 + floor_no,
			"touch_cd":0.0,"attack_cd":0.0,"phase":rng.randf_range(0.0, TAU),
			"cast_timer":0.0,"cast_kind":"","phase2":false,"attack_index":0
		}
	if kind == "skeleton":
		var sk_hp := base_hp * 0.86
		return {
			"type":"skeleton","pos":pos,"hp":sk_hp,"max_hp":sk_hp,
			"speed":66.0 + floor_no * 1.1,"radius":20.0,
			"touch_damage":8.0 + floor_no * 0.42,"reward":5 + floor_no,
			"touch_cd":0.0,"attack_cd":rng.randf_range(0.35, 1.1),"phase":rng.randf_range(0.0, TAU),
			"cast_timer":0.0,"cast_kind":"","phase2":false,"attack_index":0
		}
	var boss_hp := 310.0 + float(floor_no) * 48.0
	return {
		"type":"warden","pos":pos,"hp":boss_hp,"max_hp":boss_hp,
		"speed":62.0 + floor_no * 0.5,"radius":48.0,
		"touch_damage":22.0 + floor_no * 0.8,"reward":70 + floor_no * 7,
		"touch_cd":0.0,"attack_cd":1.15,"phase":rng.randf_range(0.0, TAU),
		"cast_timer":0.0,"cast_kind":"","phase2":false,"attack_index":0
	}

static func random_spawn_pos(rng: RandomNumberGenerator, player_pos: Vector2) -> Vector2:
	var pos := Vector2(rng.randf_range(88, 632), rng.randf_range(220, 920))
	var guard := 0
	while pos.distance_to(player_pos) < 245.0 and guard < 20:
		pos = Vector2(rng.randf_range(88, 632), rng.randf_range(220, 920))
		guard += 1
	return pos
