extends "res://scripts/main_v17.gd"

const V18_VERSION := "1.6.1-concept-final"
const V18_HOME_ART := "res://assets/art/concept_home_v16.svg"
const V18_ARCANE_ART := "res://assets/art/concept_arcane_v16.svg"
const V18_FORGE_ART := "res://assets/art/concept_forge_v16.svg"

var tex_v18_home: Texture2D
var tex_v18_arcane: Texture2D
var tex_v18_forge: Texture2D

func _ready() -> void:
	super._ready()
	tex_v18_home = load(V18_HOME_ART) as Texture2D
	tex_v18_arcane = load(V18_ARCANE_ART) as Texture2D
	tex_v18_forge = load(V18_FORGE_ART) as Texture2D
	queue_redraw()

# The supplied concept images are the only environment source of truth.
# Keep the v1.6 metallic button/panel system, but replace the older flat backdrops.
func _v16_backdrop(kind: String = "arcane", dim: float = 0.0) -> void:
	var texture: Texture2D = tex_v18_arcane
	if kind == "home":
		texture = tex_v18_home
	elif kind == "forge":
		texture = tex_v18_forge
	if texture != null:
		draw_texture_rect(texture, Rect2(Vector2.ZERO, SIZE), false, Color.WHITE)
	else:
		super._v16_backdrop(kind, dim)
	# Concept references use a dark edge vignette while the center stays readable.
	for i: int in range(7):
		var alpha: float = 0.010 + float(i) * 0.005
		var inset_x: float = float(i) * 5.0
		var inset_y: float = float(i) * 2.0
		draw_rect(Rect2(inset_x, inset_y, 720.0 - inset_x * 2.0, 1280.0 - inset_y * 2.0), Color(0,0,0,alpha), false, 2.0)
	if dim > 0.0:
		draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0,0,0,dim))

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

# Tower Pass follows the supplied reference: one large hero reward panel and two track rows.
func draw_pass_screen() -> void:
	_v16_header("TOWER PASS", "FREE SEASON PATH", V16_PURPLE, 6, "arcane")
	var level_no: int = int(tower_pass.level())
	var max_level: int = int(tower_pass.MAX_LEVEL)
	var progress: Dictionary = tower_pass.progress_to_next()
	var top := Rect2(46,218,628,270)
	_v16_frame(top, V16_GOLD, Color("060a13"), 0.24)
	var plaque := Rect2(72,246,150,152)
	_v16_frame(plaque, V16_PURPLE, Color("10091e"), 0.22)
	_v16_center("LEVEL",278,13,V16_MUTED)
	_v16_center(str(level_no),342,58,V17_IVORY,true)
	_v16_text("/ %d" % max_level, Vector2(170,372), 18, V16_MUTED)
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
	draw_rect(Rect2(bar.position,Vector2(bar.size.x*float(progress["ratio"]),bar.size.y)),Color("8d3ed8"))
	draw_line(bar.position+Vector2(4,3),Vector2(bar.position.x+bar.size.x*float(progress["ratio"])-4,bar.position.y+3),Color("df9cff"),2.0)
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
		# Diamond level badge at the left, matching the concept track spine.
		var badge_center := Vector2(78,row.get_center().y)
		draw_colored_polygon(PackedVector2Array([badge_center+Vector2(0,-42),badge_center+Vector2(42,0),badge_center+Vector2(0,42),badge_center+Vector2(-42,0)]),Color("090716"))
		draw_polyline(PackedVector2Array([badge_center+Vector2(0,-42),badge_center+Vector2(42,0),badge_center+Vector2(0,42),badge_center+Vector2(-42,0),badge_center+Vector2(0,-42)]),V16_PURPLE_HI,3.0)
		draw_string(v16_title_font,Vector2(43,row.get_center().y+7),"LV %d" % l,HORIZONTAL_ALIGNMENT_CENTER,70,18,V17_IVORY)
		if String(rr.get("label","")) == "BIG COIN CACHE":
			_v18_reward_chest(Vector2(row.position.x+83,row.get_center().y-2),0.35)
		else:
			_v16_medallion(Vector2(row.position.x+77,row.get_center().y),34,V16_GOLD,11)
		_v16_text(String(rr.get("label","COINS")),row.position+Vector2(150,47),20,V17_GOLD_HI,true)
		_v16_text("+%d" % int(rr.get("coins",0)),row.position+Vector2(150,82),18,V17_IVORY)
		var status: String = "CLAIM" if claimable else ("UNLOCKED" if unlocked else "LOCKED")
		var status_color: Color = V16_GREEN if unlocked and not claimable else (V17_GOLD_HI if claimable else V16_MUTED)
		draw_string(v16_title_font,Vector2(row.end.x-150,row.get_center().y+7),status,HORIZONTAL_ALIGNMENT_CENTER,130,18,status_color)

	var next_claim: int = int(tower_pass.next_claimable())
	_v16_button(PASS_CLAIM,"CLAIM LEVEL %d" % next_claim if next_claim > 0 else "NO REWARD READY",V16_GOLD if next_claim > 0 else Color("5a5c66"),22,-1,next_claim > 0)
	_v16_button(OVERLAY_BACK,"‹  BACK",V16_BLUE,17)
	_draw_notice(1015)
