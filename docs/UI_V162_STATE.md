# One More Floor — v1.62 UI Foundation State

Canonical checkpoint for the active UI/menu presentation milestone. **Read this file together with `docs/PROJECT_STATE.md` before continuing UI work. Repository state wins over chat memory.**

## Branch / parent
- Pull request: **#92 — `v1.62 UI foundation milestone`**.
- Active branch: `agent/v1.62-ui-foundation`.
- Base: `agent/v1.61-combat-presentation` / PR #90.
- Locked combat implementation below this branch: v1.61 r3.2 `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- Do not reopen Combat r3.2, Wanderer r11, enemy anatomy/surface baselines, combat timing/radius/damage/input, or save/progression authority while doing UI work.
- PR #92 remains **DRAFT**. No TestFlight upload/build bump/version jump from UI micro-passes.

## Current accepted implementation

### v1.62 r1 — shared component foundation
Implementation: `7f5a78d299e83d11f46bef186b19cd5b3138db06`.

Introduced a presentation-only top layer (`main_v76.gd`) over v1.61 with shared reusable drawing primitives for:
1. Primary action button.
2. Secondary/action button.
3. Home/navigation tab family.
4. Shared panel/card surface.
5. Faceted icon badge replacing the older circular medallion/ring emphasis.
6. Utility button family.
7. Section/header treatment.

The existing Canvas-drawn menu API was overridden at shared component level rather than moving individual hitboxes. Existing routes, pointer rectangles, progression actions and menu/world ownership remain inherited.

Visual review of r1:
- Home: accepted direction; clearer forged primary PLAY plate and quieter secondary navigation.
- Hero: accepted direction; dark framed stat card and secondary actions integrate with the authored 3D stage.
- Forge: accepted direction; shared frame/button family reads consistently with Home/Hero.
- Talents: **not accepted as final r1 balance** because large green/purple/gold card fills still read too much like solid mobile tiles.

### v1.62 r1.1 — accepted panel-balance lock
Implementation: **`83412d210feefa30bc0a802315aca96a3df17d85`**.
Dedicated workflow: **`32267108361` — fully green.**

r1.1 is a narrow subclass (`main_v77.gd`) over r1. It does not rewrite the component foundation. It changes only shared panel fill balance:
- large cards now establish an opaque dark production plate first;
- source hue survives as restrained material tint rather than a full saturated slab;
- low-alpha source cards keep accent identity mainly through edge, icon and subtle inner tint;
- r1 component geometry, button hierarchy and hit areas remain unchanged.

### r1.1 manual image acceptance
`home.png` — **accepted**:
- PLAY remains the single dominant CTA;
- Missions/Tower Pass and Hero/Forge/Talents/Vault use one coherent darker navigation family;
- Store/Settings remain visually subordinate utilities;
- faceted icon badges and cut-corner surfaces fit the authored 3D environment better than the older circular/full-glow language.

`hero.png` — **accepted**:
- Wanderer remains the focal point;
- stat card reads as one dark material panel instead of a generic flat rectangle;
- TRAIN/BACK share the same component language without overpowering the character stage.

`forge.png` — **accepted**:
- Forge card and action plate match the Home/Hero material language;
- the authored forge environment remains visually dominant.

`talents.png` — **accepted as r1.1 foundation**:
- Vitality/Precision/Fortune cards are materially darker than r1;
- green/purple/gold remain identity accents rather than full bright mobile tiles;
- individual screen composition may still receive later screen-specific polish, but the shared component foundation is accepted.

Therefore **r1.1 / `83412d21...` is the current accepted v1.62 UI implementation baseline.**

## Secondary menu audit — checkpoint before r2
Diagnostic implementation: `68ce35cd2b16093a7a10dcaa3bd02f376110d157`.
Dedicated workflow: **`32267829522` — fully green.**

The diagnostic pass added `v78_ui_secondary_capture.gd` and real 720x1280 captures for Vault, Missions, Tower Pass and Store without changing accepted r1.1 visuals.

### Manual audit
`vault.png` — **foundation accepted, screen-specific r2 polish required**:
- shared dark frames and faceted badges work;
- inventory header and selected-item panel fit r1.1;
- the dense Filter/Sort/Lock + Workshop + Item Progression controls still read as too many equal-weight rectangular switches, especially in the empty/disabled state;
- r2 should visually compact these controls inside the existing hit rectangles and improve enabled/disabled hierarchy. Do not change interaction rectangles or crafting/progression logic.

`missions.png` — **accepted; no r2 rewrite planned**:
- Daily/Weekly cards already sit well in the dark material language;
- status text remains readable and secondary to mission names;
- completion chests read as intentional locked secondary actions.

`pass.png` — **accepted; no r2 rewrite planned**:
- reward rail and free/premium hierarchy are coherent with r1.1;
- footer claim/unlock actions read correctly;
- retain current composition unless later state captures expose a selected/claimable-state issue.

`store.png` — **screen-specific r2 polish required**:
- product cards and icons fit the shared foundation;
- the right-side `TRY`/`BUY`/`OWNED` action is still naked text inherited from the older Store renderer and does not read as a production action affordance;
- r2 should replace only this visual action treatment with a compact forged action chip inside the existing product-card hit rectangle. Product catalog, purchase simulation/monetization action and hitbox stay unchanged.

## Current validation
Primary accepted run `32267108361` on `83412d21...`:
- Godot 4.7.1 compile/import: PASS
- r1 shared UI contract: PASS
- r1.1 dark-panel balance contract: PASS
- real 720x1280 Home/Hero/Forge/Talents captures: PASS
- v1.61 r3.2 directional Combat lock: PASS
- v1.38 MenuShell/router regression: PASS
- v1.52.1 tutorial/game-over input-flow regression: PASS

Secondary diagnostic run `32267829522` on `68ce35cd...`:
- r1/r1.1 contracts: PASS
- primary four-screen regression captures: PASS
- Vault/Missions/Pass/Store secondary captures: PASS
- v1.61 r3.2 Combat lock: PASS
- MenuShell/router: PASS
- v1.52.1 input: PASS

## Non-negotiable UI rules
1. Preserve `83412d21...` as the accepted r1.1 rollback point.
2. Do not move or resize established pointer hit rectangles merely to fit a visual redesign unless a separately scoped UX/input change is explicitly opened.
3. Do not regress to flat generic rectangles, bright full-card color slabs, cheap neon/full-ring icon language, or inconsistent per-screen component families.
4. Primary actions must remain visually dominant; secondary navigation and utilities must remain quieter.
5. Accent color identifies function/screen but should not become the entire surface.
6. CI green is necessary but runtime captures decide visual acceptance.
7. Keep UI work presentation-only on top of v1.61 unless separately scoped.
8. Save this file after every meaningful accepted/rejected UI pass so a new chat can resume without reconstruction.

## Current next priorities
1. **v1.62 r2: polish Vault control hierarchy and Store action chips only.** Missions and Tower Pass are protected from unnecessary r2 changes.
2. Re-render all eight menu screens after r2; visually accept/reject Vault and Store while treating Home/Hero/Forge/Talents/Missions/Pass as regressions.
3. Then review **Settings/modal, Upgrade/Decision, Game Over/result** states for the same button/panel language.
4. Add/verify selected, disabled and pressed-state hierarchy where the existing runtime exposes those states; do not invent new input authority just for visuals.
5. No TestFlight build for individual UI passes. A TestFlight decision comes only after the menu set is coherently upgraded and the v1.62 iOS/device gate is deliberately run.
