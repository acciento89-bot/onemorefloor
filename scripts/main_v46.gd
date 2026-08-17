extends "res://scripts/main_v45.gd"

# ONE MORE FLOOR v1.33 — Combat animation + impact pass.
# Adds readable wind-up motion, hit reactions, authored impact/death/loot art,
# actor disintegration and stronger attack/coin presentation without changing
# combat balance or collision geometry.

const V46_VERSION := "1.33.0-combat-impact"
const V46_BUILD := "22-dev"
const V46_FX_PATH := "res://assets/art/combat_fx_v46.svg"
const V46_FX_CELL := 256.0

var v46_fx_atlas: Texture2D
var v46_hit_count := 0
var v46_death_count := 0

func _ready() -> void:
	super._ready()
	v46_fx_atlas = load(V46_FX_PATH) as Texture2D
	if telemetry != null:
		telemetry.set_build_context(V46_VERSION, V46_BUILD)
	queue_redraw()

func _v46_actor_id(e: Dictionary) -> String:
	if String(e.get("type", "")) == "warden":
		return String(e.get("boss_variant", ""))
	return String(e.get("type", ""))

func _v46_is_authored_actor(e: Dictionary) -> bool:
	return _v45_has_actor(_v46_actor_id(e))

# Give authored actors real motion language without touching their gameplay radius.
func draw_enemy(e: Dictionary) -> void:
	if not _v46_is_authored_actor(e):
		super.draw_enemy(e)
		return
	var actor_id := _v46_actor_id(e)
	var visual := e.duplicate(false)
	var base_pos: Vector2 = e.get("pos", Vector2.ZERO)
	var base_radius := float(e.get("radius", 24.0))
	var phase := float(e.get("phase", 0.0))
	var boss := String(e.get("type", "")) == "warden"
	var idle := 1.0 + sin(elapsed * (2.0 if boss else 2.8) + phase) * (0.018 if boss else 0.026)
	var attack_cd := maxf(0.0, float(e.get("attack_cd", 1.0)))
	var ability_cd := maxf(0.0, float(e.get("ability_cd", attack_cd))) if boss else attack_cd
	var tell_cd := minf(attack_cd, ability_cd) if boss else attack_cd
	var windup := 0.0
	if tell_cd <= 0.34:
		windup = clampf(1.0 - tell_cd / 0.34, 0.0, 1.0)
	var hit_age := elapsed - float(e.get("v46_hit_stamp", -99.0))
	var hit_react := clampf(1.0 - hit_age / 0.17, 0.0, 1.0) if hit_age >= 0.0 else 0.0
	var to_player := player_pos - base_pos
	var aim := to_player.normalized() if to_player.length_squared() > 1.0 else Vector2.DOWN
	visual["pos"] = base_pos - aim * windup * (8.0 if boss else 5.0) + Vector2(0, hit_react * 2.0)
	visual["radius"] = base_radius * idle * (1.0 - hit_react * 0.055 + windup * 0.035)
	super.draw_enemy(visual)
	_v46_draw_attack_tell(e, actor_id, visual["pos"], base_radius, windup, boss)
	if hit_react > 0.0:
		_v46_draw_hit_reaction(actor_id, visual["pos"], base_radius, hit_react)

func _v46_draw_attack_tell(e: Dictionary, actor_id: String, p: Vector2, radius: float, windup: float, boss: bool) -> void:
	if windup <= 0.08:
		return
	var accent := _v45_actor_accent(actor_id)
	var aim := player_pos - p
	if aim.length_squared() <= 1.0:
		aim = Vector2.DOWN
	else:
		aim = aim.normalized()
	var pulse := 0.55 + 0.45 * sin(elapsed * 16.0)
	var rr := radius * (1.42 if boss else 1.18) + windup * 13.0
	draw_arc(p, rr, aim.angle() - 0.52, aim.angle() + 0.52, 24, Color(accent, 0.18 + windup * 0.38), 2.0 + windup * 2.0)
	draw_line(p + aim * (radius * 0.62), p + aim * (radius * (1.22 + windup * 0.52)), Color(accent, (0.12 + 0.28 * windup) * pulse), 2.0)
	if boss and windup > 0.62:
		for n in range(3):
			var a := elapsed * (0.8 + float(n) * 0.15) + TAU * float(n) / 3.0
			draw_circle(p + Vector2.from_angle(a) * (rr + 12.0), 3.0 + 2.0 * windup, Color(C_GOLD, 0.30 + 0.28 * windup))

