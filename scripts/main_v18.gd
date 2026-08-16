extends "res://scripts/main_v17.gd"

const V18_VERSION := "1.6.2-premium-reference"
const V18_HOME_ART := "res://assets/art/concept_home_v16.svg"
const V18_ARCANE_ART := "res://assets/art/concept_arcane_v16.svg"
const V18_FORGE_ART := "res://assets/art/menu_forge_final.svg"
const V18_HIFI_BACKDROP := "res://assets/art/hifi_menu_backdrop.svg"
const V18_CITADEL_ART := "res://assets/art/premium_menu_citadel.svg"
const V18_ROOM_FOREGROUND := "res://assets/art/premium_room_foreground.svg"

var tex_v18_home: Texture2D
var tex_v18_arcane: Texture2D
var tex_v18_forge: Texture2D
var tex_v18_hifi: Texture2D
var tex_v18_citadel: Texture2D
var tex_v18_room: Texture2D

func _ready() -> void:
	super._ready()
	tex_v18_home = load(V18_HOME_ART) as Texture2D
	tex_v18_arcane = load(V18_ARCANE_ART) as Texture2D
	tex_v18_forge = load(V18_FORGE_ART) as Texture2D
	tex_v18_hifi = load(V18_HIFI_BACKDROP) as Texture2D
	tex_v18_citadel = load(V18_CITADEL_ART) as Texture2D
	tex_v18_room = load(V18_ROOM_FOREGROUND) as Texture2D
	queue_redraw()

# Premium-reference backdrop compositor.
# The approved screenshots are treated as composition targets: a large cinematic
# environment first, UI second. Existing gameplay and touch hitboxes stay intact.
func _v16_backdrop(kind: String = "arcane", dim: float = 0.0) -> void:
	if kind == "home":
		if tex_v18_hifi != null:
			draw_texture_rect(tex_v18_hifi, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)
		elif tex_v18_home != null:
			draw_texture_rect(tex_v18_home, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)
		else:
			super._v16_backdrop(kind, dim)
		# The citadel is now the hero image, not a small flat silhouette.
		if tex_v18_citadel != null:
			draw_texture_rect(tex_v18_citadel, Rect2(0, 278, 720, 640), false, Color(1,1,1,0.99))
		_v18_arcane_crown(Vector2(360, 405), 252.0, V16_PURPLE)
		_v18_star_field(0.42)
	elif kind == "forge":
		if tex_v18_forge != null:
			draw_texture_rect(tex_v18_forge, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)
		else:
			super._v16_backdrop(kind, dim)
		_v18_star_field(0.14)
	else:
		if tex_v18_hifi != null:
			draw_texture_rect(tex_v18_hifi, Rect2(Vector2.ZERO, SIZE), false, Color(0.93,0.90,1.0,1.0))
		elif tex_v18_arcane != null:
			draw_texture_rect(tex_v18_arcane, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)
		else:
			super._v16_backdrop(kind, dim)
		# Deep-tower foreground gives Hero/Missions/Talents/Vault actual room depth.
		if tex_v18_room != null:
			draw_texture_rect_region(tex_v18_room, Rect2(0,250,720,840), Rect2(0,2520,720,840), Color(1,1,1,0.82))
		_v18_arcane_crown(Vector2(360, 410), 275.0, V16_PURPLE)
		_v18_star_field(0.28)

	# Strong cinematic edge falloff instead of a flat full-screen tint.
	draw_rect(Rect2(0,0,58,1280), Color(0,0,0,0.38))
	draw_rect(Rect2(662,0,58,1280), Color(0,0,0,0.38))
	draw_rect(Rect2(0,0,720,74), Color(0,0,0,0.23))
	draw_rect(Rect2(0,1180,720,100), Color(0,0,0,0.24))
	if dim > 0.0:
		draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0,0,0,dim))

func _v18_arcane_crown(center: Vector2, radius: float, accent: Color) -> void:
	for i: int in range(4):
		var r: float = radius - float(i) * 25.0
		draw_arc(center, r, -2.78, -0.36, 96, Color(accent, 0.16 - float(i)*0.025), 1.6)
	for angle: float in [-2.45,-2.02,-1.57,-1.12,-0.69]:
		var p: Vector2 = center + Vector2(cos(angle),sin(angle))*radius
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-4),p+Vector2(4,0),p+Vector2(0,4),p+Vector2(-4,0)]),Color(V17_PURPLE_HI,0.45))

