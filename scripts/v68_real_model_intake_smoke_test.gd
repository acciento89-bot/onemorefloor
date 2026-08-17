extends SceneTree

const RegistryV154 = preload("res://scripts/world3d_model_registry_v154.gd")
const FIXTURE_ROOT := "res://tests/fixtures/models/actors"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	# Prove the registry imports an actual glTF resource, not only string paths.
	var fixture_registry = RegistryV154.new(FIXTURE_ROOT)
	var candidates: Array[String] = fixture_registry.candidate_paths("wanderer")
	if candidates.size() != 2 or not candidates[0].ends_with(".glb") or not candidates[1].ends_with(".gltf"):
		_fail("GLB/glTF candidate ordering is wrong")
		return
	if not fixture_registry.model_available("wanderer"):
		_fail("text glTF fixture was not discovered by ResourceLoader")
		return
	var fixture_path: String = fixture_registry.asset_path("wanderer")
	if not fixture_path.ends_with("wanderer.gltf"):
		_fail("registry did not fall through from missing GLB to glTF")
		return
	var imported: Node3D = fixture_registry.instantiate_model("wanderer")
	if imported == null:
		_fail("glTF fixture did not instantiate as Node3D/PackedScene")
		return
	if String(imported.get_meta("model_format", "")) != "gltf":
		imported.free()
		_fail("imported model format metadata is wrong")
		return
	if String(imported.get_meta("model_asset_path", "")) != fixture_path:
		imported.free()
		_fail("imported model path metadata is wrong")
		return
	imported.free()

	# Prove common exporter/animation-library names resolve without renaming clips.
	var animation_player := AnimationPlayer.new()
	var library := AnimationLibrary.new()
	for clip_name in [
		"Idle",
		"Armature|Running_A",
		"1H_Melee_Attack_Slice_Diagonal",
		"Character-HitReact-Front",
		"Wizard SpellCast Long",
	]:
		library.add_animation(clip_name, Animation.new())
	animation_player.add_animation_library("", library)
	if fixture_registry.resolve_animation_clip(animation_player, "idle") != "Idle":
		_fail("exact idle alias resolution regressed")
		return
	if fixture_registry.resolve_animation_clip(animation_player, "run") != "Armature|Running_A":
		_fail("fuzzy run animation resolution failed")
		return
	if fixture_registry.resolve_animation_clip(animation_player, "attack") != "1H_Melee_Attack_Slice_Diagonal":
		_fail("fuzzy attack animation resolution failed")
		return
	if fixture_registry.resolve_animation_clip(animation_player, "hit") != "Character-HitReact-Front":
		_fail("fuzzy hit animation resolution failed")
		return
	if fixture_registry.resolve_animation_clip(animation_player, "skill") != "Wizard SpellCast Long":
		_fail("fuzzy skill animation resolution failed")
		return
	animation_player.free()

	# Finally prove the production game is routed through v1.54 while retaining
	# the v1.53 presentation and v1.52 combat/input contracts underneath it.
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene did not load")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	await physics_frame
	if not game.has_method("_v68_real_model_intake_snapshot"):
		_fail("main scene is not running v1.54 real-model intake")
		return
	if not bool(game.call("_v68_real_model_intake_ready")):
		_fail("production v1.54 real-model intake is not ready")
		return
	if not bool(game.call("_v67_3d_visual_presentation_ready")):
		_fail("v1.53 visual presentation regressed under v1.54")
		return
	if not bool(game.call("_v65_3d_combat_core_ready")):
		_fail("v1.52 combat authority regressed under v1.54")
		return

	var snapshot: Dictionary = game.call("_v68_real_model_intake_snapshot")
	if String(snapshot.get("version", "")) != "1.54.0-real-model-intake":
		_fail("v1.54 version marker is wrong")
		return

	print("v1.54 real GLB/glTF model intake smoke test passed")
	game.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V68_MODEL_INTAKE_FAIL: %s" % message)
	quit(1)