func _v46_draw_hit_reaction(actor_id: String, p: Vector2, radius: float, strength: float) -> void:
	var accent := _v45_actor_accent(actor_id)
	draw_circle(p, radius * (1.15 + 0.30 * strength), Color(1.0, 1.0, 1.0, 0.055 * strength))
	draw_arc(p, radius * (1.15 + 0.36 * strength), elapsed * 2.2, elapsed * 2.2 + PI * 1.3, 28, Color(accent, 0.42 * strength), 2.0 + 2.0 * strength)

func apply_damage_to_enemy(index: int, amount: float, crit: bool, hit_pos: Vector2) -> void:
	if index < 0 or index >= enemies.size():
		return
	var actor_id := _v46_actor_id(enemies[index])
	super.apply_damage_to_enemy(index, amount, crit, hit_pos)
	if index < 0 or index >= enemies.size():
		return
	if not _v45_has_actor(actor_id):
		return
	var e := enemies[index]
	e["v46_hit_stamp"] = elapsed
	e["v46_last_crit"] = crit
	enemies[index] = e
	var accent := C_GOLD if crit else _v45_actor_accent(actor_id)
	effects.append({
		"type":"v46_hit",
		"pos":hit_pos,
		"age":0.0,
		"dur":0.24 if crit else 0.18,
		"color":accent,
		"crit":crit,
	})
	v46_hit_count += 1

# Preserve all inherited reward/drop logic; layer the authored death beat before
# the existing removal pipeline executes.
func remove_dead() -> void:
	for e in enemies:
		if float(e.get("hp", 1.0)) > 0.0 or not _v46_is_authored_actor(e):
			continue
		var actor_id := _v46_actor_id(e)
		var boss := String(e.get("type", "")) == "warden"
		effects.append({
			"type":"v46_death",
			"pos":e.get("pos", Vector2.ZERO),
			"age":0.0,
			"dur":1.05 if boss else 0.62,
			"color":_v45_actor_accent(actor_id),
			"actor_id":actor_id,
			"radius":float(e.get("radius", 24.0)),
			"boss":boss,
		})
		v46_death_count += 1
		if telemetry != null and run != null:
			telemetry.event("combat_actor_defeated", {"floor":int(run.floor_no), "actor":actor_id, "boss":boss})
	super.remove_dead()

func fire_auto_attack() -> void:
	var dir := Vector2.RIGHT
	var idx := nearest_enemy([])
	if idx >= 0 and idx < enemies.size():
		var target: Vector2 = enemies[idx].get("pos", player_pos + Vector2.RIGHT)
		if target.distance_squared_to(player_pos) > 1.0:
			dir = (target - player_pos).normalized()
	super.fire_auto_attack()
	if idx >= 0:
		effects.append({
			"type":"v46_slash",
			"pos":player_pos + dir * 24.0,
			"dir":dir,
			"age":0.0,
			"dur":0.16,
			"color":C_GOLD,
		})

func draw_coin_orb(orb: Dictionary) -> void:
	if v46_fx_atlas == null:
		super.draw_coin_orb(orb)
		return
	var p: Vector2 = orb.get("pos", Vector2.ZERO)
	var age := float(orb.get("age", 0.0))
	var pulse := 1.0 + sin(age * 15.0) * 0.08
	for n in range(2):
		var a := age * (4.0 + float(n)) + PI * float(n)
		draw_circle(p + Vector2.from_angle(a) * (12.0 + float(n) * 4.0), 2.2, Color(C_GOLD, 0.28))
	_v46_draw_fx_cell(2, p, Vector2(31,31) * pulse, 0.0, Color(1,1,1,0.95))

func draw_effect(fx: Dictionary) -> void:
	var kind := String(fx.get("type", ""))
	match kind:
		"v46_hit":
			_v46_draw_hit_fx(fx)
			return
		"v46_death":
			_v46_draw_death_fx(fx)
			return
		"v46_slash":
			_v46_draw_slash_fx(fx)
			return
		"coin":
			super.draw_effect(fx)
			if v46_fx_atlas != null:
				var t := clampf(float(fx.get("age",0.0))/maxf(0.01,float(fx.get("dur",0.2))),0.0,1.0)
				_v46_draw_fx_cell(2, fx.get("pos",Vector2.ZERO), Vector2.ONE*(30.0+26.0*t), 0.0, Color(1,1,1,0.52*(1.0-t)))
			return
		_:
			super.draw_effect(fx)

