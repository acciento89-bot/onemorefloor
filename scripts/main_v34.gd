extends "res://scripts/main_v31.gd"

const MissionSystemV2 = preload("res://scripts/mission_system_v2.gd")
const TowerPassV2 = preload("res://scripts/tower_pass_v2.gd")
const MonetizationService = preload("res://scripts/monetization_service.gd")
const EconomyBalanceV2 = preload("res://scripts/economy_balance_v2.gd")
const V34_VERSION := "1.21-liveops-economy"

const STORE_HOME := Rect2(538, 116, 164, 42)
const STORE_BACK := Rect2(36, 1160, 170, 62)
const STORE_REWARDED := Rect2(90, 930, 540, 74)
const STORE_ROWS := [
	Rect2(58, 276, 604, 104), Rect2(58, 396, 604, 104),
	Rect2(58, 516, 604, 104), Rect2(58, 636, 604, 104),
	Rect2(58, 756, 604, 104),
]
const DAILY_ROWS := [Rect2(48,260,624,86), Rect2(48,358,624,86), Rect2(48,456,624,86)]
const WEEKLY_ROWS := [Rect2(48,684,624,86), Rect2(48,782,624,86), Rect2(48,880,624,86)]
const DAILY_CHEST := Rect2(132,558,456,60)
const WEEKLY_CHEST := Rect2(132,982,456,60)
const PASS_FREE := Rect2(64,1036,276,72)
const PASS_PREMIUM := Rect2(380,1036,276,72)

var monetization
var economy
var pressure: Dictionary = {"active":false,"hp":1.0,"damage":1.0,"reward":1.0,"label":"ON CURVE","ratio":1.0}
var store_notice := ""
var store_notice_time := 0.0

func _ready() -> void:
	super._ready()
	missions = MissionSystemV2.new()
	missions.load_data()
	missions.set_progress_context(int(meta.best_floor))
	tower_pass = TowerPassV2.new()
	tower_pass.load_data()
	monetization = MonetizationService.new()
	monetization.load_data()
	economy = EconomyBalanceV2.new()
	queue_redraw()

func _process(delta: float) -> void:
	super._process(delta)
	store_notice_time = maxf(0.0, store_notice_time - delta)

# -----------------------------------------------------------------------------
# v1.21 adaptive difficulty/economy
# -----------------------------------------------------------------------------

func spawn_floor() -> void:
	super.spawn_floor()
	_apply_pressure()

func _apply_pressure() -> void:
	pressure = {"active":false,"hp":1.0,"damage":1.0,"reward":1.0,"label":"ON CURVE","ratio":1.0}
	if run == null or meta == null or economy == null:
		return
	pressure = economy.adaptive_pressure(int(meta.power_score()), int(run.floor_no))
	if not bool(pressure.get("active", false)):
		return
	var hp_mult: float = float(pressure.get("hp", 1.0))
	var dmg_mult: float = float(pressure.get("damage", 1.0))
	var reward_mult: float = float(pressure.get("reward", 1.0))
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		if bool(e.get("v34_pressure", false)):
			continue
		e["max_hp"] = float(e.get("max_hp", e.get("hp", 1.0))) * hp_mult
		e["hp"] = float(e["max_hp"])
		e["touch_damage"] = float(e.get("touch_damage", 1.0)) * dmg_mult
		e["reward"] = maxi(1, int(round(float(e.get("reward", 1)) * reward_mult)))
		e["v34_pressure"] = true
		enemies[i] = e

func update_enemy_shots(delta: float) -> void:
	if bool(pressure.get("active", false)):
		var mult: float = float(pressure.get("damage", 1.0))
		for i in range(enemy_shots.size()):
			var shot: Dictionary = enemy_shots[i]
			if not bool(shot.get("v34_pressure", false)):
				shot["damage"] = float(shot.get("damage", 1.0)) * mult
				shot["v34_pressure"] = true
				enemy_shots[i] = shot
	super.update_enemy_shots(delta)

func _v31_resolve_floor_contract() -> String:
	var result: String = super._v31_resolve_floor_contract()
	if result.contains("COMPLETE"):
		missions.record("contracts", 1)
	return result

