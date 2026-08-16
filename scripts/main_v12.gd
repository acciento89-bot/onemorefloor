extends "res://scripts/main_v11.gd"

const V12_VERSION := "1.2.0-rc1"

var tex_fantasy_actors: Texture2D
var tex_fantasy_biomes: Texture2D

func _ready() -> void:
	super._ready()
	tex_fantasy_actors = load("res://assets/art/fantasy_actor_atlas.svg") as Texture2D
	tex_fantasy_biomes = load("res://assets/art/fantasy_biomes.svg") as Texture2D
	queue_redraw()

# -----------------------------------------------------------------------------
# Production fantasy skin helpers
# -----------------------------------------------------------------------------

func _f12_bevel_points(r: Rect2, cut: float = 10.0) -> PackedVector2Array:
	return PackedVector2Array([
		r.position + Vector2(cut, 0),
		r.position + Vector2(r.size.x - cut, 0),
		r.position + Vector2(r.size.x, cut),
		r.position + Vector2(r.size.x, r.size.y - cut),
		r.position + Vector2(r.size.x - cut, r.size.y),
		r.position + Vector2(cut, r.size.y),
		r.position + Vector2(0, r.size.y - cut),
		r.position + Vector2(0, cut)
	])

func _f12_panel(r: Rect2, accent: Color, fill: Color = Color("0b1020"), strong: bool = false) -> void:
	var shadow := r.grow(5.0)
	var shadow_pts := _f12_bevel_points(shadow, 14.0)
	draw_colored_polygon(shadow_pts, Color(0.0, 0.0, 0.0, 0.30))
	var pts := _f12_bevel_points(r, 11.0)
	draw_colored_polygon(pts, fill)
	for i in range(pts.size()):
		draw_line(pts[i], pts[(i + 1) % pts.size()], Color(accent, 0.95 if strong else 0.72), 3.0 if strong else 2.0)
	var inner := r.grow(-5.0)
	var inner_pts := _f12_bevel_points(inner, 8.0)
	for i in range(inner_pts.size()):
		draw_line(inner_pts[i], inner_pts[(i + 1) % inner_pts.size()], Color(1.0, 0.82, 0.42, 0.10 if not strong else 0.18), 1.0)
	# corner studs
	for p in [r.position + Vector2(11,11), Vector2(r.end.x-11,r.position.y+11), Vector2(r.position.x+11,r.end.y-11), r.end-Vector2(11,11)]:
		draw_circle(p, 2.2, Color(accent,0.75))

func _f12_button(r: Rect2, label: String, accent: Color, size: int = 17, enabled: bool = true) -> void:
	var use_accent: Color = accent if enabled else Color("555d72")
	_f12_panel(r, use_accent, Color(use_accent, 0.13 if enabled else 0.08), enabled)
	var shine := Rect2(r.position + Vector2(8,7), Vector2(maxf(0.0,r.size.x-16), 5))
	draw_rect(shine, Color(1,1,1,0.06 if enabled else 0.02))
	center_rect(label, r, size, C_TEXT if enabled else C_MUTED)

func _f12_gem(p: Vector2, color: Color, size: float = 12.0) -> void:
	var pts := PackedVector2Array([p+Vector2(0,-size),p+Vector2(size*0.72,0),p+Vector2(0,size),p+Vector2(-size*0.72,0)])
	draw_colored_polygon(pts, Color(color,0.88))
	draw_line(p+Vector2(0,-size+2),p+Vector2(0,size-2),Color(1,1,1,0.20),1.0)
	draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[0]]), Color(1,0.88,1,0.28), 1.5)

func _f12_coin(p: Vector2, radius: float = 10.0) -> void:
	draw_circle(p, radius+3.0, Color(C_GOLD,0.10))
	draw_circle(p, radius, Color("9c6122"))
	draw_circle(p, radius-2.0, C_GOLD)
	draw_arc(p, radius-4.0, 0, TAU, 20, Color("ffe39a"), 1.5)
	draw_colored_polygon(PackedVector2Array([p+Vector2(0,-4),p+Vector2(4,1),p+Vector2(0,5),p+Vector2(-4,1)]), Color("8f5d20"))

func _f12_medallion(p: Vector2, accent: Color, kind: String) -> void:
	draw_circle(p, 31, Color(0,0,0,0.28))
	draw_circle(p, 28, Color(accent,0.15))
	draw_arc(p, 28, 0, TAU, 36, Color(C_GOLD,0.50), 2.0)
	draw_arc(p, 23, 0, TAU, 36, Color(accent,0.70), 2.0)
	_f12_icon(kind, p, accent, 1.0)

