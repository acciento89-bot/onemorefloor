extends "res://scripts/main_v16.gd"

const V17_VERSION := "1.6.0-rc1"
const V17_SKINS := "res://assets/art/concept_button_skins.svg"
const V17_GOLD_DARK := Color("6f410d")
const V17_GOLD := Color("dba847")
const V17_GOLD_HI := Color("fff0a6")
const V17_IVORY := Color("f4ead8")
const V17_PURPLE := Color("9d4ff2")
const V17_PURPLE_HI := Color("e0b3ff")
const V17_NIGHT := Color("03050b")

var tex_v17_skins: Texture2D

func _ready() -> void:
	super._ready()
	tex_v17_skins = load(V17_SKINS) as Texture2D
	# Keep the concept typography: classical serif display + clean readable UI body.
	v16_title_font.font_names = PackedStringArray(["Palatino", "Baskerville", "Georgia", "Times New Roman", "DejaVu Serif"])
	v16_title_font.font_weight = 650
	v16_body_font.font_names = PackedStringArray(["Avenir Next", "Helvetica Neue", "Arial", "DejaVu Sans"])
	v16_body_font.font_weight = 500
	queue_redraw()

func _v16_backdrop(kind: String = "arcane", dim: float = 0.0) -> void:
	super._v16_backdrop(kind, dim)
	# Reference images use a deep vignette around a brighter center.
	for i: int in range(8):
		var a: float = 0.018 + float(i) * 0.007
		draw_rect(Rect2(float(i) * 7.0, float(i) * 3.0, 720.0 - float(i) * 14.0, 1280.0 - float(i) * 6.0), Color(0,0,0,a), false, 2.0)

func _v17_skin_index(accent: Color, enabled: bool = true) -> int:
	if not enabled:
		return 5
	var best := 0
	var best_d := 999.0
	var refs: Array[Color] = [V16_GOLD, V16_PURPLE, V16_BLUE, V16_GREEN, V16_ORANGE]
	for i: int in range(refs.size()):
		var d: float = absf(accent.r-refs[i].r)+absf(accent.g-refs[i].g)+absf(accent.b-refs[i].b)
		if d < best_d:
			best_d = d
			best = i
	return best

func _v17_skin(r: Rect2, accent: Color, enabled: bool = true) -> void:
	if tex_v17_skins == null:
		return
	var idx: int = _v17_skin_index(accent, enabled)
	var src := Rect2(0.0, float(idx * 96), 360.0, 96.0)
	draw_texture_rect_region(tex_v17_skins, r, src, Color.WHITE)

func _v16_frame(r: Rect2, accent: Color, fill: Color = V16_NAVY, glow: float = 0.15) -> void:
	# Exact concept language: black inset, metallic gold outer structure, accent inner energy.
	draw_rect(Rect2(r.position + Vector2(8,10), r.size), Color(0,0,0,0.62))
	draw_rect(r.grow(7), Color(accent, 0.045 + glow*0.12))
	draw_rect(r, Color("020307"))
	draw_rect(r.grow(-2), Color(V17_GOLD_DARK,0.96), false, 2.0)
	draw_rect(r.grow(-5), Color(V17_GOLD_HI,0.58), false, 1.0)
	draw_rect(r.grow(-8), fill)
	draw_rect(r.grow(-10), Color(accent,0.62), false, 1.5)
	# concept bevel highlights
	draw_line(r.position+Vector2(18,7),Vector2(r.end.x-18,r.position.y+7),Color(V17_GOLD_HI,0.32),1.5)
	draw_line(Vector2(r.position.x+18,r.end.y-7),r.end-Vector2(18,7),Color(0,0,0,0.84),2.5)
	# ornate gold corners + purple jewel pivots
	for pair in [[r.position+Vector2(7,7),Vector2(1,1)],[Vector2(r.end.x-7,r.position.y+7),Vector2(-1,1)],[Vector2(r.position.x+7,r.end.y-7),Vector2(1,-1)],[r.end-Vector2(7,7),Vector2(-1,-1)]]:
		var p: Vector2 = pair[0]
		var d: Vector2 = pair[1]
		draw_line(p,p+Vector2(d.x*19,0),V17_GOLD,2.5)
		draw_line(p,p+Vector2(0,d.y*19),V17_GOLD,2.5)
		var q := p + d*4.5
		draw_colored_polygon(PackedVector2Array([q+Vector2(0,-4),q+Vector2(4,0),q+Vector2(0,4),q+Vector2(-4,0)]),V17_PURPLE)

