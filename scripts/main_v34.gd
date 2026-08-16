extends "res://scripts/main_v31.gd"

# ONE MORE FLOOR cumulative v1.19-v1.21 pass.
# v1.19 Missions + Tower Pass 2.0
# v1.20 provider-safe monetization foundation
# v1.21 adaptive economy / difficulty tuning

const MissionSystemV2 = preload("res://scripts/mission_system_v2.gd")
const TowerPassV2 = preload("res://scripts/tower_pass_v2.gd")
const MonetizationService = preload("res://scripts/monetization_service.gd")
const EconomyBalanceV2 = preload("res://scripts/economy_balance_v2.gd")
const V34_VERSION := "1.21-liveops-economy"

const V34_STORE_HOME := Rect2(538, 116, 164, 42)
const V34_STORE_BACK := Rect2(36, 1160, 170, 62)
const V34_STORE_REWARDED := Rect2(90, 930, 540, 74)
const V34_STORE_RECTS := [
	Rect2(58, 276, 604, 104),
	Rect2(58, 396, 604, 104),
	Rect2(58, 516, 604, 104),
	Rect2(58, 636, 604, 104),
	Rect2(58, 756, 604, 104),
]

const V34_DAILY_RECTS := [
	Rect2(48, 260, 624, 86),
	Rect2(48, 358, 624, 86),
	Rect2(48, 456, 624, 86),
]
const V34_DAILY_CHEST := Rect2(132, 558, 456, 60)
const V34_WEEKLY_RECTS := [
	Rect2(48, 684, 624, 86),
	Rect2(48, 782, 624, 86),
	Rect2(48, 880, 624, 86),
]
const V34_WEEKLY_CHEST := Rect2(132, 982, 456, 60)

const V34_PASS_FREE := Rect2(64, 1036, 276, 72)
const V34_PASS_PREMIUM := Rect2(380, 1036, 276, 72)

var monetization
var economy
var v34_pressure: Dictionary = {"active":false, "hp":1.0, "damage":1.0, "reward":1.0, "label":"BALANCED", "ratio":1.0}
var v34_store_notice := ""
var v34_store_notice_time := 0.0

func _ready() -> void:
	super._ready()
	missions = MissionSystemV2.new()
	missions.load_data()
	if missions.has_method("set_progress_context"):
		missions.set_progress_context(int(meta.best_floor))
	tower_pass = TowerPassV2.new()
	tower_pass.load_data()
	monetization = MonetizationService.new()
	monetization.load_data()
	economy = EconomyBalanceV2.new()
	queue_redraw()

func _process(delta: float) -> void:
	super._process(delta)
	v34_store_notice_time = maxf(0.0, v34_store_notice_time - delta)

# -----------------------------------------------------------------------------
# v1.21 adaptive pressure — upgrades stay meaningful without making old realms
# permanently trivial once persistent Power is far ahead of the floor curve.
# -----------------------------------------------------------------------------

func spawn_floor() -> void:
	super.spawn_floor()
	_v34_apply_adaptive_pressure()

func _v34_apply_adaptive_pressure() -> void:
	v34_pressure = {"active":false, "hp":1.0, "damage":1.0, "reward":1.0, "label":"BALANCED", "ratio":1.0}
	if run == null or meta == null or economy == null:
		return
	v34_pressure = economy.adaptive_pressure(int(meta.power_score()), int(run.floor_no))
	var hp_mult := float(v34_pressure.get("hp", 1.0))
	var damage_mult := float(v34_pressure.get("damage", 1.0))
	var reward_mult := float(v34_pressure.get("reward", 1.0))
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		if bool(e.get("v34_pressure_applied", false)):
			continue
		if bool(v34_pressure.get("active", false)):
			e["max_hp"] = float(e.get("max_hp", e.get("hp", 1.0))) * hp_mult
			e["hp"] = float(e["max_hp"])
			e["touch_damage"] = float(e.get("touch_damage", 1.0)) * damage_mult
			e["reward"] = maxi(1, int(round(float(e.get("reward", 1)) * reward_mult)))
		e["v34_pressure_applied"] = true
		enemies[i] = e

