extends "res://scripts/main_v62.gd"

# ONE MORE FLOOR v1.50 - 3D Gameplay Authority Phase 1.
# The proven 2D runtime still computes combat/AI intent. Floors 1-50 now route
# final player/enemy locomotion endpoints through CharacterBody3D authority.

const GameplayAuthorityWorld3DChamber = preload("res://scripts/world3d_chamber_v150.gd")
const V63_VERSION := "1.50.0-3d-gameplay-authority"
const V63_BUILD := "36-dev"
const V63_3D_MIN_FLOOR := 1
const V63_3D_MAX_FLOOR := 50

var v63_authority_frames := 0
var v63_authority_corrections := 0
var v63_authority_wall_hits := 0
var v63_authority_separations := 0
var v63_authority_contacts := 0
var v63_authority_floor := -1
var v63_last_authority_report: Dictionary = {}

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V63_VERSION, V63_BUILD)
		telemetry.event("gameplay_3d_authority_ready", {
			"world_ready": _v63_3d_gameplay_authority_ready(),
			"mode": "hybrid_3d_collision_authority",
			"floor_min": V63_3D_MIN_FLOOR,
			"floor_max": V63_3D_MAX_FLOOR,
			"character_bodies": 19,
			"static_bounds": 4,
		})

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

	v52_world_root = GameplayAuthorityWorld3DChamber.new()
	v52_world_root.name = "Tower3DRealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v52_3d_active() -> bool:
	if state != State.RUNNING or run == null:
		return false
	var floor_no: int = int(run.floor_no)
	return floor_no >= V63_3D_MIN_FLOOR and floor_no <= V63_3D_MAX_FLOOR

# Existing gameplay calculates intent first. This finalization step is then the
# source of truth for the positions that survive the frame and are rendered.
func update_game(delta: float) -> void:
	super.update_game(delta)
	if state != State.RUNNING or run == null:
		return
	if not _v63_floor_uses_authority():
		return
	_v63_apply_3d_authority(delta)

func _v63_apply_3d_authority(delta: float) -> void:
	if not _v63_3d_gameplay_authority_ready():
		return
	var floor_no: int = int(run.floor_no)
	if floor_no != v63_authority_floor:
		v63_authority_floor = floor_no
		if v52_world_root.has_method("reset_gameplay_authority"):
			v52_world_root.call("reset_gameplay_authority")

	var report_value: Variant = v52_world_root.call(
		"resolve_gameplay_authority", delta, player_pos, enemies
	)
	if not (report_value is Dictionary):
		return
	var report: Dictionary = report_value
	if not bool(report.get("ready", false)):
		return

	var resolved_player: Vector2 = report.get("player_pos", player_pos)
	player_pos = resolved_player
	var resolved_enemies: Array = report.get("enemy_positions", [])
	var count: int = mini(enemies.size(), resolved_enemies.size())
	for index in range(count):
		var enemy: Dictionary = enemies[index]
		enemy["pos"] = resolved_enemies[index]
		enemies[index] = enemy

	v63_authority_frames += 1
	v63_authority_corrections += int(report.get("corrected_bodies", 0))
	v63_authority_wall_hits += int(report.get("wall_hits", 0))
	v63_authority_separations += int(report.get("separation_hits", 0))
	v63_authority_contacts += int(report.get("contact_pairs", 0))
	v63_last_authority_report = report.duplicate(true)

func _v63_floor_uses_authority() -> bool:
	if run == null:
		return false
	var floor_no: int = int(run.floor_no)
	return floor_no >= V63_3D_MIN_FLOOR and floor_no <= V63_3D_MAX_FLOOR

func _v63_3d_gameplay_authority_ready() -> bool:
	return _v62_production_art_lookdev_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("gameplay_authority_ready") \
		and bool(v52_world_root.call("gameplay_authority_ready"))

func _v63_authority_snapshot() -> Dictionary:
	return {
		"ready": _v63_3d_gameplay_authority_ready(),
		"mode": "hybrid_3d_collision_authority",
		"frames": v63_authority_frames,
		"corrections": v63_authority_corrections,
		"wall_hits": v63_authority_wall_hits,
		"separations": v63_authority_separations,
		"contacts": v63_authority_contacts,
		"floor": v63_authority_floor,
		"last_report": v63_last_authority_report.duplicate(true),
	}
