# ONE MORE FLOOR — Release Readiness

Canonical release-readiness checkpoint for the integrated device-candidate phase. **Repository truth wins over chat memory.**

## Release strategy
The visible/functional completion stack through **v1.72 r1** is accepted. From this point:
- no new feature families;
- only device-proven crash/flow/save/input/UI/build/audio/haptics/performance blockers justify production changes;
- accepted visual locks remain frozen unless a physical-device regression proves a correction is necessary;
- App Store submission work stays deferred until the integrated TestFlight candidate is physically accepted on iPhone/iPad.

## Current candidate
- Branch: `agent/v1.66-character-form` / PR #103.
- Base: accepted v1.65 Environment Surface & Depth r1.3 on `main`.
- Active production entrypoint: `scenes/main.tscn -> scripts/main_v96.gd`.
- Accepted integrated implementation head before readiness-doc hardening: `04fbc6a977839acadf50759c6c56aea7cea1db81`.
- v1.67 frontend/menu completion: accepted.
- v1.68 Wanderer visual completion r1.1: accepted.
- v1.69 enemy + boss visual completion r1: accepted.
- v1.70 realm/endgame visual completion r1.1: accepted.
- v1.71 UX/completion r1.1: accepted.
- v1.72 priority audio, rate-limited haptics and mobile runtime budgets r1: accepted.

## Accepted evidence
- v1.69 dedicated gate `32338789376` + artifact `9395598136`.
- v1.70 dedicated gate `32340024229` + artifact `9396034866`.
- v1.71 accepted r1.1 gate `32350270829` + artifact `9399620857`.
- v1.72 dedicated gate `32351081073`: SUCCESS.
- v1.72 same-head unsigned iPhone/iPad device build `32351081135`: SUCCESS.
- That iOS validation run explicitly skipped TestFlight override, App Store archive/export and Apple upload steps.

## Integrated candidate gate
`.github/workflows/v92-release-completion-gate.yml` is now the authoritative **v1.72 Integrated Device Candidate Gate**.

The old v1.66 implementation of this workflow was not sufficient for final promotion because its active-main check could match historical baseline text inside `main.tscn`. The hardened gate now parses the actual `id="1_main"` external resource and requires exactly `res://scripts/main_v96.gd`.

Required PASS set on one exact head:
1. Godot 4.7.1 full project compile/import.
2. Production metadata consistency: matching marketing version, bundle `de.kamilunavo.onemorefloor`, iPhone+iPad target, 720x1280 reference viewport and GL Compatibility.
3. Exact active production entrypoint `scripts/main_v96.gd`.
4. Pre-promotion `.github/testflight-trigger` remains on already-used Build 30.
5. Production Store fail-closed + Privacy surface smoke.
6. Accepted v1.67 frontend smoke.
7. Accepted v1.68 Wanderer smoke.
8. Accepted v1.69 enemies/boss smoke.
9. Accepted v1.70 realms/endgame smoke.
10. Accepted v1.71 UX completion smoke.
11. Accepted v1.72 feedback/performance/mobile-budget smoke.
12. Complete gameplay smoke.
13. Save/settings/privacy/pause/tutorial release smoke.
14. Lifecycle backup/touch/frame-cap smoke.
15. Endless Ascension progression smoke.
16. Post-50 endgame/boss/loot smoke.
17. v1.64 material/lighting contract.
18. v1.63 boss-dominance + projectile identity.
19. v1.61 directional danger language.
20. v1.62 production UI + v1.52.1 tutorial/game-over input flow.

A green integrated gate means the candidate is technically eligible for promotion to `main`. It does **not** replace physical iPhone/iPad playtesting.

## iOS / TestFlight state
- Current marketing version remains whatever matching value is checked into `project.godot` and `export_presets.cfg`; the integrated gate requires them to match.
- Bundle ID: `de.kamilunavo.onemorefloor`.
- Target: iPhone + iPad.
- Build 30 is already uploaded and remains the current integrated validation build.
- Completion passes v1.66-v1.72 did not create additional TestFlight builds.
- Before promotion, `.github/testflight-trigger` must still remain Build 30.
- The next deliberate upload must use the next valid App Store build number, expected to be Build 31 if App Store Connect confirms no newer build exists.
- Never auto-retry a failed signed/TestFlight upload. Inspect and report the actual Apple-upload failure first.

## Promotion sequence
1. Require the hardened integrated candidate gate green on the exact PR #103 head.
2. Require the normal unsigned iPhone/iPad build green on that same candidate lineage.
3. Review the full PR #103 diff against `main`; only accepted completion work may remain.
4. Freeze the candidate and promote/merge it to `main`.
5. Confirm the next valid App Store build number.
6. Change the TestFlight trigger exactly once and dispatch one integrated signed/TestFlight upload.
7. Verify the actual `Upload to TestFlight with Apple cloud distribution signing` step succeeds before claiming the build is on TestFlight.
8. Perform physical iPhone/iPad acceptance testing.
9. Fix only device-proven blockers; every blocker fix must re-run the integrated gate + unsigned iOS build before another signed upload is considered.
10. Only after device acceptance: finish release metadata/compliance and submit the frozen build to App Review.

## Definition of done for the current phase
The integrated device candidate is ready for TestFlight promotion when:
- PR #103 whole-diff review is clean;
- the hardened integrated candidate gate is green;
- unsigned iPhone/iPad build is green;
- no known technical blocker remains on the candidate head.

The game is release-ready only after the signed TestFlight build is installed and physically accepted on iPhone/iPad and App Store Connect submission requirements are complete.