func _v16_button(r: Rect2, label: String, accent: Color, size: int, icon_index: int = -1, enabled: bool = true) -> void:
	_v17_skin(r, accent, enabled)
	if tex_v17_skins == null:
		_v16_frame(r,accent,Color(accent,0.10),0.2)
	var text_color: Color = V17_IVORY if enabled else Color("8c8fa0")
	if icon_index >= 0:
		_v16_medallion(Vector2(r.position.x+40,r.get_center().y), minf(25.0,r.size.y*0.31), accent, icon_index)
		draw_string(v16_title_font,Vector2(r.position.x+70,r.get_center().y+float(size)*0.32),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-86,size,text_color)
	else:
		draw_string(v16_title_font,Vector2(r.position.x+10,r.get_center().y+float(size)*0.34),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-20,size,text_color)

func _v16_medallion(center: Vector2, radius: float, accent: Color, icon_index: int) -> void:
	# Circular metal medallion from the concept: gold ring, dark core, accent halo, purple crown gem.
	for i: int in range(4,0,-1):
		draw_circle(center,radius+8.0+float(i)*2.0,Color(accent,0.012*float(i)))
	draw_circle(center,radius+7.0,Color("020307"))
	draw_arc(center,radius+7.0,0,TAU,64,V17_GOLD_DARK,4.0)
	draw_arc(center,radius+3.0,0,TAU,64,V17_GOLD_HI,1.5)
	draw_circle(center,radius-1.0,Color("080b14"))
	draw_arc(center,radius-3.0,0,TAU,64,Color(accent,0.92),2.0)
	_v12_icon(icon_index,Rect2(center-Vector2(radius*0.72,radius*0.72),Vector2(radius*1.44,radius*1.44)))
	var gem := center+Vector2(0,-radius-6)
	draw_colored_polygon(PackedVector2Array([gem+Vector2(0,-6),gem+Vector2(6,0),gem+Vector2(0,6),gem+Vector2(-6,0)]),V17_PURPLE)
	draw_colored_polygon(PackedVector2Array([gem+Vector2(0,-2.5),gem+Vector2(2.5,0),gem+Vector2(0,2.5),gem+Vector2(-2.5,0)]),V17_PURPLE_HI)

func _v16_title(label: String, y: float, size: int, accent: Color = V16_GOLD) -> void:
	# All reference screens use gold/ivory display type, while accent only colors the magic line.
	for off in [Vector2(2,4),Vector2(-2,3),Vector2(1,2)]:
		draw_string(v16_title_font,Vector2(40,y)+off,label,HORIZONTAL_ALIGNMENT_CENTER,640,size,Color(0,0,0,0.72))
	draw_string(v16_title_font,Vector2(40,y+1),label,HORIZONTAL_ALIGNMENT_CENTER,640,size,V17_GOLD_DARK)
	draw_string(v16_title_font,Vector2(40,y-1),label,HORIZONTAL_ALIGNMENT_CENTER,640,size,V17_GOLD_HI)
	draw_string(v16_title_font,Vector2(40,y-2),label,HORIZONTAL_ALIGNMENT_CENTER,640,size,Color("f3d27d"))
	_v16_rule(y+20.0,accent,430.0)

func _v16_rule(y: float, accent: Color, width: float) -> void:
	var x0 := 360.0-width*0.5
	var x1 := 360.0+width*0.5
	draw_line(Vector2(x0,y),Vector2(340,y),Color(V17_GOLD,0.72),1.4)
	draw_line(Vector2(380,y),Vector2(x1,y),Color(V17_GOLD,0.72),1.4)
	draw_line(Vector2(x0+30,y+4),Vector2(332,y+4),Color(accent,0.46),1.0)
	draw_line(Vector2(388,y+4),Vector2(x1-30,y+4),Color(accent,0.46),1.0)
	var p:=Vector2(360,y)
	draw_colored_polygon(PackedVector2Array([p+Vector2(0,-8),p+Vector2(8,0),p+Vector2(0,8),p+Vector2(-8,0)]),V17_PURPLE)
	draw_colored_polygon(PackedVector2Array([p+Vector2(0,-3),p+Vector2(3,0),p+Vector2(0,3),p+Vector2(-3,0)]),V17_GOLD_HI)

