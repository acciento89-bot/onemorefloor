# One More Floor — v1.64 Character Lighting State

Canonical v1.64 character-lighting/material-integration checkpoint. **Repository truth wins over chat memory.**

## Milestone
- PR #95 / `agent/v1.64-character-lighting`, stacked on v1.63 / PR #93.
- **Accepted production implementation: `b4a63b0be50caa5ed08c9984c2101c059347dfe9` — r1.1.**
- Active path: `main.tscn` -> `main_v85.gd` -> `world3d_chamber_v164_character_lighting.gd`.
- No TestFlight build/version jump or upload.

## Accepted solution
v1.63 gameplay captures showed dark Wanderer and enemy materials losing midtone separation. v1.64 r1.1 fixes material/light integration without changing geometry, rigging, animation, combat authority, input, saves or progression.

- Wanderer dark materials gain controlled midtones.
- Existing rim/fill lights are reused; no new decorative light family.
- Goblin/Bat/Ghoul/Necromancer/Warden gain controlled readability; Skeleton remains locked.
- Crucial r1.1 fix: inherited `configure_enemy()` completes first, then v1.64 reapplies the accepted enemy material response as the final presentation-only write.

## Evidence
- v88 baseline **`32284526822` — green**.
- r1 **`32285242478` — technically green but visually superseded** because runtime enemy configuration overwrote enemy material response.
- **r1.1 `32286008428` — fully green and visually accepted.**
- matched artifact **`9377696819`**.

Approximate crop luminance delta vs v1.63 parent:
- Wanderer +25.4% Lower Halls, +27.5% Ossuary, +48.6% Iron Bastion;
- Necromancer +8.5% / +14.4%;
- Warden +10.7%.

Accepted r1.1 regressions: compile/import, v1.63 combined combat, boss r2.1, projectile r1, v1.61 danger language, matched renders, v1.62 UI and v1.52.1 input all PASS.

## Extra hardening
`v89_character_lighting_r1_smoke_test.gd` now instantiates runtime Necromancer + Skeleton and checks that r1.1 survives inherited configuration while Skeleton stays unchanged. This is an extra future-regression lock, not a production-value change.

At the final pre-documentation observation, its newest Actions job remained **queued** behind the repository's broad historical workflow fanout. Record it pending until it actually executes.

## iOS device gate
Latest verified device run before documentation-only commits: **`32286619525` — fully green**.

PASS: release metadata, Godot import, Xcode export/inspection, **unsigned iPhone/iPad compile**, **unsigned package**, unsigned/Xcode artifacts.

SKIPPED: TestFlight build override, App Store Connect API key, release archive/TestFlight export, **TestFlight upload**.

## Verdict / next
**v1.64 r1.1 is visually accepted and unsigned-device-build validated. Character lighting is complete unless new runtime/device evidence proves a concrete regression.**

Next: record hardened v89 when it finishes, then select the next largest game-wide quality gap from fresh captures and create a new stacked milestone branch/PR. Keep TestFlight off until a deliberate bundled upload decision.
