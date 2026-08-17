extends "res://scripts/main_v46.gd"

# ONE MORE FLOOR v1.34 — Foundation-to-endgame visual continuity.
# Replaces the remaining floor 1-50 combat silhouettes with dedicated tower art,
# adds a four-pose player combat atlas, authored projectile language and a short
# floor-clear transition. Balance, hit geometry and economy are unchanged.

const V47_VERSION := "1.34.0-foundation-art"
const V47_BUILD := "22-dev"
const V47_TOWER_ATLAS := "res://assets/art/actors_tower_v47.svg"
const V47_PLAYER_ATLAS := "res://assets/art/player_combat_v47.svg"
const V47_PROJECTILE_ATLAS := "res://assets/art/projectiles_v47.svg"
const V47_CELL := 192.0
const V47_PROJECTILE_CELL := 256.0
const V47_TOWER_SLOTS := {
	"goblin":[0,0], "bat":[1,0], "skeleton":[2,0], "ghoul":[3,0],
	"necromancer":[4,0], "gargoyle":[5,0], "sentinel":[6,0], "hexer":[7,0],
	"void_knight":[8,0], "rift_mage":[9,0], "soul_reaver":[0,1],
	"phase_stalker":[1,1], "orb_weaver":[2,1], "oathbreaker":[3,1],
	"warden":[4,1], "crypt_keeper":[5,1], "hollow_king":[6,1],
	"astral_warden":[7,1], "null_sovereign":[8,1],
}

var v47_tower_atlas: Texture2D
var v47_player_atlas: Texture2D
var v47_projectile_atlas: Texture2D
var v47_player_attack_stamp := -99.0
var v47_player_skill_stamp := -99.0
var v47_floor_clear_time := 0.0
var v47_foundation_kills := 0

func _ready() -> void:
	super._ready()
	v47_tower_atlas = load(V47_TOWER_ATLAS) as Texture2D
	v47_player_atlas = load(V47_PLAYER_ATLAS) as Texture2D
	v47_projectile_atlas = load(V47_PROJECTILE_ATLAS) as Texture2D
	if telemetry != null:
		telemetry.set_build_context(V47_VERSION, V47_BUILD)
	queue_redraw()

func _process(delta: float) -> void:
	var before := state
	super._process(delta)
	if before == State.RUNNING and state == State.UPGRADE:
		v47_floor_clear_time = 1.08
	else:
		v47_floor_clear_time = maxf(0.0, v47_floor_clear_time - delta)

func _v47_actor_id(e: Dictionary) -> String:
	if String(e.get("type", "")) == "warden":
		var variant := String(e.get("boss_variant", "warden"))
		return variant if V47_TOWER_SLOTS.has(variant) else "warden"
	return String(e.get("type", ""))

func _v47_has_actor(e: Dictionary) -> bool:
	return V47_TOWER_SLOTS.has(_v47_actor_id(e))

func _v47_accent(actor_id: String) -> Color:
	match actor_id:
		"goblin", "ghoul": return Color("86d06d")
		"bat", "necromancer", "hexer", "phase_stalker", "null_sovereign": return Color("b66cff")
		"skeleton", "sentinel", "oathbreaker", "warden": return Color("e2b45f")
		"gargoyle": return Color("a7b3c2")
		"void_knight", "rift_mage", "hollow_king": return Color("9e72ff")
		"soul_reaver", "orb_weaver", "crypt_keeper", "astral_warden": return Color("70e8f5")
		_: return C_GOLD

func _v47_is_boss(e: Dictionary) -> bool:
	return String(e.get("type", "")) == "warden"

