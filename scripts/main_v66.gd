extends "res://scripts/main_v65.gd"

# ONE MORE FLOOR v1.52.1 — input-flow hotfix.
# Keeps the v1.52 3D combat-core authority, while fixing two release-blocking
# onboarding/input paths discovered in hands-on Godot testing:
# - the tutorial's first upgrade is now an actual clickable upgrade choice
# - tutorial deaths can always RETRY or return HOME instead of being trapped by
#   the tutorial modal capture
# The v1.52 NOVA override also restores the inherited audio/animation/VFX hooks
# that were bypassed when NOVA membership moved into 3D.

const V66_VERSION := "1.52.1-input-flow-hotfix"
const V66_BUILD := "39-dev"

var v66_tutorial_retry_pending := false
var v66_tutorial_deaths := 0
var v66_tutorial_upgrade_completions := 0
var v66_terminal_input_recoveries := 0

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V66_VERSION, V66_BUILD)
		telemetry.event("input_flow_hotfix_ready", {
			"tutorial_upgrade_clickthrough": true,
			"tutorial_death_recovery": true,
			"game_over_direct_actions": true,
			"nova_presentation_hooks": true,
		})

# v1.52 owns NOVA target/projectile membership in 3D. Reproduce the inherited
# non-gameplay hooks after the 3D query resolves so animation/audio/presentation
# remain identical to the pre-authority path without re-running legacy 2D damage.
func use_skill() -> void:
	if state != State.RUNNING or run == null or run.skill_cd > 0.0:
		return
	if not _v65_floor_uses_combat_core() or not _v65_3d_combat_core_ready():
		super.use_skill()
		return
	var value: Variant = v52_world_root.call(
		"query_nova_3d", player_pos, enemies, enemy_shots, float(run.nova_radius)
	)
	if not (value is Dictionary):
		super.use_skill()
		return
	var report: Dictionary = value
	if not bool(report.get("ready", false)):
		super.use_skill()
		return

	run.skill_cd = 7.0
	skill_flash = 0.36
	screen_shake = 8.0
	haptic(38)
	effects.append({"type":"nova","pos":player_pos,"age":0.0,"dur":0.38,"color":C_BLUE,"kind":""})

	var enemy_indices_value: Variant = report.get("enemy_indices", [])
	if enemy_indices_value is Array:
		for index_value in enemy_indices_value:
			var enemy_index: int = int(index_value)
			if enemy_index >= 0 and enemy_index < enemies.size():
				apply_damage_to_enemy(enemy_index, run.damage * run.nova_mult, false, enemies[enemy_index]["pos"])
				v65_nova_enemy_hits += 1

	var projectile_indices_value: Variant = report.get("projectile_indices", [])
	if projectile_indices_value is Array:
		var projectile_indices: Array = (projectile_indices_value as Array).duplicate()
		projectile_indices.sort()
		for reverse_index in range(projectile_indices.size() - 1, -1, -1):
			var projectile_index: int = int(projectile_indices[reverse_index])
			if projectile_index >= 0 and projectile_index < enemy_shots.size():
				enemy_shots.remove_at(projectile_index)
				v65_nova_projectiles_purged += 1

	v65_nova_queries += 1
	v65_last_nova_report = _v65_trim_nova_report(report)
	_v66_restore_nova_presentation_hooks()

func _v66_restore_nova_presentation_hooks() -> void:
	# main_v04.gd
	_audio("nova")
	# main_v08.gd / directional motion stack
	player_anim_state = "nova"
	player_anim_timer = 0.34
	# main_v47.gd and every 3D presentation layer that reads this stamp
	v47_player_skill_stamp = elapsed
	effects.append({"type":"v47_nova","pos":player_pos,"age":0.0,"dur":0.42,"color":C_PURPLE})

