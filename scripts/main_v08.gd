extends "res://scripts/main_v07.gd"

const V8_FILTER := Rect2(54, 278, 188, 52)
const V8_SORT := Rect2(266, 278, 188, 52)
const V8_LOCK := Rect2(478, 278, 188, 52)
const V8_EQUIP := Rect2(54, 884, 188, 58)
const V8_DISMANTLE := Rect2(266, 884, 188, 58)
const V8_PREV := Rect2(478, 884, 84, 58)
const V8_NEXT := Rect2(582, 884, 84, 58)
const V8_CRAFT_WEAPON := Rect2(54, 962, 188, 58)
const V8_CRAFT_ARMOR := Rect2(266, 962, 188, 58)
const V8_CRAFT_RELIC := Rect2(478, 962, 188, 58)
const V8_PAGE_SIZE := 4
const V8_FILTERS := ["all", "weapon", "armor", "relic"]
const V8_SORTS := ["rarity", "level", "score"]

var tex_combat_atlas: Texture2D
var player_anim_state: String = "idle"
var player_anim_timer: float = 0.0
var player_previous_pos: Vector2 = Vector2.ZERO
var vault_filter_index: int = 0
var vault_sort_index: int = 0
var selected_vault_id: String = ""

func _ready() -> void:
	super._ready()
	tex_combat_atlas = load("res://assets/art/combat_atlas.svg") as Texture2D
	player_previous_pos = player_pos
	var saved_sort: String = String(loot.active_sort_mode)
	var found_sort: int = V8_SORTS.find(saved_sort)
	vault_sort_index = found_sort if found_sort >= 0 else 0

func _process(delta: float) -> void:
	var before: Vector2 = player_pos
	player_anim_timer = maxf(0.0, player_anim_timer - delta)
	super._process(delta)
	if state == State.RUNNING and player_anim_timer <= 0.0:
		player_anim_state = "move" if player_pos.distance_to(before) > 0.35 else "idle"
	elif state != State.RUNNING and player_anim_timer <= 0.0:
		player_anim_state = "idle"
	player_previous_pos = player_pos

func fire_auto_attack() -> void:
	var before: int = player_shots.size()
	super.fire_auto_attack()
	if player_shots.size() > before:
		player_anim_state = "attack"
		player_anim_timer = 0.20

func damage_player(raw_damage: float, source: Vector2) -> void:
	super.damage_player(raw_damage, source)
	player_anim_state = "hit"
	player_anim_timer = 0.24

func use_skill() -> void:
	var ready: bool = state == State.RUNNING and float(run.skill_cd) <= 0.0
	super.use_skill()
	if ready:
		player_anim_state = "nova"
		player_anim_timer = 0.34

func die() -> void:
	player_anim_state = "death"
	player_anim_timer = 0.80
	super.die()

func apply_damage_to_enemy(index: int, amount: float, crit: bool, hit_pos: Vector2) -> void:
	super.apply_damage_to_enemy(index, amount, crit, hit_pos)
	if index >= 0 and index < enemies.size():
		var e: Dictionary = enemies[index]
		e["anim_hit"] = 0.18
		enemies[index] = e

func update_enemies(delta: float) -> void:
	super.update_enemies(delta)
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		e["anim_hit"] = maxf(0.0, float(e.get("anim_hit", 0.0)) - delta)
		enemies[i] = e

func remove_dead() -> void:
	var dying: Array[Dictionary] = []
	for e in enemies:
		if float(e["hp"]) <= 0.0:
			dying.append(e.duplicate(true))
	super.remove_dead()
	for e in dying:
		effects.append({
			"type":"actor_death", "pos":e["pos"], "age":0.0, "dur":0.46,
			"color":Color.WHITE, "kind":String(e["type"]),
			"variant":String(e.get("boss_variant", "warden")),
			"size":maxf(62.0, float(e.get("radius", 22.0)) * 2.7)
		})

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	if tex_combat_atlas == null:
		super.draw_wanderer(pos, scale, combat)
		return
	var state_name: String = player_anim_state if combat else "idle"
	var frame: int = _anim_frame(state_name)
	if state_name == "move" and int(elapsed * 9.0) % 2 == 0:
		frame = 0
	var size: Vector2 = Vector2(92.0, 92.0) * scale
	var bob: float = sin(elapsed * (7.0 if combat else 2.5)) * (1.8 if combat else 1.0)
	var rect := Rect2(pos.x - size.x * 0.5, pos.y - size.y * 0.58 + bob, size.x, size.y)
	_draw_atlas_region(0, frame, rect, Color.WHITE)
	if state_name == "nova":
		draw_circle(pos, 42.0 * scale, Color(C_CYAN, 0.10))
		draw_arc(pos, 43.0 * scale, elapsed * 2.2, elapsed * 2.2 + TAU, 36, C_CYAN, 3.0 * scale)
	elif combat and state_name == "attack":
		draw_arc(pos, 38.0 * scale, -0.8, 0.65, 20, Color(C_GOLD, 0.45), 4.0 * scale)

