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
	v16_body_font = SystemFont.new()
	v16_body_font.font_names = PackedStringArray(["Avenir Next", "Helvetica Neue", "DejaVu Sans"])
	v16_body_font.font_weight = 500
	v16_body_font.allow_system_fallback = true
	queue_redraw()

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
	_v16_frame(Rect2(34,1154,652,74),Color("343d63"),Color("060a12"),0.08)
	_v16_text("POWER",Vector2(56,1190),13,V16_MUTED)
	_v16_text(str(int(meta.power_score())),Vector2(116,1192),21,V16_GOLD_HI,true)
	draw_string(v16_body_font,Vector2(330,1193),"KAMILUNAVO GAMES",HORIZONTAL_ALIGNMENT_RIGHT,328,11,V16_MUTED)
	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step in [0,1]:
		_draw_tutorial_overlay()

func _v16_home_tab(r: Rect2, label: String, icon_index: int, accent: Color) -> void:
	_v16_frame(r,accent,Color("070d18"),0.14)
	_v16_medallion(Vector2(r.get_center().x,r.position.y+34),23.0,accent,icon_index)
	draw_string(v16_body_font,Vector2(r.position.x+5,r.position.y+86),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-10,13,V16_TEXT)

# -----------------------------------------------------------------------------
# SETTINGS + PAUSE
# -----------------------------------------------------------------------------

func _draw_settings_overlay() -> void:
	# Keep the real underlying menu visible, but turn it into a cinematic backdrop.
	draw_rect(Rect2(Vector2.ZERO,SIZE),Color(0.0,0.0,0.025,0.78))
	var modal := Rect2(54,145,612,785)
	_v16_frame(modal,V16_BLUE,Color("0a1426"),0.24)
	_v16_medallion(Vector2(360,187),27.0,V16_BLUE,9)
	_v16_title("SETTINGS",236,42,V16_GOLD)
	_v16_center("Playtest controls & privacy",274,15,V16_MUTED)
	_v16_setting_row(V10_SET_MUSIC,"MUSIC",bool(settings.music_enabled),int(float(settings.music_volume)*100.0),2,V16_GREEN)
	_v16_setting_row(V10_SET_SFX,"SFX",bool(settings.sfx_enabled),int(float(settings.sfx_volume)*100.0),3,V16_GREEN)
	_v16_setting_row(V10_SET_HAPTICS,"HAPTICS",bool(settings.haptics_enabled),-1,4,V16_GREEN)
	_v16_setting_row(V10_SET_ANALYTICS,"ANALYTICS",bool(settings.analytics_enabled),-1,5,V16_GOLD)
	_v16_button(V10_SET_TUTORIAL,"REPLAY TUTORIAL",V16_PURPLE,17,6)
	_v16_rule(750,V16_PURPLE,420)
	_v16_button(V10_SET_BACK,"BACK",V16_BLUE,21)
	_v16_center("Analytics is opt-in. Playtest events stay local in this build.",895,12,V16_MUTED)

func _v16_setting_row(r: Rect2, label: String, enabled: bool, percent: int, icon_index: int, accent: Color) -> void:
	var a: Color = accent if enabled else Color("717386")
	_v16_frame(r,a,Color(a,0.09) if enabled else Color("141824"),0.12)
	_v16_medallion(Vector2(r.position.x+34,r.get_center().y),21,a,icon_index)
	_v16_text("%s  %s" % [label,"ON" if enabled else "OFF"],Vector2(r.position.x+72,r.position.y+38),17,V16_TEXT if enabled else V16_MUTED,true)
	if percent >= 0:
		_v16_text("%d%%" % percent,Vector2(r.end.x-70,r.position.y+38),16,V16_TEXT)
		var track := Rect2(r.position.x+74,r.end.y-19,r.size.x-114,7)
		draw_rect(track,Color("080b10"))
		draw_rect(Rect2(track.position,Vector2(track.size.x*clampf(float(percent)/100.0,0.0,1.0),track.size.y)),a)
		var knob := Vector2(track.position.x+track.size.x*clampf(float(percent)/100.0,0.0,1.0),track.get_center().y)
		draw_colored_polygon(PackedVector2Array([knob+Vector2(0,-7),knob+Vector2(7,0),knob+Vector2(0,7),knob+Vector2(-7,0)]),V16_GOLD_HI)
	else:
		var c := Vector2(r.end.x-42,r.get_center().y)
		draw_colored_polygon(PackedVector2Array([c+Vector2(0,-10),c+Vector2(10,0),c+Vector2(0,10),c+Vector2(-10,0)]),a)

