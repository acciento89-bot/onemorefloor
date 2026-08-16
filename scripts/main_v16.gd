extends "res://scripts/main_v15.gd"

const V16_VERSION := "1.5.0-rc1"
const V16_HOME_ART := "res://assets/art/menu_home_final.svg"
const V16_ARCANE_ART := "res://assets/art/menu_arcane_final.svg"
const V16_FORGE_ART := "res://assets/art/menu_forge_final.svg"

const V16_NAVY := Color("07101d")
const V16_NAVY_2 := Color("0b1526")
const V16_GOLD := Color("e8b64f")
const V16_GOLD_HI := Color("fff0a6")
const V16_PURPLE := Color("9c51ec")
const V16_PURPLE_HI := Color("d9a5ff")
const V16_BLUE := Color("42baf5")
const V16_GREEN := Color("55e98e")
const V16_ORANGE := Color("f39a49")
const V16_RED := Color("e55a68")
const V16_TEXT := Color("f4ecdf")
const V16_MUTED := Color("aaa7c0")

var tex_v16_home: Texture2D
var tex_v16_arcane: Texture2D
var tex_v16_forge: Texture2D
var v16_title_font: SystemFont
var v16_body_font: SystemFont

func _ready() -> void:
	super._ready()
	tex_v16_home = load(V16_HOME_ART) as Texture2D
	tex_v16_arcane = load(V16_ARCANE_ART) as Texture2D
	tex_v16_forge = load(V16_FORGE_ART) as Texture2D
	v16_title_font = SystemFont.new()
	v16_title_font.font_names = PackedStringArray(["Georgia", "Times New Roman", "DejaVu Serif"])
	v16_title_font.font_weight = 650
	v16_title_font.allow_system_fallback = true
	_configure_crisp_font(v16_title_font)
	v16_body_font = SystemFont.new()
	v16_body_font.font_names = PackedStringArray(["Avenir Next", "Helvetica Neue", "DejaVu Sans"])
	v16_body_font.font_weight = 500
	v16_body_font.allow_system_fallback = true
	_configure_crisp_font(v16_body_font)
	queue_redraw()

func _configure_crisp_font(target: SystemFont) -> void:
	# The UI is authored at 720x1280 and contains many 11-18 px labels. Force
	# high-quality rasterization so those glyphs do not turn soft after canvas
	# scaling on Retina/HiDPI displays or in the desktop preview.
	target.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	target.hinting = TextServer.HINTING_NORMAL
	target.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_ONE_QUARTER
	target.oversampling = 2.0
	target.disable_embedded_bitmaps = true

# -----------------------------------------------------------------------------
# Shared final-menu design language
# -----------------------------------------------------------------------------

func _v16_backdrop(kind: String = "arcane", dim: float = 0.0) -> void:
	var texture: Texture2D = tex_v16_arcane
	if kind == "home":
		texture = tex_v16_home
	elif kind == "forge":
		texture = tex_v16_forge
	if texture != null:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)
	else:
		_v12_background(V16_PURPLE)
	if dim > 0.0:
		draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.0, 0.0, 0.02, dim))

func _v16_center(label: String, y: float, size: int, color: Color = V16_TEXT, use_title: bool = false) -> void:
	var f: Font = v16_title_font if use_title else v16_body_font
	draw_string(f, Vector2(40, y), label, HORIZONTAL_ALIGNMENT_CENTER, 640, size, color)

func _v16_text(label: String, pos: Vector2, size: int, color: Color = V16_TEXT, use_title: bool = false) -> void:
	var f: Font = v16_title_font if use_title else v16_body_font
	draw_string(f, pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1.0, size, color)

func _v16_title(label: String, y: float, size: int, accent: Color = V16_GOLD) -> void:
	# Warm shadow + ivory face + metallic highlight give the title more depth than a flat label.
	draw_string(v16_title_font, Vector2(40, y + 3), label, HORIZONTAL_ALIGNMENT_CENTER, 640, size, Color(0, 0, 0, 0.86))
	draw_string(v16_title_font, Vector2(40, y + 1), label, HORIZONTAL_ALIGNMENT_CENTER, 640, size, Color(accent, 0.62))
	draw_string(v16_title_font, Vector2(40, y), label, HORIZONTAL_ALIGNMENT_CENTER, 640, size, V16_TEXT)
	draw_string(v16_title_font, Vector2(40, y - 1), label, HORIZONTAL_ALIGNMENT_CENTER, 640, size, Color(accent, 0.70))
	_v16_rule(y + 19.0, accent, 430.0)