func _v46_draw_hit_fx(fx: Dictionary) -> void:
	var t := clampf(float(fx.get("age",0.0))/maxf(0.01,float(fx.get("dur",0.18))),0.0,1.0)
	var p: Vector2 = fx.get("pos",Vector2.ZERO)
	var c: Color = fx.get("color",C_TEXT)
	var crit := bool(fx.get("crit",false))
	var size := lerpf(38.0, 92.0 if crit else 68.0, t)
	_v46_draw_fx_cell(0, p, Vector2(size,size), elapsed*1.1, Color(c, (1.0-t)*(0.95 if crit else 0.72)))
	if crit:
		draw_arc(p, 26.0 + 36.0*t, 0, TAU, 34, Color(C_GOLD,0.66*(1.0-t)), 3.0)

func _v46_draw_death_fx(fx: Dictionary) -> void:
	var t := clampf(float(fx.get("age",0.0))/maxf(0.01,float(fx.get("dur",0.62))),0.0,1.0)
	var p: Vector2 = fx.get("pos",Vector2.ZERO)
	var c: Color = fx.get("color",C_PURPLE)
	var actor_id := String(fx.get("actor_id",""))
	var radius := float(fx.get("radius",24.0))
	var boss := bool(fx.get("boss",false))
	_v46_draw_fx_cell(1, p, Vector2.ONE * (radius*(3.8 if boss else 3.0)+t*42.0), t*0.7, Color(c,0.42*(1.0-t)))
	var tex := _v45_actor_texture(actor_id)
	var slot := _v45_actor_slot(actor_id)
	if tex != null and slot.size() >= 2:
		var src := Rect2(float(int(slot[1]))*192.0,0,192,192)
		var body_size := radius * (3.65 if boss else _v45_actor_scale(actor_id)) * (1.0-0.16*t)
		draw_set_transform(p + Vector2(0,-12.0*t), (t-0.5)*0.18, Vector2.ONE)
		draw_texture_rect_region(tex, Rect2(Vector2(-body_size*0.5,-body_size*0.5),Vector2(body_size,body_size)), src, Color(1,1,1,0.72*(1.0-t)))
		draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)
	var shard_count := 14 if boss else 8
	for n in range(shard_count):
		var a := TAU*float(n)/float(shard_count) + float(n%3)*0.14
		var d0 := radius*(0.55+t*0.6)
		var d1 := radius*(1.05+t*(2.2 if boss else 1.55))
		draw_line(p+Vector2.from_angle(a)*d0,p+Vector2.from_angle(a)*d1,Color(c,0.55*(1.0-t)),3.0 if boss else 2.0)

func _v46_draw_slash_fx(fx: Dictionary) -> void:
	var t := clampf(float(fx.get("age",0.0))/maxf(0.01,float(fx.get("dur",0.16))),0.0,1.0)
	var p: Vector2 = fx.get("pos",Vector2.ZERO)
	var dir: Vector2 = fx.get("dir",Vector2.RIGHT)
	var ang := dir.angle()
	var size := lerpf(82.0,126.0,t)
	_v46_draw_fx_cell(3,p,Vector2(size,size),ang,Color(1,1,1,0.72*(1.0-t)))

func _v46_draw_fx_cell(cell: int, center: Vector2, size: Vector2, rotation: float, modulate: Color) -> void:
	if v46_fx_atlas == null:
		return
	var src := Rect2(float(cell)*V46_FX_CELL,0,V46_FX_CELL,V46_FX_CELL)
	draw_set_transform(center,rotation,Vector2.ONE)
	draw_texture_rect_region(v46_fx_atlas,Rect2(-size*0.5,size),src,modulate)
	draw_set_transform(Vector2.ZERO,0.0,Vector2.ONE)

func _v46_combat_vfx_ready() -> bool:
	return v46_fx_atlas is Texture2D and _v45_actor_art_ready() and V45_ACTOR_SLOTS.size() == 16