func _v31_enhance_selected() -> void:
	var idx: int = _v31_selected_vault_index()
	var before: int = int(loot.inventory[idx].get("enhance_level", 0)) if idx >= 0 and idx < loot.inventory.size() else -1
	super._v31_enhance_selected()
	if idx >= 0 and idx < loot.inventory.size() and int(loot.inventory[idx].get("enhance_level", 0)) > before:
		missions.record("enhance", 1)

func _v31_enchant_selected() -> void:
	var idx: int = _v31_selected_vault_index()
	var before: int = int(loot.inventory[idx].get("enchant_count", 0)) if idx >= 0 and idx < loot.inventory.size() else -1
	super._v31_enchant_selected()
	if idx >= 0 and idx < loot.inventory.size() and int(loot.inventory[idx].get("enchant_count", 0)) > before:
		missions.record("enchant", 1)

func _v31_awaken_selected() -> void:
	var idx: int = _v31_selected_vault_index()
	var before: int = int(loot.inventory[idx].get("awaken_count", 0)) if idx >= 0 and idx < loot.inventory.size() else -1
	super._v31_awaken_selected()
	if idx >= 0 and idx < loot.inventory.size() and int(loot.inventory[idx].get("awaken_count", 0)) > before:
		missions.record("awaken", 1)

# -----------------------------------------------------------------------------
# v1.19 missions
# -----------------------------------------------------------------------------

func claim_mission(index: int) -> void:
	var weekly: bool = index >= 3
	var list: Array = missions.all_weekly() if weekly else missions.all_daily()
	var local_index: int = index - 3 if weekly else index
	if local_index < 0 or local_index >= list.size():
		return
	var reward: Dictionary = missions.claim(list[local_index], weekly)
	if reward.is_empty():
		return
	var mult: float = float(economy.mission_coin_multiplier(int(meta.best_floor)))
	var coins: int = int(round(float(reward.get("coins", 0)) * mult))
	meta.coins += coins
	tower_pass.add_xp(int(reward.get("xp", 0)))
	meta.save_data()
	loot_notice = "+%d COINS  +%d PASS XP" % [coins, int(reward.get("xp", 0))]
	loot_notice_color = C_GREEN
	loot_notice_time = 1.8
	_audio("claim")

func _claim_completion(weekly: bool) -> void:
	var reward: Dictionary = missions.claim_completion_bonus(weekly)
	if reward.is_empty():
		loot_notice = "CLAIM ALL %s MISSIONS FIRST" % ("WEEKLY" if weekly else "DAILY")
		loot_notice_color = C_MUTED
		loot_notice_time = 1.5
		return
	var mult: float = float(economy.mission_coin_multiplier(int(meta.best_floor)))
	var coins: int = int(round(float(reward.get("coins", 0)) * mult))
	var shards: int = int(reward.get("shards", 0))
	meta.coins += coins
	loot.shards += shards
	tower_pass.add_xp(int(reward.get("xp", 0)))
	meta.save_data()
	loot.save_data()
	loot_notice = "%s CHEST  +%d COINS  +%d SHARDS" % ["WEEKLY" if weekly else "DAILY", coins, shards]
	loot_notice_color = C_GOLD
	loot_notice_time = 2.2
	_audio("claim")

func draw_missions_screen() -> void:
	_v16_header("MISSIONS", "Rotating daily and weekly contracts", V16_GREEN, 0, "arcane")
	draw_string(v16_title_font, Vector2(52,238), "DAILY", HORIZONTAL_ALIGNMENT_LEFT, 220, 18, V16_GREEN)
	var daily: Array = missions.all_daily()
	for i in range(mini(3, daily.size())):
		_draw_mission_v34(daily[i], DAILY_ROWS[i], false)
	_draw_completion_v34(DAILY_CHEST, false)
	draw_string(v16_title_font, Vector2(52,662), "WEEKLY", HORIZONTAL_ALIGNMENT_LEFT, 220, 18, V16_PURPLE_HI)
	var weekly: Array = missions.all_weekly()
	for i in range(mini(3, weekly.size())):
		_draw_mission_v34(weekly[i], WEEKLY_ROWS[i], true)
	_draw_completion_v34(WEEKLY_CHEST, true)
	_v16_button(OVERLAY_BACK, "‹  BACK", V16_PURPLE, 17)
	_draw_notice(1092)

