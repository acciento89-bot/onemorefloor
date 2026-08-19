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
- Added `main_v76.gd` as presentation-only top layer.
- Shared cut-corner production surfaces for primary/secondary buttons, navigation tabs, panels/cards, faceted icon badges, utility buttons and section headers.
- Existing Canvas-drawn menu API, routes and pointer rectangles remain inherited.
- Home/Hero/Forge direction accepted; Talents exposed overly saturated card fills.

### r1.1 — accepted dark panel balance
Implementation: `83412d210feefa30bc0a802315aca96a3df17d85`.
Workflow: `32267108361` — fully green.
- `main_v77.gd` keeps r1 geometry and only balances shared panel fills.
- Large cards establish a dark opaque production plate first; source hue remains restrained tint/accent.
- Home, Hero, Forge and Talents 720x1280 captures accepted.
- This remains a lower rollback point.

### Secondary menu audit
Diagnostic implementation: `68ce35cd2b16093a7a10dcaa3bd02f376110d157`.
Workflow: `32267829522` — fully green.
- Added real captures for Vault, Missions, Tower Pass and Store.
- Missions: accepted; protect from unnecessary rewrite.
- Tower Pass: accepted; protect from unnecessary rewrite.
- Vault: shared foundation good, but Filter/Sort/Lock + Workshop + Item Progression controls had too much equal rectangular weight.
- Store: product cards good, but `TRY/BUY/OWNED` was naked text.

### r2 — Vault accepted, Store path rejected
Implementation: `bd2f6799609a4a8cc150637bcfb63b7dbfff44d3`.
Workflow: `32268685992` — fully green.
- `main_v78.gd` compacts Vault controls visually **inside their existing hit rectangles**.
- Filter/Sort/Lock become tighter; Workshop/Item Progression controls are visually shorter; disabled actions become quieter.
- Vault screenshot: **accepted improvement**.
- Store attempt overrode historical `_v42_store_card`; runtime Store actually draws through `main_v50.gd::_v50_store_card`.
- Store screenshot therefore stayed unchanged. CI green did not equal visual acceptance.
- Preserve the r2 Vault work, but do not treat r2 alone as the final visual lock.

### r2.1 — accepted current UI lock
Implementation: **`e6cd4b8d8d997557118aebbdf97662c5df7a1d03`**.
Dedicated workflow: **`32269453589` — fully green.**

r2.1 adds `main_v79.gd` over r2 and targets the actual release-facing Store renderer:
- overrides **`_v50_store_card`** rather than the obsolete `_v42_store_card` path;
- preserves the existing product catalog, ownership checks, debug `TRY`, release `UNAVAILABLE`, `OWNED`, monetization fail-closed behavior and full inherited product-card hitboxes;
- replaces only the naked action string with a compact forged **122×46 action chip** inside the existing product card;
- actionable chip gets a restrained accent line + chevron; owned state stays green; unavailable state stays muted;
- r2 Vault compaction is preserved unchanged.

### r2.1 manual image acceptance
`store.png` — **accepted**:
- `TRY` now sits inside a real dark forged action chip instead of floating as naked text;
- chip is visibly subordinate to the full product card, so the Store does not become a wall of competing CTAs;
- product card interaction area and monetization behavior remain unchanged.

`vault.png` — **accepted**:
- r2 compact toolbar/workshop/progression hierarchy remains intact;
- disabled controls stay readable but subordinate;
- no hitbox or crafting/progression logic changes.

`missions.png` — **accepted regression**: unchanged and still coherent.

`pass.png` — **accepted regression**: unchanged and still coherent.

Primary Home/Hero/Forge/Talents captures were also regenerated successfully under r2.1 with no accepted-foundation regression.

Therefore **v1.62 r2.1 / `e6cd4b8d...` is the current fully validated and visually accepted UI implementation baseline.**

## Current validation
Dedicated `v1.62 UI Foundation Check` run **`32269453589`** on `e6cd4b8d...` is fully green:
- Godot 4.7.1 compile/import: PASS
- r1 shared UI contract: PASS
- r1.1 dark-panel balance contract: PASS
- r2 Vault hierarchy contract: PASS
- r2.1 active `_v50_store_card` action-path contract: PASS
- Home/Hero/Forge/Talents 720x1280 captures: PASS
- Vault/Missions/Tower Pass/Store 720x1280 captures: PASS
- v1.61 r3.2 directional Combat lock: PASS
- v1.38 MenuShell/router regression: PASS
- v1.52.1 tutorial/game-over input-flow regression: PASS

## Non-negotiable UI rules
1. Preserve **`e6cd4b8d...`** as the current accepted UI rollback point.
2. Preserve r2 Vault compaction and r2.1 Store action chips unless an actual visual regression is demonstrated.
3. Do not move or resize established pointer hit rectangles merely to fit visual redesigns unless a separately scoped UX/input change is explicitly opened.
4. Do not regress to flat generic rectangles, bright full-card color slabs, cheap neon/full-ring icon language, naked text actions, or inconsistent per-screen component families.
5. Primary actions stay dominant; secondary navigation/utilities stay quieter.
6. Accent color identifies function/screen but must not become the entire surface.
7. CI green is necessary but runtime captures decide visual acceptance.
8. Keep v1.62 presentation-only on top of v1.61 unless separately scoped.
9. **Update this file after every meaningful accepted/rejected UI pass.**
10. No TestFlight/build/version jump for individual UI micro-passes.

## Current next priorities
1. Audit and capture **Settings/modal, Upgrade, Decision, Game Over/result** states on top of the accepted r2.1 baseline before changing them.
2. Apply the shared button/panel hierarchy only where those runtime states still look like the older UI language.
3. Add/verify selected, disabled and pressed-state hierarchy where the existing runtime already exposes those states; do not invent new input authority for presentation.
4. Keep all eight accepted menu screens as regression captures while expanding coverage.
5. Before any v1.62 TestFlight-ready decision, run the v1.62 iOS/device build gate deliberately and make a milestone-level upload decision.
