# One More Floor — Project State

Canonical handoff for continued development. Read this file before changing art direction, character proportions, gameplay authority, release policy or regression gates.

## Current development line

- Milestone: v1.60 authored environment + character-quality milestone
- Pull request: #82 — `v1.60 authored environment milestone`
- Branch: `agent/v1.60-meta-environments`
- Base: `main`
- Last fully validated bundle before the active candidate: `6ed71e52d4c7aea2db8283d55ad0439696027de3`.
- Wanderer animation/core safe point: `00a78086d47b06093c1c7554c2713067f3def132` (r8.1).
- Active candidate in the commit containing this file: Wanderer Hood r10 + Enemy Quality r3 (Bat/Necromancer), layered on accepted r8.1 and Enemy r2 anatomy.
- PR stays DRAFT.
- No TestFlight trigger, App Store build-number bump or version jump until a visibly meaningful bundled milestone is approved.

## Non-negotiable continuity rules

1. Preserve the imported v1.55 glTF animation authority and articulated pivots.
2. Do not casually change combat authority, targeting, hitboxes, input, saves or the 2D HUD during presentation work.
3. Do not reintroduce prototype rings, debug discs/seams, generic floor blockouts, old rounded Wanderer geometry or retired realm blockouts.
4. Never regress to the broad armor-mannequin / blockout / single-color-plastic read.
5. Prefer authored geometry and silhouette changes over merely scaling old primitives.
6. CI green is necessary but not sufficient for visual acceptance. Inspect actual runtime/close-up captures.
7. Update this file after every meaningful accepted/rejected pass so a new session resumes from repository truth rather than chat memory.

## Accepted environment direction

- Authored OBJ environments cover Home, Hero, Forge, Talents, Vault, Missions, Tower Pass and Store.
- Floors 1-50 use authored production composition rather than the legacy prototype grid.
- Realm identities: Lower Halls, Ossuary, Iron Bastion, Rift Descent and Starless Spire.
- Authored focals include Ossuary reliquary altar, Iron Bastion forge engine, Rift anchor gate and Starless Starwell dais.
- GL Compatibility surface-depth shading remains part of the mobile production look.
- Orthographic combat camera remains intentionally lower/stabler for stronger isometric depth.

## Wanderer

Locked design rules:

- narrow human central mass
- deliberate shoulder asymmetry
- human/slim limb anatomy rather than rods or toy armor
- overlapping shoulder armor
- footwear built from greave/ankle/foot/toe language rather than one block
- restrained chest sigil / ArcaneCore / belt / eye proportions
- dark cloth / cool steel / restrained brass / arcane accent separation
- preserve cape, blade and animation readability

### r3-r6 accepted foundation

- r3 rebuilt Hood/Chestplate/Mask as authored OBJ geometry.
- r4 rebuilt tailored torso and layered cape.
- r5 replaced rod-like authored arm/leg/gauntlet geometry with stronger anatomy.
- r6 (`090b7ce8a702229b9d52600f9d540f68cb73ac9c`) remains an older safe rollback point for the established modular character direction.

### r7 — technically valid, visually rejected

- CI was green, but close-ups still showed dominant purple chest diamond, vertical detached-looking arms and a smooth cap-like hood.
- Do not call r7 visually locked merely because CI passed.

### r8.1 — accepted animation/core fix

Commit: `00a78086d47b06093c1c7554c2713067f3def132`.

- Root cause of the persistent large chest diamond was found in the imported glTF: Skill animates `ArcaneCore` scale, overriding a simple factory node scale.
- r8.1 constrains the ArcaneCore animation scale keys while preserving the animation itself.
- New captures confirmed the large chest diamond is genuinely gone.
- Small local arm/gauntlet angles reduce the two-vertical-bars read without changing pivots.
- Production Wanderer, v1.55, v1.54, v1.52.1, Material Depth, Godot and iOS playtest gates passed.

### Hood r9 — technically valid, not final visual lock

Bundle: `6ed71e52d4c7aea2db8283d55ad0439696027de3`.