func _v16_rule(y: float, accent: Color, width: float) -> void:
	var x0: float = 360.0 - width * 0.5
	var x1: float = 360.0 + width * 0.5
	draw_line(Vector2(x0, y), Vector2(340, y), Color(accent, 0.66), 1.5)
	draw_line(Vector2(380, y), Vector2(x1, y), Color(accent, 0.66), 1.5)
	var p := Vector2(360, y)
	draw_colored_polygon(PackedVector2Array([p + Vector2(0,-8),p + Vector2(8,0),p + Vector2(0,8),p + Vector2(-8,0)]), Color(accent,0.96))
	draw_colored_polygon(PackedVector2Array([p + Vector2(0,-3),p + Vector2(3,0),p + Vector2(0,3),p + Vector2(-3,0)]), V16_GOLD_HI)

func _v16_frame(r: Rect2, accent: Color, fill: Color = V16_NAVY, glow: float = 0.15) -> void:
	# layered shadow
	draw_rect(Rect2(r.position + Vector2(7,8), r.size), Color(0,0,0,0.48))
	draw_rect(r.grow(5), Color(accent, 0.055 + glow * 0.10))
	# outer metal and dark inset
	draw_rect(r, Color("02050a"))
	draw_rect(r.grow(-2), Color(accent, 0.90), false, 2.0)
	draw_rect(r.grow(-6), fill)
	draw_rect(r.grow(-8), Color(accent, 0.16), false, 1.0)
	# top bevel and bottom depth
	draw_line(r.position + Vector2(14,7), Vector2(r.end.x-14,r.position.y+7), Color(1,1,1,0.10), 1.0)
	draw_line(Vector2(r.position.x+14,r.end.y-7), r.end-Vector2(14,7), Color(0,0,0,0.66), 2.0)
	# corner clasps
	_v16_corner(r.position + Vector2(8,8), Vector2(1,1), accent)
	_v16_corner(Vector2(r.end.x-8,r.position.y+8), Vector2(-1,1), accent)
	_v16_corner(Vector2(r.position.x+8,r.end.y-8), Vector2(1,-1), accent)
	_v16_corner(r.end-Vector2(8,8), Vector2(-1,-1), accent)

func _v16_corner(p: Vector2, direction: Vector2, accent: Color) -> void:
	draw_line(p, p + Vector2(direction.x*15.0,0), Color(accent,0.92), 2.0)
	draw_line(p, p + Vector2(0,direction.y*15.0), Color(accent,0.92), 2.0)
	var q := p + direction * 4.0
	draw_colored_polygon(PackedVector2Array([q+Vector2(0,-3),q+Vector2(3,0),q+Vector2(0,3),q+Vector2(-3,0)]), Color(accent,0.92))

func _v16_button(r: Rect2, label: String, accent: Color, size: int, icon_index: int = -1, enabled: bool = true) -> void:
	var a: Color = accent if enabled else Color("60657a")
	_v16_frame(r, a, Color(a, 0.095) if enabled else Color("141824"), 0.20 if enabled else 0.03)
	var inner: Rect2 = r.grow(-9)
	if enabled:
		draw_rect(inner, Color(a, 0.045))
		draw_line(inner.position + Vector2(8,2), Vector2(inner.end.x-8,inner.position.y+2), Color(a,0.30), 2.0)
	if icon_index >= 0:
		_v16_medallion(Vector2(r.position.x+38,r.get_center().y), 24.0, a, icon_index)
		draw_string(v16_body_font, Vector2(r.position.x+68,r.get_center().y+7), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x-82, size, V16_TEXT if enabled else V16_MUTED)
	else:
		draw_string(v16_title_font if size >= 24 else v16_body_font, Vector2(r.position.x+8,r.get_center().y+size*0.31), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x-16, size, V16_TEXT if enabled else V16_MUTED)