func _draw_mission_v34(m: Dictionary, r: Rect2, weekly: bool) -> void:
	var complete: bool = bool(missions.is_complete(m, weekly))
	var claimed: bool = bool(missions.is_claimed(m, weekly))
	var accent: Color = V16_PURPLE if weekly else V16_GREEN
	if complete and not claimed: accent = V16_GOLD
	if claimed: accent = Color("526078")
	_v16_frame(r, accent, Color("060a14"), 0.13)
	draw_string(v16_body_font, r.position + Vector2(18,29), String(m.get("title","MISSION")), HORIZONTAL_ALIGNMENT_LEFT, 360, 17, V17_IVORY)
	var p: int = int(missions.progress(m, weekly))
	draw_string(v16_body_font, r.position + Vector2(18,57), "%d/%d  •  %d COINS  •  %d XP" % [p, int(m.get("goal",1)), int(m.get("coins",0)), int(m.get("xp",0))], HORIZONTAL_ALIGNMENT_LEFT, 430, 12, V16_MUTED)
	var status: String = "CLAIMED" if claimed else ("CLAIM" if complete else "IN PROGRESS")
	draw_string(v16_title_font, r.position + Vector2(446,48), status, HORIZONTAL_ALIGNMENT_CENTER, 150, 13, C_GREEN if complete and not claimed else V16_MUTED)

func _draw_completion_v34(r: Rect2, weekly: bool) -> void:
	var ready: bool = bool(missions.completion_bonus_claimable(weekly))
	var claimed: bool = bool(missions.weekly_bonus_claimed if weekly else missions.daily_bonus_claimed)
	_v16_frame(r, V16_GOLD if ready else V16_PURPLE, Color("070912"), 0.12)
	draw_string(v16_title_font, r.position + Vector2(12,36), ("WEEKLY" if weekly else "DAILY") + " COMPLETION CHEST", HORIZONTAL_ALIGNMENT_LEFT, 310, 14, V17_IVORY)
	draw_string(v16_body_font, r.position + Vector2(320,35), "CLAIM" if ready else ("CLAIMED" if claimed else "LOCKED"), HORIZONTAL_ALIGNMENT_RIGHT, 116, 12, C_GOLD if ready else V16_MUTED)

# -----------------------------------------------------------------------------
# v1.19 tower pass
# -----------------------------------------------------------------------------

func claim_pass_reward() -> void:
	_claim_pass_v34(false)

func _claim_pass_v34(premium: bool) -> void:
	var unlocked: bool = bool(monetization.premium_pass_unlocked())
	if premium and not unlocked:
		home_overlay = "store"
		return
	var level_no: int = int(tower_pass.next_claimable(premium, unlocked))
	if level_no < 0:
		loot_notice = "NO PASS REWARD READY"
		loot_notice_color = C_MUTED
		loot_notice_time = 1.4
		return
	var reward: Dictionary = tower_pass.claim(level_no, premium, unlocked)
	var mult: float = float(economy.pass_coin_multiplier(int(meta.best_floor)))
	var coins: int = int(round(float(reward.get("coins",0)) * mult))
	var shards: int = int(reward.get("shards",0))
	meta.coins += coins
	loot.shards += shards
	meta.save_data()
	loot.save_data()
	loot_notice = "%s PASS LV %d  +%d COINS  +%d SHARDS" % ["PREMIUM" if premium else "FREE", level_no, coins, shards]
	loot_notice_color = C_GOLD if premium else C_GREEN
	loot_notice_time = 2.0
	_audio("claim")

