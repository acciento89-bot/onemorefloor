# ONE MORE FLOOR v1.74 — Branding + Product Identity Completion

Status: **r1.1 candidate — visual acceptance pending**

## Goal
Remove the remaining prototype/cartoon mismatch between the shipping product identity and the accepted dark-fantasy game presentation.

## Locked icon direction
- Shipping project icon changes from legacy `assets/art/wanderer.svg` to `assets/art/app_icon_v174.svg`.
- New icon is a full-bleed 1024x1024 square with no baked rounded-corner mask.
- Identity grammar: gothic tower/portal, faceless hooded Wanderer, compact steel silhouette, gold core and ascending violet blade.
- r1 icon visual review: **accepted direction**. It remains readable in explicit 180/120/80/60 px reduction checks and does not reproduce the old cartoon face.

## r1 rejection
The first real-GL Home capture showed the large crest overlapping the current production `ONE MORE FLOOR` wordmark. The duplicate `KAMILUNAVO GAMES` microcopy also repeated an existing footer label. r1 is therefore visually rejected despite a fully green technical gate (`32375616514`).

## r1.1 correction
- Keep the accepted app icon unchanged.
- Reduce the Home crest to 50% scale.
- Move it to the clear top-center gap between Best Floor and coin panels.
- Remove duplicate Kamilunavo microcopy.
- No navigation/input/layout authority changes.

## Preserved locks
- v1.73 run-flow presentation.
- v1.72 device/audio/haptics budgets.
- gameplay, combat, camera, progression, input rectangles, saves and StoreKit authority.
- No TestFlight trigger or release-version change.

## Visual acceptance gates
Review both fixed captures:
1. `home_brand_v174.png` — r1.1 crest must stay fully above the production wordmark, clear both top stat panels, and read as a subtle brand seal rather than a second hero graphic.
2. `app_icon_v174.png` — accepted icon direction must remain unchanged and clearly readable at small scale.

Reject or revise if the crest still collides with Home hierarchy or if any accepted identity/gameplay lock regresses.

## Technical evidence
Dedicated gate: `.github/workflows/v101-brand-identity-check.yml`
Expected checks: Godot import/compile, identity smoke, Xvfb real-GL captures, full gameplay smoke, evidence artifact `v174-branding-product-identity`.

## TestFlight
Current confirmed device build remains `1.26.0 (31)`. v1.74 does not dispatch another TestFlight upload.
