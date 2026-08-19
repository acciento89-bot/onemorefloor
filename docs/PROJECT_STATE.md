# One More Floor — Project State

Canonical handoff for continued development. Read this file before changing art direction, character proportions, gameplay authority, release policy or regression gates. Repository truth wins over chat memory.

## Current development line

- Milestone: v1.60 authored environment + character-quality milestone
- Pull request: #82 — `v1.60 authored environment milestone`
- Branch: `agent/v1.60-meta-environments`
- Base: `main`
- Fully validated and visually accepted implementation head: `3e567bf409a8492a55f672b226ce9ce81c16780f`.
- r11 OBJ topology correction: `4f82a5aeb717a088747eb31849b2d2d97340ba27`.
- Wanderer animation/core safe point: `00a78086d47b06093c1c7554c2713067f3def132` (r8.1).
- Current actor stack: Wanderer r8.1 + accepted Hood r11 + Enemy r2 Goblin/Ghoul/Warden + Enemy r3 Bat/Necromancer + Enemy Detail r4 + accepted Character Surface r5.1.
- Skeleton remains intentionally unchanged by r4 detail and receives zero additional r5.1 procedural breakup.
- PR stays DRAFT.
- Release status: **TestFlight-ready candidate** on implementation head `3e567bf4...`. This means the milestone passed the required code/visual/iOS validation and is ready for a deliberate upload decision; it does NOT authorize an automatic upload.
- No TestFlight trigger, App Store build-number bump or version jump from micro-passes.

## Non-negotiable continuity rules

1. Preserve imported v1.55 glTF animation authority and articulated pivots.
2. Do not casually change combat authority, targeting, hitboxes, input, saves or the 2D HUD during presentation work.
3. Do not reintroduce prototype rings, debug discs/seams, generic floor blockouts, old rounded Wanderer geometry or retired realm blockouts.
4. Never regress to broad armor-mannequin, blockout or single-color-plastic character reads.
5. Prefer authored geometry/silhouette work over merely scaling old primitives.
6. CI green is necessary but not sufficient for visual acceptance. Runtime/gallery/close-up captures decide visual lock.
7. After every meaningful accepted or rejected pass, update this file.
8. A visually rejected pass remains rejected even if CI was green.

## Accepted environment direction

- Authored OBJ environments cover Home, Hero, Forge, Talents, Vault, Missions, Tower Pass and Store.
- Floors 1-50 use authored production composition rather than the legacy prototype grid.
- Realm identities: Lower Halls, Ossuary, Iron Bastion, Rift Descent and Starless Spire.
- Authored focals include Ossuary reliquary altar, Iron Bastion forge engine, Rift anchor gate and Starless Starwell dais.
- GL Compatibility surface-depth shading remains part of the mobile production look.
- Orthographic combat camera remains intentionally lower/stabler for stronger isometric depth.

## Wanderer — accepted direction

Locked visual rules:
- narrow human central mass
- deliberate shoulder asymmetry
- slim/human limbs rather than rods or toy armor
- overlapping shoulder armor
- layered footwear rather than block feet
- restrained chest sigil / ArcaneCore / belt / eyes
- dark cloth / cool steel / restrained brass / arcane accent separation
- preserve cape, blade, imported animation and pivot readability

### r3-r6 foundation

- r3 rebuilt Hood/Chestplate/Mask as authored OBJ geometry.
- r4 rebuilt tailored torso and layered cape.
- r5 replaced rod-like authored arm/leg/gauntlet geometry with stronger anatomy.
- r6 `090b7ce8a702229b9d52600f9d540f68cb73ac9c` remains an older safe rollback point for the modular character direction.

### r7 — technically valid, visually rejected

Close-ups still showed a dominant purple chest diamond, detached-looking vertical arms and smooth cap-like hood. Do not restore this look.

### r8.1 — accepted animation/core fix

Commit: `00a78086d47b06093c1c7554c2713067f3def132`.

