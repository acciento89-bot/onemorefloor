# One More Floor — Project State

This file is the canonical handoff for continued development. Read it before changing gameplay, art direction, character proportions, environment presentation, release policy, or regression gates.

## Current development line

- Milestone: v1.60 authored environment + character-quality milestone
- Pull request: #82 — `v1.60 authored environment milestone`
- Branch: `agent/v1.60-meta-environments`
- Base: `main`
- Last art implementation commit at this checkpoint: `4aeaf732463cfe6ddaa19e2f1f9e9bbe4e3884b4`
- PR remains intentionally DRAFT.
- Do not trigger TestFlight, increment the App Store build number, or create a version jump until a visibly meaningful bundled milestone is approved.

## Non-negotiable continuity rules

1. Preserve the existing imported v1.55 glTF animation authority and articulated pivots.
2. Do not casually change combat authority, targeting, hitboxes, input, saves, or the 2D HUD while doing presentation work.
3. Do not reintroduce prototype rings, debug discs/seams, generic blockout floor grids, old rounded Wanderer geometry, or retired realm blockouts.
4. Never regress to the broad "armor mannequin / blockout / single-color plastic" character read.
5. Prefer authored geometry and silhouette changes over simply scaling old primitives.
6. Every meaningful visual pass must keep the existing regression gates green before release/upload work.
7. Update this file after every major accepted pass so a new chat/session can resume from the repository rather than memory.

## Accepted v1.60 environment direction

- Authored OBJ environments extend through Home, Hero, Forge, Talents, Vault, Missions, Tower Pass and Store.
- Combat tower Floors 1-50 use authored production floor composition rather than the legacy prototype grid.
- Five realm identities are established: Lower Halls, Ossuary, Iron Bastion, Rift Descent and Starless Spire.
- Authored focal pieces include Ossuary reliquary altar, Iron Bastion forge engine, Rift anchor gate and Starless Starwell dais.
- GL Compatibility surface-depth shading is part of the production look; avoid expensive screen-space dependencies for this mobile target.
- Orthographic combat camera is intentionally lower/stabler for stronger isometric depth.

## Accepted character direction

### Wanderer

The Wanderer is an authored modular OBJ presentation mounted on the existing animated pivots. Existing authored modules include torso, chestplate, hood, mask, pauldron, arm, gauntlet, leg, boot, blade and cape.

Accepted silhouette rules:

- narrow central body mass
- deliberate shoulder asymmetry
- slim arms/legs instead of a toy-like armored body
- overlapping multi-piece shoulder armor
- boot built from greave/foot/toe-cap language rather than a single block
- restrained chest sigil, belt and eye proportions
- readable dark cloth / cool steel / restrained brass / arcane accent materials
- preserve cape, blade and animation readability

### Character-quality pass r3 — 2026-08-18

Starting point was PR #82 head `6b6f5909af5b0fb6d9973a15bd5291cd3cb10445`.

New accepted work on top of that baseline:

- `wanderer_hood.obj` rebuilt from the prior simple shell into a more authored angular hood with crown shaping, broader cowl skirt, brow overhang and side drape wedges.
- `wanderer_chestplate.obj` rebuilt from the prior minimal 12-vertex plate into a layered slim cuirass with tapered core, central keel, clavicle plates, lower lames and restrained side ribs.
- `wanderer_mask.obj` rebuilt from the prior flat extruded hexagonal plate into a faceted face solution with center ridge, cheek planes and split brow geometry.
- Existing HeadPivot/Hips placement, glTF animation authority and combat pivots are intentionally unchanged.

Do not replace this pass with the previous simpler hood/chest/mask geometry unless a regression is demonstrated.

### Enemies

Authored body bases exist for Goblin, Bat, Skeleton, Ghoul, Necromancer and Warden. Keep the retained weapons, eyes, runes and readable archetype details while avoiding a return to blockout body cores.

## Required regression gates

Before release/upload decisions, preserve and rerun the relevant existing checks, including:

- v1.60 Wanderer presentation smoke and visual captures
- character-quality / authored OBJ readiness
- v1.55 Wanderer production regression
- v1.54 real-model intake regression
- v1.59 authored-environment regression
- v1.52.1 input-flow regression
- enemy presentation visual gate
- material-depth gate
- tower/meta/focal environment smoke and captures

## Current next priorities

1. Validate the new Hood + Mask + Chestplate r3 geometry in Godot runtime/front close-up captures.
2. Only if the runtime silhouette exposes clipping/scale issues, tune authored mesh placement/scales without changing pivots.
3. Continue the Wanderer quality pass on remaining torso/cape transitions and material breakup only after the head/chest read is accepted.
4. Then revisit enemy quality where the six new authored body bases still read too coarse in gameplay camera.
5. Keep environment/gameplay systems stable while character presentation is being finalized.

## Release policy

No TestFlight upload from this checkpoint merely because commits were added. Bundle enough visible improvement to justify a build, validate the regression gates, then decide on the next upload/build number deliberately.
