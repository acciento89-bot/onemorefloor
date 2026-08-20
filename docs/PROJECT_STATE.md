# One More Floor — Project State

Canonical handoff. **Repository truth wins over chat memory.**

## Active mode — v1.74 BRANDING CANDIDATE, NOT APP STORE RELEASE
The visible and functional completion blocks through v1.73 are accepted. TestFlight build 31 (`1.26.0 (31)`) is confirmed available for iOS testing. Active development is v1.74 Branding + Product Identity Completion on `agent/v1.74-branding-product-identity`; visual evidence must pass before acceptance.

## Accepted frontend lock — v1.67 r1.2
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
- r1 was visually rejected because wide horizontal pauldrons read like wings.
- r1.1 corrected pauldrons, chest proportion, trim and tabard while preserving Hood r11 and articulated animation authority.
- Accepted implementation checkpoint: `750af8112831f7082c3925670b242253ff228ce0`.

## Accepted enemy + boss lock — v1.69 r1
- Production stack inherited through `scripts/main_v93.gd`.
- Gameplay world: `scripts/world3d_chamber_v169_enemy_completion.gd`.
- Actor factory: `scripts/world3d_actor_factory_v169_enemy_completion.gd`.
- Dedicated gate run `32338789376`: SUCCESS.
- Evidence artifact `9395598136` / `v169-enemy-boss-visual-completion`.
- Five authored OBJ secondary kits replace the visible v1.66 BoxMesh secondary armour layer for Goblin, Bat, Ghoul, Necromancer and Warden.
- Skeleton remains the locked geometric readability reference.
- Warden keeps shield/blade dominance while chest and shoulder armour read as one authored boss mass.

## Accepted realm + endgame lock — v1.70 r1.1
- Production stack inherited through `scripts/main_v94.gd`.
- Gameplay world: `scripts/world3d_chamber_v170_realm_completion.gd`.
- Accepted correction head: `db2940898206ff0291e4f6c2af3bcff27d3f64e7`.
- r1 added authored edge/foreground framing to all five realms but its Iron boss dais was rejected as too broad/orange.
- r1.1 retained Lower Halls, Ossuary, Rift and Starless framing while tightening the Iron stage and switching it to dark plate response.
- Dedicated run `32340024229`: SUCCESS.
- Evidence artifact `9396034866` / `v170-realm-endgame-visual-completion`.
- Unsigned iPhone/iPad device build run `32340024326`: SUCCESS.

## Accepted UX lock — v1.71 r1.1
- Production stack inherited through `scripts/main_v95.gd`.
- Accepted correction head: `3a883e6ebe040bcbb4cd36e7a9377305e91f443f`.
- Pause `RETURN HOME` requires explicit abandon confirmation.
- Replay Tutorial during a run returns through Home in the same session.
- Tutorial may be deliberately skipped before the guided run starts.
- Settings use production copy and retain Privacy Policy.
- Production Store remains fail-closed/hidden until a real native StoreKit provider exists.
- Dedicated run `32350270829`: SUCCESS.
- Evidence artifact `9399620857` / `v171-ux-completion`.

## Accepted feedback / device-performance lock — v1.72 r1
- Active parent scene before v1.73: `scenes/main.tscn` -> `scripts/main_v96.gd`.
- Accepted implementation head: `04fbc6a977839acadf50759c6c56aea7cea1db81`.
- `ReleaseAudioV3` adds event priorities and per-event cooldowns so low-value chatter cannot steal boss, NOVA, claim or milestone feedback.
- Eight SFX voices remain the hard audio budget.
- Haptics are centrally strength-classified and rate-limited.
- Mobile runtime locks 60 FPS, GL Compatibility, 2x 3D MSAA and accepted pooled world budgets.
- Dedicated run `32351081073`: SUCCESS.
- Unsigned iPhone/iPad device build run `32351081135`: SUCCESS.

