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
var astral_intro := 0.0

func _ready() -> void:
	super._ready()
	tex_v22_skins = load(V22_SKINS_PATH) as Texture2D
	tex_v22_icons = load(V22_ICON_ATLAS_PATH) as Texture2D
	tex_v22_medallion = load(V22_MEDALLION_PATH) as Texture2D
	tex_v22_wanderer = load(V22_WANDERER_PATH) as Texture2D
	queue_redraw()

func _process(delta: float) -> void:
	super._process(delta)
	astral_intro = maxf(0.0, astral_intro - delta)

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
	_v22_draw_skin_piece(Rect2(r.position,Vector2(dc,dc)),Rect2(0,sy,src_corner,src_corner))
	_v22_draw_skin_piece(Rect2(Vector2(r.end.x-dc,r.position.y),Vector2(dc,dc)),Rect2(sw-src_corner,sy,src_corner,src_corner))
	_v22_draw_skin_piece(Rect2(Vector2(r.position.x,r.end.y-dc),Vector2(dc,dc)),Rect2(0,sy+sh-src_corner,src_corner,src_corner))
	_v22_draw_skin_piece(Rect2(r.end-Vector2(dc,dc),Vector2(dc,dc)),Rect2(sw-src_corner,sy+sh-src_corner,src_corner,src_corner))
	var mid_w := maxf(0.0,r.size.x-dc*2.0)
	var mid_h := maxf(0.0,r.size.y-dc*2.0)
	if mid_w > 0.0:
		_v22_draw_skin_piece(Rect2(Vector2(r.position.x+dc,r.position.y),Vector2(mid_w,dc)),Rect2(src_corner,sy,sw-src_corner*2.0,src_corner))
		_v22_draw_skin_piece(Rect2(Vector2(r.position.x+dc,r.end.y-dc),Vector2(mid_w,dc)),Rect2(src_corner,sy+sh-src_corner,sw-src_corner*2.0,src_corner))
	if mid_h > 0.0:
		_v22_draw_skin_piece(Rect2(Vector2(r.position.x,r.position.y+dc),Vector2(dc,mid_h)),Rect2(0,sy+src_corner,src_corner,sh-src_corner*2.0))
		_v22_draw_skin_piece(Rect2(Vector2(r.end.x-dc,r.position.y+dc),Vector2(dc,mid_h)),Rect2(sw-src_corner,sy+src_corner,src_corner,sh-src_corner*2.0))
	if mid_w > 0.0 and mid_h > 0.0:
		_v22_draw_skin_piece(Rect2(r.position+Vector2(dc,dc),Vector2(mid_w,mid_h)),Rect2(src_corner,sy+src_corner,sw-src_corner*2.0,sh-src_corner*2.0))

func _v16_frame(r: Rect2, accent: Color, fill: Color = V16_NAVY, glow: float = 0.15) -> void:
	var shadow := Rect2(r.position+Vector2(7,9),r.size)
	draw_colored_polygon(_v19_chamfer_points(shadow,11),Color(0,0,0,0.67))
	if glow > 0.0:
		for grow in [7.0,4.0]:
			var gr := r.grow(grow)
			draw_polyline(_v19_closed(_v19_chamfer_points(gr,12.0+grow)),Color(accent,0.025+glow*0.12),4.0)
	_v22_nine_slice(r,_v22_skin_row(accent,true))
	var inner := r.grow(-13.0)
	if inner.size.x > 4.0 and inner.size.y > 4.0:
		draw_rect(inner,Color(fill,0.20))
		draw_line(inner.position+Vector2(10,2),Vector2(inner.end.x-10,inner.position.y+2),Color("fff1b0",0.11),1.0)

func _v22_atlas_tile_for_old(icon_index: int) -> int:
	match icon_index:
		0: return 4
		1: return 2
		6: return 5
		7: return 1
		9: return 7
		10: return 3
		11: return 6
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

# -----------------------------------------------------------------------------
# Gameplay continuation — Deep Tower (Floor 31+) and run-build synergies.
# This deliberately reuses the existing production actor art instead of starting
# another graphics pass. The work here is enemy behavior, encounters and builds.
# -----------------------------------------------------------------------------

