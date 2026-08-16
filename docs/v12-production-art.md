# v1.2 Production Art Integration

v1.2 moves the live game from the prototype/vector-debug presentation toward the approved dark-fantasy concept language while preserving the stable v1.1 gameplay, responsive layout, touch coordinates, save data and adaptive audio.

## Visual targets

- Midnight stone surfaces and dungeon architecture.
- Ornamental gold frames and beveled fantasy panels.
- Purple crystal / arcane accents with biome-specific secondary colors.
- Strong silhouettes for Wanderer, enemies and bosses.
- Clear readable mobile HUD and progression screens.
- No player-facing development/version labels.

## New runtime assets

- `assets/art/fantasy_actor_atlas.svg` — 1600 × 1200, 12 actor rows.
- `assets/art/fantasy_biomes.svg` — 2592 × 840, four authored room treatments.
- `scripts/main_v12.gd` — reusable fantasy panels/icons plus screen and combat rendering hooks.

## Screens covered

Home, Hero, Forge, Talents, Vault, Missions, Tower Pass, Combat HUD, Upgrade selection, Cash-out decision, Game Over, Pause, Settings and Tutorial.

## Compatibility strategy

v1.2 extends `main_v11.gd` instead of rewriting the gameplay stack. Existing hitboxes, run logic, save formats, audio contexts, room generation and boss behavior remain unchanged. The previous motion/external SVG systems remain in the inheritance chain as fallbacks.

## Playtest goal

The v1.2 TestFlight build is the first on-device pass intended to judge the new concept-inspired art direction as a cohesive game rather than as a prototype. Follow-up passes should use real-device screenshots to refine scale, density, typography, contrast and animation richness.
