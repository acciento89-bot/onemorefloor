extends "res://scripts/main_v06.gd"

const TEX_WANDERER = preload("res://assets/art/wanderer.svg")
const TEX_GOBLIN = preload("res://assets/art/goblin.svg")
const TEX_BAT = preload("res://assets/art/bat.svg")
const TEX_SKELETON = preload("res://assets/art/skeleton.svg")
const TEX_GHOUL = preload("res://assets/art/ghoul.svg")
const TEX_NECROMANCER = preload("res://assets/art/necromancer.svg")
const TEX_WARDEN = preload("res://assets/art/warden.svg")
const TEX_KEEPER = preload("res://assets/art/crypt_keeper.svg")

const V7_EQUIP := Rect2(54, 916, 188, 58)
const V7_DISMANTLE := Rect2(266, 916, 188, 58)
const V7_PREV := Rect2(478, 916, 84, 58)
const V7_NEXT := Rect2(582, 916, 84, 58)
const V7_CRAFT_WEAPON := Rect2(54, 996, 188, 58)
const V7_CRAFT_ARMOR := Rect2(266, 996, 188, 58)
const V7_CRAFT_RELIC := Rect2(478, 996, 188, 58)
const VAULT_PAGE_SIZE := 5

var vault_page: int = 0
var selected_vault_index: int = -1

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	if TEX_WANDERER == null:
		super.draw_wanderer(pos, scale, combat)
		return
	var bob: float = sin(elapsed * (6.5 if combat else 2.8)) * (2.2 if combat else 1.5)
	var size := Vector2(88.0, 88.0) * scale
	var rect := Rect2(pos.x - size.x * 0.5, pos.y - size.y * 0.58 + bob, size.x, size.y)
	draw_texture_rect(rect, TEX_WANDERER, false)
	if combat:
		draw_arc(pos + Vector2(0, 10), 31.0 * scale, -0.55, 0.85, 18, Color(1.0, 0.75, 0.30, 0.32), 2.4 * scale)

func draw_enemy(e: Dictionary) -> void:
	var kind: String = String(e["type"])
	var variant: String = String(e.get("boss_variant", "warden"))
	var tex = _enemy_texture(kind, variant)
	if tex == null:
		super.draw_enemy(e)
		return
	var p: Vector2 = e["pos"]
	var radius: float = float(e["radius"])
	var bob_speed: float = 8.5 if kind == "bat" else 4.0
	var bob_amount: float = 5.5 if kind == "bat" else 2.0
	var bob: float = sin(elapsed * bob_speed + float(e.get("phase", 0.0))) * bob_amount
	var size_px: float = maxf(58.0, radius * 2.65)
	if kind == "warden":
		size_px = radius * 2.55
	var rect := Rect2(p.x - size_px * 0.5, p.y - size_px * 0.60 + bob, size_px, size_px)
	var modulate := Color.WHITE
	if kind == "ghoul" and float(e.get("rage", 0.0)) > 0.0:
		modulate = Color(1.0, 0.55, 0.55, 1.0)
	if bool(e.get("elite", false)):
		modulate = modulate.lerp(C_GOLD, 0.18)
	draw_texture_rect(rect, tex, false, modulate)
	if bool(e.get("elite", false)):
		_draw_elite_mark(e)
	if kind == "warden" and bool(e.get("phase2", false)):
		draw_arc(p, radius + 12.0, elapsed * 0.8, elapsed * 0.8 + TAU, 42, C_CYAN if variant == "crypt_keeper" else C_RED, 4.0)
	var ratio: float = clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
	var width: float = radius * 2.0
	draw_rect(Rect2(p.x - radius, p.y - radius - 18, width, 7), Color("381726"))
	draw_rect(Rect2(p.x - radius, p.y - radius - 18, width * ratio, 7), C_RED)