- Root cause of persistent large ArcaneCore was the imported Skill animation explicitly animating its scale.
- r8.1 constrains ArcaneCore scale animation keys while retaining animation authority.
- Runtime captures confirmed the large chest diamond is gone.
- Small local arm/gauntlet angles reduce the two-vertical-bars read without changing pivots.

### Hood r9 — safe fallback, no longer canonical

Bundle: `6ed71e52d4c7aea2db8283d55ad0439696027de3`.

- Technically clean and better than the old rounded hood.
- Rejected as final because the crown/front still read too rectangular/boxy.
- Keep the original r9 OBJ only as rollback insurance.

### Hood r10 — technically valid, visually rejected

Candidate bundle: `4001178b8e7069f072ebe6a255ee8856490377f6`.

- CI passed, but side drape forms read like horn-like points around the head.
- r10 is not canonical and must not be restored.

### Hood r11 — accepted canonical hood

Accepted implementation head: `3e567bf409a8492a55f672b226ce9ce81c16780f`.
Topology correction: `4f82a5aeb717a088747eb31849b2d2d97340ba27`.

- Separate asset: `assets/models/actors/v160/wanderer_hood_r11.obj`; r9 remains intact as rollback.
- Factory layer swaps only the visible `V160AuthoredHood` mesh and keeps the existing animated node/pivot/material contract.
- Shape strategy is a continuous smoother cloth/cowl volume: no r9 box crown and no r10 horn-like side points.
- Final valid OBJ uses 142 vertices and 280 faces with face indices bounded to the real vertex count.
- An earlier r11 candidate at head `b36dd73e92b3105d8997f50bff0bf0c5fa43b56b` contained invalid phantom face indices up to 182 while only 142 vertices existed. Godot correctly rejected the OBJ and this cascaded into many red workflows. This was a data/import defect, not a gameplay or enemy regression.
- The corrected OBJ at `4f82a5ae...` restored successful Godot headless project parsing.
- The production Wanderer gate was hardened at `3e567bf4...`: r11 asset must import, the r11 snapshot marker/version must exist, and the visible `V160AuthoredHood.mesh.resource_path` must exactly equal the r11 OBJ path.
- Final valid runtime idle/attack captures were manually reviewed and accepted: the hood reads as one continuous cowl, avoids the r9 boxiness/r10 horns, and retains mask/eye readability.
- Production Wanderer on `3e567bf4...` passed compile, explicit r11 validation, main integration, runtime/close-up renders, v1.55 regression and v1.52.1 input-flow regression.

## Enemies

Authored body bases exist for Goblin, Bat, Skeleton, Ghoul, Necromancer and Warden. Authored OBJ cores own body silhouette; weapons, eyes, runes and restrained archetype accents may remain as separate detail layers.

### Enemy r1 — technically valid, visually rejected

Scaling/material tuning and restored chunky overlays did not solve anatomy. Do not restore the r1 overlay approach.

### Enemy r2 — accepted anatomy baseline

Bundle: `6ed71e52d4c7aea2db8283d55ad0439696027de3`.

- Goblin: readable arms/hands/legs, less spherical silhouette.
- Ghoul: coherent hunched body line with low hands/crouched legs.
- Warden: longer human proportions and slimmer armored body mass.

### Enemy r3 — accepted Bat + Necromancer anatomy baseline

Validation bundle: `4001178b8e7069f072ebe6a255ee8856490377f6`.

- Bat: smaller body, articulated-looking wing structure and angled membrane sections; removes board-wing read.
- Necromancer: tapered multi-stage robe, split front panels, mantle/collar, faceted hood and angled sleeves; removes robe-block/arm-stick read.

### Enemy Detail r4 — accepted production-detail baseline

Implementation: `4eed3856434c71c3f3f4b430b69cce866679e121`.

