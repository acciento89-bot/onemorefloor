# One More Floor — Project State

Canonical handoff. **Repository truth wins over chat memory.**

## Active development mode — COMPLETE THE GAME, NOT RELEASE
The project is back in active product-completion development. Release preparation is **not** the current goal. The immediate goal is to finish the visible game end-to-end: frontend/menu presentation, shared character identity, remaining environment/character polish, UX consistency, then final device QA.

## Active candidate — v1.67 Frontend Completion r1
- Branch / PR: `agent/v1.66-character-form` / PR #103.
- Parent gameplay candidate: v1.66 Character Form & Readability r1.1.
- Active scene path: `scenes/main.tscn` -> `scripts/main_v89.gd`.
- Frontend stage: `scripts/menu3d_stage_v167_completion.gd`.
- Gameplay actor authority reused by frontend: `scripts/world3d_actor_factory_v166_character_form.gd`.

### Why this pass exists
The menu previously loaded `res://assets/models/actors/wanderer.gltf` directly while gameplay used the much newer v1.66 actor-factory stack (Hood r11, authored armor/cape/blade, material hierarchy and character-form refinements). That created two visibly different Wanderers.

v1.67 removes that split. Home and Hero now instantiate the **same gameplay Wanderer factory** used inside the tower. Future Wanderer improvements therefore propagate to gameplay and frontend together.

### v1.67 r1 scope
- Home/Hero use the exact v1.66 gameplay Wanderer authority.
- Home, Hero, Forge, Talents, Vault, Missions and Tower Pass receive a unified authored 3D composition/lighting pass.
- Existing v1.59/v1.60 OBJ environment assets remain the environment authority; no return to giant procedural blockout architecture.
- Existing v1.62 UI/input, v1.63 combat identity, v1.64 character lighting and v1.65 environment depth remain protected.
- Store remains hidden in production while no native StoreKit provider exists.
- New validation: `scripts/v94_menu_completion_smoke_test.gd` + `.github/workflows/v94-menu-completion-check.yml`.

## Current gameplay candidate — v1.66 Character Form & Readability r1.1
- World: `world3d_chamber_v166_character_form.gd`.
- Actor factory: `world3d_actor_factory_v166_character_form.gd`.
- r1 rounded/SphereMesh direction is rejected.
- r1.1 uses restrained faceted secondary forms; Skeleton geometry remains locked.
- v92 consolidated gameplay/release-regression gate passed after fixing the Forgotten Castle first-floor signature-enemy RNG hole.
- The pending macOS v91 visual evidence remains useful for judging actor form, but it no longer blocks continuing game-completion work.

## TestFlight
- Build 30 is the existing TestFlight validation build and was successfully uploaded after retry.
- Do not create extra TestFlight builds for every visual/development pass.
- Next TestFlight should be a meaningful integrated completion build after several remaining game-completion passes are bundled.

## Remaining completion blocks
1. **Frontend/Menu completion** — active now.
2. Character visual acceptance and any remaining actor quality corrections.
3. Full gameplay/environment consistency sweep across all realms/endgame.
4. UX/menus/settings/tutorial/progression consistency and dead-route cleanup.
5. Audio/VFX/haptics polish and device-performance pass.
6. Integrated TestFlight build for real iPhone/iPad playtest.
7. Only after that: release metadata/App Store submission work.

## Continuity rules
- After each major pass, update this file.
- Do not call the game release-ready merely because CI is green; visual/device acceptance decides.
- Preserve accepted gameplay authority, hitboxes, navigation/collision, timing/damage, save/progression and input contracts unless a verified gameplay blocker requires change.
- Keep menu and gameplay Wanderer on one shared actor authority from v1.67 onward.
- Avoid repeated TestFlight build-number churn; bundle meaningful completion work first.
