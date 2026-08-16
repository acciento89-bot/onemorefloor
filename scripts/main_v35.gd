extends "res://scripts/main_v34.gd"

const ReleaseGuard = preload("res://scripts/release_guard.gd")
const V35_VERSION := "1.24.0-polish-release"
const V35_BUILD := "16"

var release_guard
var floor_started_msec := 0
var run_started_msec := 0
var last_realm_seen := ""
var last_combo_audio := 0

func _ready() -> void:
	super._ready()
	release_guard = ReleaseGuard.new()
	var health: Dictionary = release_guard.validate(meta, loot)
	release_guard.backup_last_good()
	if telemetry != null:
		telemetry.set_build_context(V35_VERSION, V35_BUILD)
		telemetry.event("release_guard", {
			"ok": bool(health.get("ok", true)),
			"repairs": int(Array(health.get("repairs", [])).size()),
			"backup": release_guard.backup_exists()
		})

func _process(delta: float) -> void:
	super._process(delta)
	if release_audio != null:
		var intensity := 0.0
		if state == State.RUNNING:
			intensity = clampf(float(enemies.size()) / 7.0, 0.0, 1.0)
			if _v11_has_boss():
				intensity = 1.0
		release_audio.set_combat_intensity(intensity)
	if telemetry != null:
		telemetry.heartbeat(int(run.floor_no) if run != null else 0, Engine.get_frames_per_second(), enemies.size())

func start_run() -> void:
	run_started_msec = int(Time.get_ticks_msec())
	floor_started_msec = run_started_msec
	last_realm_seen = ""
	last_combo_audio = 0
	super.start_run()

func spawn_floor() -> void:
	super.spawn_floor()
	floor_started_msec = int(Time.get_ticks_msec())
	if run == null:
		return
	var realm := String(current_room.get("area", "DUNGEON"))
	if realm != last_realm_seen:
		last_realm_seen = realm
		if telemetry != null:
			telemetry.event("realm_enter", {"floor": int(run.floor_no), "realm": realm})
		if int(run.floor_no) in [50, 100, 150, 200]:
			_audio("milestone")

func roll_upgrade_options() -> void:
	if telemetry != null and run != null and floor_started_msec > 0:
		telemetry.event("floor_clear", {
			"floor": int(run.floor_no),
			"seconds": maxf(0.0, float(Time.get_ticks_msec() - floor_started_msec) / 1000.0),
			"room": String(current_room.get("type", "COMBAT")),
			"realm": String(current_room.get("area", "DUNGEON")),
			"power": int(meta.power_score())
		})
	super.roll_upgrade_options()

func remove_dead() -> void:
	var elite_before := run_elite_kills
	var boss_before := run_boss_kills
	var combo_before := combo_count
	super.remove_dead()
	if run_elite_kills > elite_before:
		_audio("elite")
	if run_boss_kills > boss_before:
		_audio("boss_down")
		if telemetry != null and run != null:
			telemetry.event("boss_defeat", {
				"floor": int(run.floor_no),
				"realm": String(current_room.get("area", "DUNGEON")),
				"milestone": int(run.floor_no) % 50 == 0
			})
	if combo_count > combo_before and combo_count >= 5:
		var gate := int(combo_count / 5) * 5
		if gate > last_combo_audio:
			last_combo_audio = gate
			_audio("combo")

func cash_out() -> void:
	_record_v35_run_summary("cash_out")	super.cash_out()
	if release_guard != null:
		release_guard.backup_last_good()

func die() -> void:
	_record_v35_run_summary("death")	super.die()
	if release_guard != null:
		release_guard.backup_last_good()

func _record_v35_run_summary(reason: String) -> void:
	if telemetry == null or run == null:
		return
	telemetry.record_run_summary({
		"reason": reason,
		"start_floor": run_start_floor,
		"peak_floor": maxi(run_peak_floor, int(run.floor_no)),
		"kills": run_kills,
		"elites": run_elite_kills,
		"bosses": run_boss_kills,
		"combo": combo_best,
		"modifier": run_modifier,
		"seconds": maxf(0.0, float(Time.get_ticks_msec() - run_started_msec) / 1000.0),
		"power": int(meta.power_score())
	})

