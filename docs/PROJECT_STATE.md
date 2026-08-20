# One More Floor — Project State

Canonical handoff. **Repository truth wins over chat memory.**

## Active development mode — COMPLETE THE GAME, NOT RELEASE
The goal is to finish the visible and functional game end-to-end before another integrated TestFlight build. Release/App Store submission work is deliberately deferred.

## Active candidate — v1.67 Frontend Completion r1.1
- Branch / PR: `agent/v1.66-character-form` / PR #103 (Draft, active development).
- Parent gameplay candidate: v1.66 Character Form & Readability r1.1.
- Active scene path: `scenes/main.tscn` -> `scripts/main_v90.gd`.
- Frontend 3D stage: `scripts/menu3d_stage_v167_completion.gd`.
- Gameplay actor authority reused by frontend: `scripts/world3d_actor_factory_v166_character_form.gd`.

### Shared Wanderer lock
The menu no longer loads a separate `wanderer.gltf` presentation actor. Home and Hero instantiate the **same v1.66 gameplay actor factory** used in the tower (Hood r11, authored chestplate/cape/pauldrons/blade, character-form/material refinements). Future Wanderer improvements must remain shared between gameplay and frontend.

### r1 evidence and decision
`v1.67 Frontend Completion Check` run `32328967497` passed completely on r1: compile, all visible frontend screens, shared gameplay Wanderer contract and full gameplay smoke.

Real 720x1280 captures were then inspected from current-head legacy visual gates:
- Home: correct shared Wanderer and strong base, but character needed more visual authority.
- Hero: correct actor, but old 2D shrine/ring decoration boxed him in.
- Forge: authored assets loaded, but the focal read remained too blockout-like.
- Talents: large green/purple/gold card fills still looked too mobile/indie.
- Vault: empty inventory state left a large unfinished-looking middle area.
- Missions: functional but too table-like.
- Tower Pass: strongest secondary screen; keep its core reward-rail direction.

### r1.1 changes
- Home gameplay Wanderer enlarged and camera tightened.
- Hero gameplay Wanderer enlarged; old 2D shrine clutter removed by the active `main_v90.gd` screen renderer; stats condensed into forged stat chips.
- Forge reuses the authored production `assets/environment/v160/forge_engine.obj` as a dominant focal, enlarges/repositions the anvil and removes the obvious procedural ember-card blockout.
- Forge lower UI is reduced so the 3D environment remains visible.
- Talents retain their existing interaction rectangles but switch to dark neutral forged cards with accent lines instead of saturated slab fills.
- Missions retain existing row hitboxes but gain progress rails, grouped rewards and compact status chips.
- Empty Vault gains an intentional `THE VAULT AWAITS` state instead of a blank central void.
- Tower Pass currently remains on the accepted v1.28 reward-rail structure for later fine polish.

### Validation
- `scripts/v94_menu_completion_smoke_test.gd` now validates r1.1, including `main_v90.gd`, all seven visible menu screens, the exact gameplay Wanderer identity and authored Forge engine focal.
- `.github/workflows/v94-menu-completion-check.yml` remains the fast Ubuntu gate and re-runs the complete gameplay smoke after frontend validation.

## Gameplay candidate — v1.66 Character Form & Readability r1.1
- World: `world3d_chamber_v166_character_form.gd`.
- Actor factory: `world3d_actor_factory_v166_character_form.gd`.
- Original rounded/SphereMesh r1 is rejected.
- r1.1 uses restrained faceted secondary forms; Skeleton geometry remains locked.
- Consolidated v92 gameplay/release-regression gate passed after fixing the Forgotten Castle signature-enemy RNG hole.

## TestFlight
- Build 30 is already successfully uploaded and remains the current validation build.
- Do **not** create TestFlight builds for every visual pass.
- Next TestFlight must bundle several meaningful completion passes after frontend, actor, world, UX and polish work has converged.

## Remaining completion blocks
1. **Frontend/Menu completion** — active; r1.1 now under validation/visual recapture.
2. Character visual acceptance and remaining actor-quality corrections.
3. Full gameplay/environment consistency sweep across all realms/endgame.
4. UX/settings/tutorial/progression consistency and dead-route cleanup.
5. Audio/VFX/haptics + device-performance polish.
6. Integrated TestFlight build for real iPhone/iPad playtest.
7. Only after visual/device acceptance: release metadata and App Store submission.

## Continuity rules
- Update this file after each major pass.
- Do not call the game finished/release-ready because CI is green; **real portrait captures and device acceptance decide**.
- Preserve hitboxes, navigation/collision, timing/damage, save/progression and input contracts unless a verified gameplay blocker requires change.
- Keep menu and gameplay Wanderer on one shared actor authority.
- Avoid repeated TestFlight build-number churn; bundle meaningful completion work first.
