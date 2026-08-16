extends "res://scripts/main_v16.gd"

const V17_VERSION := "1.6.0-concept-lock"
const V17_HOME_ART := "res://assets/art/concept_home_v16.svg"
const V17_ARCANE_ART := "res://assets/art/concept_arcane_v16.svg"
const V17_FORGE_ART := "res://assets/art/concept_forge_v16.svg"
const V17_BTN_GOLD := "res://assets/ui/concept_btn_gold.svg"
const V17_BTN_PURPLE := "res://assets/ui/concept_btn_purple.svg"
const V17_BTN_GREEN := "res://assets/ui/concept_btn_green.svg"
const V17_BTN_BLUE := "res://assets/ui/concept_btn_blue.svg"
const V17_PANEL_GOLD := "res://assets/ui/concept_panel_gold.svg"
const V17_PANEL_PURPLE := "res://assets/ui/concept_panel_purple.svg"
const V17_PANEL_GREEN := "res://assets/ui/concept_panel_green.svg"

var tex_v17_home: Texture2D
var tex_v17_arcane: Texture2D
var tex_v17_forge: Texture2D
var tex_v17_btn_gold: Texture2D
var tex_v17_btn_purple: Texture2D
var tex_v17_btn_green: Texture2D
var tex_v17_btn_blue: Texture2D
var tex_v17_panel_gold: Texture2D
var tex_v17_panel_purple: Texture2D
var tex_v17_panel_green: Texture2D

func _ready() -> void:
	super._ready()
	tex_v17_home = load(V17_HOME_ART) as Texture2D
	tex_v17_arcane = load(V17_ARCANE_ART) as Texture2D
	tex_v17_forge = load(V17_FORGE_ART) as Texture2D
	tex_v17_btn_gold = load(V17_BTN_GOLD) as Texture2D
	tex_v17_btn_purple = load(V17_BTN_PURPLE) as Texture2D
	tex_v17_btn_green = load(V17_BTN_GREEN) as Texture2D
	tex_v17_btn_blue = load(V17_BTN_BLUE) as Texture2D
	tex_v17_panel_gold = load(V17_PANEL_GOLD) as Texture2D
	tex_v17_panel_purple = load(V17_PANEL_PURPLE) as Texture2D
	tex_v17_panel_green = load(V17_PANEL_GREEN) as Texture2D
	queue_redraw()

func _v17_is_close(a: Color, b: Color) -> bool:
	return absf(a.r-b.r) + absf(a.g-b.g) + absf(a.b-b.b) < 0.55

func _v17_button_skin(accent: Color) -> Texture2D:
	if _v17_is_close(accent, V16_GREEN):
		return tex_v17_btn_green
	if _v17_is_close(accent, V16_BLUE) or _v17_is_close(accent, C_CYAN):
		return tex_v17_btn_blue
	if _v17_is_close(accent, V16_PURPLE) or _v17_is_close(accent, V16_PURPLE_HI):
		return tex_v17_btn_purple
	return tex_v17_btn_gold

func _v17_panel_skin(accent: Color) -> Texture2D:
	if _v17_is_close(accent, V16_GREEN):
		return tex_v17_panel_green
	if _v17_is_close(accent, V16_PURPLE) or _v17_is_close(accent, V16_PURPLE_HI):
		return tex_v17_panel_purple
	return tex_v17_panel_gold

func _v16_backdrop(kind: String = "arcane", dim: float = 0.0) -> void:
	var texture: Texture2D = tex_v17_arcane
	if kind == "home":
		texture = tex_v17_home
	elif kind == "forge":
		texture = tex_v17_forge
	if texture != null:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)
	else:
		super._v16_backdrop(kind, dim)
	if dim > 0.0:
		draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.0, 0.0, 0.01, dim))

