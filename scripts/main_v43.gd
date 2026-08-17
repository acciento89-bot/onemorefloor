extends "res://scripts/main_v42.gd"

# ONE MORE FLOOR v1.30 — Endgame Chambers.
# Floors 51+ now have authored realm backplates and deterministic chamber
# identities. Chambers also add a restrained secondary encounter pulse, so the
# environment changes how a floor feels without stacking another full hazard on
# top of the existing realm mechanic.

const V43_VERSION := "1.30.0-endgame-chambers"
const V43_BUILD := "22-dev"
const V43_REALMS := ["VOID CITADEL", "ECLIPSE SANCTUM", "BLOODSTAR KEEP", "CELESTIAL GRAVE"]
const V43_REALM_ART_PATHS := {
	"VOID CITADEL": "res://assets/art/realm_void_citadel_v43.svg",
	"ECLIPSE SANCTUM": "res://assets/art/realm_eclipse_sanctum_v43.svg",
	"BLOODSTAR KEEP": "res://assets/art/realm_bloodstar_keep_v43.svg",
	"CELESTIAL GRAVE": "res://assets/art/realm_celestial_grave_v43.svg",
}

var v43_realm_art: Dictionary = {}
var v43_chamber_intro := 0.0
var v43_chamber_timer := 0.0
var v43_chamber_pulses := 0

func _ready() -> void:
	super._ready()
	for area in V43_REALMS:
		var path := String(V43_REALM_ART_PATHS.get(area, ""))
		if not path.is_empty():
			v43_realm_art[area] = load(path) as Texture2D
	if telemetry != null:
		telemetry.set_build_context(V43_VERSION, V43_BUILD)
	queue_redraw()

func _process(delta: float) -> void:
	super._process(delta)
	v43_chamber_intro = maxf(0.0, v43_chamber_intro - delta)

func spawn_floor() -> void:
	super.spawn_floor()
	v43_chamber_pulses = 0
	if run == null:
		return
	var floor_no := int(run.floor_no)
	var area := String(current_room.get("area", "DUNGEON"))
	if not area in V43_REALMS:
		return
	var chamber := _v43_chamber_for(area, floor_no)
	current_room["chamber"] = chamber
	v43_chamber_intro = 2.35
	v43_chamber_timer = _v43_chamber_cadence(chamber) * 0.72
	# Chambers with an extra encounter pulse return a little more per kill. This
	# keeps the visual/gameplay variation risk-positive instead of punitive.
	if String(current_room.get("type", "COMBAT")) != "BOSS":
		var reward_mult := _v43_chamber_reward_multiplier(chamber)
		for i in range(enemies.size()):
			var e: Dictionary = enemies[i]
			if bool(e.get("v43_chamber_reward", false)):
				continue
			e["reward"] = maxi(1, int(round(float(e.get("reward", 1)) * reward_mult)))
			e["v43_chamber_reward"] = true
			enemies[i] = e

func _v43_chamber_for(area: String, floor_no: int) -> String:
	var chambers: Array[String] = []
	var realm_start := 51
	match area:
		"VOID CITADEL":
			chambers = ["RIFT BRIDGE", "SOUL FOUNDRY", "THRONE APPROACH"]
			realm_start = 51
		"ECLIPSE SANCTUM":
			chambers = ["SUNLESS NAVE", "UMBRA CLOISTER", "CORONA ALTAR"]
			realm_start = 100
		"BLOODSTAR KEEP":
			chambers = ["CHAIN HALL", "CRIMSON COURT", "WAR ALTAR"]
			realm_start = 150
		"CELESTIAL GRAVE":
			chambers = ["ASTRAL OSSUARY", "GRAVITY CHOIR", "WORLDWOUND"]
			realm_start = 200
	if chambers.is_empty():
		return ""
	return chambers[posmod(floor_no - realm_start, chambers.size())]

func _v43_chamber_cadence(chamber: String) -> float:
	match chamber:
		"THRONE APPROACH", "CORONA ALTAR", "WAR ALTAR", "WORLDWOUND": return 5.8
		"SOUL FOUNDRY", "UMBRA CLOISTER", "CRIMSON COURT", "GRAVITY CHOIR": return 6.5
		_: return 7.2

func _v43_chamber_reward_multiplier(chamber: String) -> float:
	match chamber:
		"THRONE APPROACH", "CORONA ALTAR", "WAR ALTAR", "WORLDWOUND": return 1.10
		"SOUL FOUNDRY", "UMBRA CLOISTER", "CRIMSON COURT", "GRAVITY CHOIR": return 1.075
		_: return 1.05