## Accepted run-flow presentation lock — v1.73 r1
- Branch / PR at acceptance: `agent/v1.73-run-flow-completion` / PR #106.
- Accepted scene: `scenes/main.tscn` -> `scripts/main_v97.gd`.
- Accepted implementation/evidence head: `3d9cc8c93a8c765aa89cd8603fec648665acb408`.
- Main merge commit: `3c80025824dffb9654cd21065f2acb9a1fe66398`.
- Decision/Cash-Out is fully redrawn while preserving the authoritative `CASH` and `NEXT` input rectangles.
- Game Over/Run Result is fully redrawn while preserving `RETRY` and `HOME_BTN` input rectangles.
- Floor/Realm transitions use a production presentation plate over the accepted live 3D chamber.
- Warden, Crypt Keeper, Hollow King, Null Sovereign, miniboss and endgame boss intros share one production boss-intro treatment.
- No combat balance, progression, saves, camera, actor geometry or StoreKit authority changed.
- Dedicated v1.73 gate run `32368136475`: SUCCESS.
- Evidence artifact `9406154225` / `v173-run-flow-presentation`.
- Visual review accepted Decision, Game Over, Floor Transition and Hollow King Boss Intro.
- Real captures use Xvfb + OpenGL3 / GL Compatibility because Godot `--headless` uses a dummy renderer.

## Active candidate — v1.74 Branding + Product Identity r1
- Branch: `agent/v1.74-branding-product-identity`.
- Candidate scene: `scenes/main.tscn` -> `scripts/main_v98.gd`.
- Shipping project icon changes from legacy `assets/art/wanderer.svg` to `assets/art/app_icon_v174.svg`.
- New icon is a full-bleed 1024x1024 dark-fantasy mark: gothic tower/portal, faceless hooded Wanderer, steel silhouette, gold core and ascending violet blade.
- Home receives a compact matching crest in the top safe band; navigation and input authority remain inherited.
- `assets/art/wanderer.svg` is retained as a legacy asset but is no longer the application icon.
- Dedicated contract/capture workflow: `.github/workflows/v101-brand-identity-check.yml`.
- Acceptance requires real-GL review of `home_brand_v174.png` and `app_icon_v174.png` plus full gameplay smoke.
- Current status: **visual/CI evidence pending**.
- No TestFlight trigger or release-version change.

## Preserved gameplay/art locks
- v1.67 r1.2 frontend/menu baseline.
- v1.68 r1.1 Wanderer visual completion / Hood r11.
- v1.69 r1 enemy + boss authored silhouettes.
- v1.70 r1.1 realm/endgame authored framing.
- v1.71 r1.1 UX route/modal completion.
- v1.72 r1 priority feedback + mobile runtime budgets.
- v1.73 r1 run decision/result/transition/boss-intro presentation.
- v1.65 r1.3 environment material/depth baseline beneath v1.70.
- v1.64 r1.1 character-lighting/material ordering.
- v1.63 projectile/boss combat identity.
- v1.62 UI/input foundations.
- Save, migration, backup, progression, endless/endgame and gameplay authority remain smoke-gated.

## TestFlight
- Current confirmed TestFlight build: **ONE MORE FLOOR 1.26.0 (31)**.
- Build 31 is confirmed available to test on iOS.
- v1.74 must not modify `.github/testflight-trigger` or dispatch another TestFlight upload.
- Do not create another TestFlight build automatically for completion micro-passes; bundle meaningful work first.

## Remaining completion blocks
1. **v1.74 Branding + Product Identity Completion — ACTIVE CANDIDATE.**
2. Audit any remaining visible legacy 2D/proxy surfaces after branding.
3. Real-device corrections if new completion work exposes device-specific regressions.
4. Only after device/visual acceptance: release metadata and App Store submission work.

## Continuity rules
- Update this file after each major accepted/rejected pass.
- Real captures and device acceptance decide visual completion; CI only proves technical health.
- Keep menu and gameplay Wanderer on one shared actor authority.
- Preserve accepted gameplay/input/save contracts unless a verified blocker requires a change.
- Bundle meaningful work before TestFlight; avoid build-number churn.
