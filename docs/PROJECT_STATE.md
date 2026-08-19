# One More Floor — Project State

Canonical handoff for continued development. **Read this file before changing art direction, character proportions, gameplay authority, release policy, or regression gates. Repository truth wins over chat memory.**

## Current development line

### Active milestone — v1.61 Combat Presentation
- Pull request: **#90 — `v1.61 combat presentation milestone`**
- Branch: `agent/v1.61-combat-presentation`
- Base: `agent/v1.60-meta-environments` (stacked on the validated v1.60 milestone; do not retarget to `main` while PR #82 is still unmerged)
- **Current fully validated and visually accepted v1.61 implementation head: `ec29c5bc01db98cda004d62c40a165d9fcd2b27c` (`1.61-combat-presentation-r2.2`).**
- Prior accepted combat baseline: `31316503ef60ff316c0d55621773a566f177eb87` (r1.1).
- r2 impact baseline: `663835db6affff4636acbac84a68aa685e217e43`.
- r2.1 motion baseline: `7a00718130119b0a1087a49a9a076115c5ec3836`.
- Initial v1.61 r1 bundle: `6c68aa93565345dc58110d3dce46409c938ffe1a`.
- PR stays **DRAFT**.
- No TestFlight trigger, App Store build-number bump, or upload in v1.61 yet.

### Locked v1.60 fallback / parent milestone
- Pull request: **#82 — `v1.60 authored environment milestone`**
- Branch: `agent/v1.60-meta-environments`
- Fully validated and visually accepted v1.60 implementation head: **`3e567bf409a8492a55f672b226ce9ce81c16780f`**
- v1.60 documentation head before v1.61 branch: `c0cea10915fb1a3838310490407e266673a293fe`
- r11 OBJ topology correction: `4f82a5aeb717a088747eb31849b2d2d97340ba27`
- Wanderer animation/core safe point: `00a78086d47b06093c1c7554c2713067f3def132` (r8.1)
- v1.60 remains the last **TestFlight-ready candidate** until v1.61 gets its own milestone-level release/iOS decision.

## Non-negotiable continuity rules

1. Preserve imported v1.55 glTF animation authority and articulated pivots.
2. Do not casually change combat authority, timing, damage, targeting, hitboxes, input, saves, progression, or the 2D HUD during presentation work.
3. Do not reintroduce prototype rings, debug discs/seams, generic floor blockouts, old rounded Wanderer geometry, or retired realm blockouts.
4. Never regress to broad armor-mannequin, blockout, single-color-plastic, or obvious debug-VFX reads.
5. Prefer authored geometry and deliberate silhouette/presentation changes over merely scaling old primitives.
6. CI green is necessary but **not sufficient** for visual acceptance. Runtime/gallery/close-up captures decide visual lock.
7. A visually rejected pass remains rejected even if CI was green.
8. Update this file after every meaningful accepted or rejected pass.
9. v1.61 remains a presentation layer on top of v1.60 unless a separately scoped gameplay milestone is explicitly started.
10. Do not reopen accepted Wanderer/enemy anatomy while working on combat polish.
11. Preserve each accepted v1.61 layer as a rollback point; add narrow presentation subclasses instead of rewriting validated lower layers when possible.

## Locked v1.60 environment direction

- Authored OBJ environments cover Home, Hero, Forge, Talents, Vault, Missions, Tower Pass, and Store.
- Floors 1–50 use authored production composition rather than the legacy prototype grid.
- Realm identities: Lower Halls, Ossuary, Iron Bastion, Rift Descent, Starless Spire.
- Authored focals include Ossuary reliquary altar, Iron Bastion forge engine, Rift anchor gate, and Starless Starwell dais.
- GL Compatibility surface-depth shading remains part of the mobile production look.
- Orthographic combat camera remains intentionally lower/stabler for stronger isometric depth.
- Do not replace these accepted v1.60 environment baselines inside v1.61 combat work.

## Locked Wanderer direction

Accepted actor stack:
- Wanderer r8.1 + **accepted Hood r11**
- narrow human central mass
- deliberate shoulder asymmetry
- slim/human limbs rather than rods/toy armor
- overlapping shoulder armor
- layered footwear rather than block feet
- restrained ArcaneCore / belt / eyes
- dark cloth / cool steel / restrained brass / arcane accent separation
- preserve cape, blade, imported animation, and pivot readability

Historical guardrails:
- r6 `090b7ce8a702229b9d52600f9d540f68cb73ac9c` is an older safe modular-character rollback.
- r7 was technically valid but visually rejected: dominant chest diamond, detached vertical arms, cap-like hood.
- r8.1 `00a78086d47b06093c1c7554c2713067f3def132` is the accepted ArcaneCore animation-scale fix.
- Hood r9 `6ed71e52d4c7aea2db8283d55ad0439696027de3` is rollback insurance only; too boxy for final.
- Hood r10 in `4001178b8e7069f072ebe6a255ee8856490377f6` is rejected; side cloth read like horns.
- Hood r11 is canonical at v1.60 implementation head `3e567bf4...`.
- Corrected r11 OBJ uses 142 vertices / 280 faces; invalid `b36dd73e...` had phantom face indices and caused the old CI import cascade.
- r11 production gate explicitly verifies import, marker/version, and exact visible `wanderer_hood_r11.obj` resource path.

## Locked enemy direction

Current enemy stack:
- Enemy r2: Goblin / Ghoul / Warden anatomy
- Enemy r3: Bat / Necromancer anatomy
- Enemy Detail r4
- Character Surface r5.1
- Skeleton intentionally unchanged by r4 detail and receives zero additional r5.1 procedural breakup

Accepted / rejected history:
- Enemy r1 overlay/scaling approach: **rejected**; do not restore.
- r2 bundle `6ed71e52d4c7aea2db8283d55ad0439696027de3`: accepted anatomy baseline.
- r3 validation bundle `4001178b8e7069f072ebe6a255ee8856490377f6`: accepted Bat/Necromancer silhouette baseline.
- r4 implementation `4eed3856434c71c3f3f4b430b69cce866679e121`: accepted restrained production-detail layer; Skeleton must not receive r4.
- r5 `4f7d9c0a6f90ca2e43eed0f8c07f034fdbf76068`: technically green but visually rejected due camouflage/blotchy surface breakup.
- r5.1 `cb47de3d52e29b8b8a4250e8b5f64b15e8e387b9`: accepted subtle body-surface baseline; do not raise procedural pattern strength again.

# v1.61 Combat Presentation

## Why this milestone exists

After v1.60 locked characters and authored environments, the largest remaining gameplay-quality break was the inherited combat presentation:
- player attack was a large flat yellow fan/crescent
- skill was a bright full TorusMesh/neon ring
- enemy warnings/shockwaves were thick tube/debug rings
- inherited chest-sigil ring and six-box skill crown added prototype-looking clutter
- projectile/collision impacts were expanding rings with blocky ticks/shards
- Wanderer movement echoes were violet ring + rune glyphs
- enemy deaths still used the old v1.46 violet expanding ring + four-shard glyph

The old lower-layer geometry remains available for historical regression contracts. **v1.61 changes what the player sees in a new top presentation layer while leaving gameplay authority inherited.**

## r1 — technically valid, visually rejected as final

Bundle: `6c68aa93565345dc58110d3dce46409c938ffe1a`

Introduced:
- `world3d_chamber_v161_combat_presentation.gd`
- `main_v75.gd` / v1.61 main activation
- ArrayMesh attack ribbon + hot edge + ground contact
- segmented Arcane skill waves/runes
- segmented enemy tells / head runes / Warden shock geometry
- visible suppression of v1.60 flat attack fan, full skill torus, inherited chest-sigil ring, and six-box skill crown
- dedicated v1.61 smoke/visual workflow

Technical result: green.
Manual result: **rejected as final** because attack remained too broad/half-moon-like and skill/tell segments were too chunky. Do not return to r1 dimensions/opacity.

## r1.1 — accepted core combat-presentation baseline

Implementation: **`31316503ef60ff316c0d55621773a566f177eb87`**
Workflow: `32249368864` — green.

Accepted changes:
- substantially narrower attack ribbon/angular span
- narrower hot edge; lower broad gold opacity/emission
- narrower ground contact
- thinner, more numerous separated skill segments
- reduced radial runes
- thinner/flatter enemy tells and Warden shock

Visual lock:
- gameplay-distance attack reads as a quick blade streak rather than a filled yellow fan
- skill reads as a light segmented arcane/rune wave rather than a full neon tube
- enemy warnings remain readable but no longer dominate as thick debug rings

## r2 — accepted impact-feedback direction

Implementation: **`663835db6affff4636acbac84a68aa685e217e43`**

Replaced inherited impact ring language while preserving the underlying hit/collision systems:
- legacy projectile `impact_pool` ring -> compact 8-ray ArrayMesh contact burst
- v1.50 collision-authority `Ring` -> compact 6-ray contact burst; old Tick geometry reduced
- v1.51 combat-authority `ImpactRing` -> compact radial burst; core/shards reduced
- critical combat impacts add only a restrained camera response (`camera_kick` floor/max request 0.24), without changing damage/timing/radius

Manual isolated image review accepted the compact gold/red starburst direction. No giant impact rings remain in the r2 presentation geometry.

## r2.1 — accepted movement-feedback direction

Implementation: **`7a00718130119b0a1087a49a9a076115c5ec3836`**

Root cause addressed:
- v1.49 Wanderer `move_echo_pool` used a violet Ring + three Rune boxes, expanded/rotated for 0.42 s.

r2.1:
- keeps the inherited movement trigger, pool, distance threshold and duration
- replaces the Ring mesh with three small directional floor streaks
- hides the three legacy Rune boxes
- aligns the streak behind the actual movement vector instead of spinning a circular glyph
- uses restrained stretching/lift rather than ring expansion

Manual isolated `movement_streaks.png` review: **accepted**. Only small directional streaks remain behind the Wanderer; no large violet movement circle is visible.

Important investigation result: r2.1 proved the move echo was a genuine old prototype visual, but it was **not** the source of the three large violet circles seen in earlier combined diagnostic captures.

## r2.2 — accepted death-feedback cleanup and current v1.61 lock

Implementation: **`ec29c5bc01db98cda004d62c40a165d9fcd2b27c`**
Dedicated workflow: **`32251699332` — fully green.**

Exact root cause of the three large violet diagnostic circles:
- inherited **v1.46 `death_burst_pool`**.
- `_sync_death_feedback()` compares prior/current enemy positions; when an enemy disappears it calls `_spawn_death_burst()`.
- each old death burst used a violet expanding `Ring` plus four Shard boxes.
- the earlier diagnostic sequence removed exactly three enemies between frames, therefore exactly three old violet death glyphs appeared at their last positions.
- this was a real legacy gameplay visual, not merely a screenshot artifact.

r2.2:
- preserves inherited death detection, pooling and duration
- replaces the old violet death Ring with a compact 10-ray radial ArrayMesh dissolve burst
- reduces/recolors the four old shards
- reduces planar expansion from the old giant glyph to a restrained 0.72 -> 1.18 scale response
- greatly reduces rotational speed and vertical lift
- adds a dedicated isolated death capture using the real inherited three-enemy -> zero-enemy death path

Manual isolated review:
- `death_bursts.png`: **accepted** — old violet circles are gone; three compact purple radial dissolve/star bursts appear instead.
- `movement_streaks.png`: **accepted** — only fine directional streaks, no large circle glyphs.
- `impact_bursts.png`: **accepted** — only compact gold/red contact starbursts, no large violet circles.

Therefore **r2.2 / `ec29c5bc...` is the current accepted v1.61 visual implementation baseline.**

## Current v1.61 validation

Dedicated run `32251699332` on `ec29c5bc...` is fully green:
- Godot 4.7.1 compile/import: PASS
- preserve r2 impact contract: PASS
- preserve r2.1 movement contract: PASS
- r2.2 death presentation contract: PASS
- main scene / inherited v1.60 integration: PASS
- isolated real r2.2 diagnostics: PASS
- v1.60 Combat VFX regression: PASS
- v1.60 Wanderer/r11 regression: PASS
- v1.60 six-enemy regression: PASS
- v1.52.1 tutorial/game-over input-flow regression: PASS

The accepted r2.2 diagnostic artifact set contains:
- `death_bursts.png`
- `movement_streaks.png`
- `impact_bursts.png`

## v1.60 validated milestone gates (fallback head `3e567bf4...`)

The parent milestone remains clean:
- Godot project parse/import + main/gameplay/Deep Tower/progression/release smoke chain: PASS
- Production Wanderer incl. hard r11 contract + captures + v1.55 + v1.52.1: PASS
- Production Enemy incl. all six silhouettes + gallery + v1.53 + v1.55 + v1.52.1: PASS
- v1.54 real-model/glTF intake and animation aliases: PASS
- v1.60 Material Depth + captures/regressions: PASS
- v1.60 Authored Environment + meta/tower captures + v1.59/input: PASS
- iOS playtest: Godot import, Xcode export, unsigned iPhone/iPad device build/package: PASS
- TestFlight upload step: intentionally SKIPPED

## Required regression gates for future v1.61 changes

Preserve and rerun at minimum:
- v1.61 r2 impact contract
- v1.61 r2.1 movement contract
- v1.61 r2.2 death-feedback contract + isolated visual diagnostics
- v1.60 Production Combat VFX direct regression
- v1.60 Production Wanderer incl. r11 contract
- v1.60 Production Enemy Silhouette / all six enemies
- v1.52.1 input-flow regression
- main scene / v1.60 authored environment integration
- Godot project parse/import
- iOS playtest before any v1.61 TestFlight/release decision

If future work touches materials/environments/actors, additionally rerun their dedicated v1.60 gates.

## Current next priorities

1. **Preserve `ec29c5bc...` as the accepted v1.61 r2.2 baseline.**
2. Do not reopen Wanderer r11 or enemy r2/r3/r4/r5.1 while working on combat polish.
3. Do not restore any of the replaced ring/glyph language merely because older direct regressions instantiate it below the v1.61 top layer.
4. Next visible-quality work should be a larger coherent pass, not another blind micro-effect loop: review loot/death/impact/attack/skill together at gameplay distance and prioritize only remaining obvious prototype reads.
5. Keep telegraphs readable; never change danger radius/timing as part of visual polish.
6. Before promoting v1.61 to the next TestFlight candidate, run the v1.61 iOS playtest/device-build gate on the accepted implementation and make a deliberate milestone-level upload decision.
7. No TestFlight build for individual VFX micro-passes.

## Release policy

- PR #82/v1.60 remains the last formally TestFlight-ready parent candidate.
- PR #90/v1.61 is a stacked **Draft** milestone; current visual implementation `ec29c5bc...` is technically and visually accepted but is **not authorized for upload yet**.
- No automatic TestFlight upload, App Store build bump, or version jump.
- When v1.61 has enough bundled visible improvement and its own release/iOS gate is clean, decide the next TestFlight build deliberately.
