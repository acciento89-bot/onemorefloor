extends "res://scripts/main_v51.gd"

# ONE MORE FLOOR v1.39 — 3D pivot, phase 2.
# Floors 1-10 now render through a real SubViewport/Node3D chamber while the
# proven gameplay runtime remains authoritative. The 2D HUD, touch controls,
# progression, balance and saves are intentionally unchanged.

const World3DChamber = preload("res://scripts/world3d_chamber.gd")
const V52_VERSION := "1.39.0-first-3d-chamber"
const V52_BUILD := "25-dev"
const V52_PILOT_MIN_FLOOR := 1
const V52_PILOT_MAX_FLOOR := 10

var v52_world_viewport: SubViewport
var v52_world_root
var v52_3d_frames := 0
var v52_last_active := false

func _ready() -> void:
	super._ready()
	_v52_create_world_viewport()
	if telemetry != null:
		telemetry.set_build_context(V52_VERSION, V52_BUILD)
		telemetry.event("first_3d_chamber_ready", {
			"build": V52_BUILD,
			"pilot_floor_min": V52_PILOT_MIN_FLOOR,
			"pilot_floor_max": V52_PILOT_MAX_FLOOR,
			"world_ready": _v52_world_layer_ready(),
		})
	queue_redraw()

func _process(delta: float) -> void:
	super._process(delta)
	_v52_sync_world()

func _v52_create_world_viewport() -> void:
	v52_world_viewport = SubViewport.new()
	v52_world_viewport.name = "Combat3DViewport"
	v52_world_viewport.size = Vector2i(int(ARENA.size.x), int(ARENA.size.y))
	v52_world_viewport.own_world_3d = true
	v52_world_viewport.transparent_bg = false
	v52_world_viewport.disable_3d = false
	v52_world_viewport.msaa_3d = Viewport.MSAA_2X
	v52_world_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(v52_world_viewport)

	v52_world_root = World3DChamber.new()
	v52_world_root.name = "LowerHalls3D"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v52_world_layer_ready() -> bool:
	return v52_world_viewport != null \
		and v52_world_root != null \
		and v52_world_root.has_method("world_ready") \
		and bool(v52_world_root.call("world_ready")) \
		and _v51_menu_foundation_ready()

func _v52_3d_active() -> bool:
	if state != State.RUNNING or run == null:
		return false
	var floor_no := int(run.floor_no)
	return floor_no >= V52_PILOT_MIN_FLOOR and floor_no <= V52_PILOT_MAX_FLOOR

func _v52_sync_world() -> void:
	if v52_world_viewport == null or v52_world_root == null:
		return
	var active := _v52_3d_active()
	v52_world_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if active else SubViewport.UPDATE_DISABLED
	v52_world_root.set_active(active)
	if active:
		var attack_flash := 1.0 if elapsed - float(v47_player_attack_stamp) < 0.10 else 0.0
		var nova_flash := 1.0 if elapsed - float(v47_player_skill_stamp) < 0.16 else 0.0
		v52_world_root.sync_runtime(
			player_pos,
			enemies,
			player_shots,
			enemy_shots,
			coin_orbs,
			joy_vector,
			elapsed,
			attack_flash,
			nova_flash,
			int(run.floor_no)
		)
		v52_3d_frames += 1
	if active != v52_last_active:
		if telemetry != null:
			telemetry.event("combat_renderer_changed", {
				"renderer": "3d_lower_halls" if active else "legacy_2d",
				"floor": int(run.floor_no) if run != null else 0,
			})
		v52_last_active = active
	queue_redraw()

# -----------------------------------------------------------------------------
# 3D pilot presentation.
# Only the arena body is replaced. Existing 2D HUD/input overlays remain on top,
# so this is a renderer swap rather than a gameplay rewrite.
# -----------------------------------------------------------------------------

func draw_game() -> void:
	if not _v52_3d_active() or v52_world_viewport == null:
		super.draw_game()
		return

	var world_texture := v52_world_viewport.get_texture()
	draw_rect(ARENA, Color("05070d"))
	if world_texture != null:
		draw_texture_rect(world_texture, ARENA, false, Color.WHITE)
	else:
		draw_rect(ARENA, Color("11131b"))
	draw_rect(ARENA, Color("cda65f", 0.28), false, 2.0)

	_v52_draw_renderer_badge()
	_draw_combat_hud()
	if loot_notice_time > 0.0:
		_draw_notice(946)
	_v52_draw_chamber_intro()
	_v52_draw_boss_intro()

	# Preserve release overlays exactly where players already expect them.
	if release_paused and not settings_open:
		_draw_pause_overlay()
	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step == 2:
		_draw_tutorial_overlay()

func _v52_draw_renderer_badge() -> void:
	var r := Rect2(236, 145, 248, 28)
	draw_rect(r, Color("05070d", 0.78))
	draw_rect(r, Color("a884d8", 0.32), false, 1.0)
	draw_string(v16_body_font, Vector2(r.position.x + 8, r.position.y + 19), "3D CHAMBER  •  LOWER HALLS", HORIZONTAL_ALIGNMENT_CENTER, r.size.x - 16, 9, Color("c8bdd7"))

func _v52_draw_chamber_intro() -> void:
	if v48_chamber_intro <= 0.0 or run == null:
		return
	var alpha := clampf(v48_chamber_intro, 0.0, 1.0)
	var chamber := String(current_room.get("v48_chamber", _v48_chamber_for_floor(int(run.floor_no))))
	var zone := _v48_zone_for_floor(int(run.floor_no))
	var accent := _v48_zone_accent(zone)
	var r := Rect2(118, 204, 484, 78)
	draw_rect(r, Color("05070d", 0.72 * alpha))
	draw_rect(r, Color(accent, 0.46 * alpha), false, 1.5)
	draw_string(v16_title_font, Vector2(128, 239), chamber, HORIZONTAL_ALIGNMENT_CENTER, 464, 18, Color(V17_IVORY, alpha))
	draw_string(v16_body_font, Vector2(128, 263), V48_ZONES[zone], HORIZONTAL_ALIGNMENT_CENTER, 464, 9, Color(accent, 0.86 * alpha))

func _v52_draw_boss_intro() -> void:
	if boss_intro <= 0.0 or run == null or int(run.floor_no) % 5 != 0:
		return
	var alpha := clampf(boss_intro, 0.0, 1.0)
	var r := Rect2(140, 470, 440, 92)
	draw_rect(r, Color("09070d", 0.76 * alpha))
	draw_rect(r, Color(V16_GOLD, 0.58 * alpha), false, 2.0)
	draw_string(v16_title_font, Vector2(154, 514), "WARDEN FLOOR", HORIZONTAL_ALIGNMENT_CENTER, 412, 23, Color(V17_GOLD_HI, alpha))
	draw_string(v16_body_font, Vector2(154, 541), "The first 3D boss encounter is live.", HORIZONTAL_ALIGNMENT_CENTER, 412, 10, Color(V16_MUTED, alpha))