func _f12_icon(kind: String, p: Vector2, c: Color, scale: float = 1.0) -> void:
	match kind:
		"hero":
			draw_circle(p+Vector2(0,-7)*scale,7*scale,c)
			draw_arc(p+Vector2(0,8)*scale,14*scale,PI,TAU,20,c,3*scale)
			draw_line(p+Vector2(7,7)*scale,p+Vector2(18,-10)*scale,C_GOLD,3*scale)
		"forge", "weapon":
			draw_line(p+Vector2(-13,12)*scale,p+Vector2(13,-14)*scale,C_GOLD,5*scale)
			draw_line(p+Vector2(-6,5)*scale,p+Vector2(4,15)*scale,c,3*scale)
		"armor":
			var pts := PackedVector2Array([p+Vector2(-13,-12)*scale,p+Vector2(13,-12)*scale,p+Vector2(16,5)*scale,p+Vector2(0,18)*scale,p+Vector2(-16,5)*scale])
			draw_colored_polygon(pts,Color(c,0.62)); draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[3],pts[4],pts[0]]),C_GOLD,2*scale)
		"relic", "talent":
			_f12_gem(p,c,14*scale)
		"vault":
			draw_rect(Rect2(p-Vector2(15,7)*scale,Vector2(30,19)*scale),Color(c,0.42))
			draw_arc(p+Vector2(0,-7)*scale,15*scale,PI,TAU,20,C_GOLD,3*scale)
			draw_line(p+Vector2(0,-4)*scale,p+Vector2(0,9)*scale,C_GOLD,2*scale)
		"heart", "vitality":
			draw_circle(p+Vector2(-6,-3)*scale,8*scale,Color(c,0.84)); draw_circle(p+Vector2(6,-3)*scale,8*scale,Color(c,0.84))
			draw_colored_polygon(PackedVector2Array([p+Vector2(-13,0)*scale,p+Vector2(13,0)*scale,p+Vector2(0,17)*scale]),Color(c,0.84))
			draw_line(p+Vector2(-4,5)*scale,p+Vector2(4,5)*scale,C_TEXT,2*scale); draw_line(p+Vector2(0,1)*scale,p+Vector2(0,9)*scale,C_TEXT,2*scale)
		"precision", "range":
			draw_arc(p,15*scale,0,TAU,30,c,2*scale); draw_arc(p,8*scale,0,TAU,24,c,2*scale)
			draw_line(p+Vector2(-19,0)*scale,p+Vector2(19,0)*scale,c,2*scale); draw_line(p+Vector2(0,-19)*scale,p+Vector2(0,19)*scale,c,2*scale)
		"fortune":
			draw_circle(p+Vector2(-5,6)*scale,7*scale,C_GOLD); draw_circle(p+Vector2(5,7)*scale,7*scale,Color("d99b35")); draw_circle(p+Vector2(1,-5)*scale,8*scale,Color("8d602a"))
		"nova":
			var pts := PackedVector2Array([p+Vector2(-4,-18)*scale,p+Vector2(7,-18)*scale,p+Vector2(0,-3)*scale,p+Vector2(12,-3)*scale,p+Vector2(-9,18)*scale,p+Vector2(-2,4)*scale,p+Vector2(-13,4)*scale])
			draw_colored_polygon(pts,Color(c,0.94))
		"mission":
			draw_rect(Rect2(p-Vector2(12,16)*scale,Vector2(24,32)*scale),Color(c,0.28)); draw_rect(Rect2(p-Vector2(12,16)*scale,Vector2(24,32)*scale),c,false,2*scale)
			draw_line(p+Vector2(-6,-7)*scale,p+Vector2(6,-7)*scale,C_TEXT,2*scale); draw_line(p+Vector2(-6,0)*scale,p+Vector2(6,0)*scale,C_TEXT,2*scale)
		"pass":
			draw_rect(Rect2(p-Vector2(9,15)*scale,Vector2(18,30)*scale),Color(c,0.38)); draw_line(p+Vector2(-14,10)*scale,p+Vector2(14,10)*scale,C_GOLD,3*scale)
		"lock":
			draw_rect(Rect2(p-Vector2(10,2)*scale,Vector2(20,17)*scale),Color(c,0.36)); draw_arc(p+Vector2(0,-1)*scale,9*scale,PI,TAU,20,c,3*scale)
		_:
			_f12_gem(p,c,11*scale)

func _f12_backdrop(accent: Color = C_PURPLE) -> void:
	draw_rect(Rect2(Vector2.ZERO,SIZE),Color("040811"))
	for i in range(8):
		var radius: float = 350.0-float(i)*34.0
		draw_circle(Vector2(360,350),radius,Color(accent,0.012+float(i)*0.003))
	for i in range(20):
		var x: float = 24.0+fmod(float(i*139),672.0)
		var y: float = 20.0+fmod(float(i*i*61),1200.0)
		draw_circle(Vector2(x,y),1.2+float(i%3)*0.4,Color(0.75,0.78,1.0,0.08+0.04*sin(elapsed+float(i))))
	# side masonry
	for y in range(120,1240,80):
		draw_rect(Rect2(0,y,26,62),Color("101522")); draw_rect(Rect2(694,y+18,26,62),Color("101522"))
		draw_line(Vector2(26,y),Vector2(26,y+62),Color(accent,0.10),1)

func _f12_title(value: String, y: float, size: int, color: Color = C_TEXT) -> void:
	draw_string(font,Vector2(42,y+3),value,HORIZONTAL_ALIGNMENT_CENTER,636,size,Color(0,0,0,0.65))
	draw_string(font,Vector2(42,y),value,HORIZONTAL_ALIGNMENT_CENTER,636,size,color)

func _f12_meta_header(title_value: String, subtitle: String, accent: Color) -> void:
	_f12_backdrop(accent)
	_f12_gem(Vector2(360,62),accent,13)
	_f12_title(title_value,132,48,C_GOLD if accent == C_GOLD else C_TEXT)
	draw_string(font,Vector2(70,175),subtitle,HORIZONTAL_ALIGNMENT_CENTER,580,17,C_MUTED)
	draw_line(Vector2(220,195),Vector2(500,195),Color(accent,0.42),2)
	_f12_gem(Vector2(360,195),accent,7)
	_f12_panel(Rect2(536,42,140,66),C_GOLD,Color("0b0f1b"),true)
	_f12_coin(Vector2(560,75),9)
	text("%d" % meta.coins,Vector2(582,84),22,C_GOLD)
	_f12_button(META_BACK,"BACK",C_PURPLE,18,true)
	if meta_notice_time > 0.0:
		draw_center(meta_notice,1100,17,C_GREEN if meta_notice.begins_with("UPGRADE") else C_RED)

# -----------------------------------------------------------------------------
# Home and meta screens
# -----------------------------------------------------------------------------

func draw_home() -> void:
	if home_overlay == "missions":
		draw_missions_screen()
		return
	if home_overlay == "pass":
		draw_pass_screen()
		return
	_f12_backdrop(C_PURPLE)
	# distant tower portal
	draw_circle(Vector2(360,390),225,Color("0b1025"))
	draw_circle(Vector2(360,390),194,Color("151331"))
	draw_arc(Vector2(360,390),201,-2.7,0.4,80,Color(C_PURPLE,0.36),4)
	_f12_draw_tower(Vector2(360,520))
	_f12_panel(Rect2(34,38,176,74),C_PURPLE,Color("080c19"),true)
	text("BEST FLOOR",Vector2(53,67),12,C_MUTED); text("%d" % meta.best_floor,Vector2(53,101),29,C_TEXT)
	_f12_panel(Rect2(510,38,176,74),C_GOLD,Color("080c19"),true)
	_f12_coin(Vector2(535,77),8); text("%d" % meta.coins,Vector2(553,87),24,C_GOLD)
	_f12_title("ONE MORE",182,45,C_TEXT)
	_f12_title("FLOOR",242,72,C_GOLD)
	draw_string(font,Vector2(80,278),"CLIMB  •  LOOT  •  RISK IT ALL",HORIZONTAL_ALIGNMENT_CENTER,560,13,C_MUTED)
	draw_wanderer(Vector2(360,692),1.35,false)
	_f12_button(PLAY,"ENTER THE TOWER",C_GOLD,27,true)
	_f12_button(MISSIONS_BTN,"MISSIONS",C_GREEN,17,true)
	_f12_button(PASS_BTN,"TOWER PASS",C_PURPLE,17,true)
	var tabs := [
		{"r":HERO_TAB,"label":"HERO","c":C_BLUE,"icon":"hero"},
		{"r":FORGE_TAB,"label":"FORGE","c":C_ORANGE,"icon":"forge"},
		{"r":TALENTS_TAB,"label":"TALENTS","c":C_PURPLE,"icon":"talent"},
		{"r":VAULT_TAB,"label":"VAULT","c":C_GOLD,"icon":"vault"}
	]
	for tab in tabs:
		var r: Rect2 = tab["r"]
		_f12_panel(r,tab["c"],Color("0c1122"),false)
		_f12_icon(String(tab["icon"]),Vector2(r.get_center().x,r.position.y+34),tab["c"],0.9)
		draw_string(font,Vector2(r.position.x+4,r.position.y+80),String(tab["label"]),HORIZONTAL_ALIGNMENT_CENTER,r.size.x-8,14,C_TEXT)
	_f12_button(V10_SETTINGS_HOME,"SETTINGS",C_BLUE,13,true)
	_f12_panel(Rect2(38,1162,644,64),Color("4a4163"),Color("080d19"),false)
	text("POWER  %d" % meta.power_score(),Vector2(62,1202),17,C_GOLD)
	draw_string(font,Vector2(330,1202),"KAMILUNAVO GAMES",HORIZONTAL_ALIGNMENT_RIGHT,320,13,C_MUTED)
	if recovery_notice_time > 0.0:
		_f12_panel(Rect2(138,722,404,40),C_GOLD,Color("11131d"),true)
		center_rect("PREVIOUS SESSION RECOVERED",Rect2(138,722,404,40),12,C_GOLD)
	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step in [0,1]:
		_draw_tutorial_overlay()