func _v16_medallion(center: Vector2, radius: float, accent: Color, icon_index: int) -> void:
	draw_circle(center, radius + 5.0, Color(0,0,0,0.58))
	draw_circle(center, radius + 2.0, Color("080c16"))
	draw_arc(center, radius+2.0, 0, TAU, 44, V16_GOLD, 2.0)
	draw_arc(center, radius-2.0, 0, TAU, 44, Color(accent,0.72), 2.0)
	_v12_icon(icon_index, Rect2(center-Vector2(radius*0.72,radius*0.72), Vector2(radius*1.44,radius*1.44)))
	var gem := center + Vector2(0,-radius-2)
	draw_colored_polygon(PackedVector2Array([gem+Vector2(0,-5),gem+Vector2(5,0),gem+Vector2(0,5),gem+Vector2(-5,0)]), V16_PURPLE)

func _v16_currency(amount: int, r: Rect2 = Rect2(522,42,164,64)) -> void:
	_v16_frame(r, V16_GOLD, Color("080d18"), 0.18)
	_v16_medallion(Vector2(r.position.x+34,r.get_center().y), 21.0, V16_GOLD, 11)
	_v16_text(str(amount), Vector2(r.position.x+67,r.position.y+42), 23, V16_GOLD_HI, true)

func _v16_header(title: String, subtitle: String, accent: Color, icon_index: int, kind: String = "arcane") -> void:
	_v16_backdrop(kind)
	_v16_medallion(Vector2(360,72), 28.0, accent, icon_index)
	_v16_title(title, 137, 46, accent)
	_v16_center(subtitle, 181, 16, V16_MUTED)
	_v16_currency(int(meta.coins))
	_v16_button(META_BACK, "‹  BACK", V16_PURPLE, 17)
	if meta_notice_time > 0.0:
		_v16_center(meta_notice, 1090, 16, C_GREEN if meta_notice.begins_with("UPGRADE") else C_RED)

func _v16_section(label: String, y: float, accent: Color) -> void:
	_v16_text(label, Vector2(55,y), 18, accent, true)
	draw_line(Vector2(55,y+9),Vector2(192,y+9),Color(accent,0.45),1.0)
	var p := Vector2(205,y+9)
	draw_colored_polygon(PackedVector2Array([p+Vector2(0,-4),p+Vector2(4,0),p+Vector2(0,4),p+Vector2(-4,0)]),Color(accent,0.86))

# -----------------------------------------------------------------------------
# HOME — final menu hierarchy
# -----------------------------------------------------------------------------

func draw_home() -> void:
	if home_overlay == "missions":
		draw_missions_screen()
		return
	if home_overlay == "pass":
		draw_pass_screen()
		return
	_v16_backdrop("home")
	_v16_frame(Rect2(28,32,182,84), V16_PURPLE, Color("080c16"), 0.15)
	_v16_text("BEST FLOOR", Vector2(48,62), 11, V16_MUTED)
	_v16_text("%02d" % int(meta.best_floor), Vector2(48,104), 34, V16_TEXT, true)
	_v16_currency(int(meta.coins), Rect2(510,32,182,72))
	_v16_title("ONE MORE", 163, 47, V16_PURPLE_HI)
	_v16_center("FLOOR", 228, 70, V16_GOLD_HI, true)
	_v16_rule(250,V16_PURPLE,410)
	_v16_center("CLIMB  •  LOOT  •  RISK IT ALL", 281, 13, V16_MUTED)
	# Hero on the bridge. The citadel itself comes from the high-detail art layer.
	_v15_soft_glow(Vector2(360,716),72,V16_PURPLE,0.95)
	draw_wanderer(Vector2(360,710),0.88,false)
	_v16_button(V10_SETTINGS_HOME,"SETTINGS",V16_BLUE,13,9)
	_v16_button(PLAY,"PLAY",V16_GOLD,34)
	_v16_button(MISSIONS_BTN,"MISSIONS",V16_GREEN,16,0)
	_v16_button(PASS_BTN,"TOWER PASS",V16_PURPLE,16,6)
	_v16_home_tab(HERO_TAB,"HERO",0,V16_BLUE)
	_v16_home_tab(FORGE_TAB,"FORGE",7,V16_ORANGE)
	_v16_home_tab(TALENTS_TAB,"TALENTS",1,V16_PURPLE)
	_v16_home_tab(VAULT_TAB,"VAULT",10,V16_GOLD)
	_v16_frame(Rect2(28,1164,664,64),Color("3c4664"),Color("080c16"),0.04)
	_v16_text("POWER",Vector2(48,1201),13,V16_MUTED)
	_v16_text(str(meta.power_score()),Vector2(112,1203),21,V16_GOLD_HI,true)
	_v16_text("KAMILUNAVO GAMES",Vector2(515,1201),12,V16_MUTED)
	_draw_notice(1114)