func _draw_pause_overlay() -> void:
	draw_rect(Rect2(Vector2.ZERO,SIZE),Color(0.0,0.0,0.025,0.78))
	_v16_frame(Rect2(104,315,512,500),V16_PURPLE,Color("0a1020"),0.22)
	_v16_medallion(Vector2(360,372),29,V16_PURPLE,6)
	_v16_title("PAUSED",430,42,V16_GOLD)
	_v16_center("Floor %d  •  %s" % [int(run.floor_no),String(current_room.get("area","TOWER"))],466,15,V16_MUTED)
	_v16_button(V10_RESUME,"RESUME",V16_GREEN,21)
	_v16_button(V10_PAUSE_SETTINGS,"SETTINGS",V16_BLUE,19,9)
	_v16_button(V10_PAUSE_HOME,"RETURN HOME",V16_PURPLE,19)

# -----------------------------------------------------------------------------
# HERO / FORGE / TALENTS
# -----------------------------------------------------------------------------

func draw_hero_screen() -> void:
	_v16_header("HERO","Permanent Wanderer training",V16_PURPLE,0,"arcane")
	# layered summoning platform
	_v15_soft_glow(Vector2(360,405),190,V16_PURPLE,1.15)
	draw_circle(Vector2(360,405),146,Color("110b23"))
	draw_arc(Vector2(360,405),143,elapsed*0.12,elapsed*0.12+TAU,72,Color(V16_PURPLE,0.48),2.0)
	draw_arc(Vector2(360,405),118,-elapsed*0.08,-elapsed*0.08+TAU,72,Color(V16_PURPLE_HI,0.22),1.0)
	draw_wanderer(Vector2(360,408),2.18,false)
	var card := Rect2(78,565,564,235)
	_v16_frame(card,V16_BLUE,Color("081321"),0.18)
	_v16_center("WANDERER  •  LEVEL %d" % int(meta.hero_level),615,29,V16_TEXT,true)
	_v16_stat_line(Rect2(126,642,468,40),0,"Base HP bonus","+%d" % int(meta.hp_bonus()),V16_GREEN)
	_v16_stat_line(Rect2(126,690,468,40),6,"Combined damage","x%.2f" % meta.damage_multiplier(),V16_GOLD)
	_v16_stat_line(Rect2(126,738,468,40),8,"Power",str(int(meta.power_score())),V16_PURPLE_HI)
	_v16_button(META_BUY,"TRAIN  %d" % int(meta.hero_cost()),V16_PURPLE,22,-1,meta.coins >= meta.hero_cost())
	_v16_center("Each Hero level: +5 HP and +3.5% damage",975,15,V16_MUTED)

func _v16_stat_line(r: Rect2, icon_index: int, label: String, value: String, accent: Color) -> void:
	_v16_medallion(Vector2(r.position.x+20,r.get_center().y),14,accent,icon_index)
	_v16_text(label,Vector2(r.position.x+46,r.position.y+27),16,accent)
	draw_string(v16_title_font,Vector2(r.end.x-180,r.position.y+28),value,HORIZONTAL_ALIGNMENT_RIGHT,170,21,accent)
	draw_line(Vector2(r.position.x+44,r.end.y-2),Vector2(r.end.x-8,r.end.y-2),Color(accent,0.15),1.0)

func draw_forge_screen() -> void:
	_v16_header("FORGE","Temper the Wanderer's weapon",V16_ORANGE,7,"forge")
	_v15_soft_glow(Vector2(360,417),170,V16_ORANGE,0.95)
	_v16_medallion(Vector2(360,405),86,V16_ORANGE,7)
	_v16_medallion(Vector2(404,462),39,V16_PURPLE,6)
	var card := Rect2(78,565,564,230)
	_v16_frame(card,V16_ORANGE,Color("160d0b"),0.23)
	_v16_center("FORGE LEVEL %d" % int(meta.forge_level),618,30,V16_TEXT,true)
	_v16_center("Weapon multiplier contribution",665,16,V16_MUTED)
	_v16_center("+%.1f%% DAMAGE" % (float(meta.forge_level)*8.5),726,32,V16_GOLD_HI,true)
	_v16_button(META_BUY,"TEMPER  %d" % int(meta.forge_cost()),V16_ORANGE,22,11,meta.coins >= meta.forge_cost())
	_v16_center("Every Forge level adds +8.5% permanent damage.",975,15,V16_MUTED)

