# ONE MORE FLOOR

Mobile hybrid-casual roguelite by **Kamilunavo Games**.

> Climb. Loot. Risk it all. One more floor.

## Core loop

1. Enter a floor.
2. Move, dodge and auto-attack enemies.
3. Clear the floor and collect the loot.
4. Pick one of three random run upgrades.
5. Decide to cash out or climb one more floor.
6. Spend secured coins on permanent Camp progression.

## Tech

- Godot 4.7.1
- GDScript
- Portrait-first mobile UI (720 × 1280 reference canvas)
- iOS / iPadOS and Android targets
- GitHub Actions validation with headless project load, main-scene launch and gameplay smoke test

## Current playable slice — v0.3

v0.3 keeps the complete combat/risk loop from v0.2 and adds the first real permanent-progression layer.

### Combat

- Touch virtual joystick
- WASD / arrow-key desktop fallback
- Auto-targeting projectile attacks
- Critical hits and damage numbers
- Hit / death effects and screen shake
- Mobile haptics
- NOVA active ability that damages enemies and clears hostile projectiles
- Animated coin pickups

### Enemies

- **Goblin** — direct melee chaser
- **Bat** — fast wobble movement and low HP
- **Skeleton** — ranged enemy that tries to maintain distance
- **The Warden** — boss every fifth floor
  - telegraphed attacks
  - Phase II below 50% HP
  - alternating radial projectile rings and aimed fan attacks

### Run building

Ten temporary upgrades are currently available:

- Power Surge
- Blood Pact
- Multishot
- Quick Hands
- Long Reach
- Iron Heart
- Swift Boots
- Deadly Edge
- Nova Core
- Warden's Plate

Each cleared floor rolls three different choices.

### Permanent Camp progression

The Camp now has interactive progression screens:

- **Hero** — training increases starting HP and damage
- **Forge** — permanent weapon-damage upgrades
- **Talents**
  - Vitality: starting HP
  - Precision: starting critical chance
  - Fortune: coin-drop multiplier
- **Vault** — interactive placeholder for the upcoming artifact/equipment system

Hero, Forge and Talent levels persist in `user://save.cfg` together with banked coins and best floor.

### Risk / reward

- Cash out to secure all run coins.
- Continue to push the tower higher.
- Death currently secures 60% of unsecured run coins.
- Permanent Camp upgrades make future runs stronger.

## Validation

The CI pipeline uses Godot 4.7.1 and currently validates:

1. Headless project/editor load.
2. Main-scene launch.
3. Gameplay smoke test that exercises permanent upgrades, starts a run, rolls a run upgrade, reaches a Floor 5 Warden setup, triggers Phase II logic and cashes out.

## Run locally

1. Install Godot 4.7.1 Standard.
2. Import `project.godot`.
3. Press **F5** to run the project.
4. On desktop, use WASD/arrow keys or drag the lower-left joystick area with the mouse.
5. Press **Space** to trigger NOVA while testing on desktop.

## Roadmap

### Phase 1 — Playable core
- [x] Project foundation
- [x] First vertical-slice loop
- [x] Touch movement / auto attack
- [x] Projectile combat
- [x] Goblin / Bat / Skeleton enemy roles
- [x] Random three-choice upgrade roll
- [x] Ten run upgrades
- [x] Risk / reward decision
- [x] The Warden boss pattern
- [x] Warden telegraphs and Phase II
- [x] Basic haptics / combat feedback
- [ ] First audio pass
- [ ] Production sprites and animations

### Phase 2 — Meta progression
- [x] Camp-style home shell
- [x] Interactive Hero screen
- [x] Forge
- [x] Talents
- [x] Vault shell
- [ ] Artifact / equipment system
- [ ] Missions
- [ ] Tower Pass progression

### Phase 3 — Release systems
- [ ] Analytics
- [ ] Crash reporting
- [ ] Rewarded ads
- [ ] In-app purchases
- [ ] Leaderboards
- [ ] Cloud save

### Phase 4 — Content
- [x] Dungeon combat theme prototype
- [ ] Crypt
- [ ] Forgotten Castle
- [ ] More heroes
- [ ] More enemies
- [ ] More bosses
- [ ] Upgrade synergies and rarity tiers

## Repository layout

```text
.github/                 CI validation
scenes/                  Godot scenes
scripts/main_v03.gd      Active game/controller UI
scripts/progression.gd   Permanent Camp progression and save data
scripts/run_profile.gd   Per-run player/build state
scripts/enemy_factory.gd Enemy creation and scaling
scripts/smoke_test.gd    Headless gameplay validation
assets/                  Production art and audio (added incrementally)
docs/                    Game-design and architecture notes
```