func _v16_frame(r: Rect2, accent: Color, fill: Color = V16_NAVY, glow: float = 0.15) -> void:
	var skin: Texture2D = _v17_panel_skin(accent)
	if skin != null:
		draw_texture_rect(skin, Rect2(r.position + Vector2(5,7), r.size), false, Color(0,0,0,0.58))
		draw_texture_rect(skin, r, false, Color.WHITE)
		if fill.a > 0.0:
			draw_rect(r.grow(-12), Color(fill.r, fill.g, fill.b, minf(fill.a, 0.18)))
	else:
		super._v16_frame(r, accent, fill, glow)

func _v16_button(r: Rect2, label: String, accent: Color, size: int, icon_index: int = -1, enabled: bool = true) -> void:
	var skin: Texture2D = _v17_button_skin(accent)
	var modulate: Color = Color.WHITE if enabled else Color(0.48,0.49,0.55,0.72)
	if skin != null:
		draw_texture_rect(skin, Rect2(r.position + Vector2(5,7),r.size), false, Color(0,0,0,0.50))
		draw_texture_rect(skin, r, false, modulate)
	else:
		super._v16_button(r,label,accent,size,icon_index,enabled)
		return
	if icon_index >= 0:
		_v16_medallion(Vector2(r.position.x+38,r.get_center().y), minf(25.0,r.size.y*0.28), accent, icon_index)
		var start_x: float = r.position.x + 74.0
		draw_string(v16_title_font, Vector2(start_x,r.get_center().y+size*0.35), label, HORIZONTAL_ALIGNMENT_CENTER, r.end.x-start_x-16.0, size, V16_TEXT if enabled else V16_MUTED)
	else:
		draw_string(v16_title_font, Vector2(r.position.x+10,r.get_center().y+size*0.34), label, HORIZONTAL_ALIGNMENT_CENTER, r.size.x-20, size, V16_TEXT if enabled else V16_MUTED)

func _v16_medallion(center: Vector2, radius: float, accent: Color, icon_index: int) -> void:
	draw_circle(center, radius+8.0, Color(0,0,0,0.58))
	draw_circle(center, radius+5.0, Color("090b12"))
	draw_arc(center,radius+5.0,0,TAU,64,Color("6f4614"),4.0)
	draw_arc(center,radius+3.0,0,TAU,64,V16_GOLD_HI,1.4)
	draw_circle(center,radius-1.0,Color(accent.r, accent.g, accent.b, 0.12))
	draw_arc(center,radius-1.0,0,TAU,64,Color(accent.r, accent.g, accent.b, 0.95),2.2)
	draw_arc(center,radius-5.0,-2.45,-0.4,24,Color(1,1,1,0.32),1.2)
	_v12_icon(icon_index, Rect2(center-Vector2(radius*0.62,radius*0.62),Vector2(radius*1.24,radius*1.24)))
	var gem: Vector2 = center + Vector2(0,-radius-5)
	draw_colored_polygon(PackedVector2Array([gem+Vector2(0,-6),gem+Vector2(6,0),gem+Vector2(0,6),gem+Vector2(-6,0)]),V16_PURPLE)
	draw_colored_polygon(PackedVector2Array([gem+Vector2(0,-3),gem+Vector2(3,0),gem+Vector2(0,3),gem+Vector2(-3,0)]),V16_PURPLE_HI)

func _v16_title(label: String, y: float, size: int, accent: Color = V16_GOLD) -> void:
	var shadow := Color(0,0,0,0.92)
	draw_string(v16_title_font,Vector2(40,y+4),label,HORIZONTAL_ALIGNMENT_CENTER,640,size,shadow)
	draw_string(v16_title_font,Vector2(40,y+2),label,HORIZONTAL_ALIGNMENT_CENTER,640,size,Color("8f5715"))
	draw_string(v16_title_font,Vector2(40,y),label,HORIZONTAL_ALIGNMENT_CENTER,640,size,Color("ffe8a0"))
	draw_string(v16_title_font,Vector2(40,y-2),label,HORIZONTAL_ALIGNMENT_CENTER,640,size,Color("fff7d2"))
	_v16_rule(y+22.0, accent, 430.0)

