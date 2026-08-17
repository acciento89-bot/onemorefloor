extends "res://scripts/main_v47.gd"

# ONE MORE FLOOR v1.35 — Foundation Environments.
# Floors 1-50 now climb through five authored environment families instead of
# sharing the older generic arena treatment. Each ten-floor band has three
# deterministic chambers, foreground depth, animated ambience and a short
# arrival beat. Combat balance, collision, economy and TestFlight metadata stay
# unchanged.

const V48_VERSION := "1.35.0-foundation-environments"
const V48_BUILD := "22-dev"
const V48_ENV_ATLAS := "res://assets/art/foundation_realms_v48.svg"
const V48_ENV_CELL := Vector2(648.0, 840.0)
const V48_ZONES := ["LOWER HALLS", "OSSUARY", "IRON BASTION", "RIFT DESCENT", "STARLESS SPIRE"]
const V48_CHAMBERS := [
	["GATE OF ASH", "TORCH COURT", "OLD CISTERN"],
	["BONE GALLERY", "MOURNING VAULT", "GREEN CRYPT"],
	["CHAIN WALK", "EMBER ARMORY", "WAR FOUNDRY"],
	["FRACTURE STAIRS", "ARCANE WELL", "NULL CLOISTER"],
	["MOONLESS NAVE", "ASTRAL BRIDGE", "SOVEREIGN APPROACH"],
]

var v48_environment_atlas: Texture2D
var v48_chamber_intro := 0.0
var v48_last_zone := -1
var v48_room_entries := 0

func _ready() -> void:
	super._ready()
	v48_environment_atlas = load(V48_ENV_ATLAS) as Texture2D
	if telemetry != null:
		telemetry.set_build_context(V48_VERSION, V48_BUILD)
	queue_redraw()

func _process(delta: float) -> void:
	super._process(delta)
	v48_chamber_intro = maxf(0.0, v48_chamber_intro - delta)

func spawn_floor() -> void:
	super.spawn_floor()
	if run == null:
		return
	var floor_no := int(run.floor_no)
	if floor_no < 1 or floor_no > 50:
		return
	var zone := _v48_zone_for_floor(floor_no)
	var chamber := _v48_chamber_for_floor(floor_no)
	current_room["v48_zone"] = V48_ZONES[zone]
	current_room["v48_chamber"] = chamber
	current_room["v48_zone_index"] = zone
	v48_chamber_intro = 1.85 if zone == v48_last_zone else 2.35
	v48_last_zone = zone
	v48_room_entries += 1
	if telemetry != null:
		telemetry.event("foundation_chamber_entered", {
			"floor": floor_no,
			"zone": V48_ZONES[zone],
			"chamber": chamber,
			"room_type": String(current_room.get("type", "COMBAT")),
		})

func _v48_zone_for_floor(floor_no: int) -> int:
	return clampi((maxi(1, floor_no) - 1) / 10, 0, 4)

func _v48_chamber_for_floor(floor_no: int) -> String:
	# Floor 50 is the Null Sovereign encounter, so force the final pre-endgame
	# chamber rather than letting the normal three-room cadence wrap around.
	if floor_no == 50:
		return "SOVEREIGN APPROACH"
	var zone := _v48_zone_for_floor(floor_no)
	var start := zone * 10 + 1
	var choices: Array = V48_CHAMBERS[zone]
	return String(choices[posmod(floor_no - start, choices.size())])

func _v48_zone_accent(zone: int) -> Color:
	match zone:
		0: return Color("e1a958")
		1: return Color("7dc7a8")
		2: return Color("e06c55")
		3: return Color("a777f0")
		4: return Color("73c9eb")
	return C_GOLD

func _v48_foundation_floor_active() -> bool:
	return run != null and int(run.floor_no) >= 1 and int(run.floor_no) <= 50

# -----------------------------------------------------------------------------
# Authored floor art.
# -----------------------------------------------------------------------------