func draw_pass_screen() -> void:
	_v16_header("TOWER PASS", "Season %s • 50 levels" % String(tower_pass.season_key), V16_PURPLE, 6, "arcane")
	var lvl: int = int(tower_pass.level())
	var p: Dictionary = tower_pass.progress_to_next()
	_v16_frame(Rect2(62,220,596,132), V16_PURPLE, Color("070912"), 0.16)
	draw_string(v16_title_font, Vector2(78,264), "LEVEL %d / 50" % lvl, HORIZONTAL_ALIGNMENT_CENTER, 564, 26, V17_IVORY)
	draw_rect(Rect2(118,296,484,18), Color("231b38"))
	draw_rect(Rect2(118,296,484 * float(p.get("ratio",0.0)),18), V16_PURPLE)
	draw_string(v16_body_font, Vector2(118,336), "%d / %d XP" % [int(p.get("current",0)), int(p.get("needed",1))], HORIZONTAL_ALIGNMENT_CENTER, 484, 12, V16_MUTED)
	var start: int = clampi(maxi(1,lvl-1), 1, 46)
	for row in range(5):
		_draw_pass_row_v34(Rect2(48,380 + row*112,624,96), start + row)
	var unlocked: bool = bool(monetization.premium_pass_unlocked())
	var free_count: int = int(tower_pass.unclaimed_count(false, unlocked))
	var prem_count: int = int(tower_pass.unclaimed_count(true, unlocked)) if unlocked else 0
	_v16_button(PASS_FREE, "CLAIM FREE  %d" % free_count, V16_GREEN, 16, -1, free_count > 0)
	_v16_button(PASS_PREMIUM, "CLAIM PREMIUM  %d" % prem_count if unlocked else "UNLOCK PREMIUM", V16_GOLD, 15)
	_v16_button(OVERLAY_BACK, "‹  BACK", V16_PURPLE, 17)
	_draw_notice(1120)

func _draw_pass_row_v34(r: Rect2, level_no: int) -> void:
	var free_r: Dictionary = tower_pass.reward_for(level_no, false)
	var prem_r: Dictionary = tower_pass.reward_for(level_no, true)
	var reached: bool = level_no <= int(tower_pass.level())
	_v16_frame(r, V16_GOLD if reached else Color("4d4566"), Color("060a13"), 0.10)
	draw_string(v16_title_font, r.position + Vector2(16,40), "LV %02d" % level_no, HORIZONTAL_ALIGNMENT_LEFT, 84, 18, V17_IVORY)
	draw_string(v16_body_font, r.position + Vector2(104,32), "FREE  %d C • %d S" % [int(free_r.get("coins",0)), int(free_r.get("shards",0))], HORIZONTAL_ALIGNMENT_LEFT, 460, 12, V16_GREEN if reached else V16_MUTED)
	draw_string(v16_body_font, r.position + Vector2(104,62), "PREMIUM  %d C • %d S" % [int(prem_r.get("coins",0)), int(prem_r.get("shards",0))], HORIZONTAL_ALIGNMENT_LEFT, 460, 12, V16_GOLD if reached else V16_MUTED)

# -----------------------------------------------------------------------------
# v1.20 store foundation
# -----------------------------------------------------------------------------

func _apply_store_result(result: Dictionary) -> void:
	var status: String = String(result.get("status",""))
	if status == "granted":
		var coins: int = int(result.get("coins",0))
		var shards: int = int(result.get("shards",0))
		meta.coins += coins
		loot.shards += shards
		meta.save_data()
		loot.save_data()
		store_notice = "GRANTED  +%d COINS  +%d SHARDS" % [coins, shards]
		_audio("claim")
	elif status == "owned": store_notice = "ALREADY OWNED"
	elif status == "cooldown": store_notice = "REWARDED COOLDOWN %ds" % int(result.get("remaining",0))
	elif status == "provider_required": store_notice = "NATIVE STORE / AD PROVIDER NOT CONNECTED YET"
	else: store_notice = "STORE REQUEST FAILED"
	store_notice_time = 2.8

func draw_store_screen() -> void:
	_v16_header("STORE", "Optional convenience • fully playable free", V16_GOLD, 11, "arcane")
	var mode: String = "DEBUG PURCHASE SIMULATION" if monetization.is_debug_simulation() else "NATIVE PROVIDER REQUIRED BEFORE RELEASE"
	draw_string(v16_body_font, Vector2(60,238), mode, HORIZONTAL_ALIGNMENT_CENTER, 600, 13, V16_MUTED)
	var catalog: Array = monetization.product_catalog()
	for i in range(mini(STORE_ROWS.size(), catalog.size())):
		var product: Dictionary = catalog[i]
		var r: Rect2 = STORE_ROWS[i]
		_v16_frame(r, V16_GOLD if i < 2 else V16_PURPLE, Color("070a12"), 0.12)
		draw_string(v16_title_font, r.position + Vector2(20,40), String(product.get("title","PRODUCT")), HORIZONTAL_ALIGNMENT_LEFT, 360, 17, V17_IVORY)
		draw_string(v16_body_font, r.position + Vector2(20,70), String(product.get("subtitle","")), HORIZONTAL_ALIGNMENT_LEFT, 420, 12, V16_MUTED)
		draw_string(v16_title_font, r.position + Vector2(450,57), "DEV TEST" if monetization.is_debug_simulation() else "BUY", HORIZONTAL_ALIGNMENT_CENTER, 132, 13, V16_GOLD)
	_v16_button(STORE_REWARDED, "REWARDED TEST • %d LEFT" % int(monetization.rewarded_remaining_today()), V16_GREEN, 16, -1, monetization.can_request_rewarded())
	if store_notice_time > 0.0:
		draw_string(v16_body_font, Vector2(62,1060), store_notice, HORIZONTAL_ALIGNMENT_CENTER, 596, 13, C_GOLD)
	_v16_button(STORE_BACK, "‹  BACK", V16_PURPLE, 17)

