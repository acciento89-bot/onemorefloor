extends "res://scripts/world3d_chamber_v161_combat_presentation.gd"

# ONE MORE FLOOR v1.61 r2.1 — motion-echo cleanup.
# Keeps the accepted r1.1 combat language and r2 impact bursts, but replaces the
# inherited v1.49 Wanderer motion echo (ring + three rune boxes) with restrained
# directional floor streaks. Presentation only: movement authority, speed,
# collision, input and the inherited MOVE_ECHO timing remain unchanged.

const COMBAT_PRESENTATION_R21_VERSION := "1.61-combat-presentation-r2.1"

var v161_move_echo_mesh: ArrayMesh
var v161_move_echo_material: StandardMaterial3D

func _ready() -> void:
	super._ready()
	_upgrade_v161_motion_echoes()

func production_combat_presentation_ready() -> bool:
	return super.production_combat_presentation_ready() and _v161_motion_echo_ready()

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["combat_presentation_v161_version"] = COMBAT_PRESENTATION_R21_VERSION
	data["combat_presentation_v161_motion_streaks"] = _v161_motion_echo_ready()
	return data

func _upgrade_v161_motion_echoes() -> void:
	v161_move_echo_material = _transparent_emissive(Color("9270c9", 0.16), 0.44)
	v161_move_echo_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	v161_move_echo_mesh = _build_v161_motion_streaks()

	for value in move_echo_pool:
		var echo := value as Node3D
		if echo == null:
			continue
		var ring := echo.get_node_or_null("Ring") as MeshInstance3D
		if ring != null:
			ring.mesh = v161_move_echo_mesh
			ring.material_override = v161_move_echo_material
			ring.position = Vector3(0.0, 0.030, 0.0)
			ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for rune_index in range(3):
			var rune := echo.get_node_or_null("Rune%d" % rune_index) as MeshInstance3D
			if rune != null:
				rune.visible = false

func _v161_motion_echo_ready() -> bool:
	if move_echo_pool.is_empty():
		return false
	var echo := move_echo_pool[0] as Node3D
	if echo == null:
		return false
	var streak := echo.get_node_or_null("Ring") as MeshInstance3D
	if streak == null or not (streak.mesh is ArrayMesh):
		return false
	for rune_index in range(3):
		var rune := echo.get_node_or_null("Rune%d" % rune_index) as MeshInstance3D
		if rune != null and rune.visible:
			return false
	return true

func _sync_player_move_echo(joy: Vector2) -> void:
	if player_root == null or joy.length_squared() < 0.20 or move_echo_pool.is_empty():
		return
	var feet_socket: Node3D = actor_factory.call("actor_socket", player_root, "feet") as Node3D
	var current_position: Vector3 = feet_socket.global_position if feet_socket != null else player_root.global_position
	if last_player_echo_position.x > 9000.0:
		last_player_echo_position = current_position
		return
	if current_position.distance_to(last_player_echo_position) < 0.48:
		return
	last_player_echo_position = current_position
	var echo := move_echo_pool[move_echo_cursor % move_echo_pool.size()] as Node3D
	move_echo_cursor = (move_echo_cursor + 1) % move_echo_pool.size()
	if echo == null:
		return
	echo.visible = true
	echo.global_position = current_position + Vector3(0.0, 0.02, 0.0)
	echo.scale = Vector3.ONE
	# The streak geometry extends down local +Z. Rotate it behind the current
	# movement direction rather than spinning the old circular glyph.
	echo.rotation = Vector3(0.0, atan2(joy.x, joy.y) + PI, 0.0)
	echo.set_meta("age", 0.0)

func _animate_move_echoes(delta: float) -> void:
	for echo_value in move_echo_pool:
		var echo := echo_value as Node3D
		if echo == null or not echo.visible:
			continue
		var age: float = float(echo.get_meta("age", 0.0)) + delta
		echo.set_meta("age", age)
		if age >= MOVE_ECHO_DURATION:
			echo.visible = false
			continue
		var t: float = clampf(age / MOVE_ECHO_DURATION, 0.0, 1.0)
		# Keep the directional read stable; only lengthen slightly as the echo ages.
		echo.scale = Vector3(0.92 + t * 0.10, 1.0, 0.84 + t * 0.34)
		echo.position.y += delta * 0.025

func _build_v161_motion_streaks() -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var offsets := [-0.16, 0.0, 0.16]
	var lengths := [0.46, 0.62, 0.46]
	for index in range(offsets.size()):
		var x: float = float(offsets[index])
		var length: float = float(lengths[index])
		var start_z := 0.02
		var end_z := length
		var start_half_width := 0.040 if index == 1 else 0.030
		var end_half_width := 0.010
		var a := Vector3(x - start_half_width, 0.0, start_z)
		var b := Vector3(x - end_half_width, 0.0, end_z)
		var c := Vector3(x + end_half_width, 0.0, end_z)
		var d := Vector3(x + start_half_width, 0.0, start_z)
		_v161_add_quad(tool, a, b, c, d)
	return tool.commit()