func _enemy_texture(kind: String, variant: String):
	match kind:
		"goblin": return TEX_GOBLIN
		"bat": return TEX_BAT
		"skeleton": return TEX_SKELETON
		"ghoul": return TEX_GHOUL
		"necromancer": return TEX_NECROMANCER
		"warden": return TEX_KEEPER if variant == "crypt_keeper" else TEX_WARDEN
	return null

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if not pressed:
		super.pointer(pos, pressed, id)
		return
	if state != State.VAULT:
		super.pointer(pos, pressed, id)
		return
	if META_BACK.has_point(pos):
		selected_vault_index = -1
		state = State.HOME
		_audio("menu")
		return
	if V7_PREV.has_point(pos):
		vault_page = maxi(0, vault_page - 1)
		selected_vault_index = -1
		return
	if V7_NEXT.has_point(pos):
		var max_page: int = maxi(0, int(ceil(float(loot.inventory.size()) / float(VAULT_PAGE_SIZE))) - 1)
		vault_page = mini(max_page, vault_page + 1)
		selected_vault_index = -1
		return
	for local_index in range(VAULT_PAGE_SIZE):
		var global_index: int = vault_page * VAULT_PAGE_SIZE + local_index
		if global_index >= loot.inventory.size():
			break
		if vault_v07_item_rect(local_index).has_point(pos):
			selected_vault_index = global_index
			_audio("menu")
			return
	if V7_EQUIP.has_point(pos):
		_equip_selected()
		return
	if V7_DISMANTLE.has_point(pos):
		_dismantle_selected()
		return
	if V7_CRAFT_WEAPON.has_point(pos):
		_craft_slot("weapon")
		return
	if V7_CRAFT_ARMOR.has_point(pos):
		_craft_slot("armor")
		return
	if V7_CRAFT_RELIC.has_point(pos):
		_craft_slot("relic")
		return

func _equip_selected() -> void:
	if selected_vault_index < 0 or selected_vault_index >= loot.inventory.size():
		_set_vault_notice("SELECT AN ITEM FIRST", C_MUTED)
		return
	if loot.equip_index(selected_vault_index):
		var item: Dictionary = loot.inventory[selected_vault_index]
		_set_vault_notice("EQUIPPED %s" % String(item["name"]), C_GREEN)
		_audio("menu")

func _dismantle_selected() -> void:
	if selected_vault_index < 0 or selected_vault_index >= loot.inventory.size():
		_set_vault_notice("SELECT AN ITEM FIRST", C_MUTED)
		return
	var item: Dictionary = loot.inventory[selected_vault_index]
	if loot.is_equipped(item):
		_set_vault_notice("EQUIPPED ITEMS CANNOT BE DISMANTLED", C_RED)
		return
	var gained: int = int(loot.dismantle_index(selected_vault_index))
	if gained <= 0:
		_set_vault_notice("DISMANTLE FAILED", C_RED)
		return
	selected_vault_index = -1
	var max_page: int = maxi(0, int(ceil(float(loot.inventory.size()) / float(VAULT_PAGE_SIZE))) - 1)
	vault_page = mini(vault_page, max_page)
	_set_vault_notice("DISMANTLED  +%d SOUL SHARDS" % gained, C_CYAN)
	_audio("claim")

func _craft_slot(slot: String) -> void:
	var floor_level: int = maxi(5, int(meta.best_floor))
	var crafted: Dictionary = loot.craft_item(slot, floor_level, rng)
	if crafted.is_empty():
		_set_vault_notice("NEED %d SOUL SHARDS" % int(loot.craft_cost()), C_RED)
		return
	vault_page = 0
	selected_vault_index = 0
	_set_vault_notice("CRAFTED %s %s" % [String(crafted["rarity"]), String(crafted["name"])], rarity_color(String(crafted["rarity"])))
	_audio("loot")

func _set_vault_notice(message: String, color: Color) -> void:
	loot_notice = message
	loot_notice_color = color
	loot_notice_time = 1.8

