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
- large cards establish an opaque dark production plate first;
- source hue survives as restrained material tint rather than a full saturated slab;
- low-alpha source cards keep accent identity mainly through edge, icon and subtle inner tint;
- r1 component geometry, button hierarchy and hit areas remain unchanged.

### r1.1 manual image acceptance
`home.png` — **accepted**: PLAY is the single dominant CTA; progression navigation is coherent and Store/Settings remain subordinate.

`hero.png` — **accepted**: Wanderer remains focal; stat card and TRAIN/BACK use the shared material language.

`forge.png` — **accepted**: Forge card/action plate match Home/Hero while the authored forge environment stays dominant.

`talents.png` — **accepted as foundation**: green/purple/gold remain identity accents rather than full bright slabs.

Therefore **r1.1 / `83412d21...` remains the current fully accepted v1.62 baseline until r2.1 is visually validated.**

## Secondary menu audit — checkpoint before r2
Diagnostic implementation: `68ce35cd2b16093a7a10dcaa3bd02f376110d157`.
Dedicated workflow: **`32267829522` — fully green.**

The diagnostic pass added real 720x1280 captures for Vault, Missions, Tower Pass and Store without changing r1.1 visuals.

### Manual audit
`vault.png` — shared foundation accepted, but Filter/Sort/Lock + Workshop + Item Progression controls had too much equal rectangular weight in the empty/disabled state.

`missions.png` — **accepted; protect from unnecessary rewrite.**

`pass.png` — **accepted; protect from unnecessary rewrite.**

`store.png` — product cards fit r1.1, but right-side `TRY`/`BUY`/`OWNED` remained naked text and needed a compact production action affordance.

## r2 — technically green, only partially visually accepted
Implementation: `bd2f6799609a4a8cc150637bcfb63b7dbfff44d3`.
Dedicated workflow: **`32268685992` — fully green.**

r2 attempted two narrow presentation changes:
- Vault controls were compacted visually inside the existing hit rectangles, with disabled Workshop/Item Progression actions made quieter.
- Store attempted to replace the naked action text through `_v42_store_card`.

### r2 image verdict
`vault.png` — **accepted improvement**:
- Filter/Sort/Lock are tighter and less blocky;
- Workshop and Item Progression controls occupy less visual height while preserving their full inherited hitboxes;
- disabled actions are visibly subordinate instead of competing with active controls.

`store.png` — **rejected / unchanged**:
- screenshot remained visually identical to the pre-r2 Store action treatment;
- investigation proved the current release-facing Store no longer draws through `_v42_store_card`;
- the active inherited renderer is `main_v50.gd::_v50_store_card`, which draws the naked `TRY`/`UNAVAILABLE`/`OWNED` string itself;
- therefore the r2 Store override targeted a historical renderer and was structurally present but visually bypassed.

**Do not call `bd2f6799...` the final r2 visual lock.** Preserve its Vault work, but fix Store through a narrow r2.1 subclass overriding `_v50_store_card`; do not weaken the visual gate or alter monetization/pointer logic.

## Current validation
Primary accepted run `32267108361` on `83412d21...`: compile, r1/r1.1, Home/Hero/Forge/Talents, v1.61 Combat, MenuShell/router and input all PASS.

Secondary diagnostic run `32267829522` on `68ce35cd...`: primary/secondary captures, v1.61 Combat, MenuShell/router and input all PASS.

r2 run `32268685992` on `bd2f6799...`: compile, r1/r1.1/r2 contracts, all eight captures, v1.61 r3.2 Combat, MenuShell/router and v1.52.1 input all PASS — but Store remains visually rejected despite green CI.

## Non-negotiable UI rules
1. Preserve `83412d21...` as the last fully accepted rollback until r2.1 is visually accepted.
2. Preserve the accepted r2 Vault compaction from `bd2f6799...` while correcting only Store in r2.1.
3. Do not move or resize established pointer hit rectangles merely to fit a visual redesign unless a separately scoped UX/input change is explicitly opened.
4. Do not regress to flat generic rectangles, bright full-card color slabs, cheap neon/full-ring icon language, or inconsistent per-screen component families.
5. Primary actions must remain visually dominant; secondary navigation and utilities must remain quieter.
6. Accent color identifies function/screen but should not become the entire surface.
7. CI green is necessary but runtime captures decide visual acceptance.
8. Keep UI work presentation-only on top of v1.61 unless separately scoped.
9. Save this file after every meaningful accepted/rejected UI pass so a new chat can resume without reconstruction.

## Current next priorities
1. **v1.62 r2.1: keep r2 Vault; override the actual `main_v50::_v50_store_card` renderer with compact forged action chips.**
2. Re-render all eight menu screens; accept/reject Store visually while ensuring Vault remains improved and Missions/Pass remain unchanged.
3. Then review **Settings/modal, Upgrade/Decision, Game Over/result** states for the same button/panel language.
4. Add/verify selected, disabled and pressed-state hierarchy where the existing runtime exposes those states; do not invent new input authority just for visuals.
5. No TestFlight build for individual UI passes. A TestFlight decision comes only after the menu set is coherently upgraded and the v1.62 iOS/device gate is deliberately run.
