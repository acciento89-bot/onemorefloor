# One More Floor — v1.62 UI Foundation State

Canonical checkpoint for the active UI/menu presentation milestone. **Read this file together with `docs/PROJECT_STATE.md` before continuing UI work. Repository state wins over chat memory.**

## Branch / parent
- Pull request: **#92 — `v1.62 UI foundation milestone`**.
- Active branch: `agent/v1.62-ui-foundation`.
- Base: `agent/v1.61-combat-presentation` / PR #90.
- Locked combat implementation below this branch: v1.61 r3.2 `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- Do not reopen Combat r3.2, Wanderer r11, enemy anatomy/surface baselines, combat timing/radius/damage/input, or save/progression authority while doing UI work.
- PR #92 remains **DRAFT**.
- No TestFlight upload/build bump/version jump has been authorized or performed for v1.62.

## Current accepted v1.62 implementation

### r1 — shared component foundation
Implementation: `7f5a78d299e83d11f46bef186b19cd5b3138db06`.
- Shared cut-corner production surfaces for primary/secondary buttons, navigation tabs, panels/cards, faceted icon badges, utility buttons and section headers.
- Existing Canvas-drawn menu API, routes and pointer rectangles remain inherited.

### r1.1 — accepted dark panel balance
Implementation: `83412d210feefa30bc0a802315aca96a3df17d85`.
Workflow: `32267108361` — fully green.
- Large cards establish a dark opaque production plate first; source hue remains restrained tint/accent.
- Home, Hero, Forge and Talents captures accepted.

### r2 — accepted Vault hierarchy, rejected historical Store target
Implementation: `bd2f6799609a4a8cc150637bcfb63b7dbfff44d3`.
Workflow: `32268685992` — fully green.
- Vault controls compacted visually inside existing hit rectangles; disabled Workshop/Progression actions made quieter.
- Vault visual accepted.
- Store attempt targeted obsolete `_v42_store_card`; current runtime uses `_v50_store_card`, so Store image did not change.

### r2.1 — accepted Store correction
Implementation: `e6cd4b8d8d997557118aebbdf97662c5df7a1d03`.
Workflow: `32269453589` — fully green.
- `main_v79.gd` overrides actual release-facing `_v50_store_card`.
- Product catalog, ownership checks, debug `TRY`, release `UNAVAILABLE`, `OWNED`, monetization fail-closed behavior and full card hitboxes remain inherited.
- Naked Store action text replaced by compact forged 122×46 action chip inside existing product card.
- Accepted r2 Vault compaction remains unchanged.
- Home/Hero/Forge/Talents/Vault/Missions/Tower Pass/Store accepted under this baseline.

## Runtime-state diagnostic history
Initial diagnostic implementation: `39b8bdff8a5a06abcf4258d172cf71d0a722517f`.
Corrected state-mapping diagnostic: `8274e6615deff19bd4266738877446495841ca83`.
Workflow: `32271016269` — fully green.

Important correction that must not be forgotten:
- first diagnostic used obsolete numeric state values and rendered HERO for the intended Pause capture;
- current State enum from `main_v03.gd` is `HOME, HERO, FORGE, TALENTS, VAULT, RUNNING, UPGRADE, DECISION, GAME_OVER`;
- current runtime numeric values therefore are RUNNING=5, UPGRADE=6, DECISION=7, GAME_OVER=8;
- corrected diagnostic hard-checks `_v51_screen_from_legacy()` before each capture.

Corrected manual audit:
- Settings: accepted; no rewrite needed.
- Pause: accepted; Resume dominant, Settings secondary, Return Home subordinate.
- Upgrade: accepted; authored upgrade cards already have suitable hierarchy.
- Decision: old CASH OUT / ONE MORE FLOOR full saturated slabs required polish.
- Game Over: old RETRY / HOME full saturated slabs required polish.

## r3 — accepted current UI lock: runtime Decision / Game Over CTA language
Implementation: **`71c8ecec5387400af7ef1c4bd29a3f87f9323d17`**.
Dedicated workflow: **`32272029788` — fully green.**

r3 adds `main_v80.gd` as a narrow presentation-only top layer over r2.1.

### Exact r3 scope
- `draw_decision()` calls the inherited renderer first, then redraws only the visible surfaces inside exact inherited `CASH` and `NEXT` rectangles.
- `draw_game_over()` calls the inherited renderer first, then redraws only the visible surfaces inside exact inherited `RETRY` and `HOME_BTN` rectangles.
- **No `pointer()` override exists in r3.** Input ownership remains inherited.
- Cash-out, continue, retry, home, run state, economy and progression logic are unchanged.
- `ONE MORE FLOOR` remains the stronger primary CTA; `CASH OUT` is clear but quieter.
- `RETRY` remains the stronger primary CTA; `HOME` is a quieter secondary exit.
- Primary runtime CTAs use shared forged `_v76_primary_plate` language rather than saturated full-color slabs.
- Secondary runtime CTAs use shared dark `_v76_surface` language.

### r3 manual image acceptance
`decision.png` — **accepted**:
- old solid green/gold mobile slabs are gone;
- CASH OUT is a dark green-accented secondary plate;
- ONE MORE FLOOR is a dark gold/brass primary plate with stronger hierarchy and restrained directional cue;
- central loot/risk composition remains unchanged and readable.

`game_over.png` — **accepted**:
- old solid gold RETRY and purple HOME slabs are gone;
- RETRY is the clear forged primary action;
- HOME stays visibly available but subordinate;
- death card, run summary and setback information remain untouched.

`settings.png` — **accepted regression**: unchanged in the established production language.

`pause.png` — **accepted regression**: unchanged; Resume/Settings/Return Home hierarchy remains correct.

`upgrade.png` — **accepted regression**: unchanged authored choice-card hierarchy.

Primary and secondary eight-screen capture sets were regenerated successfully under r3 with no accepted menu regressions.

Therefore **v1.62 r3 / `71c8ecec...` is the current fully validated and visually accepted UI implementation baseline.**

## UI action-state matrix — accepted diagnostic lock
Diagnostic commit: **`64fec7921f9f898442f90900ce3265c034dbce79`**.
Dedicated workflow: **`32272995156` — fully green.**

The state matrix changes no production UI/game code. It captures the real Store renderer with three runtime-visible action families:
- `store_try.png` — **accepted**: actionable debug `TRY` chips retain gold accent + chevron and read clearly clickable without dominating the product card.
- `store_owned.png` — **accepted**: Premium Pass / Starter Cache / Remove Ads show restrained green `OWNED` chips; consumables remain actionable `TRY`; ownership is immediately legible without filling whole cards green.
- `store_unavailable.png` — **accepted**: fail-closed release presentation is clearly muted; `UNAVAILABLE` chips and Bonus Cache are visibly disabled while product information remains readable.

State coverage already present in the accepted r3 capture set:
- Settings contains enabled and disabled/toggle states.
- Vault contains active toolbar controls plus disabled Workshop/Item Progression states.
- Tower Pass contains locked premium/reward hierarchy.
- Decision/Game Over cover strong primary versus quieter secondary CTA hierarchy.

There is **no persistent generic pressed-state in the current shared Canvas button API**. Existing pointer routing acts on press and transitions/actions immediately. Do not invent new input ownership merely to create a cosmetic pressed-state during this presentation milestone.

## Current validation
Dedicated `v1.62 UI Foundation Check` run `32272029788` on `71c8ecec...` is fully green:
- Godot 4.7.1 compile/import: PASS
- r1 shared UI contract: PASS
- r1.1 dark-panel balance contract: PASS
- r2 Vault hierarchy contract: PASS
- r2.1 active Store action-path contract: PASS
- r3 runtime CTA / no-input-override contract: PASS
- Home/Hero/Forge/Talents captures: PASS
- Vault/Missions/Tower Pass/Store captures: PASS
- Settings/Pause/Upgrade/Decision/Game Over captures: PASS
- v1.61 r3.2 directional Combat lock: PASS
- v1.38 MenuShell/router regression: PASS
- v1.52.1 tutorial/game-over input-flow regression: PASS

Dedicated `v1.62 UI State Matrix Check` run `32272995156` on diagnostic commit `64fec792...` is fully green:
- current v1.62 project compile/import: PASS
- accepted r3 contract: PASS
- TRY / OWNED / UNAVAILABLE captures: PASS

## iOS/device milestone gate
`ONE MORE FLOOR iOS Playtest` run **`32272995220`** on the r3 + state-diagnostic stack is fully green:
- release metadata verification: PASS
- Godot 4.7.1 import: PASS
- Godot Xcode export: PASS
- generated Xcode project inspection: PASS
- unsigned iPhone/iPad device build: PASS
- unsigned device app packaging/artifact upload: PASS
- TestFlight build override: SKIPPED
- App Store Connect key preparation: SKIPPED
- release archive/TestFlight export: SKIPPED
- TestFlight upload: **SKIPPED**

Therefore **v1.62 r3 is a TestFlight-ready candidate from UI + unsigned-device-build perspective, but no upload is authorized or performed.** PR #92 remains Draft until a deliberate milestone/release decision.

## Non-negotiable UI rules
1. Preserve **`71c8ecec...`** as the current accepted production UI implementation rollback point.
2. `64fec792...` is diagnostic state-matrix coverage only; do not confuse it with a new production visual layer.
3. Preserve r2 Vault compaction, r2.1 Store action chips and r3 Decision/Game Over CTA hierarchy unless a real visual regression is demonstrated.
4. Preserve Settings, Pause and Upgrade from unnecessary rewrites.
5. Do not move or resize established pointer hit rectangles during presentation-only UI work.
6. Do not regress to flat generic rectangles, bright full-card slabs, cheap neon/full-ring icon language, naked text actions, or inconsistent per-screen component families.
7. Primary actions stay dominant; secondary navigation/utilities stay quieter.
8. CI green is necessary but runtime captures decide visual acceptance.
9. Keep v1.62 presentation-only on top of v1.61 unless separately scoped.
10. **Update this file after every meaningful accepted/rejected UI pass.**
11. No TestFlight/build/version jump from individual UI micro-passes.

## Current next priorities
1. **Treat the v1.62 UI foundation as visually complete at the current r3 baseline unless a new device capture demonstrates a regression.**
2. Preserve all 13 accepted main/runtime screens plus the three Store action-state captures as regression references.
3. Return development focus to the next largest game-wide presentation problem rather than adding UI decoration quantity. Candidate: projectile/trail identity or boss-specific combat presentation on top of the accepted v1.61/v1.62 stack.
4. If a TestFlight build is desired, make that decision deliberately as a bundled milestone; do not upload automatically from this checkpoint.