func update_room_hazard(delta: float) -> void:
	super.update_room_hazard(delta)
	if state != State.RUNNING or run == null:
		return
	var area := String(current_room.get("area", ""))
	if not area in V43_REALMS or String(current_room.get("type", "")) == "BOSS":
		return
	v43_chamber_timer -= delta
	if v43_chamber_timer > 0.0:
		return
	var chamber := String(current_room.get("chamber", _v43_chamber_for(area, int(run.floor_no))))
	_v43_fire_chamber_pulse(chamber, area)
	v43_chamber_pulses += 1
	v43_chamber_timer = _v43_chamber_cadence(chamber)

func _v43_fire_chamber_pulse(chamber: String, area: String) -> void:
	var floor_no := float(run.floor_no)
	var dmg := 8.0 + floor_no * 0.12
	var accent := _v28_realm_accent(area)
	var center := ARENA.get_center()
	match chamber:
		"RIFT BRIDGE":
			for y in [430.0, 760.0]:
				_v43_shot(Vector2(ARENA.position.x + 8.0, y), Vector2.RIGHT * 245.0, dmg, accent)
				_v43_shot(Vector2(ARENA.end.x - 8.0, y + 70.0), Vector2.LEFT * 245.0, dmg, accent)
		"SOUL FOUNDRY":
			for x in [160.0, 240.0, 324.0, 408.0, 488.0]:
				_v43_shot(Vector2(x, ARENA.position.y + 8.0), Vector2(0.0, 255.0), dmg, C_CYAN, 3.4)
		"THRONE APPROACH":
			var aim := (player_pos - center).normalized()
			for spread in [-0.30, -0.10, 0.10, 0.30]:
				var dir := aim.rotated(float(spread))
				_v43_shot(center + dir * 52.0, dir * 285.0, dmg * 1.05, accent)
		"SUNLESS NAVE":
			for y in [380.0, 650.0, 890.0]:
				var from_left := int(y) % 2 == 0
				var start := Vector2(ARENA.position.x + 8.0 if from_left else ARENA.end.x - 8.0, y)
				_v43_shot(start, (Vector2.RIGHT if from_left else Vector2.LEFT) * 265.0, dmg, C_GOLD)
		"UMBRA CLOISTER":
			for n in range(6):
				var a := TAU * float(n) / 6.0 + elapsed * 0.18
				var start := center + Vector2.from_angle(a) * 350.0
				_v43_shot(start, (center - start).normalized() * 240.0, dmg, C_PURPLE, 3.3)
		"CORONA ALTAR":
			for n in range(8):
				var dir := Vector2.from_angle(TAU * float(n) / 8.0 + elapsed * 0.24)
				_v43_shot(center + dir * 48.0, dir * 255.0, dmg * 1.04, C_GOLD, 3.2)
		"CHAIN HALL":
			for y in [350.0, 540.0, 730.0, 920.0]:
				var from_left := int(y / 10.0) % 2 == 1
				var start := Vector2(ARENA.position.x + 8.0 if from_left else ARENA.end.x - 8.0, y)
				_v43_shot(start, (Vector2.RIGHT if from_left else Vector2.LEFT) * 275.0, dmg, C_RED)
		"CRIMSON COURT":
			for n in range(6):
				var x := 112.0 + float(n) * 86.0
				_v43_shot(Vector2(x, ARENA.position.y + 8.0), Vector2(18.0 if n % 2 == 0 else -18.0, 285.0), dmg, C_RED, 3.1)
		"WAR ALTAR":
			for n in range(10):
				var dir := Vector2.from_angle(TAU * float(n) / 10.0 + 0.16)
				_v43_shot(center + dir * 54.0, dir * 240.0, dmg * 1.05, C_RED, 3.4)
		"ASTRAL OSSUARY":
			for n in range(5):
				var start := Vector2(100.0 + float(n) * 112.0, ARENA.position.y + 10.0)
				_v43_shot(start, Vector2(-35.0 + float(n) * 17.0, 295.0), dmg, C_CYAN, 3.2)
		"GRAVITY CHOIR":
			for n in range(8):
				var a := TAU * float(n) / 8.0 + elapsed * 0.12
				var start := center + Vector2.from_angle(a) * 360.0
				_v43_shot(start, (center - start).normalized() * 235.0, dmg, accent, 3.5)
		"WORLDWOUND":
			for n in range(10):
				var dir := Vector2.from_angle(TAU * float(n) / 10.0 + elapsed * 0.42)
				_v43_shot(center + dir * 42.0, dir * 270.0, dmg * 1.06, C_CYAN if n % 2 == 0 else C_PURPLE, 3.2)

