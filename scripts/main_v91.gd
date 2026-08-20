extends "res://scripts/main_v90.gd"

# ONE MORE FLOOR v1.67 — Frontend Completion r1.2 visual finish.
# Final capture-driven menu pass before shifting the completion focus to actor
# quality. Interaction rectangles and progression authority remain inherited.

const FrontendMenuStageR12 = preload("res://scripts/menu3d_stage_v167_completion_r12.gd")
const V91_FRONTEND_VISUAL := "1.67-frontend-visual-r1.2"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.event("frontend_visual_v167_r12_ready", _v91_frontend_snapshot())

func _v70_create_menu_3d() -> void:
	v70_menu_viewport = SubViewport.new()
	v70_menu_viewport.name = "Menu3DViewport"
	v70_menu_viewport.size = Vector2i(int(SIZE.x), int(SIZE.y))
	v70_menu_viewport.own_world_3d = true
	v70_menu_viewport.transparent_bg = false
	v70_menu_viewport.disable_3d = false
	v70_menu_viewport.msaa_3d = Viewport.MSAA_2X
	v70_menu_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(v70_menu_viewport)

	v70_menu_stage = FrontendMenuStageR12.new()
	v70_menu_stage.name = "FrontendCompletionR12MenuStage"
	v70_menu_viewport.add_child(v70_menu_stage)

func _v91_frontend_finish_ready() -> bool:
	if not _v90_menu_visual_completion_ready() or v70_menu_stage == null:
		return false
	if not v70_menu_stage.has_method("frontend_completion_ready"):
		return false
	if not bool(v70_menu_stage.call("frontend_completion_ready")):
		return false
	var snapshot: Dictionary = v70_menu_stage.call("debug_snapshot")
	return String(snapshot.get("frontend_completion_version", "")) == "1.67-frontend-completion-r1.2"

func _v91_frontend_snapshot() -> Dictionary:
	return {
		"ready": _v91_frontend_finish_ready(),
		"version": V91_FRONTEND_VISUAL,
		"talent_tree_composition": true,
		"mission_contract_composition": true,
		"forge_authored_workshop_r12": true,
		"shared_gameplay_wanderer": _v89_frontend_completion_ready(),
	}

func draw_forge_screen() -> void:
	_v16_header("FORGE", "Temper the Wanderer's weapon", V16_ORANGE, 7, "forge")
	_v15_soft_glow(Vector2(360, 508), 132.0, V16_ORANGE, 0.10)

	var card := Rect2(120, 754, 480, 168)
	_v76_surface(card, V16_ORANGE, Color("090909"), 0.18, false)
	_v16_center("FORGE LEVEL %d" % int(meta.forge_level), 793, 24, V17_IVORY, true)
	_v16_center("MASTERWORK POWER", 824, 9, V16_MUTED, true)
	_v16_center("+%.1f%% DAMAGE" % (float(meta.forge_level) * 8.5), 875, 31, V17_GOLD_HI, true)
	_v16_button(V19_FORGE_BUY, "TEMPER  %d" % int(meta.forge_cost()), V16_ORANGE, 24, 11, meta.coins >= meta.forge_cost())
	_v16_center("Each temper permanently strengthens the Wanderer's weapon.", 1094, 11, V16_MUTED)

func draw_talents_screen() -> void:
	if v31_mastery_open:
		_v16_backdrop("arcane")
		_v31_draw_mastery_overlay()
		return

	_v16_header("TALENTS", "Permanent passive bonuses", V16_PURPLE, 1, "arcane")
	_v36_draw_ascension_summary()

	var rows: Array = [
		{"name":"VITALITY", "kind":"vitality", "level":meta.vitality_level, "desc":"+12 starting HP / level", "color":V16_GREEN, "icon":0},
		{"name":"PRECISION", "kind":"precision", "level":meta.precision_level, "desc":"+1.8% starting crit / level", "color":V16_PURPLE, "icon":1},
		{"name":"FORTUNE", "kind":"fortune", "level":meta.fortune_level, "desc":"+6% coin drops / level", "color":V16_GOLD, "icon":11},
	]

	var spine_x := 102.0
	draw_line(Vector2(spine_x, 438.0), Vector2(spine_x, 944.0), Color(V16_PURPLE, 0.30), 3.0, true)

	for i in range(rows.size()):
		var row: Dictionary = rows[i]
		var hit: Rect2 = talent_rect(i)
		var accent: Color = row["color"]
		var node := Vector2(spine_x, hit.get_center().y)
		var visual := Rect2(hit.position + Vector2(88.0, 14.0), Vector2(hit.size.x - 96.0, hit.size.y - 28.0))

		draw_line(node, Vector2(visual.position.x, node.y), Color(accent, 0.52), 2.0, true)
		draw_circle(node, 31.0, Color("070b13"))
		draw_arc(node, 31.0, 0.0, TAU, 40, Color(accent, 0.76), 2.0)
		_v16_medallion(node, 22.0, accent, int(row["icon"]))

		_v76_surface(visual, accent, Color("080c14"), 0.12, false)
		draw_line(Vector2(visual.position.x + 18.0, visual.position.y + 3.0), Vector2(visual.position.x + 94.0, visual.position.y + 3.0), Color(accent, 0.88), 2.0, true)
		_v16_text(String(row["name"]), visual.position + Vector2(24.0, 42.0), 22, V17_IVORY, true)
		_v16_text("RANK %d" % int(row["level"]), visual.position + Vector2(24.0, 68.0), 9, accent, true)
		_v16_text(String(row["desc"]), visual.position + Vector2(24.0, 94.0), 11, V16_MUTED)

		var cost: int = int(meta.talent_cost(String(row["kind"])))
		var buy := Rect2(hit.end.x - 214.0, hit.position.y + 51.0, 188.0, 68.0)
		_v16_button(buy, "UPGRADE  %d" % cost, accent, 13, 11, meta.coins >= cost)

