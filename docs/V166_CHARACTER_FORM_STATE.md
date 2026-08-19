# One More Floor — v1.66 Character Form & Readability State

Canonical checkpoint for the active v1.66 actor-quality milestone. **Repository truth wins over chat memory.** Read together with `docs/PROJECT_STATE.md`, `docs/V165_ENVIRONMENT_DEPTH_STATE.md` and `docs/V164_CHARACTER_LIGHTING_STATE.md`.

## Branch / parent
- Active branch: `agent/v1.66-character-form` / PR #103.
- Parent: accepted `main` at `567c83c0cace9c6028075266aa36beb622b554fc`.
- Parent gameplay/presentation lock: v1.65 Environment Surface & Depth r1.3.
- v1.66 must not modify `.github/testflight-trigger` and must not create an additional TestFlight build number.

## Why v1.66 exists
The accepted v1.65 five-realm captures moved environment quality ahead of actor quality. At gameplay distance the remaining largest visible gap is character form: Wanderer armor/weapon hierarchy, dark enemy body separation and Warden armor layering.

## Protected systems
1. Preserve v1.65 r1.3 environment materials/depth/realm identity.
2. Preserve v1.64 character lighting/final material ordering.
3. Preserve v1.63 boss/projectile/combat identity and v1.61 danger semantics.
4. Preserve camera position/focus/orthographic size.
5. Preserve imported animation pivots, sockets, combat hitboxes, navigation, damage/timing/targeting, input, saves, progression and UI.
6. Added form geometry is presentation-only: no collision/navigation authority.
7. Stay GL Compatibility/mobile friendly.
8. Gameplay-distance images decide visual acceptance; CI green alone is insufficient.

## r1 — rejected before promotion
Initial implementation commit: `a070def65ce22075990b783d50f3d50e1d025cfe`.

Technical evidence:
- active stack compiled;
- v1.66 readiness smoke passed;
- hardened v1.64 runtime-order regression passed;
- unsigned iPhone/iPad build passed.

Why r1 is rejected:
- code inspection confirmed enemy secondary volumes were built with `SphereMesh` (`rounded-secondary-volume-and-material-hierarchy`);
- that directly conflicts with the locked visual rule against rounded/blob/mannequin-like character construction;
- therefore r1 cannot become the production lock even if its delayed screenshots eventually render.

The first v91 render attempt was cancelled during capture. A pure capture-harness fix `592ff0c74b7777567633106d706b6a58cee356bb` aligned the viewport lifecycle with the already-stable v1.65 capture path. No game presentation values changed in that fix.

## r1.1 — active candidate
r1.1 replaces the rejected rounded enemy additions with **faceted, thin BoxMesh plates/forms** using existing material families.

Active behavior:
- Wanderer keeps the r1 proportion/material rebalance around accepted Hood r11;
- Goblin uses shoulder plate / buckle / pouch planes instead of rounded masses;
- Bat uses thorax plate + faceted wing roots;
- Ghoul uses asymmetric shoulder/sternum/hip plates;
- Necromancer uses mantle/collar/waist plates;
- Warden uses shoulder/chest/hip armor plates;
- Skeleton remains a complete geometry lock;
- weapon readability scaling remains presentation-only;
- no new lights, camera changes, collision, navigation or gameplay authority.

Hard regression added in `v91_character_form_r1_smoke_test.gd`:
- active world must report `1.66-character-form-r1.1`;
- all archetypes must pass readiness;
- Skeleton must have no `CharacterFormV166` node;
- no added form may contain collision/navigation authority;
- **no `SphereMesh` may exist anywhere inside a v1.66 enemy form layer.**

## v91 evidence required for r1.1
1. Compile/import active `main_v87` stack.
2. Pass r1.1 smoke for Wanderer + all six enemy archetypes.
3. Pass hardened v1.64 runtime material-order regression.
4. Render ten fixed 720x1280 v1.65-before / v1.66-r1.1-after frames across Lower Halls, Ossuary, Iron/Warden, Rift Descent and Starless Spire.
5. Reject/correct r1.1 if plates read as blocky pasted boxes, silhouettes get too wide, weapons lose clarity, or added geometry dominates the actor.
6. Normal branch iOS workflow may validate unsigned iPhone/iPad only; TestFlight upload steps must remain skipped.

## TestFlight status (separate from v1.66)
The previously requested Build 30 dispatch was created from `main`. Its first actual TestFlight workflow run was cancelled by CI concurrency before an Apple upload was confirmed. The cancelled job was explicitly re-run without changing build number; the retry is using the same Build 30 workflow/run lineage. This is not a new v1.66 TestFlight build and does not alter this branch.

## Acceptance rule
Do not promote v1.66 to `main` merely because CI passes. r1 is rejected. Only a visually successful r1.1-or-later matched gameplay-distance review may become the v1.66 production lock.
