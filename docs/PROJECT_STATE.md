# One More Floor — Project State

Canonical handoff for continued development. Read this file before changing art direction, character proportions, gameplay authority, release policy or regression gates.

## Current development line

- Milestone: v1.60 authored environment + character-quality milestone
- Pull request: #82 — `v1.60 authored environment milestone`
- Branch: `agent/v1.60-meta-environments`
- Base: `main`
- Last fully validated Wanderer baseline: `87d6dca0f290b0f3f10fe5aabd468ff1625a0ae1` (r5)
- Current active candidate: r6 hood/boot/chest-accent cleanup in the same commit as this file.
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

Head `87d6dca0f290b0f3f10fe5aabd468ff1625a0ae1` is the current safe rollback point. Its dedicated Production Wanderer workflow completed successfully: Godot compile/import, production presentation, main v1.60 actor integration, runtime/close-up captures, v1.55 Wanderer regression and v1.52.1 input-flow regression all passed.

r5 replaced the former simple tapered octagonal cylinders with authored geometry:

- `wanderer_arm.obj`: shoulder/bicep/elbow/forearm/wrist profile plus restrained elbow plane.
- `wanderer_leg.obj`: thigh/knee/calf/ankle taper plus readable knee plane.
- `wanderer_gauntlet.obj`: cuff/wrist shell, tapered hand plate and knuckle ridge.
- All three candidate meshes were checked as closed/watertight before intake.

The r5 close-up is technically correct and anatomically improved, but the visual milestone is not locked yet. Remaining prototype read is concentrated in the pointed hood crown, oversized boot mass and dominant preserved ArcaneCore/chest accent.

### r6 — active focused cleanup

- `wanderer_hood.obj` is rebuilt again with a flatter multi-ring crown rather than an apex/cone, while retaining brow overhang and side cowl drapes.
- `wanderer_boot.obj` becomes a slimmer layered greave/ankle/low-foot/toe-cap assembly.
- New `world3d_actor_factory_v160_character_quality_r6.gd` extends the validated r4 presentation layer and only performs presentation tuning.
- r6 keeps the preserved animated glTF `ArcaneCore` visible but reduces it to an accent; the large purple diamond in r5 was primarily this preserved node, not the tiny authored `V160ChestSigil` alone.
- Authored chest sigil, belt buckle and cape clasp are reduced further.
- Boot placement/scale is reduced further to stop the oversized-foot read.
- Rig hierarchy, animation clips, pivots, sockets, hitboxes, targeting, combat, saves and input remain untouched.

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

1. Validate r6 through Godot import, Production Wanderer, v1.55 and v1.52.1 gates.
2. Inspect idle/attack close-ups and gameplay-camera captures; do not accept from code alone.
3. If hood, chest accent and boots stop dominating, lock the Wanderer silhouette for v1.60.
4. After Wanderer lock, continue the six enemy authored body bases at gameplay scale.

## Release policy

No TestFlight upload merely because commits were added. Bundle enough visible improvement to justify a build, validate regression gates, then decide on the next upload/build number deliberately.
