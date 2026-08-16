extends "res://scripts/main_v26.gd"

# ONE MORE FLOOR v1.14 — Endless Ascension.
# The tower no longer has a practical end after Floor 50. Every five floors add
# an Ascension tier with multiplicative enemy pressure, while deep checkpoint
# deaths push the player several floors backwards. Permanent upgrades and run
# upgrades therefore keep mattering instead of eventually trivialising the game.

const V27_VERSION := "1.14-endless-ascension"

var v27_last_setback := 0
var v27_resume_floor := 1
var v27_checkpoint_catchup_picks := 0

func start_run() -> void:
	v27_last_setback = 0
	v27_checkpoint_catchup_picks = 0
	super.start_run()
	_v27_apply_deep_checkpoint_catchup()
	v27_resume_floor = int(run.floor_no)
	if int(run.floor_no) >= 50:
		loot_notice = "ASCENSION %d — FLOOR %d" % [_v27_ascension_tier(), int(run.floor_no)]
		loot_notice_color = C_PURPLE
		loot_notice_time = 2.4

func spawn_floor() -> void:
	super.spawn_floor()
	if run == null or int(run.floor_no) <= 50:
		return
	_v27_add_reinforcements()
	# Reinforcements are created after v1.13's modifier/affix pass, so run those
	# idempotent passes once more before applying the endless stat multiplier.
	_v25_apply_modifier_to_spawned_enemies()
	_v25_apply_elite_affixes()
	_v27_scale_floor_enemies()

func _v27_ascension_tier() -> int:
	if run == null:
		return 0
	return maxi(0, int(ceil(float(int(run.floor_no) - 50) / 5.0)))

func _v27_depth() -> int:
	return maxi(0, int(run.floor_no) - 50) if run != null else 0

func _v27_enemy_hp_mult() -> float:
	var tier := _v27_ascension_tier()
	var depth := _v27_depth()
	return pow(1.10, float(tier)) * (1.0 + float(depth) * 0.015)

func _v27_enemy_damage_mult() -> float:
	var tier := _v27_ascension_tier()
	var depth := _v27_depth()
	return pow(1.055, float(tier)) * (1.0 + float(depth) * 0.003)

func _v27_enemy_speed_mult() -> float:
	return minf(1.65, 1.0 + float(_v27_ascension_tier()) * 0.015)

func _v27_reward_mult() -> float:
	return pow(1.045, float(_v27_ascension_tier()))

func _v27_scale_floor_enemies() -> void:
	var hp_mult := _v27_enemy_hp_mult()
	var damage_mult := _v27_enemy_damage_mult()
	var speed_mult := _v27_enemy_speed_mult()
	var reward_mult := _v27_reward_mult()
	var tier := _v27_ascension_tier()
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		if bool(e.get("v27_ascended", false)):
			continue
		var boss_pressure := 1.0
		if String(e.get("type", "")) == "warden":
			boss_pressure += float(tier) * 0.020
		elif bool(e.get("miniboss", false)):
			boss_pressure += float(tier) * 0.012
		e["max_hp"] = float(e.get("max_hp", e.get("hp", 1.0))) * hp_mult * boss_pressure
		e["hp"] = float(e["max_hp"])
		e["touch_damage"] = float(e.get("touch_damage", 1.0)) * damage_mult
		e["speed"] = float(e.get("speed", 1.0)) * speed_mult
		e["reward"] = maxi(1, int(round(float(e.get("reward", 1)) * reward_mult)))
		e["v27_ascended"] = true
		enemies[i] = e

