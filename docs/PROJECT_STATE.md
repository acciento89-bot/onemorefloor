# One More Floor — Project State

Canonical handoff. **Repository truth wins over chat memory.**

Detailed milestone state:
- `docs/V164_CHARACTER_LIGHTING_STATE.md` — accepted v1.64 character lighting/material integration.
- `docs/V163_COMBAT_IDENTITY_STATE.md` — accepted v1.63 combat identity.
- `docs/UI_V162_STATE.md` — accepted v1.62 UI.

# Active milestone — v1.64 Character Lighting
- PR #95 / `agent/v1.64-character-lighting`, stacked on v1.63 / PR #93.
- **Accepted production implementation: `b4a63b0be50caa5ed08c9984c2101c059347dfe9` — r1.1.**
- Active path: `main.tscn` -> `main_v85.gd` -> `world3d_chamber_v164_character_lighting.gd`.
- PR remains Draft/open/unmerged; last checked mergeability true.
- No TestFlight build/version jump or upload.

## Accepted v1.64 result
- Wanderer dark-material midtones recovered without geometry/rig/animation changes.
- Existing rim/fill lights reused; no extra decorative light family.
- Goblin/Bat/Ghoul/Necromancer/Warden readability recovered; Skeleton locked.
- r1.1 applies the v1.64 enemy material response after inherited runtime `configure_enemy()`.
- Combat/gameplay/input/save/progression authority unchanged.

Evidence:
- v88 baseline `32284526822` green.
- r1 `32285242478` technically green but visually superseded.
- **r1.1 review `32286008428` fully green and visually accepted.**
- matched artifact `9377696819`.
- approximate crop luminance delta vs v1.63: Wanderer +25.4% / +27.5% / +48.6%; Necromancer +8.5% / +14.4%; Warden +10.7%.

## iOS device gate
Latest verified device run before documentation-only commits: **`32286619525` — fully green**.

PASS: metadata, Godot import, Xcode export/inspection, **unsigned iPhone/iPad compile**, **unsigned device package**, artifacts.

SKIPPED: TestFlight override, App Store Connect key, release archive/TestFlight export, **TestFlight upload**.

## Extra hardening
The v89 smoke now instantiates runtime Necromancer + Skeleton and validates the r1.1 final-write ordering. This changes no production values. At the final pre-documentation observation its newest Actions job was still queued behind the broad historical workflow fanout; record its result when it actually completes.

# Locked parents
- v1.63 Combat Identity: PR #93, lock `7262f42002aeeba338559190e8a87a616329ec54`, combined review `32280114378` accepted.
- v1.62 UI: PR #92, lock `71c8ecec5387400af7ef1c4bd29a3f87f9323d17`.
- v1.61 Combat Presentation: PR #90, lock `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- v1.60 Authored 3D: lock `3e567bf409a8492a55f672b226ce9ce81c16780f`; Wanderer safe point `00a78086d47b06093c1c7554c2713067f3def132`; Hood r11 `4f82a5aeb717a088747eb31849b2d2d97340ba27`.

# Continuity rules
1. Preserve imported v1.55 glTF animation authority/pivots.
2. Presentation work must not casually alter gameplay authority, timing, damage, targeting, hitboxes, projectile collision, input, saves, progression or HUD.
3. Do not reintroduce rejected blockout geometry or prototype ring/bar VFX.
4. Preserve gameplay-significant danger-tell semantics.
5. CI green is necessary but gameplay/device images decide visual acceptance.
6. Visually rejected passes remain rejected.
7. Prefer narrow top layers and preserve rollback points.
8. Update milestone/global state after meaningful passes.
9. No TestFlight/build/version jumps for micro-passes.

# Next
**v1.64 r1.1 is complete from visual + unsigned-device-build perspective.** Record the queued hardened v89 result when it finishes, then identify the next largest game-wide quality gap from fresh captures and create the next stacked milestone branch/PR. Keep TestFlight off until a deliberate bundled upload decision.
