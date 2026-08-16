# ONE MORE FLOOR

Mobile portrait roguelite by **Kamilunavo Games**.

> Climb. Loot. Risk it all. One more floor.

## Current milestone — v1.1.0-rc1

ONE MORE FLOOR is now in real-device TestFlight iteration. The 30-floor gameplay loop is intact; v1.1 focuses on the first major **visual, responsive-layout and audio identity pass** based on hands-on iPhone feedback.

### Core loop

1. Enter a generated floor room.
2. Move, dodge and auto-attack.
3. Clear enemies and collect coins / gear.
4. Choose one of three run upgrades.
5. Cash out or climb one more floor.
6. Spend permanent resources, equip/craft gear, complete Missions and progress the Tower Pass.

### Areas and bosses

- **Dungeon** — Floors 1–10 — The Warden
- **Crypt** — Floors 11–20 — The Crypt Keeper
- **Forgotten Castle** — Floors 21–30 — The Hollow King

The roster includes Goblin, Bat, Skeleton, Ghoul, Necromancer, Gargoyle, Royal Sentinel and Hexer plus the three bosses. Rooms can roll Combat, Ambush, Elite and Treasure encounters with area-specific hazards.

## v1.1 visual & device overhaul

The active controller is now `scripts/main_v11.gd`.

### Responsive mobile presentation

- `canvas_items + expand` portrait layout for tall phones and tablets.
- The 720 × 1280 gameplay core is positioned inside the expanded viewport while extra screen space receives an atmospheric game backdrop instead of plain letterboxing.
- iOS / Android safe-area data is used when positioning the core presentation.
- Touch coordinates are translated back into stable gameplay design coordinates, preserving existing joystick and button hit targets.
- iOS status bar and home-indicator presentation is configured for an immersive portrait playtest.

### New Home presentation

- Rebuilt dark-fantasy Home backdrop with portal/moon, fog, distant silhouettes and particles.
- New multi-tower keep, Wanderer presentation, stat cards and icon-based meta tabs.
- Cleaner hierarchy around **ENTER THE TOWER**, Missions and Tower Pass.
- All inherited prototype labels such as `v0.4 LOOT + MISSIONS`, `v0.6 VISUAL PRODUCTION`, `v0.8 ANIMATION + VAULT`, `v0.9 FORGOTTEN CASTLE` and `v1.0 RC1` are removed from the player-facing Home path.

### Combat presentation

- Area-specific floor material for Dungeon, Crypt, Forgotten Castle and Deep Tower.
- New stone slabs, atmospheric rings, runes, cracks, banners and area accents.
- Reworked pillars, flames and Treasure-room chest presentation.
- Cleaner glass-style top HUD, coin counter and HP strip.
- Refined joystick and NOVA button with charge treatment.
- Actor shadows / glows layered around the existing directional motion atlas.
- Brighter projectile, enemy-shot and coin readability.

### Tower Pass

- Rebuilt reward-track presentation.
- Dedicated level/progress panel and next-reward preview.
- Clearer locked / unlocked / claimable cards.
- No internal development-version text in the player-facing screen.

## Adaptive audio

v1.1 separates the music identity instead of replaying one track everywhere.

Music contexts:

- **Menu** — existing tower theme
- **Dungeon** — low pulse / plucked exploration loop
- **Crypt** — drone / bell / spectral layer
- **Forgotten Castle** — darker marching motif
- **Boss** — faster combat pulse

`release_audio.gd` crossfades between contexts and continues to respect Music/SFX settings. Dungeon, Crypt, Castle and Boss music are currently original procedural PCM playtest loops generated in-engine; they are intentionally a playtest music layer, not final mastered production tracks.

Existing imported SFX remain available for menu click, attack/hit, loot/reward, NOVA and boss/phase events.

## Combat assets

`assets/art/motion_atlas.svg` remains the active 1600 × 1200 combat motion atlas. Twelve actor rows use Idle, three Walk frames, two Attack frames, Hit and Death with left/right facing. Older external SVG and procedural renderers remain fallback layers.

The v1.1 visual pass improves scene composition and readability around these assets; final hand-authored character/environment artwork can replace the same rendering hooks later without changing the gameplay systems.

## Release/playtest systems

- Pause / Resume during runs
- Settings from Home and Pause
- Music / SFX / Haptics toggles
- Analytics opt-in; OFF by default
- First-launch Tutorial / Onboarding
- Local unclean-session recovery marker
- Local bounded playtest analytics log and event counters
- Save format **v2** with additive migration
- Existing Loot / Missions / Tower Pass data preserved by meta saves
- Release balance profile for Floors 1–30
- iOS + Android export presets
- Current project metadata: `1.1.0-rc1`
- iOS playtest version: `1.1.0`, build `2`

## Gear and permanent progression

- Hero / Forge / Vitality / Precision / Fortune progression
- Weapon / Armor / Relic slots
- Common → Legendary rarity
- Traits and Ember / Crypt / Warden sets
- Soul Shard dismantling
- Targeted Rare+ crafting
- Lock / Unlock
- All / Weapon / Armor / Relic filters
- Rarity / Level / Score sorting
- Selected-vs-equipped comparison
- Daily / weekly Missions
- 20-level free Tower Pass

## Save safety

