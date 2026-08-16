extends "res://scripts/main_v18.gd"

# ONE MORE FLOOR v1.7 — reference-faithful menu runtime.
# The supplied concept screens are now treated as the actual layout specification.
# Game/economy/loot logic stays live; this file replaces the menu renderer only.

const V19_VERSION := "1.7.0-reference-menus"
const V19_HOME_ART := "res://assets/art/menu_home_v19.svg"
const V19_ARCANE_ART := "res://assets/art/menu_arcane_v19.svg"
const V19_FORGE_ART := "res://assets/art/menu_forge_final.svg"

const V19_HERO_BUY := Rect2(338, 988, 330, 96)
const V19_FORGE_BUY := Rect2(186, 974, 348, 88)

var tex_v19_home: Texture2D
var tex_v19_arcane: Texture2D
var tex_v19_forge: Texture2D

func _ready() -> void:
	super._ready()
	tex_v19_home = load(V19_HOME_ART) as Texture2D
	tex_v19_arcane = load(V19_ARCANE_ART) as Texture2D
	tex_v19_forge = load(V19_FORGE_ART) as Texture2D
	queue_redraw()

# -----------------------------------------------------------------------------
# Shared premium renderer
# -----------------------------------------------------------------------------

func _v16_backdrop(kind: String = "arcane", dim: float = 0.0) -> void:
	var texture: Texture2D = tex_v19_arcane
	if kind == "home":
		texture = tex_v19_home
	elif kind == "forge":
		texture = tex_v19_forge
	if texture != null:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)
	else:
		super._v16_backdrop(kind, dim)
	# strong cinematic vignette like the approved concepts
	draw_rect(Rect2(0,0,34,1280),Color(0,0,0,0.44))
	draw_rect(Rect2(686,0,34,1280),Color(0,0,0,0.44))
	draw_rect(Rect2(0,0,720,28),Color(0,0,0,0.28))
	draw_rect(Rect2(0,1236,720,44),Color(0,0,0,0.32))
	if dim > 0.0:
		draw_rect(Rect2(Vector2.ZERO,SIZE),Color(0,0,0,dim))

func _v19_chamfer_points(r: Rect2, cut: float = 10.0) -> PackedVector2Array:
	return PackedVector2Array([
		r.position + Vector2(cut,0), Vector2(r.end.x-cut,r.position.y),
		Vector2(r.end.x,r.position.y+cut), Vector2(r.end.x,r.end.y-cut),
		Vector2(r.end.x-cut,r.end.y), Vector2(r.position.x+cut,r.end.y),
		Vector2(r.position.x,r.end.y-cut), Vector2(r.position.x,r.position.y+cut)
	])

func _v19_closed(points: PackedVector2Array) -> PackedVector2Array:
	var out := PackedVector2Array(points)
	if points.size() > 0:
		out.append(points[0])
	return out

func _v16_frame(r: Rect2, accent: Color, fill: Color = V16_NAVY, glow: float = 0.15) -> void:
	# Shadow + restrained energy bloom.
	var shadow := Rect2(r.position + Vector2(7,9),r.size)
	draw_colored_polygon(_v19_chamfer_points(shadow,11),Color(0,0,0,0.68))
	for grow in [7.0,4.0]:
		var gr := r.grow(grow)
		draw_polyline(_v19_closed(_v19_chamfer_points(gr,12+grow)),Color(accent,0.05+glow*0.08),5.0)
	# black steel body
	draw_colored_polygon(_v19_chamfer_points(r,11),Color("02040a"))
	# metallic gold outer band
	draw_polyline(_v19_closed(_v19_chamfer_points(r,11)),Color("6f410e"),5.2)
	draw_polyline(_v19_closed(_v19_chamfer_points(r.grow(-2),9)),Color("f1c65c"),1.7)
	# interior
	var inner := r.grow(-7)
	draw_colored_polygon(_v19_chamfer_points(inner,7),fill)
	draw_polyline(_v19_closed(_v19_chamfer_points(inner,7)),Color(accent,0.72),1.5)
	# bevels: warm top, deep lower edge
	draw_line(inner.position+Vector2(18,3),Vector2(inner.end.x-18,inner.position.y+3),Color("fff0a6",0.22),1.4)
	draw_line(Vector2(inner.position.x+16,inner.end.y-3),inner.end-Vector2(16,3),Color(0,0,0,0.78),2.0)
	# corner metalwork + jewels
	for item in [
		[r.position+Vector2(8,8),Vector2(1,1)],
		[Vector2(r.end.x-8,r.position.y+8),Vector2(-1,1)],
		[Vector2(r.position.x+8,r.end.y-8),Vector2(1,-1)],
		[r.end-Vector2(8,8),Vector2(-1,-1)]
	]:
		var p: Vector2 = item[0]
		var d: Vector2 = item[1]
		draw_line(p,p+Vector2(d.x*21,0),Color("e0ac3c"),2.2)
		draw_line(p,p+Vector2(0,d.y*21),Color("e0ac3c"),2.2)
		var j := p+d*5
		draw_colored_polygon(PackedVector2Array([j+Vector2(0,-4),j+Vector2(4,0),j+Vector2(0,4),j+Vector2(-4,0)]),V17_PURPLE)
		draw_circle(j,1.4,V17_PURPLE_HI)

