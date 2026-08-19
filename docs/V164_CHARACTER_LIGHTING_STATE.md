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

## Verified active presentation path
- `project.godot`: 720x1280, `gl_compatibility`.
- v1.63 parent: `scenes/main.tscn` -> `scripts/main_v84.gd` -> `world3d_chamber_v163_boss_dominance.gd`.
- v1.64 active top layer: `scenes/main.tscn` -> `scripts/main_v85.gd` -> `world3d_chamber_v164_character_lighting.gd`.
- Final realm grade still comes from inherited `world3d_chamber_v160_atmosphere.gd`.
- No new light family was added. Existing `MoonKey`, `WarmTorchLight`, `ArcaneLight`, Wanderer rim/fill and transient combat light remain the intended shared structure.
- Wanderer authored pieces use `wanderer_materials`; original dark bases included cloth `#1b243a` and dark steel `#242d3b`.
- Authored enemy body cores use the r5.1 character shader; accepted Necromancer setup re-applies `#181222` during `configure_enemy()`.
- Both lightweight character surface paths begin around a 0.88 shape-light baseline and darken undersides, which is mobile-safe but can crush already-dark base colors at gameplay distance.

## v88 frozen baseline — accepted diagnostic
Workflow: **`32284526822` — fully green.**
Artifact: `v88-character-lighting-baseline`.

Frozen 720x1280 references:
1. `baseline_lower_halls_mobs.png`
2. `baseline_ossuary_mobs.png`
3. `baseline_iron_warden.png`

Baseline verdict:
- Wanderer was nearly black in all three normal gameplay frames.
- Necromancer also lost useful midtones in cool/dark realms.
- Skeleton and Warden remained much easier to parse.
- This confirmed a character material/light integration issue rather than a geometry or VFX issue.

## r1 — technically green, visually incomplete intermediate
Primary matched review workflow: **`32285242478` — fully green.**
Artifact: `v89-character-lighting-r1-before-after`.

What worked:
- Wanderer cloth/steel/cape midtones recovered clearly.
- Existing local rim/fill lights were only nudged; no new lights or expensive rendering path were introduced.
- In matched player crops, mean luminance improved approximately +25% Lower Halls, +27% Ossuary and +49% Iron Bastion.

Why r1 was not locked:
- Enemy material changes were written once during `_ready()`.
- Inherited Enemy Quality r2/r3 later re-applied archetype `base_color` from `configure_enemy()` during runtime.
- Matched enemy crops were therefore effectively unchanged despite green tests.
- r1 is a useful intermediate but **must not be promoted over r1.1**.

## r1.1 — accepted character-lighting lock
Production implementation: **`b4a63b0be50caa5ed08c9984c2101c059347dfe9`.**
Matched review workflow: **`32286008428` — fully green.**
Artifact ID: **`9377696819`** (`v89-character-lighting-r1-before-after`, r1.1 head).

Implementation:
- keeps the r1 Wanderer midtone palette and restrained existing rim/fill range/energy adjustment;
- keeps Skeleton as an explicit visual lock;
- lets inherited `configure_enemy()` finish first, then re-applies the five v1.64 enemy body material responses as the **final presentation-only runtime write**;
- changes no enemy root, mesh, scale, pivot, animation, hitbox, timing or combat state;
- keeps v1.63 boss/projectile/danger presentation underneath untouched.

Matched image verdict:
- Lower Halls Wanderer remains substantially more readable without losing dark silhouette; Necromancer gains controlled violet separation.
- Ossuary Wanderer cloth/cape becomes readable against teal floor; Necromancer no longer collapses into an almost black mass.
- Iron Bastion Wanderer becomes readable against the warm floor while Warden remains dominant and boss presentation is not washed out.
- Approximate matched-crop mean-luminance deltas vs accepted v1.63 parent: Wanderer +25.4% Lower Halls, +27.5% Ossuary, +48.6% Iron Bastion; Necromancer +8.5% Lower Halls / +14.4% Ossuary; Warden +10.7% Iron Bastion.
- Visual direction is **accepted**: more readable characters, still dark-fantasy, no studio-light flattening.

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
`v89_character_lighting_r1_smoke_test.gd` is hardened to create an actual runtime Necromancer + Skeleton and assert that r1.1 remains the final material write after inherited enemy configuration while Skeleton remains unchanged.

`main_v85.gd` and `scenes/main.tscn` identify the active top layer as **v1.64 r1.1**. These naming/checkpoint edits do not change the accepted production material/light values from `b4a63b0...`.

At the final pre-documentation observation, the newest hardened v89 Actions job was still **queued** behind the repository's broad historical workflow fanout. This extra regression job is intentionally recorded as pending, not falsely marked green. The accepted production r1.1 review is independently fully green.

## Current unsigned iOS device gate — accepted
Latest verified device workflow before the documentation-only checkpoint:
- `ONE MORE FLOOR iOS Playtest` run **`32286619525` — fully green**.
- Release metadata: PASS.
- Godot headless import: PASS.
- Godot Xcode export: PASS.
- Generated Xcode project inspection: PASS.
- **Unsigned iPhone/iPad device compile: PASS.**
- **Unsigned device package: PASS.**
- Xcode/unsigned iOS artifact upload: PASS.
- TestFlight build override: SKIPPED.
- App Store Connect API-key preparation: SKIPPED.
- Release archive/TestFlight export: SKIPPED.
- TestFlight upload: **SKIPPED**.

This validates the r1.1 integration on the real iOS device-compile path without creating or uploading a TestFlight build.

## Milestone verdict
**v1.64 r1.1 is visually accepted and unsigned-device-build validated.**

Do not add another general brightness/material lift merely because the milestone remains open as a Draft PR. Reopen character lighting only if new device/runtime evidence shows a concrete readability regression.

## Immediate next steps
1. Record the hardened v89 runtime-order regression result when its queued GitHub job eventually executes; this is an extra regression lock, not a blocker for the accepted r1.1 visual/device verdict.
2. Treat character lighting/material integration as visually complete.
3. Identify the next largest game-wide quality gap from fresh runtime/device captures rather than reopening accepted character geometry, combat VFX, UI or lighting.
4. Create the next stacked milestone branch/PR before its production implementation and save its milestone-specific state immediately.
5. Keep TestFlight/build/version jumps off until a deliberate bundled upload decision is made.