func _f12_draw_tower(center: Vector2) -> void:
	draw_circle(center+Vector2(0,38),150,Color(0,0,0,0.26))
	for side in [-1.0,1.0]:
		var x: float = center.x+side*98.0
		draw_rect(Rect2(x-28,center.y-92,56,172),Color("141a2a"))
		draw_colored_polygon(PackedVector2Array([Vector2(x-36,center.y-92),Vector2(x,center.y-148),Vector2(x+36,center.y-92)]),Color("24253c"))
		draw_line(Vector2(x-29,center.y-80),Vector2(x-29,center.y+72),Color(C_GOLD,0.16),2)
		draw_circle(Vector2(x,center.y-58),8,Color("ffad45")); draw_circle(Vector2(x,center.y-58),16,Color(C_ORANGE,0.06))
	draw_rect(Rect2(center.x-72,center.y-170,144,258),Color("12182a"))
	draw_colored_polygon(PackedVector2Array([Vector2(center.x-84,center.y-170),Vector2(center.x,center.y-260),Vector2(center.x+84,center.y-170)]),Color("242440"))
	for row in range(3):
		for col in range(2):
			var p := center+Vector2(-31+62*col,-112+58*row)
			draw_rect(Rect2(p-Vector2(8,14),Vector2(16,28)),Color("d9802d")); draw_rect(Rect2(p-Vector2(4,10),Vector2(8,20)),Color("ffd061"))
	_f12_gem(center+Vector2(0,-179),C_PURPLE,22)
	draw_rect(Rect2(center.x-25,center.y+28,50,60),Color("05070d")); draw_arc(center+Vector2(0,30),25,PI,TAU,24,Color(C_GOLD,0.34),2)

func draw_meta_header(title: String, subtitle: String, accent: Color) -> void:
	_f12_meta_header(title,subtitle,accent)

func draw_hero_screen() -> void:
	_f12_meta_header("HERO","Permanent Wanderer training",C_PURPLE)
	# shrine
	draw_circle(Vector2(360,390),158,Color(C_PURPLE,0.07))
	draw_arc(Vector2(360,390),142,0,TAU,64,Color(C_PURPLE,0.20),3)
	for i in range(8):
		var a: float = TAU*float(i)/8.0+elapsed*0.03
		_f12_gem(Vector2(360,390)+Vector2.from_angle(a)*128.0,C_PURPLE,4)
	draw_wanderer(Vector2(360,420),2.15,false)
	_f12_panel(Rect2(78,548,564,224),C_PURPLE,Color("0b1020"),true)
	_f12_title("WANDERER  •  LEVEL %d" % meta.hero_level,608,28,C_TEXT)
	_f12_icon("vitality",Vector2(200,652),C_GREEN,0.7); text("Base HP bonus  +%d" % int(meta.hp_bonus()),Vector2(230,659),20,C_GREEN)
	_f12_icon("weapon",Vector2(200,700),C_GOLD,0.65); text("Combined damage  x%.2f" % meta.damage_multiplier(),Vector2(230,707),20,C_GOLD)
	_f12_icon("armor",Vector2(200,744),C_MUTED,0.55); text("Power  %d" % meta.power_score(),Vector2(230,750),18,C_MUTED)
	_f12_button(META_BUY,"TRAIN   %d" % meta.hero_cost(),C_PURPLE,24,meta.coins>=meta.hero_cost())
	draw_string(font,Vector2(80,974),"Each Hero level: +5 HP and +3.5% damage",HORIZONTAL_ALIGNMENT_CENTER,560,16,C_MUTED)

func draw_forge_screen() -> void:
	_f12_meta_header("FORGE","Temper the Wanderer's weapon",C_ORANGE)
	# anvil / sword altar
	draw_circle(Vector2(360,395),150,Color(C_ORANGE,0.06))
	_f12_medallion(Vector2(360,365),C_ORANGE,"weapon")
	draw_line(Vector2(300,470),Vector2(430,285),Color(C_GOLD,0.16),18)
	draw_line(Vector2(305,466),Vector2(430,285),C_GOLD,9)
	draw_line(Vector2(425,290),Vector2(456,254),C_TEXT,3)
	_f12_panel(Rect2(78,548,564,224),C_ORANGE,Color("120e0b"),true)
	_f12_title("FORGE LEVEL %d" % meta.forge_level,615,30,C_TEXT)
	draw_string(font,Vector2(110,657),"Weapon multiplier contribution",HORIZONTAL_ALIGNMENT_CENTER,500,17,C_MUTED)
	_f12_title("+%.1f%% DAMAGE" % (float(meta.forge_level)*8.5),710,31,C_GOLD)
	_f12_button(META_BUY,"TEMPER   %d" % meta.forge_cost(),C_ORANGE,23,meta.coins>=meta.forge_cost())
	draw_string(font,Vector2(70,974),"Every Forge level adds +8.5% permanent damage.",HORIZONTAL_ALIGNMENT_CENTER,580,16,C_MUTED)

