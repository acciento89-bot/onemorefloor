extends "res://scripts/main_v28.gd"

# ONE MORE FLOOR cumulative v1.16-v1.18 gameplay pass.
# v1.16 Loot 2.0: Enhance / Enchant / Awaken.
# v1.17 Meta 2.0: Ascension Sigils + three permanent masteries.
# v1.18 Runs 3.0: floor contracts + three new tower events.
# Also consolidates the stacked top-of-arena condition badges into one strip.

const LootSystemV2 = preload("res://scripts/loot_system_v2.gd")
const ProgressionV2 = preload("res://scripts/progression_v2.gd")
const V31_VERSION := "1.18-runs3"

const V31_ENHANCE := Rect2(44, 1040, 198, 64)
const V31_ENCHANT := Rect2(261, 1040, 198, 64)
const V31_AWAKEN := Rect2(478, 1040, 198, 64)
const V31_MASTERY_OPEN := Rect2(190, 318, 340, 76)
const V31_MASTERY_CLOSE := Rect2(240, 1002, 240, 64)
const V31_MASTERY_RECTS := [
	Rect2(74, 350, 572, 152),
	Rect2(74, 532, 572, 152),
	Rect2(74, 714, 572, 152),
]
const V31_MASTERY_KINDS := ["warpath", "guardian", "arcana"]

var v31_mastery_open := false
var v31_challenge_active := false
var v31_challenge_type := ""
var v31_challenge_elapsed := 0.0
var v31_challenge_target := 0.0
var v31_challenge_floor := -1
var v31_challenge_reward_coins := 0
var v31_challenge_reward_shards := 0

func _ready() -> void:
	super._ready()
	# Swap in additive v2 save-compatible systems after the legacy runtime has
	# initialized. Both read the same save.cfg, so no inventory/progress is lost.
	meta = ProgressionV2.new()
	meta.load_data()
	loot = LootSystemV2.new()
	loot.load_data()
	queue_redraw()

func _process(delta: float) -> void:
	super._process(delta)
	if state == State.RUNNING and v31_challenge_active:
		v31_challenge_elapsed += delta

# -----------------------------------------------------------------------------
# v1.17 — permanent mastery application
# -----------------------------------------------------------------------------

func start_run() -> void:
	v31_challenge_active = false
	v31_challenge_type = ""
	v31_challenge_floor = -1
	super.start_run()
	if meta != null and meta.has_method("mastery_armor_bonus"):
		run.armor = minf(0.62, run.armor + float(meta.mastery_armor_bonus()))
		run.nova_mult *= float(meta.mastery_nova_multiplier())
		run.crit_mult += float(meta.mastery_crit_mult_bonus())

func continue_run() -> void:
	var sigils_before := int(meta.ascension_sigils) if meta != null and "ascension_sigils" in meta else 0
	super.continue_run()
	if meta != null and "ascension_sigils" in meta:
		var gained := int(meta.ascension_sigils) - sigils_before
		if gained > 0:
			loot_notice = "ASCENSION MILESTONE — +%d SIGIL%s" % [gained, "" if gained == 1 else "S"]
			loot_notice_color = C_GOLD
			loot_notice_time = 2.8
			_audio("claim")

# -----------------------------------------------------------------------------
# v1.18 — floor contracts
# -----------------------------------------------------------------------------

func spawn_floor() -> void:
	super.spawn_floor()
	_v31_prepare_floor_contract()