func spawn_floor() -> void:
	if int(run.floor_no) != 40:
		super.spawn_floor()
		return
	room_transition = 0.72
	current_room = room_system.roll_room(int(run.floor_no), rng)
	hazard_timer = 2.2
	enemies.clear()
	player_shots.clear()
	enemy_shots.clear()
	coin_orbs.clear()
	player_pos = Vector2(360,700)
	floor_banner = 1.25
	boss_intro = 0.0
	keeper_intro = 0.0
	hollow_intro = 0.0
	astral_intro = 2.0
	enemies.append(EnemyFactory.make_enemy("astral_warden",int(run.floor_no),rng,player_pos))
	for i: int in range(3):
		var escort_kind := "void_knight" if i < 2 else "rift_mage"
		enemies.append(EnemyFactory.make_enemy(escort_kind,int(run.floor_no),rng,player_pos))
	_audio("warden")

func update_room_hazard(delta: float) -> void:
	if String(current_room.get("area","")) != "DEEP TOWER" or String(current_room.get("type","")) == "BOSS":
		super.update_room_hazard(delta)
		return
	hazard_timer -= delta
	if hazard_timer > 0.0:
		return
	var hazard := String(current_room.get("hazard","none"))
	var damage_value := 10.0 + float(run.floor_no) * 0.34
	if hazard == "void_lanes":
		var lane_x: float = [145.0,360.0,575.0][rng.randi_range(0,2)]
		for offset: float in [-34.0,0.0,34.0]:
			var start := Vector2(lane_x+offset,ARENA.position.y+8.0)
			enemy_shots.append({"pos":start,"vel":Vector2.DOWN*300.0,"damage":damage_value,"life":3.2,"color":C_PURPLE})
		var lane_y: float = rng.randf_range(330.0,850.0)
		var from_left := rng.randf() < 0.5
		var x_start := ARENA.position.x+8.0 if from_left else ARENA.end.x-8.0
		var direction := Vector2.RIGHT if from_left else Vector2.LEFT
		for offset: float in [-28.0,28.0]:
			enemy_shots.append({"pos":Vector2(x_start,lane_y+offset),"vel":direction*285.0,"damage":damage_value,"life":2.7,"color":C_CYAN})
		hazard_timer = 4.4
	else:
		var center := ARENA.get_center()
		var count := 12
		var angle_offset := rng.randf_range(0.0,TAU)
		for i: int in range(count):
			var dir := Vector2.from_angle(angle_offset+TAU*float(i)/float(count))
			enemy_shots.append({"pos":center+dir*34.0,"vel":dir*235.0,"damage":damage_value,"life":3.1,"color":C_PURPLE if i%2==0 else C_CYAN})
		hazard_timer = 5.0

func update_enemies(delta: float) -> void:
	super.update_enemies(delta)
	for i: int in range(enemies.size()):
		var e: Dictionary = enemies[i]
		var kind := String(e.get("type",""))
		if not kind in ["void_knight","rift_mage","soul_reaver"]:
			continue
		var p: Vector2 = e["pos"]
		var to_player := player_pos-p
		var dist := to_player.length()
		if kind == "void_knight":
			e["dash_cd"] = maxf(0.0,float(e.get("dash_cd",0.0))-delta)
			e["dash_time"] = maxf(0.0,float(e.get("dash_time",0.0))-delta)
			if float(e["dash_cd"]) <= 0.0 and dist < 430.0:
				e["dash_time"] = 0.42
				e["dash_cd"] = 3.0
				effects.append({"type":"slash","pos":p,"dir":to_player.normalized(),"age":0.0,"dur":0.20,"color":C_CYAN,"kind":""})
			if dist > 1.0:
				var speed_mult := 2.75 if float(e["dash_time"]) > 0.0 else 1.0
				p += to_player.normalized()*float(e["speed"])*speed_mult*delta
		elif kind == "rift_mage":
			p = _ranged_enemy_step(e,p,to_player,dist,delta,250.0,430.0)
			if float(e["attack_cd"]) <= 0.0 and dist < 560.0:
				var aim := to_player.normalized()
				for spread: float in [-0.22,0.0,0.22]:
					var dir := aim.rotated(spread)
					enemy_shots.append({"pos":p+dir*24.0,"vel":dir*285.0,"damage":15.0+float(run.floor_no)*0.62,"life":2.9,"color":C_CYAN if spread==0.0 else C_PURPLE})
				e["attack_cd"] = 1.55
			e["blink_cd"] = maxf(0.0,float(e.get("blink_cd",0.0))-delta)
			if float(e["blink_cd"]) <= 0.0:
				effects.append({"type":"phase2","pos":p,"age":0.0,"dur":0.30,"color":C_CYAN,"kind":""})
				p = clamp_to_arena(p+Vector2(rng.randf_range(-175.0,175.0),rng.randf_range(-145.0,145.0)),float(e["radius"]))
				e["blink_cd"] = 3.8
		else:
			var hp_ratio := clampf(float(e["hp"])/float(e["max_hp"]),0.0,1.0)
			e["rage"] = 1.0 if hp_ratio <= 0.40 else 0.0
			e["lunge_cd"] = maxf(0.0,float(e.get("lunge_cd",0.0))-delta)
			e["lunge_time"] = maxf(0.0,float(e.get("lunge_time",0.0))-delta)
			if float(e["lunge_cd"]) <= 0.0 and dist < 420.0:
				e["lunge_time"] = 0.34
				e["lunge_cd"] = 2.35
				effects.append({"type":"slash","pos":p,"dir":to_player.normalized(),"age":0.0,"dur":0.18,"color":V16_PURPLE,"kind":""})
			if dist > 1.0:
				var rage_mult := 1.25 if float(e["rage"]) > 0.0 else 1.0
				var lunge_mult := 2.45 if float(e["lunge_time"]) > 0.0 else 1.0
				var side := Vector2(-to_player.y,to_player.x).normalized()*sin(elapsed*5.5+float(e.get("phase",0.0)))*0.16
				p += (to_player.normalized()+side).normalized()*float(e["speed"])*rage_mult*lunge_mult*delta
		e["pos"] = clamp_to_arena(p,float(e["radius"]))
		var new_dist := player_pos.distance_to(e["pos"])
		if new_dist < 34.0+float(e["radius"]) and float(e["touch_cd"]) <= 0.0:
			damage_player(float(e["touch_damage"]),e["pos"])
			e["touch_cd"] = 0.62
		enemies[i] = e