func draw_enemy(e: Dictionary) -> void:
	if tex_combat_atlas == null:
		super.draw_enemy(e)
		return
	var kind: String = String(e["type"])
	var variant: String = String(e.get("boss_variant", "warden"))
	var row: int = _actor_row(kind, variant)
	if row < 0:
		super.draw_enemy(e)
		return
	var p: Vector2 = e["pos"]
	var radius: float = float(e["radius"])
	var state_name: String = _enemy_anim_state(e)
	var frame: int = _anim_frame(state_name)
	if state_name == "move" and int(elapsed * (10.0 if kind == "bat" else 7.0) + float(e.get("phase", 0.0))) % 2 == 0:
		frame = 0
	var bob: float = sin(elapsed * (9.5 if kind == "bat" else 4.4) + float(e.get("phase", 0.0))) * (5.0 if kind == "bat" else 1.8)
	var size_px: float = maxf(62.0, radius * 2.75)
	if kind == "warden":
		size_px = radius * 2.65
	var rect := Rect2(p.x - size_px * 0.5, p.y - size_px * 0.61 + bob, size_px, size_px)
	var modulate: Color = Color.WHITE
	if kind == "ghoul" and float(e.get("rage", 0.0)) > 0.0:
		modulate = Color(1.0, 0.60, 0.60, 1.0)
	if bool(e.get("elite", false)):
		modulate = modulate.lerp(C_GOLD, 0.18)
	_draw_atlas_region(row, frame, rect, modulate)
	if bool(e.get("elite", false)):
		draw_arc(p, radius + 12.0, elapsed * 0.9, elapsed * 0.9 + TAU, 36, C_GOLD, 3.0)
		draw_string(font, p + Vector2(-40, -radius - 30), "ELITE", HORIZONTAL_ALIGNMENT_CENTER, 80, 12, C_GOLD)
	if kind == "warden" and bool(e.get("phase2", false)):
		draw_arc(p, radius + 13.0, elapsed * 1.1, elapsed * 1.1 + TAU, 42, C_CYAN if variant == "crypt_keeper" else C_RED, 4.0)
	var ratio: float = clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
	var width: float = radius * 2.0
	draw_rect(Rect2(p.x - radius, p.y - radius - 18, width, 7), Color("381726"))
	draw_rect(Rect2(p.x - radius, p.y - radius - 18, width * ratio, 7), C_RED)

func draw_effect(fx: Dictionary) -> void:
	super.draw_effect(fx)
	if String(fx.get("type", "")) != "actor_death" or tex_combat_atlas == null:
		return
	var kind: String = String(fx.get("kind", ""))
	var variant: String = String(fx.get("variant", "warden"))
	var row: int = _actor_row(kind, variant)
	if row < 0:
		return
	var t: float = clampf(float(fx["age"]) / float(fx["dur"]), 0.0, 1.0)
	var size_px: float = float(fx.get("size", 72.0)) * (1.0 - t * 0.15)
	var p: Vector2 = fx["pos"] + Vector2(0, t * 12.0)
	var rect := Rect2(p.x - size_px * 0.5, p.y - size_px * 0.58, size_px, size_px)
	_draw_atlas_region(row, 4, rect, Color(1.0, 1.0, 1.0, 1.0 - t))

func draw_game_over() -> void:
	super.draw_game_over()
	if tex_combat_atlas != null:
		var rect := Rect2(310, 695, 100, 100)
		_draw_atlas_region(0, 4, rect, Color(1.0, 1.0, 1.0, 0.82))

