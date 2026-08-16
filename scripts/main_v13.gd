extends "res://scripts/main_v12.gd"

const V13_VERSION := "1.2.0-rc2"
const V13_ACTOR_PATHS := [
	"res://assets/art/wanderer.svg",
	"res://assets/art/goblin.svg",
	"res://assets/art/bat.svg",
	"res://assets/art/skeleton.svg",
	"res://assets/art/ghoul.svg",
	"res://assets/art/necromancer.svg",
	"res://assets/art/warden.svg",
	"res://assets/art/crypt_keeper.svg",
	"res://assets/art/gargoyle.svg",
	"res://assets/art/sentinel.svg",
	"res://assets/art/hexer.svg",
	"res://assets/art/hollow_king.svg"
]

var v13_actor_textures: Array[Texture2D] = []
var v13_swallow_release_id: int = -99999

func _ready() -> void:
	super._ready()
	v13_actor_textures.clear()
	for path: String in V13_ACTOR_PATHS:
		var tex := load(path) as Texture2D
		v13_actor_textures.append(tex)
	queue_redraw()

# Settings is drawn on top of Home, so a touch release must never fall through
# into the PLAY hitbox after BACK closes the modal.
func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if not pressed and id == v13_swallow_release_id:
		v13_swallow_release_id = -99999
		joy_active = false
		joy_vector = Vector2.ZERO
		return
	if pressed and settings_open:
		v13_swallow_release_id = id
		super.pointer(pos, pressed, id)
		return
	super.pointer(pos, pressed, id)

func _v13_actor_texture(index: int) -> Texture2D:
	if index >= 0 and index < v13_actor_textures.size():
		return v13_actor_textures[index]
	return null

func _v12_actor(index: int, r: Rect2, modulate: Color = Color.WHITE) -> void:
	var tex := _v13_actor_texture(index)
	if tex != null:
		draw_texture_rect(tex, r, false, modulate)
		return
	super._v12_actor(index, r, modulate)

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	var tex := _v13_actor_texture(0)
	if tex == null:
		super.draw_wanderer(pos, scale, combat)
		return
	var bob: float = sin(elapsed * (6.4 if combat else 2.2)) * (2.4 if combat else 1.3) * scale
	var attack_push: float = 5.0 * scale if combat and player_anim_state == "attack" else 0.0
	var hit_offset: float = sin(elapsed * 34.0) * 3.0 * scale if player_anim_state == "hit" else 0.0
	var w: float = (84.0 if combat else 118.0) * scale
	var h: float = w * 1.5
	var p := pos + Vector2(attack_push * float(player_facing), bob + hit_offset)
	draw_ellipse_shadow(pos + Vector2(0, 29 * scale), w * 0.42, 12 * scale)
	if combat:
		draw_circle(pos + Vector2(0, 5), 46 * scale, Color(0.30, 0.14, 0.50, 0.055))
	if player_anim_state == "nova":
		draw_circle(pos, 60 * scale, Color(C_CYAN, 0.09))
		draw_arc(pos, 59 * scale, elapsed * 2.8, elapsed * 2.8 + TAU, 48, C_CYAN, 3.2 * scale)
		draw_arc(pos, 49 * scale, -elapsed * 3.3, -elapsed * 3.3 + TAU, 42, Color(V12_PURPLE,0.75), 2.2 * scale)
	elif combat and player_anim_state == "attack":
		draw_arc(pos + Vector2(10 * float(player_facing), -3), 48 * scale, -1.05, 0.78, 28, Color(V12_GOLD_LIGHT, 0.72), 5 * scale)
		draw_arc(pos + Vector2(10 * float(player_facing), -3), 58 * scale, -1.0, 0.7, 28, Color(V12_PURPLE, 0.25), 8 * scale)
	var r := Rect2(p.x - w * 0.5, p.y - h * 0.66, w, h)
	draw_texture_rect(tex, r, false, Color.WHITE)
	# rim light to separate the hero from dark floors
	draw_arc(pos + Vector2(0, -5), w * 0.42, -2.6, -0.55, 24, Color(0.55, 0.78, 1.0, 0.18), 2.0 * scale)

