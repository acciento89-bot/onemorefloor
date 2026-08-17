extends "res://scripts/main_v37.gd"

# v1.26 — graphics packs 2.0.
# The generated reference screens are used only as art-direction targets. This
# layer keeps every menu/button/value interactive and upgrades the live renderer
# itself: richer materials, pack-specific ornaments, atmospheric motifs and
# combat edge identity. No screenshot UI is baked into the game.

const V38_VERSION := "1.26.0-graphics-packs-2"
const V38_BUILD := "19"

var v38_pack_flash_until := 0.0

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V38_VERSION, V38_BUILD)
		telemetry.event("graphics_pack_2_ready", {
			"pack": _v38_pack_id(),
			"best_floor": int(meta.best_floor)
		})
	queue_redraw()

func _v38_pack_id() -> String:
	if visual_pack == null:
		return "citadel"
	return String(visual_pack.selected)

func _v38_primary() -> Color:
	return Color("9b5cff") if visual_pack == null else Color(visual_pack.primary())

func _v38_secondary() -> Color:
	return Color("e7b84d") if visual_pack == null else Color(visual_pack.secondary())

# -----------------------------------------------------------------------------
# Backdrops — each graphics pack now has its own ambient geometry rather than a
# simple tint. Alpha stays low so gameplay/menu readability wins over decoration.
# -----------------------------------------------------------------------------

func _v16_backdrop(kind: String = "arcane", dim: float = 0.0) -> void:
	super._v16_backdrop(kind, dim)
	if visual_pack == null:
		return
	var p := _v38_primary()
	var s := _v38_secondary()
	var center := Vector2(360, 448 if kind != "home" else 430)
	var radius := 248.0 if kind != "forge" else 218.0
	_v38_draw_pack_halo(center, radius, p, s)

func _v38_draw_pack_halo(center: Vector2, radius: float, primary: Color, secondary: Color) -> void:
	var pack := _v38_pack_id()
	draw_arc(center, radius, 0.0, TAU, 96, Color(primary,0.12), 1.3)
	draw_arc(center, radius-28.0, elapsed*0.018, elapsed*0.018+TAU, 84, Color(secondary,0.065), 1.0)
	match pack:
		"void":
			for i in range(8):
				var a := TAU * float(i) / 8.0 + elapsed * 0.012
				var a0 := center + Vector2(cos(a),sin(a)) * (radius-42.0)
				var a1 := center + Vector2(cos(a+0.10),sin(a+0.10)) * (radius+4.0)
				draw_line(a0,a1,Color(primary,0.13),2.0)
				draw_circle(a1,2.2,Color(secondary,0.25))
		"eclipse":
			draw_circle(center, 90.0, Color(0.01,0.01,0.025,0.10))
			draw_arc(center, 102.0, -1.10, 1.10, 42, Color(secondary,0.16), 3.0)
			for i in range(12):
				var a := TAU * float(i) / 12.0
				var a0 := center + Vector2(cos(a),sin(a)) * (radius-34.0)
				var a1 := center + Vector2(cos(a),sin(a)) * radius
				draw_line(a0,a1,Color(primary,0.09),1.0)
		"bloodstar":
			for i in range(6):
				var a := TAU * float(i) / 6.0 - PI*0.5
				var tip := center + Vector2(cos(a),sin(a)) * (radius+6.0)
				var left := center + Vector2(cos(a-0.08),sin(a-0.08)) * (radius-38.0)
				var right := center + Vector2(cos(a+0.08),sin(a+0.08)) * (radius-38.0)
				draw_colored_polygon(PackedVector2Array([tip,left,right]),Color(primary,0.055))
			for i in range(9):
				var x := 90.0 + float(i)*67.0
				var y := 250.0 + fmod(float(i*73),420.0)
				draw_line(Vector2(x,y),Vector2(x-7,y+34),Color(primary,0.07),1.0)
		"celestial":
			var stars: Array[Vector2] = [
				center+Vector2(-172,-92), center+Vector2(-95,-178), center+Vector2(22,-198),
				center+Vector2(148,-122), center+Vector2(188,24), center+Vector2(104,166),
				center+Vector2(-48,191), center+Vector2(-184,92)
			]
			for i in range(stars.size()):
				var a: Vector2 = stars[i]
				var b: Vector2 = stars[(i+1)%stars.size()]
				draw_line(a,b,Color(primary,0.075),1.0)
				draw_circle(a,2.4,Color(secondary,0.26))
		_:
			for i in range(8):
				var a := TAU * float(i)/8.0 + PI*0.125
				var c := center + Vector2(cos(a),sin(a)) * radius
				_v38_diamond(c,5.0,Color(primary,0.18))

