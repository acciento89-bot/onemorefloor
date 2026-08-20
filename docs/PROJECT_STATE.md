# One More Floor — Project State

Canonical handoff. **Repository truth wins over chat memory.**

## Active mode — COMPLETE THE GAME, NOT RELEASE
The current goal is to finish the visible and functional game end-to-end before another integrated TestFlight build. App Store submission work remains deferred.

## Accepted frontend lock — v1.67 r1.2
- Branch / PR: `agent/v1.66-character-form` / PR #103.
- Frontend r1.2 is the accepted menu baseline after real 720x1280 portrait review.
- Home/Hero share the gameplay Wanderer authority.
- Forge uses the dedicated authored v1.67 workshop kit.
- Talents use the progression-tree composition.
- Missions use the contract-board composition.
- Vault empty state and Tower Pass direction are retained.
- Existing interaction rectangles / routes / progression authority remain unchanged.

## Active candidate — v1.68 Wanderer Visual Completion r1.1
- Active scene: `scenes/main.tscn` -> `scripts/main_v92.gd`.
- Gameplay world: `scripts/world3d_chamber_v168_character_completion.gd`.
- Shared actor factory: `scripts/world3d_actor_factory_v168_character_completion.gd`.
- Frontend stage: `scripts/menu3d_stage_v168_character_completion.gd`.
- Hood remains the accepted v1.60 Hood r11.
- v1.55 articulated glTF pivots / animation state authority remain unchanged.
- No hitbox, socket, collision, damage, timing, input, save or progression changes.

### r1 decision — REJECTED VISUALLY
Dedicated v1.68 run `32335181802` passed import/compile, shared menu/gameplay identity, matched captures and the full gameplay smoke. Real 720x1280 image review then rejected r1 because the new pauldrons were too wide/horizontal: at gameplay distance they read like wings, and in Hero they made the Wanderer more block-like instead of more premium. CI was green but visual acceptance failed.

### r1.1 correction
Keep the successful tapered torso / authored kit direction but correct only the image-proven problems:
- smaller, more downward-sitting faceted pauldrons;
- narrower chestplate silhouette;
- restrained brass trim;
- slimmer front tabard;
- retain r1 gauntlets, boots and blade;
- retain Hood r11 and all animation/gameplay authority.

The same `v95` gate and matched capture harness must prove r1.1. Visual acceptance remains pending until the new Hero and v1.66-before/v1.68-after images are inspected.

## Preserved gameplay/art locks
- v1.67 r1.2 frontend/menu baseline.
- v1.66 r1.1 enemy character-form baseline; original SphereMesh r1 rejected.
- v1.65 r1.3 environment surface/depth baseline.
- v1.64 r1.1 character-lighting/material ordering.
- v1.63 projectile/boss combat identity.
- v1.62 UI/input foundations.
- Save, migration, backup, settings, tutorial, endless/endgame and gameplay authority remain covered by smoke gates.

## TestFlight
- Build 30 is successfully uploaded and remains the current integrated validation build.
- Do not create TestFlight builds for each completion pass.
- Next TestFlight bundles several completed blocks after character, enemy/boss, world, UX and polish work converge.

## Remaining completion blocks
1. **Wanderer visual completion** — active v1.68 r1.1, pending matched image review.
2. Enemy + boss visual completion and distance readability.
3. Full realm/endgame visual consistency sweep.
4. UX/settings/tutorial/progression consistency and dead-route cleanup.
5. Audio/VFX/haptics and device-performance polish.
6. Integrated TestFlight build for real iPhone/iPad playtest.
7. Only after device/visual acceptance: release metadata and App Store submission.

## Continuity rules
- Update this file after each major accepted/rejected pass.
- Real portrait captures and device acceptance decide visual completion; CI only proves technical health.
- Keep menu and gameplay Wanderer on one shared actor authority.
- Preserve accepted gameplay/input/save contracts unless a verified blocker requires a change.
- Bundle meaningful work before TestFlight; avoid build-number churn.
