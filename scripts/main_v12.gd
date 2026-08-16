extends "res://scripts/main_v11.gd"

const V12_VERSION := "1.2.0-rc1"
const V12_GOLD := Color("e3ad48")
const V12_GOLD_LIGHT := Color("ffe293")
const V12_PURPLE := Color("9252dc")
const V12_IVORY := Color("efe7d7")
const V12_DARK := Color("070b14")
const V12_PANEL := Color("0c1320")

var tex_v12_environment: Texture2D
var tex_v12_icons: Texture2D
var tex_v12_actors: Texture2D

func _ready() -> void:
	super._ready()
	tex_v12_environment = load("res://assets/art/environment_production.svg") as Texture2D
	tex_v12_icons = load("res://assets/art/ui_icons_production.svg") as Texture2D
	tex_v12_actors = load("res://assets/art/actors_production.svg") as Texture2D
	queue_redraw()

# --- shared dark-fantasy skin -------------------------------------------------

func panel(r: Rect2, fill: Color, border: Color) -> void:
	draw_rect(r.grow(5.0), Color(0.0, 0.0, 0.0, 0.34))
	draw_rect(r, fill)
	draw_rect(r, Color(border, 0.94), false, 2.0)
	draw_rect(r.grow(-4.0), Color(border, 0.24), false, 1.0)
	draw_line(r.position + Vector2(7, 5), Vector2(r.end.x - 7, r.position.y + 5), Color(1, 1, 1, 0.07), 1.0)
	draw_line(Vector2(r.position.x + 7, r.end.y - 5), r.end - Vector2(7, 5), Color(0, 0, 0, 0.38), 2.0)
	_draw_v12_corners(r, border)

func button(r: Rect2, label: String, accent: Color, size: int) -> void:
	var fill: Color = Color(accent, 0.14) if accent != C_MUTED else Color("171b28")
	panel(r, fill, accent)
	draw_rect(r.grow(-7.0), Color(accent, 0.045))
	center_rect(label, r, size, V12_IVORY if accent != C_MUTED else C_MUTED)

func _draw_v12_corners(r: Rect2, c: Color) -> void:
	var points: Array[Vector2] = [r.position, Vector2(r.end.x, r.position.y), Vector2(r.position.x, r.end.y), r.end]
	for p: Vector2 in points:
		var sx: float = 1.0 if p.x == r.position.x else -1.0
		var sy: float = 1.0 if p.y == r.position.y else -1.0
		draw_line(p + Vector2(sx * 2.0, sy * 2.0), p + Vector2(sx * 9.0, sy * 2.0), Color(c, 0.85), 2.0)
		draw_line(p + Vector2(sx * 2.0, sy * 2.0), p + Vector2(sx * 2.0, sy * 9.0), Color(c, 0.85), 2.0)

func _v12_title(label: String, y: float, size: int, accent: Color = V12_GOLD) -> void:
	draw_string(font, Vector2(40, y + 3), label, HORIZONTAL_ALIGNMENT_CENTER, 640, size, Color(0, 0, 0, 0.72))
	draw_string(font, Vector2(40, y), label, HORIZONTAL_ALIGNMENT_CENTER, 640, size, V12_IVORY)
	draw_string(font, Vector2(40, y - 1), label, HORIZONTAL_ALIGNMENT_CENTER, 640, size, accent)
	_v12_divider(y + 18.0, accent)

func _v12_divider(y: float, c: Color) -> void:
	draw_line(Vector2(160, y), Vector2(334, y), Color(c, 0.58), 2.0)
	draw_line(Vector2(386, y), Vector2(560, y), Color(c, 0.58), 2.0)
	var p: Vector2 = Vector2(360, y)
	draw_colored_polygon(PackedVector2Array([p + Vector2(0,-9), p + Vector2(9,0), p + Vector2(0,9), p + Vector2(-9,0)]), Color(c, 0.72))
	draw_colored_polygon(PackedVector2Array([p + Vector2(0,-4), p + Vector2(4,0), p + Vector2(0,4), p + Vector2(-4,0)]), V12_IVORY)

func _v12_icon(index: int, r: Rect2, modulate: Color = Color.WHITE) -> void:
	if tex_v12_icons == null:
		draw_circle(r.get_center(), minf(r.size.x, r.size.y) * 0.34, Color(modulate, 0.55))
		return
	var col: int = index % 4
	var row: int = index / 4
	var source: Rect2 = Rect2(float(col * 128), float(row * 128), 128.0, 128.0)
	draw_texture_rect_region(tex_v12_icons, r, source, modulate)

func _v12_actor(index: int, r: Rect2, modulate: Color = Color.WHITE) -> void:
	if tex_v12_actors == null:
		return
	var col: int = index % 4
	var row: int = index / 4
	var source: Rect2 = Rect2(float(col * 128), float(row * 192), 128.0, 192.0)
	draw_texture_rect_region(tex_v12_actors, r, source, modulate)

func _v12_coin_badge(r: Rect2, amount: int) -> void:
	panel(r, Color("0b101c"), V12_GOLD)
	_v12_icon(11, Rect2(r.position.x + 7, r.position.y + 6, 42, 42))
	text(str(amount), Vector2(r.position.x + 52, r.position.y + 36), 20, V12_GOLD_LIGHT)

