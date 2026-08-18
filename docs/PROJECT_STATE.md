# One More Floor — Project State

Canonical handoff for continued development. Read this file before changing art direction, character proportions, gameplay authority, release policy or regression gates.

## Current development line

- Milestone: v1.60 authored environment + character-quality milestone
- Pull request: #82 — `v1.60 authored environment milestone`
- Branch: `agent/v1.60-meta-environments`
- Base: `main`
- Last fully validated and visually accepted actor implementation: `cb47de3d52e29b8b8a4250e8b5f64b15e8e387b9` (Enemy Surface r5.1 on top of r4/r3/r2 + Wanderer r8.1/Hood r9).
- Wanderer animation/core safe point: `00a78086d47b06093c1c7554c2713067f3def132` (r8.1).
- Current actor stack: Wanderer r8.1 + temporary Hood r9 + Enemy r2 Goblin/Ghoul/Warden + Enemy r3 Bat/Necromancer + Enemy Detail r4 + accepted Character Surface r5.1. Skeleton remains intentionally unchanged by r4 detail and receives zero extra r5.1 breakup.
- PR stays DRAFT.
- No TestFlight trigger, App Store build-number bump or version jump until a visibly meaningful bundled milestone is approved.

## Non-negotiable continuity rules

1. Preserve the imported v1.55 glTF animation authority and articulated pivots.
2. Do not casually change combat authority, targeting, hitboxes, input, saves or the 2D HUD during presentation work.
3. Do not reintroduce prototype rings, debug discs/seams, generic floor blockouts, old rounded Wanderer geometry or retired realm blockouts.
4. Never regress to the broad armor-mannequin / blockout / single-color-plastic read.
5. Prefer authored geometry and silhouette changes over merely scaling old primitives.
6. CI green is necessary but not sufficient for visual acceptance. Actual runtime/close-up captures decide visual lock.
7. Update this file after every meaningful accepted/rejected pass so a new session resumes from repository truth rather than chat memory.

## Accepted environment direction

- Authored OBJ environments cover Home, Hero, Forge, Talents, Vault, Missions, Tower Pass and Store.
- Floors 1-50 use authored production composition rather than the legacy prototype grid.
- Realm identities: Lower Halls, Ossuary, Iron Bastion, Rift Descent and Starless Spire.
- Authored focals include Ossuary reliquary altar, Iron Bastion forge engine, Rift anchor gate and Starless Starwell dais.
- GL Compatibility surface-depth shading remains part of the mobile production look.
- Orthographic combat camera remains intentionally lower/stabler for stronger isometric depth.

## Wanderer

Locked direction:
- narrow human central mass
- deliberate shoulder asymmetry
- slim/human limbs rather than rods or toy armor
- overlapping shoulder armor
- layered footwear rather than block feet
- restrained chest sigil / ArcaneCore / belt / eyes
- dark cloth / cool steel / restrained brass / arcane accent separation
- preserve cape, blade and animation readability

### r3-r6 foundation

- r3 rebuilt Hood/Chestplate/Mask as authored OBJ geometry.
- r4 rebuilt tailored torso and layered cape.
- r5 replaced rod-like authored arm/leg/gauntlet geometry with stronger anatomy.
- r6 (`090b7ce8a702229b9d52600f9d540f68cb73ac9c`) remains an older safe rollback point for the established modular character direction.

### r7 — technically valid, visually rejected

- CI green, but close-ups still showed dominant purple chest diamond, vertical detached-looking arms and a smooth cap-like hood.

### r8.1 — accepted animation/core fix

Commit: `00a78086d47b06093c1c7554c2713067f3def132`.

- Root cause of the persistent large chest diamond was the imported glTF Skill animation explicitly animating `ArcaneCore` scale.
- r8.1 constrains ArcaneCore scale animation keys while keeping the animation itself alive.
- Runtime captures confirm the large chest diamond is gone.
- Small local arm/gauntlet angles reduce the two-vertical-bars read without changing pivots.
- Production Wanderer, v1.55, v1.54, v1.52.1, Material Depth, Godot and iOS playtest gates passed.

### Hood r9 — temporary accepted fallback, not final visual lock

Bundle: `6ed71e52d4c7aea2db8283d55ad0439696027de3`.

- Replaced the earlier rounded/cap-like hood with an authored angular OBJ.
- Technically clean and less dome-like, but close-up remains too rectangular/boxy for final art lock.
- Use r9 only as the temporary hood fallback while preserving r8.1.

### Hood r10 — technically valid, visually rejected

Candidate bundle: `4001178b8e7069f072ebe6a255ee8856490377f6`.

- New layered cloth/cowl OBJ compiled and passed Production Wanderer, main integration, v1.55 and v1.52.1 gates.
- Manual close-up review rejected it: side drape/cowl forms read like two horn-like points around the head.
- r10 is NOT canonical. Corrective work restored r9 while preserving r8.1 and the accepted enemy work.
- Hood r11 must use a smoother cloth-volume strategy rather than pointy side pieces or a box crown.

## Enemies

Authored body bases exist for Goblin, Bat, Skeleton, Ghoul, Necromancer and Warden. Weapons, eyes, runes and archetype accents may remain as separate detail layers while authored OBJ cores own the body silhouette.

### Enemy r1 — technically valid, visually rejected

- Scaling/material tuning plus restored overlay pieces did not solve anatomy quality.
- Goblin remained chibi, Ghoul became blockier and Warden still read as toy knight.
- Do not restore the r1 overlay approach.

### Enemy r2 — accepted anatomy baseline