func apply_damage_to_enemy(index: int, amount: float, crit: bool, hit_pos: Vector2) -> void:
	if index >= 0 and index < enemies.size() and String(enemies[index].get("type","")) == "void_knight":
		amount *= 1.0-float(enemies[index].get("guard",0.18))
	super.apply_damage_to_enemy(index,amount,crit,hit_pos)

func update_warden(e: Dictionary, p: Vector2, to_player: Vector2, dist: float, delta: float) -> void:
	if String(e.get("boss_variant","warden")) != "astral_warden":
		super.update_warden(e,p,to_player,dist,delta)
		return
	var hp_ratio := clampf(float(e["hp"])/float(e["max_hp"]),0.0,1.0)
	if hp_ratio <= 0.50 and not bool(e["phase2"]):
		e["phase2"] = true
		e["attack_cd"] = 0.22
		effects.append({"type":"phase2","pos":p,"age":0.0,"dur":0.95,"color":C_CYAN,"kind":""})
		screen_shake = 15.0
		haptic(90)

	e["teleport_cd"] = maxf(0.0,float(e.get("teleport_cd",0.0))-delta)
	if float(e["teleport_cd"]) <= 0.0:
		effects.append({"type":"keeper_cast","pos":p,"age":0.0,"dur":0.34,"color":C_PURPLE,"kind":""})
		var spots := [Vector2(145,310),Vector2(575,310),Vector2(145,850),Vector2(575,850),Vector2(360,500)]
		p = spots[rng.randi_range(0,spots.size()-1)]
		e["pos"] = p
		e["teleport_cd"] = 2.2 if bool(e["phase2"]) else 3.25
		for i: int in range(8):
			var dir := Vector2.from_angle(TAU*float(i)/8.0)
			enemy_shots.append({"pos":p+dir*54.0,"vel":dir*240.0,"damage":19.0+float(run.floor_no)*0.68,"life":3.0,"color":C_CYAN if i%2==0 else C_PURPLE})

	if float(e["cast_timer"]) > 0.0:
		e["cast_timer"] = maxf(0.0,float(e["cast_timer"])-delta)
		if float(e["cast_timer"]) <= 0.0:
			execute_warden_cast(e)
			e["cast_kind"] = ""
			e["attack_cd"] = 0.72 if bool(e["phase2"]) else 1.05
		return
	if float(e["attack_cd"]) <= 0.0:
		var attack_index := int(e["attack_index"])
		e["cast_kind"] = "crossfire" if attack_index%2==0 else "rift_ring"
		e["cast_timer"] = 0.34 if bool(e["phase2"]) else 0.48
		e["attack_index"] = attack_index+1
		effects.append({"type":"warden_telegraph","pos":p,"age":0.0,"dur":float(e["cast_timer"]),"color":C_CYAN if String(e["cast_kind"])=="crossfire" else C_PURPLE,"kind":String(e["cast_kind"])})
		return
	if dist > 175.0 and dist > 1.0:
		p += to_player.normalized()*float(e["speed"])*delta
	e["pos"] = clamp_to_arena(p,float(e["radius"]))

