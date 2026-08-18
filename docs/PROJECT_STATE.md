# One More Floor — Project State

Canonical handoff for continued development. Read this file before changing art direction, character proportions, gameplay authority, release policy or regression gates.

## Current development line

- Milestone: v1.60 authored environment + character-quality milestone
- Pull request: #82 — `v1.60 authored environment milestone`
- Branch: `agent/v1.60-meta-environments`
- Base: `main`
- Last validated actor implementation before this state update: `4eed3856434c71c3f3f4b430b69cce866679e121`.
- Wanderer animation/core safe point: `00a78086d47b06093c1c7554c2713067f3def132` (r8.1).
- Current actor stack: Wanderer r8.1 + temporary Hood r9 + Enemy r2 Goblin/Ghoul/Warden + Enemy r3 Bat/Necromancer + accepted Enemy Surface/Detail r4. Skeleton remains intentionally unchanged.
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
- r10 is NOT canonical. The corrective commit restored r9 while preserving r8.1 and the accepted enemy work.
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
- These remain anatomy baselines, not final surface/detail art.

### Enemy r3 — accepted Bat + Necromancer anatomy baseline

Validation bundle: `4001178b8e7069f072ebe6a255ee8856490377f6`.

- Production Enemy Silhouette workflow passed completely: compile/import, all six silhouettes, main integration, gallery/close-ups, v1.53, v1.55 and v1.52.1 regressions.
- Manual gallery review accepted the new anatomy/silhouette direction.

Bat r3:
- smaller head/torso, ears, feet/tail
- articulated-looking shoulder -> elbow -> wrist -> tip wing bones
- three angled membrane sections per wing
- removes the previous flat board-wing read

Necromancer r3:
- tapered multi-stage robe
- split front panels, mantle/collar and faceted hood
- angled two-part sleeves instead of hanging arm rods
- face/staff/crown/rune remain restrained accents
- removes most of the former single-block robe silhouette

### Enemy Surface/Detail r4 — accepted production-detail baseline

Implementation commit: `4eed3856434c71c3f3f4b430b69cce866679e121`.

r4 does NOT replace or rescale the accepted r2/r3 anatomy. It adds a new thin secondary detail layer using the existing production material classes. The rejected r1 chunky overlay strategy is not restored.

Accepted visual changes after manual gallery/close-up inspection:
- Goblin: crossed leather harness, narrow belt and restrained scrap bracer create clear body/clothing separation.
- Bat: thin leading/finger wing bones now read over the r3 membrane geometry, improving structure without changing wing silhouette.
- Ghoul: shallow dark rib planes and short bone/clavicle accents break the single flesh mass while preserving the r2 hunch.
- Necromancer: dark mantle edge, long front robe seams, waist band and restrained clasp create layered cloth/material separation.
- Warden: thin chest plate, waist line, knee caps and shoulder trim create a clearer metal hierarchy without replacing r2 anatomy.
- Skeleton intentionally receives NO r4 detail layer and remains locked to the existing baseline.

Technical contract:
- `v74_enemy_presentation_smoke_test.gd` now explicitly requires the r4 detail layer on Goblin/Bat/Ghoul/Necromancer/Warden and explicitly rejects it on Skeleton.
- The production enemy workflow passed compile/import, all six silhouettes, main integration, gallery/close-ups, v1.53, v1.55 and v1.52.1 regressions.
- Manual image review accepted r4 as a meaningful surface/detail improvement.

r4 is an accepted surface/detail BASELINE, not final production art. The enemies still carry a visible low-poly/faceted read at close range and need later material/surface sophistication without resetting anatomy.

## Required regression gates

Before release/upload decisions preserve and rerun relevant checks, especially:
- v1.60 Production Wanderer + runtime/close-up captures
- v1.60 Production Enemy Silhouette + gallery/close-ups
- r4 enemy detail-layer contract (five detailed archetypes, Skeleton unchanged)
- v1.55 Wanderer production regression
- v1.54 real-model intake regression
- v1.53 visual presentation regression
- v1.52.1 input-flow regression
- material-depth gate
- authored environment/tower/meta/focal checks
- Godot compile/import

## Current next priorities

1. Preserve Enemy r2/r3 anatomy + r4 detail baseline; do not reset silhouettes again.
2. Next enemy polish should target material/surface sophistication and controlled close-range faceting, not additional bulky overlay geometry.
3. Keep r8.1 + temporary Hood r9 stable while enemy surface work proceeds.
4. Hood r11 remains a focused later task and must use smoother cloth volume while avoiding both r9 boxiness and r10 horn-like points.
5. After another visible surface-quality pass, evaluate whether the character milestone is large enough to justify a TestFlight build; do not upload micro-passes.

## Release policy

No TestFlight upload merely because commits were added. Bundle enough visible improvement to justify a build, validate regression gates, then decide on the next upload/build number deliberately.