# A death while tutorial_step == 3 used to leave tutorial_active=true while the
# visible screen had already changed to GAME_OVER. main_v10.pointer() then sent
# every tap into _pointer_tutorial(), making RETRY and HOME unreachable.
func die() -> void:
	var tutorial_was_active := tutorial_active
	var tutorial_step_before := tutorial_step
	super.die()
	_v66_clear_terminal_input_blockers()
	if tutorial_was_active:
		v66_tutorial_retry_pending = true
		v66_tutorial_deaths += 1
		tutorial_active = false
		tutorial_step = clampi(tutorial_step_before, 0, 4)
		if telemetry != null:
			telemetry.event("tutorial_death_recovered", {
				"step": tutorial_step_before,
				"floor": int(run.floor_no) if run != null else 0,
			})

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	if not pressed:
		super.pointer(pos, pressed, id)
		return

	# Terminal actions must stay reachable even if an old modal/touch sequence was
	# left behind. Route the visible GAME OVER buttons before the historical modal
	# stack gets a chance to swallow them.
	if state == State.GAME_OVER:
		if RETRY.has_point(pos):
			_v66_clear_terminal_input_blockers()
			if v66_tutorial_retry_pending:
				tutorial_active = true
				tutorial_step = 2
				v66_tutorial_retry_pending = false
			start_run()
			_v66_sync_navigation_after_direct_action()
			return
		if HOME_BTN.has_point(pos):
			_v66_clear_terminal_input_blockers()
			state = State.HOME
			home_overlay = ""
			if v66_tutorial_retry_pending:
				tutorial_active = true
				tutorial_step = 0
				v66_tutorial_retry_pending = false
			_v66_sync_navigation_after_direct_action()
			queue_redraw()
			return

	# Step 4 says "choose one upgrade", so the upgrade itself is now the tutorial
	# completion action. Previously every upgrade-card tap was swallowed while a
	# separate FINISH TUTORIAL button covered the actual screen underneath.
	if tutorial_active and tutorial_step == 4 and state == State.UPGRADE:
		if room_event_active:
			super.pointer(pos, pressed, id)
			return
		for index in range(upgrade_options.size()):
			if upgrade_rect(index).has_point(pos):
				apply_upgrade(index)
				_complete_tutorial()
				v66_tutorial_upgrade_completions += 1
				_v66_sync_navigation_after_direct_action()
				if telemetry != null:
					telemetry.event("tutorial_upgrade_completed", {"index": index})
				return
		return

	super.pointer(pos, pressed, id)

func _v66_clear_terminal_input_blockers() -> void:
	release_paused = false
	settings_open = false
	settings_return_to_pause = false
	joy_active = false
	joy_id = -1
	joy_vector = Vector2.ZERO
	summary_open = false
	# main_v13 protects modal pointer sequences. A terminal state must never retain
	# a stale capture if the finger-up event arrived during a state transition.
	v13_pointer_sequence_locked = false
	v13_pointer_lock_touch_id = -99999
	v13_swallow_release_id = -99999
	v66_terminal_input_recoveries += 1

func _v66_sync_navigation_after_direct_action() -> void:
	if v51_navigation != null:
		_v51_sync_navigation(false)
		_v51_sync_shell()

# Keep the three upgrade cards visible and tappable. The old full-screen tutorial
# modal contradicted its own copy by hiding the choices it told the player to tap.
func _draw_tutorial_overlay() -> void:
	if tutorial_active and tutorial_step == 4 and state == State.UPGRADE:
		var hint := Rect2(76, 292, 568, 76)
		_v16_frame(hint, V16_GOLD, Color("080c16"), 0.18)
		var label := "RESOLVE THE EVENT, THEN PICK AN UPGRADE" if room_event_active else "TAP ONE UPGRADE TO CONTINUE"
		_v16_center(label, 327, 14, V17_GOLD_HI, true)
		_v16_center("Your first choice completes the tutorial.", 350, 10, V16_MUTED)
		return
	super._draw_tutorial_overlay()

func _v66_input_flow_snapshot() -> Dictionary:
	return {
		"ready": _v65_3d_combat_core_ready(),
		"version": V66_VERSION,
		"build": V66_BUILD,
		"tutorial_retry_pending": v66_tutorial_retry_pending,
		"tutorial_deaths": v66_tutorial_deaths,
		"tutorial_upgrade_completions": v66_tutorial_upgrade_completions,
		"terminal_input_recoveries": v66_terminal_input_recoveries,
		"nova_animation_state": player_anim_state,
	}