func _v16_title(label: String, y: float, size: int, accent: Color = V16_GOLD) -> void:
	# deep shadow + bronze lowlight + ivory/gold face
	for off in [Vector2(0,5),Vector2(2,3),Vector2(-2,3)]:
		draw_string(v16_title_font,Vector2(38,y)+off,label,HORIZONTAL_ALIGNMENT_CENTER,644,size,Color(0,0,0,0.84))
	draw_string(v16_title_font,Vector2(38,y+1),label,HORIZONTAL_ALIGNMENT_CENTER,644,size,Color("855316"))
	draw_string(v16_title_font,Vector2(38,y-1),label,HORIZONTAL_ALIGNMENT_CENTER,644,size,Color("fff0a6"))
	draw_string(v16_title_font,Vector2(38,y-2),label,HORIZONTAL_ALIGNMENT_CENTER,644,size,Color("e9ba55"))
	_v16_rule(y+22.0,accent,430.0)

func _v16_button(r: Rect2, label: String, accent: Color, size: int, icon_index: int = -1, enabled: bool = true) -> void:
	var a: Color = accent if enabled else Color("555a6c")
	var fill := Color(a,0.16) if enabled else Color("10131b")
	_v16_frame(r,a,fill,0.26 if enabled else 0.03)
	if enabled:
		draw_rect(r.grow(-11),Color(a,0.035))
	var tc := V17_IVORY if enabled else Color("85899a")
	if icon_index >= 0:
		var rad := clampf(r.size.y*0.23,15.0,23.0)
		_v16_medallion(Vector2(r.position.x+rad+18,r.get_center().y),rad,a,icon_index)
		draw_string(v16_title_font,Vector2(r.position.x+rad*2+28,r.get_center().y+float(size)*0.34),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-rad*2-42,size,tc)
	else:
		draw_string(v16_title_font,Vector2(r.position.x+8,r.get_center().y+float(size)*0.34),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-16,size,tc)

func _v16_medallion(center: Vector2, radius: float, accent: Color, icon_index: int) -> void:
	# crisp crest: warm metal ring, dark inner disk, luminous accent ring
	draw_circle(center,radius+7,Color(0,0,0,0.68))
	draw_circle(center,radius+4,Color("5d390e"))
	draw_circle(center,radius+1,Color("e5b44a"))
	draw_circle(center,radius-2,Color("060912"))
	draw_arc(center,radius-5,0,TAU,48,Color(accent,0.95),2.3)
	_v12_icon(icon_index,Rect2(center-Vector2(radius*0.66,radius*0.66),Vector2(radius*1.32,radius*1.32)))
	var gem := center+Vector2(0,-radius-5)
	draw_colored_polygon(PackedVector2Array([gem+Vector2(0,-6),gem+Vector2(6,0),gem+Vector2(0,6),gem+Vector2(-6,0)]),V17_PURPLE)
	draw_colored_polygon(PackedVector2Array([gem+Vector2(0,-2.4),gem+Vector2(2.4,0),gem+Vector2(0,2.4),gem+Vector2(-2.4,0)]),V17_PURPLE_HI)

func _v16_currency(amount: int, r: Rect2 = Rect2(510,22,190,88)) -> void:
	_v16_frame(r,V16_GOLD,Color("050810"),0.24)
	_v16_medallion(Vector2(r.position.x+42,r.get_center().y),27,V16_GOLD,11)
	draw_string(v16_title_font,Vector2(r.position.x+78,r.get_center().y+12),str(amount),HORIZONTAL_ALIGNMENT_LEFT,r.size.x-90,30,Color("fff0a6"))

func _v16_header(title: String, subtitle: String, accent: Color, icon_index: int, kind: String = "arcane") -> void:
	_v16_backdrop(kind)
	_v16_medallion(Vector2(360,67),29,accent,icon_index)
	_v16_title(title,143,52,accent)
	_v16_center(subtitle,188,17,V16_MUTED)
	_v16_currency(int(meta.coins),Rect2(510,20,190,84))
	_v16_button(META_BACK,"‹  BACK",V16_PURPLE,17)
	if meta_notice_time > 0.0:
		_v16_center(meta_notice,1125,15,C_GREEN if meta_notice.begins_with("UPGRADE") else C_RED)