func _v16_currency(amount: int, r: Rect2 = Rect2(522,42,164,64)) -> void:
	_v16_frame(r,V16_GOLD,Color("05080f"),0.24)
	_v16_medallion(Vector2(r.position.x+35,r.get_center().y),22,V16_GOLD,11)
	_v16_text(str(amount),Vector2(r.position.x+70,r.position.y+r.size.y*0.66),25,V16_GOLD_HI,true)

func _v16_header(title: String, subtitle: String, accent: Color, icon_index: int, kind: String = "arcane") -> void:
	_v16_backdrop(kind)
	_v16_medallion(Vector2(360,69),29.0,accent,icon_index)
	_v16_title(title,139,48,accent)
	_v16_center(subtitle,184,16,V16_MUTED)
	_v16_currency(int(meta.coins),Rect2(520,30,170,70))
	_v16_button(META_BACK,"‹  BACK",V16_PURPLE,17)
	if meta_notice_time > 0.0:
		_v16_center(meta_notice,1090,16,C_GREEN if meta_notice.begins_with("UPGRADE") else C_RED)

func draw_home() -> void:
	if home_overlay == "missions":
		draw_missions_screen()
		return
	if home_overlay == "pass":
		draw_pass_screen()
		return
	_v16_backdrop("home")
	_v16_frame(Rect2(20,25,190,92),V16_PURPLE,Color("050812"),0.20)
	_v16_text("BEST FLOOR",Vector2(45,60),12,V16_MUTED,true)
	_v16_text("%02d" % int(meta.best_floor),Vector2(58,104),38,V16_TEXT,true)
	_v16_currency(int(meta.coins),Rect2(510,24,190,82))
	draw_string(v16_title_font,Vector2(65,163),"ONE MORE",HORIZONTAL_ALIGNMENT_CENTER,590,48,Color("eee4f4"))
	draw_string(v16_title_font,Vector2(65,226),"FLOOR",HORIZONTAL_ALIGNMENT_CENTER,590,72,Color("ffe6a0"))
	_v16_rule(248,V16_PURPLE,390)
	_v16_center("CLIMB  •  LOOT  •  RISK IT ALL",279,14,V16_MUTED)
	_v15_soft_glow(Vector2(360,725),65,V16_PURPLE,0.85)
	draw_wanderer(Vector2(360,716),0.90,false)
	_v16_button(V10_SETTINGS_HOME,"SETTINGS",V16_BLUE,14,9)
	_v16_button(PLAY,"PLAY",V16_GOLD,37)
	_v16_button(MISSIONS_BTN,"MISSIONS",V16_GREEN,18,0)
	_v16_button(PASS_BTN,"TOWER PASS",V16_PURPLE,18,6)
	_v17_home_tile(HERO_TAB,"HERO",0,V16_BLUE)
	_v17_home_tile(FORGE_TAB,"FORGE",7,V16_ORANGE)
	_v17_home_tile(TALENTS_TAB,"TALENTS",1,V16_PURPLE)
	_v17_home_tile(VAULT_TAB,"VAULT",10,V16_GOLD)
	_v16_frame(Rect2(28,1150,664,78),Color("454f73"),Color("04070d"),0.08)
	_v16_text("POWER",Vector2(55,1192),15,V16_MUTED,true)
	_v16_text(str(int(meta.power_score())),Vector2(122,1194),23,V16_GOLD_HI,true)
	draw_string(v16_body_font,Vector2(350,1193),"KAMILUNAVO GAMES",HORIZONTAL_ALIGNMENT_RIGHT,310,12,V16_MUTED)
	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step in [0,1]:
		_draw_tutorial_overlay()

func _v17_home_tile(r: Rect2,label: String,icon_index: int,accent: Color) -> void:
	var skin: Texture2D = _v17_button_skin(accent)
	if skin != null:
		draw_texture_rect(skin,r,false,Color.WHITE)
	else:
		_v16_frame(r,accent,Color("070b14"),0.15)
	_v16_medallion(Vector2(r.get_center().x,r.position.y+35),25,accent,icon_index)
	draw_string(v16_title_font,Vector2(r.position.x+4,r.end.y-15),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-8,14,V16_TEXT)