func draw_talents_screen() -> void:
	_v16_header("TALENTS","Permanent passive bonuses",V16_PURPLE,1,"arcane")
	# Faint central sigil behind the cards.
	_v15_soft_glow(Vector2(360,520),245,V16_PURPLE,0.72)
	var rows: Array = [
		{"name":"VITALITY","kind":"vitality","level":meta.vitality_level,"desc":"+12 starting HP / level","color":V16_GREEN,"icon":0},
		{"name":"PRECISION","kind":"precision","level":meta.precision_level,"desc":"+1.8% starting crit / level","color":V16_PURPLE,"icon":1},
		{"name":"FORTUNE","kind":"fortune","level":meta.fortune_level,"desc":"+6% coin drops / level","color":V16_GOLD,"icon":11},
	]
	for i: int in range(rows.size()):
		var row: Dictionary = rows[i]
		var r: Rect2 = talent_rect(i)
		var accent: Color = row["color"]
		_v16_frame(r,accent,Color(accent,0.075),0.18)
		_v16_medallion(Vector2(r.position.x+66,r.get_center().y),39,accent,int(row["icon"]))
		_v16_text(String(row["name"]),Vector2(r.position.x+132,r.position.y+45),24,V16_TEXT,true)
		_v16_text("Lv. %d  •  %s" % [int(row["level"]),String(row["desc"])],Vector2(r.position.x+132,r.position.y+80),14,V16_MUTED)
		var cost: int = int(meta.talent_cost(String(row["kind"])))
		var buy := Rect2(r.end.x-180,r.position.y+31,154,72)
		_v16_button(buy,"UPGRADE  %d" % cost,accent,13,11,meta.coins >= cost)

# -----------------------------------------------------------------------------
# MISSIONS
# -----------------------------------------------------------------------------

func draw_missions_screen() -> void:
	_v16_header("MISSIONS","Daily and weekly tower contracts",V16_GREEN,0,"arcane")
	_v16_section("DAILY",225,V16_GREEN)
	var daily: Array = missions.all_daily()
	for i: int in range(daily.size()):
		_v16_mission_row(daily[i],i,false)
	_v16_section("WEEKLY",608,V16_PURPLE)
	var weekly: Array = missions.all_weekly()
	for i: int in range(weekly.size()):
		_v16_mission_row(weekly[i],i+3,true)
	_v16_frame(Rect2(70,1050,580,64),V16_GREEN,Color("07151a"),0.16)
	_v16_medallion(Vector2(103,1082),20,V16_GOLD,11)
	_v16_center("TOWER CONTRACTS  •  CLAIM COMPLETED REWARDS",1089,13,V16_GREEN)
	_v16_button(OVERLAY_BACK,"‹  BACK",V16_PURPLE,17)
	_draw_notice(1032)

func _v16_mission_row(mission: Dictionary, index: int, weekly: bool) -> void:
	var r: Rect2 = mission_rect(index)
	var complete: bool = bool(missions.is_complete(mission,weekly))
	var claimed: bool = bool(missions.is_claimed(mission,weekly))
	var accent: Color = V16_PURPLE if weekly else V16_GREEN
	if complete and not claimed:
		accent = V16_GOLD
	elif claimed:
		accent = Color("546075")
	_v16_frame(r,accent,Color("09111c"),0.10)
	_v16_medallion(Vector2(r.position.x+38,r.get_center().y),25,accent,8)
	_v16_text(String(mission["title"]),r.position+Vector2(79,31),18,V16_TEXT,true)
	var progress: int = int(missions.progress(mission,weekly))
	var goal: int = maxi(1,int(mission["goal"]))
	_v16_text("%d / %d" % [progress,goal],r.position+Vector2(79,57),13,accent if not claimed else V16_MUTED)
	_v16_text("%d coins  •  %d XP" % [int(mission["coins"]),int(mission["xp"])],r.position+Vector2(79,83),13,V16_GOLD_HI)
	var status: String = "CLAIMED" if claimed else ("CLAIM" if complete else "IN PROGRESS")
	var status_color: Color = V16_MUTED if claimed else (V16_GREEN if complete else accent)
	draw_string(v16_body_font,Vector2(r.end.x-154,r.position.y+58),status,HORIZONTAL_ALIGNMENT_CENTER,138,13,status_color)
	if complete:
		var c := Vector2(r.end.x-87,r.position.y+29)
		draw_arc(c,14,0,TAU,28,Color(status_color,0.72),2)
		draw_line(c+Vector2(-6,0),c+Vector2(-1,6),status_color,2.4)
		draw_line(c+Vector2(-1,6),c+Vector2(8,-7),status_color,2.4)
	var bar := Rect2(r.position.x+79,r.end.y-15,r.size.x-230,4)
	draw_rect(bar,Color("141928"))
	draw_rect(Rect2(bar.position,Vector2(bar.size.x*clampf(float(progress)/float(goal),0.0,1.0),bar.size.y)),accent)

