extends "res://scripts/main_v50.gd"

# ONE MORE FLOOR v1.38 — Combat Production Pass.
# Visual-only pass over the proven v1.37 release-candidate runtime. The goal is
# to push moment-to-moment combat away from a flat prototype look without
# touching collision, damage, enemy AI, progression, rewards, save data or IAP.

const V51_VERSION := "1.38.0-combat-production-pass"
const V51_BUILD := "24-dev"

var v51_enemy_draws := 0
var v51_projectile_draws := 0

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V51_VERSION, V51_BUILD)
		telemetry.event("combat_production_pass_ready", {
			"build": V51_BUILD,
			"release_candidate_base": _v50_release_candidate_ready(),
		})
	queue_redraw()

func _v51_combat_presentation_ready() -> bool:
	return _v50_release_candidate_ready() \
		and v47_player_atlas != null \
		and v47_tower_atlas != null \
		and v47_projectile_atlas != null \
		and v48_environment_atlas != null

# -----------------------------------------------------------------------------
# Arena depth.
# Contact shadows and restrained foreground haze make actors sit inside the room
# instead of appearing pasted over it. All additions are cosmetic.
# -----------------------------------------------------------------------------

func _draw_room_floor() -> void:
	super._draw_room_floor()
	if not _v48_foundation_floor_active():
		return
	var zone := _v48_zone_for_floor(int(run.floor_no))
	var accent := _v48_zone_accent(zone)
	var c := ARENA.get_center()

	# Long low-opacity perspective bands add depth while keeping collision space
	# visually clean and preserving the authored v1.35 chamber art.
	for n in range(4):
		var inset := 22.0 + float(n) * 31.0
		var alpha := 0.018 + float(n) * 0.006
		draw_line(
			Vector2(ARENA.position.x + inset, ARENA.end.y - 8.0),
			Vector2(c.x - 76.0 + float(n) * 18.0, ARENA.position.y + 110.0),
			Color(accent, alpha), 2.0
		)
		draw_line(
			Vector2(ARENA.end.x - inset, ARENA.end.y - 8.0),
			Vector2(c.x + 76.0 - float(n) * 18.0, ARENA.position.y + 110.0),
			Color(accent, alpha), 2.0
		)

	# Floor contact pool under the central combat area. Very subtle by design.
	draw_circle(c + Vector2(0, 168), 188.0, Color(accent, 0.018))
	draw_arc(c + Vector2(0, 168), 188.0, PI * 0.10, PI * 0.90, 48, Color(accent, 0.075), 2.0)

func _draw_room_architecture() -> void:
	super._draw_room_architecture()
	if not _v48_foundation_floor_active():
		return
	var zone := _v48_zone_for_floor(int(run.floor_no))
	var accent := _v48_zone_accent(zone)
	# Soft edge haze produces foreground separation without obscuring enemies.
	for side in [-1.0, 1.0]:
		var x := ARENA.position.x + 18.0 if side < 0.0 else ARENA.end.x - 18.0
		for n in range(3):
			var y := ARENA.position.y + 165.0 + float(n) * 245.0
			var r := 42.0 + float((zone + n) % 2) * 12.0
			draw_circle(Vector2(x, y), r, Color(accent, 0.020 + float(n) * 0.006))

# -----------------------------------------------------------------------------
# Actor grounding and presence.
# Visual radius is intentionally a little larger than collision radius. The
# original enemy dictionary is never mutated, so combat math remains identical.
# -----------------------------------------------------------------------------

func draw_enemy(e: Dictionary) -> void:
	var p: Vector2 = e.get("pos", Vector2.ZERO)
	var radius := float(e.get("radius", 24.0))
	var actor_id := _v47_actor_id(e) if _v47_has_actor(e) else String(e.get("type", ""))
	var accent := _v47_accent(actor_id) if _v47_has_actor(e) else C_GOLD
	var boss := _v47_is_boss(e) if _v47_has_actor(e) else false
	var elite := bool(e.get("elite", false))
	var bounty := bool(e.get("bounty_target", false))

	_v51_draw_contact_shadow(p, radius * (1.45 if boss else 1.10), accent, 0.14 if boss else 0.09)
	if elite or bounty or boss:
		_v51_draw_rank_presence(p, radius, accent, elite, bounty, boss)

	var visual := e.duplicate(true)
	visual["radius"] = radius * (1.10 if boss else 1.075)
	super.draw_enemy(visual)
	v51_enemy_draws += 1

	# Tiny light-catching rim below the feet makes silhouettes feel attached to
	# the environment instead of floating over the floor texture.
	draw_arc(p + Vector2(0, radius * 0.82), radius * 0.72, 0.10, PI - 0.10, 20, Color(accent, 0.15), 1.5)