func draw_enemy(e: Dictionary) -> void:
	if not _v47_has_actor(e):
		super.draw_enemy(e)
		return
	var actor_id := _v47_actor_id(e)
	var p: Vector2 = e.get("pos", Vector2.ZERO)
	var radius := float(e.get("radius", 24.0))
	var boss := _v47_is_boss(e)
	var phase := float(e.get("phase", 0.0))
	var bob := sin(elapsed * (2.0 if boss else 3.0) + phase) * (2.4 if boss else 1.6)
	var hit_age := elapsed - float(e.get("v47_hit_stamp", -99.0))
	var hit := clampf(1.0 - hit_age / 0.16, 0.0, 1.0) if hit_age >= 0.0 else 0.0
	var tell := _v47_attack_tell_amount(e)
	var aim := player_pos - p
	var aim_dir := aim.normalized() if aim.length_squared() > 1.0 else Vector2.DOWN
	var visual_p := p - aim_dir * tell * (9.0 if boss else 4.0) + Vector2(0,bob + hit*2.0)
	var size := radius * (3.15 if boss else _v47_scale(actor_id)) * (1.0 + tell*0.035 - hit*0.05)
	var accent := _v47_accent(actor_id)
	draw_circle(visual_p, radius*(1.62 if boss else 1.30), Color(accent, 0.045 if boss else 0.026))
	if bool(e.get("elite", false)):
		draw_arc(visual_p, radius*1.58+8.0, elapsed*0.5, elapsed*0.5+PI*1.65, 42, Color(C_GOLD,0.78), 3.0)
	_v47_draw_actor_cell(actor_id, visual_p, Vector2(size,size), sin(elapsed*1.6+phase)*0.018, Color.WHITE)
	_v47_draw_actor_live_fx(actor_id, visual_p, radius, accent, tell)
	_v47_draw_health(e, p, radius, accent)
	if tell > 0.08:
		_v47_draw_tell(visual_p, radius, accent, aim_dir, tell, boss)
	if hit > 0.0:
		draw_arc(visual_p, radius*(1.15+0.32*hit), elapsed*2.0, elapsed*2.0+PI*1.3, 28, Color(accent,0.42*hit), 2.0+2.0*hit)

func _v47_scale(actor_id: String) -> float:
	match actor_id:
		"bat": return 4.45
		"sentinel", "void_knight", "oathbreaker": return 4.10
		"gargoyle": return 4.22
		_: return 3.95

func _v47_draw_actor_cell(actor_id: String, center: Vector2, size: Vector2, rotation: float, modulate: Color) -> void:
	if v47_tower_atlas == null or not V47_TOWER_SLOTS.has(actor_id):
		return
	var slot: Array = V47_TOWER_SLOTS[actor_id]
	var src := Rect2(float(slot[0])*V47_CELL, float(slot[1])*V47_CELL, V47_CELL, V47_CELL)
	draw_set_transform(center, rotation, Vector2.ONE)
	draw_texture_rect_region(v47_tower_atlas, Rect2(-size*0.5,size), src, modulate)
	draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _v47_draw_health(e: Dictionary, p: Vector2, radius: float, accent: Color) -> void:
	var hpv := float(e.get("hp",1.0))
	var maxv := maxf(1.0,float(e.get("max_hp",hpv)))
	if hpv >= maxv and not bool(e.get("elite",false)) and not bool(e.get("bounty_target",false)) and not _v47_is_boss(e):
		return
	var w := clampf(radius*(2.7 if _v47_is_boss(e) else 2.35),58.0,150.0)
	var r := Rect2(p.x-w*0.5,p.y-radius*(2.05 if _v47_is_boss(e) else 1.90),w,7.0)
	draw_rect(r,Color(0.02,0.02,0.035,0.9))
	draw_rect(Rect2(r.position,Vector2(r.size.x*clampf(hpv/maxv,0.0,1.0),r.size.y)),C_GOLD if bool(e.get("elite",false)) else accent)
	draw_rect(r,Color(1,1,1,0.14),false,1.0)

func _v47_attack_tell_amount(e: Dictionary) -> float:
	var best := 99.0
	for key in ["attack_cd","dash_cd","dive_cd","blink_cd","lunge_cd","phase_cd","slam_cd","summon_cd","teleport_cd"]:
		var v := float(e.get(key,0.0))
		if v > 0.001:
			best = minf(best,v)
	if best == 99.0 or best > 0.34:
		return 0.0
	return clampf(1.0-best/0.34,0.0,1.0)

func _v47_draw_tell(p: Vector2, radius: float, accent: Color, aim: Vector2, amount: float, boss: bool) -> void:
	var rr := radius*(1.45 if boss else 1.18)+amount*12.0
	draw_arc(p,rr,aim.angle()-0.52,aim.angle()+0.52,24,Color(accent,0.20+0.38*amount),2.0+2.0*amount)
	draw_line(p+aim*(radius*0.6),p+aim*(radius*(1.20+amount*0.48)),Color(accent,0.18+0.32*amount),2.0)