# -----------------------------------------------------------------------------
# TOWER PASS
# -----------------------------------------------------------------------------

func draw_pass_screen() -> void:
	_v16_header("TOWER PASS","FREE SEASON PATH",V16_PURPLE,6,"arcane")
	var level_no: int = int(tower_pass.level())
	var progress: Dictionary = tower_pass.progress_to_next()
	var top := Rect2(54,218,612,204)
	_v16_frame(top,V16_GOLD,Color("080e1b"),0.18)
	_v16_frame(Rect2(72,238,132,142),V16_PURPLE,Color("100b21"),0.18)
	_v16_center("LEVEL",268,12,V16_MUTED)
	_v16_center(str(level_no),326,54,V16_TEXT,true)
	_v16_text("/ %d" % int(tower_pass.MAX_LEVEL),Vector2(163,354),17,V16_MUTED)
	var next_level: int = mini(int(tower_pass.MAX_LEVEL),maxi(1,level_no+1))
	var reward: Dictionary = tower_pass.reward_for(next_level)
	_v16_text("NEXT REWARD",Vector2(236,267),13,V16_MUTED)
	_v16_text(String(reward.get("label","COINS")),Vector2(236,303),23,V16_GOLD_HI,true)
	_v16_text("%d COINS" % int(reward.get("coins",0)),Vector2(236,337),17,V16_TEXT)
	_v16_medallion(Vector2(588,307),39,V16_GOLD,11)
	var bar := Rect2(86,386,548,18)
	draw_rect(bar,Color("1a1730"))
	draw_rect(Rect2(bar.position,Vector2(bar.size.x*float(progress["ratio"]),bar.size.y)),V16_PURPLE)
	draw_line(bar.position+Vector2(2,2),Vector2(bar.position.x+bar.size.x*float(progress["ratio"])-2,bar.position.y+2),Color(V16_PURPLE_HI,0.64),2)
	_v16_center("%d / %d XP" % [int(progress["current"]),int(progress["needed"])],418,13,V16_TEXT)
	_v16_section("REWARD TRACK",478,V16_GOLD)
	var start_level: int = maxi(1,level_no-2)
	for i: int in range(5):
		var l: int = start_level+i
		if l > int(tower_pass.MAX_LEVEL):
			break
		var rr: Dictionary = tower_pass.reward_for(l)
		var row := Rect2(74,505+i*94,572,76)
		var unlocked: bool = l <= level_no
		var claimable: bool = bool(tower_pass.can_claim(l))
		var accent: Color = V16_GOLD if claimable else (V16_PURPLE if unlocked else Color("4e566b"))
		_v16_frame(row,accent,Color("08101d"),0.12)
		_v16_medallion(Vector2(row.position.x+36,row.get_center().y),23,accent,11)
		_v16_text("LV %02d" % l,row.position+Vector2(74,30),16,V16_TEXT,true)
		_v16_text(String(rr["label"]),row.position+Vector2(158,27),13,V16_MUTED)
		_v16_text("+%d" % int(rr["coins"]),row.position+Vector2(158,52),16,V16_GOLD_HI)
		var status: String = "CLAIM" if claimable else ("UNLOCKED" if unlocked else "LOCKED")
		draw_string(v16_body_font,Vector2(row.end.x-135,row.position.y+42),status,HORIZONTAL_ALIGNMENT_CENTER,120,13,V16_GOLD if claimable else V16_MUTED)
	var next_claim: int = int(tower_pass.next_claimable())
	_v16_button(PASS_CLAIM,"CLAIM LEVEL %d" % next_claim if next_claim > 0 else "NO REWARD READY",V16_GOLD if next_claim > 0 else Color("656879"),18,11,next_claim > 0)
	_v16_button(OVERLAY_BACK,"‹  BACK",V16_BLUE,17)
	_draw_notice(1015)

