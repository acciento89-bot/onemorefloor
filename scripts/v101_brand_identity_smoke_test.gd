extends SceneTree

# ONE MORE FLOOR v1.74 — Branding + Product Identity contract.
# Shipping identity may change; all accepted v1.73 gameplay/input authority stays inherited.

const EXPECTED_ICON := "res://assets/art/app_icon_v174.svg"
const LEGACY_ICON := "res://assets/art/wanderer.svg"

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene failed to load")
		return
	var app = packed.instantiate()
	root.add_child(app)
	for _i in range(14):
		await process_frame

	var script = app.get_script()
	if script == null or String(script.resource_path) != "res://scripts/main_v98.gd":
		_fail("main_v98 is not the active production entrypoint")
		return
	if not app.has_method("_v98_brand_identity_ready") or not bool(app.call("_v98_brand_identity_ready")):
		_fail("v1.74 brand identity readiness failed")
		return
	if not app.has_method("_v97_run_flow_ready") or not bool(app.call("_v97_run_flow_ready")):
		_fail("v1.73 run-flow lock regressed")
		return

	var project_icon := String(ProjectSettings.get_setting("application/config/icon", ""))
	if project_icon != EXPECTED_ICON or project_icon == LEGACY_ICON:
		_fail("shipping app icon path is not the v1.74 identity")
		return
	var icon_texture := load(EXPECTED_ICON) as Texture2D
	if icon_texture == null:
		_fail("v1.74 app icon failed to import as Texture2D")
		return
	if icon_texture.get_width() != 1024 or icon_texture.get_height() != 1024:
		_fail("v1.74 app icon must be exactly 1024x1024")
		return

	var previous: Dictionary = app.call("_v97_run_flow_snapshot")
	if not bool(previous.get("ready", false)) or bool(previous.get("input_override", true)):
		_fail("v1.73 authority snapshot regressed")
		return

	var snapshot: Dictionary = app.call("_v98_brand_identity_snapshot")
	if not bool(snapshot.get("ready", false)):
		_fail("v1.74 snapshot not ready")
		return
	if String(snapshot.get("version", "")) != "1.74-branding-product-identity-r1.1":
		_fail("v1.74 r1.1 version marker invalid")
		return
	if bool(snapshot.get("legacy_icon_active", true)) or bool(snapshot.get("input_override", true)):
		_fail("legacy icon/input override contract invalid")
		return
	if not bool(snapshot.get("home_crest_compact_r11", false)):
		_fail("r1.1 compact Home crest correction missing")
		return

	print("V174_BRAND_IDENTITY_SNAPSHOT:%s" % JSON.stringify(snapshot))
	print("v1.74 branding product identity smoke test passed")
	app.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error("V174_BRAND_IDENTITY_FAIL:%s" % message)
	quit(1)
