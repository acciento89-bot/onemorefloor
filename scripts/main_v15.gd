extends "res://scripts/main_v14.gd"

const V15_VERSION := "1.4.0-rc1"
const V15_MENU_CITADEL := "res://assets/art/premium_menu_citadel.svg"
const V15_FOREGROUND := "res://assets/art/premium_room_foreground.svg"

var tex_v15_citadel: Texture2D
var tex_v15_foreground: Texture2D

func _ready() -> void:
	super._ready()
	tex_v15_citadel = load(V15_MENU_CITADEL) as Texture2D
	tex_v15_foreground = load(V15_FOREGROUND) as Texture2D
	queue_redraw()

# -----------------------------------------------------------------------------
# v1.4 shared premium presentation language
# -----------------------------------------------------------------------------

func _v15_soft_glow(center: Vector2, radius: float, color: Color, strength: float = 1.0) -> void:
	for i: int in range(5, 0, -1):
		var f: float = float(i) / 5.0
		draw_circle(center, radius * f, Color(color, 0.012 * strength * (6.0 - float(i))))

func _v15_rule(y: float, accent: Color, width: float = 420.0) -> void:
	var x0: float = 360.0 - width * 0.5
	var x1: float = 360.0 + width * 0.5
	draw_line(Vector2(x0, y), Vector2(340, y), Color(accent, 0.52), 1.5)
	draw_line(Vector2(380, y), Vector2(x1, y), Color(accent, 0.52), 1.5)
	var p := Vector2(360, y)
	draw_colored_polygon(PackedVector2Array([p+Vector2(0,-7),p+Vector2(7,0),p+Vector2(0,7),p+Vector2(-7,0)]), Color(accent,0.92))
	draw_colored_polygon(PackedVector2Array([p+Vector2(0,-3),p+Vector2(3,0),p+Vector2(0,3),p+Vector2(-3,0)]), V12_IVORY)

func _v15_premium_panel(r: Rect2, accent: Color, fill: Color = Color("070c16"), glow: float = 0.12) -> void:
	draw_rect(r.grow(10), Color(0,0,0,0.34))
	draw_rect(r.grow(4), Color(accent, glow * 0.32))
	draw_rect(r, fill)
	draw_rect(r, Color(accent,0.92), false, 2.0)
	draw_rect(r.grow(-5), Color(accent,0.18), false, 1.0)
	draw_line(r.position + Vector2(16,7), Vector2(r.end.x-16,r.position.y+7), Color(1,1,1,0.08), 1.0)
	draw_line(Vector2(r.position.x+16,r.end.y-7), r.end-Vector2(16,7), Color(0,0,0,0.48), 2.0)
	if tex_v14_ui != null:
		var s: float = clampf(minf(r.size.x,r.size.y)*0.28,16.0,28.0)
		_v14_ui_cell(0,Rect2(r.position-Vector2(2,2),Vector2(s,s)),Color(accent,0.9))
		_v14_ui_cell(1,Rect2(r.end.x-s+2,r.position.y-2,s,s),Color(accent,0.9))
		_v14_ui_cell(2,Rect2(r.position.x-2,r.end.y-s+2,s,s),Color(accent,0.72))
		_v14_ui_cell(3,Rect2(r.end.x-s+2,r.end.y-s+2,s,s),Color(accent,0.72))

func _v15_premium_button(r: Rect2, label: String, accent: Color, size: int, icon_index: int = -1) -> void:
	_v15_premium_panel(r, accent, Color(accent,0.09), 0.18)
	draw_rect(r.grow(-8), Color(accent,0.035))
	if icon_index >= 0:
		_v12_icon(icon_index, Rect2(r.position.x+10,r.get_center().y-20,40,40))
		draw_string(font,Vector2(r.position.x+54,r.get_center().y+7),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-66,size,V12_IVORY)
	else:
		center_rect(label,r,size,V12_IVORY)

func _v15_stat_badge(r: Rect2, title: String, value: String, accent: Color, icon_index: int = -1) -> void:
	_v15_premium_panel(r,accent,Color("070c16"),0.14)
	if icon_index >= 0:
		_v12_icon(icon_index,Rect2(r.position.x+8,r.position.y+11,44,44))
		text(title,r.position+Vector2(57,27),10,C_MUTED)
		text(value,r.position+Vector2(57,56),23,V12_IVORY)
	else:
		text(title,r.position+Vector2(16,27),10,C_MUTED)
		text(value,r.position+Vector2(16,59),28,V12_IVORY)

