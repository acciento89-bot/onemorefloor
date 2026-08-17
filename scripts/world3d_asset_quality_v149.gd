extends RefCounted

# ONE MORE FLOOR v1.49 — production asset quality gate.
# This does not invent or bundle binary models. It describes the production
# contract and inspects real imported actor scenes when they eventually arrive.

const REQUIRED_SOCKETS := ["weapon", "head", "chest", "feet", "overhead", "vfx"]
const REQUIRED_ANIMATIONS := ["idle", "run", "attack"]
const RECOMMENDED_ANIMATIONS := ["hit", "skill", "spawn", "death"]

const PROFILES := {
	"wanderer": {"role":"hero", "target_height_m":1.86, "max_mesh_nodes":10, "max_material_slots":14, "recommended_triangles":28000, "texture_budget_mb":18},
	"goblin": {"role":"melee_light", "target_height_m":1.20, "max_mesh_nodes":8, "max_material_slots":10, "recommended_triangles":14000, "texture_budget_mb":10},
	"bat": {"role":"flying_light", "target_height_m":0.88, "max_mesh_nodes":7, "max_material_slots":9, "recommended_triangles":12000, "texture_budget_mb":8},
	"skeleton": {"role":"melee_medium", "target_height_m":1.72, "max_mesh_nodes":9, "max_material_slots":11, "recommended_triangles":17000, "texture_budget_mb":11},
	"ghoul": {"role":"melee_brute", "target_height_m":1.76, "max_mesh_nodes":9, "max_material_slots":11, "recommended_triangles":18000, "texture_budget_mb":11},
	"necromancer": {"role":"caster", "target_height_m":1.82, "max_mesh_nodes":10, "max_material_slots":13, "recommended_triangles":22000, "texture_budget_mb":14},
	"warden": {"role":"boss", "target_height_m":2.35, "max_mesh_nodes":14, "max_material_slots":18, "recommended_triangles":38000, "texture_budget_mb":24},
}

func profile(kind: String) -> Dictionary:
	var selected: Dictionary = PROFILES.get(kind, PROFILES["goblin"])
	return selected.duplicate(true)

func known_profile_count() -> int:
	return PROFILES.size()

func inspect_actor(root: Node3D, registry: Variant = null) -> Dictionary:
	if root == null:
		return {"ready": false, "tier": "missing", "reason": "null_root"}
	var kind: String = String(root.get_meta("production_contract_kind", root.get_meta("actor_kind", "")))
	if kind.is_empty() and bool(root.get_meta("production_contract_player", false)):
		kind = "wanderer"
	var imported := root.get_node_or_null("Motion/RigMount/ImportedModel") as Node3D
	var source: String = "imported" if imported != null else "native_fallback"
	var inspect_root: Node = imported if imported != null else root
	var counts: Dictionary = {
		"node3d": 0,
		"mesh_nodes": 0,
		"material_slots": 0,
		"skeletons": 0,
		"animation_players": 0,
		"animation_trees": 0,
	}
	var animation_names: Array = []
	_scan_tree(inspect_root, counts, animation_names)
	var socket_coverage: Dictionary = _socket_coverage(root, imported, registry)
	var animation_coverage: Dictionary = _animation_coverage(animation_names)
	var required_sockets_ok := true
	for socket_value in REQUIRED_SOCKETS:
		if not bool(socket_coverage.get(String(socket_value), false)):
			required_sockets_ok = false
			break
	var required_animations_ok := true
	for animation_value in REQUIRED_ANIMATIONS:
		if not bool(animation_coverage.get(String(animation_value), false)):
			required_animations_ok = false
			break
	var skeleton_ok: bool = int(counts.get("skeletons", 0)) > 0
	var visible_geometry_ok: bool = int(counts.get("mesh_nodes", 0)) > 0
	var tier := "native_fallback"
	if imported != null:
		tier = "production_candidate" if skeleton_ok and visible_geometry_ok and required_animations_ok and required_sockets_ok else "import_needs_work"
	return {
		"ready": source == "native_fallback" or tier == "production_candidate",
		"tier": tier,
		"kind": kind,
		"source": source,
		"profile": profile(kind),
		"counts": counts,
		"socket_coverage": socket_coverage,
		"animation_coverage": animation_coverage,
		"required_sockets_ok": required_sockets_ok,
		"required_animations_ok": required_animations_ok,
		"skeleton_ok": skeleton_ok,
		"visible_geometry_ok": visible_geometry_ok,
	}