func _v16_currency(amount: int, r: Rect2 = Rect2(522,42,164,64)) -> void:
	_v16_frame(r,V16_GOLD,Color("050811"),0.20)
	_v16_medallion(Vector2(r.position.x+35,r.get_center().y),21.0,V16_GOLD,11)
	draw_string(v16_title_font,Vector2(r.position.x+68,r.get_center().y+9),str(amount),HORIZONTAL_ALIGNMENT_LEFT,r.size.x-78,24,V17_GOLD_HI)

func _v16_header(title: String, subtitle: String, accent: Color, icon_index: int, kind: String = "arcane") -> void:
	_v16_backdrop(kind)
	_v16_medallion(Vector2(360,72),28.0,accent,icon_index)
	_v16_title(title,139,48,accent)
	_v16_center(subtitle,184,16,V16_MUTED)
	_v16_currency(int(meta.coins))
	_v16_button(META_BACK,"‹  BACK",V16_PURPLE,17)
	if meta_notice_time>0.0:
		_v16_center(meta_notice,1090,16,C_GREEN if meta_notice.begins_with("UPGRADE") else C_RED)

func _v16_home_tab(r: Rect2, label: String, icon_index: int, accent: Color) -> void:
	_v17_skin(r,accent,true)
	_v16_medallion(Vector2(r.get_center().x,r.position.y+34),24.0,accent,icon_index)
	draw_string(v16_title_font,Vector2(r.position.x+5,r.position.y+88),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-10,14,V17_IVORY)

func draw_home() -> void:
	# Preserve all live game values/hitboxes, but match the exact concept hierarchy.
	if home_overlay=="missions":
		draw_missions_screen()
		return
	if home_overlay=="pass":
		draw_pass_screen()
		return
	_v16_backdrop("home")
	_v16_frame(Rect2(20,22,190,94),V16_PURPLE,Color("050811"),0.18)
	_v16_text("BEST FLOOR",Vector2(45,58),12,V16_MUTED,true)
	_v16_text(str(int(meta.best_floor)),Vector2(72,102),34,V17_IVORY,true)
	_v16_currency(int(meta.coins),Rect2(510,22,190,86))
	# Exact reference proportions: pale ONE MORE, dominant gold FLOOR, crystal/castle beneath.
	draw_string(v16_title_font,Vector2(52,164),"ONE MORE",HORIZONTAL_ALIGNMENT_CENTER,616,46,V17_IVORY)
	draw_string(v16_title_font,Vector2(52,235),"FLOOR",HORIZONTAL_ALIGNMENT_CENTER,616,72,V17_GOLD_HI)
	_v16_rule(255,V16_PURPLE,390)
	_v16_center("CLIMB  •  LOOT  •  RISK IT ALL",286,13,V16_MUTED)
	_v15_soft_glow(Vector2(360,710),80,V16_PURPLE,1.0)
	draw_wanderer(Vector2(360,706),0.78,false)
	_v16_button(V10_SETTINGS_HOME,"SETTINGS",V16_BLUE,13,9)
	_v16_button(PLAY,"PLAY",V16_GOLD,36)
	_v16_button(MISSIONS_BTN,"MISSIONS",V16_GREEN,17,0)
	_v16_button(PASS_BTN,"TOWER PASS",V16_PURPLE,17,6)
	_v16_home_tab(HERO_TAB,"HERO",0,V16_BLUE)
	_v16_home_tab(FORGE_TAB,"FORGE",7,V16_ORANGE)
	_v16_home_tab(TALENTS_TAB,"TALENTS",1,V16_PURPLE)
	_v16_home_tab(VAULT_TAB,"VAULT",10,V16_GOLD)
	_v16_frame(Rect2(34,1154,652,74),Color("343d63"),Color("040710"),0.08)
	_v16_text("POWER",Vector2(56,1190),13,V16_MUTED,true)
	_v16_text(str(int(meta.power_score())),Vector2(116,1193),22,V17_GOLD_HI,true)
	draw_string(v16_body_font,Vector2(330,1193),"KAMILUNAVO GAMES",HORIZONTAL_ALIGNMENT_RIGHT,328,11,V16_MUTED)
	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step in [0,1]:
		_draw_tutorial_overlay()