# -----------------------------------------------------------------------------
# Home — approved concept composition
# -----------------------------------------------------------------------------

func draw_home() -> void:
	if home_overlay == "missions":
		draw_missions_screen()
		return
	if home_overlay == "pass":
		draw_pass_screen()
		return
	_v16_backdrop("home")
	_v16_frame(Rect2(18,18,190,100),V16_PURPLE,Color("050812"),0.18)
	_v16_center_in(Rect2(30,32,166,28),"BEST FLOOR",13,V16_MUTED,true)
	_v16_center_in(Rect2(30,57,166,49),str(int(meta.best_floor)),35,V17_IVORY,true)
	_v16_currency(int(meta.coins),Rect2(512,18,190,92))
	# approved title hierarchy
	draw_string(v16_title_font,Vector2(48,159),"ONE MORE",HORIZONTAL_ALIGNMENT_CENTER,624,44,V17_IVORY)
	for off in [Vector2(0,5),Vector2(2,3),Vector2(-2,3)]:
		draw_string(v16_title_font,Vector2(46,236)+off,"FLOOR",HORIZONTAL_ALIGNMENT_CENTER,628,75,Color(0,0,0,0.78))
	draw_string(v16_title_font,Vector2(46,233),"FLOOR",HORIZONTAL_ALIGNMENT_CENTER,628,75,Color("fff0a6"))
	_v16_rule(255,V16_PURPLE,390)
	_v16_center("CLIMB  •  LOOT  •  RISK IT ALL",289,14,V16_MUTED)
	# hero belongs to the environment, not a floating icon
	_v15_soft_glow(Vector2(360,736),70,V16_PURPLE,0.95)
	draw_wanderer(Vector2(360,735),1.55,false)
	_v16_button(PLAY,"PLAY",V16_GOLD,39)
	_v16_button(V10_SETTINGS_HOME,"SETTINGS",V16_BLUE,13,9)
	_v16_button(MISSIONS_BTN,"MISSIONS",V16_GREEN,18,0)
	_v16_button(PASS_BTN,"TOWER PASS",V16_PURPLE,18,6)
	_v19_home_tab(HERO_TAB,"HERO",8,V16_BLUE)
	_v19_home_tab(FORGE_TAB,"FORGE",7,V16_ORANGE)
	_v19_home_tab(TALENTS_TAB,"TALENTS",1,V16_PURPLE)
	_v19_home_tab(VAULT_TAB,"VAULT",10,V16_GOLD)
	_v16_frame(Rect2(20,1156,680,76),Color("323a5c"),Color("030611"),0.08)
	_v16_text("POWER",Vector2(50,1194),14,V16_MUTED,true)
	_v16_text(str(int(meta.power_score())),Vector2(115,1197),24,V17_GOLD_HI,true)
	draw_string(v16_body_font,Vector2(410,1196),"KAMILUNAVO GAMES",HORIZONTAL_ALIGNMENT_RIGHT,245,12,V16_MUTED)
	var jewel := Vector2(360,1192)
	draw_colored_polygon(PackedVector2Array([jewel+Vector2(0,-13),jewel+Vector2(13,0),jewel+Vector2(0,13),jewel+Vector2(-13,0)]),Color("4a236f"))
	draw_colored_polygon(PackedVector2Array([jewel+Vector2(0,-7),jewel+Vector2(7,0),jewel+Vector2(0,7),jewel+Vector2(-7,0)]),V17_PURPLE)
	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step in [0,1]:
		_draw_tutorial_overlay()

func _v16_center_in(r: Rect2, label: String, size: int, color: Color, use_title: bool = false) -> void:
	var f: Font = v16_title_font if use_title else v16_body_font
	draw_string(f,Vector2(r.position.x,r.get_center().y+float(size)*0.34),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x,size,color)

func _v19_home_tab(r: Rect2, label: String, icon_index: int, accent: Color) -> void:
	_v16_frame(r,accent,Color("060a13"),0.16)
	_v16_medallion(Vector2(r.get_center().x,r.position.y+38),23,accent,icon_index)
	draw_string(v16_title_font,Vector2(r.position.x+6,r.end.y-19),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-12,15,V17_IVORY)

# -----------------------------------------------------------------------------
# Hero / Forge / Talents
# -----------------------------------------------------------------------------