func execute_warden_cast(e: Dictionary) -> void:
	if String(e.get("boss_variant","warden")) != "astral_warden":
		super.execute_warden_cast(e)
		return
	var p: Vector2 = e["pos"]
	var phase2 := bool(e["phase2"])
	if String(e["cast_kind"]) == "crossfire":
		var aim := (player_pos-p).normalized()
		var count := 13 if phase2 else 9
		for i: int in range(count):
			var spread := (float(i)-float(count-1)*0.5)*0.105
			var dir := aim.rotated(spread)
			enemy_shots.append({"pos":p+dir*58.0,"vel":dir*(385.0 if phase2 else 330.0),"damage":21.0+float(run.floor_no)*0.82,"life":2.8,"color":C_CYAN if i%2==0 else C_PURPLE})
		if phase2:
			for dir: Vector2 in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
				enemy_shots.append({"pos":p+dir*60.0,"vel":dir*410.0,"damage":23.0+float(run.floor_no)*0.84,"life":2.5,"color":C_PURPLE})
	else:
		var count := 26 if phase2 else 18
		var offset := float(e["attack_index"])*0.13
		for i: int in range(count):
			var dir := Vector2.from_angle(offset+TAU*float(i)/float(count))
			enemy_shots.append({"pos":p+dir*58.0,"vel":dir*(345.0 if phase2 else 275.0),"damage":20.0+float(run.floor_no)*0.78,"life":3.25,"color":C_PURPLE if i%2==0 else C_CYAN})
	effects.append({"type":"keeper_cast","pos":p,"age":0.0,"dur":0.40,"color":C_CYAN,"kind":""})
	screen_shake = maxf(screen_shake,10.0 if phase2 else 6.0)
	haptic(36)

func apply_upgrade(index: int) -> void:
	super.apply_upgrade(index)
	if run == null or not run.has_method("consume_synergy_notice"):
		return
	var unlocked := String(run.consume_synergy_notice())
	if unlocked.is_empty():
		return
	loot_notice = "SYNERGY UNLOCKED — %s" % unlocked
	loot_notice_color = C_CYAN
	loot_notice_time = 2.6
	_audio("claim")

func _v12_actor_index(kind: String, variant: String) -> int:
	match kind:
		"void_knight": return 9
		"rift_mage": return 10
		"soul_reaver": return 5
		"warden":
			if variant == "astral_warden": return 11
	return super._v12_actor_index(kind,variant)

func _motion_row(kind: String, variant: String = "warden") -> int:
	match kind:
		"void_knight": return 9
		"rift_mage": return 10
		"soul_reaver": return 5
		"warden":
			if variant == "astral_warden": return 11
	return super._motion_row(kind,variant)

func enemy_color(kind: String) -> Color:
	match kind:
		"void_knight": return Color("6b78d6")
		"rift_mage": return Color("63d8ff")
		"soul_reaver": return Color("aa5cff")
	return super.enemy_color(kind)

func _draw_boss_ui() -> void:
	var boss: Dictionary = {}
	for e: Dictionary in enemies:
		if String(e.get("type","")) == "warden" and String(e.get("boss_variant","")) == "astral_warden":
			boss = e
			break
	if boss.is_empty():
		super._draw_boss_ui()
		return
	var ratio := clampf(float(boss["hp"])/float(boss["max_hp"]),0.0,1.0)
	var accent := C_PURPLE if bool(boss["phase2"]) else C_CYAN
	panel(Rect2(88,156,544,60),Color("090e1b"),accent)
	text("THE ASTRAL WARDEN",Vector2(108,181),15,C_TEXT)
	draw_rect(Rect2(270,178,334,14),Color("172038"))
	draw_rect(Rect2(270,178,334*ratio,14),accent)
	if astral_intro > 0.0:
		var alpha := clampf(astral_intro,0.0,1.0)
		draw_rect(Rect2(44,468,632,184),Color(0.01,0.015,0.04,0.91*alpha))
		var title_color := C_CYAN
		title_color.a = alpha
		draw_string(font,Vector2(68,542),"THE ASTRAL WARDEN",HORIZONTAL_ALIGNMENT_CENTER,584,42,title_color)
		draw_string(font,Vector2(68,590),"FLOOR 40  •  HEART OF THE DEEP TOWER",HORIZONTAL_ALIGNMENT_CENTER,584,16,C_TEXT)

func _v22_runtime_component_ready() -> bool:
	return tex_v22_skins != null and tex_v22_icons != null and tex_v22_medallion != null and tex_v22_wanderer != null
