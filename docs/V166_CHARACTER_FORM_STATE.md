# One More Floor — v1.66 Character Form & Readability State

Canonical checkpoint for the active v1.66 actor-quality milestone. **Repository truth wins over chat memory.** Read together with `docs/PROJECT_STATE.md`, `docs/V165_ENVIRONMENT_DEPTH_STATE.md` and `docs/V164_CHARACTER_LIGHTING_STATE.md`.

## Branch / parent
- Active branch: `agent/v1.66-character-form`.
- Parent: accepted `main` at `567c83c0cace9c6028075266aa36beb622b554fc`.
- Parent gameplay/presentation lock: v1.65 Environment Surface & Depth r1.3.
- The parent already contains the single requested TestFlight Build 30 trigger. v1.66 must not modify `.github/testflight-trigger` and must not create another TestFlight upload.

## Why v1.66 exists
The final accepted v1.65 five-realm captures moved environment quality ahead of actor quality. At gameplay distance the remaining largest visible gap is now character form:
- Wanderer still compresses into a dark robe/cape mass and the weapon/armor hierarchy is weak;
- Goblin/Ghoul/Necromancer body cores still read too much as one low-poly material mass;
- Warden has strong scale but needs more armor layering to feel authored rather than block-built;
- Skeleton is already a clear benchmark and should remain geometrically locked;
- improvements must remain readable at the actual isometric gameplay camera, not only in close-up.

## Protected systems
1. Preserve v1.65 r1.3 environment materials, depth dressing and realm identity.
2. Preserve v1.64 character lighting/final material ordering.
3. Preserve v1.63 boss/projectile/combat identity and v1.61 danger semantics.
4. Preserve camera position/focus/orthographic size.
5. Preserve imported animation pivots, sockets, combat hitboxes, navigation, damage/timing/targeting, input, saves, progression and UI.
6. Added v1.66 geometry is presentation-only and must never contain CollisionShape3D, CollisionObject3D or NavigationRegion3D authority.
7. Stay on GL Compatibility/mobile-friendly rendering.
8. Gameplay-distance before/after images decide visual acceptance; CI green alone is insufficient.

## r1 implementation — pending visual acceptance
Active files:
- `scripts/world3d_actor_factory_v166_character_form.gd`
- `scripts/world3d_chamber_v166_character_form.gd`
- `scripts/main_v87.gd`
- `scenes/main.tscn`

r1 currently adds:
- restrained Wanderer proportion rebalance around the already accepted Hood r11;
- stronger chestplate/pauldron/blade material hierarchy without changing the rig or sockets;
- rounded low-cost secondary volumes for Goblin, Bat, Ghoul, Necromancer and Warden using existing material families;
- small per-archetype scale/weapon-readability corrections on the existing authored body assets;
- explicit Skeleton geometry lock as the readability benchmark;
- no new lights, no camera change and no gameplay-authority nodes.

Readiness contract:
- v1.65 environment readiness must remain true;
- v1.64 character-lighting readiness must remain true;
- Wanderer must report v1.66 form readiness while preserving Hood r11;
- all six enemy archetypes must pass runtime readiness, with Skeleton showing no `CharacterFormV166` geometry node;
- added form nodes must contain no collision/navigation authority;
- camera and renderer contracts remain unchanged.

## v91 evidence plan
1. Compile/import the active `main_v87` stack with Godot 4.7.1.
2. Run `v91_character_form_r1_smoke_test.gd` across Wanderer + all six enemy archetypes.
3. Re-run the hardened v1.64 runtime material-order test.
4. Render matched fixed 720x1280 v1.65-before / v1.66-after captures for Lower Halls, Ossuary, Iron/Warden, Rift Descent and Starless Spire.
5. Reject/correct r1 if rounded volumes read as toy-like blobs, silhouettes get too wide, weapons lose clarity, or the new geometry becomes more visually dominant than the actor itself.
6. Let the normal branch iOS playtest workflow validate unsigned iPhone/iPad compilation only; TestFlight upload steps must remain skipped.

## Acceptance rule
Do not promote v1.66 to `main` merely because CI passes. The five matched gameplay-distance image pairs must show a clear actor-quality gain without regressing the accepted environment/combat hierarchy. No TestFlight upload is planned for this intermediate development pass.
