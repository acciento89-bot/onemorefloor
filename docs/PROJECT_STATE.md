# One More Floor — Project State

Canonical handoff for continued development. **Read this file before changing art direction, gameplay authority, release policy or regression gates. Repository truth wins over chat memory.**

For detailed milestone history also read:
- `docs/V164_CHARACTER_LIGHTING_STATE.md` for the active/accepted v1.64 character-lighting milestone.
- `docs/V163_COMBAT_IDENTITY_STATE.md` for projectile/boss baselines, rejected boss r2 and accepted v1.63 r2.1.
- `docs/UI_V162_STATE.md` for the accepted v1.62 menu/UI milestone.

# Active development line — v1.64 Character Lighting

- Pull request: **#95 — `v1.64 character lighting milestone`**.
- Branch: `agent/v1.64-character-lighting`.
- Base: `agent/v1.63-combat-identity` / PR #93.
- **Current accepted production implementation lock: `b4a63b0be50caa5ed08c9984c2101c059347dfe9` (v1.64 r1.1).**
- Active integration remains `scenes/main.tscn` -> `scripts/main_v85.gd` -> `scripts/world3d_chamber_v164_character_lighting.gd`.
- PR #95 remains **Draft**, open, unmerged and mergeable at the last checked checkpoint.
- No TestFlight upload, App Store build-number bump or version jump has been performed for v1.64.

## v1.64 status
**Visually accepted at r1.1 and unsigned iPhone/iPad device-build validated.** Do not add another generic brightness pass without new runtime/device evidence.

Accepted r1.1 behavior:
1. Wanderer dark cloth/cape/steel/leather/void midtones are recovered at gameplay distance while keeping the established dark-fantasy palette.
2. Existing Wanderer rim/fill lights are reused with restrained range/energy changes; no new decorative light family or expensive screen-space dependency was added.
3. Goblin/Bat/Ghoul/Necromancer/Warden authored body materials receive controlled midtone recovery; Skeleton remains an explicit visual lock.
4. Enemy Quality `configure_enemy()` is allowed to finish first; v1.64 then reapplies the accepted enemy material response as the final presentation-only runtime write.
5. Geometry, rig pivots, imported animation, combat timing, damage, targeting, hitboxes, projectile collision, input, saves and progression remain inherited and unchanged.

## v1.64 visual/CI evidence
- Frozen v88 baseline workflow: **`32284526822` — fully green**.
- Initial r1 matched workflow: **`32285242478` — fully green but visually incomplete for enemies** because inherited runtime enemy configuration overwrote the one-time r1 material write.
- Accepted r1.1 matched workflow: **`32286008428` — fully green**.
- Accepted r1.1 artifact: **`9377696819`**, matched v1.63-before/v1.64-after frames for Lower Halls, Ossuary and Iron Bastion/Warden.
- Approximate matched-crop luminance improvement vs accepted v1.63 parent: Wanderer +25.4% Lower Halls, +27.5% Ossuary, +48.6% Iron Bastion; Necromancer +8.5% Lower Halls / +14.4% Ossuary; Warden +10.7% Iron Bastion.
- Accepted visual verdict: characters are materially more readable while realm mood, Warden dominance and dark-fantasy contrast remain intact.

## Current device/release gate
Latest verified device workflow before the final documentation-only checkpoint:
- `ONE MORE FLOOR iOS Playtest` run **`32286619525` — fully green**.
- Release metadata: PASS.
- Godot headless import: PASS.
- Godot -> Xcode export: PASS.
- Generated Xcode project inspection: PASS.
- **Unsigned iPhone/iPad device compile: PASS.**
- **Unsigned device package: PASS.**
- Xcode/unsigned iOS artifacts: PASS.
- TestFlight build override: SKIPPED.
- App Store Connect API-key preparation: SKIPPED.
- Release archive/TestFlight export: SKIPPED.
- TestFlight upload: **SKIPPED**.

Therefore v1.64 r1.1 is device-build validated without performing a TestFlight upload.

## Post-acceptance hardening
- `scripts/v89_character_lighting_r1_smoke_test.gd` now explicitly creates a runtime Necromancer + Skeleton and checks that the r1.1 enemy material response survives inherited `configure_enemy()` while Skeleton remains unchanged.
- This is an additional regression lock on top of the already-green accepted r1.1 production review; it does not alter accepted production values.
- At the final pre-documentation observation, the newest GitHub runner for this hardened v89 test was still queued behind the repository's broad historical workflow fanout. Do not falsely report it as passed until Actions completes it.

# Parent milestone locks

## v1.63 Combat Identity — accepted
- PR #93 — `v1.63 combat identity milestone`.
- Branch: `agent/v1.63-combat-identity`.
- Accepted production implementation: **`7262f42002aeeba338559190e8a87a616329ec54`**.
- Visually complete; do not add more combat VFX merely for decoration quantity.

Accepted stack:
1. v1.61 r3.2 directional danger language.
2. v1.62 r3 production UI.
3. v1.63 r1 projectile/trail identity.
4. v1.63 r2 technical v1.46 boss-frame cleanup underneath.
5. v1.63 r2.1 active v1.49 BossDominance correction.

Accepted combined review workflow: **`32280114378` — green.**
Accepted captures: `combined_fan_exchange.png`, `combined_slam_loot.png`, `combined_mob_pressure.png`.