func _v12_background(accent: Color = V12_PURPLE) -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("040811"))
	for i: int in range(8):
		var radius: float = 340.0 - float(i) * 34.0
		draw_circle(Vector2(360, 350), radius, Color(accent, 0.012 + float(i) * 0.004))
	for y: int in range(120, 1140, 72):
		draw_rect(Rect2(0, y, 26, 62), Color("111522"))
		draw_rect(Rect2(694, y, 26, 62), Color("111522"))
	for i: int in range(18):
		var x: float = 34.0 + fmod(float(i * 107), 652.0)
		var y: float = 76.0 + fmod(float(i * i * 43), 1000.0)
		draw_circle(Vector2(x, y), 1.2 + float(i % 2), Color(accent, 0.12 + 0.05 * sin(elapsed + float(i))))

func _v12_meta_header(title: String, subtitle: String, accent: Color, icon_index: int) -> void:
	_v12_background(accent)
	_v12_icon(icon_index, Rect2(326, 32, 68, 68))
	_v12_title(title, 132, 45, accent)
	draw_string(font, Vector2(70, 178), subtitle, HORIZONTAL_ALIGNMENT_CENTER, 580, 17, C_MUTED)
	_v12_coin_badge(Rect2(520, 45, 160, 58), int(meta.coins))
	button(META_BACK, "‹  BACK", C_PURPLE, 18)
	if meta_notice_time > 0.0:
		draw_string(font, Vector2(70, 1088), meta_notice, HORIZONTAL_ALIGNMENT_CENTER, 580, 17, C_GREEN if meta_notice.begins_with("UPGRADE") else C_RED)

# --- home --------------------------------------------------------------------

func draw_home() -> void:
	if home_overlay == "missions":
		draw_missions_screen()
		return
	if home_overlay == "pass":
		draw_pass_screen()
		return
	_v12_home_background()
	panel(Rect2(36, 44, 165, 82), Color("0b101d"), V12_PURPLE)
	text("BEST FLOOR", Vector2(54, 75), 12, C_MUTED)
	text("%02d" % int(meta.best_floor), Vector2(54, 112), 31, V12_IVORY)
	_v12_coin_badge(Rect2(516, 44, 165, 62), int(meta.coins))
	_v12_title("ONE MORE", 184, 44, V12_PURPLE)
	draw_string(font, Vector2(66, 257), "FLOOR", HORIZONTAL_ALIGNMENT_CENTER, 588, 74, V12_GOLD)
	draw_string(font, Vector2(70, 291), "CLIMB  •  LOOT  •  RISK IT ALL", HORIZONTAL_ALIGNMENT_CENTER, 580, 13, C_MUTED)
	_v12_home_tower(Vector2(360, 536))
	_v12_actor(0, Rect2(305, 610, 110, 165))
	button(PLAY, "PLAY", V12_GOLD, 31)
	button(MISSIONS_BTN, "MISSIONS", C_GREEN, 17)
	button(PASS_BTN, "TOWER PASS", V12_PURPLE, 17)
	_v12_home_tab(HERO_TAB, "HERO", 0, C_BLUE)
	_v12_home_tab(FORGE_TAB, "FORGE", 7, C_ORANGE)
	_v12_home_tab(TALENTS_TAB, "TALENTS", 1, C_PURPLE)
	_v12_home_tab(VAULT_TAB, "VAULT", 10, C_GOLD)
	panel(Rect2(38, 1160, 644, 68), Color("080e1b"), Color("343d63"))
	text("POWER  %d" % int(meta.power_score()), Vector2(62, 1200), 16, V12_GOLD_LIGHT)
	draw_string(font, Vector2(330, 1200), "KAMILUNAVO GAMES", HORIZONTAL_ALIGNMENT_RIGHT, 322, 12, C_MUTED)
	if home_overlay == "":
		button(V10_SETTINGS_HOME, "SETTINGS", C_BLUE, 13)
	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step in [0, 1]:
		_draw_tutorial_overlay()

func _v12_home_background() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("040812"))
	draw_colored_polygon(PackedVector2Array([Vector2(0,660),Vector2(0,510),Vector2(95,436),Vector2(172,518),Vector2(270,420),Vector2(350,522),Vector2(448,398),Vector2(540,510),Vector2(630,430),Vector2(720,500),Vector2(720,660)]), Color("080c18"))
	draw_circle(Vector2(360, 480), 205, Color("11132c"))
	draw_arc(Vector2(360,480), 194, -2.7, 0.25, 72, Color(V12_PURPLE,0.25), 3)
	draw_arc(Vector2(360,480), 184, 0.5, 2.8, 72, Color(C_BLUE,0.09), 2)
	for i: int in range(22):
		var x: float = 30.0 + fmod(float(i * 137), 660.0)
		var y: float = 125.0 + fmod(float(i * i * 57), 480.0)
		draw_circle(Vector2(x,y), 1.0 + float(i % 3) * 0.45, Color(0.75,0.75,1.0,0.13))