func _v47_draw_actor_live_fx(actor_id: String, p: Vector2, radius: float, accent: Color, tell: float) -> void:
	var pulse := 0.5+0.5*sin(elapsed*3.5)
	match actor_id:
		"bat": draw_arc(p,radius*1.42,-2.8,-0.35,22,Color(accent,0.18+0.16*pulse),2.0)
		"necromancer", "hexer", "rift_mage": draw_circle(p+Vector2(radius*1.45,-radius*0.5),4.0+3.0*pulse,Color(accent,0.30+0.30*pulse))
		"orb_weaver":
			for n in range(3):
				var a := elapsed*(0.9+float(n)*0.1)+TAU*float(n)/3.0
				draw_circle(p+Vector2.from_angle(a)*radius*1.55,3.5,Color(accent,0.42))
		"phase_stalker": draw_line(p+Vector2(-radius*1.4,0),p+Vector2(radius*1.4,0),Color(accent,0.10+0.18*pulse),2.0)
		"crypt_keeper", "astral_warden": draw_arc(p,radius*1.55,elapsed*0.3,elapsed*0.3+PI*1.55,34,Color(accent,0.22),2.0)
		"null_sovereign": draw_arc(p,radius*1.65,-elapsed*0.24,-elapsed*0.24+PI*1.72,38,Color(accent,0.28+0.12*tell),3.0)

func apply_damage_to_enemy(index: int, amount: float, crit: bool, hit_pos: Vector2) -> void:
	if index < 0 or index >= enemies.size():
		return
	var was_foundation := _v47_has_actor(enemies[index])
	var actor_id := _v47_actor_id(enemies[index])
	super.apply_damage_to_enemy(index,amount,crit,hit_pos)
	if not was_foundation or index < 0 or index >= enemies.size():
		return
	var e := enemies[index]
	e["v47_hit_stamp"] = elapsed
	enemies[index] = e
	effects.append({"type":"v47_hit","pos":hit_pos,"age":0.0,"dur":0.22 if crit else 0.16,"color":C_GOLD if crit else _v47_accent(actor_id),"crit":crit})

func remove_dead() -> void:
	for e in enemies:
		if float(e.get("hp",1.0)) > 0.0 or not _v47_has_actor(e):
			continue
		var actor_id := _v47_actor_id(e)
		var boss := _v47_is_boss(e)
		effects.append({"type":"v47_death","pos":e.get("pos",Vector2.ZERO),"age":0.0,"dur":0.98 if boss else 0.58,"actor_id":actor_id,"radius":float(e.get("radius",24.0)),"color":_v47_accent(actor_id),"boss":boss})
		v47_foundation_kills += 1
	super.remove_dead()

func fire_auto_attack() -> void:
	v47_player_attack_stamp = elapsed
	super.fire_auto_attack()

func use_skill() -> void:
	var ready: bool = run != null and float(run.skill_cd) <= 0.0
	super.use_skill()
	if ready:
		v47_player_skill_stamp = elapsed
		effects.append({"type":"v47_nova","pos":player_pos,"age":0.0,"dur":0.42,"color":C_PURPLE})

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	if not combat or v47_player_atlas == null:
		super.draw_wanderer(pos,scale,combat)
		return
	var frame := 0
	if elapsed-v47_player_skill_stamp < 0.34:
		frame = 3
	elif elapsed-v47_player_attack_stamp < 0.18:
		frame = 2
	elif joy_vector.length_squared() > 0.03:
		frame = 1
	var src := Rect2(float(frame)*192.0,0,192,192)
	var size := Vector2(112,112)*scale
	var bob := sin(elapsed*7.0)*1.5 if frame == 1 else sin(elapsed*2.7)*0.8
	draw_circle(pos+Vector2(0,18),31.0*scale,Color(C_PURPLE,0.055))
	draw_texture_rect_region(v47_player_atlas,Rect2(pos-size*0.5+Vector2(0,bob),size),src,Color.WHITE)

func draw_player_projectile(shot: Dictionary) -> void:
	if v47_projectile_atlas == null:
		super.draw_player_projectile(shot)
		return
	var p: Vector2 = shot.get("pos",Vector2.ZERO)
	var vel: Vector2 = shot.get("vel",Vector2.RIGHT)
	var crit := bool(shot.get("crit",false))
	_v47_draw_projectile_cell(1 if crit else 0,p,Vector2(64,64) if crit else Vector2(48,48),vel.angle(),Color.WHITE)

