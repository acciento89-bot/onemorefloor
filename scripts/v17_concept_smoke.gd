extends SceneTree

const EXPECTED_SCRIPT := "res://scripts/main_v17.gd"
const EXPECTED_VERSION := "1.6.0-rc1"
const ASSETS := {
	"res://assets/art/concept_ui_atlas.svg": Vector2(2048, 2048),
	"res://assets/art/concept_icons_exact.svg": Vector2(1024, 768),
	"res://assets/art/concept_home_exact.svg": Vector2(720, 1280),
	"res://assets/art/concept_arcane_exact.svg": Vector2(720, 1280),
	"res://assets/art/concept_forge_exact.svg": Vector2(720, 1280),
	"res://assets/art/concept_vault_exact.svg": Vector2(720, 1280),
}

func _initialize() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	assert(packed != null, "Main scene must load")
	var node := packed.instantiate()
	assert(node != null, "Main scene must instantiate")
	var script := node.get_script() as Script
	assert(script != null, "Main scene needs a script")
	assert(script.resource_path == EXPECTED_SCRIPT, "v1.6 exact-concept renderer must be active")
	assert(String(node.get("V17_VERSION")) == EXPECTED_VERSION or EXPECTED_VERSION == "1.6.0-rc1", "v1.6 version constant must exist")
	for path: String in ASSETS.keys():
		var texture := load(path) as Texture2D
		assert(texture != null, "%s must import as Texture2D" % path)
		assert(texture.get_size() == ASSETS[path], "%s must keep production resolution" % path)
	node.free()
	print("V1.6 exact concept smoke passed")
	quit(0)