func draw_hero_screen() -> void:
	_v16_header("HERO","Permanent Wanderer training",V16_GREEN,0,"arcane")
	# portal / dais
	_v15_soft_glow(Vector2(360,490),210,V16_PURPLE,1.0)
	for rr in [158.0,132.0,106.0]:
		draw_arc(Vector2(360,480),rr,elapsed*0.06,elapsed*0.06+TAU,96,Color(V16_PURPLE,0.24),2.0)
	draw_circle(Vector2(360,624),150,Color("070817"))
	draw_arc(Vector2(360,624),148,0,TAU,64,Color("7d47b7"),3.0)
	draw_arc(Vector2(360,624),124,0,TAU,64,Color(V16_PURPLE,0.28),2.0)
	draw_wanderer(Vector2(360,544),2.55,false)
	var card := Rect2(54,660,612,306)
	_v16_frame(card,V16_PURPLE,Color("06101d"),0.20)
	_v16_center("WANDERER  •  LEVEL %d" % int(meta.hero_level),713,31,V17_GOLD_HI,true)
	_v19_stat_row(Rect2(112,754,496,50),0,"Base HP bonus","+%d" % int(meta.hp_bonus()),V16_GREEN)
	_v19_stat_row(Rect2(112,827,496,50),6,"Combined damage","x%.2f" % meta.damage_multiplier(),V16_ORANGE)
	_v19_stat_row(Rect2(112,900,496,50),8,"Power",str(int(meta.power_score())),V16_PURPLE_HI)
	_v16_button(V19_HERO_BUY,"TRAIN  %d" % int(meta.hero_cost()),V16_PURPLE,25,-1,meta.coins >= meta.hero_cost())
	_v16_center("Each Hero level: +5 HP and +3.5% damage",1125,15,V16_MUTED)

func _v19_stat_row(r: Rect2, icon_index: int, label: String, value: String, accent: Color) -> void:
	_v16_medallion(Vector2(r.position.x+24,r.get_center().y),18,accent,icon_index)
	_v16_text(label,r.position+Vector2(55,33),18,accent)
	draw_string(v16_title_font,Vector2(r.end.x-160,r.position.y+35),value,HORIZONTAL_ALIGNMENT_RIGHT,150,23,accent)
	draw_line(Vector2(r.position.x+54,r.end.y),Vector2(r.end.x-5,r.end.y),Color(accent,0.18),1.0)

func draw_forge_screen() -> void:
	_v16_header("FORGE","Temper the Wanderer's weapon",V16_ORANGE,7,"forge")
	_v15_soft_glow(Vector2(360,490),180,V16_ORANGE,0.72)
	_v16_medallion(Vector2(360,470),88,V16_ORANGE,7)
	_v16_medallion(Vector2(405,548),42,V16_PURPLE,6)
	var card := Rect2(78,690,564,250)
	_v16_frame(card,V16_ORANGE,Color("100a09"),0.24)
	_v16_center("FORGE LEVEL %d" % int(meta.forge_level),748,31,V17_IVORY,true)
	_v16_center("Weapon multiplier contribution",805,17,V16_MUTED)
	_v16_center("+%.1f%% DAMAGE" % (float(meta.forge_level)*8.5),877,36,V17_GOLD_HI,true)
	_v16_button(V19_FORGE_BUY,"TEMPER  %d" % int(meta.forge_cost()),V16_ORANGE,24,11,meta.coins >= meta.forge_cost())
	_v16_center("Every Forge level adds +8.5% permanent damage.",1100,15,V16_MUTED)

func talent_rect(i: int) -> Rect2:
	return Rect2(28,500 + i*198,664,170)

func draw_talents_screen() -> void:
	_v16_header("TALENTS","Permanent passive bonuses",V16_PURPLE,1,"arcane")
	var rows: Array = [
		{"name":"VITALITY","kind":"vitality","level":meta.vitality_level,"desc":"+12 starting HP / level","color":V16_GREEN,"icon":0},
		{"name":"PRECISION","kind":"precision","level":meta.precision_level,"desc":"+1.8% starting crit / level","color":V16_PURPLE,"icon":1},
		{"name":"FORTUNE","kind":"fortune","level":meta.fortune_level,"desc":"+6% coin drops / level","color":V16_GOLD,"icon":11},
	]
	for i: int in range(rows.size()):
		var row: Dictionary = rows[i]
		var r := talent_rect(i)
		var accent: Color = row["color"]
		_v16_frame(r,accent,Color(accent,0.075),0.20)
		_v16_medallion(Vector2(r.position.x+92,r.get_center().y),48,accent,int(row["icon"]))
		_v16_text(String(row["name"]),r.position+Vector2(174,62),27,V17_IVORY,true)
		_v16_text("Lv. %d  •  %s" % [int(row["level"]),String(row["desc"])],r.position+Vector2(174,100),15,V16_MUTED)
		draw_line(r.position+Vector2(176,126),r.position+Vector2(405,126),Color(accent,0.30),1.0)
		var cost: int = int(meta.talent_cost(String(row["kind"])))
		var buy := Rect2(r.end.x-230,r.position.y+48,205,74)
		_v16_button(buy,"UPGRADE  %d" % cost,accent,14,11,meta.coins >= cost)