func _enemy_anim_state(e: Dictionary) -> String:
	if float(e.get("anim_hit", 0.0)) > 0.0:
		return "hit"
	var kind: String = String(e["type"])
	if kind == "warden" and float(e.get("cast_timer", 0.0)) > 0.0:
		return "attack"
	if kind == "skeleton" and float(e.get("attack_cd", 0.0)) > 1.25:
		return "attack"
	if kind == "necromancer" and float(e.get("attack_cd", 0.0)) > 1.15:
		return "attack"
	if float(e.get("touch_cd", 0.0)) > 0.44:
		return "attack"
	return "move"

func _anim_frame(state_name: String) -> int:
	match state_name:
		"move": return 1
		"attack", "nova": return 2
		"hit": return 3
		"death": return 4
	return 0

func _actor_row(kind: String, variant: String = "warden") -> int:
	match kind:
		"goblin": return 1
		"bat": return 2
		"skeleton": return 3
		"ghoul": return 4
		"necromancer": return 5
		"warden": return 7 if variant == "crypt_keeper" else 6
	return -1

func _draw_atlas_region(row: int, frame: int, rect: Rect2, modulate: Color) -> void:
	var source := Rect2(float(frame * 100), float(row * 100), 100.0, 100.0)
	draw_texture_rect_region(tex_combat_atlas, rect, source, modulate)

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if not pressed:
		super.pointer(pos, pressed, id)
		return
	if state != State.VAULT:
		super.pointer(pos, pressed, id)
		return
	if META_BACK.has_point(pos):
		selected_vault_id = ""
		state = State.HOME
		_audio("menu")
		return
	if V8_FILTER.has_point(pos):
		vault_filter_index = (vault_filter_index + 1) % V8_FILTERS.size()
		vault_page = 0
		selected_vault_id = ""
		_audio("menu")
		return
	if V8_SORT.has_point(pos):
		vault_sort_index = (vault_sort_index + 1) % V8_SORTS.size()
		loot.sort_inventory(String(V8_SORTS[vault_sort_index]))
		vault_page = 0
		selected_vault_id = ""
		_audio("menu")
		return
	if V8_LOCK.has_point(pos):
		_toggle_selected_lock()
		return
	if V8_PREV.has_point(pos):
		vault_page = maxi(0, vault_page - 1)
		return
	if V8_NEXT.has_point(pos):
		var max_page: int = _vault_max_page()
		vault_page = mini(max_page, vault_page + 1)
		return
	var visible: Array[int] = _visible_vault_indices()
	for local_index in range(V8_PAGE_SIZE):
		var page_pos: int = vault_page * V8_PAGE_SIZE + local_index
		if page_pos >= visible.size():
			break
		if vault_v08_item_rect(local_index).has_point(pos):
			var global_index: int = int(visible[page_pos])
			selected_vault_id = String(loot.inventory[global_index].get("id", ""))
			_audio("menu")
			return
	if V8_EQUIP.has_point(pos):
		_equip_selected_v08()
		return
	if V8_DISMANTLE.has_point(pos):
		_dismantle_selected_v08()
		return
	if V8_CRAFT_WEAPON.has_point(pos):
		_craft_slot_v08("weapon")
		return
	if V8_CRAFT_ARMOR.has_point(pos):
		_craft_slot_v08("armor")
		return
	if V8_CRAFT_RELIC.has_point(pos):
		_craft_slot_v08("relic")
		return

func _visible_vault_indices() -> Array[int]:
	return loot.matching_indices(String(V8_FILTERS[vault_filter_index]))

func _vault_max_page() -> int:
	var count: int = _visible_vault_indices().size()
	return maxi(0, int(ceil(float(count) / float(V8_PAGE_SIZE))) - 1)

func _selected_vault_index_v08() -> int:
	if selected_vault_id == "":
		return -1
	return int(loot.find_index_by_id(selected_vault_id))

func _selected_vault_item_v08() -> Dictionary:
	var index: int = _selected_vault_index_v08()
	if index < 0 or index >= loot.inventory.size():
		return {}
	return loot.inventory[index]

func _equip_selected_v08() -> void:
	var index: int = _selected_vault_index_v08()
	if index < 0:
		_set_vault_notice("SELECT AN ITEM FIRST", C_MUTED)
		return
	if loot.equip_index(index):
		_set_vault_notice("EQUIPPED %s" % String(loot.inventory[index]["name"]), C_GREEN)
		_audio("menu")