func _v27_add_reinforcements() -> void:
	var room_type := String(current_room.get("type", "COMBAT"))
	if room_type in ["BOSS", "TREASURE", "MINIBOSS"]:
		return
	var floor_no := int(run.floor_no)
	if floor_no < 55:
		return
	var extra_count := mini(4, 1 + int((floor_no - 55) / 25))
	if room_type == "AMBUSH":
		extra_count = mini(5, extra_count + 1)
	var pool: Array[String] = room_system.enemy_pool(String(current_room.get("area", "STARLESS SPIRE")), floor_no)
	if pool.is_empty():
		return
	for _n in range(extra_count):
		var kind := String(pool[rng.randi_range(0, pool.size() - 1)])
		enemies.append(EnemyFactory.make_enemy(kind, floor_no, rng, player_pos))

func update_enemy_shots(delta: float) -> void:
	if run != null and int(run.floor_no) > 50:
		var mult := _v27_enemy_damage_mult()
		for i in range(enemy_shots.size()):
			var shot: Dictionary = enemy_shots[i]
			if bool(shot.get("v27_ascended", false)):
				continue
			shot["damage"] = float(shot.get("damage", 1.0)) * mult
			shot["v27_ascended"] = true
			enemy_shots[i] = shot
	super.update_enemy_shots(delta)

func _v27_apply_deep_checkpoint_catchup() -> void:
	# Checkpoint runs already receive the normal Floor-50 bootstrap from
	# RunProfile. Very deep restarts get additional deterministic catch-up picks,
	# deliberately weaker than the upgrades a player would have collected by
	# actually climbing every floor.
	if run == null or int(run.floor_no) <= 80:
		return
	var floor_no := int(run.floor_no)
	var extra_picks := mini(40, int((floor_no - 80) / 4))
	if extra_picks <= 0:
		return
	var order: Array[String] = [
		"power", "vitality", "haste", "armor", "crit",
		"nova", "range", "lifesteal", "speed", "multi"
	]
	var strength := minf(1.60, 1.0 + float(floor_no - 80) * 0.004)
	for i in range(extra_picks):
		run.apply_upgrade_scaled(order[i % order.size()], strength)
	v27_checkpoint_catchup_picks = extra_picks
	run.hp = run.max_hp
	run.last_synergy_unlocked = ""

func die() -> void:
	var death_floor := int(run.floor_no) if run != null else 1
	v27_last_setback = 0
	if meta != null and meta.has_method("apply_death_setback"):
		v27_last_setback = int(meta.apply_death_setback(death_floor))
		v27_resume_floor = int(meta.run_start_floor())
	super.die()

func draw_game() -> void:
	super.draw_game()
	if run == null or int(run.floor_no) <= 50:
		return
	var badge := Rect2(278, 270, 164, 42)
	panel(badge, Color(0.03, 0.04, 0.09, 0.94), C_PURPLE)
	draw_string(font, Vector2(286, 297), "ASCENSION %d" % _v27_ascension_tier(), HORIZONTAL_ALIGNMENT_CENTER, 148, 13, C_PURPLE)

func draw_decision() -> void:
	super.draw_decision()
	if run == null or meta == null or int(run.floor_no) < 50:
		return
	var setback := int(meta.death_setback_amount(int(run.floor_no))) if meta.has_method("death_setback_amount") else 0
	if setback > 0:
		draw_string(font, Vector2(90, 1090), "DEATH SETBACK  -%d FLOORS" % setback, HORIZONTAL_ALIGNMENT_CENTER, 540, 15, C_RED)
		draw_string(font, Vector2(90, 1118), "Cash out protects your current checkpoint." , HORIZONTAL_ALIGNMENT_CENTER, 540, 13, C_MUTED)

func draw_game_over() -> void:
	super.draw_game_over()
	if v27_last_setback <= 0:
		return
	draw_string(v16_title_font, Vector2(90, 1036), "TOWER SETBACK  -%d" % v27_last_setback, HORIZONTAL_ALIGNMENT_CENTER, 540, 20, C_RED)
	draw_string(font, Vector2(90, 1062), "Checkpoint pushed back to Floor %d" % v27_resume_floor, HORIZONTAL_ALIGNMENT_CENTER, 540, 14, C_TEXT)
