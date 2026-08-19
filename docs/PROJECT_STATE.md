# One More Floor — Project State

Canonical handoff for continued development. **Repository truth wins over chat memory.** Read the milestone state files before changing accepted art direction, gameplay authority, release policy or regression gates.

Detailed state:
- `docs/V164_CHARACTER_LIGHTING_STATE.md` — accepted v1.64 character lighting/material integration.
- `docs/V163_COMBAT_IDENTITY_STATE.md` — accepted v1.63 combat identity.
- `docs/UI_V162_STATE.md` — accepted v1.62 UI.

# Active milestone — v1.64 Character Lighting

- PR **#95 — `v1.64 character lighting milestone`**.
- Branch `agent/v1.64-character-lighting`, stacked on `agent/v1.63-combat-identity` / PR #93.
- **Accepted production implementation lock: `b4a63b0be50caa5ed08c9984c2101c059347dfe9` — v1.64 r1.1.**
- Active path: `scenes/main.tscn` -> `scripts/main_v85.gd` -> `scripts/world3d_chamber_v164_character_lighting.gd`.
- PR remains Draft/open/unmerged; last checked mergeability was true.
- No TestFlight build/version jump or upload has been performed for v1.64.

## Accepted v1.64 result
- Wanderer dark-material midtones are recovered without changing accepted geometry/rig/animation.
- Existing rim/fill lights are reused; no new decorative light family or expensive screen-space dependency.
- Goblin/Bat/Ghoul/Necromancer/Warden material readability is recovered; Skeleton remains a visual lock.
- Crucial r1.1 order fix: inherited `configure_enemy()` completes first, then v1.64 reapplies the accepted enemy material response as the final presentation-only write.
- Gameplay authority, timing, damage, targeting, hitboxes, projectile collision, input, saves and progression are untouched.

Evidence:
- v88 baseline workflow **`32284526822` — green**.
- r1 workflow **`32285242478` — technically green but visually superseded** because runtime enemy configuration overwrote the enemy material response.
- accepted r1.1 workflow **`32286008428` — fully green**.
- r1.1 matched artifact **`9377696819`**.
- approximate matched-crop luminance changes vs v1.63 parent: Wanderer +25.4% Lower Halls, +27.5% Ossuary, +48.6% Iron Bastion; Necromancer +8.5% / +14.4%; Warden +10.7%.
- visual verdict: clearer characters while dark-fantasy mood and boss dominance remain intact.

## iOS device gate
Latest verified device run before documentation-only commits: **`32286619525` — fully green**.

PASS:
- release metadata;
- Godot headless import;
- Godot -> Xcode export;
- generated Xcode project inspection;
- **unsigned iPhone/iPad device compile**;
- **unsigned device package**;
- unsigned/Xcode artifact upload.

SKIPPED by policy:
- TestFlight build override;
- App Store Connect API-key preparation;
- release archive/TestFlight export;
- **TestFlight upload**.

Therefore v1.64 r1.1 is visually accepted and unsigned-device-build validated without uploading a build.

## Extra regression hardening
`v89_character_lighting_r1_smoke_test.gd` now creates a runtime Necromancer + Skeleton and asserts that r1.1 survives inherited enemy configuration while Skeleton remains unchanged. This is an extra future-regression lock and does not alter accepted production values.

At the final pre-documentation observation, the newest hardened v89 Actions job was still queued behind the repository's broad historical workflow fanout. Record it as pending until Actions actually completes it; do not falsely report it green.

# Locked parent milestones

- **v1.63 Combat Identity:** PR #93, accepted lock `7262f42002aeeba338559190e8a87a616329ec54`; combined review `32280114378` green/accepted.
- **v1.62 UI:** PR #92, accepted lock `71c8ecec5387400af7ef1c4bd29a3f87f9323d17`.
- **v1.61 Combat Presentation:** PR #90, accepted lock `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- **v1.60 Authored 3D art:** validated lock `3e567bf409a8492a55f672b226ce9ce81c16780f`; Wanderer animation/core safe point `00a78086d47b06093c1c7554c2713067f3def132`; Hood r11 `4f82a5aeb717a088747eb31849b2d2d97340ba27`.

# Non-negotiable continuity rules

1. Preserve imported v1.55 glTF animation authority and articulated pivots.
2. Presentation work must not casually change combat authority, timing, damage, targeting, hitboxes, projectile collision, input, saves, progression or the 2D HUD.
3. Do not reintroduce rejected blockout character/environment geometry or old prototype ring/bar VFX.
4. Preserve gameplay-significant danger-tell timing/position/scale/radius semantics.
5. CI green is necessary but not sufficient; gameplay-distance/device images decide visual acceptance.
6. A visually rejected pass stays rejected even if technically green.
7. Prefer narrow top-layer subclasses and preserve accepted rollback points.
8. Update milestone state + this global handoff after every meaningful accepted/rejected pass.
9. Do not trigger TestFlight/build/version jumps for micro-passes.

# Current next step

**v1.64 r1.1 is complete from visual + unsigned-device-build perspective. Do not brighten it again by habit.**

1. Record the queued hardened v89 result when it finishes.
2. Identify the next largest game-wide quality gap from fresh runtime/device captures instead of reopening accepted geometry, VFX, UI or lighting.
3. Start the next milestone on a stacked branch/PR and immediately create its state file.
4. Keep TestFlight off until a deliberate bundled upload decision.