# -----------------------------------------------------------------------------
# Frames / buttons / medallions — reference-inspired depth without replacing
# live UI. All existing semantic colors remain intact; pack colors only decorate.
# -----------------------------------------------------------------------------

func _v16_frame(r: Rect2, accent: Color, fill: Color = V16_NAVY, glow: float = 0.15) -> void:
	super._v16_frame(r, accent, fill, glow)
	if visual_pack == null or r.size.x < 54.0 or r.size.y < 34.0:
		return
	var p := _v38_primary()
	var s := _v38_secondary()
	var inner := r.grow(-10.0)
	# Material bevel: cool highlight up top, deep shadow at the bottom.
	draw_line(inner.position+Vector2(10,1), Vector2(inner.end.x-10,inner.position.y+1), Color(s,0.13), 1.0)
	draw_line(Vector2(inner.position.x+10,inner.end.y-1), inner.end-Vector2(10,1), Color(0,0,0,0.62), 1.5)
	if r.size.x >= 110.0:
		_v38_diamond(Vector2(r.get_center().x,r.position.y+2),5.2,Color(p,0.82))
		_v38_diamond(Vector2(r.get_center().x,r.end.y-2),3.2,Color(s,0.36))
	_v38_frame_motif(r,p,s)

func _v38_frame_motif(r: Rect2, primary: Color, secondary: Color) -> void:
	var pack := _v38_pack_id()
	var inset := 13.0
	match pack:
		"void":
			var cut := 12.0
			draw_line(r.position+Vector2(inset,cut), r.position+Vector2(cut,inset), Color(secondary,0.34), 1.4)
			draw_line(Vector2(r.end.x-inset,r.position.y+cut), Vector2(r.end.x-cut,r.position.y+inset), Color(primary,0.42), 1.4)
			draw_line(Vector2(r.position.x+inset,r.end.y-cut), Vector2(r.position.x+cut,r.end.y-inset), Color(primary,0.30), 1.4)
			draw_line(r.end-Vector2(inset,cut), r.end-Vector2(cut,inset), Color(secondary,0.30), 1.4)
		"eclipse":
			for xoff in [24.0,38.0]:
				draw_line(r.position+Vector2(xoff,6),r.position+Vector2(xoff+10,6),Color(primary,0.28),1.0)
				draw_line(Vector2(r.end.x-xoff,r.end.y-6),Vector2(r.end.x-xoff-10,r.end.y-6),Color(secondary,0.20),1.0)
		"bloodstar":
			var mid_l := Vector2(r.position.x+8,r.get_center().y)
			var mid_r := Vector2(r.end.x-8,r.get_center().y)
			_v38_diamond(mid_l,4.0,Color(primary,0.48))
			_v38_diamond(mid_r,4.0,Color(primary,0.48))
		"celestial":
			for c in [r.position+Vector2(17,17), Vector2(r.end.x-17,r.position.y+17), Vector2(r.position.x+17,r.end.y-17), r.end-Vector2(17,17)]:
				draw_circle(c,1.8,Color(secondary,0.38))
		_:
			# Citadel: short ornamental gold rails echo the reference UI.
			draw_line(r.position+Vector2(18,6),r.position+Vector2(40,6),Color(secondary,0.27),1.0)
			draw_line(Vector2(r.end.x-18,r.position.y+6),Vector2(r.end.x-40,r.position.y+6),Color(secondary,0.27),1.0)

func _v16_button(r: Rect2, label: String, accent: Color, size: int, icon_index: int = -1, enabled: bool = true) -> void:
	super._v16_button(r,label,accent,size,icon_index,enabled)
	if visual_pack == null or not enabled:
		return
	var p := _v38_primary()
	var s := _v38_secondary()
	if r.size.x >= 150.0 and r.size.y >= 48.0:
		# central jewel + metallic rail gives major CTAs the heavier reference look
		_v38_diamond(Vector2(r.get_center().x,r.position.y+2),5.5,Color(p,0.92))
		draw_line(r.position+Vector2(18,8),Vector2(r.end.x-18,r.position.y+8),Color(s,0.10),1.0)
	if r.size.x >= 360.0 and r.size.y >= 70.0:
		draw_rect(r.grow(3),Color(p,0.10),false,2.0)
		draw_line(r.position+Vector2(34,r.end.y-r.position.y-8),Vector2(r.end.x-34,r.end.y-8),Color(0,0,0,0.46),2.0)