func _v12_meta_header(title: String, subtitle: String, accent: Color, icon_index: int) -> void:
	_v12_background(accent)
	_v15_soft_glow(Vector2(360,125),150,accent,0.8)
	_v12_icon(icon_index,Rect2(328,28,64,64))
	draw_string(font,Vector2(45,130),title,HORIZONTAL_ALIGNMENT_CENTER,630,43,V12_IVORY)
	draw_string(font,Vector2(45,130),title,HORIZONTAL_ALIGNMENT_CENTER,630,43,Color(accent,0.82))
	_v15_rule(151,accent,405)
	draw_string(font,Vector2(70,183),subtitle,HORIZONTAL_ALIGNMENT_CENTER,580,16,C_MUTED)
	_v12_coin_badge(Rect2(520,44,160,58),int(meta.coins))
	_v15_premium_button(META_BACK,"‹  BACK",V12_PURPLE,17)
	if meta_notice_time > 0.0:
		draw_string(font,Vector2(70,1088),meta_notice,HORIZONTAL_ALIGNMENT_CENTER,580,17,C_GREEN if meta_notice.begins_with("UPGRADE") else C_RED)

# -----------------------------------------------------------------------------
# Premium Home — same proven hitboxes, completely upgraded presentation
# -----------------------------------------------------------------------------

func draw_home() -> void:
	if home_overlay == "missions":
		draw_missions_screen()
		return
	if home_overlay == "pass":
		draw_pass_screen()
		return

	_v12_home_background()
	# cinematic horizon / floor haze
	for i: int in range(5):
		var y: float = 615.0 + float(i)*28.0 + sin(elapsed*0.22+float(i))*6.0
		draw_rect(Rect2(0,y,720,42),Color(V12_PURPLE,0.012+float(i)*0.004))
	_v15_stat_badge(Rect2(34,40,170,84),"BEST FLOOR","%02d" % int(meta.best_floor),V12_PURPLE)
	_v15_stat_badge(Rect2(516,40,170,64),"COINS",str(int(meta.coins)),V12_GOLD,11)

	# restrained premium wordmark with room around it
	_v15_soft_glow(Vector2(360,185),150,V12_PURPLE,0.7)
	draw_string(font,Vector2(62,174),"ONE MORE",HORIZONTAL_ALIGNMENT_CENTER,596,42,Color("d7b6ff"))
	draw_string(font,Vector2(62,240),"FLOOR",HORIZONTAL_ALIGNMENT_CENTER,596,68,V12_GOLD_LIGHT)
	_v15_rule(257,V12_PURPLE,390)
	draw_string(font,Vector2(70,285),"CLIMB  •  LOOT  •  RISK IT ALL",HORIZONTAL_ALIGNMENT_CENTER,580,12,C_MUTED)

	# Actual production citadel asset replaces the code-block tower silhouette.
	if tex_v15_citadel != null:
		draw_texture_rect(tex_v15_citadel,Rect2(70,286,580,470),false,Color(0.90,0.92,1.0,1.0))
	else:
		_v12_home_tower(Vector2(360,515))

	# Hero is grounded on the citadel approach and separated with a subtle halo.
	_v15_soft_glow(Vector2(360,708),78,V12_PURPLE,1.0)
	draw_wanderer(Vector2(360,704),0.72,false)

	# Settings sits exactly on its proven touch target.
	_v15_premium_button(V10_SETTINGS_HOME,"SETTINGS",C_BLUE,13)
	# Primary CTA remains exactly aligned to PLAY hitbox.
	_v15_premium_button(PLAY,"PLAY",V12_GOLD,31)
	# Secondary progression row.
	_v15_premium_button(MISSIONS_BTN,"MISSIONS",C_GREEN,16,0)
	_v15_premium_button(PASS_BTN,"TOWER PASS",V12_PURPLE,16,6)
	# Meta navigation keeps the existing hitboxes but looks like a single coherent premium system.
	_v15_home_tab(HERO_TAB,"HERO",0,C_BLUE)
	_v15_home_tab(FORGE_TAB,"FORGE",7,C_ORANGE)
	_v15_home_tab(TALENTS_TAB,"TALENTS",1,V12_PURPLE)
	_v15_home_tab(VAULT_TAB,"VAULT",10,V12_GOLD)
	_v15_premium_panel(Rect2(38,1160,644,68),Color("343d63"),Color("060b14"),0.08)
	text("POWER  %d" % int(meta.power_score()),Vector2(62,1201),15,V12_GOLD_LIGHT)
	draw_string(font,Vector2(330,1201),"KAMILUNAVO GAMES",HORIZONTAL_ALIGNMENT_RIGHT,322,11,C_MUTED)

	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step in [0,1]:
		_draw_tutorial_overlay()

