# One More Floor — v1.63 Combat Identity State

Canonical checkpoint for the v1.63 combat-identity milestone. **Read this together with `docs/PROJECT_STATE.md` and `docs/UI_V162_STATE.md` before continuing. Repository truth wins over chat memory.**

## Branch / parent
- Pull request: **#93 — `v1.63 combat identity milestone`**.
- Active branch: `agent/v1.63-combat-identity`.
- Parent: `agent/v1.62-ui-foundation` / PR #92.
- Starting parent head: `1d05a87b347bcdcfda5b21d40b74b476cadab42f`.
- Accepted v1.62 UI rollback: `71c8ecec5387400af7ef1c4bd29a3f87f9323d17`.
- Accepted v1.61 combat-presentation rollback: `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- PR #93 remains **Draft**.
- No TestFlight upload/build-number bump/version jump has been authorized or performed for v1.63.

## Current accepted v1.63 production lock
**`7262f42002aeeba338559190e8a87a616329ec54` — projectile identity r1 + boss dominance r2.1.**

Commits after that lock are diagnostic/documentation only unless this file explicitly says otherwise.

## Protected systems
1. v1.63 is presentation-only. Do not change combat damage, timing, targeting, hit radii, warning windows, projectile collision/input authority, saves or progression.
2. Preserve v1.61 r3.2 Focus/Charge/Phase/Slam/Ritual warning geometry and semantics.
3. Preserve v1.62 r3 UI, routes and hitboxes.
4. Preserve Wanderer r11, enemy anatomy/surface work, imported animation authority and pivots.
5. CI green is necessary but runtime captures decide visual acceptance.
6. A technically green but visually ineffective pass stays rejected.
7. Update this file after every meaningful accepted/rejected pass.

# Projectile / trail identity

## Frozen legacy baseline
Diagnostic commit: `3eb4d60bb4701a78b7366249285326ba803dbda1`.
Workflow-marker correction only: `1b399f9d892013e139f1b07504077a559449b150`.

Verified old release-facing visuals:
- player projectile head: `SphereMesh`;
- enemy projectile head: `SphereMesh`;
- player/enemy trails: straight `BoxMesh` history bars;
- v1.51 projectile collision authority remained separate from those visible meshes.

Frozen captures: `baseline_player_projectiles.png`, `baseline_enemy_projectiles.png`, `baseline_mixed_projectiles.png`.
Verdict: **rejected production quality**, retained as honest comparison.

## r1 — accepted projectile identity
Implementation: **`4877c228d11319ad1db18e6bf12b5d2442b37ac9`**.
Workflow: **`32276028440` — fully green.**

Accepted changes:
- player head -> slim faceted blade-shard ArrayMesh;
- enemy head -> wider thorn/crystal-dart ArrayMesh;
- player trail -> tapered emissive wake;
- enemy trail -> tapered wake using the shot's inherited hostile color;
- inherited history still owns trail midpoint/length/direction;
- no new gameplay nodes/pools and no release metadata change.

Authority smoke preserves:
- player shot design radius `10.0`;
- enemy shot design radius `9.0`;
- player hit radius `28.0`;
- v1.51 projectile authority;
- v1.62 r3 UI.

Accepted captures: `r1_player_projectiles.png`, `r1_enemy_projectiles.png`, `r1_mixed_projectiles.png`.
Friendly and hostile fire now separate through **shape + color**, not color alone.

# Boss presentation

## Frozen boss baseline
Diagnostics: `606fd07a401858a4ff5223b95536791d607c8fbb`, `05f71abf32014d59353517a000638cd24807aae1`, final baseline lock `b8b68f1d8a2cb07b418d4ff028c9cd5c4b646eb7`.
Workflow: **`32277193240` — fully green.**

Recovered persistent legacy decoration:
- v1.46 frame: Torus halo ~2.16 X/Z, Cylinder beam ~2.75 high, four Box crown rods, red light;
- v1.49 `BossDominanceLookdev`: outer ring ~1.28, inner ring ~0.82, eight Box markers, separate range-4.4 dominance light.

Frozen captures: `baseline_boss_intro.png`, `baseline_boss_fan.png`, `baseline_boss_crown_slam.png`.
Verdict: **rejected production target** because persistent circular decoration competed with gameplay-significant r3.2 fan/focus and slam tells.

## r2 — technically green, visually rejected
Implementation: **`9f4ea8d51f32ec712385db6d5d7263502f9998d0`**.
Workflow: **`32278164808` — fully green.**

r2 correctly cleaned the older v1.46 frame: broken floor anchors, shorter fractured spire, faceted crown shards and reduced frame light. Strict smoke kept all five r3.2 tell AABBs identical to r1.

**Manual verdict: REJECTED.** Screenshots remained almost identical because the dominant visible ring was actually v1.49 `BossDominanceLookdev`. Keep r2 only as a technically valid intermediate fallback.

## r2.1 — accepted boss identity / current production lock
Implementation: **`7262f42002aeeba338559190e8a87a616329ec54`**.
Workflow: **`32279185350` — fully green.**
Before/after artifact: **`9375230747`**.

r2.1 targets the actual v1.49 owner:
- outer dominance ring -> four open L-like bracket groups;
- inner dominance ring -> four small inward chevrons;
- eight inherited marker nodes remain structurally present but all use faceted ArrayMeshes and only four remain visible;
- dominance-light range reduced from 4.4 to 2.85 with restrained energy;
- rotation/pulse reduced;
- r2's quieter v1.46 frame remains underneath.

Strict r2.1 proof:
- outer/inner are ArrayMeshes, not TorusMesh;
- only four dominance markers visible and none use BoxMesh;
- dominance-light range <= 2.90;
- r2 technical layer remains ready;
- r1 projectile identity remains ready;
- v1.62 r3 UI remains ready;
- Focus/Charge/Phase/Slam/Ritual tell AABBs remain **exactly identical** to accepted r1 reference geometry.

Accepted captures:
- `r21_boss_intro.png`: permanent large decorative ring gone; Warden stays focal;
- `r21_boss_fan.png`: directional focus warning and hostile shards are the dominant combat intent;
- `r21_boss_crown_slam.png`: radial teeth remain because they are the intended gameplay tell, while the second decorative circle is gone.

# Coherent combined gameplay review — accepted
Diagnostic commit: **`1e1591b28f859e4ccdff6d5034f4d768931d7cd4`**.
Workflow: **`32280114378` — fully green.**
Artifact: **`9375524836`**.

The diagnostic changes no production visuals. It combines the accepted r1/r2.1 stack with current impacts, spawn/death signatures and loot feedback at gameplay distance.

Accepted captures:
- `combined_fan_exchange.png` — fan/focus direction remains readable with Warden + adds + friendly/hostile shards + current impact feedback;
- `combined_slam_loot.png` — slam teeth remain uniquely readable with friendly shots plus death/loot/impact feedback;
- `combined_mob_pressure.png` — non-boss mixed fire remains readable alongside current spawn signatures and impacts.

Manual verdict: **accepted**. No additional VFX-decoration pass is justified; adding more would increase clutter rather than quality.

Therefore **v1.63 combat identity is visually complete at production lock `7262f420...`.**

# iPhone/iPad device milestone gate
`ONE MORE FLOOR iOS Playtest` run **`32280114299`** on the accepted production stack plus diagnostic-only files is fully green:
- release metadata verification: PASS
- Godot 4.7.1 import: PASS
- Godot Xcode export: PASS
- generated Xcode project inspection: PASS
- unsigned iPhone/iPad device build: PASS
- unsigned device app packaging/artifact upload: PASS
- TestFlight build override: SKIPPED
- App Store Connect key preparation: SKIPPED
- release archive/TestFlight export: SKIPPED
- TestFlight upload: **SKIPPED**

So v1.63 is **TestFlight-ready from visual + unsigned-device-build perspective**, but no upload is authorized or performed.

# Validation summary
- Projectile r1 `32276028440`: green + visually accepted.
- Boss baseline `32277193240`: green baseline, visually rejected target.
- Boss r2 `32278164808`: technically green, visually rejected.
- Boss r2.1 `32279185350`: green + visually accepted.
- Combined review `32280114378`: green + visually accepted.
- iPhone/iPad unsigned device `32280114299`: green; TestFlight skipped.
- v1.61 r3.2 danger language: preserved.
- v1.62 r3 UI: preserved.
- v1.52.1 input flow: preserved.

# Non-negotiable v1.63 rules
1. Preserve **`7262f420...`** as the accepted v1.63 production rollback point.
2. Preserve `4877c228...` as projectile-only fallback.
3. Preserve `9f4ea8d5...` only as rejected/technical r2 intermediate.
4. Preserve frozen baseline and accepted comparison captures.
5. Do not change v1.51 projectile authority/radii or Warden cast semantics/tell timing/scale/damage while doing unrelated presentation work.
6. Do not regress to generic glowing balls, straight debug bars, full decorative boss rings, tall generic light columns, box-rod crowns or excessive particle clutter.
7. Preserve v1.61 r3.2 danger language and v1.62 r3 UI.
8. CI green does not override visual rejection.
9. No TestFlight/build/version jump without a deliberate bundled milestone decision.
10. Update this file after every future meaningful pass.

# Next development direction
1. **Do not add more combat VFX to v1.63.** The milestone is visually complete.
2. Next chat/session must first read `docs/PROJECT_STATE.md`, this file, and `docs/UI_V162_STATE.md`.
3. Choose the next largest game-wide quality gap as a separate milestone/branch rather than reopening accepted v1.63 visuals.
4. PR #93 stays Draft until a deliberate merge/release sequence is chosen.
5. If a TestFlight build is wanted, trigger it deliberately as a bundled milestone; do not auto-upload from this checkpoint.
