# One More Floor — Project State

Canonical handoff. **Repository truth wins over chat memory.**

## Active mode — COMPLETE THE GAME, NOT RELEASE
Finish the visible and functional game end-to-end before the next integrated TestFlight build. App Store submission work remains deferred.

## Accepted frontend lock — v1.67 r1.2
- Branch / PR: `agent/v1.66-character-form` / PR #103.
- Home/Hero share gameplay Wanderer authority.
- Forge uses the authored workshop kit.
- Talents use the progression-tree composition.
- Missions use the contract-board composition.
- Vault empty state and Tower Pass direction are retained.
- Existing interaction rectangles, routes and progression authority remain unchanged.

## Accepted character lock — v1.68 Wanderer Visual Completion r1.1
- Production stack inherited through `scripts/main_v92.gd`.
- Gameplay world: `scripts/world3d_chamber_v168_character_completion.gd`.
- Shared actor factory: `scripts/world3d_actor_factory_v168_character_completion.gd`.
- Frontend stage: `scripts/menu3d_stage_v168_character_completion.gd`.
- r1 was technically green but visually rejected because wide horizontal pauldrons read like wings.
- r1.1 corrected only pauldrons, chest proportion, trim and tabard.
- Accepted head before enemy work: `750af8112831f7082c3925670b242253ff228ce0`.
- Real Hero/gameplay review accepted r1.1; Hood r11 and articulated animation authority are preserved.

## Accepted enemy + boss lock — v1.69 r1
- Production stack inherited through `scripts/main_v93.gd`.
- Gameplay world: `scripts/world3d_chamber_v169_enemy_completion.gd`.
- Actor factory: `scripts/world3d_actor_factory_v169_enemy_completion.gd`.
- Dedicated gate run `32338789376`: SUCCESS.
- Evidence artifact `9395598136` / `v169-enemy-boss-visual-completion`.
- Five authored OBJ secondary kits replace the visible v1.66 BoxMesh secondary armour layer for Goblin, Bat, Ghoul, Necromancer and Warden.
- Skeleton remains the locked geometric readability reference.
- Warden keeps shield/blade dominance while chest and shoulder armour read as one authored boss mass.
- Full gameplay authority remained green.

## Accepted realm + endgame lock — v1.70 r1.1
- Active scene: `scenes/main.tscn` -> `scripts/main_v94.gd`.
- Gameplay world: `scripts/world3d_chamber_v170_realm_completion.gd`.
- Accepted correction head: `db2940898206ff0291e4f6c2af3bcff27d3f64e7`.
- r1 added authored edge/foreground framing to all five realms but its Iron boss dais was visually rejected as too broad/orange and competed with the Warden.
- r1.1 retains the successful Lower Halls, Ossuary, Rift and Starless framing while tightening the Iron stage and switching it to dark plate response.
- Dedicated v1.70 run `32340024229`: SUCCESS.
- Evidence artifact `9396034866` / `v170-realm-endgame-visual-completion`.
- Fixed 720x1280 matched review accepted r1.1: Warden remains dominant, Iron stage reads as supporting architecture, and the four other realms retain their added depth.
- Full gameplay smoke and current unsigned iPhone/iPad device build run `32340024326` both passed on the accepted head.
- No collision, navigation, camera, combat timing, input, save or progression authority changed.

## Preserved gameplay/art locks
- v1.67 r1.2 frontend/menu baseline.
- v1.68 r1.1 Wanderer visual completion / Hood r11.
- v1.69 r1 enemy + boss authored silhouettes.
- v1.70 r1.1 realm/endgame authored framing.
- v1.65 r1.3 environment material/depth baseline beneath v1.70.
- v1.64 r1.1 character-lighting/material ordering.
- v1.63 projectile/boss combat identity.
- v1.62 UI/input foundations.
- Save, migration, backup, settings, tutorial, endless/endgame and gameplay authority remain smoke-gated.

## TestFlight
- Build 30 is successfully uploaded and remains the current integrated validation build.
- Do not create TestFlight builds for each completion pass.
- The next TestFlight bundles the finished world, UX and polish blocks.

## Active next — v1.71 UX / Completion Sweep
Purpose: remove remaining development-looking UX and dead ends without reopening accepted art/gameplay locks.

Required sweep:
- identify and remove dead/placeholder routes, stale `coming soon` / `unavailable` production copy and unfinished buttons;
- make Settings, Privacy, Tutorial, Pause/Resume and Game Over exits consistent and reachable;
- verify Home/Hero/Forge/Talents/Vault/Missions/Tower Pass navigation has no dead-end path;
- keep production Store hidden until a real native StoreKit provider exists;
- preserve save/migration/progression authority and existing touch target safety;
- add one dedicated completion smoke that exercises the visible route graph and required production surfaces.

## Remaining completion blocks
1. **UX/settings/tutorial/progression consistency + dead-route cleanup — ACTIVE v1.71.**
2. Audio/VFX/haptics + device-performance polish.
3. Integrated TestFlight build for real iPhone/iPad playtest.
4. Only after device/visual acceptance: release metadata and App Store submission.

## Continuity rules
- Update this file after each major accepted/rejected pass.
- Real captures and device acceptance decide visual completion; CI only proves technical health.
- Keep menu and gameplay Wanderer on one shared actor authority.
- Preserve accepted gameplay/input/save contracts unless a verified blocker requires a change.
- Bundle meaningful work before TestFlight; avoid build-number churn.