func _v15_home_tab(r: Rect2, label: String, icon_index: int, accent: Color) -> void:
	_v15_premium_panel(r,accent,Color("080e1b"),0.15)
	_v12_icon(icon_index,Rect2(r.get_center().x-24,r.position.y+7,48,48))
	draw_string(font,Vector2(r.position.x+6,r.position.y+82),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-12,13,V12_IVORY)
	draw_line(Vector2(r.position.x+16,r.end.y-9),Vector2(r.end.x-16,r.end.y-9),Color(accent,0.32),2.0)

# -----------------------------------------------------------------------------
# Room depth — dedicated foreground layers per biome
# -----------------------------------------------------------------------------

func _draw_room_architecture() -> void:
	super._draw_room_architecture()
	if tex_v15_foreground == null:
		return
	var area: String = String(current_room.get("area","DUNGEON"))
	var idx: int = _v14_room_index(area)
	var source := Rect2(0.0,float(idx*840),720.0,840.0)
	# Transparent side architecture and low foreground fog create real near/mid/far separation.
	draw_texture_rect_region(tex_v15_foreground,Rect2(0,160,720,840),source,Color.WHITE)

# -----------------------------------------------------------------------------
# Combat HUD — dedicated status zone and dedicated controls zone
# -----------------------------------------------------------------------------