# -----------------------------------------------------------------------------
# Realm-specific music from v1.22.
# -----------------------------------------------------------------------------

func _sync_music_context(force: bool) -> void:
	if release_audio == null:
		return
	var desired := "menu"
	if state in [State.RUNNING, State.UPGRADE, State.DECISION]:
		var area: String = String(current_room.get("area", "DUNGEON"))
		if state == State.RUNNING and _v11_has_boss():
			desired = "boss"
		else:
			match area:
				"CRYPT": desired = "crypt"
				"FORGOTTEN CASTLE": desired = "castle"
				"DEEP TOWER": desired = "deep"
				"STARLESS SPIRE": desired = "spire"
				"VOID CITADEL": desired = "void"
				"ECLIPSE SANCTUM": desired = "eclipse"
				"BLOODSTAR KEEP": desired = "bloodstar"
				"CELESTIAL GRAVE": desired = "celestial"
				_: desired = "dungeon"
	if force or desired != v11_music_context:
		v11_music_context = desired
		release_audio.set_music_context(desired)

# -----------------------------------------------------------------------------
# v1.23 realm identity: the endgame gets its own floor language and silhouettes.
# These are live vector game elements, not screenshot overlays.
# -----------------------------------------------------------------------------

func _draw_room_floor() -> void:
	var area := String(current_room.get("area", "DUNGEON"))
	if not area in V28_REALMS:
		super._draw_room_floor()
		return
	var base := Color("090a18")
	var accent := _v28_realm_accent(area)
	match area:
		"VOID CITADEL": base = Color("080919")
		"ECLIPSE SANCTUM": base = Color("100817")
		"BLOODSTAR KEEP": base = Color("18080d")
		"CELESTIAL GRAVE": base = Color("06111a")
	draw_rect(ARENA, base)
	for row in range(14):
		var y := ARENA.position.y + float(row) * 62.0
		var alpha := 0.05 + float(row % 3) * 0.012
		draw_line(Vector2(ARENA.position.x, y), Vector2(ARENA.end.x, y), Color(accent, alpha), 1.0)
	for col in range(10):
		var x := ARENA.position.x + float(col) * 72.0
		draw_line(Vector2(x, ARENA.position.y), Vector2(x, ARENA.end.y), Color(accent, 0.035), 1.0)
	var center := ARENA.get_center()
	for i in range(5):
		var radius := 118.0 + float(i) * 47.0
		draw_arc(center, radius, elapsed * (0.04 + float(i) * 0.01), elapsed * 0.04 + PI * 1.35 + float(i), 64, Color(accent, 0.10), 2.0)
	match area:
		"VOID CITADEL":
			for i in range(8):
				var a := TAU * float(i) / 8.0 + elapsed * 0.08
				var p := center + Vector2.from_angle(a) * 215.0
				draw_colored_polygon(PackedVector2Array([p+Vector2(0,-9),p+Vector2(6,0),p+Vector2(0,9),p+Vector2(-6,0)]), Color(accent,0.18))
		"ECLIPSE SANCTUM":
			draw_circle(center, 122.0, Color(0,0,0,0.18))
			draw_arc(center, 132.0, -1.3, 1.9, 80, Color("f3b85c"), 5.0)
			draw_arc(center, 146.0, 1.85, 5.0, 80, Color(accent,0.42), 3.0)
		"BLOODSTAR KEEP":
			for i in range(6):
				var a := TAU * float(i) / 6.0
				draw_line(center + Vector2.from_angle(a)*82.0, center + Vector2.from_angle(a)*236.0, Color(accent,0.11), 4.0)
		"CELESTIAL GRAVE":
			for i in range(24):
				var a := TAU * float(i) / 24.0 + elapsed * 0.015
				var r := 85.0 + float((i * 47) % 180)
				draw_circle(center + Vector2.from_angle(a)*r, 1.5 + float(i%3), Color(accent,0.22))
	draw_rect(ARENA, Color(accent,0.16), false, 2.0)