func update_enemy_shots(delta: float) -> void:
	if bool(v34_pressure.get("active", false)):
		var damage_mult := float(v34_pressure.get("damage", 1.0))
		for i in range(enemy_shots.size()):
			var shot: Dictionary = enemy_shots[i]
			if bool(shot.get("v34_pressure_applied", false)):
				continue
			shot["damage"] = float(shot.get("damage", 1.0)) * damage_mult
			shot["v34_pressure_applied"] = true
			enemy_shots[i] = shot
	super.update_enemy_shots(delta)

# Contracts now also feed the rotating mission system.
func _v31_resolve_floor_contract() -> String:
	var result: String = super._v31_resolve_floor_contract()
	if result.contains("COMPLETE"):
		missions.record("contracts", 1)
	return result

# Loot 2.0 actions feed mission objectives without changing the inherited Vault.
func _v31_enhance_selected() -> void:
	var index: int = _v31_selected_vault_index()
	var before: int = -1
	if index >= 0 and index < loot.inventory.size():
		before = int(loot.inventory[index].get("enhance_level", 0))
	super._v31_enhance_selected()
	if index >= 0 and index < loot.inventory.size() and int(loot.inventory[index].get("enhance_level", 0)) > before:
		missions.record("enhance", 1)

func _v31_enchant_selected() -> void:
	var index: int = _v31_selected_vault_index()
	var before: int = -1
	if index >= 0 and index < loot.inventory.size():
		before = int(loot.inventory[index].get("enchant_count", 0))
	super._v31_enchant_selected()
	if index >= 0 and index < loot.inventory.size() and int(loot.inventory[index].get("enchant_count", 0)) > before:
		missions.record("enchant", 1)

func _v31_awaken_selected() -> void:
	var index: int = _v31_selected_vault_index()
	var before: int = -1
	if index >= 0 and index < loot.inventory.size():
		before = int(loot.inventory[index].get("awaken_count", 0))
	super._v31_awaken_selected()
	if index >= 0 and index < loot.inventory.size() and int(loot.inventory[index].get("awaken_count", 0)) > before:
		missions.record("awaken", 1)

# -----------------------------------------------------------------------------
# Missions 2.0
# -----------------------------------------------------------------------------

func claim_mission(index: int) -> void:
	var weekly := index >= 3
	var list: Array = missions.all_weekly() if weekly else missions.all_daily()
	var local_index := index - 3 if weekly else index
	if local_index < 0 or local_index >= list.size():
		return
	var reward: Dictionary = missions.claim(list[local_index], weekly)
	if reward.is_empty():
		return
	var coin_mult := economy.mission_coin_multiplier(int(meta.best_floor)) if economy != null else 1.0
	var coins := int(round(float(reward.get("coins", 0)) * coin_mult))
	meta.coins += coins
	tower_pass.add_xp(int(reward.get("xp", 0)))
	meta.save_data()
	loot_notice = "+%d COINS  +%d PASS XP" % [coins, int(reward.get("xp", 0))]
	loot_notice_color = C_GREEN
	loot_notice_time = 1.8
	_audio("claim")

func _v34_claim_mission_chest(weekly: bool) -> void:
	var reward: Dictionary = missions.claim_completion_bonus(weekly)
	if reward.is_empty():
		loot_notice = "COMPLETE AND CLAIM ALL %s MISSIONS FIRST" % ("WEEKLY" if weekly else "DAILY")
		loot_notice_color = C_MUTED
		loot_notice_time = 1.6
		return
	var coin_mult := economy.mission_coin_multiplier(int(meta.best_floor)) if economy != null else 1.0
	var coins := int(round(float(reward.get("coins", 0)) * coin_mult))
	var shards := int(reward.get("shards", 0))
	meta.coins += coins
	loot.shards += shards
	tower_pass.add_xp(int(reward.get("xp", 0)))
	meta.save_data()
	loot.save_data()
	loot_notice = "%s CHEST — +%d COINS • +%d SHARDS" % ["WEEKLY" if weekly else "DAILY", coins, shards]
	loot_notice_color = C_GOLD
	loot_notice_time = 2.4
	_audio("claim")