func _v31_prepare_floor_contract() -> void:
	v31_challenge_active = false
	v31_challenge_type = ""
	v31_challenge_elapsed = 0.0
	v31_challenge_target = 0.0
	if run == null:
		return
	var floor_no := int(run.floor_no)
	var room_type := String(current_room.get("type", "COMBAT"))
	if floor_no < 6 or room_type in ["BOSS", "TREASURE"] or enemies.is_empty():
		return
	var chance := minf(0.38, 0.16 + float(floor_no) * 0.0011)
	var guaranteed := floor_no % 10 == 7
	if not guaranteed and rng.randf() > chance:
		return
	var pool := ["RUSH", "HUNTED", "FRAGILE", "OVERLOAD"]
	v31_challenge_type = String(pool[rng.randi_range(0, pool.size() - 1)])
	v31_challenge_active = true
	v31_challenge_floor = floor_no
	v31_challenge_reward_coins = 18 + floor_no * 2
	v31_challenge_reward_shards = 3 + int(floor_no / 12)
	match v31_challenge_type:
		"RUSH":
			v31_challenge_target = 23.0 + minf(22.0, float(floor_no) * 0.11)
			for i in range(enemies.size()):
				var e: Dictionary = enemies[i]
				e["speed"] = float(e.get("speed", 1.0)) * 1.10
				enemies[i] = e
		"HUNTED":
			var idx := rng.randi_range(0, enemies.size() - 1)
			var target: Dictionary = enemies[idx]
			target["max_hp"] = float(target.get("max_hp", target.get("hp", 1.0))) * 2.15
			target["hp"] = float(target["max_hp"])
			target["touch_damage"] = float(target.get("touch_damage", 1.0)) * 1.20
			target["reward"] = int(round(float(target.get("reward", 1)) * 2.6))
			target["elite"] = true
			target["bounty_target"] = true
			enemies[idx] = target
		"OVERLOAD":
			for i in range(enemies.size()):
				var e: Dictionary = enemies[i]
				e["max_hp"] = float(e.get("max_hp", e.get("hp", 1.0))) * 1.42
				e["hp"] = float(e["max_hp"])
				e["touch_damage"] = float(e.get("touch_damage", 1.0)) * 1.10
				enemies[i] = e
		"FRAGILE":
			pass

func damage_player(raw_damage: float, source: Vector2) -> void:
	if v31_challenge_active and v31_challenge_type == "FRAGILE":
		raw_damage *= 1.30
	super.damage_player(raw_damage, source)

func roll_upgrade_options() -> void:
	var contract_result := _v31_resolve_floor_contract()
	super.roll_upgrade_options()
	if contract_result != "":
		loot_notice = contract_result
		loot_notice_color = C_GOLD
		loot_notice_time = 2.5
		_audio("claim")

func _v31_resolve_floor_contract() -> String:
	if not v31_challenge_active or run == null or int(run.floor_no) != v31_challenge_floor:
		return ""
	var success := true
	if v31_challenge_type == "RUSH":
		success = v31_challenge_elapsed <= v31_challenge_target
	var title := v31_challenge_type
	v31_challenge_active = false
	if not success:
		return "%s CONTRACT FAILED — %.1fs" % [title, v31_challenge_elapsed]
	run.run_coins += v31_challenge_reward_coins
	loot.shards += v31_challenge_reward_shards
	loot.save_data()
	tower_pass.add_xp(18 + mini(70, int(run.floor_no / 3)))
	# Deep successful contracts have a small chance to produce a guaranteed-tier
	# cache item. It is deliberately uncommon so normal loot still matters.
	if int(run.floor_no) >= 30 and rng.randf() < 0.14:
		loot.roll_drop("warden", int(run.floor_no), rng)
	return "%s COMPLETE — +%d COINS • +%d SHARDS" % [title, v31_challenge_reward_coins, v31_challenge_reward_shards]

func _v31_contract_label() -> String:
	if not v31_challenge_active:
		return "NO CONTRACT"
	if v31_challenge_type == "RUSH":
		return "RUSH  %.0fs" % maxf(0.0, v31_challenge_target - v31_challenge_elapsed)
	match v31_challenge_type:
		"HUNTED": return "BOUNTY TARGET"
		"FRAGILE": return "FRAGILE +30% DMG"
		"OVERLOAD": return "OVERLOAD"
	return v31_challenge_type

# -----------------------------------------------------------------------------
# v1.18 — expanded between-floor tower events
# -----------------------------------------------------------------------------