func _v12_home_tower(c: Vector2) -> void:
	draw_circle(c + Vector2(0,-55), 155, Color(V12_PURPLE,0.035))
	for side_value: float in [-1.0, 1.0]:
		var x: float = c.x + side_value * 100.0
		draw_rect(Rect2(x-30,c.y-90,60,150),Color("121827"))
		draw_rect(Rect2(x-35,c.y-105,70,18),Color("303448"))
		draw_colored_polygon(PackedVector2Array([Vector2(x-34,c.y-105),Vector2(x,c.y-150),Vector2(x+34,c.y-105)]),Color("20253a"))
		draw_rect(Rect2(x-6,c.y-62,12,25),Color("d98b32"))
	draw_rect(Rect2(c.x-72,c.y-180,144,250),Color("111827"))
	draw_rect(Rect2(c.x-82,c.y-195,164,22),Color("313448"))
	draw_colored_polygon(PackedVector2Array([Vector2(c.x-82,c.y-194),Vector2(c.x,c.y-278),Vector2(c.x+82,c.y-194)]),Color("22263c"))
	for row: int in range(3):
		for col: int in range(2):
			var wx: float = c.x - 30.0 + float(col) * 60.0
			var wy: float = c.y - 120.0 + float(row) * 58.0
			draw_rect(Rect2(wx-6,wy-11,12,24),Color("f0a13b"))
			draw_rect(Rect2(wx-3,wy-8,6,18),Color("ffd77b"))
	var crown: Vector2 = Vector2(c.x,c.y-205)
	draw_colored_polygon(PackedVector2Array([crown+Vector2(0,-26),crown+Vector2(15,-3),crown+Vector2(7,20),crown+Vector2(0,28),crown+Vector2(-8,20),crown+Vector2(-15,-3)]),Color("8a46d5"))
	draw_line(crown+Vector2(0,-24),crown+Vector2(0,25),Color("e6b4ff"),2)

func _v12_home_tab(r: Rect2, label: String, icon_index: int, accent: Color) -> void:
	panel(r, Color("0d1424"), accent)
	_v12_icon(icon_index, Rect2(r.get_center().x-26,r.position.y+7,52,52))
	draw_string(font, Vector2(r.position.x+5,r.position.y+83), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x-10, 14, V12_IVORY)

# --- Hero / Forge / Talents ---------------------------------------------------

func draw_hero_screen() -> void:
	_v12_meta_header("HERO", "Permanent Wanderer training", V12_PURPLE, 0)
	draw_circle(Vector2(360,365), 178, Color(V12_PURPLE,0.07))
	draw_arc(Vector2(360,365), 154, elapsed*0.12, elapsed*0.12+TAU, 56, Color(V12_PURPLE,0.22), 2)
	_v12_actor(0, Rect2(282, 238, 156, 234))
	panel(Rect2(78,530,564,220),V12_PANEL,C_BLUE)
	draw_string(font,Vector2(102,584),"WANDERER  •  LEVEL %d" % int(meta.hero_level),HORIZONTAL_ALIGNMENT_CENTER,516,28,V12_IVORY)
	_v12_stat_line(Rect2(125,615,470,38),0,"Base HP bonus  +%d" % int(meta.hp_bonus()),C_GREEN)
	_v12_stat_line(Rect2(125,662,470,38),6,"Combined damage  x%.2f" % float(meta.damage_multiplier()),V12_GOLD)
	_v12_stat_line(Rect2(125,709,470,30),14,"Power  %d" % int(meta.power_score()),C_MUTED)
	button(META_BUY,"TRAIN  %d" % int(meta.hero_cost()),V12_PURPLE if meta.coins >= meta.hero_cost() else C_MUTED,21)
	draw_string(font,Vector2(70,975),"Each Hero level: +5 HP and +3.5% damage",HORIZONTAL_ALIGNMENT_CENTER,580,15,C_MUTED)

func draw_forge_screen() -> void:
	_v12_meta_header("FORGE", "Temper the Wanderer's weapon", C_ORANGE, 7)
	_v12_icon(7, Rect2(285,280,150,150))
	_v12_icon(6, Rect2(315,350,90,90))
	panel(Rect2(78,530,564,220),V12_PANEL,C_ORANGE)
	draw_string(font,Vector2(100,590),"FORGE LEVEL %d" % int(meta.forge_level),HORIZONTAL_ALIGNMENT_CENTER,520,29,V12_IVORY)
	draw_string(font,Vector2(100,645),"Weapon multiplier contribution",HORIZONTAL_ALIGNMENT_CENTER,520,16,C_MUTED)
	draw_string(font,Vector2(100,705),"+%.1f%% DAMAGE" % (float(meta.forge_level)*8.5),HORIZONTAL_ALIGNMENT_CENTER,520,31,V12_GOLD_LIGHT)
	button(META_BUY,"TEMPER  %d" % int(meta.forge_cost()),C_ORANGE if meta.coins >= meta.forge_cost() else C_MUTED,21)
	draw_string(font,Vector2(70,975),"Every Forge level adds +8.5% permanent damage.",HORIZONTAL_ALIGNMENT_CENTER,580,15,C_MUTED)