func _v18_star_field(alpha_scale: float) -> void:
	var stars: Array[Vector2] = [
		Vector2(74,120),Vector2(151,167),Vector2(246,92),Vector2(311,146),Vector2(421,111),
		Vector2(521,175),Vector2(635,103),Vector2(681,246),Vector2(53,301),Vector2(216,286),
		Vector2(494,278),Vector2(603,338),Vector2(113,372),Vector2(274,349),Vector2(451,368)
	]
	for i: int in range(stars.size()):
		var rr: float = 1.0 + float(i % 3) * 0.45
		draw_circle(stars[i], rr, Color(0.78,0.64,1.0,alpha_scale*(0.38+float(i%4)*0.08)))

# Smaller, integrated medallions keep the controls premium instead of oversized.
func _v16_button(r: Rect2, label: String, accent: Color, size: int, icon_index: int = -1, enabled: bool = true) -> void:
	var a: Color = accent if enabled else Color("60657a")
	_v17_skin(r, a, enabled)
	if tex_v17_skins == null:
		_v16_frame(r, a, Color(a,0.09) if enabled else Color("141824"), 0.18 if enabled else 0.03)
	# Crisp inner bevel and subtle top highlight.
	draw_rect(r.grow(-7), Color(a,0.17 if enabled else 0.06), false, 1.0)
	draw_line(r.position+Vector2(14,7), Vector2(r.end.x-14,r.position.y+7), Color(1,1,1,0.11 if enabled else 0.04), 1.0)
	var text_color: Color = V17_IVORY if enabled else Color("8c8fa0")
	if icon_index >= 0:
		var radius: float = clampf(r.size.y*0.24, 14.0, 21.0)
		var cx: float = r.position.x + maxf(29.0, radius+13.0)
		_v16_medallion(Vector2(cx,r.get_center().y),radius,a,icon_index)
		draw_string(v16_title_font,Vector2(r.position.x+radius*2.0+25.0,r.get_center().y+float(size)*0.33),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-radius*2.0-38.0,size,text_color)
	else:
		draw_string(v16_title_font,Vector2(r.position.x+10,r.get_center().y+float(size)*0.34),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-20,size,text_color)

func _v16_home_tab(r: Rect2, label: String, icon_index: int, accent: Color) -> void:
	_v17_skin(r,accent,true)
	draw_rect(r.grow(-7),Color(accent,0.14),false,1.0)
	var radius: float = clampf(r.size.y*0.20,16.0,19.0)
	_v16_medallion(Vector2(r.get_center().x,r.position.y+31),radius,accent,icon_index)
	draw_string(v16_title_font,Vector2(r.position.x+5,r.position.y+88),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-10,14,V17_IVORY)

func _v18_reward_chest(center: Vector2, scale: float = 1.0) -> void:
	var s: float = scale
	# Compact concept chest illustration: dark wood, gold hardware, coin spill.
	draw_ellipse_coin_spill(center + Vector2(0,36*s), s)
	var body := Rect2(center + Vector2(-52,-6)*s, Vector2(104,62)*s)
	draw_rect(body, Color("4a2415"))
	draw_rect(body.grow(-4*s), Color("6b341c"))
	draw_rect(Rect2(center + Vector2(-52,-31)*s, Vector2(104,34)*s), Color("3b1c12"))
	draw_arc(center + Vector2(0,-3)*s, 52*s, PI, TAU, 32, Color("c88d32"), 7*s)
	for x: float in [-39.0, 0.0, 39.0]:
		draw_rect(Rect2(center + Vector2(x-5,-31)*s, Vector2(10,87)*s), Color("b97925"))
		draw_line(center + Vector2(x,-27)*s, center + Vector2(x,52)*s, Color("ffd86c"), 1.2*s)
	var lock := Rect2(center + Vector2(-14,8)*s, Vector2(28,30)*s)
	draw_rect(lock, Color("d3a03d"))
	draw_rect(lock.grow(-4*s), Color("7e4e16"))
	draw_circle(center + Vector2(0,17)*s, 5*s, Color("ffe48a"))
	draw_line(center + Vector2(0,21)*s, center + Vector2(0,31)*s, Color("ffe48a"), 3*s)

func draw_ellipse_coin_spill(center: Vector2, scale: float) -> void:
	var offsets: Array[Vector2] = [Vector2(-48,11),Vector2(-31,20),Vector2(-12,12),Vector2(9,22),Vector2(31,12),Vector2(49,21),Vector2(-22,31),Vector2(2,34),Vector2(27,31)]
	for off: Vector2 in offsets:
		var p: Vector2 = center + off * scale
		draw_circle(p, 8.0*scale, Color("9a6218"))
		draw_circle(p, 6.0*scale, Color("edb63f"))
		draw_arc(p, 4.0*scale, 0, TAU, 18, Color("fff0a1"), 1.0*scale)

