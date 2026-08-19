# One More Floor — v1.64 Character Lighting State

Canonical checkpoint. **Repository truth wins over chat memory.**

- PR #95 / `agent/v1.64-character-lighting`, stacked on v1.63 / PR #93.
- **Accepted production implementation: `b4a63b0be50caa5ed08c9984c2101c059347dfe9` — r1.1.**
- Active: `main.tscn` -> `main_v85.gd` -> `world3d_chamber_v164_character_lighting.gd`.
- No TestFlight build/version jump or upload.

## Accepted result
r1.1 restores gameplay-distance midtone separation for the dark Wanderer and authored enemy materials without changing geometry, rigging, animation or gameplay authority. Existing rim/fill lights are reused. The enemy material response is applied after inherited runtime `configure_enemy()`; Skeleton remains the visual lock.

Evidence:
- v88 `32284526822`: green baseline.
- r1 `32285242478`: technically green but visually superseded.
- **r1.1 `32286008428`: fully green and visually accepted.**
- matched artifact `9377696819`.
- approximate luminance delta vs v1.63: Wanderer +25.4% / +27.5% / +48.6%; Necromancer +8.5% / +14.4%; Warden +10.7%.
- accepted r1.1 preserves v1.63 combined/boss/projectile, v1.61 danger, v1.62 UI and v1.52.1 input.

## Extra hardening
v89 now instantiates runtime Necromancer + Skeleton and validates the r1.1 final-write ordering. It changes no production values. At the final pre-documentation observation its newest Actions job remained queued behind the broad historical workflow fanout; keep it pending until it actually executes.

## iOS
Latest verified device run before documentation-only commits: **`32286619525` — fully green**. Metadata, Godot import, Xcode export/inspection, **unsigned iPhone/iPad compile**, **unsigned package** and artifacts PASS. TestFlight override/API key/release export/**upload SKIPPED**.

## Verdict / next
**v1.64 r1.1 is visually accepted and unsigned-device-build validated. Character lighting is complete unless fresh runtime/device evidence proves a concrete regression.** Record hardened v89 when it finishes, then select the next largest game-wide quality gap from fresh captures and start a new stacked milestone. Keep TestFlight off until a deliberate bundled upload decision.