func draw_enemy(e: Dictionary) -> void:
	var kind: String = String(e["type"])
	var variant: String = String(e.get("boss_variant", "warden"))
	var idx: int = _v12_actor_index(kind, variant)
	var tex := _v13_actor_texture(idx)
	if tex == null:
		super.draw_enemy(e)
		return
	var p: Vector2 = e["pos"]
	var radius: float = float(e["radius"])
	var bob: float = sin(elapsed * (8.5 if kind == "bat" else 4.4) + float(e.get("phase", 0.0))) * (5.0 if kind == "bat" else 1.8)
	var hit: bool = float(e.get("anim_hit", 0.0)) > 0.0
	var jitter: float = sin(elapsed * 42.0) * 3.0 if hit else 0.0
	var width: float = maxf(64.0, radius * 2.55)
	if kind == "warden":
		width = radius * 2.72
	var height: float = width * 1.5
	var tint := Color(1.0, 0.68, 0.68, 1.0) if hit else Color.WHITE
	if bool(e.get("elite", false)):
		tint = tint.lerp(V12_GOLD_LIGHT, 0.12)
	draw_ellipse_shadow(p + Vector2(0, radius * 0.82), width * 0.36, 9.0)
	if kind == "warden":
		draw_circle(p + Vector2(0,-5), radius + 26.0, Color(V12_PURPLE,0.035))
	var r := Rect2(p.x - width * 0.5 + jitter, p.y - height * 0.65 + bob, width, height)
	draw_texture_rect(tex, r, false, tint)
	if bool(e.get("elite", false)):
		draw_arc(p, radius + 13.0, elapsed * 0.95, elapsed * 0.95 + TAU, 42, V12_GOLD, 3.0)
		draw_arc(p, radius + 18.0, -elapsed * 0.65, -elapsed * 0.65 + PI * 1.4, 32, Color(V12_GOLD_LIGHT,0.24), 2.0)
	if kind == "sentinel":
		draw_arc(p, radius + 9.0, -0.95, 0.95, 22, Color(V12_GOLD_LIGHT,0.52), 4.0)
	if kind == "warden" and bool(e.get("phase2", false)):
		var phase_color: Color = V12_GOLD if variant == "hollow_king" else (C_CYAN if variant == "crypt_keeper" else C_RED)
		draw_arc(p, radius + 16.0, elapsed * 1.3, elapsed * 1.3 + TAU, 48, phase_color, 4.0)
		draw_arc(p, radius + 23.0, -elapsed * 0.9, -elapsed * 0.9 + TAU, 48, Color(phase_color,0.22), 3.0)
	var ratio: float = clampf(float(e["hp"]) / float(e["max_hp"]), 0.0, 1.0)
	var hp := Rect2(p.x - radius, p.y - radius - 20, radius * 2.0, 8)
	draw_rect(hp, Color("271119"))
	draw_rect(Rect2(hp.position, Vector2(hp.size.x * ratio, hp.size.y)), Color("e34d5e"))
	draw_line(hp.position + Vector2(0,1), Vector2(hp.position.x + hp.size.x * ratio, hp.position.y + 1), Color(1,0.72,0.76,0.45), 1.0)

func draw_effect(fx: Dictionary) -> void:
	if String(fx.get("type", "")) != "actor_death":
		super.draw_effect(fx)
		return
	var idx: int = _v12_actor_index(String(fx.get("kind", "")), String(fx.get("variant", "warden")))
	var tex := _v13_actor_texture(idx)
	if tex == null:
		super.draw_effect(fx)
		return
	var t: float = clampf(float(fx["age"]) / float(fx["dur"]), 0.0, 1.0)
	var s: float = float(fx.get("size", 72.0)) * (1.0 - t * 0.18)
	var p: Vector2 = Vector2(fx["pos"]) + Vector2(0, t * 18.0)
	draw_circle(p, 20.0 + t * 34.0, Color(V12_PURPLE, 0.10 * (1.0 - t)))
	draw_texture_rect(tex, Rect2(p.x - s * 0.5, p.y - s * 1.0, s, s * 1.5), false, Color(1,1,1,1.0-t))

# Extra atmosphere on top of the painted room, below actor rendering through the
# normal inherited draw order.
func _draw_room_architecture() -> void:
	super._draw_room_architecture()
	var area: String = String(current_room.get("area", "DUNGEON"))
	var accent: Color = _area_accent(area)
	# Light shafts from the upper arch.
	var shaft_alpha: float = 0.035 if area != "CRYPT" else 0.028
	draw_colored_polygon(PackedVector2Array([
		Vector2(258, 236), Vector2(315, 236), Vector2(248, 850), Vector2(160, 850)
	]), Color(accent, shaft_alpha))
	draw_colored_polygon(PackedVector2Array([
		Vector2(333, 236), Vector2(390, 236), Vector2(488, 850), Vector2(400, 850)
	]), Color(accent, shaft_alpha * 0.8))
	# Low drifting haze makes the floor feel less like a flat rectangle.
	for i in range(4):
		var y: float = 520.0 + float(i) * 105.0 + sin(elapsed * 0.35 + float(i)) * 10.0
		draw_rect(Rect2(72, y, 576, 42), Color(accent, 0.012 + float(i) * 0.003))