func draw_vault_screen() -> void:
	draw_meta_header("VAULT + FORGE", "Equip, dismantle and craft permanent gear", C_GOLD)
	var bonuses: Dictionary = loot.equipped_bonuses()
	panel(Rect2(48, 204, 624, 70), C_PANEL_2, C_GOLD)
	text("SOUL SHARDS  %d" % int(loot.shards), Vector2(66, 232), 17, C_CYAN)
	text("DMG +%.1f%%  HP +%d  CRIT +%.1f%%  COINS +%.1f%%" % [float(bonuses["damage_pct"])*100.0, int(round(float(bonuses["hp"]))), float(bonuses["crit_pct"])*100.0, float(bonuses["coin_pct"])*100.0], Vector2(66, 259), 14, C_TEXT)
	var first_index: int = vault_page * VAULT_PAGE_SIZE
	if loot.inventory.is_empty():
		draw_center("THE VAULT IS EMPTY", 470, 28, C_TEXT)
		draw_center("Defeat enemies or craft Rare+ gear below.", 516, 16, C_MUTED)
	else:
		for local_index in range(VAULT_PAGE_SIZE):
			var global_index: int = first_index + local_index
			if global_index >= loot.inventory.size():
				break
			var item: Dictionary = loot.inventory[global_index]
			var r: Rect2 = vault_v07_item_rect(local_index)
			var accent: Color = rarity_color(String(item["rarity"]))
			if global_index == selected_vault_index:
				accent = C_CYAN
			panel(r, C_PANEL, accent)
			text(String(item["name"]), r.position + Vector2(18, 28), 18, C_TEXT)
			text("%s • %s • Lv.%d" % [String(item["rarity"]), String(item["slot"]).to_upper(), int(item["level"])], r.position + Vector2(18, 51), 12, accent)
			text(loot.stat_line(item), r.position + Vector2(18, 75), 14, C_MUTED)
			var detail: String = loot.trait_line(item)
			if detail != "":
				text(detail, r.position + Vector2(250, 75), 12, C_PURPLE)
			var status: String = "EQUIPPED" if loot.is_equipped(item) else ("SELECTED" if global_index == selected_vault_index else "TAP")
			text(status, r.position + Vector2(500, 47), 12, C_GREEN if loot.is_equipped(item) else C_GOLD)
	button(V7_EQUIP, "EQUIP", C_GREEN if selected_vault_index >= 0 else C_MUTED, 16)
	var dismantle_label: String = "DISMANTLE"
	if selected_vault_index >= 0 and selected_vault_index < loot.inventory.size():
		dismantle_label = "DISMANTLE +%d" % int(loot.dismantle_value(loot.inventory[selected_vault_index]))
	button(V7_DISMANTLE, dismantle_label, C_RED if selected_vault_index >= 0 else C_MUTED, 14)
	button(V7_PREV, "<", C_PURPLE if vault_page > 0 else C_MUTED, 20)
	var max_page: int = maxi(0, int(ceil(float(loot.inventory.size()) / float(VAULT_PAGE_SIZE))) - 1)
	button(V7_NEXT, ">", C_PURPLE if vault_page < max_page else C_MUTED, 20)
	var craft_color: Color = C_CYAN if int(loot.shards) >= int(loot.craft_cost()) else C_MUTED
	button(V7_CRAFT_WEAPON, "CRAFT WEAPON", craft_color, 14)
	button(V7_CRAFT_ARMOR, "CRAFT ARMOR", craft_color, 14)
	button(V7_CRAFT_RELIC, "CRAFT RELIC", craft_color, 14)
	draw_center("CRAFT COST  %d SHARDS  •  GUARANTEED RARE+" % int(loot.craft_cost()), 1080, 14, C_MUTED)
	button(META_BACK, "BACK", C_PURPLE, 20)
	_draw_notice(1128)

func vault_v07_item_rect(local_index: int) -> Rect2:
	return Rect2(54, 292 + local_index * 120, 612, 104)

func draw_home() -> void:
	super.draw_home()
	if home_overlay == "":
		panel(Rect2(458, 1148, 206, 38), Color("0b1025"), C_CYAN)
		center_rect("v0.7 ASSET PIPELINE", Rect2(458, 1148, 206, 38), 11, C_TEXT)
