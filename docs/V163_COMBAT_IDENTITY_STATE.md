# One More Floor — v1.63 Combat Identity State

Canonical checkpoint for the active v1.63 combat-identity milestone. **Read this together with `docs/PROJECT_STATE.md` and `docs/UI_V162_STATE.md` before continuing. Repository truth wins over chat memory.**

## Branch / parent
- Pull request: **#93 — `v1.63 combat identity milestone`**.
- Active branch: `agent/v1.63-combat-identity`.
- Parent branch: `agent/v1.62-ui-foundation` / PR #92.
- Starting parent head: `1d05a87b347bcdcfda5b21d40b74b476cadab42f`.
- Accepted production UI rollback: v1.62 r3 `71c8ecec5387400af7ef1c4bd29a3f87f9323d17`.
- Accepted combat presentation rollback below that: v1.61 r3.2 `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- PR #93 remains **Draft**. No TestFlight/build/version jump is authorized from individual v1.63 passes.

## Protected systems
1. Do not reopen or modify accepted v1.62 UI presentation, routes or hitboxes.
2. Preserve v1.61 combat authority: timing, damage, targeting, hit radii, warning windows, projectile collision/input authority and save/progression behavior.
3. Preserve Wanderer r11, accepted enemy anatomy/surface work, imported animation authority and pivots.
4. VFX work remains presentation-only unless a separate gameplay milestone is explicitly opened.
5. CI green is necessary but runtime captures decide visual acceptance.
6. Preserve accepted passes as rollback points; prefer narrow subclasses rather than rewriting validated lower layers.
7. Update this file after every meaningful accepted/rejected pass.

## Projectile baseline — verified active legacy path
Baseline diagnostic commit: `3eb4d60bb4701a78b7366249285326ba803dbda1`.
Workflow-marker correction only: `1b399f9d892013e139f1b07504077a559449b150`.

Verified source chain before changing production visuals:
- active projectile heads were still inherited from `world3d_chamber.gd` as `SphereMesh`;
- active trails were still inherited from `world3d_chamber_v141.gd` as straight `BoxMesh` history bars;
- v1.61 r3.2 modernized impacts/tells but did not replace airborne projectile geometry;
- v1.51 `world3d_projectile_authority_v151.gd` owns projectile collision separately from those visible meshes.

Frozen 720x1280 baseline captures:
- `baseline_player_projectiles.png`
- `baseline_enemy_projectiles.png`
- `baseline_mixed_projectiles.png`

Baseline visual verdict: **rejected as production quality / retained only as comparison**. Friendly and hostile fire both read primarily as bright glowing balls with straight luminous sticks behind them; identity depended too heavily on color.

Important CI note:
- first dedicated baseline run `32275001380` successfully compiled, validated SphereMesh/BoxMesh legacy geometry, preserved v1.61 r3.2 and rendered/uploaded all three baseline images;
- its final status was red only because the new workflow grepped the wrong success string for the existing v1.62 r3 UI smoke;
- the UI smoke itself printed `v1.62 UI foundation r3 runtime CTA smoke test passed`;
- `1b399f9d...` corrected only that workflow marker. Do not treat the first red run as a game/UI regression.

## r1 — accepted current production lock: projectile / trail identity
Implementation: **`4877c228d11319ad1db18e6bf12b5d2442b37ac9`**.
Dedicated workflow: **`32276028440` — fully green.**

### Exact r1 scope
- Added `world3d_chamber_v163_projectile_identity.gd` as a narrow presentation subclass over accepted v1.61 r3.2.
- Player projectile visible head: old sphere -> slim faceted **blade shard** ArrayMesh.
- Enemy projectile visible head: old sphere -> wider faceted **thorn dart** ArrayMesh.
- Player trail: old rectangular BoxMesh -> tapered emissive wake.
- Enemy trail: old rectangular BoxMesh -> tapered wake using the projectile's inherited hostile color.
- Existing inherited history calculation still owns trail midpoint, length and direction.
- New projectile heads only align to the already-computed trail direction.
- No new particle pools or gameplay nodes were added.
- `main_v82.gd` preserves the accepted v1.62 UI top layer and swaps only the combat-world presentation class.
- No release version/build metadata is changed by r1.

### Authority explicitly preserved
Dedicated smoke verifies:
- v1.51 projectile authority is still ready and separate;
- player projectile design radius remains `10.0`;
- enemy projectile design radius remains `9.0`;
- player hit radius remains `28.0`;
- new visible heads/trails are ArrayMeshes rather than the old SphereMesh/BoxMesh family;
- v1.62 r3 UI readiness remains intact.

### r1 manual image acceptance
`r1_player_projectiles.png` — **accepted**:
- friendly fire reads as narrow directional blade/arcane shards rather than round bulbs;
- wake tapers behind the head instead of ending as a uniform rectangular stick;
- critical scale remains inherited/readable.

`r1_enemy_projectiles.png` — **accepted**:
- hostile heads read as chunkier thorn/crystal darts rather than player-like spheres;
- cyan/purple/red hostile wakes now follow each shot's actual inherited color instead of sharing one generic purple trail;
- hostile silhouette stays compact at gameplay distance.

`r1_mixed_projectiles.png` — **accepted**:
- friendly and hostile projectiles now separate through **shape plus color**, not color alone;
- projectile hierarchy is clearer without adding ring clutter or large particle volume;
- actors and the authored room remain visually dominant.

Therefore **v1.63 r1 / `4877c228...` is the current accepted production implementation baseline.**

## Current validation
Dedicated `v1.63 Projectile Identity Check` run **`32276028440`** on `4877c228...` is fully green:
- Godot 4.7.1 compile/import: PASS
- v1.63 projectile identity / preserved-authority smoke: PASS
- frozen legacy projectile baseline contract: PASS
- v1.61 r3.2 combat presentation regression: PASS
- frozen baseline three-image render: PASS
- r1 three-image render: PASS
- six-image before/after artifact upload: PASS
- v1.62 r3 UI regression: PASS
- v1.52.1 input-flow regression: PASS

## Non-negotiable v1.63 rules
1. Preserve **`4877c228...`** as the current accepted v1.63 production rollback point.
2. Preserve the frozen SphereMesh/BoxMesh baseline scripts/captures for comparison; do not rewrite history to make r1 look better.
3. Do not change v1.51 projectile collision/radii, damage, timing, targeting or lifetime while polishing projectile visuals.
4. Do not regress to generic glowing balls, straight debug bars, full rings or excessive particle clutter.
5. Keep projectile shapes compact enough that actors, danger tells and arena geometry remain dominant.
6. Preserve v1.61 r3.2 danger-language geometry and v1.62 r3 UI.
7. No TestFlight/build/version jump from individual v1.63 micro-passes.
8. Update this file immediately after each meaningful boss/projectile pass.

## Current next priorities
1. **Begin boss-specific combat presentation audit on top of accepted r1.** Trace the active boss cast/projectile/VFX paths first; do not assume historical boss spectacle renderers are still active.
2. Capture the current Warden/boss combat presentation at gameplay distance before modifying it.
3. Improve boss identity only where the active runtime still reuses generic mob/projectile language; preserve warning windows, cast kinds and attack authority.
4. Keep r1 projectile before/after captures, v1.61 r3.2 and v1.62 UI as regressions.
5. Make any future TestFlight decision only after a bundled v1.63 milestone is visually complete and deliberately approved.