func draw_talents_screen() -> void:
	_v12_meta_header("TALENTS", "Permanent passive bonuses", V12_PURPLE, 1)
	var rows: Array[Dictionary] = [
		{"name":"VITALITY","kind":"vitality","level":meta.vitality_level,"desc":"+12 starting HP / level","c":C_GREEN,"icon":0},
		{"name":"PRECISION","kind":"precision","level":meta.precision_level,"desc":"+1.8% starting crit / level","c":V12_PURPLE,"icon":1},
		{"name":"FORTUNE","kind":"fortune","level":meta.fortune_level,"desc":"+6% coin drops / level","c":V12_GOLD,"icon":2}
	]
	for i: int in range(rows.size()):
		var row: Dictionary = rows[i]
		var r: Rect2 = talent_rect(i)
		var accent: Color = row["c"]
		panel(r,V12_PANEL,accent)
		_v12_icon(int(row["icon"]),Rect2(r.position.x+14,r.position.y+15,106,106))
		text(String(row["name"]),r.position+Vector2(134,48),24,V12_IVORY)
		text("Lv. %d  •  %s" % [int(row["level"]),String(row["desc"])],r.position+Vector2(134,82),14,C_MUTED)
		var cost: int = int(meta.talent_cost(String(row["kind"])))
		button(Rect2(r.end.x-180,r.position.y+31,155,74),"UPGRADE %d" % cost,accent if meta.coins >= cost else C_MUTED,12)

func _v12_stat_line(r: Rect2, icon_index: int, label: String, accent: Color) -> void:
	_v12_icon(icon_index, Rect2(r.position.x,r.position.y-2,38,38),Color(accent,0.88))
	text(label,r.position+Vector2(48,25),17,accent)

# --- Vault + Forge ------------------------------------------------------------

func draw_vault_screen() -> void:
	_v12_meta_header("VAULT + FORGE", "Compare, lock, equip, dismantle and craft gear", V12_GOLD, 9)
	var bonuses: Dictionary = loot.equipped_bonuses()
	panel(Rect2(48,202,624,64),Color("0b1220"),V12_GOLD)
	_v12_icon(9,Rect2(56,208,48,48))
	text("SOUL SHARDS  %d" % int(loot.shards),Vector2(106,240),15,C_CYAN)
	text("DMG +%.1f%%  HP +%d  CRIT +%.1f%%" % [float(bonuses["damage_pct"])*100.0,int(round(float(bonuses["hp"]))),float(bonuses["crit_pct"])*100.0],Vector2(310,239),12,V12_IVORY)
	button(V8_FILTER,"FILTER: %s" % String(V8_FILTERS[vault_filter_index]).to_upper(),C_PURPLE,12)
	button(V8_SORT,"SORT: %s" % String(V8_SORTS[vault_sort_index]).to_upper(),C_BLUE,12)
	var selected: Dictionary = _selected_vault_item_v08()
	var lock_label: String = "LOCK ITEM"
	var lock_color: Color = C_MUTED
	if not selected.is_empty():
		lock_label = "UNLOCK" if loot.is_locked(selected) else "LOCK ITEM"
		lock_color = C_CYAN if loot.is_locked(selected) else V12_GOLD
	button(V8_LOCK,lock_label,lock_color,12)
	var visible: Array[int] = _visible_vault_indices()
	var first: int = vault_page * V8_PAGE_SIZE
	if visible.is_empty():
		panel(Rect2(54,342,612,190),V12_PANEL,Color("3a425a"))
		center_rect("NO ITEMS IN THIS FILTER",Rect2(54,342,612,190),20,C_MUTED)
	else:
		for local_index: int in range(V8_PAGE_SIZE):
			var page_pos: int = first + local_index
			if page_pos >= visible.size():
				break
			var global_index: int = int(visible[page_pos])
			var item: Dictionary = loot.inventory[global_index]
			var r: Rect2 = vault_v08_item_rect(local_index)
			var selected_now: bool = String(item.get("id","")) == selected_vault_id
			var accent: Color = C_CYAN if selected_now else rarity_color(String(item["rarity"]))
			panel(r,V12_PANEL,accent)
			var slot_icon: int = 6 if String(item["slot"]) == "weapon" else (8 if String(item["slot"]) == "armor" else 9)
			_v12_icon(slot_icon,Rect2(r.position.x+8,r.position.y+8,72,72),Color(accent,0.95))
			text(String(item["name"]),r.position+Vector2(87,28),17,V12_IVORY)
			text("%s • %s • Lv.%d • SCORE %d" % [String(item["rarity"]),String(item["slot"]).to_upper(),int(item["level"]),int(loot.item_score(item))],r.position+Vector2(87,50),10,accent)
			text(loot.stat_line(item),r.position+Vector2(87,72),12,C_MUTED)
			var tags: String = String(loot.trait_line(item))
			if loot.is_locked(item):
				tags = (tags + " • " if tags != "" else "") + "LOCKED"
			if tags != "":
				text(tags,r.position+Vector2(310,72),10,C_PURPLE if not loot.is_locked(item) else C_CYAN)
			var status: String = "EQUIPPED" if loot.is_equipped(item) else ("SELECTED" if selected_now else "TAP")
			text(status,r.position+Vector2(510,45),10,C_GREEN if loot.is_equipped(item) else V12_GOLD)
	_v12_vault_comparison(selected)
	button(V8_EQUIP,"EQUIP",C_GREEN if not selected.is_empty() else C_MUTED,14)
	var dismantle_label: String = "DISMANTLE"
	var dismantle_color: Color = C_MUTED
	if not selected.is_empty():
		dismantle_label = "DISMANTLE +%d" % int(loot.dismantle_value(selected))
		dismantle_color = C_MUTED if loot.is_locked(selected) or loot.is_equipped(selected) else C_RED
	button(V8_DISMANTLE,dismantle_label,dismantle_color,12)
	button(V8_PREV,"‹",C_PURPLE if vault_page > 0 else C_MUTED,23)
	button(V8_NEXT,"›",C_PURPLE if vault_page < _vault_max_page() else C_MUTED,23)
	var craft_color: Color = C_CYAN if int(loot.shards) >= int(loot.craft_cost()) else C_MUTED
	_v12_craft_button(V8_CRAFT_WEAPON,"CRAFT WEAPON",7,craft_color)
	_v12_craft_button(V8_CRAFT_ARMOR,"CRAFT ARMOR",8,craft_color)
	_v12_craft_button(V8_CRAFT_RELIC,"CRAFT RELIC",9,craft_color)
	draw_string(font,Vector2(70,1052),"CRAFT %d SHARDS  •  GUARANTEED RARE+" % int(loot.craft_cost()),HORIZONTAL_ALIGNMENT_CENTER,580,12,C_PURPLE)
	button(META_BACK,"‹  BACK",C_PURPLE,18)
	_draw_notice(1118)