func _v51_draw_contact_shadow(p: Vector2, radius: float, accent: Color, strength: float) -> void:
	var shadow_center := p + Vector2(0, radius * 0.72)
	for n in range(3):
		var spread := 1.0 + float(n) * 0.20
		var alpha := strength * (0.52 - float(n) * 0.13)
		draw_set_transform(shadow_center, 0.0, Vector2(1.55 * spread, 0.50 * spread))
		draw_circle(Vector2.ZERO, radius * 0.72, Color(0.0, 0.0, 0.0, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# One faint colored bounce line prevents the shadow from turning into a blob.
	draw_arc(shadow_center, radius * 0.92, 0.12, PI - 0.12, 22, Color(accent, strength * 0.42), 1.0)

func _v51_draw_rank_presence(p: Vector2, radius: float, accent: Color, elite: bool, bounty: bool, boss: bool) -> void:
	var ring_r := radius * (1.82 if boss else 1.52) + 7.0
	var spin := elapsed * (0.22 if boss else 0.40)
	var ring_color := Color(C_GOLD, 0.76) if elite or bounty else Color(accent, 0.72)
	draw_arc(p, ring_r, spin, spin + PI * 0.56, 24, ring_color, 2.2)
	draw_arc(p, ring_r, spin + PI, spin + PI * 1.56, 24, Color(ring_color, 0.42), 1.5)
	if boss:
		draw_arc(p, ring_r + 8.0, -spin * 0.72, -spin * 0.72 + PI * 1.34, 36, Color(accent, 0.24), 2.0)

	# Minimal rank crest. No new hit target and no input behavior.
	var crest_y := p.y - radius * (2.15 if boss else 1.95) - 12.0
	var crest := PackedVector2Array([
		Vector2(p.x, crest_y - 7.0),
		Vector2(p.x + 7.0, crest_y),
		Vector2(p.x, crest_y + 7.0),
		Vector2(p.x - 7.0, crest_y),
	])
	draw_colored_polygon(crest, Color(C_GOLD, 0.86) if elite or bounty else Color(accent, 0.80))
	draw_polyline(PackedVector2Array([crest[0], crest[1], crest[2], crest[3], crest[0]]), Color(1,1,1,0.32), 1.0)

func draw_wanderer(pos: Vector2, scale: float, combat: bool) -> void:
	if combat:
		var moving := joy_vector.length_squared() > 0.03
		var skill_ready := run != null and float(run.skill_cd) <= 0.0
		_v51_draw_contact_shadow(pos, 31.0 * scale, C_PURPLE, 0.10)
		if moving:
			var dir := joy_vector.normalized()
			for n in range(3):
				var lateral := dir.orthogonal() * (float(n) - 1.0) * 8.0
				draw_line(pos - dir * (24.0 + float(n) * 7.0) + lateral, pos - dir * 8.0 + lateral, Color(C_PURPLE, 0.10 + float(n) * 0.035), 2.0)
		if skill_ready:
			var pulse := 0.5 + 0.5 * sin(elapsed * 2.4)
			draw_arc(pos, 43.0 * scale + pulse * 2.5, elapsed * 0.32, elapsed * 0.32 + PI * 1.30, 30, Color(C_PURPLE, 0.12 + pulse * 0.10), 2.0)
		super.draw_wanderer(pos, scale * 1.08, combat)
		return
	super.draw_wanderer(pos, scale, combat)

# -----------------------------------------------------------------------------
# Projectile language.
# Short trails make direction and speed readable on a phone without changing any
# projectile position, velocity, radius, collision or lifetime.
# -----------------------------------------------------------------------------

func draw_player_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot.get("pos", Vector2.ZERO)
	var vel: Vector2 = shot.get("vel", Vector2.RIGHT)
	var dir := vel.normalized() if vel.length_squared() > 1.0 else Vector2.RIGHT
	var crit := bool(shot.get("crit", false))
	var trail_color := V17_GOLD_HI if crit else C_CYAN
	for n in range(3):
		var start := p - dir * (11.0 + float(n) * 9.0)
		var finish := p - dir * (3.0 + float(n) * 4.0)
		draw_line(start, finish, Color(trail_color, 0.20 - float(n) * 0.045), 3.0 - float(n) * 0.5)
	super.draw_player_projectile(shot)
	v51_projectile_draws += 1

func draw_enemy_projectile(shot: Dictionary) -> void:
	var p: Vector2 = shot.get("pos", Vector2.ZERO)
	var vel: Vector2 = shot.get("vel", Vector2.ZERO)
	var c: Color = shot.get("color", C_CYAN)
	if vel.length_squared() > 1.0:
		var dir := vel.normalized()
		for n in range(2):
			draw_line(p - dir * (12.0 + float(n) * 10.0), p - dir * (3.0 + float(n) * 5.0), Color(c, 0.16 - float(n) * 0.045), 2.5 - float(n) * 0.6)
	super.draw_enemy_projectile(shot)
	v51_projectile_draws += 1

func draw_coin_orb(orb: Dictionary) -> void:
	var p: Vector2 = orb.get("pos", Vector2.ZERO)
	_v51_draw_contact_shadow(p + Vector2(0, 4), 10.0, V17_GOLD_HI, 0.055)
	super.draw_coin_orb(orb)