## v1.62 UI — accepted
- PR #92 — `v1.62 UI foundation milestone`.
- Branch: `agent/v1.62-ui-foundation`.
- Accepted production code lock: **`71c8ecec5387400af7ef1c4bd29a3f87f9323d17`**.
- Home, Hero, Forge, Talents, Vault, Missions, Tower Pass, Store, Settings, Pause, Upgrade, Decision and Game Over accepted.
- Store TRY/OWNED/UNAVAILABLE state matrix accepted.
- Exact state and validation history: `docs/UI_V162_STATE.md`.

## v1.61 Combat Presentation — accepted
- PR #90 — `v1.61 combat presentation milestone`.
- Branch: `agent/v1.61-combat-presentation`.
- Accepted production implementation: **`bb367aad35338dd6d32fbdf7d4de4208efef2ad0`**.

Accepted visual language:
- narrow blade-ribbon attack instead of filled yellow fan;
- segmented arcane skill waves instead of full torus;
- compact impact starbursts;
- directional movement streaks;
- compact death dissolve;
- broken spawn/death signatures;
- focused attacks -> forward arc + spear/aim marker;
- charge/dash/dive/lunge -> lane rails + forward arrow;
- blink/phase/teleport -> broken phase brackets;
- slam/crown -> radial perimeter teeth;
- summon -> inward ritual markers.

All gameplay-significant trigger/window/position/radius semantics remain inherited.

## v1.60 Authored 3D art — locked parent
- PR #82 — `v1.60 authored environment milestone`.
- Branch: `agent/v1.60-meta-environments`.
- Validated v1.60 implementation lock: **`3e567bf409a8492a55f672b226ce9ce81c16780f`**.
- Wanderer animation/core safe point: `00a78086d47b06093c1c7554c2713067f3def132`.
- Wanderer Hood r11 correction: `4f82a5aeb717a088747eb31849b2d2d97340ba27`.

# Non-negotiable continuity rules

1. Preserve imported v1.55 glTF animation authority and articulated pivots.
2. Presentation work must not casually change combat authority, timing, damage, targeting, hitboxes, projectile collision, input, saves, progression or the 2D HUD.
3. Do not reintroduce old rounded Wanderer geometry, generic armor-mannequin/blockout bodies, flat single-color plastic or retired environment blockouts.
4. Do not reintroduce prototype full/neon rings, debug discs/seams, generic glowing projectile balls, straight debug-bar trails or oversized circular boss decoration.
5. Primary danger telegraphs are gameplay-significant. Their warning window, intended position, scale/radius semantics and attack behavior must not be reduced or changed by presentation work.
6. CI green is necessary but not sufficient. Runtime/gameplay-distance images decide visual acceptance.
7. A visually rejected pass stays rejected even if every test is green.
8. Preserve accepted passes as rollback points; prefer narrow top-layer subclasses over rewriting validated history.
9. After every meaningful accepted/rejected pass, update the relevant milestone state file and this global handoff when the active milestone/lock changes.
10. Do not trigger TestFlight/build/version jumps for micro-passes. Upload only as a deliberate bundled milestone decision.

# Locked art direction

## Environment
- Authored OBJ environments cover Home, Hero, Forge, Talents, Vault, Missions, Tower Pass and Store.
- Floors 1–50 use authored production composition rather than the old generic grid.
- Realm identities: Lower Halls, Ossuary, Iron Bastion, Rift Descent, Starless Spire.
- GL Compatibility/mobile-friendly surface-depth shading is part of the target.
- Orthographic combat camera remains lower/stable for stronger isometric depth.

## Wanderer
- Accepted geometry stack remains Wanderer r8.1 + Hood r11.
- Narrow human central mass, asymmetric shoulders, slim human limbs, overlapping shoulder armor and layered footwear.
- Restrained ArcaneCore/belt/eyes.
- Dark cloth / cool steel / restrained brass / arcane accents.
- v1.64 r1.1 improves material/light integration only; preserve cape, blade, imported animation and pivots.

## Enemies
- Preserve accepted authored Goblin, Bat, Skeleton, Ghoul, Necromancer and Warden silhouettes.
- Keep retained weapons/eyes/runes and archetype readability.
- Do not restore old blockout cores or rejected excessive surface/camouflage breakup.
- Preserve the v1.64 r1.1 runtime material-order fix; do not move the enemy readability write back before inherited `configure_enemy()`.

# Required regression gates for future work

Preserve at minimum:
- v1.64 r1.1 character-lighting/material contract and matched gameplay-distance readability.
- v1.63 r2.1 boss-dominance contract.
- v1.63 r1 projectile-identity / v1.51-authority contract.
- v1.63 combined gameplay-distance review when changing combat presentation.
- v1.61 r3.2 directional danger-language gate.
- v1.62 r3 UI regression.
- v1.52.1 input-flow regression.
- Wanderer/enemy authored-model regressions when character presentation is touched.
- unsigned iPhone/iPad device build before any release/upload decision.

# Current next step

**v1.64 r1.1 is visually accepted and unsigned-device-build validated. Do not keep brightening it by habit.**

1. Record the queued post-acceptance runtime-order smoke hardening result when Actions completes it.
2. Use new gameplay/device captures to identify the next largest game-wide quality gap rather than reopening accepted character geometry, combat VFX, UI or lighting.
3. Create the next stacked milestone branch/PR before production implementation.
4. Save a new milestone-specific state file immediately.
5. Keep TestFlight off until a deliberate bundled upload decision is made.
