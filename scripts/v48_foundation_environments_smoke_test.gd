extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var art_path := "res://assets/art/foundation_realms_v48.svg"
	if not FileAccess.file_exists(art_path):
		_fail(4801, "v1.35 foundation environment atlas missing")
		return
	if load(art_path) as Texture2D == null:
		_fail(4802, "v1.35 foundation environment atlas failed to import")
		return

	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail(4803, "v1.35 main scene failed to load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await process_frame

	if not game.has_method("_v48_foundation_environments_ready") or not bool(game._v48_foundation_environments_ready()):
		_fail(4804, "v1.35 foundation environment runtime is not active")
		return

	var expected := {
		1:"GATE OF ASH", 2:"TORCH COURT", 3:"OLD CISTERN",
		11:"BONE GALLERY", 12:"MOURNING VAULT", 13:"GREEN CRYPT",
		21:"CHAIN WALK", 22:"EMBER ARMORY", 23:"WAR FOUNDRY",
		31:"FRACTURE STAIRS", 32:"ARCANE WELL", 33:"NULL CLOISTER",
		41:"MOONLESS NAVE", 42:"ASTRAL BRIDGE", 43:"SOVEREIGN APPROACH",
		50:"SOVEREIGN APPROACH",
	}
	for floor_no in expected.keys():
		if String(game._v48_chamber_for_floor(int(floor_no))) != String(expected[floor_no]):
			_fail(4805, "v1.35 chamber mapping mismatch on floor %d" % int(floor_no))
			return

	for method in ["_v48_draw_chamber_floor", "_v48_draw_ambient", "_draw_room_floor", "_draw_room_architecture"]:
		if not game.has_method(method):
			_fail(4806, "v1.35 environment method missing: %s" % method)
			return

	var scene_text := FileAccess.get_file_as_string("res://scenes/main.tscn")
	if not scene_text.contains("main_v48.gd") or not scene_text.contains("main_v47.gd"):
		_fail(4807, "v1.35 scene wiring or v1.34 compatibility baseline missing")
		return
	var renderer := FileAccess.get_file_as_string("res://scripts/main_v48.gd")
	for marker in ["FOUNDATION ENVIRONMENTS", "LOWER HALLS", "OSSUARY", "IRON BASTION", "RIFT DESCENT", "STARLESS SPIRE", "SOVEREIGN APPROACH"]:
		if not renderer.to_upper().contains(marker.to_upper()):
			_fail(4808, "v1.35 renderer marker missing: %s" % marker)
			return

	print("ONE MORE FLOOR v1.35 foundation environments smoke test passed")
	quit(0)

func _fail(code: int, message: String) -> void:
	push_error(message)
	quit(code)
