extends "res://scripts/main_v43.gd"

# ONE MORE FLOOR v1.31 — Boss Spectacle.
# Endgame bosses now have dedicated intro beats, three readable combat phases,
# larger visual silhouettes, realm-specific arena rituals and restrained phase
# attacks. The extra attacks are deliberately lighter than native boss specials;
# they add identity without turning the screen into unreadable bullet spam.

const V44_VERSION := "1.31.0-boss-spectacle"
const V44_BUILD := "22-dev"
const V44_BOSS_VARIANTS := ["void_archon", "eclipse_regent", "bloodstar_tyrant", "world_eater"]
const V44_CREST_PATHS := {
	"void_archon": "res://assets/art/boss_crest_void_archon_v44.svg",
	"eclipse_regent": "res://assets/art/boss_crest_eclipse_regent_v44.svg",
	"bloodstar_tyrant": "res://assets/art/boss_crest_bloodstar_tyrant_v44.svg",
	"world_eater": "res://assets/art/boss_crest_world_eater_v44.svg",
}

var v44_boss_crests: Dictionary = {}
var v44_boss_intro := 0.0
var v44_phase_transition := 0.0
var v44_transition_name := ""
var v44_active_variant := ""
var v44_stage_pattern_count := 0

func _ready() -> void:
	super._ready()
	for variant in V44_BOSS_VARIANTS:
		var path := String(V44_CREST_PATHS.get(variant, ""))
		if not path.is_empty():
			v44_boss_crests[variant] = load(path) as Texture2D
	if telemetry != null:
		telemetry.set_build_context(V44_VERSION, V44_BUILD)
	queue_redraw()

func _process(delta: float) -> void:
	super._process(delta)
	v44_boss_intro = maxf(0.0, v44_boss_intro - delta)
	v44_phase_transition = maxf(0.0, v44_phase_transition - delta)

func spawn_floor() -> void:
	super.spawn_floor()
	v44_boss_intro = 0.0
	v44_phase_transition = 0.0
	v44_transition_name = ""
	v44_active_variant = ""
	v44_stage_pattern_count = 0
	if run == null or String(current_room.get("type", "")) != "BOSS":
		return
	var idx := _v44_boss_index()
	if idx < 0:
		return
	var boss: Dictionary = enemies[idx]
	var variant := String(boss.get("boss_variant", ""))
	if not variant in V44_BOSS_VARIANTS:
		return
	v44_active_variant = variant
	v44_boss_intro = 2.55
	v43_chamber_intro = 0.0
	boss["v44_stage"] = 1
	boss["v44_stage_cd"] = 4.8
	boss["v44_visual_scale"] = 1.22
	boss["attack_cd"] = maxf(float(boss.get("attack_cd", 0.0)), 2.4)
	boss["ability_cd"] = maxf(float(boss.get("ability_cd", 0.0)), 2.7)
	enemies[idx] = boss
	current_room["boss_encounter"] = _v44_boss_title(variant)
	if telemetry != null:
		telemetry.event("boss_encounter_start", {
			"floor": int(run.floor_no),
			"variant": variant,
			"title": _v44_boss_title(variant),
		})
	_audio("warden")

# Freeze the whole encounter during the short cinematic beats. This also keeps
# escorts fair: the player never has to dodge hidden attacks under a title card.
func update_enemies(delta: float) -> void:
	if state == State.RUNNING and _v44_boss_index() >= 0 and (v44_boss_intro > 0.0 or v44_phase_transition > 0.0):
		return
	super.update_enemies(delta)