func _v43_shot(pos: Vector2, velocity: Vector2, damage_value: float, color: Color, life: float = 3.0) -> void:
	enemy_shots.append({
		"pos": pos,
		"vel": velocity,
		"damage": damage_value,
		"life": life,
		"color": color,
		"v43_chamber": true,
	})

# -----------------------------------------------------------------------------
# Authored realm environments + chamber-specific architectural dressing.
# -----------------------------------------------------------------------------

func _draw_room_floor() -> void:
	var area := String(current_room.get("area", "DUNGEON"))
	if not area in V43_REALMS:
		super._draw_room_floor()
		return
	var tex := v43_realm_art.get(area) as Texture2D
	if tex == null:
		super._draw_room_floor()
		return
	draw_texture_rect(tex, ARENA, false, Color.WHITE)
	var chamber := String(current_room.get("chamber", _v43_chamber_for(area, int(run.floor_no) if run != null else 51)))
	_v43_draw_chamber_floor(chamber, _v28_realm_accent(area))
	# Subtle edge falloff keeps bullets/actors readable over the authored art.
	draw_rect(Rect2(ARENA.position, Vector2(34.0, ARENA.size.y)), Color(0, 0, 0, 0.18))
	draw_rect(Rect2(Vector2(ARENA.end.x - 34.0, ARENA.position.y), Vector2(34.0, ARENA.size.y)), Color(0, 0, 0, 0.18))
	draw_rect(ARENA, Color(_v28_realm_accent(area), 0.22), false, 2.0)

func _v43_draw_chamber_floor(chamber: String, accent: Color) -> void:
	var c := ARENA.get_center()
	match chamber:
		"RIFT BRIDGE":
			draw_colored_polygon(PackedVector2Array([Vector2(235, ARENA.end.y), Vector2(282, 535), Vector2(366, 535), Vector2(413, ARENA.end.y)]), Color(accent, 0.055))
		"SOUL FOUNDRY":
			for x in [170.0, 478.0]:
				draw_circle(Vector2(x, 790), 72.0, Color(0,0,0,0.34))
				draw_arc(Vector2(x, 790), 64.0, 0, TAU, 48, Color(C_CYAN, 0.26), 4.0)
				draw_circle(Vector2(x, 790), 30.0, Color(C_PURPLE, 0.12))
		"THRONE APPROACH":
			draw_colored_polygon(PackedVector2Array([Vector2(268, ARENA.end.y), Vector2(296, 465), Vector2(352, 465), Vector2(380, ARENA.end.y)]), Color(accent, 0.11))
			for y in [520.0, 590.0, 660.0, 730.0, 800.0, 870.0]:
				draw_line(Vector2(244, y), Vector2(404, y), Color(accent, 0.14), 2.0)
		"SUNLESS NAVE":
			for x in [196.0, 324.0, 452.0]:
				draw_arc(Vector2(x, 565), 54.0, PI, TAU, 32, Color(C_GOLD, 0.16), 3.0)
		"UMBRA CLOISTER":
			for x in [152.0, 496.0]:
				for y in [430.0, 640.0, 850.0]:
					draw_arc(Vector2(x, y), 42.0, PI, TAU, 28, Color(accent, 0.22), 3.0)
		"CORONA ALTAR":
			draw_circle(c, 112.0, Color(0,0,0,0.14))
			draw_arc(c, 118.0, -1.25, 1.90, 64, Color(C_GOLD, 0.38), 5.0)
			draw_arc(c, 132.0, 1.78, 5.02, 64, Color(accent, 0.34), 4.0)
		"CHAIN HALL":
			for side in [112.0, 536.0]:
				for y in range(330, 930, 70):
					draw_arc(Vector2(side, float(y)), 16.0, 0, TAU, 20, Color(accent, 0.26), 3.0)
		"CRIMSON COURT":
			draw_colored_polygon(PackedVector2Array([Vector2(250, 520), Vector2(398, 520), Vector2(430, ARENA.end.y), Vector2(218, ARENA.end.y)]), Color(C_RED, 0.07))
		"WAR ALTAR":
			for n in range(5):
				var a := -PI * 0.5 + TAU * float(n) / 5.0
				var b := -PI * 0.5 + TAU * float((n * 2) % 5) / 5.0
				draw_line(c + Vector2.from_angle(a) * 104.0, c + Vector2.from_angle(b) * 104.0, Color(accent, 0.22), 4.0)
		"ASTRAL OSSUARY":
			for x in [160.0, 218.0, 430.0, 488.0]:
				draw_colored_polygon(PackedVector2Array([Vector2(x-14, 735), Vector2(x, 688), Vector2(x+14, 735), Vector2(x+9, 812), Vector2(x-9, 812)]), Color(accent, 0.12))
		"GRAVITY CHOIR":
			for radius in [72.0, 118.0, 166.0]:
				draw_arc(c, radius, elapsed * 0.04, elapsed * 0.04 + TAU, 64, Color(accent, 0.13), 2.0)
		"WORLDWOUND":
			for n in range(12):
				var dir := Vector2.from_angle(TAU * float(n) / 12.0)
				draw_line(c + dir * 62.0, c + dir * (128.0 + float(n % 3) * 28.0), Color(accent, 0.18), 2.0)