# Tower Pass follows the supplied reference and fixes the old overlapping level plaque.
func draw_pass_screen() -> void:
	_v16_header("TOWER PASS", "FREE SEASON PATH", V16_PURPLE, 6, "arcane")
	var level_no: int = int(tower_pass.level())
	var max_level: int = int(tower_pass.MAX_LEVEL)
	var progress: Dictionary = tower_pass.progress_to_next()
	var top := Rect2(46,218,628,270)
	_v16_frame(top, V16_GOLD, Color("060a13"), 0.24)
	var plaque := Rect2(72,246,150,152)
	_v16_frame(plaque, V16_PURPLE, Color("10091e"), 0.22)
	draw_string(v16_body_font,Vector2(plaque.position.x+8,plaque.position.y+35),"LEVEL",HORIZONTAL_ALIGNMENT_CENTER,plaque.size.x-16,13,V16_MUTED)
	draw_string(v16_title_font,Vector2(plaque.position.x+8,plaque.position.y+100),str(level_no),HORIZONTAL_ALIGNMENT_CENTER,plaque.size.x-16,56,V17_IVORY)
	draw_string(v16_title_font,Vector2(plaque.position.x+8,plaque.position.y+136),"/ %d" % max_level,HORIZONTAL_ALIGNMENT_CENTER,plaque.size.x-16,18,V16_MUTED)
	var reward_level: int = mini(max_level, maxi(1, level_no + 1))
	if level_no >= max_level:
		reward_level = max_level
	var reward: Dictionary = tower_pass.reward_for(reward_level)
	_v16_text("NEXT REWARD", Vector2(258,270), 13, V16_MUTED)
	_v16_text(String(reward.get("label","BIG COIN CACHE")), Vector2(258,308), 23, V17_GOLD_HI, true)
	_v16_text("%d COINS" % int(reward.get("coins",0)), Vector2(258,344), 18, V17_IVORY)
	_v18_reward_chest(Vector2(566,317),0.62)
	var bar := Rect2(78,430,564,24)
	draw_rect(bar,Color("17102b"))
	var filled_width: float = bar.size.x*float(progress["ratio"])
	if filled_width > 0.0:
		draw_rect(Rect2(bar.position,Vector2(filled_width,bar.size.y)),Color("8d3ed8"))
		draw_line(bar.position+Vector2(4,3),Vector2(bar.position.x+maxf(4.0,filled_width-4.0),bar.position.y+3),Color("df9cff"),2.0)
	_v16_center("%d / %d XP" % [int(progress["current"]),int(progress["needed"])],476,14,V17_IVORY)
	_v16_section("REWARD TRACK",536,V17_GOLD)

	var levels: Array[int] = []
	if level_no <= 1:
		levels = [1, mini(2,max_level)]
	else:
		levels = [maxi(1,level_no-1), mini(max_level,level_no)]
	for i: int in range(levels.size()):
		var l: int = levels[i]
		var rr: Dictionary = tower_pass.reward_for(l)
		var row := Rect2(105,586 + i*154, 550, 128)
		var unlocked: bool = l <= level_no
		var claimable: bool = bool(tower_pass.can_claim(l))
		var accent: Color = V16_PURPLE
		if claimable:
			accent = V16_PURPLE_HI
		elif unlocked:
			accent = V16_GOLD
		_v16_frame(row,accent,Color("060a13"),0.20)
		var badge_center := Vector2(78,row.get_center().y)
		draw_colored_polygon(PackedVector2Array([badge_center+Vector2(0,-42),badge_center+Vector2(42,0),badge_center+Vector2(0,42),badge_center+Vector2(-42,0)]),Color("090716"))
		draw_polyline(PackedVector2Array([badge_center+Vector2(0,-42),badge_center+Vector2(42,0),badge_center+Vector2(0,42),badge_center+Vector2(-42,0),badge_center+Vector2(0,-42)]),V16_PURPLE_HI,3.0)
		draw_string(v16_title_font,Vector2(43,row.get_center().y+7),"LV %d" % l,HORIZONTAL_ALIGNMENT_CENTER,70,18,V17_IVORY)
		if String(rr.get("label","")) == "BIG COIN CACHE":
			_v18_reward_chest(Vector2(row.position.x+83,row.get_center().y-2),0.35)
		else:
			_v16_medallion(Vector2(row.position.x+77,row.get_center().y),30,V16_GOLD,11)
		_v16_text(String(rr.get("label","COINS")),row.position+Vector2(150,47),20,V17_GOLD_HI,true)
		_v16_text("+%d" % int(rr.get("coins",0)),row.position+Vector2(150,82),18,V17_IVORY)
		var status: String = "CLAIM" if claimable else ("UNLOCKED" if unlocked else "LOCKED")
		var status_color: Color = V16_GREEN if unlocked and not claimable else (V17_GOLD_HI if claimable else V16_MUTED)
		draw_string(v16_title_font,Vector2(row.end.x-150,row.get_center().y+7),status,HORIZONTAL_ALIGNMENT_CENTER,130,18,status_color)

	var next_claim: int = int(tower_pass.next_claimable())
	_v16_button(PASS_CLAIM,"CLAIM LEVEL %d" % next_claim if next_claim > 0 else "NO REWARD READY",V16_GOLD if next_claim > 0 else Color("5a5c66"),22,-1,next_claim > 0)
	_v16_button(OVERLAY_BACK,"‹  BACK",V16_BLUE,17)
	_draw_notice(1015)