func _draw_room_floor() -> void:
	if not _v48_foundation_floor_active() or v48_environment_atlas == null:
		super._draw_room_floor()
		return
	var floor_no := int(run.floor_no)
	var zone := _v48_zone_for_floor(floor_no)
	var src := Rect2(float(zone) * V48_ENV_CELL.x, 0.0, V48_ENV_CELL.x, V48_ENV_CELL.y)
	draw_texture_rect_region(v48_environment_atlas, ARENA, src, Color.WHITE)
	var chamber := String(current_room.get("v48_chamber", _v48_chamber_for_floor(floor_no)))
	var accent := _v48_zone_accent(zone)
	_v48_draw_chamber_floor(zone, chamber, accent)
	_v48_draw_ambient(zone, accent, floor_no)
	# A restrained center falloff keeps actor silhouettes and projectiles readable.
	draw_rect(Rect2(ARENA.position, Vector2(32.0, ARENA.size.y)), Color(0,0,0,0.18))
	draw_rect(Rect2(Vector2(ARENA.end.x-32.0, ARENA.position.y), Vector2(32.0, ARENA.size.y)), Color(0,0,0,0.18))
	draw_rect(ARENA, Color(accent,0.27), false, 2.0)

func _v48_draw_chamber_floor(zone: int, chamber: String, accent: Color) -> void:
	var c := ARENA.get_center()
	match chamber:
		"GATE OF ASH":
			for x in [220.0, 428.0]:
				draw_line(Vector2(x,420),Vector2(x,910),Color(accent,0.13),4.0)
			draw_arc(c+Vector2(0,-170),132.0,PI,TAU,48,Color(accent,0.17),4.0)
		"TORCH COURT":
			for p in [Vector2(150,420),Vector2(498,420),Vector2(150,760),Vector2(498,760)]:
				draw_circle(p,34.0,Color(accent,0.055))
				draw_circle(p,9.0+sin(elapsed*8.0+p.x)*2.0,Color("ffbb55",0.42))
		"OLD CISTERN":
			draw_arc(c+Vector2(0,160),176.0,0,TAU,64,Color("6ca8b0",0.14),4.0)
			draw_arc(c+Vector2(0,160),120.0,0,TAU,56,Color("86cbd2",0.09),2.0)
		"BONE GALLERY":
			for x in [166.0, 482.0]:
				for y in [370.0,510.0,650.0,790.0]:
					draw_arc(Vector2(x,y),24.0,0,TAU,24,Color("d9d1c2",0.14),3.0)
		"MOURNING VAULT":
			draw_colored_polygon(PackedVector2Array([Vector2(246,820),Vector2(282,610),Vector2(366,610),Vector2(402,820)]),Color(accent,0.07))
			for y in [650.0,710.0,770.0]: draw_line(Vector2(255,y),Vector2(393,y),Color(accent,0.12),2.0)
		"GREEN CRYPT":
			for p in [Vector2(178,560),Vector2(470,560)]:
				draw_circle(p,58.0,Color(accent,0.055))
				draw_arc(p,52.0,elapsed*0.12,elapsed*0.12+PI*1.6,40,Color(accent,0.20),3.0)
		"CHAIN WALK":
			for side in [138.0,510.0]:
				for y in range(360,900,66): draw_arc(Vector2(side,float(y)),13.0,0,TAU,18,Color(accent,0.24),3.0)
		"EMBER ARMORY":
			for p in [Vector2(158,710),Vector2(490,710)]:
				draw_colored_polygon(PackedVector2Array([p+Vector2(-34,45),p+Vector2(0,-18),p+Vector2(34,45)]),Color(accent,0.09))
				draw_circle(p,11.0+sin(elapsed*7.0+p.x)*2.0,Color("ff8b5b",0.44))
		"WAR FOUNDRY":
			draw_circle(c+Vector2(0,130),108.0,Color(0,0,0,0.18))
			draw_arc(c+Vector2(0,130),100.0,elapsed*0.10,elapsed*0.10+TAU,56,Color(accent,0.24),5.0)
			for n in range(8):
				var a := TAU*float(n)/8.0
				draw_line(c+Vector2(0,130)+Vector2.from_angle(a)*78.0,c+Vector2(0,130)+Vector2.from_angle(a)*118.0,Color(accent,0.20),3.0)
		"FRACTURE STAIRS":
			for y in [455.0,535.0,615.0,695.0,775.0,855.0]:
				draw_line(Vector2(244,y),Vector2(404,y),Color(accent,0.14),2.0)
			draw_line(Vector2(244,450),Vector2(214,900),Color(accent,0.13),3.0)
			draw_line(Vector2(404,450),Vector2(434,900),Color(accent,0.13),3.0)
		"ARCANE WELL":
			for radius in [54.0,88.0,126.0]:
				draw_arc(c+Vector2(0,150),radius,elapsed*(0.08+radius*0.0003),elapsed*(0.08+radius*0.0003)+TAU,48,Color(accent,0.13),2.0)
		"NULL CLOISTER":
			for p in [Vector2(146,420),Vector2(502,420),Vector2(146,800),Vector2(502,800)]:
				draw_colored_polygon(PackedVector2Array([p+Vector2(0,-22),p+Vector2(14,0),p+Vector2(0,22),p+Vector2(-14,0)]),Color(accent,0.15))
		"MOONLESS NAVE":
			draw_circle(c+Vector2(0,-170),94.0,Color(0,0,0,0.22))
			draw_arc(c+Vector2(0,-170),108.0,-1.3,1.9,56,Color(C_CYAN,0.22),4.0)
		"ASTRAL BRIDGE":
			draw_colored_polygon(PackedVector2Array([Vector2(248,ARENA.end.y),Vector2(294,480),Vector2(354,480),Vector2(400,ARENA.end.y)]),Color(accent,0.08))
			for y in [550.0,640.0,730.0,820.0,910.0]: draw_line(Vector2(244,y),Vector2(404,y),Color(accent,0.10),2.0)
		"SOVEREIGN APPROACH":
			for radius in [78.0,132.0,190.0]: draw_arc(c+Vector2(0,110),radius,-elapsed*0.035,-elapsed*0.035+PI*1.75,56,Color(accent,0.14),2.0)
			for n in range(6):
				var a := TAU*float(n)/6.0+elapsed*0.03
				var p := c+Vector2(0,110)+Vector2.from_angle(a)*156.0
				draw_colored_polygon(PackedVector2Array([p+Vector2(0,-8),p+Vector2(6,0),p+Vector2(0,8),p+Vector2(-6,0)]),Color(accent,0.20))

