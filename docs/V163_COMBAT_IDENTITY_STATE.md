# One More Floor — v1.63 Combat Identity State

Canonical checkpoint for the active v1.63 combat-identity milestone. Read this together with `docs/PROJECT_STATE.md` and `docs/UI_V162_STATE.md` before continuing. Repository truth wins over chat memory.

## Branch / parent
- Active branch: `agent/v1.63-combat-identity`.
- Parent branch: `agent/v1.62-ui-foundation` / PR #92.
- Starting parent head: `1d05a87b347bcdcfda5b21d40b74b476cadab42f`.
- Accepted production UI rollback: v1.62 r3 `71c8ecec5387400af7ef1c4bd29a3f87f9323d17`.
- Accepted combat presentation rollback below that: v1.61 r3.2 `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.

## Protected systems
1. Do not reopen or modify accepted v1.62 UI presentation, routes or hitboxes.
2. Preserve v1.61 combat authority: timing, damage, targeting, hit radii, warning windows, projectile collision/input authority and save/progression behavior.
3. Preserve Wanderer r11, accepted enemy anatomy/surface work, imported animation authority and pivots.
4. VFX work must remain presentation-only unless a separate gameplay milestone is explicitly opened.
5. No TestFlight/build/version jump from individual v1.63 passes.
6. CI green is necessary but runtime captures decide visual acceptance.
7. Update this file after every meaningful accepted/rejected pass.

## v1.63 goal
Improve the next largest game-wide presentation weakness after the accepted v1.62 UI milestone:
- first: projectile / trail identity at gameplay distance;
- second: boss-specific combat presentation if projectile/trail work is accepted;
- avoid generic neon balls, full rings, flat debug streaks, or excessive particle clutter;
- preserve readable archetype identity and mobile performance.

## Starting validation baseline
- v1.62 UI Foundation run `32272029788`: green.
- v1.62 UI State Matrix run `32272995156`: green.
- iOS unsigned iPhone/iPad device run `32272995220`: green; TestFlight upload skipped.
- Parent PR #92 remained Draft / open / mergeable at branch creation.

## Immediate next steps
1. Trace the current active player-projectile, enemy-projectile and trail render paths; do not assume historical renderers are still active.
2. Capture current projectile/trail gameplay-distance baseline before modifying visuals.
3. Implement the smallest presentation-only identity pass on the verified active renderer.
4. Preserve v1.61 r3.2 combat and v1.62 UI regressions.
5. Record accepted/rejected image verdicts and exact commits here.
