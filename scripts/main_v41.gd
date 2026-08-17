extends "res://scripts/main_v40.gd"

# v1.28 — progression UI art-direction pass.
# Keeps the current economy/input/save systems intact while replacing the three
# weakest progression surfaces from the TestFlight screenshots with intentional,
# game-like compositions: Ascension Mastery tree, reward-driven Tower Pass and a
# contextual Vault workshop. Everything remains live Godot UI; no screenshots are
# baked into the runtime.

const V41_VERSION := "1.26.0-progression-ui-pass"
const V41_BUILD := "21"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V41_VERSION, V41_BUILD)
		telemetry.event("progression_ui_pass_ready", {
			"build": V41_BUILD,
			"best_floor": int(meta.best_floor),
			"pass_level": int(tower_pass.level()) if tower_pass != null else 0
		})
	queue_redraw()

# -----------------------------------------------------------------------------
# ASCENSION MASTERY — readable talent tree instead of three developer-like rows.
# Existing V31_MASTERY_RECTS remain the tap targets, so progression/save behavior
# is unchanged.
# -----------------------------------------------------------------------------

func _v31_draw_mastery_overlay() -> void:
	var p := _v38_primary()
	var s := _v38_secondary()
	var panel := Rect2(42, 146, 636, 960)
	_v16_frame(panel, p, Color("050814"), 0.24)

	# Crown / resource focus.
	_v15_soft_glow(Vector2(360, 230), 92, p, 0.48)
	_v16_title("ASCENSION MASTERY", 230, 37, V16_GOLD)
	_v16_medallion(Vector2(360, 285), 27, p, 1)
	_v16_center("%d  SIGILS" % int(meta.ascension_sigils), 330, 17, V17_GOLD_HI, true)
	_v16_center("Deep-floor milestones become permanent power", 356, 11, V16_MUTED)

	# A real progression spine. Branches alternate sides so the screen reads as a
	# tree rather than another stack of store-style cards.
	draw_line(Vector2(360, 382), Vector2(360, 875), Color(p, 0.22), 3.0)
	for y in [424.0, 606.0, 788.0]:
		draw_circle(Vector2(360, y), 6.0, Color("050812"))
		draw_arc(Vector2(360, y), 6.0, 0.0, TAU, 24, Color(s, 0.42), 1.5)

	_v41_draw_mastery_branch(0, "WARPATH", "Relentless offense", V16_ORANGE, 6, true)
	_v41_draw_mastery_branch(1, "GUARDIAN", "Survive the next floor", V16_GREEN, 0, false)
	_v41_draw_mastery_branch(2, "ARCANA", "NOVA and critical mastery", V16_PURPLE, 1, true)

	_v16_button(V31_MASTERY_CLOSE, "BACK TO TALENTS", V16_PURPLE, 15)
	_v16_center("Tap a branch to invest • ranks are permanent", 1080, 11, Color(V16_MUTED, 0.86))

