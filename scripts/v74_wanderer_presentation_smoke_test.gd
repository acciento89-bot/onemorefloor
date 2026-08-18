extends SceneTree

const WorldV160Actors = preload("res://scripts/world3d_chamber_v160_actors.gd")

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var world = WorldV160Actors.new()
	root.add_child(world)
	world.set_active(true)
	for _i in range(10):
		await process_frame

	if not bool(world.call("production_actor_presentation_ready")):
		_fail("production actor presentation did not become ready")
		return
	var snapshot: Dictionary = world.debug_snapshot()
	var wanderer: Dictionary = snapshot.get("wanderer_v160", {})
	if int(wanderer.get("mesh_count", 0)) < 22:
		_fail("insufficient v1.60 Wanderer presentation meshes")
		return
	if not bool(wanderer.get("prototype_geometry_hidden", false)):
		_fail("prototype Wanderer geometry was not retired")
		return

	var imported := world.player_root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	if imported == null:
		_fail("imported Wanderer mount missing")
		return
	var old_torso := _find_named_mesh(imported, "Torso")
	var new_torso := _find_named_mesh(imported, "V160Torso")
	var new_hood := _find_named_mesh(imported, "V160Hood")
	var new_blade := _find_named_mesh(imported, "V160Blade")
	var arcane_core := _find_named_mesh(imported, "ArcaneCore")
	if old_torso == null or old_torso.visible:
		_fail("prototype torso is still visible")
		return
	if new_torso == null or not new_torso.visible or not (new_torso.material_override is ShaderMaterial):
		_fail("v1.60 torso presentation missing")
		return
	if new_hood == null or not new_hood.visible or new_blade == null or not new_blade.visible:
		_fail("hood/blade production silhouette missing")
		return
	if arcane_core == null or not arcane_core.visible:
		_fail("animated ArcaneCore was not preserved")
		return

	# Drive the same required production states through the existing v1.54
	# registry. We only changed visible geometry, not animation authority.
	var cases := [
		["idle", 0.0, 0.0, 0.0],
		["run", 1.0, 0.0, 0.0],
		["attack", 0.0, 1.0, 0.0],
		["skill", 0.0, 0.0, 1.0],
	]
	for case_value in cases:
		var case: Array = case_value
		world.actor_factory.animate_player(world.player_root, 0.25, float(case[1]), float(case[2]), float(case[3]))
		await process_frame
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