func update_warden(e: Dictionary, p: Vector2, to_player: Vector2, dist: float, delta: float) -> void:
	var variant := String(e.get("boss_variant", ""))
	if not variant in V44_BOSS_VARIANTS:
		super.update_warden(e, p, to_player, dist, delta)
		return

	var ratio := clampf(float(e.get("hp", 1.0)) / maxf(1.0, float(e.get("max_hp", 1.0))), 0.0, 1.0)
	var desired_stage := _v44_boss_stage_for_ratio(ratio)
	var current_stage := int(e.get("v44_stage", 1))
	if desired_stage > current_stage:
		e["v44_stage"] = desired_stage
		e["v44_stage_cd"] = 1.5
		if desired_stage >= 2:
			e["phase2"] = true
		_v44_begin_phase(e, variant, desired_stage, p)
		return

	super.update_warden(e, p, to_player, dist, delta)
	var stage := int(e.get("v44_stage", 1))
	if stage <= 1:
		return
	var stage_cd := maxf(0.0, float(e.get("v44_stage_cd", 0.0)) - delta)
	if stage_cd <= 0.0:
		_v44_fire_stage_pattern(e, variant, stage)
		stage_cd = _v44_stage_pattern_cooldown(variant, stage)
	e["v44_stage_cd"] = stage_cd

func _v44_begin_phase(e: Dictionary, variant: String, stage: int, pos: Vector2) -> void:
	v44_phase_transition = 1.45
	v44_transition_name = _v44_phase_name(variant, stage)
	enemy_shots.clear()
	e["attack_cd"] = maxf(float(e.get("attack_cd", 0.0)), 1.1)
	e["ability_cd"] = maxf(float(e.get("ability_cd", 0.0)), 1.25)
	effects.append({"type":"phase2", "pos":pos, "age":0.0, "dur":1.0, "color":_v28_boss_accent(variant), "kind":""})
	screen_shake = maxf(screen_shake, 18.0 if stage == 3 else 13.0)
	haptic(125 if stage == 3 else 82)
	_audio("warden")
	if telemetry != null and run != null:
		telemetry.event("boss_phase", {
			"floor": int(run.floor_no),
			"variant": variant,
			"stage": stage,
			"phase": v44_transition_name,
		})

func _v44_boss_stage_for_ratio(ratio: float) -> int:
	if ratio <= 0.22:
		return 3
	if ratio <= 0.50:
		return 2
	return 1

func _v44_stage_pattern_cooldown(variant: String, stage: int) -> float:
	var cd := 5.2 if stage == 2 else 4.0
	if variant == "world_eater":
		cd -= 0.35
	elif variant == "bloodstar_tyrant":
		cd -= 0.15
	return maxf(3.25, cd)

func _v44_fire_stage_pattern(e: Dictionary, variant: String, stage: int) -> void:
	if run == null:
		return
	var p: Vector2 = e.get("pos", ARENA.get_center())
	var floor_no := float(run.floor_no)
	var damage_value := (8.0 + floor_no * 0.10) * (1.10 if stage == 3 else 1.0)
	var accent := _v28_boss_accent(variant)
	match variant:
		"void_archon":
			var lanes := [355.0, 565.0, 775.0]
			for y in lanes:
				var left := Vector2(ARENA.position.x + 8.0, y)
				var right := Vector2(ARENA.end.x - 8.0, y + 52.0)
				_v44_shot(left, (player_pos - left).normalized() * 255.0, damage_value, accent, 3.5)
				_v44_shot(right, (player_pos - right).normalized() * 255.0, damage_value, C_CYAN, 3.5)
			if stage == 3:
				_v44_radial(p, 8, 235.0, damage_value, accent, elapsed * 0.28)
		"eclipse_regent":
			var center := ARENA.get_center()
			for start in [Vector2(ARENA.position.x+8.0, center.y), Vector2(ARENA.end.x-8.0, center.y), Vector2(center.x, ARENA.position.y+8.0), Vector2(center.x, ARENA.end.y-8.0)]:
				_v44_shot(start, (center-start).normalized()*270.0, damage_value, C_GOLD if int(start.x+start.y)%2 == 0 else accent, 3.4)
			if stage == 3:
				_v44_radial(p, 8, 250.0, damage_value, C_GOLD, elapsed * 0.20 + 0.38)
		"bloodstar_tyrant":
			var count := 6 if stage == 2 else 9
			for n in range(count):
				var x := 92.0 + float(n) * (536.0 / float(maxi(1, count - 1)))
				var drift := -38.0 if n % 2 == 0 else 38.0
				_v44_shot(Vector2(x, ARENA.position.y + 8.0), Vector2(drift, 300.0), damage_value, C_RED, 3.2)
		"world_eater":
			var center := ARENA.get_center()
			var count := 8 if stage == 2 else 12
			for n in range(count):
				var a := TAU * float(n) / float(count) + elapsed * 0.16
				var start := center + Vector2.from_angle(a) * 365.0
				_v44_shot(start, (center-start).normalized() * 245.0, damage_value, C_CYAN if n % 2 == 0 else accent, 3.8)
	v44_stage_pattern_count += 1
	effects.append({"type":"keeper_cast", "pos":p, "age":0.0, "dur":0.34, "color":accent, "kind":""})
	screen_shake = maxf(screen_shake, 5.0 if stage == 2 else 7.0)
	haptic(22 if stage == 2 else 32)