# -----------------------------------------------------------------------------
# VAULT + FORGE
# -----------------------------------------------------------------------------

func draw_vault_screen() -> void:
	_v16_header("VAULT + FORGE","Compare, lock, equip, dismantle and craft gear",V16_GOLD,10,"arcane")
	var bonuses: Dictionary = loot.equipped_bonuses()
	var info := Rect2(48,202,624,64)
	_v16_frame(info,V16_GOLD,Color("09101b"),0.12)
	_v16_medallion(Vector2(78,234),21,V16_PURPLE,10)
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

func _v16_vault_item(item: Dictionary, local_index: int, selected_now: bool) -> void:
	var r: Rect2 = vault_v08_item_rect(local_index)
	var rarity: String = String(item["rarity"])
	var rarity_accent: Color = rarity_color(rarity)
	var accent: Color = C_CYAN if selected_now else rarity_accent
	_v16_frame(r,accent,Color("08111f"),0.13)
	var slot: String = String(item["slot"])
	var icon_index: int = 6 if slot == "weapon" else (8 if slot == "armor" else 10)
	_v16_medallion(Vector2(r.position.x+38,r.get_center().y),27,accent,icon_index)
	_v16_text(String(item["name"]),r.position+Vector2(76,27),16,V16_TEXT,true)
	_v16_text("%s • %s • Lv.%d • SCORE %d" % [rarity,slot.to_upper(),int(item["level"]),int(loot.item_score(item))],r.position+Vector2(76,49),10,rarity_accent)
	_v16_text(loot.stat_line(item),r.position+Vector2(76,72),12,V16_MUTED)
	var tags: String = loot.trait_line(item)
	if loot.is_locked(item):
		tags = (tags+" • " if tags != "" else "")+"LOCKED"
	if tags != "":
		_v16_text(tags,r.position+Vector2(275,72),10,C_CYAN if loot.is_locked(item) else V16_PURPLE_HI)
	var status: String = "EQUIPPED" if loot.is_equipped(item) else ("SELECTED" if selected_now else "TAP")
	var status_color: Color = V16_GREEN if loot.is_equipped(item) else V16_GOLD
	draw_string(v16_body_font,Vector2(r.end.x-105,r.position.y+49),status,HORIZONTAL_ALIGNMENT_CENTER,90,11,status_color)

func _v16_vault_comparison(selected: Dictionary) -> void:
	var r := Rect2(54,748,612,116)
	_v16_frame(r,V16_BLUE if not selected.is_empty() else Color("485066"),Color("070d19"),0.10)
	if selected.is_empty():
		_v16_medallion(Vector2(r.get_center().x,r.position.y+36),18,V16_PURPLE,10)
		draw_string(v16_body_font,Vector2(r.position.x+12,r.position.y+77),"SELECT AN ITEM TO COMPARE",HORIZONTAL_ALIGNMENT_CENTER,r.size.x-24,14,V16_MUTED)
		return
	var equipped_item: Dictionary = loot.equipped_item_for_slot(String(selected["slot"]))
	var delta: int = int(loot.comparison_delta(selected))
	_v16_text("SELECTED",r.position+Vector2(18,27),11,C_CYAN)
	_v16_text("%s  •  %s  •  %d" % [String(selected["name"]),loot.stat_line(selected),int(loot.item_score(selected))],r.position+Vector2(18,51),12,V16_TEXT)
	_v16_text("EQUIPPED",r.position+Vector2(18,78),11,V16_GREEN)
	_v16_text("EMPTY SLOT" if equipped_item.is_empty() else "%s  •  %s  •  %d" % [String(equipped_item["name"]),loot.stat_line(equipped_item),int(loot.item_score(equipped_item))],r.position+Vector2(108,78),12,V16_MUTED if equipped_item.is_empty() else V16_TEXT)
	var delta_text: String = "+%d" % delta if delta >= 0 else "%d" % delta
	draw_string(v16_title_font,Vector2(r.end.x-90,r.position.y+59),delta_text,HORIZONTAL_ALIGNMENT_CENTER,72,18,V16_GREEN if delta >= 0 else V16_RED)