func _v41_draw_mastery_branch(index: int, title: String, subtitle: String, accent: Color, icon_index: int, left_node: bool) -> void:
	var hit: Rect2 = V31_MASTERY_RECTS[index]
	var kind: String = String(V31_MASTERY_KINDS[index])
	var rank: int = int(meta.mastery_level(kind))
	var cost: int = int(meta.mastery_cost(kind))
	var affordable: bool = int(meta.ascension_sigils) >= cost
	var node_x := 124.0 if left_node else 596.0
	var node := Vector2(node_x, hit.get_center().y)
	var card := Rect2(172, hit.position.y + 5, 466, hit.size.y - 10) if left_node else Rect2(82, hit.position.y + 5, 466, hit.size.y - 10)

	# Branch connector and node halo.
	draw_line(Vector2(360, hit.get_center().y), Vector2(node_x, hit.get_center().y), Color(accent, 0.25), 2.0)
	_v15_soft_glow(node, 47, accent, 0.42 if affordable else 0.20)
	_v16_medallion(node, 34, accent, icon_index)
	_v16_frame(card, accent, Color(accent, 0.055), 0.14)

	var tx := card.position.x + 24.0
	_v16_text(title, Vector2(tx, card.position.y + 38), 22, V17_IVORY, true)
	_v16_text("RANK %d  •  %s" % [rank, subtitle], Vector2(tx, card.position.y + 65), 11, accent)
	_v16_text(_v41_mastery_bonus_text(kind, rank), Vector2(tx, card.position.y + 90), 11, V16_MUTED)

	# Rank pips communicate progress instantly even before the player reads text.
	var pip_y := card.end.y - 22.0
	for pip in range(8):
		var pip_x := tx + float(pip) * 22.0
		var filled := pip < mini(rank, 8)
		_v38_diamond(Vector2(pip_x, pip_y), 4.0, Color(accent, 0.88 if filled else 0.16))
	if rank > 8:
		_v16_text("+%d" % (rank - 8), Vector2(tx + 181, pip_y + 4), 9, accent, true)

	var cost_color := V17_GOLD_HI if affordable else Color("777a8b")
	draw_string(v16_title_font, Vector2(card.end.x - 174, card.position.y + 42), "%d SIGIL%s" % [cost, "" if cost == 1 else "S"], HORIZONTAL_ALIGNMENT_CENTER, 148, 13, cost_color)
	draw_string(v16_body_font, Vector2(card.end.x - 174, card.position.y + 69), "TAP TO UPGRADE", HORIZONTAL_ALIGNMENT_CENTER, 148, 9, cost_color)

func _v41_mastery_bonus_text(kind: String, rank: int) -> String:
	match kind:
		"warpath":
			return "+%d%% permanent damage" % (rank * 6)
		"guardian":
			return "+%d starting HP  •  +%.1f%% armor" % [rank * 11, float(rank) * 0.8]
		"arcana":
			return "+%d%% NOVA  •  +%.1f%% crit scaling" % [rank * 8, float(rank) * 0.4]
	return "Permanent tower mastery"

# -----------------------------------------------------------------------------
# TOWER PASS — the rewards are now the visual language. Five levels remain on
# screen, but every row has coin/shard/cache iconography, a rail state and clear
# free/premium separation instead of reading like a debug table.
# -----------------------------------------------------------------------------

func draw_pass_screen() -> void:
	_v16_header("TOWER PASS", "Season %s  •  50 levels" % String(tower_pass.season_key), V16_PURPLE, 6, "arcane")
	var p := _v38_primary()
	var level_no: int = int(tower_pass.level())
	var progress: Dictionary = tower_pass.progress_to_next()
	var premium_unlocked: bool = bool(monetization.premium_pass_unlocked())

	# Current level / progress crown.
	var crown := Rect2(58, 214, 604, 142)
	_v16_frame(crown, p, Color("070912"), 0.18)
	_v16_medallion(Vector2(108, 271), 29, p, 6)
	_v16_text("LEVEL %d / 50" % level_no, Vector2(154, 258), 25, V17_IVORY, true)
	_v16_text("ASCEND THE SEASON TRACK", Vector2(154, 285), 10, V16_MUTED, true)
	var bar := Rect2(154, 306, 418, 18)
	draw_rect(bar, Color("211a35"))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * float(progress.get("ratio", 0.0)), bar.size.y)), Color(p, 0.92))
	draw_line(bar.position + Vector2(3, 3), Vector2(bar.position.x + maxf(3.0, bar.size.x * float(progress.get("ratio", 0.0)) - 3.0), bar.position.y + 3), Color("e4b8ff", 0.62), 1.5)
	_v16_text("%d / %d XP" % [int(progress.get("current", 0)), int(progress.get("needed", 1))], Vector2(154, 344), 11, V16_MUTED)

	# Vertical reward rail.
	var start: int = clampi(maxi(1, level_no - 1), 1, 46)
	draw_line(Vector2(82, 404), Vector2(82, 918), Color(p, 0.20), 4.0)
	for row_index in range(5):
		var reward_level := start + row_index
		var row := Rect2(52, 374 + row_index * 112, 616, 98)
		_v41_draw_pass_level(row, reward_level, level_no, premium_unlocked)

	# Claim footer keeps the existing input hitboxes intact.
	var free_count: int = int(tower_pass.unclaimed_count(false, premium_unlocked))
	var premium_count: int = int(tower_pass.unclaimed_count(true, premium_unlocked)) if premium_unlocked else 0
	_v16_button(PASS_FREE, "CLAIM FREE  %d" % free_count, V16_GREEN, 16, 11, free_count > 0)
	_v16_button(PASS_PREMIUM, "CLAIM PREMIUM  %d" % premium_count if premium_unlocked else "UNLOCK PREMIUM", V16_GOLD, 15, 10, true)
	_v16_button(OVERLAY_BACK, "‹  BACK", V16_PURPLE, 17)
	_draw_notice(1120)

