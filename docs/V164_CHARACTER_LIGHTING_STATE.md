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
The accepted v1.63 combined gameplay-distance captures exposed the next largest game-wide presentation weakness: Wanderer and other very dark authored character materials lost useful midtone separation at gameplay distance. The issue was lighting/material integration, **not accepted anatomy, proportions, pivots or combat VFX**.

## Protected systems
1. Preserve Wanderer/enemy anatomy, authored geometry and rig pivots.
2. Preserve imported v1.55 glTF animation authority.
3. Preserve v1.63 projectile identity and boss-dominance presentation.
4. Preserve v1.61 r3.2 danger-tell geometry/timing/scale semantics.
5. Preserve v1.62 r3 UI/routes/hitboxes.
6. Do not change combat damage/timing/targeting/hitboxes/projectile collision/input/saves/progression.
7. Stay mobile-friendly; no expensive screen-space dependency for actor readability.
8. Runtime/gameplay-distance images decide visual acceptance; CI green alone is insufficient.

## Active presentation path
- 720x1280, `gl_compatibility`.
- `scenes/main.tscn` -> `scripts/main_v85.gd` -> `world3d_chamber_v164_character_lighting.gd`.
- v1.64 remains a narrow presentation layer on top of accepted v1.63 r2.1.
- Existing key/warm/arcane + Wanderer rim/fill lights are reused; no new light family was introduced.

## v88 baseline
Workflow **`32284526822` — fully green**.

Frozen 720x1280 references:
- `baseline_lower_halls_mobs.png`
- `baseline_ossuary_mobs.png`
- `baseline_iron_warden.png`

Verdict: Wanderer was close to black silhouette; Necromancer also lost midtones. Skeleton/Warden remained substantially easier to parse.

## r1 — superseded intermediate
Workflow **`32285242478` — fully green**, but visually incomplete for enemies. Wanderer improved, while inherited runtime `configure_enemy()` overwrote the one-time enemy material changes. Never promote r1 over r1.1.

## r1.1 — accepted lock
Production implementation: **`b4a63b0be50caa5ed08c9984c2101c059347dfe9`.**
Matched review workflow: **`32286008428` — fully green.**
Artifact: **`9377696819`**.

r1.1:
- preserves the improved Wanderer midtone palette and restrained existing rim/fill adjustment;
- preserves Skeleton as a visual lock;
- lets inherited enemy configuration finish first, then reapplies the accepted v1.64 enemy material response as the final presentation-only runtime write;
- changes no geometry, animation, gameplay, timing, hitbox or collision authority.

Matched visual deltas vs accepted v1.63 parent:
- Wanderer: about +25.4% Lower Halls, +27.5% Ossuary, +48.6% Iron Bastion mean crop luminance;
- Necromancer: +8.5% Lower Halls / +14.4% Ossuary;
- Warden: +10.7% Iron Bastion.

Visual verdict: **accepted** — materially clearer characters without flattening the dark-fantasy realm mood or Warden dominance.

Regression status in `32286008428`:
- v1.64 compile/import: PASS;
- character-lighting smoke: PASS;
- v1.63 combined combat: PASS;
- v1.63 boss r2.1: PASS;
- v1.63 projectile r1: PASS;
- v1.61 danger language: PASS;
- matched before/after render: PASS;
- v1.62 UI: PASS;
- v1.52.1 input: PASS.

## Post-acceptance hardening
`v89_character_lighting_r1_smoke_test.gd` now creates a runtime Necromancer + Skeleton and asserts that r1.1 survives inherited enemy configuration while Skeleton stays unchanged. This is an additional future-regression lock, not a production-value change.

At the final pre-documentation observation, the newest hardened v89 Actions job was still **queued** behind the repository's broad historical workflow fanout. It is deliberately recorded as pending, not falsely reported green.

## Unsigned iOS device gate — accepted
Latest verified device workflow before the final documentation-only checkpoint: **`32286619525` — fully green.**

- release metadata: PASS;
- Godot import: PASS;
- Xcode export/project inspection: PASS;
- **unsigned iPhone/iPad device compile: PASS**;
- **unsigned device package: PASS**;
- unsigned artifacts: PASS;
- TestFlight build override: SKIPPED;
- App Store Connect API key: SKIPPED;
- release archive/TestFlight export: SKIPPED;
- TestFlight upload: **SKIPPED**.

## Milestone verdict
**v1.64 r1.1 is visually accepted and unsigned-device-build validated. Character lighting/material integration is complete unless new device/runtime evidence proves a concrete regression.**

## Next
1. Record the hardened v89 runtime-order regression result when its queued job eventually executes.
2. Identify the next largest quality gap from fresh runtime/device captures instead of reopening accepted character geometry, combat VFX, UI or lighting.
3. Start the next milestone as a stacked branch/PR and save its state immediately.
4. Keep TestFlight/build/version jumps off until a deliberate bundled upload decision.