func draw_missions_screen() -> void:
	_v16_header("MISSIONS", "Rotating daily and weekly contracts", V16_GREEN, 0, "arcane")

	_v16_text("DAILY CONTRACTS", Vector2(54, 244), 14, V16_GREEN, true)
	draw_line(Vector2(74, 276), Vector2(74, 530), Color(V16_GREEN, 0.22), 3.0, true)
	var daily: Array = missions.all_daily()
	for i in range(mini(3, daily.size())):
		_v91_draw_contract(daily[i], DAILY_ROWS[i], false, i)

	_draw_completion_v34(DAILY_CHEST, false)

	_v16_text("WEEKLY CONTRACTS", Vector2(54, 670), 14, V16_PURPLE_HI, true)
	draw_line(Vector2(74, 700), Vector2(74, 954), Color(V16_PURPLE_HI, 0.22), 3.0, true)
	var weekly: Array = missions.all_weekly()
	for i in range(mini(3, weekly.size())):
		_v91_draw_contract(weekly[i], WEEKLY_ROWS[i], true, i)

	_draw_completion_v34(WEEKLY_CHEST, true)
	_v16_button(OVERLAY_BACK, "‹  BACK", V16_PURPLE, 17)
	_draw_notice(1092)

func _draw_mission_v34(m: Dictionary, r: Rect2, weekly: bool) -> void:
	_v91_draw_contract(m, r, weekly, 0)

func _v91_draw_contract(m: Dictionary, r: Rect2, weekly: bool, row_index: int) -> void:
	var complete: bool = bool(missions.is_complete(m, weekly))
	var claimed: bool = bool(missions.is_claimed(m, weekly))
	var accent: Color = V16_PURPLE_HI if weekly else V16_GREEN
	if complete and not claimed:
		accent = V16_GOLD
	if claimed:
		accent = Color("596273")

	var visual := Rect2(r.position + Vector2(32.0, 5.0), Vector2(r.size.x - 38.0, r.size.y - 10.0))
	var node := Vector2(r.position.x + 26.0, r.get_center().y)
	draw_circle(node, 13.0, Color("070b13"))
	draw_arc(node, 13.0, 0.0, TAU, 28, Color(accent, 0.72), 1.8)
	draw_circle(node, 4.0, Color(accent, 0.92 if complete and not claimed else 0.44))

	_v76_surface(visual, accent, Color("080c14"), 0.12, false)
	_v16_text(String(m.get("title", "MISSION")), visual.position + Vector2(18.0, 28.0), 15, V17_IVORY, true)

	var progress_value: int = int(missions.progress(m, weekly))
	var goal: int = maxi(1, int(m.get("goal", 1)))
	_v90_draw_mission_progress(Rect2(visual.position.x + 18.0, visual.position.y + 47.0, 224.0, 7.0), progress_value, goal, accent)
	_v16_text("%d/%d" % [progress_value, goal], visual.position + Vector2(18.0, 69.0), 9, accent, true)

	_v16_text("%d C" % int(m.get("coins", 0)), visual.position + Vector2(278.0, 54.0), 9, V16_GOLD_HI, true)
	_v16_text("%d XP" % int(m.get("xp", 0)), visual.position + Vector2(342.0, 54.0), 9, V16_PURPLE_HI, true)

	var status: String = "CLAIMED" if claimed else ("CLAIM" if complete else "ACTIVE")
	var status_accent: Color = Color("697080") if claimed else (V16_GOLD if complete else accent)
	var status_rect := Rect2(visual.end.x - 108.0, visual.position.y + 18.0, 88.0, 40.0)
	_v76_surface(status_rect, status_accent, Color("090d14"), 0.08, complete and not claimed)
	draw_string(v16_title_font, Vector2(status_rect.position.x + 5.0, status_rect.get_center().y + 4.0), status, HORIZONTAL_ALIGNMENT_CENTER, status_rect.size.x - 10.0, 9, V76_IVORY if not claimed else V16_MUTED)
