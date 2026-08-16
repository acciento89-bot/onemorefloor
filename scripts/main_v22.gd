extends "res://scripts/main_v21.gd"

# ONE MORE FLOOR v1.10 — premium component UI pass.
# This keeps every menu live and interactive while replacing the flat procedural
# frames/icons with reusable texture components and 9-slice rendering.

const V22_VERSION := "1.10.0-premium-components"
const V22_SKINS_PATH := "res://assets/art/concept_button_skins.svg"
const V22_ICON_ATLAS_PATH := "res://assets/art/ui_icon_atlas_v22.svg"
const V22_MEDALLION_PATH := "res://assets/art/ui_medallion_shell_v22.svg"
const V22_WANDERER_PATH := "res://assets/art/wanderer.svg"

var tex_v22_skins: Texture2D
var tex_v22_icons: Texture2D
var tex_v22_medallion: Texture2D
var tex_v22_wanderer: Texture2D

func _ready() -> void:
	super._ready()
	tex_v22_skins = load(V22_SKINS_PATH) as Texture2D
	tex_v22_icons = load(V22_ICON_ATLAS_PATH) as Texture2D
	tex_v22_medallion = load(V22_MEDALLION_PATH) as Texture2D
	tex_v22_wanderer = load(V22_WANDERER_PATH) as Texture2D
	queue_redraw()

func _v22_color_distance(a: Color, b: Color) -> float:
	return absf(a.r-b.r) + absf(a.g-b.g) + absf(a.b-b.b)

func _v22_skin_row(accent: Color, enabled: bool = true) -> int:
	if not enabled:
		return 5
	var best := 0
	var best_distance := 99.0
	var palette: Array[Color] = [V16_GOLD,V16_PURPLE,V16_BLUE,V16_GREEN,V16_ORANGE,Color("70798f")]
	for i: int in range(palette.size()):
		var d := _v22_color_distance(accent,palette[i])
		if d < best_distance:
			best_distance = d
			best = i
	return best

func _v22_draw_skin_piece(dst: Rect2, src: Rect2) -> void:
	if tex_v22_skins == null:
		return
	draw_texture_rect_region(tex_v22_skins,dst,src,Color.WHITE)

func _v22_nine_slice(r: Rect2, row: int) -> void:
	if tex_v22_skins == null:
		return
	var sw := 360.0
	var sh := 96.0
	var src_corner := 26.0
	var dc := minf(26.0,minf(r.size.x*0.24,r.size.y*0.42))
	var sy := float(row)*96.0
	# corners
	_v22_draw_skin_piece(Rect2(r.position,Vector2(dc,dc)),Rect2(0,sy,src_corner,src_corner))
	_v22_draw_skin_piece(Rect2(Vector2(r.end.x-dc,r.position.y),Vector2(dc,dc)),Rect2(sw-src_corner,sy,src_corner,src_corner))
	_v22_draw_skin_piece(Rect2(Vector2(r.position.x,r.end.y-dc),Vector2(dc,dc)),Rect2(0,sy+sh-src_corner,src_corner,src_corner))
	_v22_draw_skin_piece(Rect2(r.end-Vector2(dc,dc),Vector2(dc,dc)),Rect2(sw-src_corner,sy+sh-src_corner,src_corner,src_corner))
	# edges
	var mid_w := maxf(0.0,r.size.x-dc*2.0)
	var mid_h := maxf(0.0,r.size.y-dc*2.0)
	if mid_w > 0.0:
		_v22_draw_skin_piece(Rect2(Vector2(r.position.x+dc,r.position.y),Vector2(mid_w,dc)),Rect2(src_corner,sy,sw-src_corner*2.0,src_corner))
		_v22_draw_skin_piece(Rect2(Vector2(r.position.x+dc,r.end.y-dc),Vector2(mid_w,dc)),Rect2(src_corner,sy+sh-src_corner,sw-src_corner*2.0,src_corner))
	if mid_h > 0.0:
		_v22_draw_skin_piece(Rect2(Vector2(r.position.x,r.position.y+dc),Vector2(dc,mid_h)),Rect2(0,sy+src_corner,src_corner,sh-src_corner*2.0))
		_v22_draw_skin_piece(Rect2(Vector2(r.end.x-dc,r.position.y+dc),Vector2(dc,mid_h)),Rect2(sw-src_corner,sy+src_corner,src_corner,sh-src_corner*2.0))
	# center
	if mid_w > 0.0 and mid_h > 0.0:
		_v22_draw_skin_piece(Rect2(r.position+Vector2(dc,dc),Vector2(mid_w,mid_h)),Rect2(src_corner,sy+src_corner,sw-src_corner*2.0,sh-src_corner*2.0))