- r9 replaced the former rounded/cap-like hood with a new authored OBJ.
- Production Wanderer gate and regressions passed.
- Manual close-up review: r9 is less dome-like, but the crown/cowl reads too rectangular/boxy to lock as final.
- Keep r8.1 chest/core fix; continue only the Hood/Cowl shape rather than reopening the whole Wanderer.

### Hood r10 — active candidate

- New authored closed mesh: 88 vertices / 148 faces.
- Uses multi-ring angular crown, brow overhang, separate side drapes, shoulder cowl plates and a rear center fold.
- Presentation layer gives the new cloth more vertical presence while keeping mask visibility and human head scale.
- Not accepted until Production Wanderer + close-up/gameplay captures are manually reviewed.

## Enemies

Authored body bases exist for Goblin, Bat, Skeleton, Ghoul, Necromancer and Warden. Weapons, eyes, runes and archetype accents may remain as separate readable detail layers while authored OBJ cores own the body silhouette.

### Enemy r1 — technically valid, visually rejected

- r1 used scaling/material changes and restored procedural overlay parts on Goblin/Ghoul/Warden.
- Six-silhouette, main-integration, gallery, v1.53, v1.55 and v1.52.1 gates passed.
- Manual gallery review rejected r1: Goblin remained chibi, Ghoul became blockier and Warden still read as toy knight.
- Do not restore the rejected r1 overlay approach.

### Enemy r2 — accepted anatomy baseline, not final art lock

Bundle: `6ed71e52d4c7aea2db8283d55ad0439696027de3`.

- Replaced the actual authored OBJ cores for Goblin, Ghoul and Warden instead of stacking overlays.
- All production enemy checks and regressions passed.
- Manual image comparison against r1 shows material silhouette improvement:
  - Goblin now has readable arms/hands/legs and a less spherical body/head structure.
  - Ghoul now has a coherent hunched body line with low hands and crouched legs instead of disconnected capsule masses.
  - Warden now has longer human proportions and slimmer armored body mass instead of the short toy-knight silhouette.
- r2 is accepted as the new anatomy baseline for these three, but they still need later surface/detail polish to escape the remaining low-poly read.
- Skeleton remains the clearest existing enemy and should be preserved unless a later capture shows a real issue.

### Enemy r3 — active Bat + Necromancer candidate

Bat:
- new closed authored mesh: 246 vertices / 416 faces
- smaller head/torso, ears, feet/tail
- wing bones articulate shoulder -> elbow -> wrist -> tip
- three angled membrane sections per wing replace the previous flat board-wing silhouette

Necromancer:
- new closed authored mesh: 166 vertices / 288 faces
- tapered multi-stage robe rather than one block
- split front robe panels
- mantle/collar layer
- faceted hood shell
- angled two-part sleeves rather than hanging arm rods
- existing face/staff/crown/rune remain as restrained accents

Enemy r3 is not accepted until the production enemy gate and actual gallery/close-up captures are inspected.

## Required regression gates

Before release/upload decisions preserve and rerun relevant checks, especially:

- v1.60 Production Wanderer + runtime/close-up captures
- v1.60 Production Enemy Silhouette + gallery/close-ups
- v1.55 Wanderer production regression
- v1.54 real-model intake regression
- v1.53 visual presentation regression
- v1.52.1 input-flow regression
- material-depth gate
- authored environment/tower/meta/focal checks
- Godot compile/import

## Current next priorities

1. Validate active Hood r10 + Enemy r3 bundle through Godot/import and production actor gates.
2. Manually inspect Wanderer idle/attack/gameplay captures; accept Hood r10 only if the boxy r9 crown is materially resolved without clipping.
3. Manually inspect Bat/Necromancer gallery and close-ups; accept only if Bat loses the board-wing read and Necromancer loses the robe-block/arm-stick read.
4. Preserve Goblin/Ghoul/Warden r2 as the current anatomy baseline while r3 is evaluated.
5. After all six enemies have acceptable silhouettes, move to surface/detail polish rather than another wholesale anatomy reset.
6. Do not upload TestFlight from these character micro-passes; bundle a visibly meaningful milestone first.

## Release policy

No TestFlight upload merely because commits were added. Bundle enough visible improvement to justify a build, validate regression gates, then decide on the next upload/build number deliberately.