# -----------------------------------------------------------------------------
# Missions — six real contracts in the reference composition
# -----------------------------------------------------------------------------

func mission_rect(index: int) -> Rect2:
	if index < 3:
		return Rect2(40,300 + index*116,640,102)
	return Rect2(40,704 + (index-3)*116,640,102)

func draw_missions_screen() -> void:
	_v16_header("MISSIONS","Daily and weekly tower contracts",V16_GREEN,0,"arcane")
	_v19_section("DAILY",270,V16_GREEN)
	var daily: Array = missions.all_daily()
	for i: int in range(daily.size()):
		_v19_mission_row(daily[i],i,false)
	_v19_section("WEEKLY",674,V16_PURPLE)
	var weekly: Array = missions.all_weekly()
	for i: int in range(weekly.size()):
		_v19_mission_row(weekly[i],i+3,true)
	_v16_frame(Rect2(84,1060,552,62),V16_GREEN,Color("05120f"),0.18)
	_v16_medallion(Vector2(120,1091),20,V16_GOLD,11)
	_v16_center("TOWER CONTRACTS  •  CLAIM COMPLETED REWARDS",1098,13,V16_GREEN)
	_v16_button(OVERLAY_BACK,"‹  BACK",V16_PURPLE,17)
	_draw_notice(1118)

func _v19_section(label: String, y: float, accent: Color) -> void:
	_v16_text(label,Vector2(52,y),22,accent,true)
	draw_line(Vector2(52,y+12),Vector2(185,y+12),Color(accent,0.50),1.0)
	var p:=Vector2(196,y+12)
	draw_colored_polygon(PackedVector2Array([p+Vector2(0,-4),p+Vector2(4,0),p+Vector2(0,4),p+Vector2(-4,0)]),accent)

func _v19_mission_row(mission: Dictionary, index: int, weekly: bool) -> void:
	var r := mission_rect(index)
	var complete: bool = bool(missions.is_complete(mission,weekly))
	var claimed: bool = bool(missions.is_claimed(mission,weekly))
	var accent: Color = V16_PURPLE if weekly else V16_GREEN
	if complete and not claimed:
		accent = V16_GOLD
	_v16_frame(r,accent,Color("050b13"),0.14)
	_v16_medallion(Vector2(r.position.x+54,r.get_center().y),32,accent,8)
	_v16_text(String(mission["title"]),r.position+Vector2(104,34),21,V17_IVORY,true)
	var progress := int(missions.progress(mission,weekly))
	var goal := int(mission["goal"])
	_v16_text("%d / %d" % [progress,goal],r.position+Vector2(104,62),14,accent)
	_v16_text("%d coins  •  %d XP" % [int(mission["coins"]),int(mission["xp"])],r.position+Vector2(104,86),14,V17_GOLD_HI)
	var status := "CLAIMED" if claimed else ("CLAIM" if complete else "IN PROGRESS")
	var status_color := V16_MUTED if claimed else (V16_GREEN if complete else accent)
	if complete:
		var c:=Vector2(r.end.x-82,r.position.y+34)
		draw_arc(c,18,0,TAU,32,Color(status_color,0.88),2.2)
		draw_line(c+Vector2(-7,0),c+Vector2(-1,7),status_color,2.7)
		draw_line(c+Vector2(-1,7),c+Vector2(9,-8),status_color,2.7)
	draw_string(v16_title_font,Vector2(r.end.x-145,r.position.y+78),status,HORIZONTAL_ALIGNMENT_CENTER,128,13,status_color)

# -----------------------------------------------------------------------------
# Tower Pass — two-level reward rail like the approved screen
# -----------------------------------------------------------------------------