func draw_talents_screen() -> void:
	_f12_meta_header("TALENTS","Permanent passive bonuses",C_PURPLE)
	var rows := [
		{"name":"VITALITY","kind":"vitality","level":meta.vitality_level,"desc":"+12 starting HP / level","c":C_GREEN},
		{"name":"PRECISION","kind":"precision","level":meta.precision_level,"desc":"+1.8% starting crit / level","c":C_PURPLE},
		{"name":"FORTUNE","kind":"fortune","level":meta.fortune_level,"desc":"+6% coin drops / level","c":C_GOLD}
	]
	for i in range(rows.size()):
		var row: Dictionary = rows[i]
		var r: Rect2 = talent_rect(i)
		_f12_panel(r,row["c"],Color(row["c"],0.055),true)
		_f12_medallion(r.position+Vector2(62,68),row["c"],String(row["kind"]))
		text(String(row["name"]),r.position+Vector2(116,45),24,C_TEXT)
		text("Lv. %d  •  %s" % [int(row["level"]),String(row["desc"])],r.position+Vector2(116,82),15,C_MUTED)
		var cost: int = int(meta.talent_cost(String(row["kind"])))
		var br := Rect2(r.end.x-176,r.position.y+35,144,66)
		_f12_button(br,"UPGRADE\n%d" % cost,row["c"],15,meta.coins>=cost)

func draw_vault_screen() -> void:
	_f12_meta_header("VAULT + FORGE","Compare, lock, equip, dismantle and craft gear",C_GOLD)
	var bonuses: Dictionary = loot.equipped_bonuses()
	_f12_panel(Rect2(48,202,624,64),C_GOLD,Color("0b1020"),true)
	_f12_gem(Vector2(73,234),C_PURPLE,10)
	text("SOUL SHARDS  %d" % int(loot.shards),Vector2(92,240),16,C_CYAN)
	text("DMG +%.1f%%   HP +%d   CRIT +%.1f%%" % [float(bonuses["damage_pct"])*100.0,int(round(float(bonuses["hp"]))),float(bonuses["crit_pct"])*100.0],Vector2(310,240),13,C_TEXT)
	_f12_button(V8_FILTER,"FILTER: %s" % String(V8_FILTERS[vault_filter_index]).to_upper(),C_PURPLE,12,true)
	_f12_button(V8_SORT,"SORT: %s" % String(V8_SORTS[vault_sort_index]).to_upper(),C_BLUE,12,true)
	var selected: Dictionary = _selected_vault_item_v08()
	var lock_label: String = "LOCK ITEM" if selected.is_empty() else ("UNLOCK" if loot.is_locked(selected) else "LOCK")
	_f12_button(V8_LOCK,lock_label,C_GOLD if not selected.is_empty() else C_MUTED,12,not selected.is_empty())
	var visible: Array[int] = _visible_vault_indices()
	var first: int = vault_page*V8_PAGE_SIZE
	if visible.is_empty():
		_f12_panel(Rect2(54,350,612,300),Color("454b63"),Color("090e1c"),false)
		_f12_icon("vault",Vector2(360,455),C_GOLD,2.0)
		draw_center("THE VAULT IS EMPTY",540,25,C_TEXT)
	else:
		for local_index in range(V8_PAGE_SIZE):
			var page_pos: int = first+local_index
			if page_pos >= visible.size(): break
			var global_index: int = int(visible[page_pos])
			var item: Dictionary = loot.inventory[global_index]
			var r: Rect2 = vault_v08_item_rect(local_index)
			var selected_now: bool = String(item.get("id","")) == selected_vault_id
			var accent: Color = C_CYAN if selected_now else rarity_color(String(item["rarity"]))
			_f12_panel(r,accent,Color(accent,0.045),selected_now or loot.is_equipped(item))
			_f12_medallion(r.position+Vector2(42,45),accent,String(item["slot"]))
			text(String(item["name"]),r.position+Vector2(88,27),17,C_TEXT)
			text("%s • %s • Lv.%d • SCORE %d" % [String(item["rarity"]),String(item["slot"]).to_upper(),int(item["level"]),int(loot.item_score(item))],r.position+Vector2(88,49),11,accent)
			text(loot.stat_line(item),r.position+Vector2(88,72),13,C_MUTED)
			var tags: String = loot.trait_line(item)
			if loot.is_locked(item): tags = (tags+" • " if tags!="" else "")+"LOCKED"
			if tags!="": text(tags,r.position+Vector2(285,72),10,C_PURPLE if not loot.is_locked(item) else C_CYAN)
			var status: String = "EQUIPPED" if loot.is_equipped(item) else ("SELECTED" if selected_now else "TAP")
			text(status,r.position+Vector2(508,45),11,C_GREEN if loot.is_equipped(item) else C_GOLD)
	_f12_vault_comparison(selected)
	_f12_button(V8_EQUIP,"EQUIP",C_GREEN,14,not selected.is_empty())
	var can_dismantle: bool = not selected.is_empty() and not loot.is_locked(selected) and not loot.is_equipped(selected)
	var dismantle_label: String = "DISMANTLE" if selected.is_empty() else "DISMANTLE +%d" % int(loot.dismantle_value(selected))
	_f12_button(V8_DISMANTLE,dismantle_label,C_RED,12,can_dismantle)
	_f12_button(V8_PREV,"<",C_PURPLE,20,vault_page>0)
	_f12_button(V8_NEXT,">",C_PURPLE,20,vault_page<_vault_max_page())
	var craft_ready: bool = int(loot.shards)>=int(loot.craft_cost())
	_f12_button(V8_CRAFT_WEAPON,"CRAFT WEAPON",C_PURPLE,12,craft_ready)
	_f12_button(V8_CRAFT_ARMOR,"CRAFT ARMOR",C_PURPLE,12,craft_ready)
	_f12_button(V8_CRAFT_RELIC,"CRAFT RELIC",C_PURPLE,12,craft_ready)
	draw_center("CRAFT %d SHARDS  •  GUARANTEED RARE+" % int(loot.craft_cost()),1052,13,C_PURPLE)
	_f12_button(META_BACK,"BACK",C_PURPLE,18,true)
	_draw_notice(1118)

func _f12_vault_comparison(selected: Dictionary) -> void:
	var r := Rect2(54,748,612,116)
	_f12_panel(r,C_BLUE if not selected.is_empty() else Color("454b63"),Color("090e1b"),not selected.is_empty())
	if selected.is_empty():
		_f12_gem(r.get_center()-Vector2(0,20),C_PURPLE,9)
		center_rect("SELECT AN ITEM TO COMPARE",r,14,C_MUTED)
		return
	var equipped_item: Dictionary = loot.equipped_item_for_slot(String(selected["slot"]))
	var delta: int = int(loot.comparison_delta(selected))
	text("SELECTED",r.position+Vector2(18,27),11,C_CYAN)
	text("%s  •  %s  •  %d" % [String(selected["name"]),loot.stat_line(selected),int(loot.item_score(selected))],r.position+Vector2(18,52),12,C_TEXT)
	text("EQUIPPED",r.position+Vector2(18,80),11,C_GREEN)
	text("EMPTY SLOT" if equipped_item.is_empty() else "%s  •  %s  •  %d" % [String(equipped_item["name"]),loot.stat_line(equipped_item),int(loot.item_score(equipped_item))],r.position+Vector2(110,80),12,C_MUTED if equipped_item.is_empty() else C_TEXT)
	var dt: String = "+%d" % delta if delta>=0 else "%d" % delta
	text(dt,r.position+Vector2(532,58),18,C_GREEN if delta>=0 else C_RED)