func _v44_shot(pos: Vector2, velocity: Vector2, damage_value: float, color: Color, life: float) -> void:
	enemy_shots.append({
		"pos": pos,
		"vel": velocity,
		"damage": damage_value,
		"life": life,
		"color": color,
		"v44_boss_phase": true,
	})

func _v44_radial(pos: Vector2, count: int, speed: float, damage_value: float, color: Color, offset: float) -> void:
	for n in range(count):
		var dir := Vector2.from_angle(offset + TAU * float(n) / float(count))
		_v44_shot(pos + dir * 58.0, dir * speed, damage_value, color, 3.3)

# -----------------------------------------------------------------------------
# Boss arena art and silhouette language.
# -----------------------------------------------------------------------------

func _draw_room_floor() -> void:
	super._draw_room_floor()
	var boss := _v44_boss_snapshot()
	if boss.is_empty():
		return
	var variant := String(boss.get("boss_variant", ""))
	if not variant in V44_BOSS_VARIANTS:
		return
	var stage := int(boss.get("v44_stage", 1))
	var accent := _v28_boss_accent(variant)
	var center := ARENA.get_center()
	var crest := v44_boss_crests.get(variant) as Texture2D
	if crest != null:
		var d := 280.0 + float(stage - 1) * 34.0
		draw_texture_rect(crest, Rect2(center-Vector2(d,d)*0.5, Vector2(d,d)), false, Color(1,1,1,0.075 + float(stage-1)*0.025))
	_v44_draw_boss_arena(variant, stage, center, accent)

func _v44_draw_boss_arena(variant: String, stage: int, center: Vector2, accent: Color) -> void:
	var intensity := 0.12 + float(stage - 1) * 0.045
	match variant:
		"void_archon":
			for radius in [150.0, 205.0, 260.0]:
				draw_arc(center, radius, elapsed*0.08, elapsed*0.08+PI*1.45, 64, Color(accent, intensity), 2.0)
			for n in range(4 + stage * 2):
				var a := TAU*float(n)/float(4+stage*2) + elapsed*0.04
				var p := center + Vector2.from_angle(a)*210.0
				draw_colored_polygon(PackedVector2Array([p+Vector2(0,-9),p+Vector2(7,0),p+Vector2(0,9),p+Vector2(-7,0)]), Color(accent, intensity))
		"eclipse_regent":
			draw_circle(center, 105.0 + float(stage)*10.0, Color(0,0,0,0.12 + float(stage)*0.025))
			draw_arc(center, 132.0+float(stage)*9.0, -1.34, 1.88, 72, Color(C_GOLD, intensity+0.08), 5.0)
			draw_arc(center, 148.0+float(stage)*9.0, 1.72, 4.98, 72, Color(accent, intensity+0.04), 4.0)
		"bloodstar_tyrant":
			for n in range(5):
				var a := -PI*0.5 + TAU*float(n)/5.0
				var b := -PI*0.5 + TAU*float((n*2)%5)/5.0
				draw_line(center+Vector2.from_angle(a)*(130.0+stage*8.0), center+Vector2.from_angle(b)*(130.0+stage*8.0), Color(accent, intensity+0.04), 4.0)
			if stage == 3:
				draw_arc(center, 198.0, elapsed*0.18, elapsed*0.18+TAU, 72, Color(C_RED,0.20), 3.0)
		"world_eater":
			for radius in [92.0, 148.0, 214.0, 278.0]:
				draw_arc(center, radius, elapsed*(0.035+radius*0.00012), elapsed*(0.035+radius*0.00012)+TAU, 72, Color(accent, intensity*0.80), 2.0)
			for n in range(8 + stage*2):
				var a := elapsed*0.07 + TAU*float(n)/float(8+stage*2)
				var rr := 155.0 + float((n*41)%115)
				draw_circle(center+Vector2.from_angle(a)*rr, 2.0+float(n%3), Color(C_CYAN, intensity+0.03))

