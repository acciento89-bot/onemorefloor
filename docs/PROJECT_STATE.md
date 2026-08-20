# One More Floor — Project State

Canonical handoff. **Repository truth wins over chat memory.**

## Active development mode — COMPLETE THE GAME, NOT RELEASE
The goal is to finish the visible and functional game end-to-end before another integrated TestFlight build. Release/App Store submission work remains deliberately deferred.

## Active candidate — v1.67 Frontend Completion r1.2
- Branch / PR: `agent/v1.66-character-form` / PR #103 (Draft, active development).
- Parent gameplay candidate: v1.66 Character Form & Readability r1.1.
- Active scene path: `scenes/main.tscn` -> `scripts/main_v91.gd`.
- Frontend 3D stage: `scripts/menu3d_stage_v167_completion_r12.gd`.
- Gameplay actor authority reused by frontend: `scripts/world3d_actor_factory_v166_character_form.gd`.

### Shared Wanderer lock
Home and Hero instantiate the **same v1.66 gameplay actor factory** used in the tower. There is no separate menu Wanderer. Hood r11, authored chestplate/cape/pauldrons/blade and future character-quality improvements must remain shared between gameplay and frontend.

### r1.1 validation and real-image decision
`v1.67 Frontend Completion Check` on r1.1 passed completely: compile, all visible menu screens, exact shared gameplay Wanderer and the full gameplay smoke.

Fresh real 720x1280 captures from head `52959f7590c8e26a1cf9bf0183fcddb061b5fc3d` were inspected:
- v1.60 visual run `32329719710`: full authored environment workflow green; current Talents/Vault/Missions/Tower Pass captures produced successfully.
- v1.59 visual run `32329719688`: Home/Hero/Forge captures produced and uploaded successfully; the workflow later failed only in its historical v1.58 composition regression step.
- Home is structurally strong enough for the frontend candidate.
- Hero composition is substantially cleaner; the **Wanderer model itself** is now the main visible quality bottleneck rather than the menu layout.
- Forge still reads too much like assembled blockout despite the r1.1 engine reuse.
- Talents improved from saturated cards but still reads as stacked cards rather than progression.
- Vault empty-state is acceptable as an intentional destination.
- Missions is improved but still somewhat list/table-like.
- Tower Pass remains the strongest secondary screen and keeps its reward-rail direction.

### r1.2 changes
- Adds dedicated authored v1.67 Forge workshop assets:
  - `assets/environment/v167/forge_workshop_structure.obj`
  - `assets/environment/v167/forge_workshop_trim.obj`
  - `assets/environment/v167/forge_workshop_ember.obj`
- Forge retires the coarse reused focal cluster and layers separate stone/metal, brass trim and ember materials for a denser blacksmith silhouette.
- Forge camera is tightened and its information card is reduced so the 3D workshop owns the screen.
- Talents keeps every existing interaction rectangle but changes the visible composition to a connected progression spine with branch nodes.
- Missions keeps all six contract hitboxes and reward logic but changes the visible composition to daily/weekly contract rails with compact progress/reward surfaces.
- Home/Hero keep the exact shared gameplay Wanderer and their r1.1 composition.

### Validation
- `scripts/v94_menu_completion_smoke_test.gd` validates r1.2 authored assets, all seven visible menu screens, shared Wanderer identity, new Forge nodes, v1.65 environment and v1.62 UI regression locks.
- `.github/workflows/v94-menu-completion-check.yml` remains the fast Ubuntu frontend gate and still runs the complete gameplay smoke.
- Real 720x1280 visual recapture remains mandatory before the frontend block can be considered visually accepted.

## Gameplay candidate — v1.66 Character Form & Readability r1.1
- World: `world3d_chamber_v166_character_form.gd`.
- Actor factory: `world3d_actor_factory_v166_character_form.gd`.
- Original rounded/SphereMesh r1 is rejected.
- r1.1 uses restrained faceted secondary forms; Skeleton geometry remains locked.
- Consolidated v92 gameplay/release-regression gate passed after fixing the Forgotten Castle signature-enemy RNG hole.

## TestFlight
- Build 30 remains the current validation build.
- Do **not** create TestFlight builds for every visual pass.
- Next TestFlight must bundle several meaningful completion passes after frontend, actor, world, UX and polish work has converged.

## Remaining completion blocks
1. **Frontend/Menu completion** — r1.2 under technical gate + real visual recapture.
2. **Character visual completion** — next immediately after frontend acceptance; current captures show the Wanderer itself is now the dominant quality gap.
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
