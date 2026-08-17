extends "res://scripts/main_v36.gd"

# v1.25 — visual identity packs.
# This is a live renderer feature, not screenshot art: reaching deep-tower
# milestones unlocks cosmetic UI/arena palettes that can be selected in Settings.

const VisualPackManager = preload("res://scripts/visual_pack_manager.gd")
const V37_VERSION := "1.25.0-visual-packs"
const V37_BUILD := "18"
const V37_PACK_SELECTOR := Rect2(96, 724, 528, 52)

var visual_pack

func _ready() -> void:
	super._ready()
	visual_pack = VisualPackManager.new()
	visual_pack.load_data(int(meta.best_floor))
	if telemetry != null:
		telemetry.set_build_context(V37_VERSION, V37_BUILD)
		telemetry.event("visual_pack_ready", {
			"pack": visual_pack.selected,
			"unlocked": visual_pack.unlocked_count(),
			"best_floor": int(meta.best_floor)
		})
	queue_redraw()

func spawn_floor() -> void:
	super.spawn_floor()
	if visual_pack == null or run == null:
		return
	var previous_count: int = int(visual_pack.unlocked_count())
	visual_pack.refresh_unlocks(maxi(int(meta.best_floor), int(run.floor_no)))
	var current_count: int = int(visual_pack.unlocked_count())
	if current_count > previous_count:
		visual_pack.selected = visual_pack.highest_unlocked()
		visual_pack.save_data()
		loot_notice = "GRAPHICS PACK UNLOCKED — %s" % visual_pack.label()
		loot_notice_color = visual_pack.primary()
		loot_notice_time = 2.8
		_audio("milestone")
		if telemetry != null:
			telemetry.event("visual_pack_unlock", {
				"pack": visual_pack.selected,
				"floor": int(run.floor_no),
				"unlocked": current_count
			})

# -----------------------------------------------------------------------------
# Global menu identity. Every inherited menu still uses the same working live
# controls, but the selected graphics pack changes ambient hue and ornaments.
# -----------------------------------------------------------------------------

func _v16_backdrop(kind: String = "arcane", dim: float = 0.0) -> void:
	super._v16_backdrop(kind, dim)
	if visual_pack == null:
		return
	var p: Color = Color(visual_pack.primary())
	var s: Color = Color(visual_pack.secondary())
	# A very light tint keeps text and button contrast unchanged.
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(p, 0.025))
	_v37_corner_runes(p, s)

func _v37_corner_runes(primary: Color, secondary: Color) -> void:
	var centers: Array[Vector2] = [Vector2(52,148), Vector2(668,148), Vector2(52,1126), Vector2(668,1126)]
	for i in range(centers.size()):
		var c: Vector2 = centers[i]
		var flip: float = -1.0 if i % 2 == 0 else 1.0
		draw_arc(c, 31.0, -1.3 + elapsed*0.025*flip, 1.3 + elapsed*0.025*flip, 24, Color(primary,0.24), 1.5)
		draw_arc(c, 22.0, 1.8 - elapsed*0.018*flip, 4.5 - elapsed*0.018*flip, 20, Color(secondary,0.15), 1.0)
		var gem: Vector2 = c + Vector2(0,-31)
		draw_colored_polygon(PackedVector2Array([
			gem+Vector2(0,-5), gem+Vector2(4,0), gem+Vector2(0,5), gem+Vector2(-4,0)
		]), Color(primary,0.65))

func draw_home() -> void:
	super.draw_home()
	if home_overlay != "" or settings_open or tutorial_active or visual_pack == null:
		return
	# Tiny visual signature only; no extra button clutter on Home.
	var p: Color = Color(visual_pack.primary())
	var s: Color = Color(visual_pack.secondary())
	var c: Vector2 = Vector2(360, 1193)
	draw_colored_polygon(PackedVector2Array([
		c+Vector2(0,-9), c+Vector2(8,0), c+Vector2(0,9), c+Vector2(-8,0)
	]), Color(p,0.86))
	draw_circle(c, 2.5, s)

# -----------------------------------------------------------------------------
# Combat pack accents: keep the HUD readable and only skin the arena boundary,
# NOVA ring and corner glyphs. Realm mechanics remain the dominant combat cue.
# -----------------------------------------------------------------------------

func draw_game() -> void:
	super.draw_game()
	if visual_pack == null or settings_open or release_paused:
		return
	var p: Color = Color(visual_pack.primary())
	var s: Color = Color(visual_pack.secondary())
	draw_rect(ARENA.grow(-3), Color(p,0.18), false, 2.0)
	var corners: Array[Vector2] = [
		ARENA.position+Vector2(18,18),
		Vector2(ARENA.end.x-18,ARENA.position.y+18),
		Vector2(ARENA.position.x+18,ARENA.end.y-18),
		ARENA.end-Vector2(18,18)
	]
	for c: Vector2 in corners:
		draw_colored_polygon(PackedVector2Array([
			c+Vector2(0,-6), c+Vector2(6,0), c+Vector2(0,6), c+Vector2(-6,0)
		]), Color(p,0.56))
	# Secondary ring around the skill button gives the pack a visible gameplay cue.
	draw_arc(SKILL.get_center(), 62.0, elapsed*0.12, elapsed*0.12+TAU, 48, Color(s,0.25), 1.5)

# -----------------------------------------------------------------------------
# Settings — graphics packs are real unlockable cosmetics, selected here.
# Existing audio/privacy/tutorial controls retain their established hitboxes.
# -----------------------------------------------------------------------------

func _draw_settings_overlay() -> void:
	super._draw_settings_overlay()
	if visual_pack == null:
		return
	var p: Color = Color(visual_pack.primary())
	var next_floor: int = int(visual_pack.next_unlock_floor())
	# Fill the deliberate gap between Replay Tutorial and Back.
	draw_rect(V37_PACK_SELECTOR, Color("070b14"))
	draw_rect(V37_PACK_SELECTOR, Color(p,0.46), false, 1.5)
	_v16_medallion(Vector2(V37_PACK_SELECTOR.position.x+31,V37_PACK_SELECTOR.get_center().y), 16, p, 1)
	_v16_text("GRAPHICS PACK", Vector2(V37_PACK_SELECTOR.position.x+58,V37_PACK_SELECTOR.position.y+23), 11, V16_MUTED, true)
	_v16_text(String(visual_pack.label()), Vector2(V37_PACK_SELECTOR.position.x+58,V37_PACK_SELECTOR.position.y+43), 15, V17_IVORY, true)
	var status: String = "%d/5" % int(visual_pack.unlocked_count())
	if next_floor > 0:
		status += "  •  NEXT F%d" % next_floor
	draw_string(v16_body_font, Vector2(V37_PACK_SELECTOR.end.x-188,V37_PACK_SELECTOR.position.y+33), status, HORIZONTAL_ALIGNMENT_RIGHT, 166, 10, Color(p,0.92))

func _pointer_settings(pos: Vector2) -> void:
	if V37_PACK_SELECTOR.has_point(pos) and visual_pack != null:
		visual_pack.refresh_unlocks(int(meta.best_floor))
		visual_pack.cycle(1)
		loot_notice = "GRAPHICS PACK — %s" % visual_pack.label()
		loot_notice_color = visual_pack.primary()
		loot_notice_time = 1.5
		_audio("menu")
		haptic(12)
		if telemetry != null:
			telemetry.event("visual_pack_select", {"pack": visual_pack.selected})
		queue_redraw()
		return
	super._pointer_settings(pos)