func draw_enemy(e: Dictionary) -> void:
	super.draw_enemy(e)
	if String(e.get("type", "")) != "warden":
		return
	var variant := String(e.get("boss_variant", ""))
	if not variant in V44_BOSS_VARIANTS:
		return
	_v44_draw_boss_presence(e, variant)

func _v44_draw_boss_presence(e: Dictionary, variant: String) -> void:
	var p: Vector2 = e.get("pos", Vector2.ZERO)
	var r := float(e.get("radius", 70.0))
	var stage := int(e.get("v44_stage", 1))
	var accent := _v28_boss_accent(variant)
	var outer := r + 42.0 + float(stage-1)*12.0
	draw_circle(p, outer, Color(accent, 0.035 + float(stage)*0.018))
	for i in range(2 + stage):
		var rr := outer + float(i)*11.0
		var start := elapsed*(0.12+float(i)*0.035)+float(i)
		draw_arc(p, rr, start, start+PI*1.35, 56, Color(accent, 0.24-float(i)*0.035), 2.5)
	match variant:
		"void_archon":
			for side in [-1.0, 1.0]:
				draw_colored_polygon(PackedVector2Array([p+Vector2(side*34,-20), p+Vector2(side*(94+stage*8),-58), p+Vector2(side*(72+stage*8),8), p+Vector2(side*32,34)]), Color(accent,0.20))
				draw_line(p+Vector2(side*25,-35), p+Vector2(side*(88+stage*7),-78), Color(C_CYAN,0.55), 3.0)
		"eclipse_regent":
			draw_arc(p, outer+9.0, -1.38, 1.82, 52, Color(C_GOLD,0.72), 7.0)
			draw_arc(p, outer+16.0, 1.72, 5.00, 52, Color(accent,0.50), 4.0)
			for n in range(5+stage):
				var a := -2.45 + float(n)*(1.75/float(4+stage))
				draw_line(p+Vector2.from_angle(a)*outer, p+Vector2.from_angle(a)*(outer+28.0+stage*5.0), Color(C_GOLD,0.46), 4.0)
		"bloodstar_tyrant":
			for n in range(8+stage*2):
				var a := TAU*float(n)/float(8+stage*2)
				var inner := p+Vector2.from_angle(a)*(r+28.0)
				var tip := p+Vector2.from_angle(a)*(outer+30.0+float(n%2)*13.0)
				draw_line(inner, tip, Color(accent,0.60), 5.0 if n%2==0 else 3.0)
		"world_eater":
			for n in range(4+stage):
				var a := elapsed*(0.13+float(n)*0.018)+TAU*float(n)/float(4+stage)
				var moon := p+Vector2.from_angle(a)*(outer+18.0+float(n%2)*12.0)
				draw_circle(moon, 7.0+float(n%3)*2.0, Color(C_CYAN,0.50))
				draw_line(p+Vector2.from_angle(a)*(r+18.0), moon, Color(accent,0.18), 2.0)
			for side in [-1.0,1.0]:
				draw_colored_polygon(PackedVector2Array([p+Vector2(side*24,22),p+Vector2(side*(72+stage*8),52),p+Vector2(side*(54+stage*7),78),p+Vector2(side*18,48)]),Color(accent,0.16))

