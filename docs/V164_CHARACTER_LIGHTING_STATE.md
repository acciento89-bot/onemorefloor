# One More Floor — v1.64 Character Lighting State

Canonical checkpoint. **Repository truth wins over chat memory.**

## Milestone
- PR #95 / `agent/v1.64-character-lighting`, stacked on v1.63 / PR #93.
- **Accepted production implementation: `b4a63b0be50caa5ed08c9984c2101c059347dfe9` — r1.1.**
- Active: `main.tscn` -> `main_v85.gd` -> `world3d_chamber_v164_character_lighting.gd`.
- No TestFlight build/version jump or upload.

## Result
v1.64 r1.1 fixes gameplay-distance character material/light integration while preserving geometry, rigging, animation and gameplay authority.

- Wanderer dark materials gain controlled midtones.
- Existing rim/fill lights reused; no new decorative light family.
- Goblin/Bat/Ghoul/Necromancer/Warden readability recovered; Skeleton locked.
- v1.64 enemy material response is applied after inherited runtime `configure_enemy()` as the final presentation-only write.

## Evidence
- v88 baseline `32284526822`: green.
- r1 `32285242478`: technically green but visually superseded because enemy response was overwritten at runtime.
- **r1.1 `32286008428`: fully green and visually accepted.**
- matched artifact `9377696819`.
- approximate luminance deltas vs v1.63: Wanderer +25.4% / +27.5% / +48.6%; Necromancer +8.5% / +14.4%; Warden +10.7%.
- compile/import, v1.63 combined/boss/projectile, v1.61 danger, matched render, v1.62 UI and v1.52.1 input all PASS in the accepted r1.1 review.

## Extra hardening
The v89 smoke now instantiates runtime Necromancer + Skeleton and checks the r1.1 final-write ordering. It changes no production values. At the final pre-documentation observation, its newest Actions job remained queued behind the broad historical workflow fanout; record it pending until it actually executes.

## iOS gate
Latest verified device run before documentation-only commits: **`32286619525` — fully green**.

PASS: metadata, Godot import, Xcode export/inspection, **unsigned iPhone/iPad compile**, **unsigned package**, artifacts.

SKIPPED: TestFlight override, App Store Connect key, release archive/TestFlight export, **TestFlight upload**.

## Verdict
**v1.64 r1.1 is visually accepted and unsigned-device-build validated. Character lighting is complete unless fresh runtime/device evidence proves a concrete regression.**

Next: record the hardened v89 result when it finishes, select the next largest game-wide quality gap from fresh captures, create the next stacked milestone branch/PR, and keep TestFlight off until a deliberate bundled upload decision.
