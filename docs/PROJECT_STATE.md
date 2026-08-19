# One More Floor — Project State

Canonical handoff. **Repository truth wins over chat memory.**

## Active / accepted — v1.65 Environment Surface & Depth
- PR #100 / `agent/v1.65-environment-depth`, stacked on accepted v1.64 / PR #95.
- **Accepted production implementation: `a5951b244166bf824e403eda037a4568194348c6` — v1.65 r1.3.**
- Final visual/test checkpoint: `c1078573877a4e204405a41f781e92201ac20b85`.
- Active path: `main.tscn` -> `main_v86.gd` -> `world3d_chamber_v165_environment_depth_r13.gd`.
- Detailed history: `docs/V165_ENVIRONMENT_DEPTH_STATE.md`.

v1.65 r1.3 improves the five combat realms through mobile-safe procedural material breakup plus restrained presentation-only surface/depth dressing. Camera, collision/navigation, combat authority, character geometry/animation, UI, input, saves and progression remain unchanged.

Accepted visual direction:
- Lower Halls: restrained soot/wear and compact chips instead of regular bright strips.
- Ossuary: darker dust/patina plus small bone fragments; no large pale applied polygons.
- Iron Bastion: restrained rust/patina/debris while Warden dominance stays intact.
- Rift Descent: stronger dark-purple material depth with compact accents; no neon/debug fracture bars.
- Starless Spire: cold-blue material breakup with compact inlay chips; no long blue bars.

### v1.65 decision history
- r1: technically green, visually rejected for long brass/purple/blue debug-bar language.
- r1.1: technically green, visually too subtle.
- r1.2: materially stronger, but visually rejected for large low-poly-looking wear patches in Ossuary/Iron.
- **r1.3: visually accepted.**

Final r1.3 visual gate:
- workflow **`32292817771` — fully green**;
- artifact **`9380157967`**;
- all ten matched before/after captures asserted at 720x1280;
- v1.65 readiness/camera/no-collision contract PASS;
- hardened v1.64 runtime material-order regression PASS.

Final r1.3 unsigned iOS gate:
- workflow **`32292817944` — fully green**;
- metadata/import/Xcode export/project inspection PASS;
- **unsigned iPhone/iPad compile + package PASS**;
- artifacts PASS;
- TestFlight override/API key/release archive/export/**upload SKIPPED**.

## Locked parents
- v1.64 Character Lighting r1.1: `b4a63b0be50caa5ed08c9984c2101c059347dfe9`; accepted matched run `32286008428`.
- v1.63 Combat Identity: `7262f42002aeeba338559190e8a87a616329ec54`; combined review `32280114378` accepted.
- v1.62 UI: `71c8ecec5387400af7ef1c4bd29a3f87f9323d17`.
- v1.61 Combat Presentation: `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- v1.60 Authored 3D: `3e567bf409a8492a55f672b226ce9ce81c16780f`; Wanderer safe point `00a78086d47b06093c1c7554c2713067f3def132`; Hood r11 `4f82a5aeb717a088747eb31849b2d2d97340ba27`.

## Continuity rules
Preserve accepted animation/pivots, gameplay authority, danger semantics, geometry/VFX/UI/lighting/environment locks and rollback points. Gameplay/device images decide visual acceptance; technically green but visually rejected passes stay rejected. Presentation details must not acquire collision/navigation authority. No accidental repeated TestFlight uploads.

## Current release action
**v1.65 r1.3 is complete from visual + unsigned-device-build perspective.** The user explicitly requested exactly one TestFlight upload after this development block.

Release sequence:
1. create a fresh release bundle from accepted `agent/v1.65-environment-depth` to stale `main`;
2. merge only the accepted bundle;
3. verify current stored TestFlight build trigger/build number immediately before dispatch;
4. trigger **exactly one** TestFlight upload;
5. track the actual workflow through App Store Connect upload success; if the attempt fails, report it before any retry.

See `docs/V165_ENVIRONMENT_DEPTH_STATE.md`, `docs/V164_CHARACTER_LIGHTING_STATE.md`, `docs/V163_COMBAT_IDENTITY_STATE.md`, `docs/UI_V162_STATE.md`.
