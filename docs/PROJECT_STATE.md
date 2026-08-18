# One More Floor — Project State

Canonical handoff for continued development. Read this file before changing art direction, character proportions, gameplay authority, release policy or regression gates.

## Current development line

- Milestone: v1.60 authored environment + character-quality milestone
- Pull request: #82 — `v1.60 authored environment milestone`
- Branch: `agent/v1.60-meta-environments`
- Base: `main`
- Last fully validated Wanderer baseline: `090b7ce8a702229b9d52600f9d540f68cb73ac9c` (r6).
- Current active candidate: r7 silhouette-lock candidate, implementation head before this state commit `070d3bfcc2c29379ae3ae660f527287d8b3382c3`.
- PR stays DRAFT.
- No TestFlight trigger, App Store build-number bump or version jump until a visibly meaningful bundled milestone is approved.

## Non-negotiable continuity rules

1. Preserve the imported v1.55 glTF animation authority and articulated pivots.
2. Do not casually change combat authority, targeting, hitboxes, input, saves or the 2D HUD during presentation work.
3. Do not reintroduce prototype rings, debug discs/seams, generic floor blockouts, old rounded Wanderer geometry or retired realm blockouts.
4. Never regress to the broad armor-mannequin / blockout / single-color-plastic read.
5. Prefer authored geometry and silhouette changes over merely scaling old primitives.
6. Meaningful visual passes must retain the relevant regression gates before release/upload work.
7. Update this file after every major pass so a new session resumes from the repository rather than chat memory.

## Accepted environment direction

- Authored OBJ environments cover Home, Hero, Forge, Talents, Vault, Missions, Tower Pass and Store.
- Floors 1-50 use authored production composition rather than the legacy prototype grid.
- Realm identities: Lower Halls, Ossuary, Iron Bastion, Rift Descent and Starless Spire.
- Authored focals include Ossuary reliquary altar, Iron Bastion forge engine, Rift anchor gate and Starless Starwell dais.
- GL Compatibility surface-depth shading is part of the mobile production look.
- Orthographic combat camera remains intentionally lower/stabler for stronger isometric depth.

## Wanderer direction

The Wanderer uses authored modular OBJ presentation mounted on the existing animated pivots. Modules include torso, chestplate, hood, mask, pauldron, arm, gauntlet, leg, boot, blade and cape.

Locked design rules:

- narrow human central mass
- deliberate shoulder asymmetry
- human/slim limb anatomy rather than rods or toy armor
- overlapping shoulder armor
- footwear built from greave/ankle/foot/toe language rather than one block
- restrained chest sigil, ArcaneCore, belt and eye proportions
- dark cloth / cool steel / restrained brass / arcane accent separation
- preserve cape, blade and animation readability

### r3 — accepted head/chest rebuild

Starting point: PR #82 head `6b6f5909af5b0fb6d9973a15bd5291cd3cb10445`.

- Hood rebuilt with authored crown/cowl/brow/drape geometry.
- Chestplate rebuilt as layered slim cuirass.
- Mask rebuilt as faceted face solution.
- HeadPivot/Hips and combat pivots unchanged.

### r4 — accepted body/proportion baseline

- Torso rebuilt from rounded tube to tapered tailored body.
- Cape rebuilt from broad flat trapezoid to narrower folded shell.
- r4 presentation layer reduced head, shoulder, limb, boot and ornament mass and improved cloth/cape/steel separation.
- Eye slits moved inward; sigil, ArcaneCore, belt and clasp reduced.
- No gameplay authority changed.

### r5 — fully validated limb-anatomy baseline

Head `87d6dca0f290b0f3f10fe5aabd468ff1625a0ae1` replaced former simple tapered octagonal cylinders with authored geometry:

- `wanderer_arm.obj`: shoulder/bicep/elbow/forearm/wrist profile plus restrained elbow plane.
- `wanderer_leg.obj`: thigh/knee/calf/ankle taper plus readable knee plane.
- `wanderer_gauntlet.obj`: cuff/wrist shell, tapered hand plate and knuckle ridge.
- All three candidate meshes were checked as closed/watertight before intake.

### r6 — fully validated focused cleanup

Head `090b7ce8a702229b9d52600f9d540f68cb73ac9c` is the current validated rollback point.

- Hood rebuilt with a flatter multi-ring crown rather than an apex/cone while retaining brow overhang and side cowl drapes.
- Boot rebuilt as slimmer layered greave/ankle/low-foot/toe-cap assembly.
- `world3d_actor_factory_v160_character_quality_r6.gd` reduced boot mass, chest accents, belt buckle and cape clasp.
- The preserved animated glTF `ArcaneCore` remained visible but was reduced to an accent.
- Dedicated Production Wanderer, v1.55 Wanderer, v1.54 real-model intake, v1.52.1 input-flow, material-depth, enemy silhouette, authored environment and Godot checks all completed successfully on r6.
- r6 runtime close-ups were inspected manually. Technical readiness is green, but visual lock was rejected because the chest diamond still dominates, arms remain too detached/segment-like and the hood still reads too smooth/helmet-like from the front.

### r7 — active silhouette-lock candidate

Implementation head before this state commit: `070d3bfcc2c29379ae3ae660f527287d8b3382c3`.

- Adds `world3d_actor_factory_v160_character_quality_r7.gd`, extending the fully validated r6 layer only.
- Hood is narrowed and shifted to expose more of the faceted mask and reduce the smooth cap/helmet read.
- Authored pauldrons, arms and gauntlets are pulled inward on their existing presentation meshes only; articulated pivots remain untouched.
- Boot mass is reduced one more step while retaining the r6 authored layered boot geometry.
- Animated `ArcaneCore` scale reduced from r6 accent level to a small tertiary magical core; authored chest sigil, buckle and clasp reduced further.
- Material hierarchy is cooled/darkened: darker cloth/cape, cooler restrained steel, less saturated leather/gold and lower arcane emission.
- `world3d_chamber_v160_actors.gd` now activates the r7 actor factory.
- r7 is NOT accepted/locked until the dedicated Production Wanderer workflow and runtime/close-up captures are inspected.

Do not restore pre-r3 head/chest geometry, pre-r4 rounded torso/broad cape or pre-r5 rod-like limbs unless a demonstrated regression requires it.

## Enemies

Authored body bases exist for Goblin, Bat, Skeleton, Ghoul, Necromancer and Warden. Retain weapons, eyes, runes and archetype details while avoiding blockout body cores.

## Required regression gates

Before release/upload decisions preserve and rerun relevant checks, especially:

- v1.60 Production Wanderer presentation + runtime/close-up visual captures
- character-quality / authored OBJ readiness
- v1.55 Wanderer production regression
- v1.54 real-model intake regression
- v1.59 authored-environment regression
- v1.52.1 input-flow regression
- enemy presentation visual gate
- material-depth gate
- tower/meta/focal environment checks

## Current next priorities

1. Validate r7 through Godot import, Production Wanderer, v1.55, v1.54 and v1.52.1 gates.
2. Download and inspect r7 idle/attack close-ups plus gameplay-camera captures.
3. Lock Wanderer silhouette for v1.60 only if the chest accent, detached-arm read and hood/helmet read are materially improved without new clipping.
4. If locked, record r7 as the canonical Wanderer baseline and move to the six enemy authored body bases at gameplay scale.
5. If not locked, make only a narrowly targeted r8 fix based on visible capture evidence; do not reopen already accepted body geometry broadly.

## Release policy

No TestFlight upload merely because commits were added. Bundle enough visible improvement to justify a build, validate regression gates, then decide on the next upload/build number deliberately.
