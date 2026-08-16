# ONE MORE FLOOR

Mobile hybrid-casual roguelite by **Kamilunavo Games**.

> Climb. Loot. Risk it all. One more floor.

## Core loop

1. Enter a generated floor room.
2. Move, dodge and auto-attack enemies.
3. Clear the room and collect coins and possible gear.
4. Pick one of three random run upgrades.
5. Decide to cash out or climb one more floor.
6. Spend secured coins, equip loot, complete missions and progress the Tower Pass.

## Tech

- Godot 4.7.1
- GDScript
- Portrait-first mobile UI (720 × 1280 reference canvas)
- iOS / iPadOS and Android targets
- GitHub Actions validation with direct script checks, headless project load, main-scene launch and gameplay smoke test

## Current playable slice — v0.6

v0.6 is the first dedicated visual-production pass. It keeps the verified v0.5 gameplay systems and replaces the flat prototype presentation with a stronger procedural art baseline that can later be swapped for external sprite sheets without changing gameplay architecture.

### Visual production baseline

- Reworked **Wanderer** silhouette with cape, armor, face, shadow and directional sword presentation.
- Reworked Goblin, Bat, Skeleton, Ghoul, Necromancer and Warden presentation.
- Animated bob/flap/aura details that make roles more readable during motion.
- Soft character shadows to separate units from the floor.
- Brighter player projectiles, critical trails, enemy-orb pulses and coin glows.
- Rarity-colored vertical **loot beams** with orbiting sparks.
- Stronger NOVA / boss-cast visual hierarchy.
- Dungeon torch pillars, Crypt bone pillars, floor patterning and area-specific rune details.
- Animated room-transition overlay between floors.
- Compact room-type badge and refreshed combat HUD.
- Shared art-direction document at `docs/art-direction.md`.

### Areas and rooms

- **Dungeon** — Floors 1–10
- **Crypt** — Floors 11–20
- **Deep Tower** — reserved routing for Floor 21+

Non-boss floors can roll Combat, Ambush, Elite and Treasure encounters. Boss rooms remain milestone encounters every fifth floor.

Crypt rooms include Soul Mist / Bone Rune hazards and a colder cyan-purple environment language distinct from the warm Dungeon.

### Combat and enemies

- Touch virtual joystick plus WASD / arrow-key desktop fallback
- Auto-targeting projectile attacks
- Critical hits, damage numbers, hit/death effects and screen shake
- Mobile haptics
- NOVA active ability that damages enemies and clears hostile projectiles
- Procedural first-pass audio feedback

Enemy roster:

- **Goblin** — melee chaser
- **Bat** — fast wobble movement
- **Skeleton** — ranged kiter
- **Ghoul** — durable melee enemy that enrages below 40% HP
- **Necromancer** — ranged Crypt caster that can summon weakened Skeletons
- **The Warden** — recurring milestone boss with telegraphs and Phase II
- **The Crypt Keeper** — dedicated Floor-20 boss with a unique cold-blue silhouette and custom projectile patterns

### Boss progression

The Warden remains the recurring early-tower boss. Floor 20 now replaces the standard Warden encounter with **The Crypt Keeper**:

- unique factory variant and visuals
- dedicated intro presentation
- stronger base HP / contact pressure
- custom cyan-purple radial pattern
- custom aimed fan pattern
- Phase II still uses the existing telegraph / transition framework

### Run building

Ten temporary run upgrades remain available, including Power Surge, Blood Pact, Multishot, Quick Hands, Deadly Edge and Nova Core. Each cleared floor rolls three choices.

Room clears can also grant room-specific coin and Tower Pass XP bonuses.

### Permanent Camp progression

- **Hero** — permanent HP and damage training
- **Forge** — permanent weapon-damage upgrades
- **Talents** — Vitality, Precision and Fortune
- **Vault** — persistent equipment inventory and tap-to-equip UI
- **Missions** — daily and weekly contracts
- **Tower Pass** — 20-level free progression track

