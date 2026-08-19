extends SceneTree

const CAPTURE_DIR := "res://artifacts/v162_states"

class FakeUnavailableMonetization:
	extends RefCounted
	const PRODUCT_REMOVE_ADS := "com.kamilunavo.onemorefloor.removeads"
	const PRODUCT_STARTER := "com.kamilunavo.onemorefloor.starterpack"
	const PRODUCT_PREMIUM_PASS := "com.kamilunavo.onemorefloor.premiumpass"
	const PRODUCT_COINS_SMALL := "com.kamilunavo.onemorefloor.coins.small"
	const PRODUCT_SHARDS_SMALL := "com.kamilunavo.onemorefloor.shards.small"
	var remove_ads := false
	var starter_claimed := false
	var premium_pass_season := ""
	func is_debug_simulation() -> bool: return false
	func premium_pass_unlocked() -> bool: return false
	func rewarded_remaining_today() -> int: return 5
	func rewarded_cooldown_remaining() -> int: return 0
	func save_data() -> void: pass
	func product_catalog() -> Array[Dictionary]:
		return [
			{"id":PRODUCT_PREMIUM_PASS,"title":"PREMIUM TOWER PASS","subtitle":"Extra rewards for the current season"},
			{"id":PRODUCT_STARTER,"title":"STARTER CACHE","subtitle":"One-time 1200 coins + 90 shards"},
			{"id":PRODUCT_REMOVE_ADS,"title":"REMOVE ADS","subtitle":"Permanent ad-free entitlement"},
			{"id":PRODUCT_COINS_SMALL,"title":"COIN CACHE","subtitle":"900 permanent coins"},
			{"id":PRODUCT_SHARDS_SMALL,"title":"SOUL SHARD CACHE","subtitle":"75 Soul Shards"},
		]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(720, 1280)
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	for _i in range(12):
		await process_frame

	game.tutorial_active = false
	game.settings_open = false
	game.release_paused = false
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_DIR))

	if not bool(game.call("_v51_route_to", "store", false)):
		_fail("could not route to Store")
		return

	var real_monetization = game.monetization
	if real_monetization == null:
		_fail("real monetization service missing")
		return
	var old_remove_ads: bool = bool(real_monetization.remove_ads)
	var old_starter: bool = bool(real_monetization.starter_claimed)
	var old_pass: String = String(real_monetization.premium_pass_season)

	# Actionable debug state: no non-consumable ownership, so cards show TRY.
	real_monetization.remove_ads = false
	real_monetization.starter_claimed = false
	real_monetization.premium_pass_season = ""
	game.store_notice_time = 0.0
	await _capture(game, "store_try")

	# Owned state: exercise all three entitlement chips without writing save data.
	real_monetization.remove_ads = true
	real_monetization.starter_claimed = true
	real_monetization.premium_pass_season = String(real_monetization.current_season_key())
	game.queue_redraw()
	await _capture(game, "store_owned")

	# Fail-closed release presentation: use an in-memory service double whose only
	# purpose is to expose the same catalog with debug simulation disabled.
	game.monetization = FakeUnavailableMonetization.new()
	game.queue_redraw()
	await _capture(game, "store_unavailable")

	# Restore the real service in-memory; CI never persists these diagnostic states.
	game.monetization = real_monetization
	real_monetization.remove_ads = old_remove_ads
	real_monetization.starter_claimed = old_starter
	real_monetization.premium_pass_season = old_pass

	print("v1.62 UI state matrix visual capture passed")
	game.queue_free()
	await process_frame
	quit(0)

func _capture(game: Node, label: String) -> void:
	if game.has_method("_v70_sync_menu_3d"):
		game.call("_v70_sync_menu_3d", true)
	game.queue_redraw()
	for _i in range(12):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		_fail("empty state image: %s" % label)
		return
	var output := "%s/%s.png" % [CAPTURE_DIR, label]
	var result := image.save_png(ProjectSettings.globalize_path(output))
	if result != OK:
		_fail("could not save %s (%s)" % [output, result])
		return
	print("V81_UI_STATE_CAPTURE:%s:%s:%dx%d" % [label, output, image.get_width(), image.get_height()])

func _fail(message: String) -> void:
	push_error("V81_UI_STATE_FAIL:%s" % message)
	quit(1)
