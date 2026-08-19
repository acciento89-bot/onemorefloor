# One More Floor — v1.64 Character Lighting State

Canonical checkpoint for the active v1.64 character-lighting/material-integration milestone. **Read this together with `docs/PROJECT_STATE.md`, `docs/V163_COMBAT_IDENTITY_STATE.md` and `docs/UI_V162_STATE.md` before continuing. Repository truth wins over chat memory.**

## Branch / parent
- Active branch: `agent/v1.64-character-lighting` / PR #95.
- Parent branch: `agent/v1.63-combat-identity` / PR #93.
- Starting parent head: `bb4167d9a829c2d3fab006c552ac3b9fc4606670`.
- Accepted v1.63 production rollback: `7262f42002aeeba338559190e8a87a616329ec54`.
- **Accepted v1.64 r1.1 production implementation lock: `b4a63b0be50caa5ed08c9984c2101c059347dfe9`.**
- Accepted v1.62 UI rollback: `71c8ecec5387400af7ef1c4bd29a3f87f9323d17`.
- Accepted v1.61 danger-language rollback: `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- No TestFlight/build/version jump is authorized from individual v1.64 passes.

## Why v1.64 exists
The accepted v1.63 combined gameplay-distance captures exposed the next largest game-wide presentation weakness:
- Wanderer midtones collapsed toward near-black silhouette in normal combat framing;
- dark cloth/steel details lost separation from one another and from the floor;
- dark authored enemies, especially Necromancer, could collapse similarly while Skeleton/Warden highlights sat much brighter;
- the issue was lighting/material integration, **not accepted anatomy, proportions, pivots or combat VFX**.

## Protected systems
1. Do not reopen Wanderer/enemy anatomy, mesh proportions, authored OBJ geometry or rig pivots during the lighting milestone unless a separately proven geometry regression is found.
2. Preserve imported v1.55 glTF animation authority.
3. Preserve v1.63 r1 projectile identity and r2.1 boss-dominance presentation.
4. Preserve all v1.61 r3.2 danger-tell geometry/timing/scale semantics.
5. Preserve v1.62 r3 UI/routes/hitboxes.
6. Do not change combat damage/timing/targeting/hitboxes/projectile collision/input/saves/progression.
7. Stay mobile-friendly: no expensive screen-space lighting dependency merely to fix actor readability.
8. CI green is necessary but gameplay-distance images decide visual acceptance.
9. Preserve rejected/superseded visual passes as history; never silently promote them.

## Active presentation path
- `project.godot`: 720x1280, `gl_compatibility`.
- v1.63 parent: `scenes/main.tscn` -> `scripts/main_v84.gd` -> `world3d_chamber_v163_boss_dominance.gd`.
- v1.64 active top layer: `scenes/main.tscn` -> `scripts/main_v85.gd` -> `world3d_chamber_v164_character_lighting.gd`.
- Final realm grade remains inherited from `world3d_chamber_v160_atmosphere.gd`.
- No new light family was added; the existing key/warm/arcane and Wanderer rim/fill structure is reused.

## v88 frozen baseline
Workflow: **`32284526822` — fully green.**
Artifact: `v88-character-lighting-baseline`.

Frozen 720x1280 references:
1. `baseline_lower_halls_mobs.png`
2. `baseline_ossuary_mobs.png`
3. `baseline_iron_warden.png`

Verdict: Wanderer and dark Necromancer materials lost midtone separation at gameplay distance; this was a material/light integration problem, not geometry or VFX.

## r1 — superseded intermediate
Matched review workflow: **`32285242478` — fully green.**

Wanderer readability improved, but enemy material changes were later overwritten by inherited runtime `configure_enemy()`. Therefore r1 was not promoted as final.

## r1.1 — accepted character-lighting lock
Production implementation: **`b4a63b0be50caa5ed08c9984c2101c059347dfe9`.**
Matched review workflow: **`32286008428` — fully green.**
Artifact ID: **`9377696819`**.

Implementation:
- keeps the r1 Wanderer midtone palette and restrained existing rim/fill adjustment;
- keeps Skeleton as an explicit visual lock;
- lets inherited `configure_enemy()` finish first, then re-applies the five v1.64 enemy body material responses as the final presentation-only runtime write;
- changes no root, mesh, scale, pivot, animation, hitbox, timing or combat state;
- preserves v1.63 boss/projectile/danger presentation underneath.

Matched image verdict:
- Wanderer mean-luminance improvement vs accepted v1.63 parent: approximately +25.4% Lower Halls, +27.5% Ossuary, +48.6% Iron Bastion.
- Necromancer: +8.5% Lower Halls / +14.4% Ossuary.
- Warden: +10.7% Iron Bastion.
- Characters are substantially more readable while the dark-fantasy mood and Warden dominance remain intact.

Regression status in `32286008428`:
- active v1.64 compile/import: PASS;
- v1.64 character-lighting smoke: PASS;
- v1.63 combined combat stack: PASS;
- v1.63 r2.1 boss dominance: PASS;
- v1.63 r1 projectile identity: PASS;
- v1.61 r3.2 danger language: PASS;
- matched 720x1280 before/after render: PASS;
- v1.62 r3 UI: PASS;
- v1.52.1 input flow: PASS.

## Post-acceptance hardening
`v89_character_lighting_r1_smoke_test.gd` now creates a runtime Necromancer + Skeleton and asserts that r1.1 survives inherited enemy configuration while Skeleton remains unchanged. This is an extra future-regression lock; it does not alter accepted r1.1 production values.

At the final pre-documentation observation, the newest hardened v89 Actions job was still **queued** behind the repository's broad historical workflow fanout. It is intentionally recorded as pending rather than falsely marked green.

## Current unsigned iOS device gate — accepted
Latest verified device workflow before the final documentation-only checkpoint:
- `ONE MORE FLOOR iOS Playtest` run **`32286619525` — fully green**.
- Release metadata: PASS.
- Godot headless import: PASS.
- Godot Xcode export: PASS.
- Generated Xcode project inspection: PASS.
- **Unsigned iPhone/iPad device compile: PASS.**
- **Unsigned device package: PASS.**
- Xcode/unsigned iOS artifacts: PASS.
- TestFlight build override: SKIPPED.
- App Store Connect API-key preparation: SKIPPED.
- Release archive/TestFlight export: SKIPPED.
- TestFlight upload: **SKIPPED**.

## Milestone verdict
**v1.64 r1.1 is visually accepted and unsigned-device-build validated.** Character lighting/material integration is complete unless new device/runtime evidence shows a concrete regression.

## Immediate next steps
1. Record the hardened v89 runtime-order regression result when its queued GitHub job eventually executes.
2. Identify the next largest game-wide quality gap from fresh runtime/device captures rather than reopening accepted character geometry, combat VFX, UI or lighting.
3. Create the next stacked milestone branch/PR before production implementation and save its milestone-specific state immediately.
4. Keep TestFlight/build/version jumps off until a deliberate bundled upload decision is made.