func draw_missions_screen() -> void:
	_v16_header("MISSIONS", "Rotating daily and weekly tower contracts", V16_GREEN, 0, "arcane")
	draw_string(v16_title_font, Vector2(52, 238), "DAILY", HORIZONTAL_ALIGNMENT_LEFT, 240, 18, V16_GREEN)
	var daily: Array = missions.all_daily()
	for i in range(mini(3, daily.size())):
		_v34_draw_mission_row(daily[i], V34_DAILY_RECTS[i], false)
	_v34_draw_completion_chest(V34_DAILY_CHEST, false)
	draw_string(v16_title_font, Vector2(52, 662), "WEEKLY", HORIZONTAL_ALIGNMENT_LEFT, 240, 18, V16_PURPLE_HI)
	var weekly: Array = missions.all_weekly()
	for i in range(mini(3, weekly.size())):
		_v34_draw_mission_row(weekly[i], V34_WEEKLY_RECTS[i], true)
	_v34_draw_completion_chest(V34_WEEKLY_CHEST, true)
	_v16_button(OVERLAY_BACK, "‹  BACK", V16_PURPLE, 17)
	_draw_notice(1092)

func _v34_draw_mission_row(mission: Dictionary, r: Rect2, weekly: bool) -> void:
	var complete := bool(missions.is_complete(mission, weekly))
	var claimed := bool(missions.is_claimed(mission, weekly))
	var accent: Color = V16_PURPLE if weekly else V16_GREEN
	if complete and not claimed:
		accent = V16_GOLD
	if claimed:
		accent = Color("526078")
	_v16_frame(r, accent, Color("060a14"), 0.13)
	draw_string(v16_body_font, r.position + Vector2(18, 29), String(mission.get("title", "MISSION")), HORIZONTAL_ALIGNMENT_LEFT, 360, 17, V17_IVORY)
	var progress := int(missions.progress(mission, weekly))
	draw_string(v16_body_font, r.position + Vector2(18, 57), "%d / %d   •   %d COINS   •   %d XP" % [progress, int(mission.get("goal", 1)), int(mission.get("coins", 0)), int(mission.get("xp", 0))], HORIZONTAL_ALIGNMENT_LEFT, 430, 12, V16_MUTED)
	var status := "CLAIMED" if claimed else ("CLAIM" if complete else "IN PROGRESS")
	draw_string(v16_title_font, r.position + Vector2(446, 48), status, HORIZONTAL_ALIGNMENT_CENTER, 150, 13, C_GREEN if complete and not claimed else V16_MUTED)

func _v34_draw_completion_chest(r: Rect2, weekly: bool) -> void:
	var claimable := bool(missions.completion_bonus_claimable(weekly))
	var claimed := bool(missions.weekly_bonus_claimed if weekly else missions.daily_bonus_claimed)
	var accent: Color = V16_GOLD if claimable else (Color("526078") if claimed else V16_PURPLE)
	_v16_frame(r, accent, Color("070912"), 0.15)
	var label := ("WEEKLY" if weekly else "DAILY") + " COMPLETION CHEST"
	var status := "CLAIM" if claimable else ("CLAIMED" if claimed else "LOCKED")
	draw_string(v16_title_font, r.position + Vector2(12, 36), label, HORIZONTAL_ALIGNMENT_LEFT, 300, 14, V17_IVORY)
	draw_string(v16_body_font, r.position + Vector2(310, 35), status, HORIZONTAL_ALIGNMENT_RIGHT, 126, 13, C_GOLD if claimable else V16_MUTED)

# -----------------------------------------------------------------------------
# Tower Pass 2.0
# -----------------------------------------------------------------------------

func claim_pass_reward() -> void:
	_v34_claim_pass(false)