# -----------------------------------------------------------------------------
# Boss HUD, intro and phase transition presentation.
# -----------------------------------------------------------------------------

func draw_game() -> void:
	super.draw_game()
	var boss := _v44_boss_snapshot()
	if boss.is_empty():
		return
	var variant := String(boss.get("boss_variant", ""))
	if not variant in V44_BOSS_VARIANTS:
		return
	_v44_draw_boss_hud(boss, variant)
	if v44_boss_intro > 0.0:
		_v44_draw_boss_intro(variant)
	elif v44_phase_transition > 0.0:
		_v44_draw_phase_transition(boss, variant)

func _v44_draw_boss_hud(boss: Dictionary, variant: String) -> void:
	var stage := int(boss.get("v44_stage", 1))
	var ratio := clampf(float(boss.get("hp", 1.0))/maxf(1.0,float(boss.get("max_hp", 1.0))),0.0,1.0)
	var accent := _v28_boss_accent(variant)
	var r := Rect2(78, 148, 564, 74)
	draw_rect(r, Color(0.008,0.010,0.018,0.93))
	draw_rect(r, Color(accent,0.62), false, 2.0)
	var crest := v44_boss_crests.get(variant) as Texture2D
	if crest != null:
		draw_texture_rect(crest, Rect2(86,154,56,56), false, Color.WHITE)
	draw_string(v16_title_font, Vector2(151,177), _v44_boss_title(variant), HORIZONTAL_ALIGNMENT_LEFT, 330, 17, V17_IVORY)
	draw_string(v16_body_font, Vector2(151,198), "PHASE %s  •  %s" % [_v44_stage_roman(stage), _v44_phase_name(variant, stage)], HORIZONTAL_ALIGNMENT_LEFT, 395, 10, Color(accent,0.92))
	var hp_r := Rect2(151,204,468,9)
	draw_rect(hp_r, Color("241520"))
	draw_rect(Rect2(hp_r.position, Vector2(hp_r.size.x*ratio,hp_r.size.y)), accent)
	draw_rect(hp_r, Color(1,1,1,0.16), false, 1.0)

func _v44_draw_boss_intro(variant: String) -> void:
	var alpha := clampf(v44_boss_intro / 0.55, 0.0, 1.0)
	var accent := _v28_boss_accent(variant)
	draw_rect(ARENA, Color(0.0,0.0,0.0,0.56*alpha))
	var center := ARENA.get_center()
	var crest := v44_boss_crests.get(variant) as Texture2D
	if crest != null:
		draw_texture_rect(crest, Rect2(center-Vector2(90,90),Vector2(180,180)), false, Color(1,1,1,0.86*alpha))
	draw_string(v16_title_font, Vector2(80,624), _v44_boss_title(variant), HORIZONTAL_ALIGNMENT_CENTER, 560, 36, Color(V17_IVORY,alpha))
	draw_string(v16_body_font, Vector2(90,655), _v44_boss_subtitle(variant), HORIZONTAL_ALIGNMENT_CENTER, 540, 12, Color(accent,0.90*alpha))
	draw_line(Vector2(150,680),Vector2(570,680),Color(accent,0.55*alpha),2.0)

