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
- Production stack: `scenes/main.tscn` inherited through `scripts/main_v92.gd`.
- Gameplay world: `scripts/world3d_chamber_v168_character_completion.gd`.
- Shared actor factory: `scripts/world3d_actor_factory_v168_character_completion.gd`.
- Frontend stage: `scripts/menu3d_stage_v168_character_completion.gd`.
- r1 was technically green but visually rejected because wide horizontal pauldrons read like wings.
- r1.1 corrected only pauldrons, chest proportion, trim and tabard.
- Final r1.1 head before enemy work: `750af8112831f7082c3925670b242253ff228ce0`.
- v1.68 gate proved OBJ import, shared menu/gameplay identity, matched captures and full gameplay smoke.
- Real Hero/gameplay review accepted r1.1: tighter silhouette, no wing read, Hood r11 and articulated animation authority preserved.

## Accepted enemy + boss lock — v1.69 r1
- Active scene: `scenes/main.tscn` -> `scripts/main_v93.gd`.
- Gameplay world: `scripts/world3d_chamber_v169_enemy_completion.gd`.
- Actor factory: `scripts/world3d_actor_factory_v169_enemy_completion.gd`.
- Evidence head: `78622215695ab33a3eee451d72bc23a4160024b8`.
- Dedicated gate: run `32338789376` — SUCCESS.
- Evidence artifact: `9395598136` / `v169-enemy-boss-visual-completion`.
- Five authored OBJ secondary kits replace the visible v1.66 BoxMesh secondary armour layer for Goblin, Bat, Ghoul, Necromancer and Warden.
- Existing v1.60 authored body cores, weapons, eyes, tells, animation, hitboxes and combat authority remain inherited.
- Skeleton is the locked geometric readability reference and receives no new v1.69 geometry.
- Warden keeps shield/blade dominance while chest and shoulder armour now read as one authored boss mass rather than stacked box plates.
- Fixed 720x1280 before/after evidence was produced for Lower Halls, Ossuary, Iron Warden, Rift Descent and Starless Spire.
- Import/compile, v1.69 enemy readiness, Skeleton lock and complete gameplay smoke all passed.
- Visual review accepted r1 as a net improvement; no additional decorative combat VFX were added.

## Preserved gameplay/art locks
- v1.67 r1.2 frontend/menu baseline.
- v1.68 r1.1 Wanderer visual completion / Hood r11.
- v1.69 r1 enemy + boss authored secondary silhouettes.
- v1.65 r1.3 environment surface/depth baseline.
- v1.64 r1.1 character-lighting/material ordering.
- v1.63 projectile/boss combat identity.
- v1.62 UI/input foundations.
- Save, migration, backup, settings, tutorial, endless/endgame and gameplay authority remain smoke-gated.

## TestFlight
- Build 30 is successfully uploaded and remains the current integrated validation build.
- Do not create TestFlight builds for each completion pass.
- The next TestFlight must bundle several completed blocks after world, UX and polish work converge.

## Remaining completion blocks
1. **Full realm/endgame visual consistency sweep — ACTIVE NEXT.**
2. UX/settings/tutorial/progression consistency and dead-route cleanup.
3. Audio/VFX/haptics and device-performance polish.
4. Integrated TestFlight build for real iPhone/iPad playtest.
5. Only after device/visual acceptance: release metadata and App Store submission.

## Realm/endgame acceptance rules
- Work from the accepted v1.65 environment-depth stack; do not regress the five realm identities.
- Improve authored focal structures, floor/wall depth, dressing density and endgame/boss-stage composition instead of adding debug-like bars or generic glow clutter.
- Keep the v1.68 Wanderer and v1.69 enemy/boss locks unchanged.
- Use fixed 720x1280 matched captures across all five realms before visual acceptance.
- Preserve camera, collision, navigation, combat timing, input, saves and progression authority.

## Continuity rules
- Update this file after each major accepted/rejected pass.
- Real portrait captures and device acceptance decide visual completion; CI only proves technical health.
- Keep menu and gameplay Wanderer on one shared actor authority.
- Preserve accepted gameplay/input/save contracts unless a verified blocker requires a change.
- Bundle meaningful work before TestFlight; avoid build-number churn.