func _draw_combat_hud() -> void:
	# top tactical bar
	_v15_premium_panel(Rect2(28,22,664,112),Color("59667d"),Color("050a13"),0.08)
	text("FLOOR",Vector2(49,52),10,C_MUTED)
	text("%02d" % int(run.floor_no),Vector2(48,101),40,V12_IVORY)
	var area: String = String(current_room.get("area","DUNGEON"))
	var accent: Color = _area_accent(area)
	text(area,Vector2(140,64),15,accent)
	text(String(current_room.get("type","COMBAT")),Vector2(140,93),12,C_MUTED)
	_v12_coin_badge(Rect2(510,42,104,58),int(run.run_coins))
	_v15_premium_panel(V10_PAUSE,C_MUTED,Color("090d16"),0.06)
	center_rect("Ⅱ",V10_PAUSE,17,V12_IVORY)

	# HP is now an isolated status rail ABOVE both controls. No joystick/HP collision.
	var hp_box := Rect2(144,982,432,34)
	_v15_premium_panel(hp_box,Color("743743"),Color("160b12"),0.09)
	var ratio: float = clampf(run.hp/run.max_hp,0.0,1.0)
	var inner := hp_box.grow(-6.0)
	draw_rect(inner,Color("32111a"))
	draw_rect(Rect2(inner.position,Vector2(inner.size.x*ratio,inner.size.y)),Color("b92e46"))
	draw_line(inner.position+Vector2(1,2),Vector2(inner.position.x+inner.size.x*ratio-1,inner.position.y+2),Color(1.0,0.70,0.74,0.48),2.0)
	_v14_ui_cell(4,Rect2(hp_box.position.x-28,hp_box.position.y-15,58,58))
	center_rect("%d / %d HP" % [int(run.hp),int(run.max_hp)],hp_box,13,V12_IVORY)

	# Controls sit in their own lower safe zone. Visual origin is clamped so a high touch can never collide with HP.
	var base := Vector2(132,1138)
	if joy_active:
		base = Vector2(clampf(joy_origin.x,96.0,190.0),clampf(joy_origin.y,1102.0,1160.0))
	var knob := base + joy_vector * 34.0
	_v15_soft_glow(base,82,V12_PURPLE,0.55)
	draw_circle(base,70,Color(0.012,0.020,0.045,0.96))
	draw_arc(base,70,0,TAU,64,Color(V12_GOLD,0.68),3.0)
	draw_arc(base,62,0,TAU,64,Color(V12_PURPLE,0.34),2.0)
	for a: float in [0.0,PI*0.5,PI,PI*1.5]:
		draw_circle(base+Vector2.from_angle(a)*52.0,3.0,Color(V12_IVORY,0.46))
	draw_circle(knob,32,Color("657188"))
	draw_circle(knob+Vector2(-7,-8),5,Color(1,1,1,0.10))
	draw_arc(knob,32,0,TAU,40,Color("cbd7e7"),1.8)
	draw_string(font,Vector2(70,1225),"MOVE",HORIZONTAL_ALIGNMENT_CENTER,124,11,C_MUTED)

	var skill_center: Vector2 = SKILL.get_center()
	_v15_soft_glow(skill_center,75,C_CYAN,0.65)
	draw_circle(skill_center,60,Color(0.006,0.025,0.06,0.98))
	draw_arc(skill_center,60,0,TAU,64,V12_GOLD,3.0)
	var ready_ratio: float = 1.0 if run.skill_cd <= 0.0 else clampf(1.0-run.skill_cd/7.0,0.0,1.0)
	draw_arc(skill_center,52,-PI*0.5,-PI*0.5+TAU*ready_ratio,64,C_CYAN if run.skill_cd<=0.0 else Color("4b5368"),5.0)
	if run.skill_cd <= 0.0:
		_v14_ui_cell(7,Rect2(skill_center.x-43,skill_center.y-43,86,86))
		text("NOVA",Vector2(skill_center.x-24,skill_center.y+35),12,V12_IVORY)
	else:
		_v14_ui_cell(7,Rect2(skill_center.x-36,skill_center.y-36,72,72),Color(0.38,0.42,0.5,0.48))
		draw_string(font,Vector2(skill_center.x-38,skill_center.y+7),"%.1f" % run.skill_cd,HORIZONTAL_ALIGNMENT_CENTER,76,19,C_MUTED)

	if floor_banner > 0.0:
		var banner_color := V12_GOLD_LIGHT
		banner_color.a = clampf(floor_banner,0.0,1.0)
		draw_string(font,Vector2(80,610),"FLOOR %d" % int(run.floor_no),HORIZONTAL_ALIGNMENT_CENTER,560,45,banner_color)

# -----------------------------------------------------------------------------
# Premium reward decision screen — larger visual jump than another border pass
# -----------------------------------------------------------------------------

func draw_upgrade() -> void:
	_v12_background(V12_PURPLE)
	_v15_soft_glow(Vector2(360,250),220,V12_PURPLE,0.9)
	draw_string(font,Vector2(60,150),"FLOOR CLEARED!",HORIZONTAL_ALIGNMENT_CENTER,600,43,V12_GOLD_LIGHT)
	_v15_rule(173,V12_GOLD,410)
	draw_string(font,Vector2(70,218),"Choose an Upgrade",HORIZONTAL_ALIGNMENT_CENTER,580,29,V12_IVORY)
	draw_string(font,Vector2(70,252),"Build the run. Break the tower.",HORIZONTAL_ALIGNMENT_CENTER,580,16,C_MUTED)
	for i: int in range(upgrade_options.size()):
		var r: Rect2 = upgrade_rect(i)
		var u: Dictionary = upgrade_options[i]
		var c: Color = u["color"]
		_v15_premium_panel(r,c,Color("080e1b"),0.16)
		_v15_soft_glow(r.position+Vector2(64,69),42,c,0.55)
		draw_circle(r.position+Vector2(64,69),31,Color(c,0.14))
		_v12_upgrade_icon(String(u["kind"]),Rect2(r.position.x+31,r.position.y+36,66,66),c)
		text(String(u["name"]),r.position+Vector2(118,60),22,V12_IVORY)
		text(String(u["desc"]),r.position+Vector2(118,97),16,C_MUTED)
		draw_line(Vector2(r.position.x+118,r.end.y-18),Vector2(r.end.x-22,r.end.y-18),Color(c,0.16),1.0)
	draw_string(font,Vector2(70,1015),"Tap an upgrade to continue.",HORIZONTAL_ALIGNMENT_CENTER,580,15,C_MUTED)