func draw_enemy_projectile(shot: Dictionary) -> void:
	if v47_projectile_atlas == null:
		super.draw_enemy_projectile(shot)
		return
	var p: Vector2 = shot.get("pos",Vector2.ZERO)
	var c: Color = shot.get("color",C_CYAN)
	_v47_draw_projectile_cell(2,p,Vector2(46,46),elapsed*1.6,Color(c,0.94))

func draw_effect(fx: Dictionary) -> void:
	match String(fx.get("type","")):
		"v47_hit":
			var t := clampf(float(fx.get("age",0.0))/maxf(0.01,float(fx.get("dur",0.16))),0.0,1.0)
			var p: Vector2 = fx.get("pos",Vector2.ZERO)
			var c: Color = fx.get("color",C_TEXT)
			var r := lerpf(16.0,52.0 if bool(fx.get("crit",false)) else 36.0,t)
			draw_arc(p,r,0,TAU,28,Color(c,0.58*(1.0-t)),3.0)
			return
		"v47_death":
			_v47_draw_death(fx)
			return
		"v47_nova":
			var t := clampf(float(fx.get("age",0.0))/maxf(0.01,float(fx.get("dur",0.42))),0.0,1.0)
			var nova_r := float(run.nova_radius) if run != null else 250.0
			_v47_draw_projectile_cell(3,fx.get("pos",Vector2.ZERO),Vector2.ONE*lerpf(90.0,nova_r*1.65,t),t*0.45,Color(1,1,1,0.72*(1.0-t)))
			return
		_:
			super.draw_effect(fx)

func _v47_draw_death(fx: Dictionary) -> void:
	var t := clampf(float(fx.get("age",0.0))/maxf(0.01,float(fx.get("dur",0.58))),0.0,1.0)
	var p: Vector2 = fx.get("pos",Vector2.ZERO)
	var actor_id := String(fx.get("actor_id",""))
	var radius := float(fx.get("radius",24.0))
	var boss := bool(fx.get("boss",false))
	var c: Color = fx.get("color",C_PURPLE)
	_v47_draw_actor_cell(actor_id,p+Vector2(0,-12*t),Vector2.ONE*radius*(3.05 if boss else _v47_scale(actor_id))*(1.0-0.16*t),(t-0.5)*0.15,Color(1,1,1,0.70*(1.0-t)))
	var shard_count := 12 if boss else 7
	for n in range(shard_count):
		var a := TAU*float(n)/float(shard_count)
		draw_line(p+Vector2.from_angle(a)*radius*0.55,p+Vector2.from_angle(a)*radius*(1.1+t*(2.0 if boss else 1.4)),Color(c,0.55*(1.0-t)),3.0 if boss else 2.0)

func _v47_draw_projectile_cell(cell: int, center: Vector2, size: Vector2, rotation: float, modulate: Color) -> void:
	if v47_projectile_atlas == null:
		return
	var src := Rect2(float(cell)*V47_PROJECTILE_CELL,0,V47_PROJECTILE_CELL,V47_PROJECTILE_CELL)
	draw_set_transform(center,rotation,Vector2.ONE)
	draw_texture_rect_region(v47_projectile_atlas,Rect2(-size*0.5,size),src,modulate)
	draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func draw_upgrade() -> void:
	super.draw_upgrade()
	if v47_floor_clear_time <= 0.0 or v47_projectile_atlas == null:
		return
	var t := 1.0-clampf(v47_floor_clear_time/1.08,0.0,1.0)
	var alpha := sin(clampf(t,0.0,1.0)*PI)
	var center := Vector2(360,315)
	draw_rect(Rect2(0,180,720,260),Color(0.01,0.01,0.025,0.38*alpha))
	_v47_draw_projectile_cell(4,center,Vector2.ONE*lerpf(110.0,210.0,t),t*0.25,Color(1,1,1,0.68*alpha))
	draw_string(v16_title_font,Vector2(80,326),"FLOOR CLEARED",HORIZONTAL_ALIGNMENT_CENTER,560,34,Color(V17_IVORY,alpha))
	draw_string(v16_body_font,Vector2(100,356),"Loot secured. Choose your next edge.",HORIZONTAL_ALIGNMENT_CENTER,520,13,Color(C_GOLD,0.92*alpha))

func _v47_foundation_visuals_ready() -> bool:
	return v47_tower_atlas is Texture2D and v47_player_atlas is Texture2D and v47_projectile_atlas is Texture2D and V47_TOWER_SLOTS.size() == 19 and _v46_combat_vfx_ready()
