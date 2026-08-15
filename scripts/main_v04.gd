extends "res://scripts/main_v03.gd"

const LootSystem = preload("res://scripts/loot_system.gd")
const MissionSystem = preload("res://scripts/mission_system.gd")
const TowerPass = preload("res://scripts/tower_pass.gd")
const AudioFeedback = preload("res://scripts/audio_feedback.gd")

const MISSIONS_BTN := Rect2(52, 930, 282, 70)
const PASS_BTN := Rect2(386, 930, 282, 70)
const OVERLAY_BACK := Rect2(36, 1160, 170, 62)
const PASS_CLAIM := Rect2(394, 1050, 270, 82)

var loot
var missions
var tower_pass
var audio
var home_overlay := ""
var loot_notice := ""
var loot_notice_color := C_GOLD
var loot_notice_time := 0.0
var boss_intro := 0.0

func _ready() -> void:
	super._ready()
	loot = LootSystem.new()
	missions = MissionSystem.new()
	tower_pass = TowerPass.new()
	loot.load_data()
	missions.load_data()
	tower_pass.load_data()
	audio = AudioFeedback.new()
	add_child(audio)

func _process(delta: float) -> void:
	super._process(delta)
	loot_notice_time = maxf(0.0, loot_notice_time - delta)
	boss_intro = maxf(0.0, boss_intro - delta)

func start_run() -> void:
	super.start_run()
	var bonuses: Dictionary = loot.equipped_bonuses()
	run.damage *= 1.0 + float(bonuses["damage_pct"])
	run.max_hp += float(bonuses["hp"])
	run.hp = run.max_hp
	run.crit_chance = minf(0.65, run.crit_chance + float(bonuses["crit_pct"]))
	home_overlay = ""
	_audio("menu")

func spawn_floor() -> void:
	super.spawn_floor()
	if run.floor_no % 5 == 0:
		boss_intro = 1.35
		_audio("warden")

func update_warden(e: Dictionary, p: Vector2, to_player: Vector2, dist: float, delta: float) -> void:
	var was_phase2: bool = bool(e["phase2"])
	super.update_warden(e, p, to_player, dist, delta)
	if not was_phase2 and bool(e["phase2"]):
		_audio("phase2")

func fire_auto_attack() -> void:
	var before: int = player_shots.size()
	super.fire_auto_attack()
	if player_shots.size() > before:
		var crit_found: bool = false
		for i in range(before, player_shots.size()):
			if bool(player_shots[i]["crit"]):
				crit_found = true
				break
		_audio("crit" if crit_found else "attack")

func apply_damage_to_enemy(index: int, amount: float, crit: bool, hit_pos: Vector2) -> void:
	super.apply_damage_to_enemy(index, amount, crit, hit_pos)
	if not crit:
		_audio("hit")

func use_skill() -> void:
	var ready: bool = state == State.RUNNING and float(run.skill_cd) <= 0.0
	super.use_skill()
	if ready:
		_audio("nova")

func roll_upgrade_options() -> void:
	missions.record("floors", 1)
	tower_pass.add_xp(12 + mini(28, int(run.floor_no) * 2))
	super.roll_upgrade_options()

func remove_dead() -> void:
	for i in range(enemies.size() - 1, -1, -1):
		if float(enemies[i]["hp"]) > 0.0:
			continue
		var e: Dictionary = enemies[i]
		var kind: String = String(e["type"])
		var bonuses: Dictionary = loot.equipped_bonuses()
		var reward: int = int(round(float(e["reward"]) * meta.coin_multiplier() * (1.0 + float(bonuses["coin_pct"]))))
		coin_orbs.append({"pos":e["pos"],"value":reward,"age":0.0})
		effects.append({"type":"burst","pos":e["pos"],"age":0.0,"dur":0.30,"color":enemy_color(kind),"kind":""})
		missions.record("kills", 1)
		if kind == "warden":
			missions.record("wardens", 1)
			tower_pass.add_xp(70)
			screen_shake = 12.0
			haptic(80)
		var item: Dictionary = loot.roll_drop(kind, run.floor_no, rng)
		if not item.is_empty():
			loot_notice = "%s %s — %s" % [String(item["rarity"]), String(item["name"]), loot.stat_line(item)]
			loot_notice_color = rarity_color(String(item["rarity"]))
			loot_notice_time = 2.4
			_audio("loot")
		enemies.remove_at(i)