func _v16_home_tab(r: Rect2, label: String, icon_index: int, accent: Color) -> void:
	_v16_frame(r,accent,Color("050810"),0.14)
	_v16_medallion(Vector2(r.get_center().x,r.position.y+34),22,accent,icon_index)
	draw_string(v16_title_font,Vector2(r.position.x+5,r.end.y-14),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-10,14,V16_TEXT)

# -----------------------------------------------------------------------------
# HERO
# -----------------------------------------------------------------------------

func draw_hero_screen() -> void:
	_v16_header("HERO","Permanent Wanderer training",V16_GREEN,0,"arcane")
	_v15_soft_glow(Vector2(360,408),112,V16_PURPLE,0.85)
	draw_arc(Vector2(360,408),113,elapsed*0.10,elapsed*0.10+TAU,96,Color(V16_PURPLE,0.25),2.0)
	draw_wanderer(Vector2(360,430),1.62,false)
	var card:=Rect2(62,566,596,310)
	_v16_frame(card,V16_PURPLE,Color("07111f"),0.19)
	_v16_center("WANDERER  •  LEVEL %d" % int(meta.hero_level),622,27,V16_GOLD_HI,true)
	_v16_stat_row(card.position+Vector2(58,104),"Base HP bonus","+%d" % int(meta.hp_bonus()),V16_GREEN,0)
	_v16_stat_row(card.position+Vector2(58,168),"Combined damage","x%.2f" % float(meta.damage_multiplier()),V16_ORANGE,7)
	_v16_stat_row(card.position+Vector2(58,232),"Power",str(meta.power_score()),V16_PURPLE_HI,10)
	var cost:=int(meta.hero_cost())
	_v16_button(META_BUY,"TRAIN  %d" % cost,V16_PURPLE if meta.coins>=cost else Color("626578"),24,-1,meta.coins>=cost)
	_v16_center("Each Hero level: +5 HP and +3.5% damage",974,14,V16_MUTED)

func _v16_stat_row(pos: Vector2,label:String,value:String,accent:Color,icon_index:int) -> void:
	_v16_medallion(pos+Vector2(2,-5),20,accent,icon_index)
	_v16_text(label,pos+Vector2(38,1),16,accent)
	draw_string(v16_title_font,pos+Vector2(300,2),value,HORIZONTAL_ALIGNMENT_RIGHT,190,22,accent)
	draw_line(pos+Vector2(38,17),pos+Vector2(490,17),Color(accent,0.20),1.0)

# -----------------------------------------------------------------------------
# FORGE
# -----------------------------------------------------------------------------

func draw_forge_screen() -> void:
	_v16_header("FORGE","Temper the Wanderer's weapon",V16_ORANGE,7,"forge")
	_v15_soft_glow(Vector2(360,430),145,V16_ORANGE,0.75)
	_v16_medallion(Vector2(360,410),92,V16_ORANGE,7)
	_v16_medallion(Vector2(408,475),48,V16_PURPLE,6)
	var card:=Rect2(70,604,580,242)
	_v16_frame(card,V16_ORANGE,Color("130a08"),0.20)
	_v16_center("FORGE LEVEL %d" % int(meta.forge_level),660,27,V16_TEXT,true)
	_v16_center("Weapon multiplier contribution",707,15,V16_MUTED)
	_v16_center("+%.1f%% DAMAGE" % (float(meta.forge_level)*8.5),772,34,V16_GOLD_HI,true)
	var cost:=int(meta.forge_cost())
	_v16_button(META_BUY,"TEMPER  %d" % cost,V16_ORANGE if meta.coins>=cost else Color("626578"),22,11,meta.coins>=cost)
	_v16_center("Every Forge level adds +8.5% permanent damage.",978,14,V16_MUTED)