func _draw_room_architecture() -> void:
	var area := String(current_room.get("area", "DUNGEON"))
	if not area in V43_REALMS:
		super._draw_room_architecture()
		return
	var chamber := String(current_room.get("chamber", _v43_chamber_for(area, int(run.floor_no) if run != null else 51)))
	var accent := _v28_realm_accent(area)
	# Foreground silhouettes create depth without obscuring the playable center.
	for side in [-1.0, 1.0]:
		var x := 56.0 if side < 0.0 else 664.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 26.0 * side, 176),
			Vector2(x - 8.0 * side, 176),
			Vector2(x + 14.0 * side, 990),
			Vector2(x - 38.0 * side, 990),
		]), Color(0.018, 0.020, 0.030, 0.82))
		draw_line(Vector2(x, 200), Vector2(x + 8.0 * side, 954), Color(accent, 0.20), 2.0)
	if chamber in ["SOUL FOUNDRY", "WAR ALTAR", "WORLDWOUND"]:
		for p in [Vector2(116, 930), Vector2(604, 930)]:
			draw_circle(p, 24.0, Color(accent, 0.09))
			draw_arc(p, 21.0, elapsed * 0.18, elapsed * 0.18 + TAU, 28, Color(accent, 0.42), 2.0)
	elif chamber in ["UMBRA CLOISTER", "CRIMSON COURT", "ASTRAL OSSUARY"]:
		for p in [Vector2(118, 340), Vector2(602, 340)]:
			draw_line(p, p + Vector2(0, 150), Color(accent, 0.18), 5.0)
			draw_colored_polygon(PackedVector2Array([p+Vector2(-22,38), p+Vector2(22,38), p+Vector2(14,126), p+Vector2(0,146), p+Vector2(-14,126)]), Color(accent, 0.12))

func draw_game() -> void:
	super.draw_game()
	if run == null or v43_chamber_intro <= 0.0:
		return
	var area := String(current_room.get("area", ""))
	if not area in V43_REALMS:
		return
	var chamber := String(current_room.get("chamber", _v43_chamber_for(area, int(run.floor_no))))
	var alpha := clampf(v43_chamber_intro / 0.75, 0.0, 1.0)
	var plate := Rect2(142, 378, 436, 70)
	draw_rect(plate, Color(0.01, 0.012, 0.022, 0.68 * alpha))
	draw_rect(plate, Color(_v28_realm_accent(area), 0.42 * alpha), false, 2.0)
	draw_string(v16_title_font, Vector2(154, 408), chamber, HORIZONTAL_ALIGNMENT_CENTER, 412, 20, Color(V17_IVORY, alpha))
	draw_string(v16_body_font, Vector2(154, 432), area, HORIZONTAL_ALIGNMENT_CENTER, 412, 11, Color(V16_MUTED, alpha))

func _v43_endgame_chambers_ready() -> bool:
	if v43_realm_art.size() != 4:
		return false
	for area in V43_REALMS:
		if not (v43_realm_art.get(area) is Texture2D):
			return false
	return _v43_chamber_for("VOID CITADEL", 51) == "RIFT BRIDGE" and _v43_chamber_for("CELESTIAL GRAVE", 202) == "WORLDWOUND"