func cash_out() -> void:
	var secured: int = int(run.run_coins)
	if secured > 0:
		missions.record("cash", secured)
		tower_pass.add_xp(mini(120, maxi(5, int(secured / 6))))
	super.cash_out()

func claim_mission(index: int) -> void:
	var weekly: bool = index >= 3
	var list: Array = missions.all_weekly() if weekly else missions.all_daily()
	var local_index: int = index - 3 if weekly else index
	if local_index < 0 or local_index >= list.size():
		return
	var reward: Dictionary = missions.claim(list[local_index], weekly)
	if reward.is_empty():
		return
	meta.coins += int(reward["coins"])
	tower_pass.add_xp(int(reward["xp"]))
	meta.save_data()
	loot_notice = "+%d COINS  +%d PASS XP" % [int(reward["coins"]), int(reward["xp"])]
	loot_notice_color = C_GREEN
	loot_notice_time = 1.8
	_audio("claim")

func claim_pass_reward() -> void:
	var level_no: int = int(tower_pass.next_claimable())
	if level_no < 0:
		return
	var reward: Dictionary = tower_pass.claim(level_no)
	if reward.is_empty():
		return
	meta.coins += int(reward["coins"])
	meta.save_data()
	loot_notice = "PASS LEVEL %d — +%d COINS" % [level_no, int(reward["coins"])]
	loot_notice_color = C_GOLD
	loot_notice_time = 1.8
	_audio("claim")

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if not pressed:
		super.pointer(pos, pressed, id)
		return
	if state == State.HOME and home_overlay != "":
		if OVERLAY_BACK.has_point(pos):
			home_overlay = ""
			_audio("menu")
			return
		if home_overlay == "missions":
			for i in range(6):
				if mission_rect(i).has_point(pos):
					claim_mission(i)
					return
		elif home_overlay == "pass" and PASS_CLAIM.has_point(pos):
			claim_pass_reward()
			return
		return
	if state == State.HOME:
		if MISSIONS_BTN.has_point(pos):
			home_overlay = "missions"
			_audio("menu")
			return
		if PASS_BTN.has_point(pos):
			home_overlay = "pass"
			_audio("menu")
			return
	if state == State.VAULT:
		for i in range(mini(6, loot.inventory.size())):
			if vault_item_rect(i).has_point(pos):
				if loot.equip_index(i):
					loot_notice = "EQUIPPED %s" % String(loot.inventory[i]["name"])
					loot_notice_color = C_GREEN
					loot_notice_time = 1.5
					_audio("menu")
				return
	super.pointer(pos, pressed, id)

func draw_home() -> void:
	if home_overlay == "missions":
		draw_missions_screen()
		return
	if home_overlay == "pass":
		draw_pass_screen()
		return
	super.draw_home()
	button(MISSIONS_BTN, "MISSIONS", C_GREEN, 19)
	button(PASS_BTN, "TOWER PASS", C_PURPLE, 19)
	draw_rect(Rect2(400, 1180, 260, 28), C_PANEL_2)
	text("v0.4 LOOT + MISSIONS", Vector2(425, 1201), 13, C_TEXT)
	_draw_notice(1118)