func _draw_room_architecture() -> void:
	var area := String(current_room.get("area", "DUNGEON"))
	if not area in V28_REALMS:
		super._draw_room_architecture()
		return
	var accent := _v28_realm_accent(area)
	for side in [-1.0, 1.0]:
		var x := 54.0 if side < 0.0 else 638.0
		draw_rect(Rect2(x, 205, 28, 750), Color("111525"))
		draw_rect(Rect2(x-7, 205, 42, 14), Color(accent,0.28))
		draw_rect(Rect2(x-7, 941, 42, 14), Color(accent,0.20))
		for y in [290.0, 470.0, 650.0, 830.0]:
			var p := Vector2(x+14.0, y)
			draw_circle(p, 16.0, Color(accent,0.10))
			draw_arc(p, 14.0, elapsed*0.12, elapsed*0.12+TAU, 28, Color(accent,0.55), 2.0)
			draw_colored_polygon(PackedVector2Array([p+Vector2(0,-8),p+Vector2(7,0),p+Vector2(0,8),p+Vector2(-7,0)]), Color(accent,0.45))
	if area == "BLOODSTAR KEEP":
		for x in [112.0, 608.0]:
			draw_colored_polygon(PackedVector2Array([Vector2(x-22,190),Vector2(x+22,190),Vector2(x+16,292),Vector2(x,312),Vector2(x-16,292)]), Color("651726"))
			draw_line(Vector2(x-24,190),Vector2(x+24,190),C_GOLD,3.0)
	elif area == "CELESTIAL GRAVE":
		for x in [118.0, 602.0]:
			for i in range(4):
				draw_arc(Vector2(x,250.0+float(i)*190.0), 26.0, elapsed*0.08+float(i), elapsed*0.08+float(i)+PI*1.5, 30, Color(accent,0.24), 2.0)

func draw_enemy(e: Dictionary) -> void:
	super.draw_enemy(e)
	var kind := String(e.get("type", ""))
	var variant := String(e.get("boss_variant", ""))
	if _v28_is_endgame_kind(kind):
		_v35_draw_enemy_identity(e, kind)
	elif kind == "warden" and variant in ["void_archon", "eclipse_regent", "bloodstar_tyrant", "world_eater"]:
		_v35_draw_boss_identity(e, variant)