func _v16_medallion(center: Vector2, radius: float, accent: Color, icon_index: int) -> void:
	super._v16_medallion(center,radius,accent,icon_index)
	if visual_pack == null:
		return
	var p := _v38_primary()
	var s := _v38_secondary()
	# segmented outer ring and tiny cardinal studs make icons feel authored rather
	# than flat circles while remaining cheap enough for mobile.
	for i in range(4):
		var a0 := float(i)*PI*0.5 + 0.12
		var a1 := a0 + 0.48
		draw_arc(center,radius+5.5,a0,a1,8,Color(p,0.46),1.2)
	for a in [0.0,PI*0.5,PI,PI*1.5]:
		var c := center+Vector2(cos(a),sin(a))*(radius+5.5)
		draw_circle(c,1.8,Color(s,0.58))

func _v38_diamond(center: Vector2, radius: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		center+Vector2(0,-radius), center+Vector2(radius,0),
		center+Vector2(0,radius), center+Vector2(-radius,0)
	]),color)

# -----------------------------------------------------------------------------
# Combat — packs now alter arena ornament language, not enemy readability.
# -----------------------------------------------------------------------------

func draw_game() -> void:
	super.draw_game()
	if visual_pack == null or settings_open or release_paused:
		return
	var p := _v38_primary()
	var s := _v38_secondary()
	_v38_draw_arena_skin(p,s)
	if elapsed < v38_pack_flash_until:
		var t := clampf((v38_pack_flash_until-elapsed)/0.9,0.0,1.0)
		draw_rect(ARENA.grow(-6),Color(p,0.04*t),false,4.0)

func _v38_draw_arena_skin(primary: Color, secondary: Color) -> void:
	var pack := _v38_pack_id()
	var left := ARENA.position.x+8.0
	var right := ARENA.end.x-8.0
	for y in [ARENA.position.y+92.0,ARENA.get_center().y,ARENA.end.y-92.0]:
		match pack:
			"void":
				draw_line(Vector2(left,y-10),Vector2(left+8,y),Color(primary,0.32),1.3)
				draw_line(Vector2(left+8,y),Vector2(left,y+10),Color(secondary,0.25),1.3)
				draw_line(Vector2(right,y-10),Vector2(right-8,y),Color(primary,0.32),1.3)
				draw_line(Vector2(right-8,y),Vector2(right,y+10),Color(secondary,0.25),1.3)
			"eclipse":
				draw_circle(Vector2(left+5,y),3.0,Color(primary,0.34))
				draw_circle(Vector2(right-5,y),3.0,Color(primary,0.34))
			"bloodstar":
				_v38_diamond(Vector2(left+5,y),4.0,Color(primary,0.34))
				_v38_diamond(Vector2(right-5,y),4.0,Color(primary,0.34))
			"celestial":
				draw_circle(Vector2(left+5,y),2.0,Color(secondary,0.42))
				draw_circle(Vector2(right-5,y),2.0,Color(secondary,0.42))
			_:
				draw_line(Vector2(left,y),Vector2(left+9,y),Color(secondary,0.28),1.2)
				draw_line(Vector2(right,y),Vector2(right-9,y),Color(secondary,0.28),1.2)

# -----------------------------------------------------------------------------
# Settings pack selector — add a five-pack collection strip so progression is
# visible at a glance without opening another screen.
# -----------------------------------------------------------------------------

func _draw_settings_overlay() -> void:
	super._draw_settings_overlay()
	if visual_pack == null:
		return
	var ids: Array[String] = ["citadel","void","eclipse","bloodstar","celestial"]
	var start_x := V37_PACK_SELECTOR.position.x + 327.0
	var y := V37_PACK_SELECTOR.end.y - 9.0
	for i in range(ids.size()):
		var id: String = ids[i]
		var c := Vector2(start_x + float(i)*28.0,y)
		var unlocked: bool = bool(visual_pack.is_unlocked(id))
		var selected: bool = String(visual_pack.selected) == id
		var col := Color("596074")
		if unlocked:
			col = Color(visual_pack.primary_for(id))
		_v38_diamond(c,4.5 if selected else 3.0,Color(col,0.95 if selected else 0.45))
		if selected:
			draw_arc(c,8.0,0,TAU,20,Color(col,0.48),1.0)

func _pointer_settings(pos: Vector2) -> void:
	var before := _v38_pack_id()
	super._pointer_settings(pos)
	if visual_pack != null and before != _v38_pack_id():
		v38_pack_flash_until = elapsed + 0.9
		if telemetry != null:
			telemetry.event("graphics_pack_2_select", {"pack": _v38_pack_id()})

func spawn_floor() -> void:
	var before := _v38_pack_id()
	super.spawn_floor()
	if visual_pack != null and before != _v38_pack_id():
		v38_pack_flash_until = elapsed + 1.2