func draw_vault_screen() -> void:
	draw_meta_header("VAULT", "Loot, equipment and permanent bonuses", C_GOLD)
	var bonuses: Dictionary = loot.equipped_bonuses()
	panel(Rect2(48, 210, 624, 72), C_PANEL_2, C_GOLD)
	text("EQUIPPED", Vector2(66, 240), 15, C_MUTED)
	text("DMG +%.1f%%   HP +%d   CRIT +%.1f%%   COINS +%.1f%%" % [float(bonuses["damage_pct"])*100.0, int(round(float(bonuses["hp"]))), float(bonuses["crit_pct"])*100.0, float(bonuses["coin_pct"])*100.0], Vector2(66, 268), 15, C_TEXT)
	if loot.inventory.is_empty():
		draw_center("THE VAULT IS EMPTY", 510, 28, C_TEXT)
		draw_center("Enemies can drop gear. Wardens always drop one item.", 558, 16, C_MUTED)
		draw_center("Tap an item here later to equip it.", 600, 16, C_GOLD)
	else:
		for i in range(mini(6, loot.inventory.size())):
			var item: Dictionary = loot.inventory[i]
			var r: Rect2 = vault_item_rect(i)
			var accent: Color = rarity_color(String(item["rarity"]))
			panel(r, C_PANEL, accent)
			text(String(item["name"]), r.position + Vector2(20, 31), 20, C_TEXT)
			text("%s • %s • Lv.%d" % [String(item["rarity"]), String(item["slot"]).to_upper(), int(item["level"])], r.position + Vector2(20, 57), 13, accent)
			text(loot.stat_line(item), r.position + Vector2(20, 83), 15, C_MUTED)
			if loot.is_equipped(item):
				text("EQUIPPED", r.position + Vector2(465, 59), 15, C_GREEN)
			else:
				text("TAP TO EQUIP", r.position + Vector2(440, 59), 14, C_GOLD)
	_draw_notice(1095)

func draw_game() -> void:
	super.draw_game()
	var warden: Dictionary = {}
	for e in enemies:
		if String(e["type"]) == "warden":
			warden = e
			break
	if not warden.is_empty():
		var ratio: float = clampf(float(warden["hp"]) / float(warden["max_hp"]), 0.0, 1.0)
		panel(Rect2(118, 164, 484, 50), Color("151025"), C_PURPLE if not bool(warden["phase2"]) else C_RED)
		text("THE WARDEN", Vector2(138, 185), 15, C_TEXT)
		draw_rect(Rect2(260, 180, 318, 12), Color("381726"))
		draw_rect(Rect2(260, 180, 318 * ratio, 12), C_RED if bool(warden["phase2"]) else C_PURPLE)
	if boss_intro > 0.0:
		var alpha: float = clampf(boss_intro, 0.0, 1.0)
		draw_rect(Rect2(60, 500, 600, 145), Color(0.03, 0.02, 0.08, 0.84 * alpha))
		var c: Color = C_RED
		c.a = alpha
		draw_string(font, Vector2(80, 558), "THE WARDEN", HORIZONTAL_ALIGNMENT_CENTER, 560, 48, c)
		draw_string(font, Vector2(80, 605), "FLOOR %d BOSS" % run.floor_no, HORIZONTAL_ALIGNMENT_CENTER, 560, 18, C_TEXT)
	_draw_notice(950)

func draw_missions_screen() -> void:
	draw_meta_header("MISSIONS", "Daily and weekly tower contracts", C_GREEN)
	text("DAILY", Vector2(54, 232), 18, C_GREEN)
	var daily: Array = missions.all_daily()
	for i in range(daily.size()):
		draw_mission_row(daily[i], i, false)
	text("WEEKLY", Vector2(54, 615), 18, C_PURPLE)
	var weekly: Array = missions.all_weekly()
	for i in range(weekly.size()):
		draw_mission_row(weekly[i], i + 3, true)
	button(OVERLAY_BACK, "BACK", C_PURPLE, 20)
	_draw_notice(1085)