func _v34_claim_pass(premium: bool) -> void:
	var unlocked := bool(monetization.premium_pass_unlocked()) if monetization != null else false
	if premium and not unlocked:
		home_overlay = "store"
		return
	var level_no := int(tower_pass.next_claimable(premium, unlocked))
	if level_no < 0:
		loot_notice = "NO %s PASS REWARD READY" % ("PREMIUM" if premium else "FREE")
		loot_notice_color = C_MUTED
		loot_notice_time = 1.5
		return
	var reward: Dictionary = tower_pass.claim(level_no, premium, unlocked)
	if reward.is_empty():
		return
	var coin_mult := economy.pass_coin_multiplier(int(meta.best_floor)) if economy != null else 1.0
	var coins := int(round(float(reward.get("coins", 0)) * coin_mult))
	var shards := int(reward.get("shards", 0))
	meta.coins += coins
	loot.shards += shards
	meta.save_data()
	loot.save_data()
	loot_notice = "%s PASS LV %d — +%d COINS%s" % ["PREMIUM" if premium else "FREE", level_no, coins, " • +%d SHARDS" % shards if shards > 0 else ""]
	loot_notice_color = C_GOLD if premium else C_GREEN
	loot_notice_time = 2.1
	_audio("claim")

func draw_pass_screen() -> void:
	_v16_header("TOWER PASS", "Season %s • 50 levels • free + premium tracks" % String(tower_pass.season_key), V16_PURPLE, 6, "arcane")
	var level_no := int(tower_pass.level())
	var progress: Dictionary = tower_pass.progress_to_next()
	_v16_frame(Rect2(62, 220, 596, 132), V16_PURPLE, Color("070912"), 0.18)
	draw_string(v16_title_font, Vector2(78, 264), "LEVEL %d / %d" % [level_no, tower_pass.MAX_LEVEL], HORIZONTAL_ALIGNMENT_CENTER, 564, 26, V17_IVORY)
	draw_rect(Rect2(118, 296, 484, 18), Color("231b38"))
	draw_rect(Rect2(118, 296, 484 * float(progress.get("ratio", 0.0)), 18), V16_PURPLE)
	draw_string(v16_body_font, Vector2(118, 336), "%d / %d XP TO NEXT LEVEL" % [int(progress.get("current", 0)), int(progress.get("needed", 1))], HORIZONTAL_ALIGNMENT_CENTER, 484, 12, V16_MUTED)

	var start_level := clampi(maxi(1, level_no - 1), 1, maxi(1, tower_pass.MAX_LEVEL - 4))
	for row in range(5):
		var lvl := start_level + row
		var r := Rect2(48, 380 + row * 112, 624, 96)
		_v34_draw_pass_level(r, lvl)

	var unlocked := bool(monetization.premium_pass_unlocked()) if monetization != null else false
	var free_count := int(tower_pass.unclaimed_count(false, unlocked))
	var premium_count := int(tower_pass.unclaimed_count(true, unlocked)) if unlocked else 0
	_v16_button(V34_PASS_FREE, "CLAIM FREE  %d" % free_count, V16_GREEN, 16, -1, free_count > 0)
	_v16_button(V34_PASS_PREMIUM, "CLAIM PREMIUM  %d" % premium_count if unlocked else "UNLOCK PREMIUM", V16_GOLD, 15, -1, (premium_count > 0) if unlocked else true)
	_v16_button(OVERLAY_BACK, "‹  BACK", V16_PURPLE, 17)
	_draw_notice(1120)

func _v34_draw_pass_level(r: Rect2, level_no: int) -> void:
	var reached := level_no <= int(tower_pass.level())
	var free_reward: Dictionary = tower_pass.reward_for(level_no, false)
	var premium_reward: Dictionary = tower_pass.reward_for(level_no, true)
	var accent: Color = V16_GOLD if reached else Color("4d4566")
	_v16_frame(r, accent, Color("060a13"), 0.11)
	draw_string(v16_title_font, r.position + Vector2(16, 40), "LV %02d" % level_no, HORIZONTAL_ALIGNMENT_LEFT, 84, 18, V17_IVORY)
	draw_string(v16_body_font, r.position + Vector2(104, 32), "FREE  %s • %d C • %d S" % [String(free_reward.get("label", "REWARD")), int(free_reward.get("coins", 0)), int(free_reward.get("shards", 0))], HORIZONTAL_ALIGNMENT_LEFT, 480, 11, V16_GREEN if reached else V16_MUTED)
	draw_string(v16_body_font, r.position + Vector2(104, 62), "PREMIUM  %s • %d C • %d S" % [String(premium_reward.get("label", "REWARD")), int(premium_reward.get("coins", 0)), int(premium_reward.get("shards", 0))], HORIZONTAL_ALIGNMENT_LEFT, 480, 11, V16_GOLD if reached else V16_MUTED)