func draw_missions_screen() -> void:
	_f12_meta_header("MISSIONS","Daily and weekly tower contracts",C_GREEN)
	text("DAILY CONTRACTS",Vector2(54,232),17,C_GREEN)
	var daily: Array = missions.all_daily()
	for i in range(daily.size()): _f12_mission_row(daily[i],i,false)
	text("WEEKLY CONTRACTS",Vector2(54,615),17,C_PURPLE)
	var weekly: Array = missions.all_weekly()
	for i in range(weekly.size()): _f12_mission_row(weekly[i],i+3,true)
	_f12_button(OVERLAY_BACK,"BACK",C_PURPLE,18,true)
	_draw_notice(1085)

func _f12_mission_row(mission: Dictionary, index: int, weekly: bool) -> void:
	var r: Rect2 = mission_rect(index)
	var complete: bool = bool(missions.is_complete(mission,weekly))
	var claimed: bool = bool(missions.is_claimed(mission,weekly))
	var accent: Color = C_PURPLE if weekly else C_GREEN
	if complete and not claimed: accent = C_GOLD
	if claimed: accent = Color("4e5871")
	_f12_panel(r,accent,Color(accent,0.04),complete and not claimed)
	_f12_medallion(r.position+Vector2(42,52),accent,"mission")
	text(String(mission["title"]),r.position+Vector2(86,31),17,C_TEXT)
	var progress: int = int(missions.progress(mission,weekly))
	text("%d / %d" % [progress,int(mission["goal"])],r.position+Vector2(86,58),13,C_MUTED)
	text("%d COINS  •  %d XP" % [int(mission["coins"]),int(mission["xp"])],r.position+Vector2(86,82),13,C_GOLD)
	var status: String = "CLAIMED" if claimed else ("CLAIM" if complete else "IN PROGRESS")
	text(status,r.position+Vector2(456,60),13,C_GOLD if complete and not claimed else C_MUTED)

func draw_pass_screen() -> void:
	_f12_backdrop(C_PURPLE)
	_f12_panel(Rect2(42,42,636,102),C_PURPLE,Color("080c18"),true)
	_f12_medallion(Vector2(92,93),C_PURPLE,"pass")
	text("TOWER PASS",Vector2(140,96),33,C_TEXT)
	text("FREE SEASON PATH",Vector2(142,124),12,C_PURPLE)
	_f12_coin(Vector2(570,91),9); text("%d" % meta.coins,Vector2(590,100),21,C_GOLD)
	var level_no: int = int(tower_pass.level())
	var p: Dictionary = tower_pass.progress_to_next()
	_f12_panel(Rect2(58,178,604,188),C_PURPLE,Color("0b1020"),true)
	text("LEVEL",Vector2(84,220),13,C_MUTED); text("%d" % level_no,Vector2(84,274),46,C_TEXT); text("/ %d" % tower_pass.MAX_LEVEL,Vector2(145,274),18,C_MUTED)
	var preview_level: int = mini(tower_pass.MAX_LEVEL,level_no+1)
	var preview: Dictionary = tower_pass.reward_for(preview_level)
	text("NEXT REWARD",Vector2(430,220),13,C_MUTED); text(String(preview["label"]),Vector2(430,250),16,C_TEXT); text("%d COINS" % int(preview["coins"]),Vector2(430,279),15,C_GOLD)
	var bar := Rect2(84,310,552,18)
	_f12_panel(bar.grow(4),C_PURPLE,Color("090d18"),false)
	draw_rect(bar,Color("24223d")); draw_rect(Rect2(bar.position,Vector2(bar.size.x*float(p["ratio"]),bar.size.y)),C_PURPLE); _f12_gem(Vector2(bar.position.x+bar.size.x*float(p["ratio"]),bar.get_center().y),C_TEXT,7)
	text("%d / %d XP" % [int(p["current"]),int(p["needed"])],Vector2(84,351),13,C_MUTED)
	text("REWARD TRACK",Vector2(58,420),16,C_GOLD)
	var start_level: int = maxi(1,level_no-1)
	for i in range(5):
		var l: int = start_level+i
		if l>tower_pass.MAX_LEVEL: break
		_f12_pass_reward(l,i)
	var next_claim: int = int(tower_pass.next_claimable())
	_f12_button(PASS_CLAIM,"CLAIM LEVEL %d" % next_claim if next_claim>0 else "NO REWARD READY",C_GOLD,17,next_claim>0)
	_f12_button(OVERLAY_BACK,"BACK",C_PURPLE,18,true)
	_draw_notice(1008)

func _f12_pass_reward(level_no: int,index: int) -> void:
	var reward: Dictionary = tower_pass.reward_for(level_no)
	var unlocked: bool = level_no<=int(tower_pass.level())
	var claimable: bool = bool(tower_pass.can_claim(level_no))
	var accent: Color = C_GOLD if claimable else (C_PURPLE if unlocked else Color("444a61"))
	var r := Rect2(58,452+index*100,604,82)
	_f12_panel(r,accent,Color(accent,0.045),claimable)
	_f12_medallion(r.position+Vector2(45,41),accent,"fortune" if unlocked else "lock")
	text("LV %02d" % level_no,r.position+Vector2(84,34),16,C_TEXT)
	text(String(reward["label"]),r.position+Vector2(174,31),13,C_MUTED)
	text("+%d" % int(reward["coins"]),r.position+Vector2(174,58),15,C_GOLD)
	var status: String = "CLAIM" if claimable else ("UNLOCKED" if unlocked else "LOCKED")
	text(status,r.position+Vector2(486,49),13,C_GOLD if claimable else C_MUTED)

# -----------------------------------------------------------------------------
# Combat presentation
# -----------------------------------------------------------------------------

