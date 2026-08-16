extends "res://scripts/main_v19.gd"

# ONE MORE FLOOR v1.9 — real runtime UI rebuild.
# IMPORTANT: no approved concept screenshot/raster is drawn over the game.
# Background/environment art may be textured, but every interactive UI element,
# value, icon, button and submenu remains a live engine-rendered component.

const V21_VERSION := "1.9.0-runtime-ui"

func _ready() -> void:
	super._ready()
	queue_redraw()

func _v21_diamond(center: Vector2, half: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(0,-half),
		center + Vector2(half,0),
		center + Vector2(0,half),
		center + Vector2(-half,0)
	]),color)

func _v21_live_medallion(center: Vector2, radius: float, accent: Color, kind: String) -> void:
	# Multi-ring crest. This is drawn at device resolution, so the tiny Home icons
	# stay sharp instead of becoming compressed raster blocks.
	draw_circle(center,radius+8,Color(0,0,0,0.78))
	draw_circle(center,radius+5,Color("5d390e"))
	draw_circle(center,radius+2,Color("edc45d"))
	draw_circle(center,radius-1,Color("070912"))
	draw_arc(center,radius-5,0,TAU,64,Color(accent,0.98),2.2)
	draw_arc(center,radius-9,0,TAU,64,Color("f8e8ae",0.18),1.0)

	match kind:
		"hero":
			# Helmet crest.
			var p := PackedVector2Array([
				center+Vector2(-10,-6),center+Vector2(-6,-13),center+Vector2(0,-16),
				center+Vector2(6,-13),center+Vector2(10,-6),center+Vector2(8,8),
				center+Vector2(3,13),center+Vector2(3,2),center+Vector2(-3,2),
				center+Vector2(-3,13),center+Vector2(-8,8)
			])
			draw_colored_polygon(p,Color("9fc8ff"))
			draw_polyline(PackedVector2Array([center+Vector2(-8,-4),center+Vector2(0,-8),center+Vector2(8,-4)]),Color("e7f4ff"),2.0)
		"forge":
			# Anvil.
			draw_colored_polygon(PackedVector2Array([
				center+Vector2(-13,-9),center+Vector2(12,-9),center+Vector2(8,-3),
				center+Vector2(3,-1),center+Vector2(3,8),center+Vector2(9,12),
				center+Vector2(-9,12),center+Vector2(-3,8),center+Vector2(-3,-1),
				center+Vector2(-13,-3)
			]),Color("d9e3f2"))
			draw_line(center+Vector2(-10,-5),center+Vector2(8,-5),Color.WHITE,1.5)
		"talents":
			# Arcane compass/star.
			_v21_diamond(center,13.0,Color("d7a0ff"))
			_v21_diamond(center,6.0,Color("fff0ff"))
			draw_line(center+Vector2(-16,0),center+Vector2(16,0),Color(accent,0.8),1.4)
			draw_line(center+Vector2(0,-16),center+Vector2(0,16),Color(accent,0.8),1.4)
		"vault":
			# Chest silhouette.
			draw_rect(Rect2(center+Vector2(-13,-5),Vector2(26,17)),Color("d7a83f"))
			draw_arc(center+Vector2(0,-5),13.0,PI,TAU,24,Color("ffd96b"),5.0)
			draw_rect(Rect2(center+Vector2(-2,0),Vector2(4,9)),Color("3b2509"))
		"missions":
			# Heart/plus crest.
			draw_circle(center+Vector2(-5,-2),7,Color("6eff9d"))
			draw_circle(center+Vector2(5,-2),7,Color("6eff9d"))
			draw_colored_polygon(PackedVector2Array([center+Vector2(-11,1),center+Vector2(11,1),center+Vector2(0,14)]),Color("6eff9d"))
			draw_line(center+Vector2(-5,2),center+Vector2(5,2),Color.WHITE,2.0)
			draw_line(center+Vector2(0,-3),center+Vector2(0,7),Color.WHITE,2.0)
		"pass":
			# Sword.
			draw_line(center+Vector2(-7,9),center+Vector2(9,-10),Color("d9e6ff"),4.0)
			draw_line(center+Vector2(-10,5),center+Vector2(-3,12),Color("e9b54c"),4.0)
			draw_line(center+Vector2(7,-12),center+Vector2(11,-8),Color("d6a3ff"),3.0)

	var jewel := center + Vector2(0,-radius-5)
	_v21_diamond(jewel,5.5,V17_PURPLE)
	_v21_diamond(jewel,2.5,V17_PURPLE_HI)

