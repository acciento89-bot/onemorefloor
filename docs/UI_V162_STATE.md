# One More Floor — v1.62 UI Foundation State

Canonical checkpoint for the active UI/menu presentation milestone. Read this together with `docs/PROJECT_STATE.md` before continuing UI work.

## Branch / parent
- Active branch: `agent/v1.62-ui-foundation`
- Parent checkpoint: v1.61 PR #90 documentation head `497f3ee945312955a620fa0c5b8913bc27d5c8db`.
- Locked combat implementation below this branch: v1.61 r3.2 `bb367aad35338dd6d32fbdf7d4de4208efef2ad0`.
- Do not reopen Combat r3.2, Wanderer r11, enemy anatomy/surface baselines, combat timing/radius/damage/input, or save/progression authority while doing UI work.

## v1.62 r1 target
Build a shared production UI foundation before individually restyling every menu.

Initial component scope:
1. Primary action button.
2. Secondary/back button.
3. Tab/navigation button with selected state.
4. Shared panel/card surface.
5. Section/header treatment.

First acceptance screen: Main/Home menu using the existing routing and menu/world ownership. Existing navigation hit areas and actions must remain unchanged.

## Visual direction
- Match the accepted authored 3D game: dark premium fantasy/action presentation.
- Avoid flat generic mobile rectangles, cheap neon, debug-like outlines, and inconsistent per-screen styling.
- Use restrained dark metal/stone/cloth surfaces with cool steel/brass/arcane accents.
- Primary/secondary/selected/disabled/pressed states must be visually distinct without excessive glow.
- Components must be reusable by Hero, Forge, Talents, Vault, Missions, Tower Pass, Store and later modal/result screens.

## Validation rules
- CI green is necessary but visual captures decide acceptance.
- Preserve existing menu routes and pointer hit areas.
- Preserve combat/world presentation underneath the menus.
- Add a dedicated v1.62 UI smoke/visual gate before calling r1 accepted.
- Update this file after every meaningful UI pass, including rejected visual directions.
- No TestFlight/build/version jump for individual UI micro-passes.

## Current status
- 2026-08-19: v1.62 branch created and checkpointed before implementation.
- Next: inspect `menu_shell.gd` plus current production menu draw path, implement shared component styling as a new top-layer/subsystem, then apply it to Home/Main without altering navigation behavior.