func _v12_vault_comparison(selected: Dictionary) -> void:
	var r: Rect2 = Rect2(54,748,612,116)
	panel(r,Color("090f1b"),C_BLUE if not selected.is_empty() else Color("394057"))
	if selected.is_empty():
		_v12_icon(1,Rect2(314,760,92,92),Color(0.35,0.35,0.55,0.16))
		center_rect("SELECT AN ITEM TO COMPARE",r,14,C_MUTED)
		return
	var equipped_item: Dictionary = loot.equipped_item_for_slot(String(selected["slot"]))
	var delta: int = int(loot.comparison_delta(selected))
	text("SELECTED",r.position+Vector2(18,27),11,C_CYAN)
	text("%s  •  %s  •  %d" % [String(selected["name"]),loot.stat_line(selected),int(loot.item_score(selected))],r.position+Vector2(18,52),12,V12_IVORY)
	text("EQUIPPED",r.position+Vector2(18,79),11,C_GREEN)
	var equipped_line: String = "EMPTY SLOT" if equipped_item.is_empty() else "%s  •  %s  •  %d" % [String(equipped_item["name"]),loot.stat_line(equipped_item),int(loot.item_score(equipped_item))]
	text(equipped_line,r.position+Vector2(110,79),12,C_MUTED if equipped_item.is_empty() else V12_IVORY)
	text("+%d" % delta if delta >= 0 else "%d" % delta,r.position+Vector2(530,58),17,C_GREEN if delta >= 0 else C_RED)

func _v12_craft_button(r: Rect2, label: String, icon_index: int, accent: Color) -> void:
	panel(r,Color("171027"),accent)
	_v12_icon(icon_index,Rect2(r.position.x+7,r.position.y+6,45,45),Color(accent,0.9))
	draw_string(font,Vector2(r.position.x+48,r.position.y+36),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-52,11,V12_IVORY)

# --- Tower Pass ---------------------------------------------------------------

func draw_pass_screen() -> void:
	_v12_background(V12_PURPLE)
	panel(Rect2(42,42,636,100),Color("0a0d19"),V12_PURPLE)
	_v12_icon(14,Rect2(53,48,82,82))
	text("TOWER PASS",Vector2(145,91),34,V12_IVORY)
	text("FREE SEASON PATH",Vector2(147,119),12,V12_PURPLE)
	_v12_coin_badge(Rect2(532,60,132,58),int(meta.coins))
	var level_no: int = int(tower_pass.level())
	var prog: Dictionary = tower_pass.progress_to_next()
	panel(Rect2(58,178,604,188),Color("0b111d"),V12_PURPLE)
	text("LEVEL",Vector2(84,218),12,C_MUTED)
	text("%d" % level_no,Vector2(84,273),44,V12_IVORY)
	text("/ %d" % int(tower_pass.MAX_LEVEL),Vector2(145,273),17,C_MUTED)
	text("NEXT REWARD",Vector2(430,218),12,C_MUTED)
	var preview_level: int = mini(tower_pass.MAX_LEVEL,level_no+1)
	var preview: Dictionary = tower_pass.reward_for(preview_level)
	text(String(preview["label"]),Vector2(430,250),16,V12_IVORY)
	text("%d COINS" % int(preview["coins"]),Vector2(430,279),15,V12_GOLD)
	var bar: Rect2 = Rect2(84,310,552,18)
	draw_rect(bar,Color("211b31"))
	draw_rect(Rect2(bar.position,Vector2(bar.size.x*float(prog["ratio"]),bar.size.y)),V12_PURPLE)
	draw_circle(Vector2(bar.position.x+bar.size.x*float(prog["ratio"]),bar.get_center().y),9,V12_IVORY)
	text("%d / %d XP" % [int(prog["current"]),int(prog["needed"])],Vector2(84,352),12,C_MUTED)
	_v12_title("REWARD TRACK",420,22,V12_GOLD)
	var start_level: int = maxi(1,level_no-1)
	for i: int in range(5):
		var reward_level: int = start_level + i
		if reward_level > tower_pass.MAX_LEVEL:
			break
		_v12_pass_reward(reward_level,i)
	var next_claim: int = int(tower_pass.next_claimable())
	button(PASS_CLAIM,"CLAIM LEVEL %d" % next_claim if next_claim > 0 else "NO REWARD READY",V12_GOLD if next_claim > 0 else C_MUTED,16)
	button(OVERLAY_BACK,"‹  BACK",C_PURPLE,18)
	_draw_notice(1008)