func _v44_draw_phase_transition(boss: Dictionary, variant: String) -> void:
	var alpha := clampf(v44_phase_transition / 0.42, 0.0, 1.0)
	var accent := _v28_boss_accent(variant)
	var stage := int(boss.get("v44_stage", 2))
	draw_rect(ARENA, Color(accent,0.07*alpha))
	var plate := Rect2(116, 520, 488, 104)
	draw_rect(plate, Color(0.005,0.006,0.012,0.82*alpha))
	draw_rect(plate, Color(accent,0.66*alpha), false, 2.0)
	draw_string(v16_body_font, Vector2(132,552), "PHASE %s" % _v44_stage_roman(stage), HORIZONTAL_ALIGNMENT_CENTER, 456, 12, Color(accent,alpha))
	draw_string(v16_title_font, Vector2(132,588), v44_transition_name, HORIZONTAL_ALIGNMENT_CENTER, 456, 26, Color(V17_IVORY,alpha))
	draw_string(v16_body_font, Vector2(132,612), _v44_phase_stinger(variant,stage), HORIZONTAL_ALIGNMENT_CENTER, 456, 10, Color(V16_MUTED,alpha))

func _v44_boss_index() -> int:
	for i in range(enemies.size()):
		var e: Dictionary = enemies[i]
		if String(e.get("type", "")) == "warden" and String(e.get("boss_variant", "")) in V44_BOSS_VARIANTS:
			return i
	return -1

func _v44_boss_snapshot() -> Dictionary:
	var idx := _v44_boss_index()
	if idx < 0:
		return {}
	return enemies[idx]

func _v44_boss_title(variant: String) -> String:
	return _v28_boss_title(variant)

func _v44_boss_subtitle(variant: String) -> String:
	match variant:
		"void_archon": return "THE CITADEL BENDS TO ITS WILL"
		"eclipse_regent": return "THE LAST LIGHT ENTERS TOTALITY"
		"bloodstar_tyrant": return "THE RED CROWN DEMANDS A PRICE"
		"world_eater": return "THE FINAL STAR HAS NOWHERE LEFT TO FALL"
	return "THE TOWER ANSWERS"

func _v44_phase_name(variant: String, stage: int) -> String:
	match variant:
		"void_archon":
			return ["RIFT THRONE", "CITADEL UNBOUND", "EVENT HORIZON"][clampi(stage-1,0,2)]
		"eclipse_regent":
			return ["DUSK COURT", "TOTALITY", "BLACK SUN"][clampi(stage-1,0,2)]
		"bloodstar_tyrant":
			return ["IRON OATH", "CRIMSON ASCENT", "RED CROWN"][clampi(stage-1,0,2)]
		"world_eater":
			return ["HUNGER", "GRAVITY COLLAPSE", "LAST STAR"][clampi(stage-1,0,2)]
	return "WARDEN"

func _v44_phase_stinger(variant: String, stage: int) -> String:
	if stage < 3:
		match variant:
			"void_archon": return "THE RIFT OPENS WIDER"
			"eclipse_regent": return "LIGHT AND SHADOW BECOME ONE"
			"bloodstar_tyrant": return "THE CHAINS DRAW TIGHT"
			"world_eater": return "GRAVITY STARTS TO BREAK"
	match variant:
		"void_archon": return "NO WALL REMAINS"
		"eclipse_regent": return "THE SUN GOES OUT"
		"bloodstar_tyrant": return "ONLY THE CROWN REMAINS"
		"world_eater": return "SURVIVE THE LAST STAR"
	return "FINAL PHASE"

func _v44_stage_roman(stage: int) -> String:
	return ["I", "II", "III"][clampi(stage-1,0,2)]

func _v44_boss_spectacle_ready() -> bool:
	if v44_boss_crests.size() != 4:
		return false
	for variant in V44_BOSS_VARIANTS:
		if not (v44_boss_crests.get(variant) is Texture2D):
			return false
	return _v44_boss_stage_for_ratio(0.90) == 1 and _v44_boss_stage_for_ratio(0.50) == 2 and _v44_boss_stage_for_ratio(0.20) == 3
