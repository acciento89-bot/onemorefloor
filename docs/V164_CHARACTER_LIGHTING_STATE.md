# One More Floor — v1.64 Character Lighting State

Canonical checkpoint. **Repository truth wins over chat memory.**

- PR #95 / `agent/v1.64-character-lighting`, stacked on v1.63 / PR #93.
- **Accepted production implementation: `b4a63b0be50caa5ed08c9984c2101c059347dfe9` — r1.1.**
- Active: `main.tscn` -> `main_v85.gd` -> `world3d_chamber_v164_character_lighting.gd`.
- No TestFlight build/version jump or upload.

## Accepted result
v1.64 r1.1 recovers gameplay-distance midtone separation for Wanderer and dark authored enemies while preserving geometry, rigging, animation and gameplay authority. Existing rim/fill lights are reused. The r1.1 runtime-order fix reapplies enemy material response after inherited `configure_enemy()`; Skeleton remains locked.

Evidence:
- v88 baseline `32284526822`: green.
- r1 `32285242478`: technically green but visually superseded.
- **r1.1 `32286008428`: fully green and visually accepted.**
- matched artifact `9377696819`.
- approximate crop luminance delta vs v1.63: Wanderer +25.4% / +27.5% / +48.6%; Necromancer +8.5% / +14.4%; Warden +10.7%.
- accepted review preserves v1.63 combined/boss/projectile, v1.61 danger, v1.62 UI and v1.52.1 input.

## Extra hardening
The v89 smoke now instantiates runtime Necromancer + Skeleton and checks the r1.1 final-write ordering. It changes no production values. At the final pre-documentation observation its newest Actions job remained queued behind broad historical workflow fanout; keep it pending until it actually executes.

## iOS
Latest verified device run before documentation-only commits: **`32286619525` — fully green**. Metadata, Godot import, Xcode export/inspection, **unsigned iPhone/iPad compile**, **unsigned package** and artifacts PASS. TestFlight override/API key/release export/**upload SKIPPED**.

## Verdict / next
**v1.64 r1.1 is visually accepted and unsigned-device-build validated. Character lighting is complete unless fresh runtime/device evidence proves a concrete regression.** Record hardened v89 when it finishes, then select the next largest game-wide quality gap from fresh captures and start it as a new stacked milestone. Keep TestFlight off until a deliberate bundled upload decision.