func _toggle_selected_lock() -> void:
	var index: int = _selected_vault_index_v08()
	if index < 0:
		_set_vault_notice("SELECT AN ITEM FIRST", C_MUTED)
		return
	var locked: bool = bool(loot.toggle_lock_index(index))
	_set_vault_notice("ITEM LOCKED" if locked else "ITEM UNLOCKED", C_CYAN if locked else C_MUTED)
	_audio("menu")

func _dismantle_selected_v08() -> void:
	var index: int = _selected_vault_index_v08()
	if index < 0:
		_set_vault_notice("SELECT AN ITEM FIRST", C_MUTED)
		return
	var item: Dictionary = loot.inventory[index]
	if loot.is_equipped(item):
		_set_vault_notice("EQUIPPED ITEMS CANNOT BE DISMANTLED", C_RED)
		return
	if loot.is_locked(item):
		_set_vault_notice("UNLOCK ITEM BEFORE DISMANTLING", C_RED)
		return
	var gained: int = int(loot.dismantle_index(index))
	if gained <= 0:
		_set_vault_notice("DISMANTLE FAILED", C_RED)
		return
	selected_vault_id = ""
	vault_page = mini(vault_page, _vault_max_page())
	_set_vault_notice("DISMANTLED  +%d SOUL SHARDS" % gained, C_CYAN)
	_audio("claim")

func _craft_slot_v08(slot: String) -> void:
	var floor_level: int = maxi(5, int(meta.best_floor))
	var crafted: Dictionary = loot.craft_item(slot, floor_level, rng)
	if crafted.is_empty():
		_set_vault_notice("NEED %d SOUL SHARDS" % int(loot.craft_cost()), C_RED)
		return
	vault_filter_index = 0
	vault_page = 0
	selected_vault_id = String(crafted["id"])
	_set_vault_notice("CRAFTED %s %s" % [String(crafted["rarity"]), String(crafted["name"])], rarity_color(String(crafted["rarity"])))
	_audio("loot")

