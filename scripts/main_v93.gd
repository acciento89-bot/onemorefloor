extends "res://scripts/main_v92.gd"

# ONE MORE FLOOR v1.69 r1 — Enemy + Boss Visual Completion.
# Frontend/Hero keep the accepted v1.68 shared Wanderer. Only the gameplay world
# advances to v1.69 so enemy/boss authored silhouette changes stay isolated.

const EnemyCompletionWorldV169 = preload("res://scripts/world3d_chamber_v169_enemy_completion.gd")
const V93_ENEMY_COMPLETION := "1.69-enemy-boss-visual-completion-r1"

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.event("enemy_completion_v169_ready", _v93_enemy_completion_snapshot())

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

	v52_world_root = EnemyCompletionWorldV169.new()
	v52_world_root.name = "EnemyCompletionV169RealmWorld"
	v52_world_viewport.add_child(v52_world_root)
	v52_world_root.set_active(false)

func _v93_enemy_completion_ready() -> bool:
	return _v92_character_completion_ready() \
		and v52_world_root != null \
		and v52_world_root.has_method("production_enemy_completion_ready") \
		and bool(v52_world_root.call("production_enemy_completion_ready"))

func _v93_enemy_completion_snapshot() -> Dictionary:
	var world_snapshot: Dictionary = {}
	if v52_world_root != null and v52_world_root.has_method("debug_snapshot"):
		world_snapshot = v52_world_root.call("debug_snapshot")
	return {
		"ready": _v93_enemy_completion_ready(),
		"version": V93_ENEMY_COMPLETION,
		"wanderer_v168_preserved": _v92_character_completion_ready(),
		"world": world_snapshot,
	}