func _v41_draw_pass_level(r: Rect2, level_no: int, current_level: int, premium_unlocked: bool) -> void:
	var free_reward: Dictionary = tower_pass.reward_for(level_no, false)
	var premium_reward: Dictionary = tower_pass.reward_for(level_no, true)
	var reached := level_no <= current_level
	var free_claimable := bool(tower_pass.can_claim(level_no, false, premium_unlocked))
	var premium_claimable := bool(tower_pass.can_claim(level_no, true, premium_unlocked))
	var accent := V16_GOLD if reached else Color("52576b")
	if free_claimable or premium_claimable:
		accent = V16_PURPLE_HI

	# Rail node sits outside the card and makes the five rows one progression path.
	var rail_center := Vector2(82, r.get_center().y)
	draw_circle(rail_center, 16.0, Color("050713"))
	draw_arc(rail_center, 16.0, 0.0, TAU, 32, Color(accent, 0.92), 2.0)
	_v16_center_in(Rect2(66, rail_center.y - 10, 32, 20), str(level_no), 10, V17_IVORY, true)

	var card := Rect2(112, r.position.y, 556, r.size.y)
	_v16_frame(card, accent, Color("050912"), 0.11)
	_v16_text("LV %02d" % level_no, card.position + Vector2(16, 31), 16, V17_IVORY, true)
	_v16_text("FREE", card.position + Vector2(92, 25), 9, V16_GREEN, true)
	_v41_draw_pass_reward(free_reward, card.position + Vector2(139, 49), V16_GREEN, free_claimable, reached)
	_v16_text("PREMIUM", card.position + Vector2(315, 25), 9, V16_GOLD, true)
	_v41_draw_pass_reward(premium_reward, card.position + Vector2(374, 49), V16_GOLD, premium_claimable, reached and premium_unlocked)

	if not premium_unlocked:
		draw_rect(Rect2(card.position.x + 302, card.position.y + 39, 232, 46), Color(0, 0, 0, 0.34))
		_v16_text("LOCKED", card.position + Vector2(432, 67), 9, Color("8f829c"), true)

func _v41_draw_pass_reward(reward: Dictionary, center: Vector2, accent: Color, claimable: bool, reached: bool) -> void:
	var label := String(reward.get("label", "COINS"))
	var coins := int(reward.get("coins", 0))
	var shards := int(reward.get("shards", 0))
	if label.contains("CACHE"):
		_v18_reward_chest(center, 0.24)
	else:
		_v16_medallion(center, 18, accent, 11)
	_v16_text("%d C" % coins, center + Vector2(28, -3), 10, V17_IVORY, true)
	if shards > 0:
		_v38_diamond(center + Vector2(35, 17), 5.0, Color(V16_PURPLE_HI, 0.95))
		_v16_text("%d S" % shards, center + Vector2(46, 21), 9, V16_PURPLE_HI, true)
	if claimable:
		draw_arc(center, 25.0, elapsed * 0.8, elapsed * 0.8 + TAU, 32, Color(accent, 0.64), 2.0)
	elif reached:
		draw_circle(center + Vector2(-18, 19), 4.0, V16_GREEN)

