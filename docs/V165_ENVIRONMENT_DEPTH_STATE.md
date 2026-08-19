# One More Floor — v1.65 Environment Surface & Depth State

Canonical checkpoint for the active v1.65 environment-quality milestone. **Repository truth wins over chat memory.** Read together with `docs/PROJECT_STATE.md` and `docs/V164_CHARACTER_LIGHTING_STATE.md`.

## Branch / parent
- Active branch: `agent/v1.65-environment-depth`.
- Parent: `agent/v1.64-character-lighting` / PR #95.
- Accepted parent production lock: `b4a63b0be50caa5ed08c9984c2101c059347dfe9` — v1.64 r1.1.
- No TestFlight upload is authorized until v1.65 is visually accepted and bundled to `main`.

## Why v1.65 exists
Accepted v1.64 matched gameplay captures fixed the dominant character-readability issue. The next largest visible quality gap is now the environment itself:
- floor plates/flagstones read as very large flat rectangles;
- authored OBJ props still receive largely flat single-material response;
- set dressing is sparse/symmetrical enough to expose the constructed/blockout feel;
- realm identity exists, but surface wear, depth cues and local breakup are too weak for the target high-quality isometric 3D look.

## Protected systems
1. Preserve the accepted v1.64 character-lighting/material response.
2. Preserve v1.63 combat identity, boss dominance, projectile identity and v1.61 danger semantics.
3. Preserve camera position/focus/orthographic size.
4. Do not alter collision, navigation, combat space, hitboxes, damage, timing, targeting, input, saves, progression or UI.
5. Added depth dressing must remain presentation-only and low-profile.
6. Stay on GL Compatibility/mobile-friendly rendering.
7. CI green is necessary but five-realm gameplay-distance images decide visual acceptance.

## r1 implementation — pending visual acceptance
Active files:
- `assets/shaders/v165_environment_surface.gdshader`
- `scripts/world3d_chamber_v165_environment_depth.gd`
- `scripts/main_v86.gd`
- `scenes/main.tscn`

r1 currently adds:
- one lightweight procedural GL-compatible environment surface shader using world-space broad/fine variation, restrained edge response and ground-band darkening;
- realm-specific surface materials for Lower Halls, Ossuary, Iron Bastion, Rift Descent and Starless Spire;
- material replacement on existing v1.60 floor slabs and authored imported environment meshes;
- low-profile realm dressing: curbs, seams, rubble/bone fragments, rivet-like plate details, rift fractures and Starless inlays;
- no CollisionShape3D, no navigation nodes and no new light family.

Readiness contract:
- v1.64 character lighting must remain ready;
- at least 50 existing environment meshes/slabs must use the v1.65 surface path;
- at least 50 low-profile depth details must exist;
- renderer must remain `gl_compatibility`.

## Immediate next steps
1. Compile and smoke-test the active r1 stack.
2. Render matched v1.64-before / v1.65-after captures for all five realms at 720x1280.
3. Reject or correct r1 if surfaces become noisy, too bright, visually repetitive or interfere with combat readability.
4. Preserve v1.64/v1.63/v1.62/v1.61/input regressions.
5. Only after visual acceptance update `docs/PROJECT_STATE.md` and prepare the single requested TestFlight bundle.