# Vault is intentionally its own destination. Crafting remains available inside it,
# but the screen name is VAULT exactly as requested.
func draw_vault_screen() -> void:
	_v16_header("VAULT","Compare, lock, equip, dismantle and craft gear",V16_GOLD,10,"arcane")
	var bonuses: Dictionary = loot.equipped_bonuses()
	var info := Rect2(48,202,624,64)
	_v16_frame(info,V16_GOLD,Color("09101b"),0.12)
	_v16_medallion(Vector2(78,234),18,V16_PURPLE,10)
	_v16_text("SOUL SHARDS  %d" % int(loot.shards),Vector2(108,241),15,C_CYAN,true)
	_v16_text("DMG +%.1f%%   HP +%d   CRIT +%.1f%%" % [float(bonuses["damage_pct"])*100.0,int(round(float(bonuses["hp"]))),float(bonuses["crit_pct"])*100.0],Vector2(314,241),12,V16_TEXT)
	_v16_button(V8_FILTER,"FILTER: %s" % String(V8_FILTERS[vault_filter_index]).to_upper(),V16_PURPLE,12)
	_v16_button(V8_SORT,"SORT: %s" % String(V8_SORTS[vault_sort_index]).to_upper(),V16_BLUE,12)
	var selected: Dictionary = _selected_vault_item_v08()
	var lock_label: String = "LOCK ITEM"
	var lock_color: Color = Color("666a79")
	if not selected.is_empty():
		lock_label = "UNLOCK" if loot.is_locked(selected) else "LOCK"
		lock_color = C_CYAN if loot.is_locked(selected) else V16_GOLD
	_v16_button(V8_LOCK,lock_label,lock_color,12,-1,not selected.is_empty())
	var visible: Array[int] = _visible_vault_indices()
	var first: int = vault_page*V8_PAGE_SIZE
	if visible.is_empty():
		_v16_center("NO ITEMS IN THIS FILTER",510,22,V16_MUTED,true)
	else:
		for local_index: int in range(V8_PAGE_SIZE):
			var page_pos: int = first+local_index
			if page_pos >= visible.size():
				break
			var global_index: int = int(visible[page_pos])
			var item: Dictionary = loot.inventory[global_index]
			_v16_vault_item(item,local_index,String(item.get("id","")) == selected_vault_id)
	_v16_vault_comparison(selected)
	_v16_button(V8_EQUIP,"EQUIP",V16_GREEN,13,8,not selected.is_empty())
	var can_dismantle: bool = not selected.is_empty() and not loot.is_locked(selected) and not loot.is_equipped(selected)
	var dismantle_label: String = "DISMANTLE" if selected.is_empty() else "DISMANTLE +%d" % int(loot.dismantle_value(selected))
	_v16_button(V8_DISMANTLE,dismantle_label,V16_RED,12,7,can_dismantle)
	_v16_button(V8_PREV,"‹",V16_PURPLE,20,-1,vault_page > 0)
	_v16_button(V8_NEXT,"›",V16_PURPLE,20,-1,vault_page < _vault_max_page())
	var craft_ready: bool = int(loot.shards) >= int(loot.craft_cost())
	_v16_button(V8_CRAFT_WEAPON,"CRAFT WEAPON",V16_PURPLE,11,6,craft_ready)
	_v16_button(V8_CRAFT_ARMOR,"CRAFT ARMOR",V16_PURPLE,11,8,craft_ready)
	_v16_button(V8_CRAFT_RELIC,"CRAFT RELIC",V16_PURPLE,11,10,craft_ready)
	_v16_center("CRAFT %d SHARDS  •  GUARANTEED RARE+" % int(loot.craft_cost()),1053,12,V16_PURPLE_HI)
	_v16_button(META_BACK,"‹  BACK",V16_PURPLE,17)
	_draw_notice(1117)
