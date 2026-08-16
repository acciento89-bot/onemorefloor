# ONE MORE FLOOR — v1.0.0-rc1 Playtest Release

This milestone turns the first 30 floors into a device-playtest candidate. It is not yet a signed App Store / Play Store release.

## Build identity

- Game version: `1.0.0-rc1`
- Engine: Godot 4.7.1
- Orientation: portrait
- Reference viewport: 720 × 1280
- Recommended mobile application identifier: `de.kamilunavo.onemorefloor`
- Target families: iPhone + iPad + Android phones/tablets

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

Before a signed device/TestFlight build, configure the Godot iOS export preset with:

1. Bundle Identifier (`de.kamilunavo.onemorefloor` is the current recommendation).
2. The real Apple App Store Team ID.
3. iPhone & iPad as the targeted device family.
4. Godot 4.7.1 export templates.
5. A macOS machine with Xcode and the appropriate signing identity/provisioning.

The repository intentionally does not commit a fake Team ID or signing certificate.

### Android

Before APK/AAB export, configure Godot with OpenJDK 17 and the Android SDK, then create the Android export preset with the package identifier and VIBRATE permission for handheld feedback. Store release keystore credentials outside the repository.

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
- [ ] Physical iPhone touch / haptics / audio pass
- [ ] Physical iPad layout pass
- [ ] Signed TestFlight archive
- [ ] Physical Android pass
- [ ] Store icons / screenshots / final production audio

## Device test focus

The first real-device pass should focus on touch movement dead-zone, NOVA reachability, pause-button reachability, haptic intensity, speaker balance, room pacing, thermal performance, safe-area overlap and readability on both iPhone and iPad aspect ratios.