Bundle: `6ed71e52d4c7aea2db8283d55ad0439696027de3`.

- Actual authored OBJ cores for Goblin, Ghoul and Warden were replaced.
- Production enemy gate, main integration, v1.53, v1.55 and v1.52.1 regressions passed.
- Manual image comparison accepted the anatomy direction:
  - Goblin has readable arms/hands/legs and a less spherical silhouette.
  - Ghoul has one coherent hunched body line with low hands and crouched legs.
  - Warden has longer human proportions and slimmer armored body mass.

### Enemy r3 — accepted Bat + Necromancer anatomy baseline

Validation bundle: `4001178b8e7069f072ebe6a255ee8856490377f6`.

- Production Enemy Silhouette workflow passed completely: compile/import, all six silhouettes, main integration, gallery/close-ups, v1.53, v1.55 and v1.52.1 regressions.
- Manual gallery review accepted the new anatomy/silhouette direction.
- Bat: smaller body plus articulated-looking wing structure and angled membrane sections; removes board-wing read.
- Necromancer: tapered multi-stage robe, split front panels, mantle/collar, faceted hood and angled sleeves; removes most of the robe-block/arm-stick read.

### Enemy Surface/Detail r4 — accepted production-detail baseline

Implementation: `4eed3856434c71c3f3f4b430b69cce866679e121`.

r4 keeps r2/r3 anatomy fixed and adds only thin secondary production details using existing material classes:
- Goblin: crossed leather harness, narrow belt, restrained scrap bracer.
- Bat: thin leading/finger wing bones over r3 membranes.
- Ghoul: shallow dark rib planes and short bone/clavicle accents.
- Necromancer: dark mantle edge, robe seams, waist band and restrained clasp.
- Warden: thin chest plate, waist line, knee caps and shoulder trim.
- Skeleton intentionally receives NO r4 detail layer.

The enemy smoke gate explicitly requires r4 detail on Goblin/Bat/Ghoul/Necromancer/Warden and explicitly rejects it on Skeleton. Production Enemy workflow and regressions passed. Manual gallery review accepted r4 as a meaningful material/depth improvement.

### Character Surface r5 — technically valid, visually rejected

Implementation: `4f7d9c0a6f90ca2e43eed0f8c07f034fdbf76068`.
Workflow run: `32185144135`.

- Introduced `v160_character_surface_r5.gdshader`, used only by the six authored enemy body-core materials; Environment and Wanderer shaders remained untouched.
- Shader adds cheap object-space tonal and roughness variation without textures, screen-space effects or extra passes.
- Full production workflow was technically green: shader compile, all six silhouettes, main integration, gallery/close-ups, v1.53, v1.55 and v1.52.1.
- Manual image review rejected the initial strength: Goblin/Ghoul/Warden showed recognizable blotchy/camouflage-like patches rather than natural material variation.
- Do NOT restore initial r5 strengths merely because its CI was green.

### Character Surface r5.1 — accepted surface baseline

Implementation/head: `cb47de3d52e29b8b8a4250e8b5f64b15e8e387b9`.

- Keeps the character-only mobile shader architecture from r5 but greatly reduces visible color modulation.
- Most of the remaining effect is subtle roughness/tonal variation rather than visible colored patches.
- Environment shader and Wanderer shader remain untouched.
- Skeleton uses the compatible character shader with zero additional r5.1 color/roughness breakup, preserving its locked appearance.
- Full current-head validation is green, including Production Enemy, Production Wanderer, Godot, iOS playtest, v1.55, v1.54, v1.53, v1.52.1, Material Depth and authored environment checks.
- Manual side-by-side review against accepted r4 confirms the r5 camouflage/blotch problem is gone:
  - Goblin/Ghoul/Warden retain r4 material separation without recognizable patch patterns.
  - Necromancer remains dark and cloth-like rather than visibly patterned.
  - Bat remains clean/readable.
  - Skeleton is visually effectively unchanged.
- r5.1 is accepted as the current enemy BODY-SURFACE baseline. It is deliberately subtle; future surface work must not turn the procedural signal back into a visible pattern.

## Required regression gates

Before release/upload decisions preserve and rerun relevant checks, especially:
- v1.60 Production Wanderer + runtime/close-up captures
- v1.60 Production Enemy Silhouette + gallery/close-ups
- r4 enemy detail contract: five detailed archetypes, Skeleton unchanged
- r5.1 body-surface contract: character-only shader; no extra Skeleton breakup; no environment shader replacement
- v1.55 Wanderer production regression
- v1.54 real-model intake regression
- v1.53 visual presentation regression
- v1.52.1 input-flow regression
- material-depth gate
- authored environment/tower/meta/focal checks
- Godot compile/import

## Current next priorities

1. Preserve Enemy r2/r3 anatomy + r4 detail + r5.1 subtle body-surface baseline. Do not reset enemy silhouettes again.
2. Return to the remaining Wanderer visual blocker: Hood r11.
3. Hood r11 must use smoother rounded cloth volume with a controlled front opening/cowl, avoiding r9 boxiness and r10 horn-like side points.
4. Keep r8.1 ArcaneCore animation fix and all existing pivots/animation authority untouched.
5. After Hood r11 is visually accepted, reassess the bundled character milestone as a whole before deciding whether it is finally large enough for a TestFlight build. Do not upload a hood micro-pass by itself.

## Release policy

No TestFlight upload merely because commits were added. Bundle enough visible improvement to justify a build, validate regression gates, then decide on the next upload/build number deliberately.