func _v35_draw_enemy_identity(e: Dictionary, kind: String) -> void:
	var p: Vector2 = e.get("pos", Vector2.ZERO)
	var r := float(e.get("radius", 24.0))
	var c := _v28_kind_accent(kind)
	var pulse := 1.0 + sin(elapsed*4.0 + float(e.get("phase",0.0))) * 0.08
	draw_circle(p, (r+8.0)*pulse, Color(c,0.08))
	match kind:
		"void_lancer":
			draw_line(p+Vector2(-22,26), p+Vector2(28,-34), c, 5.0)
			draw_line(p+Vector2(18,-27), p+Vector2(35,-44), C_TEXT, 2.0)
		"rift_hound":
			draw_colored_polygon(PackedVector2Array([p+Vector2(-30,-8),p+Vector2(-9,-25),p+Vector2(25,-18),p+Vector2(34,3),p+Vector2(11,18),p+Vector2(-26,15)]), Color(c,0.52))
			draw_circle(p+Vector2(21,-7), 4.0, C_TEXT)
		"soul_cannon":
			draw_rect(Rect2(p-Vector2(30,16),Vector2(60,32)),Color(c,0.32))
			draw_rect(Rect2(p+Vector2(18,-8),Vector2(28,16)),Color(c,0.72))
			draw_circle(p,10.0,C_CYAN)
		"eclipse_oracle":
			draw_arc(p, r+13.0, -1.4, 1.8, 40, C_GOLD, 4.0)
			draw_arc(p, r+18.0, 1.7, 4.9, 40, c, 3.0)
			draw_circle(p,5.0,C_TEXT)
		"shade_duelist":
			draw_line(p+Vector2(-28,26),p+Vector2(20,-30),c,4.0)
			draw_line(p+Vector2(28,26),p+Vector2(-20,-30),C_GOLD,4.0)
		"sunless_guard":
			draw_colored_polygon(PackedVector2Array([p+Vector2(-28,-26),p+Vector2(28,-26),p+Vector2(35,8),p+Vector2(0,39),p+Vector2(-35,8)]),Color(c,0.30))
			draw_arc(p, r+6.0, -2.6, -0.55, 30, C_GOLD, 5.0)
		"blood_seraph":
			for side in [-1.0,1.0]:
				draw_colored_polygon(PackedVector2Array([p+Vector2(side*8,-10),p+Vector2(side*44,-34),p+Vector2(side*34,8),p+Vector2(side*12,24)]),Color(c,0.42))
		"chain_titan":
			for i in range(4):
				var q := p+Vector2(-30+float(i)*20.0,24)
				draw_arc(q,10.0,0,TAU,20,C_GOLD,3.0)
		"hemomancer":
			draw_circle(p-Vector2(0,8),14.0,Color(c,0.35))
			draw_circle(p-Vector2(0,8),6.0,c)
			for a in [0.0,2.1,4.2]:
				draw_line(p+Vector2.from_angle(a)*14.0,p+Vector2.from_angle(a)*34.0,Color(c,0.55),3.0)
		"star_devourer":
			draw_circle(p,r*0.66,Color("010207"))
			draw_arc(p,r+12.0,elapsed*0.5,elapsed*0.5+PI*1.5,42,c,4.0)
		"crownless":
			var crown := PackedVector2Array([p+Vector2(-30,-24),p+Vector2(-19,-48),p+Vector2(-7,-27),p+Vector2(0,-53),p+Vector2(9,-27),p+Vector2(21,-47),p+Vector2(31,-24)])
			draw_polyline(crown,C_GOLD,4.0)
		"cosmic_eye":
			draw_arc(p,r+10.0,0,TAU,40,c,3.0)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-30,0),p+Vector2(0,-16),p+Vector2(30,0),p+Vector2(0,16)]),Color(c,0.42))
			draw_circle(p,7.0,C_TEXT)
			draw_circle(p,3.0,Color("050611"))

func _v35_draw_boss_identity(e: Dictionary, variant: String) -> void:
	var p: Vector2 = e.get("pos", Vector2.ZERO)
	var r := float(e.get("radius", 70.0))
	var c := _v28_boss_accent(variant)
	for i in range(3):
		draw_arc(p,r+16.0+float(i)*10.0,elapsed*(0.18+float(i)*0.05)+float(i),elapsed*(0.18+float(i)*0.05)+float(i)+PI*1.55,64,Color(c,0.30-float(i)*0.06),3.0)
	match variant:
		"void_archon":
			draw_colored_polygon(PackedVector2Array([p+Vector2(0,-46),p+Vector2(24,0),p+Vector2(0,46),p+Vector2(-24,0)]),Color(c,0.35))
		"eclipse_regent":
			draw_circle(p,26.0,Color("020207"))
			draw_arc(p,34.0,-1.35,1.85,40,C_GOLD,7.0)
		"bloodstar_tyrant":
			for i in range(8):
				var a := TAU*float(i)/8.0
				draw_line(p+Vector2.from_angle(a)*28.0,p+Vector2.from_angle(a)*54.0,c,5.0)
		"world_eater":
			draw_circle(p,30.0,Color("010207"))
			for i in range(5):
				var a := elapsed*0.15+TAU*float(i)/5.0
				draw_circle(p+Vector2.from_angle(a)*45.0,5.0,Color(c,0.72))

func draw_game() -> void:
	super.draw_game()
	if state != State.RUNNING or run == null:
		return
	if combo_count >= 5 and combo_timer > 0.0:
		var r := Rect2(262, 970, 196, 30)
		draw_rect(r, Color(0.03,0.04,0.09,0.88))
		draw_rect(r, Color(C_GOLD,0.55), false, 1.5)
		draw_string(v16_body_font, Vector2(r.position.x+6,r.position.y+20), "COMBO x%d" % combo_count, HORIZONTAL_ALIGNMENT_CENTER, r.size.x-12, 12, C_GOLD)
