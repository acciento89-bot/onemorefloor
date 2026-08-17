extends "res://scripts/main_v44.gd"

# ONE MORE FLOOR v1.32 — Dedicated endgame actor art.
# The endgame roster no longer relies on legacy visual aliases. Four authored
# realm atlases provide twelve distinct enemies plus the four cinematic bosses.

const V45_VERSION := "1.32.0-actor-art"
const V45_BUILD := "22-dev"
const V45_ATLAS_PATHS := {
	"void": "res://assets/art/actors_void_v45.svg",
	"eclipse": "res://assets/art/actors_eclipse_v45.svg",
	"bloodstar": "res://assets/art/actors_bloodstar_v45.svg",
	"celestial": "res://assets/art/actors_celestial_v45.svg",
}
const V45_ACTOR_SLOTS := {
	"void_lancer": ["void", 0],
	"rift_hound": ["void", 1],
	"soul_cannon": ["void", 2],
	"void_archon": ["void", 3],
	"eclipse_oracle": ["eclipse", 0],
	"shade_duelist": ["eclipse", 1],
	"sunless_guard": ["eclipse", 2],
	"eclipse_regent": ["eclipse", 3],
	"blood_seraph": ["bloodstar", 0],
	"chain_titan": ["bloodstar", 1],
	"hemomancer": ["bloodstar", 2],
	"bloodstar_tyrant": ["bloodstar", 3],
	"star_devourer": ["celestial", 0],
	"crownless": ["celestial", 1],
	"cosmic_eye": ["celestial", 2],
	"world_eater": ["celestial", 3],
}

var v45_actor_atlases: Dictionary = {}

func _ready() -> void:
	super._ready()
	for key in V45_ATLAS_PATHS.keys():
		var tex := load(String(V45_ATLAS_PATHS[key])) as Texture2D
		if tex != null:
			v45_actor_atlases[key] = tex
	if telemetry != null:
		telemetry.set_build_context(V45_VERSION, V45_BUILD)
	queue_redraw()

func draw_enemy(e: Dictionary) -> void:
	var kind := String(e.get("type", ""))
	if kind == "warden":
		var variant := String(e.get("boss_variant", ""))
		if variant in V44_BOSS_VARIANTS and _v45_has_actor(variant):
			_v45_draw_actor(e, variant, true)
			_v44_draw_boss_presence(e, variant)
			return
	if _v45_has_actor(kind):
		_v45_draw_actor(e, kind, false)
		return
	super.draw_enemy(e)

func _v45_has_actor(actor_id: String) -> bool:
	return V45_ACTOR_SLOTS.has(actor_id)

func _v45_actor_slot(actor_id: String) -> Array:
	return V45_ACTOR_SLOTS.get(actor_id, []) as Array

func _v45_actor_texture(actor_id: String) -> Texture2D:
	var slot := _v45_actor_slot(actor_id)
	if slot.size() < 2:
		return null
	return v45_actor_atlases.get(String(slot[0])) as Texture2D

func _v45_draw_actor(e: Dictionary, actor_id: String, boss: bool) -> void:
	var tex := _v45_actor_texture(actor_id)
	var slot := _v45_actor_slot(actor_id)
	if tex == null or slot.size() < 2:
		super.draw_enemy(e)
		return
	var p: Vector2 = e.get("pos", Vector2.ZERO)
	var radius := float(e.get("radius", 24.0))
	var phase := float(e.get("phase", 0.0))
	var stage := int(e.get("v44_stage", 1)) if boss else 1
	var size := radius * (3.55 + float(stage - 1) * 0.13) if boss else radius * _v45_actor_scale(actor_id)
	var bob := sin(elapsed * _v45_bob_speed(actor_id) + phase) * (3.0 if boss else 1.8)
	var sway := sin(elapsed * 1.7 + phase * 0.7) * (0.018 if boss else 0.028)
	var accent := _v45_actor_accent(actor_id)
	var glow_r := radius * (1.82 if boss else 1.36)
	draw_circle(p + Vector2(0, bob), glow_r, Color(accent, 0.055 if boss else 0.035))
	if bool(e.get("elite", false)):
		draw_arc(p + Vector2(0,bob), glow_r + 7.0, elapsed*0.45, elapsed*0.45+PI*1.55, 40, Color(C_GOLD,0.74), 3.0)
	var col := int(slot[1])
	var src := Rect2(float(col) * 192.0, 0.0, 192.0, 192.0)
	draw_set_transform(p + Vector2(0,bob), sway, Vector2.ONE)
	draw_texture_rect_region(tex, Rect2(Vector2(-size*0.5,-size*0.5),Vector2(size,size)), src, Color.WHITE)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_v45_draw_actor_fx(e, actor_id, p + Vector2(0,bob), radius, accent, boss)
	if not boss:
		_v45_draw_actor_health(e, p, radius, accent)