func _v12_pass_reward(level_no: int, index: int) -> void:
	var reward: Dictionary = tower_pass.reward_for(level_no)
	var unlocked: bool = level_no <= int(tower_pass.level())
	var claimable: bool = bool(tower_pass.can_claim(level_no))
	var accent: Color = V12_GOLD if claimable else (V12_PURPLE if unlocked else Color("3d4355"))
	var r: Rect2 = Rect2(58,452+index*100,604,82)
	panel(r,V12_PANEL,accent)
	var icon_idx: int = 10 if String(reward["label"]).contains("CACHE") else 11
	_v12_icon(icon_idx,Rect2(r.position.x+8,r.position.y+7,68,68),Color(accent,0.95))
	text("LV %02d" % level_no,r.position+Vector2(88,33),16,V12_IVORY)
	text(String(reward["label"]),r.position+Vector2(168,31),13,C_MUTED)
	text("+%d" % int(reward["coins"]),r.position+Vector2(168,57),14,V12_GOLD)
	var status: String = "CLAIM" if claimable else ("UNLOCKED" if unlocked else "LOCKED")
	text(status,r.position+Vector2(474,48),12,V12_GOLD if claimable else C_MUTED)
	if not unlocked:
		_v12_icon(12,Rect2(r.end.x-55,r.position.y+20,38,38),Color(0.55,0.55,0.62,0.8))

# --- painted combat room + production actors --------------------------------

func _draw_room_floor() -> void:
	if tex_v12_environment == null:
		super._draw_room_floor()
		return
	var area: String = String(current_room.get("area","DUNGEON"))
	var index: int = 0
	if area == "CRYPT":
		index = 1
	elif area == "FORGOTTEN CASTLE":
		index = 2
	elif area == "DEEP TOWER":
		index = 3
	var source: Rect2 = Rect2(0.0,float(index*840),648.0,840.0)
	draw_texture_rect_region(tex_v12_environment,ARENA,source,Color.WHITE)
	draw_circle(ARENA.get_center(),280,Color(0.02,0.03,0.07,0.10))

func _draw_room_architecture() -> void:
	var area: String = String(current_room.get("area","DUNGEON"))
	var accent: Color = _area_accent(area)
	var glows: Array[Vector2] = [Vector2(98,320),Vector2(622,320),Vector2(98,850),Vector2(622,850)]
	for glow_pos: Vector2 in glows:
		draw_circle(glow_pos,28.0+sin(elapsed*5.0+glow_pos.y)*3.0,Color(accent,0.035))
	if String(current_room.get("type","")) == "ELITE":
		draw_arc(ARENA.get_center(),252,elapsed*0.14,elapsed*0.14+TAU,72,Color(V12_GOLD,0.16),3)
	if String(current_room.get("type","")) == "TREASURE":
		_v12_icon(10,Rect2(304,215,112,112),Color(1,0.92,0.72,1))

func _draw_room_badge() -> void:
	var area: String = String(current_room.get("area","DUNGEON"))
	var r: Rect2 = Rect2(215,170,290,42)
	panel(r,Color("070b13"),_area_accent(area))
	center_rect(room_system.room_label(current_room),r,12,V12_IVORY)