func _v23_maybe_prepare_room_event() -> void:
	super._v23_maybe_prepare_room_event()
	if run == null or int(run.floor_no) < 10:
		return
	var new_events := ["cursed_gate", "mirror_chamber", "gamblers_reliquary"]
	if room_event_active:
		# About a third of existing events in the deeper tower become one of the
		# new high-risk event families, keeping the overall event cadence stable.
		if rng.randf() < 0.34:
			_v23_set_room_event(String(new_events[rng.randi_range(0, new_events.size() - 1)]))
		return
	if int(run.floor_no) - v23_last_event_floor >= 3 and rng.randf() < 0.10:
		_v23_set_room_event(String(new_events[rng.randi_range(0, new_events.size() - 1)]))
		v23_last_event_floor = int(run.floor_no)

func _v23_set_room_event(kind: String) -> void:
	match kind:
		"cursed_gate":
			room_event_active = true
			room_event = {"type":kind, "title":"CURSED GATE", "subtitle":"The shortcut is open. So is the price."}
		"mirror_chamber":
			room_event_active = true
			room_event = {"type":kind, "title":"MIRROR CHAMBER", "subtitle":"Your strongest choices stare back at you."}
		"gamblers_reliquary":
			room_event_active = true
			room_event = {"type":kind, "title":"GAMBLER'S RELIQUARY", "subtitle":"The reliquary rewards conviction, not caution."}
		_:
			super._v23_set_room_event(kind)

func _v23_event_choices() -> Array[Dictionary]:
	var kind := String(room_event.get("type", ""))
	if kind == "cursed_gate":
		return [
			{"title":"EMBRACE THE CURSE", "desc":"-10% max HP • +25% damage • +20% run coin multiplier", "accent":C_RED},
			{"title":"BREAK THE SEAL", "desc":"Pay 25% run coins • +7% armor • +5% crit", "accent":C_GOLD},
			{"title":"TURN BACK", "desc":"Leave the gate sealed", "accent":C_MUTED},
		]
	if kind == "mirror_chamber":
		return [
			{"title":"REFLECT POWER", "desc":"Repeat your strongest run upgrade at Rare strength", "accent":C_PURPLE},
			{"title":"REFLECT LIFE", "desc":"+15% max HP and fully heal", "accent":C_GREEN},
			{"title":"SHATTER MIRROR", "desc":"Lose 20% current HP • gain persistent Soul Shards", "accent":C_CYAN},
		]
	if kind == "gamblers_reliquary":
		var item_cost := 85 + int(run.floor_no) * 4
		return [
			{"title":"WAGER 20% COINS", "desc":"50/50: lose the wager or win triple", "accent":C_ORANGE},
			{"title":"BUY RELIQUARY CACHE", "desc":"%d run coins • guaranteed gear drop" % item_cost, "accent":C_GOLD},
			{"title":"KEEP WALKING", "desc":"Risk nothing", "accent":C_MUTED},
		]
	return super._v23_event_choices()

