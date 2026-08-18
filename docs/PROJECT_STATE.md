# One More Floor — Project State

This file is the canonical handoff for continued development. Read it before changing gameplay, art direction, character proportions, environment presentation, release policy, or regression gates.

## Current development line

- Milestone: v1.60 authored environment + character-quality milestone
- Pull request: #82 — `v1.60 authored environment milestone`
- Branch: `agent/v1.60-meta-environments`
- Base: `main`
- Last fully validated Wanderer baseline: `5a405f32fc6bf302de851112d360ec9f2c3ce423`
- Current active candidate: r5 limb-anatomy pass in the same commit as this file.
- PR remains intentionally DRAFT.
- Do not trigger TestFlight, increment the App Store build number, or create a version jump until a visibly meaningful bundled milestone is approved.

## Non-negotiable continuity rules

1. Preserve the imported v1.55 glTF animation authority and articulated pivots.
2. Do not casually change combat authority, targeting, hitboxes, input, saves, or the 2D HUD during presentation work.
3. Do not reintroduce prototype rings, debug discs/seams, generic blockout floor grids, old rounded Wanderer geometry, or retired realm blockouts.
4. Never regress to the broad armor-mannequin / blockout / single-color-plastic character read.
5. Prefer authored geometry and silhouette changes over merely scaling old primitives.
6. Every meaningful visual pass must keep the relevant regression gates green before release/upload work.
7. Update this file after every major pass so a new chat/session can resume from the repository rather than memory.

## Accepted v1.60 environment direction

- Authored OBJ environments cover Home, Hero, Forge, Talents, Vault, Missions, Tower Pass and Store.
- Combat tower Floors 1-50 use authored production floor composition rather than the legacy prototype grid.
- Five realm identities are established: Lower Halls, Ossuary, Iron Bastion, Rift Descent and Starless Spire.
- Authored focal pieces include Ossuary reliquary altar, Iron Bastion forge engine, Rift anchor gate and Starless Starwell dais.
- GL Compatibility surface-depth shading is part of the mobile production look.
- Orthographic combat camera is intentionally lower/stabler for stronger isometric depth.

## Wanderer — accepted direction

The Wanderer uses authored modular OBJ presentation mounted on the existing animated pivots. Modules include torso, chestplate, hood, mask, pauldron, arm, gauntlet, leg, boot, blade and cape.

Locked design rules:

- narrow central body mass
- deliberate shoulder asymmetry
- human/slim limb anatomy instead of rods or toy armor
- overlapping multi-piece shoulder armor
- boot language built from greave/foot/toe-cap rather than a single block
- restrained chest sigil, ArcaneCore, belt and eye proportions
- readable dark cloth / cool steel / restrained brass / arcane accent materials
- preserve cape, blade and animation readability

### r3 — accepted head/chest rebuild

Starting point was PR #82 head `6b6f5909af5b0fb6d9973a15bd5291cd3cb10445`.

- `wanderer_hood.obj`: authored angular hood with crown shaping, cowl skirt, brow overhang and side drape wedges.
- `wanderer_chestplate.obj`: layered slim cuirass with tapered core, central keel, clavicle plates, lower lames and restrained side ribs.
- `wanderer_mask.obj`: faceted face solution with center ridge, cheek planes and split brow geometry.
- HeadPivot/Hips placement, glTF animation authority and combat pivots remained unchanged.

### r4 — fully validated baseline

Head `5a405f32fc6bf302de851112d360ec9f2c3ce423` is the safe Wanderer rollback point. Its dedicated production Wanderer workflow completed successfully, including Godot compile/import, production presentation, main v1.60 actor integration, runtime/close-up captures, v1.55 Wanderer regression and v1.52.1 input-flow regression.

r4 work:

- `wanderer_torso.obj` rebuilt from the rounded/tubular core into a tapered tailored torso with narrower waist, ribcage/shoulder transition, collar volume and restrained front detailing.
- `wanderer_cape.obj` rebuilt into a narrower folded shell with uneven hem and depth variation rather than a broad flat trapezoid.
- `world3d_actor_factory_v160_character_quality_r4.gd` reduces hood/mask, shoulder armor, arm/gauntlet width, boot bulk and chest ornament dominance while lengthening the leg read slightly.
- eye slits moved inward for the smaller face solution.
- chest sigil, ArcaneCore, belt and cape clasp reduced further.
- cloth/cape/steel material separation strengthened under warm tower lighting.
- no articulated pivot or gameplay authority changed.

### r5 — active limb-anatomy candidate

The r4 close-up is clearly slimmer and less chibi, but the remaining low-poly read is concentrated in the old limb base meshes. The old arm, leg and gauntlet were essentially simple tapered octagonal cylinders.

This candidate replaces those three base meshes while keeping the same asset paths and existing pivots:

- `wanderer_arm.obj`: multi-section shoulder/bicep/elbow/forearm/wrist silhouette plus a restrained elbow cloth guard; no straight rod profile.
- `wanderer_leg.obj`: thigh/knee/calf/ankle taper with a readable knee plane; no single conical leg column.
- `wanderer_gauntlet.obj`: cuff/wrist shell plus tapered hand plate and knuckle ridge instead of a single cylinder/block.
- All three candidate meshes were checked as closed/watertight geometry before repository intake.
- Rig nodes, combat pivots, animation authority and gameplay systems remain untouched.

Do not restore the pre-r3 head/chest geometry, pre-r4 rounded torso/broad cape, or pre-r5 rod-like limb geometry unless an actual regression is demonstrated.

## Enemies

Authored body bases exist for Goblin, Bat, Skeleton, Ghoul, Necromancer and Warden. Retain weapons, eyes, runes and archetype details while avoiding blockout body cores.

## Required regression gates

Before release/upload decisions, preserve and rerun relevant checks including:

- v1.60 Wanderer production presentation + runtime/close-up visual captures
- character-quality / authored OBJ readiness
- v1.55 Wanderer production regression
- v1.54 real-model intake regression
- v1.59 authored-environment regression
- v1.52.1 input-flow regression
- enemy presentation visual gate
- material-depth gate
- tower/meta/focal environment checks

## Current next priorities

1. Run the r5 arm/leg/gauntlet candidate through Godot import, Wanderer presentation, v1.55 and v1.52.1 gates.
2. Inspect the new idle/attack close-ups and gameplay-camera render before accepting r5 visually.
3. If limbs now read human rather than rod/block-like, lock the Wanderer silhouette for the v1.60 milestone; only then polish any remaining boot/sigil detail if visibly necessary.
4. After the Wanderer silhouette is locked, continue with the six enemy authored body bases where gameplay-scale quality still needs work.

## Release policy

No TestFlight upload from this checkpoint merely because commits were added. Bundle enough visible improvement to justify a build, validate the regression gates, then decide on the next upload/build number deliberately.
