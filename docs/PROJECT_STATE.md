# One More Floor — Project State

Canonical handoff. **Repository truth wins over chat memory.**

## Active candidate — v1.66 Character Form & Readability
- Branch: `agent/v1.66-character-form`.
- Parent: accepted `main` at `567c83c0cace9c6028075266aa36beb622b554fc`.
- Active path after the v1.66 r1 bundle lands: `main.tscn` -> `main_v87.gd` -> `world3d_chamber_v166_character_form.gd` -> `world3d_actor_factory_v166_character_form.gd`.
- Detailed state: `docs/V166_CHARACTER_FORM_STATE.md`.
- **v1.66 r1 is a candidate, not yet accepted.** CI + fixed 720x1280 five-realm before/after images decide acceptance.

Why this is next: the accepted v1.65 r1.3 captures moved environment quality ahead of actor quality. Wanderer and several enemy archetypes still compress into low-poly single-mass silhouettes at gameplay distance. v1.66 therefore targets proportion/material hierarchy and restrained rounded secondary form while preserving all gameplay authority.

r1 scope:
- Wanderer: stronger chest/pauldron/blade hierarchy around accepted Hood r11; cape slightly narrowed.
- Goblin/Bat/Ghoul/Necromancer/Warden: small rounded presentation-only secondary volumes plus restrained authored-body/weapon scaling.
- Skeleton: explicit geometry lock; remains the readability benchmark.
- No camera, collision/navigation, hitbox, combat timing/damage/targeting, input, save/progression or UI changes.
- No new light family.

v91 gate plan:
- Godot 4.7.1 compile/import;
- v1.66 runtime readiness across Wanderer + all six enemy archetypes;
- accepted camera/renderer/environment contracts unchanged;
- hardened v1.64 material-order regression PASS;
- ten fixed 720x1280 v1.65-before/v1.66-after images across five realms;
- normal branch iPhone/iPad unsigned compile/package only; TestFlight steps must remain SKIPPED.

## Accepted production parent — v1.65 Environment Surface & Depth r1.3
- Production implementation: `a5951b244166bf824e403eda037a4568194348c6`.
- Final visual/test checkpoint: `c1078573877a4e204405a41f781e92201ac20b85`.
- Final matched visual workflow: `32292817771` — fully green; artifact `9380157967`; ten 720x1280 captures visually accepted.
- Final unsigned iOS workflow: `32292817944` — fully green; unsigned iPhone/iPad compile + package PASS; TestFlight upload SKIPPED.
- Accepted direction: restrained material breakup/patina across all five realms; no neon/debug bars and no large applied low-poly floor patches.

## Locked parents
- v1.64 Character Lighting r1.1: `b4a63b0be50caa5ed08c9984c2101c059347dfe9`; accepted matched run `32286008428`.
- v1.63 Combat Identity: `7262f42002aeeba338559190e8a87a616329ec54`; accepted combined review `32280114378`.
- v1.62 UI: `71c8ecec5387400af7ef1c4bd29a3f87f9323d17`.
- v1.61 Combat Presentation: `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- v1.60 Authored 3D: `3e567bf409a8492a55f672b226ce9ce81c16780f`; Wanderer safe point `00a78086d47b06093c1c7554c2713067f3def132`; Hood r11 `4f82a5aeb717a088747eb31849b2d2d97340ba27`.

## TestFlight state
- The user requested exactly one TestFlight upload after the completed v1.65 block.
- `.github/testflight-trigger` was changed exactly once from Build 29 to **Build 30** in commit `567c83c0cace9c6028075266aa36beb622b554fc`.
- Trigger workflow run identified: `32293490622`. Do not create another Build 30 trigger or automatic retry.
- v1.66 development is post-trigger work and must not touch `.github/testflight-trigger`; branch development uploads remain disabled/skipped.

## Continuity rules
Preserve accepted animation/pivots, gameplay authority, danger semantics, geometry/VFX/UI/lighting/environment locks and rollback points. Gameplay/device images decide visual acceptance; technically green but visually rejected passes stay rejected. Presentation-only geometry must not acquire collision/navigation authority. No accidental repeated TestFlight uploads.

See `docs/V166_CHARACTER_FORM_STATE.md`, `docs/V165_ENVIRONMENT_DEPTH_STATE.md`, `docs/V164_CHARACTER_LIGHTING_STATE.md`, `docs/V163_COMBAT_IDENTITY_STATE.md`, `docs/UI_V162_STATE.md`.
