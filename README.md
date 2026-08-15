# ONE MORE FLOOR

Mobile hybrid-casual roguelite by **Kamilunavo Games**.

> Climb. Loot. Risk it all. One more floor.

## Core loop

1. Enter a floor.
2. Move, dodge and auto-attack enemies.
3. Clear the floor and collect the loot.
4. Pick one of three random run upgrades.
5. Decide to cash out or climb one more floor.
6. Build permanent progression between runs.

## Tech

- Godot 4.7.1
- GDScript
- Portrait-first mobile UI (720 × 1280 reference canvas)
- iOS / iPadOS and Android targets
- Headless Godot validation workflow in GitHub Actions

## Current playable slice — v0.2

The current branch proves the complete run loop before production art and monetization are added.

### Combat

- Touch virtual joystick
- WASD / arrow-key desktop fallback
- Auto-targeting projectile attacks
- Critical hits
- Damage numbers
- Hit / death effects
- Screen shake
- Mobile haptics
- NOVA active ability that damages enemies and clears hostile projectiles
- Animated coin pickups that fly into the run counter

### Enemies

- **Goblin** — direct melee chaser
- **Bat** — fast wobble movement and low HP
- **Skeleton** — ranged enemy that tries to maintain distance
- **The Warden** — boss every fifth floor with a radial projectile pattern and escorts

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

Each floor rolls three different options from the pool.

### Risk / reward

- Cash out to secure all run coins.
- Continue to push the tower higher.
- Death currently secures only 60% of unsecured run coins.
- Best floor and banked coins persist locally.

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
- [x] First authored boss attack pattern — The Warden
- [x] Basic haptics / combat feedback
- [ ] First audio pass
- [ ] Production sprites and animations

### Phase 2 — Meta progression
- [x] Camp-style home shell
- [ ] Interactive Hero screen
- [ ] Forge
- [ ] Talents
- [ ] Vault
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
.github/    CI validation
scenes/     Godot scenes
scripts/    Gameplay and UI logic
docs/       Game design / architecture notes
assets/     Production art and audio (added incrementally)
```
