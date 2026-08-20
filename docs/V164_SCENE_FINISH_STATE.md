# One More Floor — v1.64 Scene Finish State

Canonical checkpoint for the active v1.64 scene-finish milestone. Read this together with `docs/PROJECT_STATE.md`, `docs/UI_V162_STATE.md` and `docs/V163_COMBAT_IDENTITY_STATE.md` before continuing. Repository truth wins over chat memory.

## Branch / parent
- Active branch: `agent/v1.64-scene-finish`.
- Parent branch: `agent/v1.63-combat-identity` / PR #93.
- Starting parent head: `bb4167d9a829c2d3fab006c552ac3b9fc4606670`.
- Accepted v1.63 production implementation lock: `7262f42002aeeba338559190e8a87a616329ec54`.
- v1.63 is visually complete; do not add more combat VFX in this milestone.
- No TestFlight/build/version jump is authorized from individual v1.64 passes.

## Why v1.64 exists
The accepted v1.63 gameplay-distance captures prove UI, projectile identity, boss identity and danger-language readability are now coherent. The largest remaining game-wide visual gap is scene finish rather than combat VFX quantity:
- large floor/wall masses still read too blocky and flat at gameplay distance;
- hard near-black shadow regions crush material/readability;
- authored actors and props do not separate enough from the environment through lighting/material depth;
- the overall image still trends toward a prototype/low-cost 3D read despite the accepted authored geometry.

v1.64 therefore targets **lighting, value structure, grounding and material-depth presentation** across the gameplay scene while preserving accepted geometry and gameplay authority.

## Protected systems
1. Preserve the complete accepted v1.63 combat-identity stack and its visual hierarchy.
2. Do not change combat damage, timing, targeting, hit radii, warning windows, projectile collision/input authority, saves or progression.
3. Preserve v1.61 r3.2 Focus/Charge/Phase/Slam/Ritual warning geometry and semantics.
4. Preserve v1.62 r3 UI, routes and hitboxes.
5. Preserve Wanderer/enemy authored geometry, imported animation authority and pivots.
6. Do not reopen v1.60 authored environment composition by replacing accepted meshes with blockouts.
7. Keep GL Compatibility/mobile cost discipline; avoid screen-space effects or expensive texture-heavy solutions unless separately justified and measured.
8. CI green is necessary but gameplay-distance captures decide visual acceptance.
9. Prefer a narrow top-layer scene-finish subclass over rewriting validated lower layers.
10. Update this file immediately after every meaningful accepted/rejected pass.

## Baseline visual evidence
Current accepted gameplay-distance evidence to compare against:
- v1.63 combined review `combined_fan_exchange.png`;
- v1.63 combined review `combined_slam_loot.png`;
- v1.63 combined review `combined_mob_pressure.png`;
- v1.60/character gallery and Wanderer close-up captures remain supporting references when judging actor/environment separation.

Baseline verdict for v1.64 target: **combat readability accepted; global scene finish still below target**.

## Initial v1.64 goals
1. Freeze a dedicated current-stack baseline across representative realms/floors before modifying production presentation.
2. Improve ambient/fill/rim balance so dark forms retain readable midtones instead of collapsing into black.
3. Add restrained material/value separation between floor masses, architectural props and actors without reintroducing neon/full-ring clutter.
4. Improve contact/grounding and local focal-light hierarchy while keeping danger tells/projectiles dominant when active.
5. Preserve performance/mobile compatibility and existing gameplay/collision/animation authority.
6. Validate with identical before/after gameplay-distance captures, then run the v1.63, v1.62, input and unsigned iOS device regressions.

## Current next step
Create the v1.64 Draft PR stacked on PR #93, then build a **baseline-only scene-finish capture gate**. Do not change production lighting/material code until the baseline capture and current-stack regressions are green.