# -----------------------------------------------------------------------------
# v1.20 Store / rewarded-ad foundation
# -----------------------------------------------------------------------------

func _v34_set_store_notice(message: String) -> void:
	v34_store_notice = message
	v34_store_notice_time = 2.8

func _v34_apply_store_result(result: Dictionary) -> void:
	var status := String(result.get("status", ""))
	if status == "granted":
		var coins := int(result.get("coins", 0))
		var shards := int(result.get("shards", 0))
		meta.coins += coins
		loot.shards += shards
		meta.save_data()
		loot.save_data()
		_v34_set_store_notice("GRANTED%s%s" % [" • +%d COINS" % coins if coins > 0 else "", " • +%d SHARDS" % shards if shards > 0 else ""])
		_audio("claim")
	elif status == "owned":
		_v34_set_store_notice("ALREADY OWNED")
	elif status == "cooldown":
		_v34_set_store_notice("REWARDED COOLDOWN • %ds" % int(result.get("remaining", 0)))
	elif status == "provider_required":
		_v34_set_store_notice("NATIVE STORE / AD PROVIDER NOT CONNECTED YET")
	else:
		_v34_set_store_notice("STORE REQUEST FAILED: %s" % status.to_upper())

func _v34_purchase(product_id: String) -> void:
	if monetization == null:
		return
	_v34_apply_store_result(monetization.request_purchase(product_id))

func _v34_rewarded() -> void:
	if monetization == null:
		return
	_v34_apply_store_result(monetization.complete_rewarded_debug())

func draw_store_screen() -> void:
	_v16_header("STORE", "Optional convenience • gameplay remains fully playable free", V16_GOLD, 11, "arcane")
	var mode := "DEBUG PURCHASE SIMULATION" if monetization != null and monetization.is_debug_simulation() else "NATIVE PROVIDER REQUIRED BEFORE RELEASE"
	draw_string(v16_body_font, Vector2(60, 238), mode, HORIZONTAL_ALIGNMENT_CENTER, 600, 13, V16_MUTED)
	var catalog: Array = monetization.product_catalog() if monetization != null else []
	for i in range(mini(V34_STORE_RECTS.size(), catalog.size())):
		var product: Dictionary = catalog[i]
		var r: Rect2 = V34_STORE_RECTS[i]
		_v16_frame(r, V16_GOLD if i < 2 else V16_PURPLE, Color("070a12"), 0.13)
		draw_string(v16_title_font, r.position + Vector2(20, 40), String(product.get("title", "PRODUCT")), HORIZONTAL_ALIGNMENT_LEFT, 360, 17, V17_IVORY)
		draw_string(v16_body_font, r.position + Vector2(20, 70), String(product.get("subtitle", "")), HORIZONTAL_ALIGNMENT_LEFT, 420, 12, V16_MUTED)
		var owned := _v34_product_owned(String(product.get("id", "")))
		draw_string(v16_title_font, r.position + Vector2(450, 57), "OWNED" if owned else ("DEV TEST" if monetization.is_debug_simulation() else "BUY"), HORIZONTAL_ALIGNMENT_CENTER, 132, 13, C_GREEN if owned else V16_GOLD)

	var reward_label := "REWARDED TEST • %d LEFT TODAY" % int(monetization.rewarded_remaining_today()) if monetization != null else "REWARDED"
	_v16_button(V34_STORE_REWARDED, reward_label, V16_GREEN, 16, -1, monetization != null and monetization.can_request_rewarded())
	if v34_store_notice_time > 0.0:
		draw_string(v16_body_font, Vector2(62, 1060), v34_store_notice, HORIZONTAL_ALIGNMENT_CENTER, 596, 13, C_GOLD)
	_v16_button(V34_STORE_BACK, "‹  BACK", V16_PURPLE, 17)