func _draw_room_floor() -> void:
	if tex_fantasy_biomes == null:
		super._draw_room_floor()
		return
	var area: String = String(current_room.get("area","DUNGEON"))
	var index: int = 0
	match area:
		"CRYPT": index = 1
		"FORGOTTEN CASTLE": index = 2
		"DEEP TOWER": index = 3
	var source := Rect2(float(index*648),0,648,840)
	draw_texture_rect_region(tex_fantasy_biomes,ARENA,source,Color.WHITE)
	# animated room magic over the authored background
	var accent: Color = _area_accent(area)
	for i in range(3):
		var radius: float = 120.0+float(i)*62.0
		draw_arc(ARENA.get_center(),radius,elapsed*(0.06+0.02*i)+float(i),elapsed*(0.06+0.02*i)+float(i)+PI*1.35,64,Color(accent,0.09),2.0)
	if String(current_room.get("type","")) == "ELITE":
		draw_arc(ARENA.get_center(),260,elapsed*0.16,elapsed*0.16+TAU,72,Color(C_GOLD,0.18),3)

func _draw_room_architecture() -> void:
	# The biome atlas already contains the main architecture. Keep only dynamic room props.
	var room_type: String = String(current_room.get("type","COMBAT"))
	if room_type == "TREASURE":
		_f12_draw_chest(Vector2(360,292))
	elif room_type == "AMBUSH":
		for i in range(4):
			var p := ARENA.get_center()+Vector2.from_angle(TAU*float(i)/4.0)*238.0
			var pts := PackedVector2Array([p+Vector2(0,-12),p+Vector2(10,8),p+Vector2(-10,8)])
			draw_colored_polygon(pts,Color(C_RED,0.35)); draw_polyline(PackedVector2Array([pts[0],pts[1],pts[2],pts[0]]),Color(C_ORANGE,0.50),1.5)

func _f12_draw_chest(p: Vector2) -> void:
	draw_circle(p+Vector2(0,12),60,Color(C_GOLD,0.06))
	_f12_panel(Rect2(p-Vector2(48,10),Vector2(96,54)),C_GOLD,Color("4a2d1e"),true)
	draw_colored_polygon(PackedVector2Array([p+Vector2(-45,-10),p+Vector2(-32,-34),p+Vector2(32,-34),p+Vector2(45,-10)]),Color("704326"))
	draw_line(p+Vector2(-45,-10),p+Vector2(45,-10),C_GOLD,3); draw_rect(Rect2(p.x-5,p.y-34,10,78),C_GOLD)
	_f12_gem(p+Vector2(0,13),C_PURPLE,7)

func _draw_room_badge() -> void:
	if String(current_room.get("type","")) == "BOSS": return
	var accent: Color = _area_accent(String(current_room.get("area","DUNGEON")))
	var r := Rect2(238,170,244,40)
	_f12_panel(r,accent,Color("070b14"),true)
	center_rect(room_system.room_label(current_room),r,12,C_TEXT)

func _draw_combat_hud() -> void:
	var area_name: String = String(current_room.get("area","DUNGEON"))
	var room_name: String = String(current_room.get("type","COMBAT"))
	var accent: Color = _area_accent(area_name)
	_f12_panel(Rect2(24,20,672,118),accent,Color("060a14"),true)
	text("FLOOR",Vector2(47,53),11,C_MUTED); text("%02d" % int(run.floor_no),Vector2(47,103),40,C_TEXT)
	draw_line(Vector2(120,40),Vector2(120,112),Color(C_GOLD,0.30),2)
	text(area_name,Vector2(142,67),18,C_GOLD if area_name=="DUNGEON" else accent); text(room_name,Vector2(142,97),13,C_MUTED)
	_f12_panel(Rect2(502,45,108,55),C_GOLD,Color("0b0d14"),true); _f12_coin(Vector2(523,73),8); text("%d" % int(run.run_coins),Vector2(541,82),20,C_GOLD)
	_f12_button(V10_PAUSE,"II",C_GOLD,16,true)
	# HP bar
	var hp_shell := Rect2(260,1006,320,40)
	_f12_panel(hp_shell,C_GOLD,Color("110b12"),false)
	var hp_bar := Rect2(277,1018,286,16)
	var ratio: float = clampf(run.hp/run.max_hp,0.0,1.0)
	draw_rect(hp_bar,Color("36131d")); draw_rect(Rect2(hp_bar.position,Vector2(hp_bar.size.x*ratio,hp_bar.size.y)),Color("d94b54")); draw_rect(Rect2(hp_bar.position+Vector2(2,2),Vector2(maxf(0.0,hp_bar.size.x*ratio-4),4)),Color(1,1,1,0.18))
	_f12_icon("heart",Vector2(265,1026),C_RED,0.65); center_rect("%d / %d HP" % [int(run.hp),int(run.max_hp)],hp_shell,13,C_TEXT)
	# joystick
	var base: Vector2 = joy_origin if joy_active else Vector2(145,1115)
	var knob: Vector2 = joy_pos if joy_active else base
	draw_circle(base,86,Color(0.02,0.03,0.06,0.80)); draw_arc(base,86,0,TAU,64,Color(C_GOLD,0.48),3); draw_arc(base,75,0,TAU,64,Color(C_PURPLE,0.22),2)
	for dir in [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]:
		var q: Vector2 = base + dir * 61.0
		draw_colored_polygon(PackedVector2Array([q+dir*5.0,q+dir.rotated(2.2)*7.0,q+dir.rotated(-2.2)*7.0]),Color(C_TEXT,0.25))
	draw_circle(knob,39,Color("30384c")); draw_arc(knob,39,0,TAU,40,Color(C_TEXT,0.20),2); draw_circle(knob-Vector2(8,9),8,Color(1,1,1,0.06)); text("MOVE",Vector2(111,1218),11,C_MUTED)
	# Nova
	var center: Vector2 = SKILL.get_center(); var ready: bool = float(run.skill_cd)<=0.0
	draw_circle(center,70,Color(0.02,0.03,0.07,0.90)); draw_arc(center,70,0,TAU,64,Color(C_GOLD,0.55),3); draw_circle(center,59,Color("112d65")); draw_circle(center,48,Color("154e9a"))
	var fill: float = 1.0 if ready else clampf(1.0-run.skill_cd/7.0,0.0,1.0)
	draw_arc(center,64,-PI/2.0,-PI/2.0+TAU*fill,64,C_CYAN if ready else Color("59637a"),6)
	if ready: draw_arc(center,74+sin(elapsed*4.0)*2.0,0,TAU,64,Color(C_CYAN,0.20),3)
	_f12_icon("nova",center+Vector2(0,-9),C_TEXT if ready else C_MUTED,1.15); draw_string(font,Vector2(center.x-50,center.y+27),"NOVA" if ready else "%.1f" % run.skill_cd,HORIZONTAL_ALIGNMENT_CENTER,100,14,C_TEXT)
	if floor_banner>0.0:
		var fc: Color = C_GOLD; fc.a = clampf(floor_banner,0.0,1.0); _f12_title("FLOOR %d" % run.floor_no,606,43,fc)

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	if tex_fantasy_actors == null:
		super.draw_wanderer(pos,scale,combat)
		return
	var state_name: String = player_anim_state if combat else "idle"
	var frame: int = _motion_frame(state_name,player_anim_timer,false)
	var bob: float = sin(elapsed*(7.0 if combat else 2.5))*(1.8 if combat else 1.0)
	var size: Vector2 = Vector2(104,104)*scale
	var rect := Rect2(pos.x-size.x*0.5,pos.y-size.y*0.61+bob,size.x,size.y)
	if combat:
		draw_ellipse_shadow(pos+Vector2(0,25*scale),34*scale,10*scale)
		draw_circle(pos,38*scale,Color(C_PURPLE,0.035))
	_f12_draw_actor_region(0,frame,player_facing,rect,Color.WHITE)
	if state_name=="attack": draw_arc(pos,45*scale,-0.8,0.8,24,Color(C_GOLD,0.40),4*scale)
	elif state_name=="nova": draw_arc(pos,52*scale,elapsed*2.5,elapsed*2.5+TAU,44,C_CYAN,4*scale)
	elif state_name=="hit": draw_arc(pos,48*scale,-0.4,PI+0.4,30,Color(C_RED,0.60),3*scale)