- Goblin: crossed leather harness, narrow belt, restrained scrap bracer.
- Bat: thin leading/finger wing bones over r3 membranes.
- Ghoul: shallow dark rib planes and short bone/clavicle accents.
- Necromancer: dark mantle edge, robe seams, waist band and restrained clasp.
- Warden: thin chest plate, waist line, knee caps and shoulder trim.
- Skeleton intentionally receives NO r4 detail layer.
- Smoke gate explicitly requires r4 on the five changed archetypes and rejects it on Skeleton.

### Character Surface r5 — technically valid, visually rejected

Implementation: `4f7d9c0a6f90ca2e43eed0f8c07f034fdbf76068`.

- Character-only procedural tonal/roughness shader was technically green.
- Manual gallery review rejected the original strength because Goblin/Ghoul/Warden showed recognizable blotchy/camouflage-like patches.
- Do not restore initial r5 strengths merely because its CI was green.

### Character Surface r5.1 — accepted body-surface baseline

Implementation: `cb47de3d52e29b8b8a4250e8b5f64b15e8e387b9`.

- Keeps the character-only mobile shader architecture but greatly reduces visible color modulation.
- Remaining signal is subtle tonal/roughness variation rather than visible patterning.
- Environment and Wanderer surface shaders remain untouched.
- Skeleton receives zero extra r5.1 breakup.
- Side-by-side image review against r4 accepted r5.1: no camouflage read, Necromancer remains dark/cloth-like, Bat stays clean/readable, Skeleton effectively unchanged.

## Validated milestone gates on `3e567bf4...`

The release-relevant v1.60 code head is clean:
- Godot project parse/import + main scene + gameplay + Deep Tower + progression/release smoke chain: PASS
- Production Wanderer including hard r11 asset/marker/path contract, runtime captures, v1.55 and v1.52.1: PASS
- Production Enemy including all six silhouettes, gallery, v1.53, v1.55 and v1.52.1: PASS
- v1.54 real-model/glTF intake and animation aliases: PASS
- v1.60 Material Depth including visual captures and focal/input regressions: PASS
- v1.60 Authored Environment including meta/tower captures, v1.59 and input regressions: PASS
- iOS playtest: Godot import, Xcode export and unsigned iPhone/iPad device build/package: PASS
- TestFlight upload step in the iOS workflow: intentionally SKIPPED; no build was uploaded by this milestone validation.

## Required regression gates for future changes

Before later release/upload decisions preserve and rerun the relevant checks, especially:
- v1.60 Production Wanderer including explicit r11 asset/marker/path contract and runtime close-ups
- v1.60 Production Enemy Silhouette including gallery/close-ups
- r4 enemy detail contract: five detailed archetypes, Skeleton unchanged
- r5.1 body-surface contract: character-only shader, no extra Skeleton breakup, no environment shader replacement
- v1.55 Wanderer production regression
- v1.54 real-model intake regression
- v1.53 visual presentation regression
- v1.52.1 input-flow regression
- material-depth gate
- authored environment/tower/meta/focal checks
- Godot project parse/import and main gameplay smoke
- iOS playtest before a TestFlight decision

## Current next priorities

1. Preserve r8.1 + accepted Hood r11. Do not return to r9/r10 unless intentionally rolling back a proven regression.
2. Preserve Enemy r2/r3 anatomy + r4 details + r5.1 subtle surface baseline. Do not reset enemy silhouettes again.
3. The invalid-r11 import incident is fixed; do not confuse the old cascade of red runs from `b36dd73e...` with current gameplay quality.
4. v1.60 is now a TestFlight-ready candidate at the validated implementation head. Decide the upload deliberately as a milestone action, not as an automatic side effect.
5. If continuing art before TestFlight, only start a new clearly scoped milestone; do not reopen already accepted r11/enemy anatomy without evidence from gameplay captures.

## Release policy

No TestFlight upload merely because commits were added. The current v1.60 implementation has passed the milestone gates and may be uploaded when deliberately chosen. Any later code/art changes require their own relevant regression pass before replacing `3e567bf4...` as the validated implementation head.
