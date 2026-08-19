# One More Floor — v1.65 Environment Surface & Depth State

Canonical checkpoint for v1.65 environment quality. **Repository truth wins over chat memory.** Read together with `docs/PROJECT_STATE.md` and `docs/V164_CHARACTER_LIGHTING_STATE.md`.

## Milestone / lock
- Branch: `agent/v1.65-environment-depth` / PR #100.
- Parent: accepted v1.64 r1.1 / PR #95.
- **Accepted v1.65 production implementation lock: `a5951b244166bf824e403eda037a4568194348c6` — r1.3 active through `main_v86.gd`.**
- Final visual/test checkpoint: `c1078573877a4e204405a41f781e92201ac20b85`.
- Active world: `world3d_chamber_v165_environment_depth_r13.gd`.
- No TestFlight upload occurred during v1.65 development passes.

## Goal
After v1.64 fixed character readability, the largest visible gap was the environment: large flat slabs, weak material breakup, sparse/symmetrical dressing and insufficient realm-specific surface depth.

v1.65 improves that presentation without changing camera, collision, navigation, combat space, hitboxes, damage, timing, targeting, input, saves, progression, UI or accepted character/combat presentation.

## Accepted r1.3 result
- Lightweight GL Compatibility shader adds world-space broad/fine material variation, roughness breakup, restrained edge response and ground contact darkening without texture fetches or screen-space effects.
- Existing authored environment/floor meshes receive realm-specific stone/metal/bone/rift/spire material response.
- Low-profile presentation-only dressing adds chips, rubble, bone fragments, rivets, compact material inlays and restrained wear/patina.
- Lower Halls: controlled soot/wear plus small stone/brass chips; no continuous brass bars.
- Ossuary: darker dust/patina and small bone fragments; no large pale polygon plates.
- Iron Bastion: restrained rust/patina and compact metal debris; Warden/boss dominance remains intact.
- Rift Descent: dark-purple material mottling and compact crystal/shard accents; no long neon/debug fractures.
- Starless Spire: cold-blue surface breakup and compact inlay chips; no long blue debug bars.
- More than the required 50 environment surfaces and 50 low-profile details remain on the v1.65 presentation path.
- Camera position/focus/orthographic size remain identical to accepted v1.64.
- No `V165` collision or navigation authority exists.

## Rejected/superseded passes
### r1 — technically green, visually rejected
- Fixed-size technical review: run `32291127807` — green.
- Artifact `9379525207`.
- Rejected because Lower Halls used overly regular brass strips and Rift/Starless contained long purple/blue floor lines that read as prototype/debug/neon bars.
- An earlier macOS capture from run `32290827578` exposed a capture-window resize problem; it was not used for visual acceptance. The capture harness was then moved to a dedicated fixed 720x1280 offscreen `SubViewport` with dimension assertions.

### r1.1 — technically green, visually superseded
- Run `32291617993` — green.
- Artifact `9379797882`.
- Removed the long debug-bar language correctly, but the overall environment change remained too subtle to justify the milestone as complete.

### r1.2 — technically green, visually rejected
- Run `32292389117` — green.
- Artifact `9380008645`.
- Material mottling became meaningfully visible and Rift/Starless moved in the correct direction.
- Rejected because large bright faceted wear patches in Ossuary/Iron read like applied low-poly polygon plates rather than natural surface wear.

### r1.3 — accepted
- Final matched visual workflow: **`32292817771` — fully green.**
- Final matched artifact: **`9380157967`** (`v90-environment-depth-r1-macos-before-after`).
- All ten images were asserted at exactly **720x1280**.
- Visual verdict: accepted. Lower/Ossuary/Iron use smaller/darker patina and compact debris; Rift/Starless retain the successful r1.2 material-depth gain without debug bars. Character/boss readability remains dominant.

## Regression / device validation
Final r1.3 macOS visual gate `32292817771`:
- active v1.65 compile/import: PASS;
- r1.3 readiness/camera/no-collision contract: PASS;
- hardened v1.64 Necromancer/Skeleton runtime material ordering: PASS;
- five matched fixed 720x1280 realm pairs: PASS;
- artifact upload: PASS.

Final r1.3 iPhone/iPad device gate **`32292817944` — fully green**:
- release metadata: PASS;
- Godot import: PASS;
- Xcode export/project inspection: PASS;
- **unsigned iPhone/iPad device compile: PASS**;
- **unsigned device package: PASS**;
- unsigned/Xcode artifacts: PASS;
- TestFlight override/API key/release archive/export/upload: **SKIPPED**.

The previously queued standalone v1.64 hardening concern is superseded by repeated PASS inside the v1.65 macOS gates, including the accepted r1.3 gate.

## Milestone verdict / release policy
**v1.65 Environment Surface & Depth r1.3 is visually accepted and unsigned-device-build validated.**

Next action is the explicitly requested release bundle:
1. bundle the accepted v1.65 branch to `main`;
2. verify the current stored TestFlight build trigger immediately before upload;
3. trigger **exactly one** TestFlight upload for the accepted bundled milestone;
4. do not automatically issue a second upload if the first upload attempt fails — report the failure first.