# -----------------------------------------------------------------------------
# TALENTS
# -----------------------------------------------------------------------------

func draw_talents_screen() -> void:
	_v16_header("TALENTS","Permanent passive bonuses",V16_PURPLE,1,"arcane")
	var rows: Array=[
		{"kind":"vitality","name":"VITALITY","desc":"+12 starting HP / level","accent":V16_GREEN,"icon":0},
		{"kind":"precision","name":"PRECISION","desc":"+1.8% starting crit / level","accent":V16_PURPLE,"icon":1},
		{"kind":"fortune","name":"FORTUNE","desc":"+6% coin drops / level","accent":V16_GOLD,"icon":11},
	]
	for i in range(rows.size()):
		var r:=talent_rect(i)
		var row:Dictionary=rows[i]
		var accent:Color=row["accent"]
		_v16_frame(r,accent,Color(accent,0.075),0.15)
		_v16_medallion(r.position+Vector2(70,r.size.y*0.5),37,accent,int(row["icon"]))
		_v16_text(String(row["name"]),r.position+Vector2(126,54),23,V16_TEXT,true)
		var lvl:=int(meta.talent_level(String(row["kind"])))
		_v16_text("Lv. %d  •  %s" % [lvl,String(row["desc"])],r.position+Vector2(126,87),14,V16_MUTED)
		var cost:=int(meta.talent_cost(String(row["kind"])))
		var br:=Rect2(r.end.x-205,r.position.y+37,178,62)
		_v16_button(br,"UPGRADE  %d" % cost,accent if meta.coins>=cost else Color("626578"),14,11,meta.coins>=cost)

# -----------------------------------------------------------------------------
# VAULT
# -----------------------------------------------------------------------------

func draw_vault_screen() -> void:
	_v16_header("VAULT","Compare, lock, equip, dismantle and craft gear",V16_GOLD,10,"arcane")
	var bonuses:Dictionary=loot.equipped_bonuses()
	_v16_frame(Rect2(46,214,628,68),V16_GOLD,Color("07111b"),0.10)
	_v16_text("SOUL SHARDS  %d" % int(loot.shards),Vector2(96,257),16,V16_BLUE)
	_v16_text("DMG +%.1f%%   HP +%d   CRIT +%.1f%%" % [float(bonuses["damage_pct"])*100.0,int(round(float(bonuses["hp"]))),float(bonuses["crit_pct"])*100.0],Vector2(394,257),14,V16_TEXT)
	for i in range(mini(4,loot.inventory.size())):
		var item:Dictionary=loot.inventory[i]
		var r:=Rect2(46,368+i*112,628,100)
		var accent:=rarity_color(String(item["rarity"]))
		_v16_frame(r,accent,Color("06101a"),0.10)
		_v16_text(String(item["name"]),r.position+Vector2(92,35),19,V16_TEXT,true)
		_v16_text("%s • %s • Lv.%d" % [String(item["rarity"]),String(item["slot"]).to_upper(),int(item["level"])],r.position+Vector2(92,58),12,accent)
		_v16_text(loot.stat_line(item),r.position+Vector2(92,82),13,V16_MUTED)
		_v16_text("EQUIPPED" if loot.is_equipped(item) else "TAP ›",r.position+Vector2(515,57),13,V16_GREEN if loot.is_equipped(item) else V16_GOLD)
		_v16_medallion(r.position+Vector2(49,50),27,accent,10)
	if loot.inventory.is_empty():
		_v16_center("THE VAULT IS EMPTY",560,28,V16_TEXT,true)
		_v16_center("Enemies drop weapons, armor and relics.",604,15,V16_MUTED)
	_draw_notice(1086)
