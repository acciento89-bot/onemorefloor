# ONE MORE FLOOR v1.74 — Branding + Product Identity Completion

Status: **r1 candidate — visual acceptance pending**

## Goal
Remove the remaining prototype/cartoon mismatch between the shipping product identity and the accepted dark-fantasy game presentation.

## r1 scope
- Replace the shipping project icon path from legacy `assets/art/wanderer.svg` to `assets/art/app_icon_v174.svg`.
- New icon is authored as a full-bleed 1024x1024 square with no baked rounded-corner mask.
- Identity grammar: gothic tower/portal, faceless hooded Wanderer, compact steel silhouette, gold core and ascending violet blade.
- Add a compact matching crest to the Home safe top band through `scripts/main_v98.gd`.
- Preserve v1.73 run-flow, v1.72 device/audio/haptics, gameplay, input rectangles, progression, saves and StoreKit authority.
- No TestFlight trigger or release-version change.

## Visual acceptance gates
The r1 candidate is not accepted from CI alone. Review both fixed captures:
1. `home_brand_v174.png` — crest must feel integrated with the accepted Home composition and must not collide with title/navigation/safe areas.
2. `app_icon_v174.png` — must read clearly at small scale, avoid a cartoon-face impression, avoid noisy micro-detail, and remain recognizably ONE MORE FLOOR rather than a generic fantasy RPG icon.

Reject or revise if:
- the crest competes with the ONE MORE FLOOR title;
- the icon becomes too dark to read at TestFlight/iOS icon size;
- violet/gold accents dominate the silhouette;
- the hood/body looks like a flat 2D mascot rather than the accepted armored dark-fantasy identity;
- any gameplay/input/save regression appears.

## Technical evidence
Dedicated gate: `.github/workflows/v101-brand-identity-check.yml`

Expected checks:
- Godot 4.7.1 import/compile;
- v1.74 identity smoke;
- Xvfb + real OpenGL3/GL Compatibility Home/icon capture;
- full gameplay smoke;
- evidence artifact `v174-branding-product-identity`.

## TestFlight
Current confirmed device build remains `1.26.0 (31)`. v1.74 r1 does not dispatch another TestFlight upload.