func draw_vault_screen() -> void:
	draw_meta_header("VAULT + FORGE", "Compare, lock, equip, dismantle and craft gear", C_GOLD)
	var bonuses: Dictionary = loot.equipped_bonuses()
	panel(Rect2(48, 202, 624, 64), C_PANEL_2, C_GOLD)
	text("SOUL SHARDS  %d" % int(loot.shards), Vector2(66, 229), 16, C_CYAN)
	text("DMG +%.1f%%  HP +%d  CRIT +%.1f%%" % [float(bonuses["damage_pct"])*100.0, int(round(float(bonuses["hp"]))), float(bonuses["crit_pct"])*100.0], Vector2(310, 229), 13, C_TEXT)
	button(V8_FILTER, "FILTER: %s" % String(V8_FILTERS[vault_filter_index]).to_upper(), C_PURPLE, 13)
	button(V8_SORT, "SORT: %s" % String(V8_SORTS[vault_sort_index]).to_upper(), C_BLUE, 13)
	var selected: Dictionary = _selected_vault_item_v08()
	var lock_label: String = "LOCK ITEM"
	var lock_color: Color = C_MUTED
	if not selected.is_empty():
		lock_label = "UNLOCK" if loot.is_locked(selected) else "LOCK"
		lock_color = C_CYAN if loot.is_locked(selected) else C_GOLD
	button(V8_LOCK, lock_label, lock_color, 14)

	var visible: Array[int] = _visible_vault_indices()
	var first: int = vault_page * V8_PAGE_SIZE
	if visible.is_empty():
		draw_center("NO ITEMS IN THIS FILTER", 500, 25, C_TEXT)
	else:
		for local_index in range(V8_PAGE_SIZE):
			var page_pos: int = first + local_index
			if page_pos >= visible.size():
				break
			var global_index: int = int(visible[page_pos])
			var item: Dictionary = loot.inventory[global_index]
			var r: Rect2 = vault_v08_item_rect(local_index)
			var selected_now: bool = String(item.get("id", "")) == selected_vault_id
			var accent: Color = C_CYAN if selected_now else rarity_color(String(item["rarity"]))
			panel(r, C_PANEL, accent)
			text(String(item["name"]), r.position + Vector2(16, 27), 17, C_TEXT)
			text("%s • %s • Lv.%d • SCORE %d" % [String(item["rarity"]), String(item["slot"]).to_upper(), int(item["level"]), int(loot.item_score(item))], r.position + Vector2(16, 50), 11, accent)
			text(loot.stat_line(item), r.position + Vector2(16, 73), 13, C_MUTED)
			var tags: String = loot.trait_line(item)
			if loot.is_locked(item): tags = (tags + " • " if tags != "" else "") + "LOCKED"
			if tags != "": text(tags, r.position + Vector2(230, 73), 11, C_PURPLE if not loot.is_locked(item) else C_CYAN)
			var status: String = "EQUIPPED" if loot.is_equipped(item) else ("SELECTED" if selected_now else "TAP")
			text(status, r.position + Vector2(510, 48), 11, C_GREEN if loot.is_equipped(item) else C_GOLD)

	_draw_vault_comparison(selected)
	button(V8_EQUIP, "EQUIP", C_GREEN if not selected.is_empty() else C_MUTED, 15)
	var dismantle_label: String = "DISMANTLE"
	var dismantle_color: Color = C_MUTED
	if not selected.is_empty():
		dismantle_label = "DISMANTLE +%d" % int(loot.dismantle_value(selected))
		dismantle_color = C_MUTED if loot.is_locked(selected) or loot.is_equipped(selected) else C_RED
	button(V8_DISMANTLE, dismantle_label, dismantle_color, 13)
	button(V8_PREV, "<", C_PURPLE if vault_page > 0 else C_MUTED, 20)
	button(V8_NEXT, ">", C_PURPLE if vault_page < _vault_max_page() else C_MUTED, 20)
	var craft_color: Color = C_CYAN if int(loot.shards) >= int(loot.craft_cost()) else C_MUTED
	button(V8_CRAFT_WEAPON, "CRAFT WEAPON", craft_color, 13)
	button(V8_CRAFT_ARMOR, "CRAFT ARMOR", craft_color, 13)
	button(V8_CRAFT_RELIC, "CRAFT RELIC", craft_color, 13)
	draw_center("CRAFT %d SHARDS • GUARANTEED RARE+" % int(loot.craft_cost()), 1050, 13, C_MUTED)
	button(META_BACK, "BACK", C_PURPLE, 20)
	_draw_notice(1118)

func _draw_vault_comparison(selected: Dictionary) -> void:
	var r := Rect2(54, 748, 612, 116)
	panel(r, C_PANEL_2, C_BLUE if not selected.is_empty() else Color("3c4261"))
	if selected.is_empty():
		center_rect("SELECT AN ITEM TO COMPARE", r, 15, C_MUTED)
		return
	var equipped_item: Dictionary = loot.equipped_item_for_slot(String(selected["slot"]))
	var selected_score: int = int(loot.item_score(selected))
	var delta: int = int(loot.comparison_delta(selected))
	text("SELECTED", r.position + Vector2(18, 27), 12, C_CYAN)
	text("%s  •  %s  •  %d" % [String(selected["name"]), loot.stat_line(selected), selected_score], r.position + Vector2(18, 52), 13, C_TEXT)
	text("EQUIPPED", r.position + Vector2(18, 79), 12, C_GREEN)
	if equipped_item.is_empty():
		text("EMPTY SLOT", r.position + Vector2(110, 79), 13, C_MUTED)
	else:
		text("%s  •  %s  •  %d" % [String(equipped_item["name"]), loot.stat_line(equipped_item), int(loot.item_score(equipped_item))], r.position + Vector2(110, 79), 13, C_TEXT)
	var delta_text: String = "+%d" % delta if delta >= 0 else "%d" % delta
	text(delta_text, r.position + Vector2(525, 55), 18, C_GREEN if delta >= 0 else C_RED)

func vault_v08_item_rect(local_index: int) -> Rect2:
	return Rect2(54, 342 + local_index * 100, 612, 90)

func draw_home() -> void:
	super.draw_home()
	if home_overlay == "":
		panel(Rect2(452, 1104, 214, 38), Color("0b1025"), C_CYAN)
		center_rect("v0.8 ANIMATION + VAULT", Rect2(452, 1104, 214, 38), 10, C_TEXT)
