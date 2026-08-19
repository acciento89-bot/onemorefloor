# One More Floor — v1.62 UI Foundation State

Canonical checkpoint for the active UI/menu presentation milestone. **Read this file together with `docs/PROJECT_STATE.md` before continuing UI work. Repository state wins over chat memory.**

## Branch / parent
- Pull request: **#92 — `v1.62 UI foundation milestone`**.
- Active branch: `agent/v1.62-ui-foundation`.
- Base: `agent/v1.61-combat-presentation` / PR #90.
- Locked combat implementation below this branch: v1.61 r3.2 `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- Do not reopen Combat r3.2, Wanderer r11, enemy anatomy/surface baselines, combat timing/radius/damage/input, or save/progression authority while doing UI work.
- PR #92 remains **DRAFT**. No TestFlight upload/build bump/version jump from UI micro-passes.

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

### r2.1 — accepted current UI lock
Implementation: **`e6cd4b8d8d997557118aebbdf97662c5df7a1d03`**.
Workflow: **`32269453589` — fully green.**
- `main_v79.gd` overrides actual release-facing `_v50_store_card`.
- Product catalog, ownership checks, debug `TRY`, release `UNAVAILABLE`, `OWNED`, monetization fail-closed behavior and full card hitboxes remain inherited.
- Naked Store action text replaced by compact forged **122×46 action chip** inside existing product card.
- Accepted r2 Vault compaction remains unchanged.

### r2.1 accepted visual set
- Home: accepted.
- Hero: accepted.
- Forge: accepted.
- Talents: accepted.
- Vault: accepted.
- Missions: accepted.
- Tower Pass: accepted.
- Store: accepted after active-path r2.1 correction.

Therefore **v1.62 r2.1 / `e6cd4b8d...` is the current fully validated and visually accepted UI implementation baseline.**

## Runtime-state UI audit — checkpoint before r3
Initial diagnostic implementation: `39b8bdff8a5a06abcf4258d172cf71d0a722517f`.
Corrected state-mapping diagnostic: **`8274e6615deff19bd4266738877446495841ca83`**.
Workflow: **`32271016269` — fully green.**

Important diagnostic correction:
- first capture used the old pre-meta numeric state values, so `pause.png` incorrectly rendered HERO;
- current State enum is defined in `main_v03.gd` as `HOME, HERO, FORGE, TALENTS, VAULT, RUNNING, UPGRADE, DECISION, GAME_OVER`;
- `8274e661...` corrected RUNNING/UPGRADE/DECISION/GAME_OVER values and hard-checks `_v51_screen_from_legacy()` before each runtime capture;
- do not reuse the old numeric mapping.

### Manual runtime-state audit
`settings.png` — **accepted foundation; no r3 rewrite planned**:
- settings controls already inherit the dark shared material language;
- enabled/disabled states are visually readable;
- Back is a clear secondary action;
- minor title/subtitle spacing is not a large enough quality problem to justify reopening the screen in r3.

`pause.png` — **accepted; no r3 rewrite planned**:
- Resume is dominant, Settings secondary, Return Home subordinate;
- dark modal plate reads coherently over the 3D combat scene;
- combat HUD remains visibly de-emphasized behind the pause overlay.

`upgrade.png` — **accepted; no r3 rewrite planned**:
- upgrade rarity cards already use strong hierarchy and authored icon language;
- three choices are readable without becoming flat bright full-card slabs;
- no need to force the general menu button treatment onto upgrade cards.

`decision.png` — **r3 polish required**:
- central loot/risk composition and hierarchy are good;
- the large `CASH OUT` and `ONE MORE FLOOR` buttons are still strong full green/gold slabs and read like older mobile CTA tiles;
- r3 should preserve exact `CASH` and `NEXT` hit rectangles and all cash-out/continue logic, but redraw only their visible action surfaces using the accepted forged dark CTA language;
- `ONE MORE FLOOR` should remain the visually dominant primary choice; `CASH OUT` remains clear but secondary.

`game_over.png` — **r3 polish required**:
- title, death card, run summary and setback information are readable;
- large `RETRY` and `HOME` buttons remain saturated full gold/purple slabs and visually break the newer menu language;
- r3 should preserve exact `RETRY` and `HOME_BTN` hit rectangles and input flow while replacing only visible action surfaces;
- `RETRY` should be the primary CTA; `HOME` quieter secondary.

## Current validation
Accepted r2.1 run `32269453589`:
- compile/import: PASS
- r1/r1.1/r2/r2.1 contracts: PASS
- all eight accepted menu captures: PASS
- v1.61 r3.2 Combat: PASS
- MenuShell/router: PASS
- v1.52.1 input: PASS

Corrected runtime diagnostic run **`32271016269`** on `8274e661...`:
- compile/import: PASS
- r1/r1.1/r2/r2.1 contracts: PASS
- all eight accepted menu regressions: PASS
- Settings/Pause/Upgrade/Decision/Game Over diagnostic captures: PASS
- v1.61 r3.2 Combat: PASS
- MenuShell/router: PASS
- v1.52.1 input: PASS

## Non-negotiable UI rules
1. Preserve **`e6cd4b8d...`** as the accepted implementation rollback until r3 is visually accepted.
2. Preserve r2 Vault compaction and r2.1 Store action chips.
3. Preserve Settings, Pause and Upgrade from unnecessary r3 rewrites.
4. Do not move/resize established pointer hit rectangles during presentation-only UI work.
5. Do not regress to flat generic rectangles, bright full-card slabs, cheap neon/full-ring icon language, naked text actions, or inconsistent per-screen component families.
6. Primary actions stay dominant; secondary navigation/utilities stay quieter.
7. CI green is necessary but runtime captures decide visual acceptance.
8. Keep v1.62 presentation-only on top of v1.61 unless separately scoped.
9. **Update this file after every meaningful accepted/rejected UI pass.**
10. No TestFlight/build/version jump for individual UI micro-passes.

## Current next priorities
1. **v1.62 r3: polish Decision `CASH OUT` / `ONE MORE FLOOR` and Game Over `RETRY` / `HOME` visible CTA surfaces only.**
2. Preserve exact `CASH`, `NEXT`, `RETRY`, `HOME_BTN` hitboxes and existing pointer/input behavior.
3. Re-render runtime-state set plus all eight accepted menu regressions; visually accept/reject Decision and Game Over.
4. After r3, audit actual selected/pressed/disabled states where runtime exposes them rather than inventing new input authority.
5. Before any v1.62 TestFlight-ready decision, run the v1.62 iOS/device build gate deliberately and make a milestone-level upload decision.