func draw_enemy(e: Dictionary) -> void:
	if tex_fantasy_actors == null:
		super.draw_enemy(e)
		return
	var kind: String = String(e["type"]); var variant: String = String(e.get("boss_variant","warden")); var row: int = _motion_row(kind,variant)
	if row<0:
		super.draw_enemy(e); return
	var p: Vector2 = e["pos"]; var radius: float = float(e["radius"]); var state_name: String = _enemy_anim_state(e); var frame: int = _motion_frame(state_name,float(e.get("anim_hit",0.0)),true)
	var facing: int = 1 if player_pos.x>=p.x else -1
	var bob: float = sin(elapsed*(9.0 if kind=="bat" else 4.2)+float(e.get("phase",0.0)))*(5.0 if kind=="bat" else 1.6)
	var size_px: float = maxf(68.0, radius * 2.9)
	if kind == "warden":
		size_px = radius * 2.85
	draw_ellipse_shadow(p+Vector2(0,radius*0.72),radius*0.86,maxf(5.0,radius*0.24))
	var rect := Rect2(p.x-size_px*0.5,p.y-size_px*0.62+bob,size_px,size_px)
	var modulate := Color.WHITE
	if bool(e.get("elite",false)): modulate = Color(1.0,0.92,0.68,1.0)
	_f12_draw_actor_region(row,frame,facing,rect,modulate)
	if bool(e.get("elite",false)):
		draw_arc(p,radius+13,elapsed,elapsed+TAU,40,C_GOLD,3); draw_string(font,p+Vector2(-42,-radius-31),"ELITE",HORIZONTAL_ALIGNMENT_CENTER,84,11,C_GOLD)
	if kind=="warden" and bool(e.get("phase2",false)):
		draw_arc(p,radius+15,elapsed*1.2,elapsed*1.2+TAU,44,C_GOLD if variant=="hollow_king" else C_CYAN,4)
	var ratio: float = clampf(float(e["hp"])/float(e["max_hp"]),0.0,1.0)
	var bar := Rect2(p.x-radius,p.y-radius-20,radius*2.0,8)
	draw_rect(bar,Color("32131b")); draw_rect(Rect2(bar.position,Vector2(bar.size.x*ratio,bar.size.y)),C_RED); draw_rect(Rect2(bar.position,Vector2(bar.size.x,bar.size.y)),Color(C_GOLD,0.25),false,1)

func _f12_draw_actor_region(row: int, frame: int, facing: int, rect: Rect2, modulate: Color) -> void:
	var column: int = frame if facing>=0 else 15-frame
	var source := Rect2(float(column*100),float(row*100),100,100)
	draw_texture_rect_region(tex_fantasy_actors,rect,source,modulate)

func draw_effect(fx: Dictionary) -> void:
	if String(fx.get("type","")) != "actor_death" or tex_fantasy_actors == null:
		super.draw_effect(fx)
		return
	var row: int = _motion_row(String(fx.get("kind","")),String(fx.get("variant","warden")))
	if row<0: return
	var t: float = clampf(float(fx["age"])/float(fx["dur"]),0.0,1.0)
	var size_px: float = float(fx.get("size",72.0))*(1.0-t*0.12)
	var p: Vector2 = fx["pos"]+Vector2(0,t*12)
	var rect := Rect2(p.x-size_px*0.5,p.y-size_px*0.60,size_px,size_px)
	_f12_draw_actor_region(row,7,1,rect,Color(1,1,1,1.0-t))

func draw_player_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot["pos"]; var dir: Vector2 = shot["vel"].normalized(); var c: Color = C_GOLD if bool(shot["crit"]) else C_CYAN
	draw_line(p-dir*34,p+dir*8,Color(c,0.10),12 if bool(shot["crit"]) else 8); draw_line(p-dir*24,p+dir*8,Color(c,0.48),6 if bool(shot["crit"]) else 4); draw_line(p-dir*12,p+dir*8,C_TEXT,2); draw_circle(p,5 if bool(shot["crit"]) else 4,c)

func draw_enemy_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot["pos"]; var c: Color = shot["color"]; var pulse: float = 1.0+sin(elapsed*9.0+p.x*0.03)*0.10
	draw_circle(p,14*pulse,Color(c,0.07)); draw_circle(p,9*pulse,Color(c,0.18)); draw_circle(p,5*pulse,c); draw_circle(p-Vector2(2,2),2,C_TEXT)

func draw_coin_orb(orb: Dictionary) -> void:
	var p: Vector2 = orb["pos"]; var pulse: float = 1.0+sin(elapsed*8.0+p.x)*0.12
	draw_circle(p,16*pulse,Color(C_GOLD,0.07)); _f12_coin(p,8*pulse)

# -----------------------------------------------------------------------------
# Run overlays / upgrade / results
# -----------------------------------------------------------------------------