func _v23_resolve_room_event(index: int) -> void:
	var kind := String(room_event.get("type", ""))
	if not kind in ["cursed_gate", "mirror_chamber", "gamblers_reliquary"]:
		super._v23_resolve_room_event(index)
		return
	if index < 0 or index > 2 or not room_event_active:
		return
	var result := "EVENT PASSED"
	if kind == "cursed_gate":
		if index == 0:
			run.max_hp = maxf(40.0, run.max_hp * 0.90)
			run.hp = minf(run.hp, run.max_hp)
			run.damage *= 1.25
			run_modifier_coin_mult *= 1.20
			result = "CURSED GATE — CURSE EMBRACED"
		elif index == 1:
			var payment := int(round(float(run.run_coins) * 0.25))
			run.run_coins = maxi(0, run.run_coins - payment)
			run.armor = minf(0.62, run.armor + 0.07)
			run.crit_chance = minf(0.70, run.crit_chance + 0.05)
			result = "CURSED GATE — SEAL BROKEN"
		else:
			result = "CURSED GATE — LEFT SEALED"
	elif kind == "mirror_chamber":
		if index == 0:
			var best_kind := "power"
			var best_count := -1
			for key in run.upgrade_counts.keys():
				var count := int(run.upgrade_counts[key])
				if count > best_count:
					best_count = count
					best_kind = String(key)
			run.apply_upgrade_scaled(best_kind, 1.35)
			result = "MIRROR — %s REFLECTED" % best_kind.to_upper()
		elif index == 1:
			run.max_hp *= 1.15
			run.hp = run.max_hp
			result = "MIRROR — LIFE REFLECTED"
		else:
			var gained := 7 + int(run.floor_no / 8)
			run.hp = maxf(1.0, run.hp * 0.80)
			loot.shards += gained
			loot.save_data()
			result = "MIRROR SHATTERED — +%d SHARDS" % gained
	else:
		if index == 0:
			var wager := int(round(float(run.run_coins) * 0.20))
			if wager <= 0:
				result = "RELIQUARY — NOTHING TO WAGER"
			elif rng.randf() < 0.50:
				run.run_coins = maxi(0, run.run_coins - wager)
				result = "RELIQUARY — LOST %d COINS" % wager
			else:
				run.run_coins += wager * 2
				result = "RELIQUARY — WON %d COINS" % (wager * 2)
		elif index == 1:
			var cost := 85 + int(run.floor_no) * 4
			if run.run_coins < cost:
				loot_notice = "NOT ENOUGH RUN COINS"
				loot_notice_color = C_RED
				loot_notice_time = 1.4
				return
			run.run_coins -= cost
			var item := loot.roll_drop("warden", int(run.floor_no), rng)
			result = "RELIQUARY CACHE — %s" % String(item.get("name", "GEAR"))
		else:
			result = "RELIQUARY — NO WAGER"
	room_event_active = false
	room_event.clear()
	loot_notice = result
	loot_notice_color = C_GOLD
	loot_notice_time = 2.2
	_audio("claim")

# -----------------------------------------------------------------------------
# v1.16 — Vault item progression UI
# -----------------------------------------------------------------------------

func _v31_selected_vault_index() -> int:
	if selected_vault_id == "":
		return -1
	return int(loot.find_index_by_id(selected_vault_id))

func _v31_set_loot_notice(message: String, color: Color) -> void:
	loot_notice = message
	loot_notice_color = color
	loot_notice_time = 2.2

func _v31_enhance_selected() -> void:
	var index := _v31_selected_vault_index()
	if index < 0:
		_v31_set_loot_notice("SELECT AN ITEM FIRST", C_MUTED)
		return
	var item: Dictionary = loot.inventory[index]
	var cost := int(loot.enhance_cost(item))
	if loot.enhance_index(index):
		_v31_set_loot_notice("ENHANCED %s  +%d" % [String(loot.inventory[index]["name"]), int(loot.inventory[index].get("enhance_level", 0))], C_GREEN)
		_audio("claim")
	else:
		_v31_set_loot_notice("ENHANCE NEEDS %d SHARDS OR IS MAXED" % cost, C_RED)

func _v31_enchant_selected() -> void:
	var index := _v31_selected_vault_index()
	if index < 0:
		_v31_set_loot_notice("SELECT AN ITEM FIRST", C_MUTED)
		return
	var item: Dictionary = loot.inventory[index]
	var cost := int(loot.enchant_cost(item))
	if loot.enchant_index(index, rng):
		_v31_set_loot_notice("ENCHANTED — %s" % String(loot.inventory[index].get("trait", "")), C_PURPLE)
		_audio("claim")
	else:
		_v31_set_loot_notice("ENCHANT NEEDS RARE+ AND %d SHARDS" % cost, C_RED)