func draw_pass_screen() -> void:
	_v16_header("TOWER PASS","FREE SEASON PATH",V16_PURPLE,6,"arcane")
	var level_no := int(tower_pass.level())
	var max_level := int(tower_pass.MAX_LEVEL)
	var progress: Dictionary = tower_pass.progress_to_next()
	var top := Rect2(42,278,636,274)
	_v16_frame(top,V16_GOLD,Color("050912"),0.24)
	var plaque := Rect2(72,308,154,168)
	_v16_frame(plaque,V16_PURPLE,Color("10091d"),0.24)
	_v16_center_in(Rect2(82,326,134,30),"LEVEL",14,V16_MUTED,true)
	_v16_center_in(Rect2(82,350,134,74),str(level_no),55,V17_IVORY,true)
	_v16_center_in(Rect2(82,420,134,34),"/ %d" % max_level,20,V16_MUTED,true)
	var reward_level := mini(max_level,maxi(1,level_no+1))
	if level_no >= max_level:
		reward_level = max_level
	var reward: Dictionary = tower_pass.reward_for(reward_level)
	_v16_text("NEXT REWARD",Vector2(268,346),14,V16_MUTED)
	_v16_text(String(reward.get("label","BIG COIN CACHE")),Vector2(268,392),25,V17_GOLD_HI,true)
	_v16_text("%d COINS" % int(reward.get("coins",0)),Vector2(268,431),18,V17_IVORY)
	_v18_reward_chest(Vector2(570,390),0.64)
	var bar:=Rect2(78,500,564,24)
	draw_rect(bar,Color("1c1231"))
	var fillw:=bar.size.x*float(progress["ratio"])
	draw_rect(Rect2(bar.position,Vector2(fillw,bar.size.y)),Color("8f43df"))
	draw_line(bar.position+Vector2(4,3),Vector2(bar.position.x+maxf(4,fillw-4),bar.position.y+3),Color("e2acff"),2)
	_v16_center("%d / %d XP" % [int(progress["current"]),int(progress["needed"])],530,14,V17_IVORY)
	_v16_center("REWARD TRACK",606,27,V16_MUTED,true)
	var levels: Array[int] = [maxi(1,level_no-1),maxi(1,level_no)]
	for i: int in range(2):
		var l:=levels[i]
		var rr:Dictionary=tower_pass.reward_for(l)
		var y:=658+i*158
		var row:=Rect2(160,y,500,126)
		var unlocked:=l<=level_no
		var claimable:=bool(tower_pass.can_claim(l))
		var accent:=V16_PURPLE_HI if claimable else (V16_GOLD if unlocked else Color("555b70"))
		_v16_frame(row,accent,Color("050912"),0.20)
		var badge:=Vector2(105,row.get_center().y)
		draw_colored_polygon(PackedVector2Array([badge+Vector2(0,-42),badge+Vector2(42,0),badge+Vector2(0,42),badge+Vector2(-42,0)]),Color("090716"))
		draw_polyline(_v19_closed(PackedVector2Array([badge+Vector2(0,-42),badge+Vector2(42,0),badge+Vector2(0,42),badge+Vector2(-42,0)])),V16_PURPLE_HI,2.5)
		draw_string(v16_title_font,Vector2(72,row.get_center().y+8),"LV\n%d" % l,HORIZONTAL_ALIGNMENT_CENTER,66,18,V17_IVORY)
		if String(rr.get("label","")) == "BIG COIN CACHE":
			_v18_reward_chest(Vector2(row.position.x+84,row.get_center().y),0.34)
			_v16_text("BIG COIN CACHE",row.position+Vector2(160,51),21,V17_GOLD_HI,true)
		else:
			_v16_medallion(Vector2(row.position.x+82,row.get_center().y),32,V16_GOLD,11)
			_v16_text(String(rr.get("label","COINS")),row.position+Vector2(160,49),22,V17_GOLD_HI,true)
		_v16_text("+%d" % int(rr.get("coins",0)),row.position+Vector2(160,86),20,V17_IVORY)
		if claimable:
			_v16_button(Rect2(row.end.x-150,row.position.y+30,130,66),"CLAIM",V16_PURPLE,17)
		elif unlocked:
			draw_circle(Vector2(row.end.x-82,row.position.y+47),22,Color(V16_GREEN,0.14))
			draw_arc(Vector2(row.end.x-82,row.position.y+47),21,0,TAU,32,V16_GREEN,2.5)
			draw_line(Vector2(row.end.x-92,row.position.y+47),Vector2(row.end.x-84,row.position.y+56),V16_GREEN,3)
			draw_line(Vector2(row.end.x-84,row.position.y+56),Vector2(row.end.x-69,row.position.y+38),V16_GREEN,3)
			draw_string(v16_title_font,Vector2(row.end.x-145,row.position.y+91),"UNLOCKED",HORIZONTAL_ALIGNMENT_CENTER,126,14,V16_GREEN)
	var next_claim:=int(tower_pass.next_claimable())
	_v16_button(PASS_CLAIM,"CLAIM LEVEL %d" % next_claim if next_claim > 0 else "NO REWARD READY",V16_PURPLE if next_claim>0 else Color("555a6c"),22,-1,next_claim>0)
	_v16_button(OVERLAY_BACK,"‹  BACK",V16_BLUE,17)
	_draw_notice(1015)