func _v48_draw_ambient(zone: int, accent: Color, floor_no: int) -> void:
	var speed := 0.30 + float(zone)*0.045
	for n in range(12):
		var seed := float((n*83 + floor_no*41) % 997)
		var x := ARENA.position.x + 30.0 + fmod(seed*3.17, ARENA.size.x-60.0)
		var travel := fmod(elapsed*(18.0+float(n%4)*7.0)*(1.0+speed)+seed, ARENA.size.y-70.0)
		var y := ARENA.end.y-32.0-travel
		var r := 1.2+float(n%3)*0.7
		if zone == 0 or zone == 2:
			draw_circle(Vector2(x,y),r,Color(accent,0.18+float(n%2)*0.08))
		elif zone == 1:
			draw_circle(Vector2(x,y),r+1.0,Color(accent,0.12))
		elif zone == 3:
			draw_line(Vector2(x-5,y+4),Vector2(x+5,y-4),Color(accent,0.13),1.5)
		else:
			draw_circle(Vector2(x,y),r,Color(C_CYAN,0.18+0.08*sin(elapsed*2.0+seed)))

# -----------------------------------------------------------------------------
# Foreground silhouettes / depth pass.
# -----------------------------------------------------------------------------

func _draw_room_architecture() -> void:
	if not _v48_foundation_floor_active():
		super._draw_room_architecture()
		return
	var floor_no := int(run.floor_no)
	var zone := _v48_zone_for_floor(floor_no)
	var accent := _v48_zone_accent(zone)
	var chamber := String(current_room.get("v48_chamber", _v48_chamber_for_floor(floor_no)))
	# Dark side silhouettes keep the playfield readable while adding depth.
	for side in [-1.0,1.0]:
		var x := 57.0 if side < 0.0 else 663.0
		var top_w := 24.0+float(zone)*3.0
		draw_colored_polygon(PackedVector2Array([
			Vector2(x-top_w*side,176),Vector2(x-6.0*side,176),
			Vector2(x+16.0*side,990),Vector2(x-(38.0+float(zone)*4.0)*side,990),
		]),Color(0.010,0.012,0.018,0.82))
		draw_line(Vector2(x,205),Vector2(x+8.0*side,956),Color(accent,0.18),2.0)
	match zone:
		0:
			for p in [Vector2(112,900),Vector2(608,900)]:
				draw_circle(p,24.0,Color("ff9b43",0.08))
				draw_colored_polygon(PackedVector2Array([p+Vector2(-10,12),p+Vector2(0,-28),p+Vector2(10,12)]),Color("ffad4a",0.28))
		1:
			for p in [Vector2(112,864),Vector2(608,864)]: draw_arc(p,28.0,0,TAU,26,Color(accent,0.20),3.0)
		2:
			for p in [Vector2(112,900),Vector2(608,900)]:
				draw_circle(p,30.0,Color(0,0,0,0.28))
				draw_arc(p,26.0,elapsed*0.15,elapsed*0.15+TAU,26,Color(accent,0.32),3.0)
		3:
			for p in [Vector2(112,360),Vector2(608,360)]: draw_line(p,p+Vector2(0,390),Color(accent,0.16),5.0)
		4:
			for p in [Vector2(112,350),Vector2(608,350)]:
				draw_colored_polygon(PackedVector2Array([p+Vector2(0,-32),p+Vector2(18,0),p+Vector2(0,32),p+Vector2(-18,0)]),Color(accent,0.14))
	if chamber in ["OLD CISTERN","GREEN CRYPT","WAR FOUNDRY","ARCANE WELL","SOVEREIGN APPROACH"]:
		var c := ARENA.get_center()+Vector2(0,250)
		draw_arc(c,148.0,elapsed*0.04,elapsed*0.04+PI*1.6,54,Color(accent,0.10),2.0)

