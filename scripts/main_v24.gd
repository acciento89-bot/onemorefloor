extends "res://scripts/main_v23.gd"

# ONE MORE FLOOR v1.12 — checkpoint + difficulty pass.
# Gameplay progression now resumes from Floor 50+ checkpoints, while the final
# menu fonts are forced through high-quality oversampling for crisp small text.

const V24_VERSION := "1.12-checkpoint-difficulty"

func _ready() -> void:
	super._ready()
	_configure_v24_text_rendering()

func _configure_v24_text_rendering() -> void:
	# The game is authored at 720x1280 but is often previewed at fractional
	# desktop/mobile scales. Oversampling prevents the 11-18 px labels from being
	# rasterized into a soft half-resolution texture before scaling.
	var viewport := get_viewport()
	if viewport != null:
		viewport.oversampling_override = 2.0
	for target in [v16_title_font, v16_body_font]:
		if target == null:
			continue
		target.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
		target.hinting = TextServer.HINTING_NORMAL
		target.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_ONE_QUARTER
		target.oversampling = 2.0
		target.disable_embedded_bitmaps = true

func start_run() -> void:
	super.start_run()
	if run != null and int(run.floor_no) >= 50:
		loot_notice = "CHECKPOINT RESUMED — FLOOR %d" % int(run.floor_no)
		loot_notice_color = C_PURPLE
		loot_notice_time = 2.4

func continue_run() -> void:
	var old_checkpoint := int(meta.checkpoint_floor) if meta != null else 1
	super.continue_run()
	if meta != null and int(meta.checkpoint_floor) > old_checkpoint:
		loot_notice = "CHECKPOINT SAVED — FLOOR %d" % int(meta.checkpoint_floor)
		loot_notice_color = C_GREEN
		loot_notice_time = 2.0
		_audio("claim")

func draw_home() -> void:
	super.draw_home()
	if home_overlay != "" or settings_open:
		return
	if meta != null and int(meta.checkpoint_floor) >= 50:
		_v16_text(
			"CHECKPOINT  F%d" % int(meta.checkpoint_floor),
			Vector2(264, 804),
			12,
			V16_PURPLE_HI,
			true
		)

func draw_game_over() -> void:
	super.draw_game_over()
	if meta != null and int(meta.checkpoint_floor) >= 50:
		_v16_center(
			"Next run resumes at Floor %d" % int(meta.checkpoint_floor),
			1072,
			14,
			V16_PURPLE_HI
		)