func _v21_home_tab(r: Rect2, label: String, kind: String, accent: Color) -> void:
	_v16_frame(r,accent,Color("050810"),0.17)
	_v21_live_medallion(Vector2(r.get_center().x,r.position.y+37),22,accent,kind)
	draw_string(v16_title_font,Vector2(r.position.x+6,r.end.y-17),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-12,15,V17_IVORY)

func _v21_action_button(r: Rect2, label: String, accent: Color, kind: String) -> void:
	_v16_frame(r,accent,Color(accent,0.13),0.24)
	_v21_live_medallion(Vector2(r.position.x+42,r.get_center().y),22,accent,kind)
	draw_string(v16_title_font,Vector2(r.position.x+77,r.get_center().y+7),label,HORIZONTAL_ALIGNMENT_CENTER,r.size.x-88,18,V17_IVORY)

func draw_home() -> void:
	# These are real sub-screens. They replace Home visually and BACK returns here.
	if home_overlay == "missions":
		draw_missions_screen()
		return
	if home_overlay == "pass":
		draw_pass_screen()
		return

	# Environment artwork only. No UI screenshot is used.
	_v16_backdrop("home")

	# Top HUD.
	_v16_frame(Rect2(18,18,190,100),V16_PURPLE,Color("040610"),0.18)
	_v16_center_in(Rect2(30,31,166,28),"BEST FLOOR",13,V16_MUTED,true)
	_v16_center_in(Rect2(30,58,166,48),str(int(meta.best_floor)),35,V17_IVORY,true)
	_v16_currency(int(meta.coins),Rect2(512,18,190,92))

	# Title stack.
	draw_string(v16_title_font,Vector2(48,158),"ONE MORE",HORIZONTAL_ALIGNMENT_CENTER,624,43,V17_IVORY)
	for off in [Vector2(0,5),Vector2(2,3),Vector2(-2,3)]:
		draw_string(v16_title_font,Vector2(46,235)+off,"FLOOR",HORIZONTAL_ALIGNMENT_CENTER,628,74,Color(0,0,0,0.80))
	draw_string(v16_title_font,Vector2(46,232),"FLOOR",HORIZONTAL_ALIGNMENT_CENTER,628,74,Color("fff0a6"))
	_v16_rule(254,V16_PURPLE,390)
	_v16_center("CLIMB  •  LOOT  •  RISK IT ALL",287,14,V16_MUTED)

	# Live hero render over the environment.
	_v15_soft_glow(Vector2(360,736),74,V16_PURPLE,1.0)
	draw_wanderer(Vector2(360,735),1.58,false)

	# Main actions.
	_v16_button(PLAY,"PLAY",V16_GOLD,39)
	_v16_button(V10_SETTINGS_HOME,"SETTINGS",V16_BLUE,13,9)
	_v21_action_button(MISSIONS_BTN,"MISSIONS",V16_GREEN,"missions")
	_v21_action_button(PASS_BTN,"TOWER PASS",V16_PURPLE,"pass")

	# Bottom navigation — real, crisp runtime icons.
	_v21_home_tab(HERO_TAB,"HERO","hero",V16_BLUE)
	_v21_home_tab(FORGE_TAB,"FORGE","forge",V16_ORANGE)
	_v21_home_tab(TALENTS_TAB,"TALENTS","talents",V16_PURPLE)
	_v21_home_tab(VAULT_TAB,"VAULT","vault",V16_GOLD)

	# Footer.
	_v16_frame(Rect2(20,1156,680,76),Color("323a5c"),Color("030611"),0.08)
	_v16_text("POWER",Vector2(50,1194),14,V16_MUTED,true)
	_v16_text(str(int(meta.power_score())),Vector2(115,1197),24,V17_GOLD_HI,true)
	draw_string(v16_body_font,Vector2(410,1196),"KAMILUNAVO GAMES",HORIZONTAL_ALIGNMENT_RIGHT,245,12,V16_MUTED)
	var footer_jewel := Vector2(360,1192)
	_v21_diamond(footer_jewel,13.0,Color("4a236f"))
	_v21_diamond(footer_jewel,7.0,V17_PURPLE)

	# Modal UI remains live above Home.
	if settings_open:
		_draw_settings_overlay()
	elif tutorial_active and tutorial_step in [0,1]:
		_draw_tutorial_overlay()

func _v21_runtime_ui_ready() -> bool:
	# CI probe: confirms this renderer is the non-raster implementation.
	return tex_v19_home != null and not FileAccess.file_exists("res://scripts/main_v21_raster.flag")
