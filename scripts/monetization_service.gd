extends RefCounted

# v1.20 — Monetization foundation.
# This deliberately does NOT pretend that a native StoreKit/Google Billing or ad
# SDK is connected. In editor/debug builds purchases and rewarded ads can be
# simulated so the game/UI/reward plumbing can be tested. Release builds return
# provider_required until a native provider is wired later.

const SAVE_PATH := "user://save.cfg"
const PRODUCT_REMOVE_ADS := "com.kamilunavo.onemorefloor.removeads"
const PRODUCT_STARTER := "com.kamilunavo.onemorefloor.starterpack"
const PRODUCT_PREMIUM_PASS := "com.kamilunavo.onemorefloor.premiumpass"
const PRODUCT_COINS_SMALL := "com.kamilunavo.onemorefloor.coins.small"
const PRODUCT_SHARDS_SMALL := "com.kamilunavo.onemorefloor.shards.small"
const REWARDED_DAILY_LIMIT := 5
const REWARDED_COOLDOWN_SECONDS := 60

var remove_ads := false
var starter_claimed := false
var premium_pass := false
var purchase_count := 0
var rewarded_count := 0
var rewarded_daily_count := 0
var rewarded_day_key := ""
var last_rewarded_unix := 0
var native_provider_ready := false

func load_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		_refresh_rewarded_day()
		return
	remove_ads = bool(cfg.get_value("monetization", "remove_ads", false))
	starter_claimed = bool(cfg.get_value("monetization", "starter_claimed", false))
	premium_pass = bool(cfg.get_value("monetization", "premium_pass", false))
	purchase_count = int(cfg.get_value("monetization", "purchase_count", 0))
	rewarded_count = int(cfg.get_value("monetization", "rewarded_count", 0))
	rewarded_daily_count = int(cfg.get_value("monetization", "rewarded_daily_count", 0))
	rewarded_day_key = String(cfg.get_value("monetization", "rewarded_day_key", ""))
	last_rewarded_unix = int(cfg.get_value("monetization", "last_rewarded_unix", 0))
	_refresh_rewarded_day()

func save_data() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("monetization", "remove_ads", remove_ads)
	cfg.set_value("monetization", "starter_claimed", starter_claimed)
	cfg.set_value("monetization", "premium_pass", premium_pass)
	cfg.set_value("monetization", "purchase_count", purchase_count)
	cfg.set_value("monetization", "rewarded_count", rewarded_count)
	cfg.set_value("monetization", "rewarded_daily_count", rewarded_daily_count)
	cfg.set_value("monetization", "rewarded_day_key", rewarded_day_key)
	cfg.set_value("monetization", "last_rewarded_unix", last_rewarded_unix)
	cfg.set_value("system", "monetization_feature", "v1.20-foundation")
	cfg.save(SAVE_PATH)

func _refresh_rewarded_day() -> void:
	var today := Time.get_date_string_from_system()
	if rewarded_day_key == today:
		return
	rewarded_day_key = today
	rewarded_daily_count = 0
	save_data()

func premium_pass_unlocked() -> bool:
	return premium_pass

func is_debug_simulation() -> bool:
	return OS.is_debug_build()

func rewarded_remaining_today() -> int:
	_refresh_rewarded_day()
	return maxi(0, REWARDED_DAILY_LIMIT - rewarded_daily_count)

func rewarded_cooldown_remaining() -> int:
	var now := int(Time.get_unix_time_from_system())
	return maxi(0, REWARDED_COOLDOWN_SECONDS - (now - last_rewarded_unix))

func can_request_rewarded() -> bool:
	_refresh_rewarded_day()
	return rewarded_daily_count < REWARDED_DAILY_LIMIT and rewarded_cooldown_remaining() <= 0

func complete_rewarded_debug() -> Dictionary:
	if not is_debug_simulation():
		return {"status":"provider_required"}
	if not can_request_rewarded():
		return {"status":"cooldown", "remaining":rewarded_cooldown_remaining()}
	rewarded_daily_count += 1
	rewarded_count += 1
	last_rewarded_unix = int(Time.get_unix_time_from_system())
	save_data()
	return {"status":"granted", "coins":140, "shards":8}

func request_purchase(product_id: String) -> Dictionary:
	if not is_debug_simulation():
		return {"status":"provider_required", "product_id":product_id}
	return _complete_debug_purchase(product_id)

func _complete_debug_purchase(product_id: String) -> Dictionary:
	match product_id:
		PRODUCT_REMOVE_ADS:
			if remove_ads:
				return {"status":"owned", "product_id":product_id}
			remove_ads = true
			purchase_count += 1
			save_data()
			return {"status":"granted", "product_id":product_id, "coins":0, "shards":0}
		PRODUCT_STARTER:
			if starter_claimed:
				return {"status":"owned", "product_id":product_id}
			starter_claimed = true
			purchase_count += 1
			save_data()
			return {"status":"granted", "product_id":product_id, "coins":1200, "shards":90}
		PRODUCT_PREMIUM_PASS:
			if premium_pass:
				return {"status":"owned", "product_id":product_id}
			premium_pass = true
			purchase_count += 1
			save_data()
			return {"status":"granted", "product_id":product_id, "coins":250, "shards":20}
		PRODUCT_COINS_SMALL:
			purchase_count += 1
			save_data()
			return {"status":"granted", "product_id":product_id, "coins":900, "shards":0}
		PRODUCT_SHARDS_SMALL:
			purchase_count += 1
			save_data()
			return {"status":"granted", "product_id":product_id, "coins":0, "shards":75}
	return {"status":"unknown_product", "product_id":product_id}

func product_catalog() -> Array[Dictionary]:
	return [
		{"id":PRODUCT_PREMIUM_PASS,"title":"PREMIUM TOWER PASS","subtitle":"Extra seasonal reward track"},
		{"id":PRODUCT_STARTER,"title":"STARTER CACHE","subtitle":"One-time 1200 coins + 90 shards"},
		{"id":PRODUCT_REMOVE_ADS,"title":"REMOVE ADS","subtitle":"Permanent ad-free entitlement"},
		{"id":PRODUCT_COINS_SMALL,"title":"COIN CACHE","subtitle":"900 permanent coins"},
		{"id":PRODUCT_SHARDS_SMALL,"title":"SOUL SHARD CACHE","subtitle":"75 Soul Shards"},
	]