func _v31_awaken_selected() -> void:
	var index := _v31_selected_vault_index()
	if index < 0:
		_v31_set_loot_notice("SELECT AN ITEM FIRST", C_MUTED)
		return
	var item: Dictionary = loot.inventory[index]
	var cost := int(loot.awaken_cost(item))
	if loot.awaken_index(index):
		var awakened: Dictionary = loot.inventory[index]
		_v31_set_loot_notice("AWAKENED — %s %s" % [String(awakened["rarity"]), String(awakened["name"])], rarity_color(String(awakened["rarity"])))
		_audio("loot")
	else:
		_v31_set_loot_notice("MAX ENHANCE FIRST • AWAKEN COST %d" % cost, C_RED)

func draw_vault_screen() -> void:
	super.draw_vault_screen()
	var index := _v31_selected_vault_index()
	var has_item := index >= 0 and index < loot.inventory.size()
	var enhance_label := "ENHANCE"
	var enchant_label := "ENCHANT"
	var awaken_label := "AWAKEN"
	var can_enhance := false
	var can_enchant := false
	var can_awaken := false
	if has_item:
		var item: Dictionary = loot.inventory[index]
		enhance_label = "ENHANCE  %d" % int(loot.enhance_cost(item))
		enchant_label = "ENCHANT  %d" % int(loot.enchant_cost(item))
		awaken_label = "AWAKEN  %d" % int(loot.awaken_cost(item))
		can_enhance = int(item.get("enhance_level", 0)) < int(loot.max_enhance_level(item)) and int(loot.shards) >= int(loot.enhance_cost(item))
		can_enchant = int(item.get("rarity_index", 0)) >= 2 and int(loot.shards) >= int(loot.enchant_cost(item))
		can_awaken = bool(loot.can_awaken(item)) and int(loot.shards) >= int(loot.awaken_cost(item))
		_v16_center(loot.progression_line(item), 1025, 12, V16_MUTED)
	_v16_button(V31_ENHANCE, enhance_label, V16_GREEN if can_enhance else Color("626578"), 12, -1, can_enhance)
	_v16_button(V31_ENCHANT, enchant_label, V16_PURPLE if can_enchant else Color("626578"), 12, -1, can_enchant)
	_v16_button(V31_AWAKEN, awaken_label, V16_GOLD if can_awaken else Color("626578"), 12, -1, can_awaken)

# -----------------------------------------------------------------------------
# v1.17 — Mastery UI
# -----------------------------------------------------------------------------

func draw_talents_screen() -> void:
	super.draw_talents_screen()
	if v31_mastery_open:
		_v31_draw_mastery_overlay()
		return
	var sigils := int(meta.ascension_sigils) if meta != null and "ascension_sigils" in meta else 0
	_v16_frame(Rect2(106, 292, 508, 116), V16_GOLD, Color("07101d"), 0.15)
	_v16_center("ASCENSION SIGILS  %d" % sigils, 326, 15, V16_GOLD_HI, true)
	_v16_center("Warpath %d   •   Guardian %d   •   Arcana %d" % [int(meta.mastery_level("warpath")), int(meta.mastery_level("guardian")), int(meta.mastery_level("arcana"))], 354, 12, V16_MUTED)
	_v16_button(V31_MASTERY_OPEN, "ASCENSION MASTERY", V16_PURPLE, 15)

func _v31_draw_mastery_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.0, 0.0, 0.02, 0.88))
	_v16_frame(Rect2(52, 170, 616, 914), V16_PURPLE, Color("050a14"), 0.24)
	_v16_title("ASCENSION MASTERY", 246, 37, V16_GOLD)
	_v16_center("SIGILS  %d" % int(meta.ascension_sigils), 292, 17, V16_GOLD_HI)
	var names := ["WARPATH", "GUARDIAN", "ARCANA"]
	var descs := [
		"+6% permanent damage / rank",
		"+11 starting HP +0.8% armor / rank",
		"+8% NOVA +0.4% crit +crit damage / rank",
	]
	var accents := [V16_ORANGE, V16_GREEN, V16_PURPLE]
	for i in range(3):
		var kind := String(V31_MASTERY_KINDS[i])
		var r: Rect2 = V31_MASTERY_RECTS[i]
		var accent: Color = accents[i]
		_v16_frame(r, accent, Color(accent, 0.07), 0.16)
		_v16_text(names[i], r.position + Vector2(28, 46), 22, V16_TEXT, true)
		_v16_text("RANK %d" % int(meta.mastery_level(kind)), r.position + Vector2(28, 77), 14, accent)
		_v16_text(descs[i], r.position + Vector2(28, 108), 13, V16_MUTED)
		var cost := int(meta.mastery_cost(kind))
		_v16_text("TAP TO UPGRADE • %d SIGIL%s" % [cost, "" if cost == 1 else "S"], r.position + Vector2(320, 79), 13, V16_GOLD_HI)
	_v16_button(V31_MASTERY_CLOSE, "BACK TO TALENTS", V16_PURPLE, 15)

