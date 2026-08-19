extends SceneTree

const TARGET_SCREENS := ["talents", "vault", "missions", "pass", "store"]
const REQUIRED_ASSETS := [
	"res://assets/environment/v160/arcane_obelisk.obj",
	"res://assets/environment/v160/vault_door.obj",
	"res://assets/environment/v160/treasure_chest.obj",
	"res://assets/environment/v160/mission_table.obj",
	"res://assets/environment/v160/mission_board.obj",
	"res://assets/environment/v160/pass_shrine.obj",
	"res://assets/environment/v160/store_counter.obj",
]

var _stage_name := "boot"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	_stage("asset-imports")
	for path in REQUIRED_ASSETS:
		if not ResourceLoader.exists(path):
			_fail("missing v1.60 asset: %s" % path)
			return
		var mesh := load(path) as Mesh
		if mesh == null or mesh.get_surface_count() <= 0:
			_fail("asset did not import as Mesh: %s" % path)
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
	if not game.has_method("_v74_meta_environment_snapshot"):
		_fail("v1.60 main stack is not active")
		return
	var stage = game.v70_menu_stage
	if stage == null or not stage.has_method("meta_environment_assets_ready"):
		_fail("v1.60 stage is missing")
		return

	var required_nodes := {
		"talents": ["TalentObelisk0Asset", "TalentObelisk1Asset", "TalentPedestalAsset", "TalentPortalAsset"],
		"vault": ["VaultDoorAsset", "VaultChest0Asset", "VaultChest1Asset", "VaultPillarLAsset"],
		"missions": ["MissionTableAsset", "MissionBoardLAsset", "MissionBoardRAsset", "MissionPortalAsset"],
		"pass": ["PassShrineAsset", "PassBannerLAsset", "PassBannerRAsset", "PassPedestalAsset"],
		"store": ["StoreCounterAsset", "StorePedestalLAsset", "StorePedestalRAsset", "StoreBrazierLAsset"],
	}

	for screen in TARGET_SCREENS:
		_stage("screen-%s" % screen)
		stage.call("set_screen", screen)
		await process_frame
		var snapshot: Dictionary = stage.call("debug_snapshot")
		if String(snapshot.get("meta_environment_version", "")) != "1.60":
			_fail("v1.60 marker missing on %s" % screen)
			return
		if String(snapshot.get("meta_environment_asset_mode", "")) != "authored-obj-expanded":
			_fail("authored OBJ expanded mode missing on %s" % screen)
			return
		if int(snapshot.get("meta_environment_asset_instances", 0)) <= 0:
			_fail("no v1.60 assets instantiated on %s" % screen)
			return
		for node_name in required_nodes[screen]:
			var node := stage.stage_root.get_node_or_null(node_name) as MeshInstance3D
			if node == null or node.mesh == null:
				_fail("missing authored node %s on %s" % [node_name, screen])
				return

	_stage("regressions")
	if not bool(game.call("_v73_environment_ready")):
		_fail("v1.59 environment regression")
		return
	if not bool(game.call("_v72_composition_ready")):
		_fail("v1.58 composition regression")
		return
	if not bool(game.call("_v69_wanderer_production_ready")):
		_fail("v1.55 Wanderer regression")
		return

	_stage("complete")
	print("v1.60 authored meta environment smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _stage(name: String) -> void:
	_stage_name = name
	print("V74_TEST_STAGE:%s" % name)

func _fail(message: String) -> void:
	push_error("V74_META_ENV_FAIL:%s:%s" % [_stage_name, message])
	quit(1)