func _v45_actor_scale(actor_id: String) -> float:
	match actor_id:
		"rift_hound": return 4.25
		"soul_cannon": return 4.15
		"chain_titan": return 4.35
		"star_devourer": return 4.15
		_: return 3.95

func _v45_bob_speed(actor_id: String) -> float:
	match actor_id:
		"star_devourer", "cosmic_eye", "eclipse_oracle": return 2.2
		"rift_hound": return 4.0
		_: return 3.0

func _v45_actor_accent(actor_id: String) -> Color:
	if actor_id in ["void_lancer","rift_hound","soul_cannon","void_archon"]:
		return Color("8064ff")
	if actor_id in ["eclipse_oracle","shade_duelist","sunless_guard","eclipse_regent"]:
		return Color("d45cff")
	if actor_id in ["blood_seraph","chain_titan","hemomancer","bloodstar_tyrant"]:
		return Color("ff455f")
	return Color("65e8ff")

func _v45_draw_actor_health(e: Dictionary, p: Vector2, radius: float, accent: Color) -> void:
	var hp := float(e.get("hp", 1.0))
	var max_hp := maxf(1.0, float(e.get("max_hp", hp)))
	if hp >= max_hp and not bool(e.get("elite", false)) and not bool(e.get("bounty_target", false)):
		return
	var w := clampf(radius * 2.35, 54.0, 96.0)
	var r := Rect2(p.x-w*0.5, p.y-radius*1.92, w, 6.0)
	draw_rect(r, Color(0.02,0.02,0.035,0.88))
	draw_rect(Rect2(r.position,Vector2(r.size.x*clampf(hp/max_hp,0.0,1.0),r.size.y)), C_GOLD if bool(e.get("elite",false)) else accent)
	draw_rect(r, Color(1,1,1,0.14), false, 1.0)
	if bool(e.get("bounty_target", false)):
		var q := Vector2(p.x, r.position.y - 9.0)
		draw_colored_polygon(PackedVector2Array([q+Vector2(0,-6),q+Vector2(6,0),q+Vector2(0,6),q+Vector2(-6,0)]), C_GOLD)