func _v34_product_owned(product_id: String) -> bool:
	if monetization == null:
		return false
	if product_id == monetization.PRODUCT_REMOVE_ADS:
		return bool(monetization.remove_ads)
	if product_id == monetization.PRODUCT_STARTER:
		return bool(monetization.starter_claimed)
	if product_id == monetization.PRODUCT_PREMIUM_PASS:
		return bool(monetization.premium_pass_unlocked())
	return false

# -----------------------------------------------------------------------------
# Input / home overlay routing
# -----------------------------------------------------------------------------

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if not pressed:
		super.pointer(pos, pressed, id)
		return
	if state == State.HOME and home_overlay == "store":
		if V34_STORE_BACK.has_point(pos):
			home_overlay = ""
			_audio("menu")
			return
		for i in range(V34_STORE_RECTS.size()):
			if V34_STORE_RECTS[i].has_point(pos):
				var catalog: Array = monetization.product_catalog()
				if i < catalog.size():
					_v34_purchase(String(catalog[i].get("id", "")))
				return
		if V34_STORE_REWARDED.has_point(pos):
			_v34_rewarded()
			return
		return
	if state == State.HOME and home_overlay == "missions":
		if OVERLAY_BACK.has_point(pos):
			home_overlay = ""
			_audio("menu")
			return
		for i in range(3):
			if V34_DAILY_RECTS[i].has_point(pos):
				claim_mission(i)
				return
			if V34_WEEKLY_RECTS[i].has_point(pos):
				claim_mission(i + 3)
				return
		if V34_DAILY_CHEST.has_point(pos):
			_v34_claim_mission_chest(false)
			return
		if V34_WEEKLY_CHEST.has_point(pos):
			_v34_claim_mission_chest(true)
			return
		return
	if state == State.HOME and home_overlay == "pass":
		if OVERLAY_BACK.has_point(pos):
			home_overlay = ""
			_audio("menu")
			return
		if V34_PASS_FREE.has_point(pos):
			_v34_claim_pass(false)
			return
		if V34_PASS_PREMIUM.has_point(pos):
			_v34_claim_pass(true)
			return
		return
	if state == State.HOME and home_overlay == "" and not settings_open and V34_STORE_HOME.has_point(pos):
		home_overlay = "store"
		_audio("menu")
		return
	super.pointer(pos, pressed, id)

func draw_home() -> void:
	if home_overlay == "store":
		draw_store_screen()
		return
	if home_overlay in ["missions", "pass"]:
		super.draw_home()
		return
	super.draw_home()
	if not settings_open:
		_v16_button(V34_STORE_HOME, "STORE", V16_GOLD, 12, 11)

# Repaint the inherited deep-tower strip as one compact four-column status bar.
func draw_game() -> void:
	super.draw_game()
	if run == null or int(run.floor_no) <= 50:
		return
	draw_rect(Rect2(38, 250, 644, 110), Color(0.018, 0.025, 0.055, 0.97))
	_v16_frame(Rect2(54, 266, 612, 58), V16_PURPLE, Color("050813"), 0.10)
	var area := String(current_room.get("area", "TOWER"))
	var modifier := run_modifier if run_modifier != "NONE" else "STANDARD"
	var asc := "ASCENSION %d" % _v27_ascension_tier()
	var contract := _v31_contract_label() if v31_challenge_active else String(v34_pressure.get("label", "ON CURVE"))
	draw_string(v16_body_font, Vector2(66, 301), modifier, HORIZONTAL_ALIGNMENT_CENTER, 138, 11, V16_PURPLE_HI)
	draw_string(v16_body_font, Vector2(210, 301), asc, HORIZONTAL_ALIGNMENT_CENTER, 138, 11, V16_GOLD)
	draw_string(v16_body_font, Vector2(354, 301), area, HORIZONTAL_ALIGNMENT_CENTER, 156, 11, V17_IVORY)
	draw_string(v16_body_font, Vector2(516, 301), contract, HORIZONTAL_ALIGNMENT_CENTER, 138, 10, C_CYAN if v31_challenge_active else V16_MUTED)
