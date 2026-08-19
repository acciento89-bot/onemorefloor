# One More Floor — v1.64 Character Lighting State

Canonical checkpoint for the active v1.64 character-lighting/material-integration milestone. **Read this together with `docs/PROJECT_STATE.md`, `docs/V163_COMBAT_IDENTITY_STATE.md` and `docs/UI_V162_STATE.md` before continuing. Repository truth wins over chat memory.**

## Branch / parent
- Active branch: `agent/v1.64-character-lighting`.
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

## Immediate next steps
1. Trace the actual current actor materials, WorldEnvironment/ambient light, directional/key/fill lights and any per-actor lights in the active v1.63 world stack.
2. Freeze dedicated v1.64 lighting baselines at identical 720x1280 gameplay framing before production changes.
3. Implement the smallest shared lighting/material integration pass on the verified active path.
4. Compare Wanderer, normal mobs and Warden in at least a dark/cool and warm/boss context.
5. Preserve v1.63/v1.62/v1.61/input regressions.