func _v45_draw_actor_fx(e: Dictionary, actor_id: String, p: Vector2, radius: float, accent: Color, boss: bool) -> void:
	var pulse := 0.5 + 0.5*sin(elapsed*3.2 + float(e.get("phase",0.0)))
	match actor_id:
		"void_lancer":
			draw_line(p+Vector2(18,-28), p+Vector2(48,-62), Color(C_CYAN,0.35+0.25*pulse), 2.0)
		"rift_hound":
			for side in [-1.0,1.0]: draw_line(p+Vector2(side*15,20),p+Vector2(side*38,34),Color(accent,0.25+0.20*pulse),2.0)
		"soul_cannon":
			draw_circle(p+Vector2(radius*1.45,-2),4.0+3.0*pulse,Color(C_CYAN,0.34+0.35*pulse))
		"eclipse_oracle":
			draw_arc(p,radius*1.45,elapsed*0.35,elapsed*0.35+PI*1.4,32,Color(C_GOLD,0.28+0.24*pulse),2.0)
		"shade_duelist":
			draw_line(p+Vector2(-34,30),p+Vector2(30,-34),Color(C_GOLD,0.25+0.20*pulse),2.0)
		"sunless_guard":
			draw_arc(p,radius*1.35,-2.6,-0.5,28,Color(C_GOLD,0.28+0.25*pulse),3.0)
		"blood_seraph":
			draw_arc(p,radius*1.55,-2.75,-1.15,24,Color(accent,0.22+0.20*pulse),3.0)
			draw_arc(p,radius*1.55,-1.99,-0.40,24,Color(accent,0.22+0.20*pulse),3.0)
		"chain_titan":
			for side in [-1.0,1.0]: draw_arc(p+Vector2(side*radius,20),11.0+2.0*pulse,0,TAU,18,Color(C_GOLD,0.28),2.0)
		"hemomancer":
			draw_circle(p+Vector2(0,-radius*1.25),5.0+4.0*pulse,Color(C_RED,0.32+0.35*pulse))
		"star_devourer":
			draw_arc(p,radius*1.42,elapsed*0.45,elapsed*0.45+PI*1.5,36,Color(C_CYAN,0.24+0.18*pulse),2.0)
		"crownless":
			draw_arc(p+Vector2(0,-radius*0.75),radius*0.65,PI,TAU,24,Color(C_PURPLE,0.28+0.20*pulse),2.0)
		"cosmic_eye":
			draw_arc(p,radius*1.45,elapsed*0.25,elapsed*0.25+TAU,36,Color(C_CYAN,0.20+0.20*pulse),2.0)
	if boss:
		var stage := int(e.get("v44_stage",1))
		for i in range(stage):
			var rr := radius*(1.55+float(i)*0.18)
			draw_arc(p,rr,elapsed*(0.18+float(i)*0.05),elapsed*(0.18+float(i)*0.05)+PI*1.55,46,Color(accent,0.20+0.05*stage),2.0)

# Replace the crest-only intro with the actual boss body art while keeping the
# title/subtitle treatment from v1.31.
func _v44_draw_boss_intro(variant: String) -> void:
	var alpha := clampf(v44_boss_intro / 0.55, 0.0, 1.0)
	var accent := _v28_boss_accent(variant)
	draw_rect(ARENA, Color(0.0,0.0,0.0,0.60*alpha))
	var center := ARENA.get_center()
	var crest := v44_boss_crests.get(variant) as Texture2D
	if crest != null:
		draw_texture_rect(crest,Rect2(center-Vector2(122,122),Vector2(244,244)),false,Color(1,1,1,0.13*alpha))
	_v45_draw_intro_actor(variant, center+Vector2(0,-22), 246.0, alpha)
	draw_string(v16_title_font,Vector2(80,650),_v44_boss_title(variant),HORIZONTAL_ALIGNMENT_CENTER,560,36,Color(V17_IVORY,alpha))
	draw_string(v16_body_font,Vector2(90,680),_v44_boss_subtitle(variant),HORIZONTAL_ALIGNMENT_CENTER,540,12,Color(accent,0.92*alpha))
	draw_line(Vector2(150,704),Vector2(570,704),Color(accent,0.58*alpha),2.0)

func _v45_draw_intro_actor(actor_id: String, center: Vector2, size: float, alpha: float) -> void:
	var tex := _v45_actor_texture(actor_id)
	var slot := _v45_actor_slot(actor_id)
	if tex == null or slot.size() < 2:
		return
	var src := Rect2(float(int(slot[1]))*192.0,0,192,192)
	draw_texture_rect_region(tex,Rect2(center-Vector2(size,size)*0.5,Vector2(size,size)),src,Color(1,1,1,alpha))

func _v45_actor_art_ready() -> bool:
	if v45_actor_atlases.size() != 4 or V45_ACTOR_SLOTS.size() != 16:
		return false
	for key in V45_ATLAS_PATHS.keys():
		if not (v45_actor_atlases.get(key) is Texture2D):
			return false
	return _v45_actor_slot("void_lancer").size() == 2 and _v45_actor_slot("world_eater").size() == 2