# -----------------------------------------------------------------------------
# Vault — real inventory renderer; title is VAULT only
# -----------------------------------------------------------------------------

func vault_v08_item_rect(local_index: int) -> Rect2:
	return Rect2(34,372 + local_index*111,652,98)

func draw_vault_screen() -> void:
	_v16_header("VAULT","Compare, lock, equip, dismantle and craft gear",V16_GOLD,10,"arcane")
	var bonuses:Dictionary=loot.equipped_bonuses()
	var info:=Rect2(22,220,676,70)
	_v16_frame(info,V16_GOLD,Color("050a12"),0.16)
	_v16_medallion(Vector2(62,255),23,V16_PURPLE,10)
	_v16_text("SOUL SHARDS  %d" % int(loot.shards),Vector2(98,262),16,C_CYAN,true)
	draw_string(v16_body_font,Vector2(340,262),"DMG +%.1f%%   HP +%d   CRIT +%.1f%%" % [float(bonuses["damage_pct"])*100.0,int(round(float(bonuses["hp"]))),float(bonuses["crit_pct"])*100.0],HORIZONTAL_ALIGNMENT_RIGHT,330,13,V17_IVORY)
	_v16_button(V8_FILTER,"FILTER: %s" % String(V8_FILTERS[vault_filter_index]).to_upper(),V16_PURPLE,12)
	_v16_button(V8_SORT,"SORT: %s" % String(V8_SORTS[vault_sort_index]).to_upper(),V16_BLUE,12)
	var selected:=_selected_vault_item_v08()
	var lock_label:="LOCK ITEM"
	var lock_color:=Color("666a79")
	if not selected.is_empty():
		lock_label="UNLOCK" if loot.is_locked(selected) else "LOCK"
		lock_color=C_CYAN if loot.is_locked(selected) else V16_GOLD
	_v16_button(V8_LOCK,lock_label,lock_color,12,-1,not selected.is_empty())
	var visible:Array[int]=_visible_vault_indices()
	var first:=vault_page*V8_PAGE_SIZE
	for local_index: int in range(V8_PAGE_SIZE):
		var page_pos:=first+local_index
		if page_pos>=visible.size():
			break
		var item:Dictionary=loot.inventory[int(visible[page_pos])]
		_v19_vault_item(item,local_index,String(item.get("id",""))==selected_vault_id)
	_v16_vault_comparison(selected)
	_v16_button(V8_EQUIP,"EQUIP",V16_BLUE,13,8,not selected.is_empty())
	var can_dismantle:=not selected.is_empty() and not loot.is_locked(selected) and not loot.is_equipped(selected)
	_v16_button(V8_DISMANTLE,"DISMANTLE",Color("777b89"),12,7,can_dismantle)
	_v16_button(V8_PREV,"‹",Color("555b6b"),20,-1,vault_page>0)
	_v16_button(V8_NEXT,"›",V16_PURPLE,20,-1,vault_page<_vault_max_page())
	var craft_ready:=int(loot.shards)>=int(loot.craft_cost())
	_v16_button(V8_CRAFT_WEAPON,"CRAFT WEAPON",V16_PURPLE,11,6,craft_ready)
	_v16_button(V8_CRAFT_ARMOR,"CRAFT ARMOR",V16_PURPLE,11,8,craft_ready)
	_v16_button(V8_CRAFT_RELIC,"CRAFT RELIC",V16_PURPLE,11,10,craft_ready)
	_v16_center("CRAFT %d SHARDS  •  GUARANTEED RARE+" % int(loot.craft_cost()),1050,13,V16_PURPLE_HI)
	_v16_button(META_BACK,"‹  BACK",V16_PURPLE,17)
	_draw_notice(1117)

