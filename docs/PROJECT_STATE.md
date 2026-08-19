# One More Floor — Project State

Canonical handoff. **Repository truth wins over chat memory.**

## Active — v1.64 Character Lighting
- PR #95 / `agent/v1.64-character-lighting`, stacked on v1.63 / PR #93.
- **Accepted production implementation: `b4a63b0be50caa5ed08c9984c2101c059347dfe9` — r1.1.**
- Active: `main.tscn` -> `main_v85.gd` -> `world3d_chamber_v164_character_lighting.gd`.
- No TestFlight build/version jump or upload.

r1.1 restores gameplay-distance midtone separation for dark Wanderer/enemy materials while preserving geometry, rigging, animation and gameplay authority. Existing rim/fill lights are reused. Enemy material response is applied after inherited runtime `configure_enemy()`; Skeleton stays locked.

Evidence: v88 `32284526822` green baseline; r1 `32285242478` technically green but visually superseded; **r1.1 `32286008428` fully green and visually accepted**; matched artifact `9377696819`; approximate luminance delta vs v1.63: Wanderer +25.4% / +27.5% / +48.6%, Necromancer +8.5% / +14.4%, Warden +10.7%.

Latest verified iOS device run before documentation-only commits: **`32286619525` — fully green**. Metadata, Godot import, Xcode export/inspection, **unsigned iPhone/iPad compile**, **unsigned package** and artifacts PASS; TestFlight override/API key/release export/**upload SKIPPED**.

Extra hardening: v89 now validates runtime Necromancer + Skeleton final-write ordering without changing production values. At the final pre-documentation observation its newest Actions job remained queued behind broad historical workflow fanout; keep it pending until it actually executes.

Locked parents: v1.63 `7262f42002aeeba338559190e8a87a616329ec54`; v1.62 UI `71c8ecec5387400af7ef1c4bd29a3f87f9323d17`; v1.61 `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`; v1.60 `3e567bf409a8492a55f672b226ce9ce81c16780f`, Wanderer safe point `00a78086d47b06093c1c7554c2713067f3def132`, Hood r11 `4f82a5aeb717a088747eb31849b2d2d97340ba27`.

Preserve imported animation/pivots, gameplay authority, danger semantics, accepted geometry/VFX/UI/lighting and rollback points. Gameplay/device images decide acceptance. Visually rejected passes remain rejected. No TestFlight/version jumps for micro-passes.

**v1.64 r1.1 is complete from visual + unsigned-device-build perspective.** Record hardened v89 when it finishes, then select the next largest quality gap from fresh runtime/device captures and create the next stacked milestone. Keep TestFlight off until a deliberate bundled upload decision.

See `docs/V164_CHARACTER_LIGHTING_STATE.md`, `docs/V163_COMBAT_IDENTITY_STATE.md`, `docs/UI_V162_STATE.md`.
