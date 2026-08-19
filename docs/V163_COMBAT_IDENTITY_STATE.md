# One More Floor — v1.63 Combat Identity State

Canonical checkpoint for the active v1.63 combat-identity milestone. **Read this together with `docs/PROJECT_STATE.md` and `docs/UI_V162_STATE.md` before continuing. Repository truth wins over chat memory.**

## Branch / parent
- Pull request: **#93 — `v1.63 combat identity milestone`**.
- Active branch: `agent/v1.63-combat-identity`.
- Parent: `agent/v1.62-ui-foundation` / PR #92.
- Starting parent head: `1d05a87b347bcdcfda5b21d40b74b476cadab42f`.
- Accepted v1.62 UI rollback: `71c8ecec5387400af7ef1c4bd29a3f87f9323d17`.
- Accepted v1.61 combat-presentation rollback: `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- PR #93 remains **Draft**. No TestFlight/build/version jump is authorized from individual v1.63 passes.

## Protected systems
1. Keep v1.63 presentation-only. Do not change combat damage, timing, targeting, hit radii, warning windows, projectile collision/input authority, saves or progression.
2. Preserve v1.61 r3.2 Focus/Charge/Phase/Slam/Ritual warning geometry and semantics.
3. Preserve v1.62 r3 UI, routes and hitboxes.
4. Preserve Wanderer r11, enemy anatomy/surface work, imported animation authority and pivots.
5. CI green is necessary but runtime captures decide visual acceptance.
6. A technically green but visually ineffective pass stays rejected.
7. Update this file immediately after every meaningful accepted/rejected pass.

# Projectile / trail identity

## Frozen legacy projectile baseline
Diagnostic commit: `3eb4d60bb4701a78b7366249285326ba803dbda1`.
Workflow-marker-only correction: `1b399f9d892013e139f1b07504077a559449b150`.

Verified active legacy visuals before r1:
- player projectile head: `SphereMesh`;
- enemy projectile head: `SphereMesh`;
- player/enemy trails: straight `BoxMesh` history bars from v1.41;
- v1.51 `world3d_projectile_authority_v151.gd` owns collision separately from visible meshes.

Frozen captures:
- `baseline_player_projectiles.png`
- `baseline_enemy_projectiles.png`
- `baseline_mixed_projectiles.png`

Visual verdict: **rejected as production quality / retained only as comparison**. Friendly and hostile fire looked like the same bright ball + luminous stick family and relied too much on color.

## r1 — accepted projectile identity
Implementation: **`4877c228d11319ad1db18e6bf12b5d2442b37ac9`**.
Dedicated workflow: **`32276028440` — fully green.**

Accepted changes:
- player head -> slim faceted blade-shard ArrayMesh;
- enemy head -> wider thorn/crystal-dart ArrayMesh;
- player trail -> tapered emissive wake;
- enemy trail -> tapered wake using the shot's inherited hostile color;
- inherited trail history still owns midpoint, length and direction;
- no new particle pools/gameplay nodes;
- no release metadata change.

Authority smoke explicitly preserves:
- player shot design radius `10.0`;
- enemy shot design radius `9.0`;
- player hit radius `28.0`;
- v1.51 projectile authority readiness;
- v1.62 r3 UI readiness.

Accepted captures:
- `r1_player_projectiles.png`
- `r1_enemy_projectiles.png`
- `r1_mixed_projectiles.png`

Friendly and hostile fire now separate through **shape + color**, while actors and arena remain dominant.

# Boss presentation

## Frozen boss baseline
Initial diagnostic: `606fd07a401858a4ff5223b95536791d607c8fbb`.
Runtime-class inspection: `05f71abf32014d59353517a000638cd24807aae1`.
Final baseline lock: `b8b68f1d8a2cb07b418d4ff028c9cd5c4b646eb7`.
Workflow: **`32277193240` — fully green.**

Recovered active legacy/decorative layers:
- v1.46 boss frame: runtime `boss_halo` TorusMesh ~2.16 X/Z, `boss_beam` CylinderMesh ~2.75 high, four BoxMesh crown rods, red OmniLight;
- v1.49 **BossDominanceLookdev**: outer ring ~1.28, inner ring ~0.82, eight `DominanceMark` BoxMeshes and separate range-4.4 dominance light;
- `_sync_boss_dominance()` keeps that v1.49 root persistently visible on Warden boss floors.

Frozen captures:
- `baseline_boss_intro.png`
- `baseline_boss_fan.png`
- `baseline_boss_crown_slam.png`

Visual verdict: **rejected production target / retained comparison**. Persistent circular boss decoration competed with the gameplay-significant r3.2 fan/focus and slam tells.

## r2 — technically green, visually rejected
Implementation: **`9f4ea8d51f32ec712385db6d5d7263502f9998d0`**.
Workflow: **`32278164808` — fully green.**

r2 correctly cleaned the older v1.46 frame:
- old boss halo -> broken floor anchors;
- tall cylinder beam -> shorter fractured spire;
- four Box crown rods -> faceted crown shards;
- boss-frame light reduced.

Strict smoke proved all five r3.2 tell AABBs remained exactly identical to the accepted r1 reference world. r1 projectiles, v1.62 UI and v1.52.1 input also passed.

**Manual verdict: REJECTED.** `r2_boss_intro.png`, `r2_boss_fan.png` and `r2_boss_crown_slam.png` remained visually almost identical to baseline because the dominant visible ring was not the v1.46 halo. Root cause was recovered as the still-active v1.49 `BossDominanceLookdev`.

Keep `9f4ea8d5...` only as a technically valid intermediate fallback. Do not call it accepted visual completion.

## r2.1 — accepted current production lock: active BossDominance correction
Implementation: **`7262f42002aeeba338559190e8a87a616329ec54`**.
Dedicated workflow: **`32279185350` — fully green.**
Before/after artifact: **`9375230747`**.

r2.1 extends r2 and targets the **actual dominant v1.49 visual owner**:
- `boss_dominance_ring_outer` -> four open L-like bracket groups; no closed perimeter;
- `boss_dominance_ring_inner` -> four small inward chevrons; no inner ring;
- inherited eight `DominanceMark` nodes remain structurally present, but all use faceted ArrayMesh shards and only four are visually active;
- separate dominance-light range reduced from inherited 4.4 to 2.85 with restrained energy;
- dominance rotation/pulse slowed and reduced;
- r2's quieter v1.46 frame remains underneath.

### Authority / regression proof
r2.1 smoke verifies:
- active dominance outer/inner meshes are ArrayMeshes, not TorusMesh;
- only four of eight dominance marker nodes are visible and none use BoxMesh;
- dominance-light range <= 2.90;
- r2 technical boss-frame contract remains ready;
- r1 projectile identity remains ready;
- v1.62 r3 UI remains ready;
- Focus/Charge/Phase/Slam/Ritual tell AABBs are **exactly identical** to an untouched accepted r1 world.

Dedicated run `32279185350` is fully green:
- Godot 4.7.1 compile/import: PASS
- r2.1 BossDominance contract: PASS
- r2 boss-frame regression: PASS
- r1 projectile identity regression: PASS
- frozen boss baseline contract: PASS
- v1.61 r3.2 danger-language regression: PASS
- frozen baseline render: PASS
- r2.1 Intro/Fan/Crown-Slam render: PASS
- before/after artifact upload: PASS
- v1.62 r3 UI regression: PASS
- v1.52.1 input-flow regression: PASS

### r2.1 manual image acceptance
`r21_boss_intro.png` — **accepted**:
- permanent large red ring is gone;
- Warden remains focal;
- only sparse broken floor signature pieces remain;
- boss identity no longer reads as a generic floor telegraph.

`r21_boss_fan.png` — **accepted**:
- the r3.2 forward/focus warning and r1 hostile shards are now the dominant readable combat intent;
- decorative boss framing no longer reconstructs a second full circle around the warning.

`r21_boss_crown_slam.png` — **accepted**:
- radial teeth remain clearly visible because they are the intended gameplay-significant slam tell;
- the former second decorative dominance-ring layer is gone;
- boss identity and warning language are visually separable.

Therefore **v1.63 r2.1 / `7262f420...` is the current accepted production implementation baseline.**

# Current validation summary
- v1.63 Projectile Identity `32276028440`: green.
- v1.63 Boss Baseline `32277193240`: green.
- v1.63 Boss r2 `32278164808`: technically green, **visually rejected**.
- v1.63 Boss Dominance r2.1 `32279185350`: **fully green and visually accepted**.
- v1.61 r3.2 danger language: preserved.
- v1.62 r3 UI: preserved.
- v1.52.1 input flow: preserved.

# Non-negotiable v1.63 rules
1. Preserve **`7262f420...`** as the current accepted v1.63 production rollback point.
2. Preserve `4877c228...` as the accepted projectile-only fallback.
3. Preserve `9f4ea8d5...` only as the rejected/technical r2 intermediate; do not promote it over r2.1.
4. Preserve frozen projectile and boss baseline captures for honest before/after comparison.
5. Do not change v1.51 projectile collision/radii, Warden cast semantics, warning windows, danger-tell position/scale, damage, input, saves or progression during presentation work.
6. Do not regress to generic glowing balls, straight debug bars, full decorative boss rings, tall generic light columns, box-rod crowns or excessive particle clutter.
7. Preserve v1.61 r3.2 danger language and v1.62 r3 UI.
8. CI green does not override a visual rejection.
9. No TestFlight/build/version jump from individual v1.63 micro-passes.
10. Update this file immediately after every meaningful pass.

# Current next priorities
1. Run a **coherent combined v1.63 gameplay review** with accepted r1 projectile identity + accepted r2.1 boss identity together in one gameplay-distance sequence/capture set.
2. Look specifically for VFX density conflicts between projectile wakes, boss focus/slam tells, impacts, spawn/death signatures and the new sparse boss-dominance pieces.
3. If the combined review is clean, treat v1.63 combat identity as visually complete rather than adding decoration quantity.
4. Then run a deliberate unsigned iPhone/iPad device-build milestone gate on the accepted stack.
5. Keep PR #93 Draft and do **not** upload to TestFlight unless a bundled milestone upload is deliberately approved.