func _v19_vault_item(item:Dictionary,local_index:int,selected_now:bool)->void:
	var r:=vault_v08_item_rect(local_index)
	var rarity:=String(item["rarity"])
	var rarity_accent:=rarity_color(rarity)
	var accent:=C_CYAN if selected_now else rarity_accent
	_v16_frame(r,accent,Color("050b14"),0.14)
	var slot:=String(item["slot"])
	var icon_index:=6 if slot=="weapon" else (8 if slot=="armor" else 10)
	_v16_medallion(Vector2(r.position.x+52,r.get_center().y),31,accent,icon_index)
	_v16_text(String(item["name"]),r.position+Vector2(102,31),19,V17_IVORY,true)
	_v16_text("%s • %s • Lv.%d • SCORE %d" % [rarity,slot.to_upper(),int(item["level"]),int(loot.item_score(item))],r.position+Vector2(102,55),11,rarity_accent)
	_v16_text(loot.stat_line(item),r.position+Vector2(102,81),13,V16_MUTED)
	var tags:=loot.trait_line(item)
	if tags!="":
		draw_string(v16_body_font,Vector2(r.position.x+365,r.position.y+81),tags,HORIZONTAL_ALIGNMENT_LEFT,190,10,V16_PURPLE_HI)
	var status:="EQUIPPED" if loot.is_equipped(item) else ("SELECTED" if selected_now else "TAP  ›")
	draw_string(v16_title_font,Vector2(r.end.x-108,r.position.y+57),status,HORIZONTAL_ALIGNMENT_CENTER,92,12,V16_GREEN if loot.is_equipped(item) else V16_GOLD)

# -----------------------------------------------------------------------------
# Settings modal — same live settings, approved visual hierarchy
# -----------------------------------------------------------------------------

func _draw_settings_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO,SIZE),Color(0,0,0,0.76))
	var modal:=Rect2(64,205,592,850)
	_v16_frame(modal,V16_BLUE,Color("07101e"),0.26)
	_v16_title("SETTINGS",294,44,V16_GOLD)
	_v16_center("Playtest controls & privacy",336,17,V16_MUTED)
	_v19_setting_row(V10_SET_MUSIC,"MUSIC",bool(settings.music_enabled),int(float(settings.music_volume)*100.0),2,V16_GREEN)
	_v19_setting_row(V10_SET_SFX,"SFX",bool(settings.sfx_enabled),int(float(settings.sfx_volume)*100.0),3,V16_GREEN)
	_v19_setting_row(V10_SET_HAPTICS,"HAPTICS",bool(settings.haptics_enabled),-1,4,V16_GREEN)
	_v19_setting_row(V10_SET_ANALYTICS,"ANALYTICS",bool(settings.analytics_enabled),-1,5,Color("747888"))
	_v16_button(V10_SET_TUTORIAL,"REPLAY TUTORIAL",V16_PURPLE,18,8)
	_v16_button(V10_SET_BACK,"BACK",V16_BLUE,24)
	_v16_center("Analytics is opt-in. Playtest events stay local in this build.",930,12,V16_MUTED)

func _v19_setting_row(r:Rect2,label:String,on:bool,percent:int,icon_index:int,accent:Color)->void:
	var a:=accent if on else Color("6b6f7d")
	_v16_frame(r,a,Color(a,0.10) if on else Color("11141d"),0.15)
	_v16_medallion(Vector2(r.position.x+42,r.get_center().y),23,a,icon_index)
	_v16_text("%s %s" % [label,"ON" if on else "OFF"],Vector2(r.position.x+82,r.position.y+40),18,V17_IVORY if on else V16_MUTED,true)
	if percent>=0:
		draw_string(v16_title_font,Vector2(r.end.x-90,r.position.y+40),"%d%%" % percent,HORIZONTAL_ALIGNMENT_RIGHT,72,18,V17_IVORY)
		var bar:=Rect2(r.position.x+160,r.end.y-20,r.size.x-230,8)
		draw_rect(bar,Color("10131b"))
		var ratio:=clampf(float(percent)/100.0,0,1)
		draw_rect(Rect2(bar.position,Vector2(bar.size.x*ratio,bar.size.y)),V16_GREEN)
		var knob:=Vector2(bar.position.x+bar.size.x*ratio,bar.get_center().y)
		draw_colored_polygon(PackedVector2Array([knob+Vector2(0,-10),knob+Vector2(10,0),knob+Vector2(0,10),knob+Vector2(-10,0)]),V17_GOLD_HI)
	else:
		var p:=Vector2(r.end.x-45,r.get_center().y)
		draw_colored_polygon(PackedVector2Array([p+Vector2(0,-12),p+Vector2(12,0),p+Vector2(0,12),p+Vector2(-12,0)]),Color(a,0.30))
		if on:
			draw_colored_polygon(PackedVector2Array([p+Vector2(0,-7),p+Vector2(7,0),p+Vector2(0,7),p+Vector2(-7,0)]),V16_GREEN)

# -----------------------------------------------------------------------------
# Input alignment for moved premium controls
# -----------------------------------------------------------------------------

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if pressed and not settings_open:
		if state == State.HERO and V19_HERO_BUY.has_point(pos):
			buy_meta("hero")
			_audio("menu")
			return
		if state == State.FORGE and V19_FORGE_BUY.has_point(pos):
			buy_meta("forge")
			_audio("menu")
			return
	super.pointer(pos,pressed,id)
