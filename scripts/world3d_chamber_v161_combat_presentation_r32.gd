extends "res://scripts/world3d_chamber_v161_combat_presentation_r31.gd"

# ONE MORE FLOOR v1.61 r3.2 — directional danger-language pass.
# Replaces the remaining universal rotating segmented enemy ring with attack-family
# shapes that preserve the inherited tell trigger, position and radius scale.
# Gameplay timing, hit radius, damage and enemy behavior remain untouched.

const COMBAT_PRESENTATION_R32_VERSION := "1.61-combat-presentation-r3.2"

const V161_TELL_KEYS := [
	"attack_cd", "dash_cd", "dive_cd", "blink_cd", "lunge_cd",
	"phase_cd", "slam_cd", "summon_cd", "teleport_cd"
]

var v161_tell_focus_mesh: ArrayMesh
var v161_tell_charge_mesh: ArrayMesh
var v161_tell_phase_mesh: ArrayMesh
var v161_tell_slam_mesh: ArrayMesh
var v161_tell_ritual_mesh: ArrayMesh

func _ready() -> void:
	super._ready()
	_build_v161_directional_tell_language()

func production_combat_presentation_ready() -> bool:
	return super.production_combat_presentation_ready() and _v161_directional_tells_ready()

func debug_snapshot() -> Dictionary:
	var data: Dictionary = super.debug_snapshot()
	data["combat_presentation_v161_version"] = COMBAT_PRESENTATION_R32_VERSION
	data["combat_presentation_v161_directional_tells"] = _v161_directional_tells_ready()
	return data

func _build_v161_directional_tell_language() -> void:
	v161_tell_focus_mesh = _build_v161_focus_tell()
	v161_tell_charge_mesh = _build_v161_charge_tell()
	v161_tell_phase_mesh = _build_v161_phase_tell()
	v161_tell_slam_mesh = _build_v161_slam_tell()
	v161_tell_ritual_mesh = _build_v161_ritual_tell()

func _apply_v161_enemy_presentation(enemies: Array) -> void:
	super._apply_v161_enemy_presentation(enemies)
	for index in range(mini(telegraph_pool.size(), enemies.size())):
		var tell := telegraph_pool[index] as MeshInstance3D
		if tell == null:
			continue
		var enemy: Dictionary = enemies[index]
		var tell_key := _v161_active_tell_key(enemy)
		if tell_key.is_empty():
			continue
		var mode := _v161_tell_mode(enemy, tell_key)
		tell.mesh = _v161_tell_mesh_for_mode(mode)
		# The inherited _sync_ground_telegraphs() owns visibility, position, pulse
		# and radius scale. r3.2 changes only local shape/orientation.
		if mode == "focus" or mode == "charge":
			_v161_point_tell_at_player(tell)
		elif mode == "phase":
			tell.rotation.y = runtime_elapsed * 0.16 + float(enemy.get("phase", 0.0)) * 0.12
		elif mode == "slam":
			tell.rotation.y = runtime_elapsed * 0.10
		else:
			tell.rotation.y = -runtime_elapsed * 0.14 + float(enemy.get("phase", 0.0)) * 0.10

func _v161_active_tell_key(enemy: Dictionary) -> String:
	var best := 99.0
	var best_key := ""
	for key_value in V161_TELL_KEYS:
		var key := String(key_value)
		var value := float(enemy.get(key, 0.0))
		if value > 0.001 and value < best:
			best = value
			best_key = key
	if best > 0.34:
		return ""
	return best_key

func _v161_tell_mode(enemy: Dictionary, tell_key: String = "") -> String:
	var cast_kind := String(enemy.get("cast_kind", ""))
	if cast_kind == "crown":
		return "slam"
	if cast_kind == "fan":
		return "focus"
	var key := tell_key if not tell_key.is_empty() else _v161_active_tell_key(enemy)
	match key:
		"dash_cd", "dive_cd", "lunge_cd":
			return "charge"
		"blink_cd", "phase_cd", "teleport_cd":
			return "phase"
		"slam_cd":
			return "slam"
		"summon_cd":
			return "ritual"
		_:
			return "focus"

func _v161_tell_mesh_for_mode(mode: String) -> ArrayMesh:
	match mode:
		"charge": return v161_tell_charge_mesh
		"phase": return v161_tell_phase_mesh
		"slam": return v161_tell_slam_mesh
		"ritual": return v161_tell_ritual_mesh
		_: return v161_tell_focus_mesh

func _v161_point_tell_at_player(tell: MeshInstance3D) -> void:
	if player_root == null:
		return
	var to_player := player_root.global_position - tell.global_position
	to_player.y = 0.0
	if to_player.length_squared() <= 0.0001:
		return
	tell.rotation.y = atan2(to_player.x, -to_player.z)

