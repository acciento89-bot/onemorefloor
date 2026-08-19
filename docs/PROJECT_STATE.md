# One More Floor — Project State

Canonical handoff for continued development. **Read this file before changing art direction, character proportions, gameplay authority, release policy, or regression gates. Repository truth wins over chat memory.**

## Current development line

### Active milestone — v1.61 Combat Presentation
- Pull request: **#90 — `v1.61 combat presentation milestone`**
- Branch: `agent/v1.61-combat-presentation`
- Base: `agent/v1.60-meta-environments` while PR #82 remains unmerged.
- **Current fully validated and visually accepted implementation head: `bb367aad35338dd6d32fbdf7d4de4208efef2ad0` (`1.61-combat-presentation-r3.2`).**
- r3.2 initial implementation: `67347231d92fe510f495eff67bd450105ab2289b`.
- r3.2 charge-typing implementation fix: `7c31c63615085e5410b6621d15e72e14471f2350`.
- r3.2 smoke-only typing fix: `0e8c5925598b6fc73c081e527328af3f2d41f2d1` — test code only.
- r3.2 final ritual-bound correction / accepted implementation: `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- r3.1 previous accepted fallback: `a6a7395a248295a7c4fdb5e87a767a4496d1ff2e`.
- r3 implementation: `2233a51327db849d80c3c16968bf507f285cfd1f`.
- r3 smoke-only activation fix: `6c398cc396e1bb901bba0d26f6cdd59c213286b4` — no visual/gameplay implementation change.
- r2.2 fallback: `ec29c5bc01db98cda004d62c40a165d9fcd2b27c`.
- r2.1 motion fallback: `7a00718130119b0a1087a49a9a076115c5ec3836`.
- r2 impact fallback: `663835db6affff4636acbac84a68aa685e217e43`.
- r1.1 core combat fallback: `31316503ef60ff316c0d55621773a566f177eb87`.
- PR stays **DRAFT**.
- No TestFlight trigger, App Store build-number bump, or upload in v1.61 yet.

### Locked v1.60 fallback / parent milestone
- PR #82 — `v1.60 authored environment milestone`.
- Branch: `agent/v1.60-meta-environments`.
- Fully validated v1.60 implementation head: **`3e567bf409a8492a55f672b226ce9ce81c16780f`**.
- Wanderer animation/core safe point: `00a78086d47b06093c1c7554c2713067f3def132` (r8.1).
- r11 OBJ correction: `4f82a5aeb717a088747eb31849b2d2d97340ba27`.
- v1.60 remains the last formally TestFlight-ready parent candidate until v1.61 gets its own milestone-level iOS/release decision.

## Non-negotiable continuity rules

1. Preserve imported v1.55 glTF animation authority and articulated pivots.
2. Do not change combat authority, timing, damage, targeting, hitboxes, input, saves, progression, or the 2D HUD during presentation work.
3. Do not reintroduce prototype neon/full rings, debug discs/seams, old blockouts, rounded Wanderer geometry, or retired realm blockouts.
4. Never regress to armor-mannequin, blockout, single-color-plastic, or obvious debug-VFX reads.
5. CI green is necessary but not sufficient; runtime/gallery/gameplay-distance captures decide visual acceptance.
6. A visually rejected pass stays rejected even if technically green.
7. Update this file after every meaningful accepted/rejected pass.
8. v1.61 remains presentation-only on top of v1.60 unless a separately scoped gameplay milestone is explicitly started.
9. Do not reopen accepted Wanderer/enemy anatomy while polishing combat.
10. Preserve accepted v1.61 layers as rollback points; prefer narrow subclasses rather than rewriting validated lower layers.
11. Primary danger telegraphs are gameplay-significant: visual language may be improved, but inherited warning window, position, radius scale, attack behavior and readability must not be reduced or changed.

## Locked v1.60 art direction

### Environment
- Authored OBJ environments cover Home, Hero, Forge, Talents, Vault, Missions, Tower Pass, and Store.
- Floors 1–50 use authored production composition.
- Realms: Lower Halls, Ossuary, Iron Bastion, Rift Descent, Starless Spire.
- GL Compatibility surface-depth shading and the lower/stabler orthographic combat camera remain part of the accepted mobile look.

### Wanderer
- Accepted stack: Wanderer r8.1 + Hood r11.
- Narrow human central mass, asymmetric shoulders, slim human limbs, overlapping shoulder armor, layered footwear, restrained ArcaneCore/belt/eyes.
- Dark cloth / cool steel / restrained brass / arcane accents.
- Preserve cape, blade, imported animation and pivots.
- Hood r9 is rollback only; r10 rejected; r11 canonical.

### Enemies
- r2: Goblin/Ghoul/Warden anatomy.
- r3: Bat/Necromancer anatomy.
- r4: restrained detail layer; Skeleton intentionally receives no r4.
- r5.1: accepted subtle surface breakup; Skeleton gets no extra breakup.
- Do not restore r1 overlays or rejected r5 camouflage/blotchy strengths.

# v1.61 Combat Presentation history

## r1 — technically green, visually rejected
- Introduced the presentation-only v1.61 layer, attack ArrayMesh ribbon, segmented skill waves, segmented enemy tells and suppression of old player fan/torus/chest-sigil/skill-crown presentation.
- Rejected because attack remained too broad/half-moon-like and segments were too chunky.

## r1.1 — accepted core combat baseline
Implementation: `31316503ef60ff316c0d55621773a566f177eb87`.
- Narrower attack ribbon/hot edge/ground contact.
- Thinner skill waves/runes and enemy tells.
- Attack reads as a quick blade streak instead of the old filled yellow fan.
- Skill reads as segmented arcane energy instead of a full neon tube.

## r2 — accepted impact language
Implementation: `663835db6affff4636acbac84a68aa685e217e43`.
- Projectile/collision/combat-authority impact rings replaced by compact radial starbursts.
- Critical camera response capped to a restrained `camera_kick` request of 0.24.
- No hit radius, timing or damage changes.

## r2.1 — accepted movement language
Implementation: `7a00718130119b0a1087a49a9a076115c5ec3836`.
- v1.49 Wanderer motion Ring + three Rune boxes replaced by three small directional floor streaks.
- Trigger/distance threshold/pool/duration preserved.

## r2.2 — accepted v1.46 death-burst cleanup
Implementation: `ec29c5bc01db98cda004d62c40a165d9fcd2b27c`.
- Exact source of the earlier three violet circles was verified as inherited v1.46 `death_burst_pool`: Ring + four shards triggered when enemies disappear.
- Replaced with compact radial dissolve/star burst; expansion/rotation/lift reduced.
- Dedicated run `32251699332` fully green.
- Isolated `death_bursts.png`, `movement_streaks.png`, `impact_bursts.png` accepted.

## Coherent gameplay review after r2.2
Diagnostic commit: `1862a1b7b71ecc353d37b2e73dc05030e9761873`.
- Added a combined gameplay-distance capture without changing r2.2 implementation.
- Attack/skill/impact/death worked together, but the frozen frames showed large archetype-colored circles around enemies and a circular loot/beam language.
- Initial working hypothesis was that the enemy circles were persistent v1.49 grounding. That hypothesis was incomplete.

## r3 — accepted Grounding + Loot sub-layer
Implementation: `2233a51327db849d80c3c16968bf507f285cfd1f`.
Smoke-only test fix: `6c398cc396e1bb901bba0d26f6cdd59c213286b4`.

r3 presentation changes:
- v1.49 secondary `EnemyGround` Ring meshes replaced by small broken/tapered ground-anchor ArrayMeshes with subdued neutral/arcane/elite materials.
- v1.46 loot `FloorGlow` circle replaced by compact radial glint geometry.
- tall cylindrical loot `Beam` replaced by a short tapered/crossed shard glint.
- loot values, positions, pools and triggers unchanged.
- primary danger telegraphs explicitly preserved.

Important test note:
- the first r3 smoke failed only because its automatic state did not activate secondary grounding in that headless test setup.
- implementation compiled and r2/r2.1/r2.2 remained green.
- `6c398cc3...` changed only the smoke to exercise the inherited grounding/loot paths deterministically; it did not change the game visuals.

Visual review proved r3 loot was cleaner, but the large archetype-colored circles remained in the frozen spawn/kill screenshots. This led to the exact source investigation below.

## r3.1 — accepted Spawn/Death Signature Language
Implementation: `a6a7395a248295a7c4fdb5e87a767a4496d1ff2e`.
Dedicated workflow: `32257942233` — fully green.

Corrected diagnosis:
- The dominant archetype-colored rings in the frozen combined review were primarily inherited **v1.48 `spawn_signature_pool` / `death_signature_pool`** effects, not persistent enemy grounding.
- Each v1.48 signature used a Ring radius 0.52 plus five vertical Shard boxes.
- Spawn/death signature duration is 0.52 s.
- Old animation made spawn scale from 1.42 -> 0.72 and death from 0.62 -> 2.05 while rotating/lifting, which made a frozen frame look like persistent circular clutter.

r3.1 changes:
- signature Ring -> five broken inward bracket segments, no continuous circle.
- five rod-like Shards -> short tapered ArrayMesh shards.
- archetype color remains, preserving spawn/death identity.
- signature trigger, pool and 0.52-s duration remain unchanged.
- visual animation restrained: spawn roughly 1.10 -> 0.74; death roughly 0.74 -> 1.35, with much lower rotation/lift.

### r3.1 manual image acceptance
`r31_spawn_signatures.png` — accepted: large full colored circles are gone; spawn uses compact broken brackets/shards.

`r31_steady_attack_pressure.png` — accepted: transient signature pools are hidden for diagnosis; archetype-colored ring clutter disappears; remaining red shapes are the primary danger telegraphs.

`r31_kill_loot_signatures.png` — accepted: giant green death/signature ring is gone; death is compact and loot reads as small gold glints.

## r3.2 — accepted current visual lock: Directional Danger Language
Initial implementation: `67347231d92fe510f495eff67bd450105ab2289b`.
Charge-typing implementation fix: `7c31c63615085e5410b6621d15e72e14471f2350`.
Smoke-only typing fix: `0e8c5925598b6fc73c081e527328af3f2d41f2d1`.
Final accepted implementation: **`bb367aad35338dd6d32fbdf7d4de4208efef2ad0`**.
Dedicated workflow: **`32260926762` — fully green.**

Root cause / semantic recovery:
- r3.1 correctly exposed that the remaining repeated red shapes were true primary danger telegraphs.
- the v1.61 3D layer still presented nearly every warning as the same rotating segmented ring.
- investigation of the established 2D combat implementation showed that focused attacks had previously used a **player-directed warning arc plus an aim line**, so directionality was already part of the intended readable language.
- runtime cooldown semantics were verified before implementation: `dash/dive/lunge` are fast movement attacks, `blink/phase/teleport` are relocation/phase warnings, `slam` is radial, and `summon` is ritual/cast behavior.

r3.2 changes only presentation geometry/orientation:
- `attack_cd` / focused attacks -> compact forward arc + spear/aim marker pointing toward the Wanderer.
- `dash_cd`, `dive_cd`, `lunge_cd` -> two compact lane rails + forward charge arrow pointing toward the Wanderer.
- `blink_cd`, `phase_cd`, `teleport_cd` -> broken phase-bracket language rather than a full ring.
- `slam_cd` / crown cast -> radial perimeter teeth.
- `summon_cd` -> inward ritual markers/ticks.
- boss `cast_kind == "fan"` maps to focused directional language; `cast_kind == "crown"` maps to slam language.
- the lowest active inherited cooldown still selects the warning family.
- inherited warning trigger/window remains the same 0.34-s logic.
- inherited telegraph position, pulse and `radius / 24.0` scale remain owned by the old gameplay path and are not changed by r3.2.
- dedicated smoke verifies the r3.2 mesh swap does not change inherited tell scale.
- dedicated smoke additionally verifies all five local tell meshes remain inside the accepted 0.68 local bound.
- Focus and Charge orientation are hard-checked against the Wanderer's actual world position.

Implementation/test history that must not be repeated:
- initial r3.2 compile failure was a GDScript type-inference issue in the charge mesh loop, not a design failure; `7c31c636...` added explicit local float typing.
- the next failure was smoke-test-only type inference for direction math; `0e8c5925...` changed only test typing.
- once real geometry checks ran, Ritual alone exceeded the 0.68 local safety bound because its tick center sat at 0.68 plus radial thickness. **The test was not weakened.**
- `bb367aad...` moved only Ritual ticks inward (`0.64` center, narrower tangential half-width), after which all five tell families passed the original strict bound.

### r3.2 manual image acceptance
`r32_focus_pressure.png` — **accepted**:
- repeated full/near-full enemy rings are gone.
- focused warning arcs sit in front of the actors and point toward the Wanderer.
- actors remain visually dominant; warnings read as intent instead of generic floor decoration.

`r32_mobility_phase.png` — **accepted**:
- movement/charge warnings and phase warnings no longer share the same silhouette.
- charge language is directional while phase language is broken/non-directional.
- warning footprint remains restrained at gameplay distance.

`r32_slam_ritual.png` — **accepted**:
- Warden/slam reads as radial perimeter teeth.
- ritual/cast reads as separate inward markers rather than another rotating circle.
- both remain inside the preserved visual radius bound.

Therefore **r3.2 / `bb367aad...` is the current accepted v1.61 visual implementation baseline.**

## Current v1.61 validation

Dedicated `v1.61 Combat Presentation Check` run **`32260926762`** on `bb367aad...` is fully green:
- Godot 4.7.1 compile/import: PASS
- r2 impact contract: PASS
- r2.1 motion contract: PASS
- r2.2 death contract: PASS
- r3 grounding + loot contract: PASS
- r3.1 spawn/death signature contract: PASS
- r3.2 directional danger-language / preserved-radius contract: PASS
- main scene / inherited v1.60 integration: PASS
- isolated r2.2 diagnostics: PASS
- coherent r2.2 review baseline: PASS
- r3 gameplay-distance comparison: PASS
- r3.1 spawn / steady-state / kill+loot captures: PASS
- r3.2 focus / mobility-phase / slam-ritual captures: PASS
- v1.60 Combat VFX regression: PASS
- v1.60 Wanderer/r11 regression: PASS
- v1.60 six-enemy regression: PASS
- v1.52.1 tutorial/game-over input-flow regression: PASS

## Required gates for future v1.61 changes

Preserve at minimum:
- r2 impact contract.
- r2.1 movement contract.
- r2.2 death-burst contract + isolated diagnostics.
- r3 grounding + loot contract.
- r3.1 spawn/death signature contract + separated spawn/steady/kill captures.
- r3.2 directional danger-language contract + strict inherited scale/local-bound checks + focus/mobility/slam visual captures.
- v1.60 Combat VFX regression.
- v1.60 Wanderer/r11 regression.
- v1.60 all-six-enemy regression.
- v1.52.1 input-flow regression.
- main scene / v1.60 authored environment integration.
- Godot project parse/import.
- iOS playtest/device build before any v1.61 TestFlight decision.

## Current next priorities

1. **Preserve `bb367aad...` as the accepted r3.2 implementation baseline.**
2. Do not reopen Wanderer r11, enemy anatomy/surface baselines, r3.1 signature language, or r3.2 danger radii while continuing combat work.
3. Do not restore a universal enemy warning ring. Any future tell work must keep the accepted Focus / Charge / Phase / Slam / Ritual semantic split.
4. Next coherent gameplay-distance review should identify the next largest remaining prototype read rather than adding effect quantity. Candidate areas: projectile/trail identity, boss-specific attack presentation, or overly dominant player-feedback elements visible only now that enemy floor clutter is reduced.
5. Keep all accepted visual feedback presentation-only unless a separately scoped gameplay milestone is explicitly opened.
6. No TestFlight build for individual presentation micro-passes.
7. Before promoting v1.61 to TestFlight-ready status, run the v1.61 iOS playtest/device-build gate on the accepted implementation and make a deliberate milestone-level upload decision.

## Release policy

- PR #82/v1.60 remains the last formally TestFlight-ready parent candidate.
- PR #90/v1.61 remains a stacked **Draft** milestone.
- Current accepted visual implementation is `bb367aad...`, but it is **not authorized for TestFlight upload yet**.
- No automatic build bump, version jump, App Store submission or TestFlight upload from micro-passes.