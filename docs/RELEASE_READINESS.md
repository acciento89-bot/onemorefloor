# ONE MORE FLOOR — Release Readiness

Canonical release-readiness checkpoint for the final pre-release phase. **Repository truth wins over chat memory.**

## Release strategy
From v1.66 onward, development is in **release-completion mode**:
- no new feature families unless a release blocker proves one is required;
- no more cosmetic micro-passes after v1.66 visual acceptance;
- only crash/flow/save/input/UI/build/store/release blockers justify production changes;
- visual changes must still pass the fixed gameplay-distance comparison gate;
- release promotion requires the bundled `v92 Final Release Completion Gate`, unsigned iPhone/iPad build, and a deliberate signed/TestFlight validation.

## Current candidate
- Branch: `agent/v1.66-character-form` / PR #103.
- Production parent: accepted v1.65 Environment Surface & Depth r1.3 on `main`.
- Active candidate: **v1.66 Character Form & Readability r1.1**.
- r1 was rejected because it introduced rounded `SphereMesh` form volumes.
- r1.1 replaces those additions with faceted thin presentation-only forms and adds a hard no-`SphereMesh` regression rule.
- v1.66 remains visually pending until ten fixed 720x1280 before/after captures are reviewed.

## Already-covered release systems
The repository already has executable regression coverage for:
- main-scene boot and production asset import;
- complete gameplay progression through the Floor-30 production loop;
- loot drops, inventory locking, dismantling, crafting, equipment and set bonuses;
- Missions and Tower Pass rewards;
- Dungeon / Crypt / Forgotten Castle routing and bosses;
- Endless Ascension checkpoint/death-setback scaling;
- post-50 endgame realms/bosses/loot;
- save schema migration and non-destructive save-section preservation;
- last-known-good save backup/checkpoint writes;
- Settings persistence;
- Pause / Resume gameplay blocking;
- Tutorial completion persistence;
- analytics opt-out/opt-in behavior;
- release audio resource wiring;
- mobile 60-FPS cap and critical touch geometry;
- v1.61 directional danger language;
- v1.62 production UI/runtime CTAs;
- v1.63 projectile identity and boss dominance;
- v1.64 runtime material ordering;
- v1.65 environment/camera/no-collision contract;
- v1.66 character-form/no-collision/no-navigation contract;
- unsigned iPhone/iPad Xcode compilation/package pipeline.

## Final automated gate — v92
`.github/workflows/v92-release-completion-gate.yml` consolidates the release-critical historical gates into a single modern verdict on the active candidate.

Required PASS set:
1. Godot 4.7.1 full project compile/import.
2. Production metadata consistency (`1.26.0`, bundle ID, iPhone+iPad target, 720x1280, GL Compatibility).
3. v1.66 r1.1 character-form runtime contract.
4. Full production gameplay smoke.
5. Release save/settings/privacy/pause/tutorial smoke.
6. Lifecycle checkpoint/save backup/touch/frame-cap release-candidate smoke.
7. Endless Ascension smoke.
8. Endgame realms/bosses/loot smoke.
9. v1.65 environment contract.
10. v1.64 runtime material-order contract.
11. v1.63 boss-dominance + projectile-identity contracts.
12. v1.61 directional danger language.
13. v1.62 production UI + v1.52.1 input flow.

A green v92 means the **software/gameplay release bundle is technically complete**. It does not replace physical device playtesting or App Store review requirements.

## iOS / TestFlight state
- Current marketing version: `1.26.0`.
- Bundle ID: `de.kamilunavo.onemorefloor`.
- Target: iPhone + iPad.
- Build 30 was requested for the accepted v1.65 parent.
- The first actual Build-30 TestFlight run was cancelled before Apple upload confirmation.
- The same Build-30 run/job lineage has been explicitly retried; no Build 31 was created for that retry.
- v1.66 development must not mutate `.github/testflight-trigger`.

## Remaining release blockers
Only these items may block release after v92 is green:
- v1.66 r1.1 gameplay-distance images show a real visual regression;
- unsigned iPhone/iPad compile/package fails on the accepted final head;
- physical iPhone/iPad test finds a touch, safe-area, performance, audio, haptics, save or gameplay-flow blocker;
- signed TestFlight/archive/upload fails;
- App Store Connect metadata/assets/privacy/compliance are incomplete;
- App Review finds a functional or policy blocker.

Everything else is post-release backlog.

## Release promotion sequence
1. Finish and visually accept v1.66 r1.1 (or one narrowly-scoped correction only if the fixed images prove it necessary).
2. Require v92 green on the accepted v1.66 head.
3. Require the normal unsigned iPhone/iPad gate green on that same head.
4. Freeze gameplay/features.
5. Merge the accepted release bundle to `main`.
6. Create one deliberate final signed/TestFlight build using the next valid App Store build number at that time.
7. Perform physical iPhone/iPad acceptance testing.
8. Fix release blockers only; re-run v92 + device gate after every blocker fix.
9. Submit the frozen build to App Review.

## Definition of done
ONE MORE FLOOR is release-ready when:
- v1.66 visual gate is accepted;
- v92 is green;
- unsigned iOS build is green;
- signed/TestFlight build is installed and physically accepted on iPhone and iPad;
- App Store Connect submission metadata/compliance is complete;
- no known release blocker remains.