func _v161_directional_tells_ready() -> bool:
	for mesh_value in [
		v161_tell_focus_mesh, v161_tell_charge_mesh, v161_tell_phase_mesh,
		v161_tell_slam_mesh, v161_tell_ritual_mesh
	]:
		if mesh_value == null or not (mesh_value is ArrayMesh):
			return false
	return true

func _build_v161_focus_tell() -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	_v161_add_arc_band(tool, 0.54, 0.68, -0.64, 0.64, 12)
	# Forward spear reproduces the old readable 2D aim-line semantics in 3D.
	_v161_add_triangle(tool, Vector3(0.0, 0.0, -0.68), Vector3(0.085, 0.0, -0.39), Vector3(-0.085, 0.0, -0.39))
	_v161_add_quad(tool,
		Vector3(-0.026, 0.0, -0.40), Vector3(0.026, 0.0, -0.40),
		Vector3(0.026, 0.0, -0.12), Vector3(-0.026, 0.0, -0.12)
	)
	return tool.commit()

func _build_v161_charge_tell() -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Two compact lane rails plus a single forward arrowhead. Maximum reach stays
	# at the same 0.68 local radius as the accepted segmented tell.
	for side in [-1.0, 1.0]:
		var x := side * 0.21
		_v161_add_quad(tool,
			Vector3(x - 0.032, 0.0, 0.28), Vector3(x + 0.032, 0.0, 0.28),
			Vector3(x + 0.032, 0.0, -0.43), Vector3(x - 0.032, 0.0, -0.43)
		)
	_v161_add_triangle(tool, Vector3(0.0, 0.0, -0.68), Vector3(0.20, 0.0, -0.43), Vector3(-0.20, 0.0, -0.43))
	_v161_add_triangle(tool, Vector3(0.0, 0.0, 0.38), Vector3(-0.10, 0.0, 0.24), Vector3(0.10, 0.0, 0.24))
	return tool.commit()

func _build_v161_phase_tell() -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(4):
		var angle := PI * 0.25 + TAU * float(index) / 4.0
		var radial := Vector3(sin(angle), 0.0, -cos(angle))
		var tangent := Vector3(cos(angle), 0.0, sin(angle))
		var inner := radial * 0.46
		var outer := radial * 0.68
		_v161_add_quad(tool,
			inner - tangent * 0.075, outer - tangent * 0.032,
			outer + tangent * 0.032, inner + tangent * 0.075
		)
		var hook := inner - radial * 0.02
		_v161_add_quad(tool,
			hook - tangent * 0.15 - radial * 0.024,
			hook + tangent * 0.15 - radial * 0.024,
			hook + tangent * 0.15 + radial * 0.024,
			hook - tangent * 0.15 + radial * 0.024
		)
	return tool.commit()

func _build_v161_slam_tell() -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(8):
		var angle := TAU * float(index) / 8.0
		var radial := Vector3(sin(angle), 0.0, -cos(angle))
		var tangent := Vector3(cos(angle), 0.0, sin(angle))
		var inner_center := radial * 0.50
		var outer_center := radial * 0.68
		_v161_add_quad(tool,
			inner_center - tangent * 0.038,
			outer_center - tangent * 0.090,
			outer_center + tangent * 0.090,
			inner_center + tangent * 0.038
		)
	return tool.commit()

func _build_v161_ritual_tell() -> ArrayMesh:
	var tool := SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for index in range(6):
		var angle := TAU * float(index) / 6.0
		var radial := Vector3(sin(angle), 0.0, -cos(angle))
		var tangent := Vector3(cos(angle), 0.0, sin(angle))
		var outer := radial * 0.66
		var tip := radial * 0.43
		_v161_add_triangle(tool, tip, outer + tangent * 0.075, outer - tangent * 0.075)
		var tick_center := radial * 0.68
		_v161_add_quad(tool,
			tick_center - tangent * 0.095 - radial * 0.020,
			tick_center + tangent * 0.095 - radial * 0.020,
			tick_center + tangent * 0.095 + radial * 0.020,
			tick_center - tangent * 0.095 + radial * 0.020
		)
	return tool.commit()

func _v161_add_arc_band(tool: SurfaceTool, inner_radius: float, outer_radius: float, start_angle: float, end_angle: float, segments: int) -> void:
	for index in range(segments):
		var t0 := float(index) / float(segments)
		var t1 := float(index + 1) / float(segments)
		var a0 := lerpf(start_angle, end_angle, t0)
		var a1 := lerpf(start_angle, end_angle, t1)
		var i0 := _v161_polar_point(a0, inner_radius, 0.0)
		var o0 := _v161_polar_point(a0, outer_radius, 0.0)
		var i1 := _v161_polar_point(a1, inner_radius, 0.0)
		var o1 := _v161_polar_point(a1, outer_radius, 0.0)
		_v161_add_quad(tool, i0, o0, o1, i1)