func _v16_frame(r: Rect2, accent: Color, fill: Color = V16_NAVY, glow: float = 0.15) -> void:
	# Runtime shadow and energy halo stay live; the actual chrome/body comes from
	# a reusable 9-slice component, not from a full-screen screenshot.
	var shadow := Rect2(r.position+Vector2(7,9),r.size)
	draw_colored_polygon(_v19_chamfer_points(shadow,11),Color(0,0,0,0.67))
	if glow > 0.0:
		for grow in [7.0,4.0]:
			var gr := r.grow(grow)
			draw_polyline(_v19_closed(_v19_chamfer_points(gr,12.0+grow)),Color(accent,0.025+glow*0.12),4.0)
	_v22_nine_slice(r,_v22_skin_row(accent,true))
	# Preserve caller-specific tone without flattening the component texture.
	var inner := r.grow(-13.0)
	if inner.size.x > 4.0 and inner.size.y > 4.0:
		draw_rect(inner,Color(fill,0.20))
		draw_line(inner.position+Vector2(10,2),Vector2(inner.end.x-10,inner.position.y+2),Color("fff1b0",0.11),1.0)

func _v22_atlas_tile_for_old(icon_index: int) -> int:
	match icon_index:
		0: return 4 # missions / vitality
		1: return 2 # talents / precision
		6: return 5 # sword / pass
		7: return 1 # forge
		9: return 7 # settings
		10: return 3 # vault
		11: return 6 # coin
		_: return -1

func _v22_atlas_tile_for_kind(kind: String) -> int:
	match kind:
		"hero": return 0
		"forge": return 1
		"talents": return 2
		"vault": return 3
		"missions": return 4
		"pass": return 5
		"coin": return 6
		"settings": return 7
		_: return -1

func _v22_draw_icon_tile(tile: int, dst: Rect2, modulate: Color = Color.WHITE) -> void:
	if tex_v22_icons == null or tile < 0:
		return
	var col := tile % 4
	var row := tile / 4
	var src := Rect2(float(col)*128.0,float(row)*128.0,128.0,128.0)
	draw_texture_rect_region(tex_v22_icons,dst,src,modulate)

func _v22_medallion_shell(center: Vector2, radius: float) -> void:
	if tex_v22_medallion != null:
		var d := (radius+10.0)*2.0
		draw_texture_rect(tex_v22_medallion,Rect2(center-Vector2(d,d)*0.5,Vector2(d,d)),false,Color.WHITE)
	else:
		draw_circle(center,radius+7,Color(0,0,0,0.7))
		draw_circle(center,radius+4,Color("6c410e"))
		draw_circle(center,radius,Color("090b13"))

func _v16_medallion(center: Vector2, radius: float, accent: Color, icon_index: int) -> void:
	_v22_medallion_shell(center,radius)
	# Accent halo is live and can change with state/rarity.
	draw_arc(center,maxf(4.0,radius-5.0),0,TAU,64,Color(accent,0.92),2.0)
	var tile := _v22_atlas_tile_for_old(icon_index)
	if tile >= 0:
		var d := radius*1.40
		_v22_draw_icon_tile(tile,Rect2(center-Vector2(d,d)*0.5,Vector2(d,d)))
	else:
		_v12_icon(icon_index,Rect2(center-Vector2(radius*0.66,radius*0.66),Vector2(radius*1.32,radius*1.32)))