# -----------------------------------------------------------------------------
# input + overlays
# -----------------------------------------------------------------------------

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if not pressed:
		super.pointer(pos, pressed, id)
		return
	if state == State.HOME and home_overlay == "store":
		if STORE_BACK.has_point(pos): home_overlay = ""; _audio("menu"); return
		var catalog: Array = monetization.product_catalog()
		for i in range(STORE_ROWS.size()):
			if STORE_ROWS[i].has_point(pos) and i < catalog.size():
				_apply_store_result(monetization.request_purchase(String(catalog[i].get("id",""))))
				return
		if STORE_REWARDED.has_point(pos): _apply_store_result(monetization.complete_rewarded_debug()); return
		return
	if state == State.HOME and home_overlay == "missions":
		if OVERLAY_BACK.has_point(pos): home_overlay = ""; _audio("menu"); return
		for i in range(3):
			if DAILY_ROWS[i].has_point(pos): claim_mission(i); return
			if WEEKLY_ROWS[i].has_point(pos): claim_mission(i+3); return
		if DAILY_CHEST.has_point(pos): _claim_completion(false); return
		if WEEKLY_CHEST.has_point(pos): _claim_completion(true); return
		return
	if state == State.HOME and home_overlay == "pass":
		if OVERLAY_BACK.has_point(pos): home_overlay = ""; _audio("menu"); return
		if PASS_FREE.has_point(pos): _claim_pass_v34(false); return
		if PASS_PREMIUM.has_point(pos): _claim_pass_v34(true); return
		return
	if state == State.HOME and home_overlay == "" and not settings_open and STORE_HOME.has_point(pos):
		home_overlay = "store"
		_audio("menu")
		return
	super.pointer(pos, pressed, id)

func draw_home() -> void:
	if home_overlay == "store": draw_store_screen(); return
	if home_overlay in ["missions","pass"]: super.draw_home(); return
	super.draw_home()
	if not settings_open: _v16_button(STORE_HOME, "STORE", V16_GOLD, 12, 11)

func draw_game() -> void:
	super.draw_game()
	if run == null or int(run.floor_no) <= 50:
		return
	draw_rect(Rect2(38,250,644,110), Color(0.018,0.025,0.055,0.97))
	_v16_frame(Rect2(54,266,612,58), V16_PURPLE, Color("050813"), 0.10)
	var modifier: String = run_modifier if run_modifier != "NONE" else "STANDARD"
	var asc: String = "ASCENSION %d" % _v27_ascension_tier()
	var area: String = String(current_room.get("area","TOWER"))
	var right: String = _v31_contract_label() if v31_challenge_active else String(pressure.get("label","ON CURVE"))
	draw_string(v16_body_font, Vector2(66,301), modifier, HORIZONTAL_ALIGNMENT_CENTER, 138, 11, V16_PURPLE_HI)
	draw_string(v16_body_font, Vector2(210,301), asc, HORIZONTAL_ALIGNMENT_CENTER, 138, 11, V16_GOLD)
	draw_string(v16_body_font, Vector2(354,301), area, HORIZONTAL_ALIGNMENT_CENTER, 156, 11, V17_IVORY)
	draw_string(v16_body_font, Vector2(516,301), right, HORIZONTAL_ALIGNMENT_CENTER, 138, 10, C_CYAN if v31_challenge_active else V16_MUTED)