func _v31_buy_mastery(index: int) -> void:
	if index < 0 or index >= V31_MASTERY_KINDS.size():
		return
	var kind := String(V31_MASTERY_KINDS[index])
	if meta.buy_mastery(kind):
		_v31_set_loot_notice("%s MASTERY — RANK %d" % [kind.to_upper(), int(meta.mastery_level(kind))], C_GOLD)
		_audio("claim")
	else:
		_v31_set_loot_notice("NOT ENOUGH ASCENSION SIGILS", C_RED)

# -----------------------------------------------------------------------------
# Input
# -----------------------------------------------------------------------------

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if pressed and state == State.VAULT:
		if V31_ENHANCE.has_point(pos):
			_v31_enhance_selected()
			return
		if V31_ENCHANT.has_point(pos):
			_v31_enchant_selected()
			return
		if V31_AWAKEN.has_point(pos):
			_v31_awaken_selected()
			return
	if pressed and state == State.TALENTS:
		if v31_mastery_open:
			if V31_MASTERY_CLOSE.has_point(pos):
				v31_mastery_open = false
				_audio("menu")
				return
			for i in range(V31_MASTERY_RECTS.size()):
				if V31_MASTERY_RECTS[i].has_point(pos):
					_v31_buy_mastery(i)
					return
			return
		if V31_MASTERY_OPEN.has_point(pos):
			v31_mastery_open = true
			_audio("menu")
			return
	super.pointer(pos, pressed, id)

# -----------------------------------------------------------------------------
# Compact combat condition strip — replaces the three stacked badges visible in
# the Floor 53 screenshot with one readable line.
# -----------------------------------------------------------------------------

func draw_game() -> void:
	super.draw_game()
	if run == null or int(run.floor_no) <= 50:
		return
	# Cover only the legacy badge stack, not the entire upper arena.
	draw_rect(Rect2(38, 252, 644, 108), Color(0.018, 0.025, 0.055, 0.94))
	draw_line(Vector2(52, 258), Vector2(668, 258), Color(V16_PURPLE, 0.45), 1.0)
	draw_line(Vector2(52, 326), Vector2(668, 326), Color(V16_PURPLE, 0.30), 1.0)
	var modifier := run_modifier if run_modifier != "NONE" else "STANDARD"
	var ascension := "ASCENSION %d" % _v27_ascension_tier()
	var contract := _v31_contract_label()
	draw_string(font, Vector2(54, 293), modifier, HORIZONTAL_ALIGNMENT_CENTER, 196, 12, V16_PURPLE_HI)
	draw_string(font, Vector2(262, 293), ascension, HORIZONTAL_ALIGNMENT_CENTER, 196, 12, V16_GOLD_HI)
	draw_string(font, Vector2(470, 293), contract, HORIZONTAL_ALIGNMENT_CENTER, 196, 12, C_CYAN if v31_challenge_active else V16_MUTED)
	if v31_challenge_active:
		draw_string(font, Vector2(72, 342), "FLOOR CONTRACT — extra coins, shards and Pass XP on success", HORIZONTAL_ALIGNMENT_CENTER, 576, 11, V16_MUTED)