`user://save.cfg` carries `system.save_version = 2`.

The migration is non-destructive. `progression.gd` loads the existing file before writing meta keys, so Loot, equipment, Soul Shards, Missions and Tower Pass sections are not erased by a Hero/Forge/Talent/progress save.

Player-facing settings live separately in `user://settings.cfg`. Local playtest telemetry uses `user://telemetry.cfg`.

## Privacy / telemetry

Analytics is disabled by default. Enabling it in Settings records playtest counters and a short recent-event list locally; no third-party analytics backend is connected yet. The same local telemetry layer marks a session open/closed so the next launch can identify an unclean previous exit.

## Validation

Godot 4.7.1 CI validates:

1. Critical parser checks through `main_v11.gd` plus release helper systems.
2. Headless project/editor import.
3. Main-scene boot.
4. Full gameplay regression through Floor 30.
5. Loot, Vault, crafting, Missions and Tower Pass regressions.
6. Dungeon, Crypt and Forgotten Castle routing and hazards.
7. Warden, Crypt Keeper and Hollow King regressions.
8. WAV/SFX release-audio wiring.
9. Save v2 migration and preservation of unrelated save sections.
10. Settings persistence and analytics opt-in behavior.
11. Pause / Resume and tutorial persistence.
12. v1.1 `expand` viewport configuration and touch-coordinate translation.
13. Separate Menu / Dungeon / Crypt / Castle / Boss music contexts.
14. Regression guard against legacy visible development-version labels.
15. macOS Godot → Xcode export and unsigned ARM64 `iphoneos` device compilation on visual branches.
16. Signed archive and TestFlight upload only from `main` when App Store Connect secrets are present.

## Run locally

1. Install Godot 4.7.1 Standard and its export templates when preparing mobile exports.
2. Import `project.godot`.
3. Press **F5**.
4. Desktop: WASD / arrows or drag the virtual joystick with the mouse.
5. **Space** = NOVA.
6. **P / Escape** = Pause / Resume during a run.

## Mobile playtest

The GitHub Actions iOS pipeline can produce the Xcode project and an unsigned ARM64 iPhone/iPad app for branch validation. On `main`, configured App Store Connect API credentials enable automatic signing, archive and TestFlight upload.

`export_presets.cfg` contains **iOS Playtest** and **Android Playtest** presets using `de.kamilunavo.onemorefloor`.

## Roadmap

### Playable core
- [x] Touch movement / auto attack / NOVA
- [x] Risk/reward run loop
- [x] Dungeon / Crypt / Forgotten Castle
- [x] Three authored bosses
- [x] Directional multi-frame actor motion
- [x] Real iPhone TestFlight playtest
- [x] First responsive/edge-to-edge mobile pass
- [x] Separate biome/boss playtest music contexts
- [ ] Final production character/environment artwork
- [ ] Final mastered music / SFX mix

### Meta progression
- [x] Hero / Forge / Talents
- [x] Persistent equipment Vault
- [x] Traits / sets
- [x] Dismantling / Soul Shards / targeted crafting
- [x] Advanced Vault management
- [x] Missions / free Tower Pass

### Release candidate systems
- [x] Pause / Settings
- [x] First-launch tutorial
- [x] Save versioning / migration
- [x] Local opt-in playtest analytics
- [x] Local crash-session recovery hook
- [x] 30-floor release balance profile
- [x] iOS / Android export presets
- [x] Signed TestFlight pipeline
- [ ] Production analytics / crash backend
- [ ] Android device build
- [ ] Cloud save
- [ ] Leaderboards
- [ ] Rewarded ads / IAP

### Future content
- [ ] Floor 31+ area
- [ ] More heroes
- [ ] Upgrade synergies
- [ ] Room events
- [ ] Additional bosses and seasonal content

## Repository layout

```text
.github/                     CI + iOS/TestFlight validation
scenes/                      Godot scenes
assets/art/                  SVG actors + combat/motion atlases
assets/audio/                imported playtest WAV resources
docs/art-direction.md        visual production rules
docs/playtest-release.md     RC/device export checklist
export_presets.cfg           iOS + Android playtest export presets
scripts/main_v03.gd          combat/meta controller
scripts/main_v04.gd          Loot/Missions/Tower Pass/audio feedback
scripts/main_v05.gd          Crypt/rooms/traits
scripts/main_v06.gd          visual baseline / Crypt Keeper
scripts/main_v07.gd          external asset renderer / crafting
scripts/main_v08.gd          combat atlas / advanced Vault
scripts/main_v09.gd          Forgotten Castle / Hollow King / motion
scripts/main_v10.gd          v1.0 pause/settings/tutorial/release layer
scripts/main_v11.gd          v1.1 responsive visual/audio presentation
scripts/progression.gd       versioned persistent meta save
scripts/settings_manager.gd  persistent player settings
scripts/telemetry.gd         local opt-in playtest telemetry/session hook
scripts/balance_profile.gd   Floors 1–30 RC balance curve
scripts/release_audio.gd     adaptive music + imported SFX layer
scripts/release_smoke_test.gd v1.0 release-system validation
scripts/v11_smoke_test.gd    v1.1 visual/audio regression validation
scripts/smoke_test.gd        full gameplay regression validation
```