func _draw_combat_hud() -> void:
	panel(Rect2(28,22,664,112),V12_DARK,Color("526079"))
	text("FLOOR",Vector2(50,55),11,C_MUTED)
	text("%02d" % int(run.floor_no),Vector2(49,100),38,V12_IVORY)
	var area: String = String(current_room.get("area","DUNGEON"))
	text(area,Vector2(140,65),16,_area_accent(area))
	text(String(current_room.get("type","COMBAT")),Vector2(140,94),13,C_MUTED)
	_v12_coin_badge(Rect2(510,45,102,56),int(run.run_coins))
	panel(V10_PAUSE,Color("101522"),V12_GOLD)
	center_rect("Ⅱ",V10_PAUSE,18,V12_IVORY)
	var hp_box: Rect2 = Rect2(110,1016,430,32)
	panel(hp_box,Color("1d1018"),Color("73452d"))
	var ratio: float = clampf(run.hp/run.max_hp,0.0,1.0)
	var hp_fill: Rect2 = Rect2(hp_box.position+Vector2(4,4),Vector2((hp_box.size.x-8)*ratio,hp_box.size.y-8))
	draw_rect(hp_fill,Color("b92f42"))
	draw_rect(Rect2(hp_fill.position,Vector2(hp_fill.size.x,5)),Color(1.0,0.55,0.60,0.34))
	_v12_icon(0,Rect2(hp_box.position.x-31,hp_box.position.y-14,60,60))
	center_rect("%d / %d HP" % [int(run.hp),int(run.max_hp)],hp_box,14,V12_IVORY)
	var base: Vector2 = joy_origin if joy_active else Vector2(145,1115)
	var knob: Vector2 = joy_pos if joy_active else base
	draw_circle(base,84,Color(0.025,0.04,0.08,0.86))
	draw_arc(base,84,0,TAU,56,Color(V12_GOLD,0.72),3)
	draw_arc(base,70,0,TAU,56,Color(C_PURPLE,0.28),2)
	var directions: Array[Vector2] = [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]
	for dir: Vector2 in directions:
		var arrow_pos: Vector2 = base + dir * 62.0
		draw_circle(arrow_pos,3.0,Color(V12_IVORY,0.48))
	draw_circle(knob,35,Color("59637b"))
	draw_arc(knob,35,0,TAU,40,Color("b0b9c8"),2)
	draw_string(font,Vector2(86,1215),"MOVE",HORIZONTAL_ALIGNMENT_CENTER,118,12,C_MUTED)
	var skill_center: Vector2 = SKILL.get_center()
	draw_circle(skill_center,67,Color(0.01,0.05,0.12,0.93))
	draw_arc(skill_center,67,0,TAU,58,V12_GOLD,3)
	draw_arc(skill_center,59,0,TAU,58,C_CYAN if run.skill_cd <= 0.0 else Color("4a5267"),5)
	if run.skill_cd <= 0.0:
		_v12_icon(15,Rect2(skill_center.x-42,skill_center.y-48,84,84))
		text("NOVA",Vector2(skill_center.x-26,skill_center.y+36),14,V12_IVORY)
	else:
		draw_string(font,Vector2(skill_center.x-42,skill_center.y+8),"%.1f" % run.skill_cd,HORIZONTAL_ALIGNMENT_CENTER,84,22,C_MUTED)

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	if tex_v12_actors == null:
		super.draw_wanderer(pos,scale,combat)
		return
	var bob: float = sin(elapsed*(6.0 if combat else 2.5))*2.0*scale
	var w: float = 76.0*scale if combat else 112.0*scale
	var h: float = 114.0*scale if combat else 168.0*scale
	var r: Rect2 = Rect2(pos.x-w*0.5,pos.y-h*0.65+bob,w,h)
	draw_ellipse_shadow(pos+Vector2(0,25*scale),w*0.44,11*scale)
	if player_anim_state == "nova":
		draw_circle(pos,52*scale,Color(C_CYAN,0.10))
		draw_arc(pos,54*scale,elapsed*2.5,elapsed*2.5+TAU,42,C_CYAN,3*scale)
	elif combat and player_anim_state == "attack":
		draw_arc(pos,44*scale,-0.9,0.75,24,Color(V12_PURPLE,0.55),4*scale)
	_v12_actor(0,r,Color.WHITE)

func draw_enemy(e: Dictionary) -> void:
	if tex_v12_actors == null:
		super.draw_enemy(e)
		return
	var kind: String = String(e["type"])
	var variant: String = String(e.get("boss_variant","warden"))
	var idx: int = _v12_actor_index(kind,variant)
	if idx < 0:
		super.draw_enemy(e)
		return
	var p: Vector2 = e["pos"]
	var radius: float = float(e["radius"])
	var bob: float = sin(elapsed*(8.0 if kind=="bat" else 4.0)+float(e.get("phase",0.0)))*(4.5 if kind=="bat" else 1.5)
	var width: float = maxf(58.0,radius*2.35)
	if kind == "warden":
		width = radius*2.45
	var height: float = width*1.5
	var modulate: Color = Color.WHITE
	if float(e.get("anim_hit",0.0)) > 0.0:
		modulate = Color(1.0,0.65,0.65,1.0)
	if bool(e.get("elite",false)):
		modulate = modulate.lerp(V12_GOLD_LIGHT,0.15)
	draw_ellipse_shadow(p+Vector2(0,radius*0.8),width*0.35,8)
	_v12_actor(idx,Rect2(p.x-width*0.5,p.y-height*0.64+bob,width,height),modulate)
	if bool(e.get("elite",false)):
		draw_arc(p,radius+12,elapsed*0.9,elapsed*0.9+TAU,36,V12_GOLD,3)
	if kind == "warden" and bool(e.get("phase2",false)):
		var phase_color: Color = V12_GOLD if variant=="hollow_king" else (C_CYAN if variant=="crypt_keeper" else C_RED)
		draw_arc(p,radius+15,elapsed*1.2,elapsed*1.2+TAU,44,phase_color,4)
	var ratio: float = clampf(float(e["hp"])/float(e["max_hp"]),0.0,1.0)
	var hp: Rect2 = Rect2(p.x-radius,p.y-radius-18,radius*2.0,7)
	draw_rect(hp,Color("32131d"))
	draw_rect(Rect2(hp.position,Vector2(hp.size.x*ratio,hp.size.y)),Color("e34d5e"))

func _v12_actor_index(kind: String, variant: String) -> int:
	match kind:
		"goblin": return 1
		"bat": return 2
		"skeleton": return 3
		"ghoul": return 4
		"necromancer": return 5
		"gargoyle": return 8
		"sentinel": return 9
		"hexer": return 10
		"warden":
			if variant == "crypt_keeper": return 7
			if variant == "hollow_king": return 11
			return 6
	return -1

