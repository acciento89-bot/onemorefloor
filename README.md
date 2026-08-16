# ONE MORE FLOOR

Mobile portrait roguelite by **Kamilunavo Games**.

> Climb. Loot. Risk it all. One more floor.

## Current milestone — v1.0.0-rc1

ONE MORE FLOOR now has a complete 30-floor playtest loop plus the first release-candidate systems around it.

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

The current roster includes Goblin, Bat, Skeleton, Ghoul, Necromancer, Gargoyle, Royal Sentinel and Hexer plus the three bosses. Rooms can roll Combat, Ambush, Elite and Treasure encounters with area-specific hazards.

### Combat presentation

`assets/art/motion_atlas.svg` is the active 1600 × 1200 combat motion atlas. Twelve actor rows use Idle, three Walk frames, two Attack frames, Hit and Death with left/right facing. Older external SVG and procedural renderers remain fallback layers.

### v1.0 playtest systems

- **Pause / Resume** during runs
- **Settings** from Home and Pause
- Music / SFX / Haptics toggles
- Analytics opt-in; OFF by default
- First-launch **Tutorial / Onboarding**
- Local unclean-session recovery marker
- Local bounded playtest analytics log and event counters
- Save format **v2** with additive migration
- Existing Loot / Missions / Tower Pass data preserved by meta saves
- First external **WAV playtest audio** set and looping tower theme
- Release balance profile for Floors 1–30
- Project version metadata: `1.0.0-rc1`
- Committed iOS + Android playtest export presets

The active controller is `scripts/main_v10.gd`.

### Gear and permanent progression

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

## Audio

`assets/audio/` now contains actual imported WAV resources for the RC:

- tower theme
- menu click
- attack / hit
- loot / reward
- NOVA
- boss / phase transition

The old procedural tone generator remains as a fallback implementation but is disabled by `main_v10.gd` while the release audio layer is active.

## Save safety

`user://save.cfg` now carries `system.save_version = 2`.

The migration is non-destructive. `progression.gd` loads the existing file before writing meta keys, so Loot, equipment, Soul Shards, Missions and Tower Pass sections are not erased by a Hero/Forge/Talent/progress save.

Player-facing settings live separately in `user://settings.cfg`. Local playtest telemetry uses `user://telemetry.cfg`.

## Privacy / telemetry

Analytics is disabled by default. Enabling it in Settings records playtest counters and a short recent-event list locally for this RC; no third-party analytics backend is connected yet. The same local telemetry layer marks a session open/closed so the next launch can identify an unclean previous exit.

## Validation

Godot 4.7.1 CI now validates:

1. Critical parser checks through `main_v10.gd` plus all release helper systems.
2. Headless project/editor import.
3. Main-scene boot.
4. External SVG combat assets and both combat/motion atlases.
5. Existing Loot, Vault, crafting, Missions and Tower Pass regressions.
6. Dungeon, Crypt and Forgotten Castle routing and hazards.
7. Warden, Crypt Keeper and Hollow King regressions through Floor 30.
8. External WAV resource import and release-audio wiring.
9. Save v2 migration and preservation of unrelated save sections.
10. Settings persistence.
11. Analytics opt-out and opt-in behavior.
12. Pause / Resume blocking.
13. Tutorial completion persistence.
14. Release balance profile behavior.

## Run locally

1. Install Godot 4.7.1 Standard and its export templates when preparing mobile exports.
2. Import `project.godot`.
3. Press **F5**.
4. Desktop: WASD / arrows or drag the virtual joystick with the mouse.
5. **Space** = NOVA.
6. **P / Escape** = Pause / Resume during a run.

## Mobile playtest preparation

See [`docs/playtest-release.md`](docs/playtest-release.md) for the device/export checklist.

`export_presets.cfg` now contains an **iOS Playtest** preset for iPhone + iPad and an **Android Playtest** preset, both using `de.kamilunavo.onemorefloor`. The iOS preset is configured with the existing Apple Team ID and arm64 target. A signed TestFlight build still requires the signing identity/provisioning and a macOS/Xcode export environment; Android device/release builds require the Android SDK/JDK and appropriate keystore configuration.

## Roadmap

### Playable core
- [x] Touch movement / auto attack / NOVA
- [x] Risk/reward run loop
- [x] Dungeon / Crypt / Forgotten Castle
- [x] Three authored bosses
- [x] Directional multi-frame actor motion
- [x] Playtest WAV music / SFX layer
- [ ] Final production music / SFX mix

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
- [x] iOS / Android export preset preparation
- [ ] Production analytics / crash backend
- [ ] Signed TestFlight build
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
.github/                     CI validation
scenes/                      Godot scenes
assets/art/                  SVG actors + combat/motion atlases
assets/audio/                v1.0 playtest WAV music and SFX
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
scripts/progression.gd       versioned persistent meta save
scripts/settings_manager.gd  persistent player settings
scripts/telemetry.gd         local opt-in playtest telemetry/session hook
scripts/balance_profile.gd   Floors 1–30 RC balance curve
scripts/release_audio.gd     external WAV playback layer
scripts/release_smoke_test.gd v1.0 release-system validation
scripts/smoke_test.gd        full gameplay regression validation
```