# -----------------------------------------------------------------------------
# Arrival presentation.
# -----------------------------------------------------------------------------

func draw_game() -> void:
	super.draw_game()
	if not _v48_foundation_floor_active() or v48_chamber_intro <= 0.0:
		return
	var floor_no := int(run.floor_no)
	var zone := _v48_zone_for_floor(floor_no)
	var chamber := String(current_room.get("v48_chamber", _v48_chamber_for_floor(floor_no)))
	var accent := _v48_zone_accent(zone)
	var alpha := clampf(v48_chamber_intro/0.58,0.0,1.0)
	var plate := Rect2(126,300,468,82)
	draw_rect(plate,Color(0.006,0.008,0.014,0.78*alpha))
	draw_rect(plate,Color(accent,0.50*alpha),false,2.0)
	draw_string(v16_body_font,Vector2(143,326),"FLOOR %d  •  %s" % [floor_no,V48_ZONES[zone]],HORIZONTAL_ALIGNMENT_CENTER,434,11,Color(accent,alpha))
	draw_string(v16_title_font,Vector2(143,357),chamber,HORIZONTAL_ALIGNMENT_CENTER,434,23,Color(V17_IVORY,alpha))
	var room_type := String(current_room.get("type","COMBAT"))
	if room_type in ["BOSS","MINIBOSS","ELITE","AMBUSH"]:
		draw_string(v16_body_font,Vector2(143,375),room_type,HORIZONTAL_ALIGNMENT_CENTER,434,9,Color(C_GOLD,0.82*alpha))

func _v48_foundation_environments_ready() -> bool:
	return v48_environment_atlas is Texture2D and V48_ZONES.size() == 5 and V48_CHAMBERS.size() == 5 and _v48_chamber_for_floor(1) == "GATE OF ASH" and _v48_chamber_for_floor(50) == "SOVEREIGN APPROACH" and _v47_foundation_visuals_ready()