func draw_player_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot["pos"]
	var dir: Vector2 = Vector2(shot["vel"]).normalized()
	var c: Color = V12_GOLD if bool(shot["crit"]) else C_BLUE
	draw_line(p-dir*23,p+dir*10,Color(c,0.18),10 if bool(shot["crit"]) else 7)
	draw_line(p-dir*20,p+dir*8,c,5 if bool(shot["crit"]) else 3)
	draw_circle(p,4,V12_IVORY)

func draw_enemy_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot["pos"]
	var c: Color = shot["color"]
	draw_circle(p,13,Color(c,0.08))
	draw_circle(p,7,Color(c,0.22))
	draw_circle(p,3.5,c)

func draw_coin_orb(orb: Dictionary) -> void:
	var p: Vector2 = orb["pos"]
	draw_circle(p,13,Color(V12_GOLD,0.10))
	_v12_icon(11,Rect2(p.x-10,p.y-10,20,20))

func draw_effect(fx: Dictionary) -> void:
	if String(fx.get("type","")) != "actor_death":
		super.draw_effect(fx)
		return
	var idx: int = _v12_actor_index(String(fx.get("kind","")),String(fx.get("variant","warden")))
	if idx < 0 or tex_v12_actors == null:
		super.draw_effect(fx)
		return
	var t: float = clampf(float(fx["age"])/float(fx["dur"]),0.0,1.0)
	var s: float = float(fx.get("size",72.0))*(1.0-t*0.16)
	var p: Vector2 = Vector2(fx["pos"])+Vector2(0,t*12.0)
	_v12_actor(idx,Rect2(p.x-s*0.5,p.y-s*0.82,s,s*1.5),Color(1,1,1,1.0-t))

# --- Upgrade / decision / death ----------------------------------------------

func draw_upgrade() -> void:
	_v12_background(V12_PURPLE)
	_v12_title("FLOOR CLEARED!",155,44,V12_GOLD)
	draw_string(font,Vector2(70,220),"Choose an Upgrade",HORIZONTAL_ALIGNMENT_CENTER,580,29,V12_IVORY)
	draw_string(font,Vector2(70,257),"Build the run. Break the tower.",HORIZONTAL_ALIGNMENT_CENTER,580,16,C_MUTED)
	for i: int in range(upgrade_options.size()):
		var r: Rect2 = upgrade_rect(i)
		var u: Dictionary = upgrade_options[i]
		var kind: String = String(u["kind"])
		var accent: Color = u["color"]
		panel(r,V12_PANEL,accent)
		_v12_icon(_v12_upgrade_icon(kind),Rect2(r.position.x+18,r.position.y+15,108,108),Color(accent,0.98))
		text(String(u["name"]),r.position+Vector2(145,58),24,V12_IVORY)
		text(String(u["desc"]),r.position+Vector2(145,96),16,C_MUTED)
	draw_string(font,Vector2(70,986),"Tap an upgrade to continue.",HORIZONTAL_ALIGNMENT_CENTER,580,14,C_MUTED)

func _v12_upgrade_icon(kind: String) -> int:
	match kind:
		"range": return 3
		"nova": return 4
		"vitality": return 5
		"crit": return 1
		"power": return 6
		"multi": return 3
		"lifesteal": return 0
		"armor": return 8
		"speed": return 15
	return 4

func draw_decision() -> void:
	_v12_background(V12_GOLD)
	_v12_title("TAKE THE LOOT?",190,38,V12_IVORY)
	draw_string(font,Vector2(70,258),"OR",HORIZONTAL_ALIGNMENT_CENTER,580,16,C_MUTED)
	_v12_title("ONE MORE FLOOR",330,47,V12_GOLD)
	panel(Rect2(118,420,484,230),V12_PANEL,V12_GOLD)
	_v12_icon(10,Rect2(302,440,116,116))
	draw_string(font,Vector2(150,585),"%d COINS" % int(run.run_coins),HORIZONTAL_ALIGNMENT_CENTER,420,33,V12_GOLD_LIGHT)
	draw_string(font,Vector2(150,620),"Floor %d cleared" % int(run.floor_no),HORIZONTAL_ALIGNMENT_CENTER,420,16,V12_IVORY)
	button(CASH,"CASH OUT",C_GREEN,22)
	button(NEXT,"ONE MORE FLOOR",V12_GOLD,21)
	draw_string(font,Vector2(70,1040),"Death keeps only 60% of unsecured coins.",HORIZONTAL_ALIGNMENT_CENTER,580,15,C_MUTED)

func draw_game_over() -> void:
	_v12_background(C_RED)
	_v12_title("RUN ENDED",220,48,C_RED)
	draw_string(font,Vector2(70,280),"The tower wins this time.",HORIZONTAL_ALIGNMENT_CENTER,580,18,C_MUTED)
	panel(Rect2(118,410,484,260),V12_PANEL,V12_PURPLE)
	_v12_icon(13,Rect2(302,430,116,116),Color(0.85,0.78,0.82,1))
	draw_string(font,Vector2(150,580),"FLOOR %d" % int(run.floor_no),HORIZONTAL_ALIGNMENT_CENTER,420,38,V12_IVORY)
	draw_string(font,Vector2(150,625),"%d coins secured" % int(run.saved_after_death),HORIZONTAL_ALIGNMENT_CENTER,420,20,V12_GOLD)
	button(RETRY,"RETRY",V12_GOLD,25)
	button(HOME_BTN,"HOME",C_PURPLE,25)