func draw_forge_screen() -> void:
	_v16_header("FORGE","Temper the Wanderer's weapon",V16_ORANGE,7,"forge")
	_v15_soft_glow(Vector2(360,420),205,V16_ORANGE,1.0)
	_v16_medallion(Vector2(360,398),94,V16_ORANGE,7)
	_v16_medallion(Vector2(408,465),42,V16_PURPLE,6)
	var card := Rect2(82,570,556,226)
	_v16_frame(card,V16_GOLD,Color("120a08"),0.25)
	_v16_center("FORGE LEVEL %d" % int(meta.forge_level),624,31,V16_TEXT,true)
	_v16_center("Weapon multiplier contribution",670,16,V16_MUTED)
	_v16_center("+%.1f%% DAMAGE" % (float(meta.forge_level)*8.5),735,34,V16_GOLD_HI,true)
	_v16_button(META_BUY,"TEMPER  %d" % int(meta.forge_cost()),V16_GOLD,23,11,meta.coins >= meta.forge_cost())
	_v16_center("Every Forge level adds +8.5% permanent damage.",980,15,V16_MUTED)

func draw_hero_screen() -> void:
	_v16_header("HERO","Permanent Wanderer training",V16_PURPLE,0,"arcane")
	_v15_soft_glow(Vector2(360,442),210,V16_PURPLE,1.0)
	draw_wanderer(Vector2(360,446),1.48,false)
	var card := Rect2(74,590,572,248)
	_v16_frame(card,V16_PURPLE,Color("070d18"),0.22)
	_v16_center("WANDERER  •  LEVEL %d" % int(meta.hero_level),643,31,V16_TEXT,true)
	_v16_stat_line(Rect2(120,680,480,42),0,"Base HP bonus","+%d" % int(meta.hero_level*5-5),V16_GREEN)
	_v16_stat_line(Rect2(120,726,480,42),6,"Combined damage","x%.2f" % float(meta.combined_damage_multiplier()),V16_GOLD)
	_v16_stat_line(Rect2(120,772,480,42),8,"Power",str(int(meta.power_score())),V16_PURPLE_HI)
	_v16_button(META_BUY,"TRAIN  %d" % int(meta.hero_cost()),V16_PURPLE,22,-1,meta.coins >= meta.hero_cost())
	_v16_center("Each Hero level: +5 HP and +3.5% damage",974,15,V16_MUTED)

func _draw_settings_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO,SIZE),Color(0,0,0,0.76))
	var modal := Rect2(54,142,612,792)
	_v16_frame(modal,V16_GOLD,Color("07101e"),0.25)
	_v16_medallion(Vector2(360,178),27,V16_PURPLE,10)
	_v16_title("SETTINGS",232,42,V16_GOLD)
	_v16_center("Playtest controls & privacy",271,16,V16_MUTED)
	_v16_setting_row(V10_SET_MUSIC,"MUSIC",bool(settings.music_enabled),int(float(settings.music_volume)*100.0),2,V16_GREEN)
	_v16_setting_row(V10_SET_SFX,"SFX",bool(settings.sfx_enabled),int(float(settings.sfx_volume)*100.0),3,V16_GREEN)
	_v16_setting_row(V10_SET_HAPTICS,"HAPTICS",bool(settings.haptics_enabled),-1,4,V16_GREEN)
	_v16_setting_row(V10_SET_ANALYTICS,"ANALYTICS",bool(settings.analytics_enabled),-1,5,Color("5e6475"))
	_v16_button(V10_SET_TUTORIAL,"REPLAY TUTORIAL",V16_PURPLE,18,6)
	_v16_rule(731,V16_PURPLE,390)
	_v16_button(V10_SET_BACK,"BACK",V16_BLUE,22)
	_v16_center("Analytics is opt-in. Playtest events stay local in this build.",889,12,V16_MUTED)
