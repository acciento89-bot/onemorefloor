extends "res://scripts/main_v38.gd"

# v1.26 build 20 hotfix — cash-out Home navigation.
# main_v25 introduced a modal run summary (`summary_open`) after cash-out. Later
# Home renderers were rebuilt from scratch and no longer draw that modal, but the
# inherited input handler still treated it as active and swallowed Home taps.
# Store/Settings could still work because newer input layers intercept them first.
# This layer removes that invisible modal state and leaves a non-blocking toast.

const V39_VERSION := "1.26.0-cashout-nav-hotfix"
const V39_BUILD := "20"

var v39_cashout_notice_time := 0.0
var v39_cashout_notice := ""

func _ready() -> void:
	super._ready()
	if telemetry != null:
		telemetry.set_build_context(V39_VERSION, V39_BUILD)
	queue_redraw()

func _process(delta: float) -> void:
	super._process(delta)
	if v39_cashout_notice_time > 0.0:
		v39_cashout_notice_time = maxf(0.0, v39_cashout_notice_time - delta)
		if v39_cashout_notice_time <= 0.0:
			queue_redraw()

func cash_out() -> void:
	var secured_hint := int(run.run_coins) if run != null else 0
	super.cash_out()
	_v39_restore_home_navigation_after_cashout()
	var secured := int(summary_secured) if summary_secured > 0 else secured_hint
	v39_cashout_notice = "RUN SECURED" if secured <= 0 else "RUN SECURED  •  +%d COINS" % secured
	v39_cashout_notice_time = 2.8
	if telemetry != null:
		telemetry.event("cashout_home_navigation_restored", {
			"secured": secured,
			"summary_open": summary_open,
			"home_overlay": home_overlay
		})
	queue_redraw()

func _v39_restore_home_navigation_after_cashout() -> void:
	# The current Home screen has no cash-out modal. Keeping summary_open=true
	# therefore creates an invisible input blocker in main_v25.pointer().
	summary_open = false
	home_overlay = ""
	v31_mastery_open = false
	room_event_active = false
	settings_open = false
	settings_return_to_pause = false
	release_paused = false

func pointer(pos: Vector2, pressed: bool, id: int) -> void:
	# Defensive recovery for migrated saves/session state: no invisible modal is
	# ever allowed to swallow Home navigation in the current renderer.
	if state == State.HOME and summary_open:
		summary_open = false
	super.pointer(pos, pressed, id)

func draw_home() -> void:
	super.draw_home()
	if v39_cashout_notice_time <= 0.0 or home_overlay != "" or settings_open or tutorial_active:
		return
	var accent := _v38_primary()
	_v16_frame(Rect2(184, 306, 352, 48), accent, Color("06101a"), 0.10)
	_v16_center(v39_cashout_notice, 337, 12, V17_IVORY)

func _v39_home_navigation_ready() -> bool:
	return state == State.HOME and not summary_open and home_overlay == "" and not settings_open
