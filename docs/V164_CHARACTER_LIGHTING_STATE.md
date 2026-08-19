# One More Floor — v1.64 Character Lighting State

Canonical checkpoint for v1.64 character-lighting/material integration. **Repository truth wins over chat memory.** Read together with `docs/PROJECT_STATE.md`, `docs/V163_COMBAT_IDENTITY_STATE.md` and `docs/UI_V162_STATE.md`.

## Milestone
- PR #95 / `agent/v1.64-character-lighting`, stacked on v1.63 / PR #93.
- **Accepted production implementation: `b4a63b0be50caa5ed08c9984c2101c059347dfe9` — r1.1.**
- Active path: `main.tscn` -> `main_v85.gd` -> `world3d_chamber_v164_character_lighting.gd`.
- No TestFlight build/version jump or upload for this milestone.

## Problem and solution
Accepted v1.63 gameplay frames showed Wanderer and some dark enemy materials losing midtone separation. Geometry, rigging and VFX were not the cause.

v1.64 r1.1:
- recovers dark Wanderer cloth/cape/steel/leather/void midtones;
- reuses existing rim/fill lights with restrained changes;
- recovers Goblin/Bat/Ghoul/Necromancer/Warden material readability while locking Skeleton;
- lets inherited runtime `configure_enemy()` finish before the v1.64 enemy material response is reapplied as the final presentation-only write;
- changes no geometry, animation, gameplay, timing, hitbox, collision, input, save or progression authority.

## Evidence
- v88 frozen baseline `32284526822`: green.
- r1 `32285242478`: technically green but visually superseded; enemy material response was overwritten at runtime.
- **r1.1 `32286008428`: fully green and visually accepted.**
- matched artifact: **`9377696819`**.

Approximate matched-crop mean-luminance delta vs v1.63 parent:
- Wanderer: +25.4% Lower Halls, +27.5% Ossuary, +48.6% Iron Bastion;
- Necromancer: +8.5% Lower Halls, +14.4% Ossuary;
- Warden: +10.7% Iron Bastion.

Visual verdict: substantially clearer characters without flattening realm mood or boss dominance.

Regression coverage in accepted r1.1 review:
- v1.64 compile/import: PASS;
- character-lighting smoke: PASS;
- v1.63 combined combat: PASS;
- v1.63 boss r2.1: PASS;
- v1.63 projectile r1: PASS;
- v1.61 danger language: PASS;
- matched before/after render: PASS;
- v1.62 UI: PASS;
- v1.52.1 input: PASS.

## Extra runtime-order hardening
`v89_character_lighting_r1_smoke_test.gd` was strengthened after acceptance to instantiate runtime Necromancer + Skeleton and assert that the r1.1 final-write ordering remains intact. This changes no accepted production values.

At the final pre-documentation observation, the newest hardened v89 job remained **queued** behind the broad historical Actions fanout. Keep it recorded as pending until it actually runs.

## iOS device gate
Latest verified device workflow before documentation-only commits: **`32286619525` — fully green**.

PASS: release metadata, Godot import, Xcode export, generated-project inspection, **unsigned iPhone/iPad device compile**, **unsigned package**, unsigned/Xcode artifacts.

SKIPPED: TestFlight build override, App Store Connect API key, release archive/TestFlight export, **TestFlight upload**.

## Verdict / next
**v1.64 r1.1 is visually accepted and unsigned-device-build validated. Character lighting is complete unless new device/runtime evidence proves a concrete regression.**

Next:
1. Record the queued hardened v89 result when it finishes.
2. Select the next largest game-wide quality gap from fresh runtime/device captures.
3. Create the next stacked milestone branch/PR and state file before production work.
4. Keep TestFlight off until a deliberate bundled upload decision.
