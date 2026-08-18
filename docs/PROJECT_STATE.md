# One More Floor — Project State

Canonical handoff for continued development. Read this file before changing art direction, character proportions, gameplay authority, release policy or regression gates.

## Current development line

- Milestone: v1.60 authored environment + character-quality milestone
- Pull request: #82 — `v1.60 authored environment milestone`
- Branch: `agent/v1.60-meta-environments`
- Base: `main`
- Last fully validated technical Wanderer candidate: `5a5d4b2fa915b609b521912bb79761149eabe475` (r7), but visual lock was rejected after manual capture inspection.
- Last accepted safe rollback baseline remains `090b7ce8a702229b9d52600f9d540f68cb73ac9c` (r6).
- Current Wanderer candidate: r8 capture-driven silhouette correction.
- Current actor stack before this state commit: `d88d84998e7a09ed16a60dddf2600850a1a8af97` = Wanderer r8 + Enemy Quality r1.
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
- No gameplay authority changed.

### r5 — fully validated limb-anatomy baseline

Head `87d6dca0f290b0f3f10fe5aabd468ff1625a0ae1` replaced former simple tapered octagonal cylinders with authored arm, leg and gauntlet OBJ geometry. Candidate meshes were checked closed/watertight before intake.

### r6 — accepted safe rollback baseline

Head `090b7ce8a702229b9d52600f9d540f68cb73ac9c` is the current accepted rollback point.

- Hood uses a flatter multi-ring crown rather than the former apex/cone.
- Boot uses slimmer layered greave/ankle/low-foot/toe-cap geometry.
- Boot mass, chest accents, belt buckle and cape clasp were reduced.
- Dedicated Production Wanderer, v1.55 Wanderer, v1.54 real-model intake, v1.52.1 input-flow, material-depth, enemy silhouette, authored environment and Godot checks completed successfully.
- Manual r6 captures still showed dominant chest accent, detached/segment-like arms and a smooth helmet-like hood, so visual work continued.

### r7 — technically validated, visually rejected

Head `5a5d4b2fa915b609b521912bb79761149eabe475` completed the dedicated Production Wanderer workflow successfully, including Godot compile/import, main v1.60 actor integration, runtime/close-up captures, v1.55 regression and v1.52.1 input-flow regression.

Manual inspection of the actual r7 idle close-up rejected the visual lock:

- preserved purple chest diamond still dominates the torso
- arms remain too long/vertical and read as detached bars
- hood still reads too smooth/cap-like from the front
- overall technical contract is sound; failures are presentation quality only

Do not call r7 visually locked merely because CI is green.

### r8 — active capture-driven correction

Activation commit: `8486af39db2c91d28974cc2febab2b3659e71941`.

- `world3d_actor_factory_v160_character_quality_r8.gd` extends r7 only; no gameplay or rig authority is changed.
- Hood is flattened more aggressively and shifted to expose the faceted mask.
- Authored arms are shortened and pulled inward; gauntlets are moved upward/inward on the same animated arm pivots.
- Pauldron mass is reduced again without changing shoulder pivots.
- Preserved animated glTF `ArcaneCore` remains visible for the production contract but is reduced to 6% scale; authored chest sigil is reduced further.
- Warm highlight contamination is reduced with darker cloth/cape, cooler steel and even more restrained gold/arcane response.
- r8 is NOT accepted until its Production Wanderer workflow and idle/attack/gameplay captures are manually inspected.

Do not restore pre-r3 head/chest geometry, pre-r4 rounded torso/broad cape or pre-r5 rod-like authored limb meshes unless a demonstrated regression requires it.

## Enemies

Authored body bases exist for Goblin, Bat, Skeleton, Ghoul, Necromancer and Warden. Retain weapons, eyes, runes and archetype details while avoiding blockout body cores.

### Gameplay-scale review before Enemy Quality r1

- Skeleton is the clearest of the six current silhouettes.
- Goblin remains too round/chibi.
- Bat wings are too flat/paper-like.
- Ghoul reads as disconnected capsule masses and needs stronger hunch/anatomy/material breakup.
- Necromancer robe/body is still too block-like.
- Warden remains too toy-like and needs a more human armored proportion plus clearer armor-layer separation.

### Enemy Quality r1 — active

Actor stack activation commit: `d88d84998e7a09ed16a60dddf2600850a1a8af97`.

`world3d_actor_factory_v160_enemy_quality_r1.gd` extends Wanderer r8 and is presentation-only.

Focus 1 — Goblin:
- authored OBJ body core remains active
- body width/depth is reduced to move away from the round/chibi silhouette
- scrap shoulder, dagger and eye accents stay visible but are restrained
- body surface is darker/rougher with clearer green edge separation

Focus 2 — Ghoul:
- authored OBJ body core remains active and receives a stronger hunch
- hidden spine details and jaw layer are restored for one predatory silhouette
- claws/eyes are reduced slightly rather than allowed to dominate
- flesh surface is darker/rougher

Focus 3 — Warden:
- authored OBJ core becomes the slimmer dark under-armor body
- existing metal chest, helm and pauldron pieces are restored as an outer armor layer
- shield/blade/horns/eyes/rune remain but are reduced to stop the toy-knight read
- body surface shifts toward dark cool armor rather than purple block mass

Enemy Quality r1 does not alter enemy roots, hitboxes, tell timing, targeting, movement, combat authority or saves.

Bat/Necromancer remain next after visual validation. Skeleton should be preserved unless a capture shows a clear regression.

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

1. Validate the current actor stack: Wanderer r8 + Enemy Quality r1.
2. Download and manually inspect r8 Wanderer idle/attack/gameplay captures.
3. Download and manually inspect Enemy Quality r1 Goblin/Ghoul/Warden gameplay captures.
4. Lock Wanderer only if chest accent, arm-bar read and hood/cap read are materially resolved without new clipping.
5. Keep Enemy Quality r1 only where the visual capture is materially better; revise narrowly if an overlay causes clipping/double geometry.
6. After the first enemy trio is accepted, continue Bat + Necromancer; preserve Skeleton unless necessary.
7. Do not upload TestFlight from character micro-passes; bundle a visibly meaningful milestone first.

## Release policy

No TestFlight upload merely because commits were added. Bundle enough visible improvement to justify a build, validate regression gates, then decide on the next upload/build number deliberately.
