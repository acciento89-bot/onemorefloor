extends SceneTree

const MissionsV2 = preload("res://scripts/mission_system_v2.gd")
const TowerPassV2 = preload("res://scripts/tower_pass_v2.gd")
const Monetization = preload("res://scripts/monetization_service.gd")
const Economy = preload("res://scripts/economy_balance_v2.gd")

func _init() -> void:
	call_deferred("_run")

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)

func _run() -> void:
	var missions = MissionsV2.new()
	missions.load_data()
	missions.set_progress_context(1)
	var early_daily: Array = missions.all_daily()
	if early_daily.size() != 3:
		_fail(2101, "v1.19 Missions 2.0: early Daily set is not three missions")
		return
	for mission in early_daily:
		if int(mission.get("min_floor", 1)) > 1:
			_fail(2102, "v1.19 Missions 2.0: impossible early mission leaked into rotation")
			return
	missions.set_progress_context(80)
	if missions.all_weekly().size() != 3:
		_fail(2103, "v1.19 Missions 2.0: deep Weekly rotation missing")
		return

	var tower = TowerPassV2.new()
	tower.season_key = tower.current_season_key()
	tower.xp = tower.xp_for_level(50)
	if tower.level() != 50 or tower.MAX_LEVEL != 50:
		_fail(2104, "v1.19 Tower Pass 2.0: level 50 progression failed")
		return
	var free_reward: Dictionary = tower.reward_for(10, false)
	var premium_reward: Dictionary = tower.reward_for(10, true)
	if int(free_reward.get("coins", 0)) <= 0 or int(premium_reward.get("shards", 0)) <= 0:
		_fail(2105, "v1.19 Tower Pass 2.0: dual reward tracks invalid")
		return

	var store = Monetization.new()
	var premium_result: Dictionary = store._complete_debug_purchase(store.PRODUCT_PREMIUM_PASS)
	if String(premium_result.get("status", "")) not in ["granted", "owned"] or not store.premium_pass_unlocked():
		_fail(2106, "v1.20 Monetization: premium entitlement plumbing failed")
		return
	if store.product_catalog().size() < 5:
		_fail(2107, "v1.20 Monetization: catalog incomplete")
		return

	var economy = Economy.new()
	var rec: int = economy.recommended_power(55)
	var normal: Dictionary = economy.adaptive_pressure(rec, 55)
	var over: Dictionary = economy.adaptive_pressure(rec * 4, 55)
	if bool(normal.get("active", true)):
		_fail(2108, "v1.21 Economy: on-curve player was incorrectly pressure-scaled")
		return
	if not bool(over.get("active", false)) or float(over.get("hp", 1.0)) <= 1.20:
		_fail(2109, "v1.21 Economy: overgeared pressure did not activate")
		return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(2110, "v1.21 Runtime: main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	if not game.has_method("draw_store_screen") or not game.has_method("_apply_pressure"):
		_fail(2111, "v1.21 Runtime: liveops renderer/runtime not active")
		return
	if not game.missions.has_method("completion_bonus_claimable") or int(game.tower_pass.MAX_LEVEL) != 50:
		_fail(2112, "v1.21 Runtime: v2 mission/pass systems were not installed")
		return

	print("ONE MORE FLOOR v1.19-v1.21 liveops/economy smoke test passed")
	quit(0)