# -----------------------------------------------------------------------------
# VAULT — inventory stays information-dense, but actions are grouped into a real
# item/workshop panel. The existing V8/V31 rectangles remain the interaction map,
# so no save/economy logic is duplicated here.
# -----------------------------------------------------------------------------

func draw_vault_screen() -> void:
	_v16_header("VAULT", "Compare, equip and refine your tower gear", V16_GOLD, 10, "arcane")
	var p := _v38_primary()
	var bonuses: Dictionary = loot.equipped_bonuses()
	var info := Rect2(22, 214, 676, 72)
	_v16_frame(info, V16_GOLD, Color("050a12"), 0.15)
	_v16_medallion(Vector2(62, 250), 23, p, 10)
	_v16_text("SOUL SHARDS  %d" % int(loot.shards), Vector2(98, 257), 16, C_CYAN, true)
	draw_string(v16_body_font, Vector2(340, 257), "DMG +%.1f%%   HP +%d   CRIT +%.1f%%" % [float(bonuses.get("damage_pct", 0.0)) * 100.0, int(round(float(bonuses.get("hp", 0.0)))), float(bonuses.get("crit_pct", 0.0)) * 100.0], HORIZONTAL_ALIGNMENT_RIGHT, 330, 12, V17_IVORY)

	_v16_button(V8_FILTER, "FILTER: %s" % String(V8_FILTERS[vault_filter_index]).to_upper(), V16_PURPLE, 12)
	_v16_button(V8_SORT, "SORT: %s" % String(V8_SORTS[vault_sort_index]).to_upper(), V16_BLUE, 12)
	var selected: Dictionary = _selected_vault_item_v08()
	var lock_label := "LOCK ITEM"
	var lock_color := Color("666a79")
	if not selected.is_empty():
		lock_label = "UNLOCK" if loot.is_locked(selected) else "LOCK"
		lock_color = C_CYAN if loot.is_locked(selected) else V16_GOLD
	_v16_button(V8_LOCK, lock_label, lock_color, 12, -1, not selected.is_empty())

	var visible: Array[int] = _visible_vault_indices()
	var first := vault_page * V8_PAGE_SIZE
	for local_index in range(V8_PAGE_SIZE):
		var page_pos := first + local_index
		if page_pos >= visible.size():
			break
		var item: Dictionary = loot.inventory[int(visible[page_pos])]
		_v19_vault_item(item, local_index, String(item.get("id", "")) == selected_vault_id)

	_v41_draw_vault_comparison(selected)
	_v41_draw_vault_action_panel(selected)
	_v16_button(META_BACK, "‹  BACK", V16_PURPLE, 17)
	_draw_notice(1117)

func _v41_draw_vault_comparison(selected: Dictionary) -> void:
	var panel := Rect2(54, 760, 612, 104)
	if selected.is_empty():
		_v16_frame(panel, Color("596078"), Color("060a12"), 0.06)
		_v16_medallion(Vector2(102, panel.get_center().y), 22, V16_PURPLE, 10)
		_v16_text("SELECT AN ITEM", Vector2(142, 806), 16, V16_MUTED, true)
		_v16_text("Tap gear above to compare and unlock its actions", Vector2(142, 832), 10, Color(V16_MUTED, 0.80))
		return

	var rarity := String(selected.get("rarity", "COMMON"))
	var accent := rarity_color(rarity)
	var delta := int(loot.comparison_delta(selected))
	var slot := String(selected.get("slot", ""))
	var equipped_item: Dictionary = loot.equipped_item_for_slot(slot)
	_v16_frame(panel, accent, Color(accent, 0.045), 0.13)
	_v16_medallion(Vector2(101, panel.get_center().y), 25, accent, 6 if slot == "weapon" else (8 if slot == "armor" else 10))
	_v16_text(String(selected.get("name", "ITEM")), Vector2(142, 798), 18, V17_IVORY, true)
	_v16_text("%s  •  SCORE %d  •  %s" % [rarity, int(loot.item_score(selected)), loot.stat_line(selected)], Vector2(142, 824), 10, accent)
	var compare_label := "EMPTY SLOT  +%d" % int(loot.item_score(selected)) if equipped_item.is_empty() else ("+%d VS EQUIPPED" % delta if delta >= 0 else "%d VS EQUIPPED" % delta)
	var compare_color := V16_GREEN if delta >= 0 else V16_ORANGE
	draw_string(v16_title_font, Vector2(438, 812), compare_label, HORIZONTAL_ALIGNMENT_CENTER, 202, 12, compare_color)
	var tags := String(loot.trait_line(selected))
	if tags != "":
		_v16_text(tags, Vector2(142, 848), 9, V16_PURPLE_HI, true)

