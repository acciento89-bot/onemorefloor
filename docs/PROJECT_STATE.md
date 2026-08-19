# One More Floor — Project State

Canonical handoff. **Repository truth wins over chat memory.**

## Active candidate — v1.66 Character Form & Readability
- PR #103 / branch `agent/v1.66-character-form`.
- Parent: accepted `main` at `567c83c0cace9c6028075266aa36beb622b554fc`.
- Active path: `main.tscn` -> `main_v87.gd` -> `world3d_chamber_v166_character_form.gd` -> `world3d_actor_factory_v166_character_form.gd`.
- Detailed state: `docs/V166_CHARACTER_FORM_STATE.md`.
- **r1 is rejected. r1.1 is the active candidate and is not yet visually accepted.**

Why v1.66 is next: accepted v1.65 r1.3 moved environment quality ahead of actor quality. Wanderer and several enemies still compress into low-detail/single-mass silhouettes at gameplay distance.

### r1 — rejected
Initial bundle `a070def65ce22075990b783d50f3d50e1d025cfe` was technically healthy: compile/readiness/hardened v1.64 regression and unsigned iPhone/iPad build all passed.

It is nevertheless rejected because code review confirmed the added enemy form used `SphereMesh` rounded secondary volumes. That directly violates the locked anti-blob/mannequin art direction. r1 cannot become a production lock even if its delayed screenshots eventually render.

A pure v91 capture-harness fix `592ff0c74b7777567633106d706b6a58cee356bb` aligned the fixed 720x1280 viewport lifecycle with the already-stable v1.65 capture path; it changed no game presentation values.

### r1.1 — active candidate
Current r1.1 removes the rejected sphere/blob additions and replaces them with thin faceted BoxMesh presentation plates/forms:
- Wanderer keeps the stronger chest/pauldron/blade hierarchy around accepted Hood r11;
- Goblin: shoulder plate / buckle / pouch;
- Bat: thorax plate + faceted wing roots;
- Ghoul: asymmetric shoulders / sternum / hip plate;
- Necromancer: mantle / collar / waist plates;
- Warden: shoulder / chest / hip armor plates;
- Skeleton remains a complete geometry lock;
- no camera, lighting, collision/navigation, hitbox, gameplay, input, save/progression or UI changes.

v91 r1.1 gate additionally forbids any `SphereMesh` inside `CharacterFormV166` and preserves the existing no-collision/no-navigation contract.

Acceptance still requires ten fixed 720x1280 v1.65-before/v1.66-r1.1-after images across all five realms. Reject/correct r1.1 if plates read as pasted boxes, silhouettes become too wide or the added form dominates the actor.

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
- Build 30 remains the requested TestFlight build number; no Build 31 was created.
- Original trigger workflow `32293490622` successfully dispatched `ios-testflight.yml` on main.
- First actual Build 30 TestFlight run `32296684353` was cancelled before Apple upload confirmation.
- The cancelled Build 30 job was explicitly re-run **with the same workflow/run lineage and same build number**; no new trigger commit and no new build number were created.
- Current Build 30 retry job ID: `96241827655` (queued at the last recorded checkpoint).
- v1.66 branch development must not touch `.github/testflight-trigger`; branch TestFlight steps remain skipped.

## Continuity rules
Preserve accepted animation/pivots, gameplay authority, danger semantics, geometry/VFX/UI/lighting/environment locks and rollback points. Gameplay/device images decide visual acceptance; technically green but visually rejected passes stay rejected. Presentation-only geometry must not acquire collision/navigation authority. No accidental repeated TestFlight build-number increments.

See `docs/V166_CHARACTER_FORM_STATE.md`, `docs/V165_ENVIRONMENT_DEPTH_STATE.md`, `docs/V164_CHARACTER_LIGHTING_STATE.md`, `docs/V163_COMBAT_IDENTITY_STATE.md`, `docs/UI_V162_STATE.md`.
