extends "res://scripts/main_v25.gd"

# v1.13 compatibility layer: main_v25 owns the new reward/combo/affix kill
# pipeline, while this layer restores the animated actor-death FX that earlier
# combat renderers and regression tests expect.

const V26_VERSION := "1.13-combos-affixes-summary"

func remove_dead() -> void:
	var dying: Array[Dictionary] = []
	for e in enemies:
		if float(e.get("hp", 1.0)) <= 0.0:
			dying.append(e.duplicate(true))

	super.remove_dead()

	for e in dying:
		effects.append({
			"type":"actor_death",
			"pos":e.get("pos", Vector2.ZERO),
			"age":0.0,
			"dur":0.46,
			"color":Color.WHITE,
			"kind":String(e.get("type", "goblin")),
			"variant":String(e.get("boss_variant", "warden")),
			"size":maxf(62.0, float(e.get("radius", 22.0)) * 2.7)
		})