func _v41_draw_vault_action_panel(selected: Dictionary) -> void:
	var workshop := Rect2(42, 874, 636, 254)
	_v16_frame(workshop, _v38_primary(), Color("040812"), 0.09)

	# Immediate item actions + pager.
	var has_item := not selected.is_empty()
	var equipped := has_item and bool(loot.is_equipped(selected))
	var can_dismantle := has_item and not equipped and not bool(loot.is_locked(selected))
	_v16_button(V8_EQUIP, "EQUIPPED" if equipped else "EQUIP", V16_GREEN if equipped else V16_BLUE, 12, 8, has_item and not equipped)
	_v16_button(V8_DISMANTLE, "DISMANTLE", Color("777b89"), 11, 7, can_dismantle)
	_v16_button(V8_PREV, "‹", Color("555b6b"), 20, -1, vault_page > 0)
	_v16_button(V8_NEXT, "›", V16_PURPLE, 20, -1, vault_page < _vault_max_page())

	# Crafting is one visually unified workshop rail rather than three unrelated
	# buttons floating beneath the inventory.
	_v16_text("WORKSHOP", Vector2(58, 958), 10, V16_GOLD, true)
	var craft_ready := int(loot.shards) >= int(loot.craft_cost())
	_v16_button(V8_CRAFT_WEAPON, "WEAPON", V16_ORANGE, 10, 6, craft_ready)
	_v16_button(V8_CRAFT_ARMOR, "ARMOR", V16_BLUE, 10, 8, craft_ready)
	_v16_button(V8_CRAFT_RELIC, "RELIC", V16_PURPLE, 10, 10, craft_ready)
	_v16_center("CRAFT %d SHARDS  •  RARE+" % int(loot.craft_cost()), 1032, 9, Color(V16_MUTED, 0.86))

	# Item progression only lights up when the selected piece can actually use it.
	var enhance_label := "ENHANCE"
	var enchant_label := "ENCHANT"
	var awaken_label := "AWAKEN"
	var can_enhance := false
	var can_enchant := false
	var can_awaken := false
	if has_item:
		enhance_label = "ENHANCE %d" % int(loot.enhance_cost(selected))
		enchant_label = "ENCHANT %d" % int(loot.enchant_cost(selected))
		awaken_label = "AWAKEN %d" % int(loot.awaken_cost(selected))
		can_enhance = int(selected.get("enhance_level", 0)) < int(loot.max_enhance_level(selected)) and int(loot.shards) >= int(loot.enhance_cost(selected))
		can_enchant = int(selected.get("rarity_index", 0)) >= 2 and int(loot.shards) >= int(loot.enchant_cost(selected))
		can_awaken = bool(loot.can_awaken(selected)) and int(loot.shards) >= int(loot.awaken_cost(selected))
	_v16_text("ITEM PROGRESSION", Vector2(58, 1041), 10, V16_PURPLE_HI, true)
	_v16_button(V31_ENHANCE, enhance_label, V16_GREEN if can_enhance else Color("55596a"), 10, -1, can_enhance)
	_v16_button(V31_ENCHANT, enchant_label, V16_PURPLE if can_enchant else Color("55596a"), 10, -1, can_enchant)
	_v16_button(V31_AWAKEN, awaken_label, V16_GOLD if can_awaken else Color("55596a"), 10, -1, can_awaken)

func _v41_progression_ui_ready() -> bool:
	return has_method("_v41_draw_mastery_branch") and has_method("_v41_draw_pass_level") and has_method("_v41_draw_vault_action_panel")
