# One More Floor — v1.64 Character Lighting State

Canonical checkpoint for the active v1.64 character-lighting/material-integration milestone. **Read this together with `docs/PROJECT_STATE.md`, `docs/V163_COMBAT_IDENTITY_STATE.md` and `docs/UI_V162_STATE.md` before continuing. Repository truth wins over chat memory.**

## Branch / parent
- Active branch: `agent/v1.64-character-lighting` / PR #95.
- Parent branch: `agent/v1.63-combat-identity` / PR #93.
- Starting parent head: `bb4167d9a829c2d3fab006c552ac3b9fc4606670`.
- Accepted v1.63 production rollback: `7262f42002aeeba338559190e8a87a616329ec54`.
- Accepted v1.62 UI rollback: `71c8ecec5387400af7ef1c4bd29a3f87f9323d17`.
- Accepted v1.61 danger-language rollback: `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- No TestFlight/build/version jump is authorized from individual v1.64 passes.

## Why v1.64 exists
The accepted v1.63 combined gameplay-distance captures exposed the next largest game-wide presentation weakness:
- Wanderer midtones collapse toward near-black silhouette in normal combat framing;
- dark cloth/steel details lose separation from one another and from the floor;
- some enemy/Warden surfaces hit much brighter values, creating inconsistent actor readability;
- the issue is lighting/material integration, **not accepted anatomy, proportions, pivots or combat VFX**.

## v1.64 goal
Improve character readability and material separation at gameplay distance while preserving the established dark-fantasy palette:
- recover controlled Wanderer midtones without flattening the silhouette;
- separate cloth / steel / brass / arcane materials through restrained key/fill/rim response;
- keep enemies readable without bleaching bone/metal or turning the scene into bright studio lighting;
- preserve realm mood and mobile GL Compatibility constraints;
- prefer shared actor-light/material integration over per-screenshot hacks.

## Protected systems
1. Do not reopen Wanderer/enemy anatomy, mesh proportions, authored OBJ geometry or rig pivots during the lighting milestone unless a separately proven geometry regression is found.
2. Preserve imported v1.55 glTF animation authority.
3. Preserve v1.63 r1 projectile identity and r2.1 boss-dominance presentation.
4. Preserve all v1.61 r3.2 danger-tell geometry/timing/scale semantics.
5. Preserve v1.62 r3 UI/routes/hitboxes.
6. Do not change combat damage/timing/targeting/hitboxes/projectile collision/input/saves/progression.
7. Stay mobile-friendly: no expensive screen-space lighting dependency merely to fix actor readability.
8. CI green is necessary but gameplay-distance images decide visual acceptance.
9. Update this file immediately after every meaningful accepted/rejected pass.

## Starting image diagnosis
Current accepted v1.63 combined captures are the initial evidence:
- `combined_mob_pressure.png`: Wanderer reads almost as a black silhouette while enemy bones/props occupy much brighter values.
- `combined_fan_exchange.png`: Warden receives strong highlights while Wanderer cloth/armor separation is weak at the same gameplay camera.
- `combined_slam_loot.png`: use as regression reference for boss tell/VFX density while adjusting actor readability.

These captures are accepted v1.63 composition/VFX references; v1.64 must not change their combat semantics.

## Verified active presentation path
The v1.64 trace is complete before production edits:
- `project.godot` remains 720x1280 on `gl_compatibility`.
- `scenes/main.tscn` runs `scripts/main_v84.gd`.
- `main_v84.gd` instantiates `world3d_chamber_v163_boss_dominance.gd`; the accepted v1.63 r2.1 world is therefore the active combat presentation owner.
- Final realm grade comes from `world3d_chamber_v160_atmosphere.gd`, which intentionally writes after inherited v1.49 lookdev.
- Existing shared scene lights are `MoonKey`, `WarmTorchLight`, `ArcaneLight`, plus Wanderer `player_rim_light`, `player_fill_light` and transient `player_combat_light`.
- The Wanderer uses the authored v1.60 OBJ layer on the preserved v1.55 articulated glTF pivots.
- Authored Wanderer pieces resolve to `wanderer_materials` from `world3d_actor_factory_v160.gd`; notably cloth base `#1b243a` and dark steel base `#242d3b` are already very dark.
- `v160_surface_depth.gdshader` is the active lightweight GL-compatible material shader. It starts base shading at 0.88 and subtracts up to 0.10 on undersides, so dark base materials can lose gameplay-distance midtone separation even though the scene already has key/fill/rim lighting.

### Working diagnosis
Do **not** solve v1.64 by stacking extra decorative lights. The verified path already has the required shared lighting structure. First compare frozen images; then prefer a restrained shared material/lighting response correction on this active path.

## v88 dedicated lighting baseline gate
Baseline-only files were added before any production lighting/material change:
- `scripts/v88_character_lighting_baseline_smoke_test.gd`
- `scripts/v88_character_lighting_baseline_capture.gd`
- `.github/workflows/v88-character-lighting-baseline.yml`

The gate fixes three 720x1280 gameplay-distance references:
1. `baseline_lower_halls_mobs.png` — neutral Lower Halls mixed mobs.
2. `baseline_ossuary_mobs.png` — cool Ossuary mixed mobs.
3. `baseline_iron_warden.png` — warm Iron Bastion Warden context with accepted r2.1 boss dominance retained.

Required regressions inside v88:
- accepted v1.63 combined stack;
- v1.63 r2.1 boss dominance;
- v1.63 r1 projectile identity;
- v1.61 r3.2 danger language;
- v1.62 r3 UI;
- v1.52.1 input flow;
- authored Wanderer readiness and GL Compatibility ownership.

First v88 workflow run: `32284526822` (started from branch head `d93e6ad613fedff687ed39c6c5329a02a96aeb28`; result/image review still pending at this checkpoint).

## Immediate next steps
1. Finish v88 workflow and inspect all three baseline PNGs at native gameplay framing.
2. Record exact image verdict before touching production lighting/material code.
3. Implement the smallest shared v1.64 integration pass on the verified active path.
4. Produce matched before/after captures for Lower Halls, Ossuary and Iron Bastion/Warden.
5. Preserve v1.63/v1.62/v1.61/input regressions and keep TestFlight/build/version jumps off.
