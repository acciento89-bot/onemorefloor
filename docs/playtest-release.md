# ONE MORE FLOOR — v1.0.0-rc1 Playtest Release

This milestone turns the first 30 floors into a device-playtest candidate. It is not yet a signed App Store / Play Store release.

## Build identity

- Game version: `1.0.0-rc1`
- Engine: Godot 4.7.1
- Orientation: portrait
- Reference viewport: 720 × 1280
- Application identifier: `de.kamilunavo.onemorefloor`
- Apple Team ID: `TKG684N5GL`
- Target families: iPhone + iPad + Android phones/tablets
- Mobile presets: `iOS Playtest` and `Android Playtest` in `export_presets.cfg`

## Release systems included

- Pause / Resume during runs
- Home and in-run Settings
- Music, SFX and Haptics toggles
- Analytics opt-in, disabled by default
- First-launch onboarding / tutorial
- Save format version 2 with non-destructive migration
- Local unclean-session recovery marker
- Local opt-in playtest event counters / recent-event log
- Playtest WAV theme and combat/menu SFX
- Release balance curve for Floors 1–30
- Existing Dungeon, Crypt and Forgotten Castle content

## Save migration

`user://save.cfg` now stores `system.save_version = 2`.

The v1.0 migration is deliberately additive. Existing progress, loot, equipment, Soul Shards, Missions and Tower Pass sections are preserved. Meta progression no longer rewrites the file from an empty `ConfigFile`; it loads the existing save first and updates only its own keys.

## Privacy / telemetry

Analytics starts OFF. The player can opt in from Settings.

The RC currently stores playtest counters and a bounded recent-event list locally in `user://telemetry.cfg`. There is no third-party analytics upload in this milestone. The same file records whether a session was left open; the next launch can surface a recovery notice after an unclean exit.

A production analytics/crash provider can later consume the same event boundaries without changing the gameplay loop.

## Audio

`assets/audio/` contains the first external WAV playtest audio set:

- `tower_theme.wav`
- `menu_click.wav`
- `attack.wav`
- `loot.wav`
- `nova.wav`
- `boss.wav`

These replace the procedural tone generator during v1.0 gameplay. The old generator remains in the codebase as a fallback layer, but is disabled by the active release controller.

## Device export preparation

### iPhone / iPad

The committed `iOS Playtest` preset already contains:

1. Bundle Identifier `de.kamilunavo.onemorefloor`.
2. Apple App Store Team ID `TKG684N5GL`.
3. iPhone & iPad targeted device family.
4. arm64 architecture.
5. User-facing version `1.0.0`.

A signed device/TestFlight build still requires Godot 4.7.1 export templates plus a macOS machine with Xcode and the appropriate signing identity/provisioning profile. Signing certificates/profiles are intentionally not stored in the repository.

### Android

The committed `Android Playtest` preset already contains:

- package identifier `de.kamilunavo.onemorefloor`
- version code 1 / version name 1.0.0
- Gradle build enabled
- VIBRATE permission for handheld feedback
- arm64-v8a and armeabi-v7a targets

Before APK/AAB export, configure Godot with OpenJDK 17 and the Android SDK. Store release keystore credentials outside the repository.

## Playtest checklist

- [x] Godot critical script parser checks
- [x] Headless project import
- [x] Main scene boot
- [x] Full gameplay regression smoke test through Floor 30 systems
- [x] v1.0 release smoke test
- [x] External WAV resource import
- [x] Save-section preservation test
- [x] Settings persistence test
- [x] Analytics opt-out / opt-in test
- [x] Pause / Resume state test
- [x] Tutorial completion persistence test
- [x] Release balance profile test
- [x] iOS/Android export identity and preset preparation
- [ ] Physical iPhone touch / haptics / audio pass
- [ ] Physical iPad layout pass
- [ ] Signed TestFlight archive
- [ ] Physical Android pass
- [ ] Store icons / screenshots / final production audio

## Device test focus

The first real-device pass should focus on touch movement dead-zone, NOVA reachability, pause-button reachability, haptic intensity, speaker balance, room pacing, thermal performance, safe-area overlap and readability on both iPhone and iPad aspect ratios.
