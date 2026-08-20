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
- Production stack inherited through `scripts/main_v94.gd`.
- Gameplay world: `scripts/world3d_chamber_v170_realm_completion.gd`.
- Accepted correction head: `db2940898206ff0291e4f6c2af3bcff27d3f64e7`.
- r1 added authored edge/foreground framing to all five realms but its Iron boss dais was visually rejected as too broad/orange and competed with the Warden.
- r1.1 retains the successful Lower Halls, Ossuary, Rift and Starless framing while tightening the Iron stage and switching it to dark plate response.
- Dedicated v1.70 run `32340024229`: SUCCESS.
- Evidence artifact `9396034866` / `v170-realm-endgame-visual-completion`.
- Fixed 720x1280 matched review accepted r1.1: Warden remains dominant, Iron stage reads as supporting architecture, and the four other realms retain their added depth.
- Full gameplay smoke and unsigned iPhone/iPad device build run `32340024326` passed on the accepted head.

## Accepted UX / completion lock — v1.71 r1.1
- Active scene: `scenes/main.tscn` -> `scripts/main_v95.gd`.
- Accepted correction head: `3a883e6ebe040bcbb4cd36e7a9377305e91f443f`.
- Pause `RETURN HOME` now requires an explicit abandon confirmation; cancel preserves the live run.
- Replay Tutorial requested during a run starts from Home in the same session instead of relying on an app restart.
- Tutorial may be deliberately skipped before the guided run starts; guided combat remains authoritative once started.
- Settings use production copy, retain Privacy Policy, and no longer expose development/playtest wording.
- Production Store remains fail-closed/hidden until a real native StoreKit provider exists.
- r1 gate was technically green, but real portrait review rejected Settings copy leakage and clipped Tutorial body text.
- r1.1 redraws Settings cleanly and uses explicit portrait-safe Tutorial line layout.
- Dedicated v1.71 run `32350270829`: SUCCESS.
- Evidence artifact `9399620857` / `v171-ux-completion`.
- Fixed 720x1280 review accepted Settings, Pause, Abandon Confirm and Tutorial surfaces.
- Route graph, Privacy/Store guards, abandon flow, tutorial replay/skip and complete gameplay smoke all passed.

## Preserved gameplay/art locks
- v1.67 r1.2 frontend/menu baseline.
- v1.68 r1.1 Wanderer visual completion / Hood r11.
- v1.69 r1 enemy + boss authored silhouettes.
- v1.70 r1.1 realm/endgame authored framing.
- v1.71 r1.1 UX route/modal completion.
- v1.65 r1.3 environment material/depth baseline beneath v1.70.
- v1.64 r1.1 character-lighting/material ordering.
- v1.63 projectile/boss combat identity.
- v1.62 UI/input foundations.
- Save, migration, backup, progression, endless/endgame and gameplay authority remain smoke-gated.

## TestFlight
- Build 30 is successfully uploaded and remains the current integrated validation build.
- Do not create TestFlight builds for each completion pass.
- The next TestFlight bundles the finished world, UX and polish blocks.

## Active next — v1.72 Audio / Haptics / Device Performance Polish
Purpose: make moment-to-moment feedback feel deliberate on iPhone/iPad and remove avoidable mobile runtime waste without changing combat balance.

Required sweep:
- audit gameplay events so boss phases, NOVA, crits, loot, claims, run decisions and destructive UI actions have distinct but restrained feedback;
- add semantic haptic patterns with cooldown/rate limiting so combat bursts cannot buzz continuously;
- harden SFX voice allocation so low-priority attack/hit spam cannot steal boss/claim feedback;
- preserve Music/SFX/Haptics settings and existing realm music identities;
- add a mobile-safe runtime budget gate for pooled actors/VFX, viewport MSAA, renderer and active audio voices;
- preserve 60-FPS target and current iPhone/iPad build contract;
- no new decorative combat VFX unless a missing gameplay tell requires one.

## Remaining completion blocks
1. **Audio/VFX/haptics + device-performance polish — ACTIVE v1.72.**
2. Integrated TestFlight build for real iPhone/iPad playtest.
3. Device-driven corrections if needed.
4. Only after device/visual acceptance: release metadata and App Store submission.

## Continuity rules
- Update this file after each major accepted/rejected pass.
- Real captures and device acceptance decide visual completion; CI only proves technical health.
- Keep menu and gameplay Wanderer on one shared actor authority.
- Preserve accepted gameplay/input/save contracts unless a verified blocker requires a change.
- Bundle meaningful work before TestFlight; avoid build-number churn.
