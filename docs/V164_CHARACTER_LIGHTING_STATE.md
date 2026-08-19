# One More Floor — v1.64 Character Lighting State

Canonical checkpoint. **Repository truth wins over chat memory.**

- PR #95 / `agent/v1.64-character-lighting`, stacked on v1.63 / PR #93.
- **Accepted production implementation: `b4a63b0be50caa5ed08c9984c2101c059347dfe9` — r1.1.**
- Active: `main.tscn` -> `main_v85.gd` -> `world3d_chamber_v164_character_lighting.gd`.
- No TestFlight build/version jump or upload.

r1.1 restores gameplay-distance midtone separation for dark Wanderer/enemy materials while preserving geometry, rigging, animation and gameplay authority. Existing rim/fill lights are reused. Enemy material response is applied after inherited runtime `configure_enemy()`; Skeleton stays locked.

Evidence: v88 `32284526822` green; r1 `32285242478` technically green but visually superseded; **r1.1 `32286008428` fully green and visually accepted**; artifact `9377696819`; approximate luminance delta vs v1.63: Wanderer +25.4% / +27.5% / +48.6%, Necromancer +8.5% / +14.4%, Warden +10.7%.

Extra hardening: v89 now validates runtime Necromancer + Skeleton final-write ordering without changing production values. The latest observed current-head v89 run `32288004312` is still queued behind broad historical workflow fanout; keep it pending until it actually executes.

Latest verified code-equivalent iOS run before documentation-only commits: **`32286619525` — fully green**. Metadata, Godot import, Xcode export/inspection, **unsigned iPhone/iPad compile**, **unsigned package** and artifacts PASS; TestFlight override/API key/release export/**upload SKIPPED**. Documentation-only pushes may enqueue newer iOS runs but do not alter the validated production integration.

**Verdict: v1.64 r1.1 is visually accepted and unsigned-device-build validated.** Character lighting is complete unless fresh runtime/device evidence proves a concrete regression. Next: record hardened v89 when it finishes, then select the next largest quality gap from fresh captures and start a new stacked milestone. Keep TestFlight off until a deliberate bundled upload decision.
