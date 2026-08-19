# One More Floor — Project State

Canonical handoff for continued development. **Read this file before changing art direction, character proportions, gameplay authority, release policy, or regression gates. Repository truth wins over chat memory.**

## Current development line

### Active milestone — v1.61 Combat Presentation
- Pull request: **#90 — `v1.61 combat presentation milestone`**
- Branch: `agent/v1.61-combat-presentation`
- Base: `agent/v1.60-meta-environments` (stacked on the validated v1.60 milestone; do not retarget to `main` while PR #82 is still unmerged)
- Accepted v1.61 implementation head: **`31316503ef60ff316c0d55621773a566f177eb87`** (`1.61-combat-presentation-r1.1`)
- Initial v1.61 r1 bundle: `6c68aa93565345dc58110d3dce46409c938ffe1a`
- PR stays **DRAFT**.
- No TestFlight trigger, App Store build-number bump, or upload in v1.61 yet.

### Locked v1.60 fallback / parent milestone
- Pull request: **#82 — `v1.60 authored environment milestone`**
- Branch: `agent/v1.60-meta-environments`
- Fully validated and visually accepted v1.60 implementation head: **`3e567bf409a8492a55f672b226ce9ce81c16780f`**
- v1.60 documentation head before v1.61 branch: `c0cea10915fb1a3838310490407e266673a293fe`
- r11 OBJ topology correction: `4f82a5aeb717a088747eb31849b2d2d97340ba27`
- Wanderer animation/core safe point: `00a78086d47b06093c1c7554c2713067f3def132` (r8.1)
- v1.60 remains the last **TestFlight-ready candidate**. v1.61 has not replaced that release status yet.

## Non-negotiable continuity rules

1. Preserve imported v1.55 glTF animation authority and articulated pivots.
2. Do not casually change combat authority, timing, damage, targeting, hitboxes, input, saves, progression, or the 2D HUD during presentation work.
3. Do not reintroduce prototype rings, debug discs/seams, generic floor blockouts, old rounded Wanderer geometry, or retired realm blockouts.
4. Never regress to broad armor-mannequin, blockout, single-color-plastic, or obvious debug-VFX reads.
5. Prefer authored geometry and deliberate silhouette/presentation changes over merely scaling old primitives.
6. CI green is necessary but **not sufficient** for visual acceptance. Runtime/gallery/close-up captures decide visual lock.
7. A visually rejected pass remains rejected even if CI was green.
8. Update this file after every meaningful accepted or rejected pass.
9. v1.61 must remain a presentation layer on top of v1.60 unless a separate, explicitly scoped gameplay milestone is started.
10. Do not reopen accepted Wanderer/enemy anatomy merely because combat presentation is being polished.

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
- restrained chest sigil / ArcaneCore / belt / eyes
- dark cloth / cool steel / restrained brass / arcane accent separation
- preserve cape, blade, imported animation, and pivot readability

Historical guardrails:
- r6 `090b7ce8a702229b9d52600f9d540f68cb73ac9c` is an older safe modular-character rollback.
- r7 was technically valid but visually rejected: dominant chest diamond, detached vertical arms, cap-like hood.
- r8.1 `00a78086d47b06093c1c7554c2713067f3def132` is the accepted ArcaneCore animation-scale fix.
- Hood r9 `6ed71e52d4c7aea2db8283d55ad0439696027de3` is rollback insurance only; too boxy for final.
- Hood r10 in `4001178b8e7069f072ebe6a255ee8856490377f6` is rejected; side cloth read like horns.
- Hood r11 is canonical at v1.60 implementation head `3e567bf4...`.
- Corrected r11 OBJ uses 142 vertices / 280 faces; the invalid `b36dd73e...` candidate had phantom face indices and caused a CI import cascade. Do not confuse those old failures with gameplay regressions.
- The r11 production gate explicitly verifies asset import, marker/version, and exact visible `wanderer_hood_r11.obj` resource path.

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

## v1.61 Combat Presentation

### Why this milestone exists

After v1.60 locked characters and authored environments, the largest remaining gameplay-quality break was the combat VFX language:
- player attack presented as a large flat yellow fan/crescent
- skill presented as a bright full TorusMesh/neon ring
- enemy warnings/shockwaves read as thick tube/debug rings
- inherited chest-sigil ring and six-box skill crown added more prototype-looking ring/stick clutter

The old v1.60 VFX geometry remains instantiated for its historical regression contract. **v1.61 changes only what the player sees at the new top presentation layer.** Gameplay radii/timing/authority remain inherited.

### v1.61 r1 — technically valid, visually not accepted as final

Bundle: `6c68aa93565345dc58110d3dce46409c938ffe1a`

Implemented:
- new `world3d_chamber_v161_combat_presentation.gd` on top of v1.60 atmosphere
- new `main_v75.gd` and v1.61 main-scene activation
- attack ribbon + hot edge + thin ground contact using ArrayMesh geometry
- segmented Arcane skill waves + radial runes
- segmented primary enemy tells / head runes / Warden shock geometry
- visible suppression of v1.60 attack fan, v1.60 skill torus, inherited chest-sigil ring, and six-box skill crown
- dedicated v1.61 smoke/visual workflow and four real 720×1280 captures

Technical result: green.

Manual image review: **not accepted as final**. Direction was correct, but the attack ribbon remained too broad/half-moon-like and the skill/tell segments were too chunky. Do not return to r1 dimensions/opacity.

### v1.61 r1.1 — accepted combat-presentation baseline

Implementation head: **`31316503ef60ff316c0d55621773a566f177eb87`**
Workflow run: **`32249368864`**

Changes from r1:
- attack ribbon width and angular span reduced substantially
- hot edge narrowed and broad gold opacity/emission reduced
- ground-contact arc narrowed
- skill waves made thinner with more/smaller separated segments
- radial runes reduced
- enemy primary tell and Warden shock geometry made thinner, more segmented, and less opaque
- presentation marker advanced to `1.61-combat-presentation-r1.1`

Manual runtime/capture review accepted r1.1 as the first v1.61 baseline:
- gameplay-distance attack now reads as a **quick blade streak**, not the old filled yellow fan
- skill has a light segmented arcane/rune language instead of a full neon tube ring
- enemy tells remain readable but are flatter/lighter and less debug-like
- v1.60 bright Torus player rings are suppressed in the v1.61 visible layer
- the three purple circular elements seen in the diagnostic blade close-up already existed in the v1.60 capture sequence; they are capture-state residue, not newly introduced r1.1 geometry. Do not treat that diagnostic residue as a new gameplay regression without evidence from a fresh isolated runtime capture.

## v1.61 validation on `31316503...`

Dedicated `v1.61 Combat Presentation Check` run `32249368864` is fully green:
- Godot 4.7.1 compile/import: PASS
- v1.61 presentation contract: PASS
- main scene / inherited v1.60 integration: PASS
- real 720×1280 combat captures: PASS
- v1.60 combat VFX regression: PASS
- v1.60 Wanderer regression: PASS
- v1.60 six-enemy regression: PASS
- v1.52.1 tutorial/game-over input-flow regression: PASS

The accepted visual artifact set contains:
- `attack_blade_trail.png`
- `skill_arcane_wave.png`
- `enemy_segmented_tells.png`
- `player_blade_closeup.png`

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
- v1.61 Combat Presentation compile/contract + real visual captures
- v1.60 Production Combat VFX direct regression
- v1.60 Production Wanderer incl. r11 contract
- v1.60 Production Enemy Silhouette / all six enemies
- v1.52.1 input-flow regression
- main scene / v1.60 authored environment integration
- Godot project parse/import
- iOS playtest before any v1.61 TestFlight/release decision

If future work touches materials/environments/actors, additionally rerun their dedicated v1.60 gates.

## Current next priorities

1. **Preserve `31316503...` as the accepted v1.61 r1.1 combat-presentation baseline.**
2. Do not reopen Wanderer r11 or enemy r2/r3/r4/r5.1 while working on combat polish.
3. Next combat-quality work should target **impact readability and moment-to-moment polish** (hit/impact response, attack/skill timing presentation, restrained camera/light response) rather than increasing effect size.
4. Keep telegraphs readable for gameplay; polish their shape/material language without changing danger radius or timing.
5. If investigating the purple diagnostic rings, use a fresh isolated runtime/capture state first; do not “fix” them blindly from the reused close-up capture.
6. Before making v1.61 the next TestFlight candidate, complete its own iOS playtest/build gate and perform a deliberate milestone-level upload decision.
7. No TestFlight build for individual combat micro-passes.

## Release policy

- PR #82/v1.60 remains the last fully validated TestFlight-ready candidate.
- PR #90/v1.61 is a new stacked **Draft** milestone and is not authorized for upload yet.
- No automatic TestFlight upload, App Store build bump, or version jump.
- When v1.61 has enough visible improvement and its release/iOS gates are clean, decide the next TestFlight build deliberately.