func _v21_live_medallion(center: Vector2, radius: float, accent: Color, kind: String) -> void:
	_v22_medallion_shell(center,radius)
	draw_arc(center,maxf(4.0,radius-5.0),0,TAU,64,Color(accent,0.95),2.2)
	var tile := _v22_atlas_tile_for_kind(kind)
	if tile >= 0:
		var d := radius*1.45
		_v22_draw_icon_tile(tile,Rect2(center-Vector2(d,d)*0.5,Vector2(d,d)))

func _v16_button(r: Rect2, label: String, accent: Color, size: int, icon_index: int = -1, enabled: bool = true) -> void:
	var a: Color = accent if enabled else Color("666a7b")
	var row := _v22_skin_row(a,enabled)
	var shadow := Rect2(r.position+Vector2(5,7),r.size)
	draw_colored_polygon(_v19_chamfer_points(shadow,10),Color(0,0,0,0.68))
	_v22_nine_slice(r,row)
	if enabled:
		draw_rect(r.grow(-14),Color(a,0.035))
	var tc := V17_IVORY if enabled else Color("8c90a0")
	if icon_index >= 0:
		var rad := clampf(r.size.y*0.23,15.0,25.0)
		_v16_medallion(Vector2(r.position.x+rad+18.0,r.get_center().y),rad,a,icon_index)
		draw_string(v16_title_font,Vector2(r.position.x+rad*2.0+28.0,r.get_center().y+float(size)*0.34),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-rad*2.0-42.0,size,tc)
	else:
		draw_string(v16_title_font,Vector2(r.position.x+8.0,r.get_center().y+float(size)*0.34),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-16.0,size,tc)

func _v16_currency(amount: int, r: Rect2 = Rect2(510,22,190,88)) -> void:
	_v16_frame(r,V16_GOLD,Color("04060c"),0.24)
	_v22_medallion_shell(Vector2(r.position.x+43,r.get_center().y),27)
	var d := 38.0
	_v22_draw_icon_tile(6,Rect2(Vector2(r.position.x+43,r.get_center().y)-Vector2(d,d)*0.5,Vector2(d,d)))
	draw_string(v16_title_font,Vector2(r.position.x+79,r.get_center().y+12),str(amount),HORIZONTAL_ALIGNMENT_LEFT,r.size.x-90,30,Color("fff0a6"))

func _v21_action_button(r: Rect2, label: String, accent: Color, kind: String) -> void:
	_v16_frame(r,accent,Color(accent,0.10),0.26)
	_v21_live_medallion(Vector2(r.position.x+42,r.get_center().y),22,accent,kind)
	draw_string(v16_title_font,Vector2(r.position.x+77,r.get_center().y+7),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-88,18,V17_IVORY)

func _v21_home_tab(r: Rect2, label: String, kind: String, accent: Color) -> void:
	_v16_frame(r,accent,Color("04060d"),0.18)
	_v21_live_medallion(Vector2(r.get_center().x,r.position.y+37),23,accent,kind)
	draw_string(v16_title_font,Vector2(r.position.x+6,r.end.y-17),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-12,15,V17_IVORY)

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	# Use the high-detail character sheet everywhere instead of the old primitive
	# circle/polygon placeholder. Keeping the same method preserves all gameplay.
	if tex_v22_wanderer == null:
		super.draw_wanderer(pos,scale,combat)
		return
	var h := (98.0 if combat else 104.0) * scale
	var w := h * (2.0 / 3.0)
	var top_left := Vector2(pos.x-w*0.5,pos.y-h*0.78)
	if not combat:
		draw_circle(pos+Vector2(0,7.0*scale),34.0*scale,Color(V16_PURPLE,0.10))
		draw_arc(pos+Vector2(0,-10.0*scale),42.0*scale,-2.7,-0.45,40,Color(V17_PURPLE_HI,0.18),2.0)
	draw_texture_rect(tex_v22_wanderer,Rect2(top_left,Vector2(w,h)),false,Color.WHITE)
	if combat:
		draw_arc(pos,31.0*scale,-0.7,0.9,18,Color(1.0,0.75,0.3,0.28),2.2*scale)

func _v22_runtime_component_ready() -> bool:
	return tex_v22_skins != null and tex_v22_icons != null and tex_v22_medallion != null and tex_v22_wanderer != null