### Loot, traits and sets

Equipment has Common, Uncommon, Rare, Epic and Legendary rarity tiers across Weapon, Armor and Relic slots.

Rare+ equipment can roll Executioner, Frenzy, Bulwark, Vital Core, Vampiric or Fortune traits. Equipment can belong to Ember, Crypt or Warden sets with real two-piece and three-piece run bonuses.

### Risk / reward

- Cash out to secure all run coins.
- Continue to push the tower higher.
- Death currently secures 60% of unsecured run coins.
- Camp progression, equipped gear, traits and set bonuses strengthen future runs.

## Validation

The Godot 4.7.1 CI pipeline validates:

1. Direct parser checks for critical gameplay scripts including the active v0.6 controller.
2. Headless project/editor load with logged script errors treated as failures.
3. Main-scene launch with logged script errors treated as failures.
4. Gameplay smoke test covering permanent upgrades, Warden loot, three-piece Crypt equipment bonuses, Ghoul / Necromancer creation, Crypt Floor 11 routing, room transition state, Treasure rewards, Missions, Tower Pass, Floor-20 Crypt Keeper, standard Floor-5 Warden, boss Phase II and cash-out.

## Run locally

1. Install Godot 4.7.1 Standard.
2. Import `project.godot`.
3. Press **F5** to run the project.
4. On desktop, use WASD/arrow keys or drag the lower-left joystick area with the mouse.
5. Press **Space** to trigger NOVA while testing on desktop.

## Roadmap

### Phase 1 — Playable core
- [x] Project foundation and vertical-slice loop
- [x] Touch movement / auto attack / projectile combat
- [x] Run upgrades and risk/reward decision
- [x] Warden boss with telegraphs and Phase II
- [x] Haptics and first procedural audio-feedback pass
- [x] Procedural visual-production baseline
- [ ] External production sprite sheets / frame animations
- [ ] Production audio / music

### Phase 2 — Meta progression
- [x] Hero / Forge / Talents
- [x] Persistent Vault and equipment
- [x] Daily / weekly Missions
- [x] Free Tower Pass
- [x] Item traits and set bonuses
- [ ] Equipment dismantling / crafting

### Phase 3 — Release systems
- [ ] Analytics
- [ ] Crash reporting
- [ ] Rewarded ads
- [ ] In-app purchases
- [ ] Leaderboards
- [ ] Cloud save

### Phase 4 — Content
- [x] Dungeon area prototype
- [x] Crypt area prototype
- [x] Combat / Ambush / Elite / Treasure room roles
- [x] Ghoul and Necromancer
- [x] Second authored boss: The Crypt Keeper
- [ ] Forgotten Castle
- [ ] More heroes
- [ ] Upgrade synergies and room events

## Repository layout

```text
.github/                  CI validation
scenes/                   Godot scenes
scripts/main_v03.gd       Verified combat/meta controller
scripts/main_v04.gd       Loot/Missions/Tower Pass extension
scripts/main_v05.gd       Crypt/rooms/traits content extension
scripts/main_v06.gd       Active visual-production / Crypt Keeper extension
scripts/progression.gd    Permanent Camp progression and save data
scripts/run_profile.gd    Per-run player/build state
scripts/enemy_factory.gd  Enemy creation, scaling, elites and boss variants
scripts/room_system.gd    Area routing and room generation
scripts/loot_system.gd    Persistent gear, traits and set bonuses
scripts/mission_system.gd Daily/weekly mission progress and claims
scripts/tower_pass.gd     Free Tower Pass XP and rewards
scripts/audio_feedback.gd Procedural first-pass sound feedback
scripts/smoke_test.gd     Headless gameplay validation
assets/                   External production art/audio target
scripts/                   Runtime gameplay/UI code
docs/art-direction.md     Visual north star and production rules
```