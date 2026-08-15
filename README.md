# ONE MORE FLOOR

Mobile hybrid-casual roguelite by **Kamilunavo Games**.

> Climb. Loot. Risk it all. One more floor.

## Core loop

1. Enter a floor.
2. Move, dodge and auto-attack enemies.
3. Clear the floor and collect coins and possible gear.
4. Pick one of three random run upgrades.
5. Decide to cash out or climb one more floor.
6. Spend secured coins, equip loot, complete missions and progress the Tower Pass.

## Tech

- Godot 4.7.1
- GDScript
- Portrait-first mobile UI (720 × 1280 reference canvas)
- iOS / iPadOS and Android targets
- GitHub Actions validation with headless project load, main-scene launch and gameplay smoke test

## Current playable slice — v0.4

v0.4 keeps the verified v0.3 combat and permanent-progression core, then layers loot, missions, Tower Pass progression, boss presentation and first audio feedback on top.

### Combat

- Touch virtual joystick
- WASD / arrow-key desktop fallback
- Auto-targeting projectile attacks
- Critical hits and damage numbers
- Hit / death effects and screen shake
- Mobile haptics
- NOVA active ability that damages enemies and clears hostile projectiles
- Animated coin pickups
- Procedural first-pass audio cues for attacks, hits, crits, NOVA, boss events, loot and reward claims

### Enemies

- **Goblin** — direct melee chaser
- **Bat** — fast wobble movement and low HP
- **Skeleton** — ranged enemy that tries to maintain distance
- **The Warden** — boss every fifth floor
  - boss intro presentation
  - dedicated boss HP bar
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

- **Hero** — training increases starting HP and damage
- **Forge** — permanent weapon-damage upgrades
- **Talents**
  - Vitality: starting HP
  - Precision: starting critical chance
  - Fortune: coin-drop multiplier
- **Vault** — real persistent loot inventory and equipment screen

### Loot and equipment

Enemies can now drop permanent equipment with five rarity tiers:

- Common
- Uncommon
- Rare
- Epic
- Legendary

Equipment slots:

- **Weapon** — permanent damage bonus
- **Armor** — permanent starting-HP bonus
- **Relic** — critical-chance or coin bonus

Wardens currently guarantee one equipment drop; normal enemies have a smaller scaling drop chance. The Vault stores up to 60 recent items and supports tap-to-equip.

### Missions

Daily missions currently cover:

- enemy kills
- cleared floors
- secured cash-out coins

Weekly missions include larger versions plus Warden kills. Completed missions award banked coins and Tower Pass XP.

### Tower Pass

The prototype Tower Pass currently has 20 free progression levels. XP comes from floor clears, Warden kills, cash-outs and mission rewards. Unlocked levels award claimable coin caches. There is no paid track in v0.4.

### Risk / reward

- Cash out to secure all run coins.
- Continue to push the tower higher.
- Death currently secures 60% of unsecured run coins.
- Equipped loot and Camp upgrades make future runs stronger.

## Validation

The CI pipeline uses Godot 4.7.1 and validates:

1. Headless project/editor load.
2. Main-scene launch.
3. Gameplay smoke test covering permanent upgrades, guaranteed Warden loot, equipment bonuses, mission completion/claiming, Tower Pass leveling/rewards, run start, run upgrades, Floor 5 Warden/Phase II and cash-out.

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
- [x] First procedural audio-feedback pass
- [ ] Production audio / music
- [ ] Production sprites and animations

### Phase 2 — Meta progression
- [x] Camp-style home shell
- [x] Interactive Hero screen
- [x] Forge
- [x] Talents
- [x] Vault inventory
- [x] Artifact / equipment foundation
- [x] Daily / weekly missions
- [x] Free Tower Pass progression
- [ ] Item traits and set bonuses
- [ ] Equipment dismantling / crafting

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
scripts/main_v03.gd      Verified v0.3 combat/meta controller
scripts/main_v04.gd      Active v0.4 systems/UI extension
scripts/progression.gd   Permanent Camp progression and save data
scripts/run_profile.gd   Per-run player/build state
scripts/enemy_factory.gd Enemy creation and scaling
scripts/loot_system.gd   Persistent gear drops and equipment
scripts/mission_system.gd Daily/weekly mission progress and claims
scripts/tower_pass.gd    Free Tower Pass XP and rewards
scripts/audio_feedback.gd Procedural first-pass sound feedback
scripts/smoke_test.gd    Headless gameplay validation
assets/                  Production art and audio (added incrementally)
docs/                    Game-design and architecture notes
```
