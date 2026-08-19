# One More Floor — Project State

Canonical handoff. **Repository truth wins over chat memory.**

- Active milestone: v1.64 Character Lighting, PR #95, branch `agent/v1.64-character-lighting`, stacked on v1.63 / PR #93.
- **Accepted production implementation: `b4a63b0be50caa5ed08c9984c2101c059347dfe9` — r1.1.**
- Active path: `main.tscn` -> `main_v85.gd` -> `world3d_chamber_v164_character_lighting.gd`.
- No TestFlight build/version jump or upload.

## v1.64 accepted
Wanderer and dark enemy materials gain controlled gameplay-distance midtone separation without geometry, rig, animation or gameplay-authority changes. Existing rim/fill lights are reused. r1.1 applies the enemy material response after inherited runtime `configure_enemy()`, fixing the r1 overwrite while Skeleton remains a visual lock.

Evidence:
- v88 baseline `32284526822`: green.
- r1 `32285242478`: technically green but visually superseded.
- **r1.1 `32286008428`: fully green + visually accepted.**
- matched artifact `9377696819`.
- approximate crop luminance vs v1.63: Wanderer +25.4% / +27.5% / +48.6%; Necromancer +8.5% / +14.4%; Warden +10.7%.

## iOS
Latest verified device run before documentation-only commits: **`32286619525` — fully green**. Metadata, Godot import, Xcode export/inspection, **unsigned iPhone/iPad compile**, **unsigned package** and artifacts PASS. TestFlight override/API key/release export/**upload SKIPPED**.

## Extra hardening
The v89 smoke now instantiates runtime Necromancer + Skeleton and checks the r1.1 final-write ordering. This is a future-regression lock only. At the final pre-documentation observation its newest Actions job remained queued behind broad historical workflow fanout; do not mark it green until it actually runs.

## Locked parents
- v1.63 lock `7262f42002aeeba338559190e8a87a616329ec54`, combined review `32280114378` accepted.
- v1.62 UI lock `71c8ecec5387400af7ef1c4bd29a3f87f9323d17`.
- v1.61 Combat Presentation lock `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- v1.60 Authored 3D lock `3e567bf409a8492a55f672b226ce9ce81c16780f`; Wanderer safe point `00a78086d47b06093c1c7554c2713067f3def132`; Hood r11 `4f82a5aeb717a088747eb31849b2d2d97340ba27`.

## Continuity
Preserve imported animation/pivots, gameplay authority, danger-tell semantics, accepted geometry/VFX/UI/lighting, rollback points and device gates. Gameplay/device images decide visual acceptance; technically green but visually rejected passes stay rejected. No TestFlight/version jumps for micro-passes.

## Next
**v1.64 r1.1 is complete from visual + unsigned-device-build perspective.** Record hardened v89 when it finishes, then select the next largest game-wide quality gap from fresh runtime/device captures and open a new stacked milestone branch/PR. Keep TestFlight off until a deliberate bundled upload decision.