func snapshot() -> Dictionary:
	return {
		"profiles": PROFILES.size(),
		"required_sockets": REQUIRED_SOCKETS.size(),
		"required_animations": REQUIRED_ANIMATIONS.size(),
		"recommended_animations": RECOMMENDED_ANIMATIONS.size(),
	}

func _scan_tree(node: Node, counts: Dictionary, animation_names: Array) -> void:
	if node is Node3D:
		counts["node3d"] = int(counts["node3d"]) + 1
	if node is MeshInstance3D:
		counts["mesh_nodes"] = int(counts["mesh_nodes"]) + 1
		var mesh_node := node as MeshInstance3D
		if mesh_node.mesh != null:
			counts["material_slots"] = int(counts["material_slots"]) + mesh_node.mesh.get_surface_count()
	if node is Skeleton3D:
		counts["skeletons"] = int(counts["skeletons"]) + 1
	if node is AnimationPlayer:
		counts["animation_players"] = int(counts["animation_players"]) + 1
		var player := node as AnimationPlayer
		for animation_name_value in player.get_animation_list():
			var normalized: String = String(animation_name_value).to_lower()
			if not animation_names.has(normalized):
				animation_names.append(normalized)
	if node is AnimationTree:
		counts["animation_trees"] = int(counts["animation_trees"]) + 1
	for child in node.get_children():
		_scan_tree(child, counts, animation_names)

func _socket_coverage(root: Node3D, imported: Node3D, registry: Variant) -> Dictionary:
	var data: Dictionary = {}
	for socket_value in REQUIRED_SOCKETS:
		var socket_name: String = String(socket_value)
		var covered := false
		if imported != null and registry != null and registry.has_method("resolve_socket"):
			covered = registry.call("resolve_socket", imported, socket_name) != null
		if not covered:
			covered = root.get_node_or_null("ProductionSockets/%s" % _socket_node_name(socket_name)) != null
		data[socket_name] = covered
	return data

func _socket_node_name(logical_name: String) -> String:
	match logical_name:
		"weapon": return "WeaponSocket"
		"head": return "HeadSocket"
		"chest": return "ChestSocket"
		"feet": return "FeetSocket"
		"overhead": return "OverheadSocket"
		"vfx": return "VFXSocket"
		_: return logical_name.capitalize().replace(" ", "") + "Socket"

func _animation_coverage(animation_names: Array) -> Dictionary:
	var data: Dictionary = {}
	var all_states: Array = REQUIRED_ANIMATIONS + RECOMMENDED_ANIMATIONS
	for state_value in all_states:
		var state: String = String(state_value)
		var aliases: Array = _aliases_for(state)
		var matched := false
		for name_value in animation_names:
			var name_text: String = String(name_value).to_lower()
			for alias_value in aliases:
				var alias_text: String = String(alias_value).to_lower()
				if name_text == alias_text or name_text.contains(alias_text):
					matched = true
					break
			if matched:
				break
		data[state] = matched
	return data

func _aliases_for(state: String) -> Array:
	match state:
		"idle": return ["idle", "stand"]
		"run": return ["run", "jog", "locomotion", "walk"]
		"attack": return ["attack", "slash", "melee", "swing"]
		"hit": return ["hit", "hitreact", "damage"]
		"skill": return ["skill", "cast", "spell", "summon"]
		"spawn": return ["spawn", "appear", "summon"]
		"death": return ["death", "die", "dead"]
		_: return [state]