func draw_upgrade() -> void:
	_f12_backdrop(C_PURPLE)
	_f12_gem(Vector2(360,68),C_PURPLE,15)
	_f12_title("FLOOR CLEARED!",154,45,C_GOLD)
	_f12_title("Choose an Upgrade",216,29,C_TEXT)
	draw_string(font,Vector2(80,258),"Build the run. Break the tower.",HORIZONTAL_ALIGNMENT_CENTER,560,17,C_MUTED)
	for i in range(upgrade_options.size()):
		var r: Rect2 = upgrade_rect(i); var u: Dictionary = upgrade_options[i]; var accent: Color = u["color"]
		_f12_panel(r,accent,Color(accent,0.055),true)
		_f12_medallion(r.position+Vector2(67,69),accent,String(u["kind"]))
		text(String(u["name"]),r.position+Vector2(116,58),24,C_TEXT)
		text(String(u["desc"]),r.position+Vector2(116,96),17,C_MUTED)
		_f12_gem(Vector2(r.end.x-22,r.get_center().y),accent,7)
	draw_center("Tap an upgrade to continue.",982,16,C_MUTED)
	if tutorial_active and tutorial_step==4: _draw_tutorial_overlay()

func draw_decision() -> void:
	_f12_backdrop(C_GOLD)
	_f12_title("TAKE THE LOOT?",200,42,C_TEXT); draw_center("OR",258,18,C_MUTED); _f12_title("ONE MORE FLOOR",330,49,C_GOLD)
	_f12_panel(Rect2(118,420,484,230),C_GOLD,Color("0b101c"),true)
	draw_center("RUN LOOT",468,16,C_MUTED); _f12_coin(Vector2(300,536),14); _f12_title("%d COINS" % run.run_coins,548,43,C_GOLD); draw_center("Floor %d cleared" % run.floor_no,602,20,C_TEXT)
	_f12_button(CASH,"CASH OUT",C_GREEN,23,true); _f12_button(NEXT,"ONE MORE FLOOR",C_GOLD,21,true)
	draw_center("Death keeps only 60% of unsecured coins.",1040,16,C_MUTED)

func draw_game_over() -> void:
	_f12_backdrop(C_RED)
	_f12_title("RUN ENDED",230,52,C_RED); draw_center("The tower wins this time.",292,20,C_MUTED)
	_f12_panel(Rect2(118,410,484,260),C_PURPLE,Color("0b101d"),true)
	_f12_icon("hero",Vector2(360,458),C_MUTED,1.4); _f12_title("FLOOR %d" % run.floor_no,530,43,C_TEXT); _f12_title("%d coins secured" % run.saved_after_death,596,24,C_GOLD)
	_f12_button(RETRY,"RETRY",C_GOLD,27,true); _f12_button(HOME_BTN,"HOME",C_PURPLE,27,true)

func _draw_pause_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO,SIZE),Color(0.01,0.012,0.025,0.86))
	_f12_panel(Rect2(112,330,496,520),C_PURPLE,Color("090d19"),true)
	_f12_gem(Vector2(360,380),C_PURPLE,14); _f12_title("PAUSED",425,43,C_TEXT); draw_center("Floor %d  •  %s" % [int(run.floor_no),String(current_room.get("area","TOWER"))],462,15,C_MUTED)
	_f12_button(V10_RESUME,"RESUME",C_GREEN,21,true); _f12_button(V10_PAUSE_SETTINGS,"SETTINGS",C_BLUE,19,true); _f12_button(V10_PAUSE_HOME,"RETURN HOME",C_PURPLE,19,true)

func _draw_settings_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO,SIZE),Color(0.01,0.012,0.025,0.92))
	_f12_panel(Rect2(66,160,588,760),C_BLUE,Color("090d19"),true)
	_f12_gem(Vector2(360,204),C_BLUE,12); _f12_title("SETTINGS",246,39,C_TEXT); draw_center("Playtest controls & privacy",280,15,C_MUTED)
	_f12_button(V10_SET_MUSIC,"MUSIC  %s   %d%%" % [_on_off(bool(settings.music_enabled)),int(float(settings.music_volume)*100.0)],C_GREEN,17,bool(settings.music_enabled))
	_f12_button(V10_SET_SFX,"SFX  %s   %d%%" % [_on_off(bool(settings.sfx_enabled)),int(float(settings.sfx_volume)*100.0)],C_GREEN,17,bool(settings.sfx_enabled))
	_f12_button(V10_SET_HAPTICS,"HAPTICS  %s" % _on_off(bool(settings.haptics_enabled)),C_GREEN,17,bool(settings.haptics_enabled))
	_f12_button(V10_SET_ANALYTICS,"ANALYTICS  %s" % _on_off(bool(settings.analytics_enabled)),C_GOLD,17,true)
	_f12_button(V10_SET_TUTORIAL,"REPLAY TUTORIAL",C_PURPLE,17,true); _f12_button(V10_SET_BACK,"BACK",C_BLUE,19,true)
	draw_string(font,Vector2(96,895),"Analytics is opt-in. Playtest events stay local in this build.",HORIZONTAL_ALIGNMENT_CENTER,528,12,C_MUTED)

func _draw_tutorial_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO,SIZE),Color(0.01,0.012,0.025,0.89))
	_f12_panel(Rect2(82,260,556,700),C_GOLD,Color("090d19"),true)
	var title_value: String = "WELCOME TO THE TOWER"; var body_a: String = "Move. Auto-attack. Survive."; var body_b: String = "Every cleared floor asks one question: climb again or bank the loot?"; var button_text: String = "NEXT"
	match tutorial_step:
		1:
			title_value="RISK VS REWARD"; body_a="Pick one of three run upgrades after every floor."; body_b="Cash out to secure everything. Death only keeps part of unsecured coins."; button_text="START TUTORIAL RUN"
		2:
			title_value="ONE-THUMB COMBAT"; body_a="Drag the left joystick to dodge. Attacks fire automatically at nearby enemies."; body_b="Tap NOVA when ready: it damages nearby enemies and clears hostile projectiles."; button_text="GOT IT"
		4:
			title_value="BUILD THE RUN"; body_a="Choose one upgrade now. Your build changes every climb."; body_b="After the upgrade you can CASH OUT or press ONE MORE FLOOR."; button_text="FINISH TUTORIAL"
	_f12_gem(Vector2(360,318),C_GOLD,13); _f12_title(title_value,372,28,C_GOLD)
	draw_string(font,Vector2(122,470),body_a,HORIZONTAL_ALIGNMENT_CENTER,476,16,C_TEXT); draw_string(font,Vector2(122,545),body_b,HORIZONTAL_ALIGNMENT_CENTER,476,15,C_MUTED)
	if tutorial_step==2:
		_f12_medallion(Vector2(160,670),C_BLUE,"range"); _f12_medallion(Vector2(560,670),C_CYAN,"nova"); draw_string(font,Vector2(90,748),"MOVE",HORIZONTAL_ALIGNMENT_CENTER,140,15,C_BLUE); draw_string(font,Vector2(490,748),"NOVA",HORIZONTAL_ALIGNMENT_CENTER,140,15,C_CYAN)
	_f12_button(V10_TUTORIAL_NEXT,button_text,C_GOLD,19,true)
