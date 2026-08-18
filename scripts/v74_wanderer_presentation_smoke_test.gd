extends SceneTree

const WorldV160Actors = preload("res://scripts/world3d_chamber_v160_actors.gd")
const REQUIRED_AUTHORED_ASSETS := [
	"res://assets/models/actors/v160/wanderer_torso.obj",
	"res://assets/models/actors/v160/wanderer_chestplate.obj",
	"res://assets/models/actors/v160/wanderer_hood.obj",
	"res://assets/models/actors/v160/wanderer_mask.obj",
	"res://assets/models/actors/v160/wanderer_pauldron.obj",
	"res://assets/models/actors/v160/wanderer_arm.obj",
	"res://assets/models/actors/v160/wanderer_gauntlet.obj",
	"res://assets/models/actors/v160/wanderer_leg.obj",
	"res://assets/models/actors/v160/wanderer_boot.obj",
	"res://assets/models/actors/v160/wanderer_blade.obj",
	"res://assets/models/actors/v160/wanderer_cape.obj",
]

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	for path in REQUIRED_AUTHORED_ASSETS:
		if not ResourceLoader.exists(path):
			_fail("missing authored Wanderer asset: %s" % path)
			return
		var mesh := load(path) as Mesh
		if mesh == null or mesh.get_surface_count() <= 0:
			_fail("authored Wanderer asset did not import as Mesh: %s" % path)
			return

	var world = WorldV160Actors.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame

	if not bool(world.call("production_actor_presentation_ready")):
		_fail("production actor presentation did not become ready")
		return
	if not world.actor_factory.has_method("character_quality_player_ready"):
		_fail("character-quality Wanderer API missing")
		return
	if not bool(world.actor_factory.call("character_quality_player_ready", world.player_root)):
		_fail("final character-quality Wanderer did not become ready")
		return
	var snapshot: Dictionary = world.debug_snapshot()
	var wanderer: Dictionary = snapshot.get("wanderer_v160", {})
	var authored: Dictionary = snapshot.get("wanderer_v160_authored", {})
	var quality: Dictionary = snapshot.get("character_quality_v160", {})
	if int(wanderer.get("mesh_count", 0)) < 22:
		_fail("base v1.60 Wanderer presentation contract regressed")
		return
	if not bool(wanderer.get("prototype_geometry_hidden", false)):
		_fail("v1.55 prototype Wanderer geometry was not retired")
		return
	if not bool(authored.get("ready", false)) or int(authored.get("instances", 0)) < 16:
		_fail("authored modular Wanderer coverage incomplete: %s" % JSON.stringify(authored))
		return
	if int(authored.get("asset_count", 0)) != REQUIRED_AUTHORED_ASSETS.size():
		_fail("authored Wanderer asset count mismatch")
		return
	if not bool(quality.get("ready", false)) or not bool(quality.get("wanderer_ready", false)):
		_fail("final character-quality snapshot incomplete: %s" % JSON.stringify(quality))
		return

	var imported := world.player_root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		_fail("imported Wanderer mount missing")
		return
	var old_torso := _find_named_mesh(imported, "Torso")
	var rounded_torso := _find_named_mesh(imported, "V160Torso")
	var rounded_hood := _find_named_mesh(imported, "V160Hood")
	var old_face_shadow := _find_named_mesh(imported, "V160FaceShadow")
	var polish_cape := _find_named_mesh(imported, "V160ProductionCape")
	var authored_torso := _find_named_mesh(imported, "V160AuthoredTorso")
	var authored_hood := _find_named_mesh(imported, "V160AuthoredHood")
	var authored_mask := _find_named_mesh(imported, "V160AuthoredMask")
	var authored_cape := _find_named_mesh(imported, "V160AuthoredCape")
	var authored_blade := _find_named_mesh(imported, "V160AuthoredBlade")
	var eye_l := _find_named_mesh(imported, "V160EyeSlitL")
	var eye_r := _find_named_mesh(imported, "V160EyeSlitR")
	var arcane_core := _find_named_mesh(imported, "ArcaneCore")
	if old_torso == null or old_torso.visible:
		_fail("v1.55 prototype torso is still visible")
		return
	if rounded_torso == null or rounded_torso.visible or rounded_hood == null or rounded_hood.visible:
		_fail("rounded v1.60 intermediate body geometry is still visible")
		return
	if old_face_shadow == null or old_face_shadow.visible:
		_fail("spherical face shadow is still visible")
		return
	if polish_cape == null or polish_cape.visible:
		_fail("intermediate polish cape is still visible")
		return

	for mesh_instance in [authored_torso, authored_hood, authored_mask, authored_cape, authored_blade]:
		if mesh_instance == null or not mesh_instance.visible:
			_fail("authored Wanderer landmark mesh missing")
			return
		if not (mesh_instance.material_override is ShaderMaterial):
			_fail("authored Wanderer landmark is missing production shader material")
			return
		if not String(mesh_instance.mesh.resource_path).ends_with(".obj"):
			_fail("authored Wanderer landmark is not backed by imported OBJ geometry")
			return
	if eye_l == null or eye_r == null or not eye_l.visible or not eye_r.visible:
		_fail("authored mask eye slits are missing")
		return
	if arcane_core == null or not arcane_core.visible:
		_fail("animated ArcaneCore was not preserved")
		return

	# Drive the same required production states through the existing v1.54
	# registry. The authored meshes are children of those same animated pivots.
	var cases := [
		["idle", 0.0, 0.0, 0.0],
		["run", 1.0, 0.0, 0.0],
		["attack", 0.0, 1.0, 0.0],
		["skill", 0.0, 0.0, 1.0],
	]
	for case_value in cases:
		var case: Array = case_value
		world.actor_factory.animate_player(world.player_root, 0.25, float(case[1]), float(case[2]), float(case[3]))
		var active_clip := String(imported.get_meta("active_animation_clip", "")).to_lower()
		if active_clip.is_empty() or not active_clip.contains(String(case[0])):
			_fail("animation state %s no longer drives imported clip (got %s)" % [case[0], active_clip])
			return

	if not bool(snapshot.get("production_material_depth_ready", false)):
		_fail("material-depth regression under actor layer")
		return
	if not bool(snapshot.get("real_model_intake_v154_ready", false)):
		_fail("v1.54 real-model intake regression")
		return

	print("v1.60 production Wanderer presentation smoke test passed")
	world.queue_free()
	await process_frame
	quit(0)

func _find_named_mesh(node: Node, target_name: String) -> MeshInstance3D:
	if node == null:
		return null
	if node is MeshInstance3D and String(node.name) == target_name:
		return node as MeshInstance3D
	for child in node.get_children():
		var found := _find_named_mesh(child, target_name)
		if found != null:
			return found
	return null

func _fail(message: String) -> void:
	push_error("V74_WANDERER_PRESENTATION_FAIL:%s" % message)
	quit(1)
