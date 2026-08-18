extends SceneTree

const TARGET_SCREENS := ["home", "hero", "forge"]
const REQUIRED_ASSETS := [
	"res://assets/environment/v159/gothic_pillar.obj",
	"res://assets/environment/v159/gothic_portal.obj",
	"res://assets/environment/v159/hero_pedestal.obj",
	"res://assets/environment/v159/wall_brazier.obj",
	"res://assets/environment/v159/forge_hearth.obj",
	"res://assets/environment/v159/blacksmith_anvil.obj",
	"res://assets/environment/v159/weapon_rack.obj",
	"res://assets/environment/v159/royal_banner.obj",
]

var _stage_name := "boot"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_stage("asset-imports")
	for path in REQUIRED_ASSETS:
		if not ResourceLoader.exists(path):
			_fail("missing authored environment asset: %s" % path)
			return
		var mesh := load(path) as Mesh
		if mesh == null or mesh.get_surface_count() <= 0:
			_fail("environment asset did not import as Mesh: %s" % path)
			return

	_stage("load-main")
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	for _i in range(4):
		await process_frame

	_stage("version-gate")
	if not game.has_method("_v73_environment_snapshot") or not bool(game.call("_v73_environment_ready")):
		_fail("main scene is not running v1.59 authored environment foundation")
		return
	var stage = game.v70_menu_stage
	if stage == null or not stage.has_method("environment_assets_ready"):
		_fail("v1.59 menu stage missing")
		return

	_stage("home-assets")
	stage.call("set_screen", "home")
	await process_frame
	var home: Dictionary = stage.call("debug_snapshot")
	if String(home.get("environment_asset_mode", "")) != "authored-obj":
		_fail("Home is not in authored OBJ mode")
		return
	for name in ["HomePortalAsset", "HomePillarLAsset", "HomePillarRAsset", "HomeBannerLAsset", "HomePedestalAsset"]:
		if stage.stage_root.get_node_or_null(name) == null:
			_fail("Home authored asset missing: %s" % name)
			return
	if int(home.get("environment_asset_instances", 0)) < 8:
		_fail("Home authored asset density too low")
		return

	_stage("hero-assets")
	stage.call("set_screen", "hero")
	await process_frame
	var hero: Dictionary = stage.call("debug_snapshot")
	for name in ["HeroPortalAsset", "HeroPillarLAsset", "HeroPillarRAsset", "HeroPedestalAsset"]:
		if stage.stage_root.get_node_or_null(name) == null:
			_fail("Hero authored asset missing: %s" % name)
			return
	if not bool(hero.get("actor_present", false)) or String(hero.get("actor_animation", "")) != "Idle":
		_fail("Hero Wanderer regression")
		return

	_stage("forge-assets")
	stage.call("set_screen", "forge")
	await process_frame
	var forge: Dictionary = stage.call("debug_snapshot")
	for name in ["ForgeHearthAsset", "ForgeAnvilAsset", "ForgeRackAsset", "ForgePillarLAsset", "ForgePillarRAsset"]:
		var node := stage.stage_root.get_node_or_null(name) as MeshInstance3D
		if node == null or node.mesh == null:
			_fail("Forge authored asset missing/unloaded: %s" % name)
			return
	if int(forge.get("environment_asset_instances", 0)) < 6:
		_fail("Forge authored asset density too low")
		return
	for legacy in ["ForgeHearth", "ForgeRack", "ForgeAnvilTop", "ForgeAnvilStem"]:
		if stage.stage_root.get_node_or_null(legacy) != null:
			_fail("v1.58 procedural Forge focal blockout survived: %s" % legacy)
			return

	_stage("regressions")
	if not bool(game.call("_v72_composition_ready")):
		_fail("v1.58 composition regression")
		return
	if not bool(game.call("_v70_full_3d_presentation_ready")):
		_fail("v1.56 full 3D presentation regression")
		return
	if not bool(game.call("_v69_wanderer_production_ready")):
		_fail("v1.55 Wanderer regression")
		return

	_stage("complete")
	print("v1.59 authored environment asset smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _stage(name: String) -> void:
	_stage_name = name
	print("V73_TEST_STAGE:%s" % name)

func _fail(message: String) -> void:
	push_error("V73_ENVIRONMENT_FAIL:%s:%s" % [_stage_name, message])
	quit(1)