func draw_mission_row(mission: Dictionary, index: int, weekly: bool) -> void:
	var r: Rect2 = mission_rect(index)
	var complete: bool = bool(missions.is_complete(mission, weekly))
	var claimed: bool = bool(missions.is_claimed(mission, weekly))
	var accent: Color = C_PURPLE if weekly else C_GREEN
	if complete and not claimed:
		accent = C_GOLD
	if claimed:
		accent = Color("4e5871")
	panel(r, C_PANEL, accent)
	text(String(mission["title"]), r.position + Vector2(18, 31), 18, C_TEXT)
	var progress: int = int(missions.progress(mission, weekly))
	text("%d / %d" % [progress, int(mission["goal"])], r.position + Vector2(18, 59), 14, C_MUTED)
	text("%d coins  •  %d XP" % [int(mission["coins"]), int(mission["xp"])], r.position + Vector2(18, 84), 14, C_GOLD)
	var status: String = "CLAIMED" if claimed else ("TAP TO CLAIM" if complete else "IN PROGRESS")
	text(status, r.position + Vector2(435, 60), 14, C_GREEN if complete and not claimed else C_MUTED)

func draw_pass_screen() -> void:
	draw_meta_header("TOWER PASS", "Free progression — no purchase required", C_PURPLE)
	var level_no: int = int(tower_pass.level())
	var p: Dictionary = tower_pass.progress_to_next()
	panel(Rect2(74, 240, 572, 190), C_PANEL, C_PURPLE)
	draw_center("PASS LEVEL %d / %d" % [level_no, tower_pass.MAX_LEVEL], 300, 34, C_TEXT)
	draw_rect(Rect2(130, 340, 460, 22), Color("272642"))
	draw_rect(Rect2(130, 340, 460 * float(p["ratio"]), 22), C_PURPLE)
	draw_center("%d / %d XP TO NEXT LEVEL" % [int(p["current"]), int(p["needed"])], 397, 15, C_MUTED)
	text("RECENT REWARDS", Vector2(74, 485), 18, C_GOLD)
	var start_level: int = maxi(1, level_no - 2)
	for i in range(5):
		var l: int = start_level + i
		if l > tower_pass.MAX_LEVEL:
			break
		var reward: Dictionary = tower_pass.reward_for(l)
		var r: Rect2 = Rect2(74, 515 + i * 94, 572, 76)
		var unlocked: bool = l <= level_no
		var claimable: bool = bool(tower_pass.can_claim(l))
		panel(r, C_PANEL, C_GOLD if claimable else (C_PURPLE if unlocked else Color("3c4261")))
		text("LEVEL %d" % l, r.position + Vector2(18, 31), 17, C_TEXT)
		text("%s • %d" % [String(reward["label"]), int(reward["coins"])], r.position + Vector2(145, 31), 15, C_MUTED)
		text("CLAIM" if claimable else ("UNLOCKED" if unlocked else "LOCKED"), r.position + Vector2(455, 31), 14, C_GOLD if claimable else C_MUTED)
	var next_claim: int = int(tower_pass.next_claimable())
	button(PASS_CLAIM, "CLAIM LEVEL %d" % next_claim if next_claim > 0 else "NO REWARD READY", C_GOLD if next_claim > 0 else C_MUTED, 18)
	button(OVERLAY_BACK, "BACK", C_PURPLE, 20)
	_draw_notice(1018)

func mission_rect(index: int) -> Rect2:
	if index < 3:
		return Rect2(54, 250 + index * 112, 612, 98)
	return Rect2(54, 633 + (index - 3) * 112, 612, 98)

func vault_item_rect(index: int) -> Rect2:
	return Rect2(54, 305 + index * 120, 612, 104)

func rarity_color(rarity: String) -> Color:
	match rarity:
		"UNCOMMON": return C_GREEN
		"RARE": return C_BLUE
		"EPIC": return C_PURPLE
		"LEGENDARY": return C_GOLD
	return Color("9ca6b8")

func _draw_notice(y: float) -> void:
	if loot_notice_time <= 0.0:
		return
	panel(Rect2(70, y - 32, 580, 48), Color("0b1025"), loot_notice_color)
	draw_string(font, Vector2(86, y), loot_notice, HORIZONTAL_ALIGNMENT_CENTER, 548, 15, loot_notice_color)

func _audio(name: String) -> void:
	if audio != null:
		audio.event(name)
