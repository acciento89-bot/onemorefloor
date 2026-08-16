# ONE MORE FLOOR

Mobile hybrid-casual roguelite by **Kamilunavo Games**.

> Climb. Loot. Risk it all. One more floor.

## Core loop

1. Enter a generated floor room.
2. Move, dodge and auto-attack enemies.
3. Clear the room and collect coins and gear.
4. Pick one of three random run upgrades.
5. Cash out or climb one more floor.
6. Spend secured resources, equip/craft gear, complete missions and progress the Tower Pass.

## Tech

- Godot 4.7.1
- GDScript
- Portrait-first mobile UI (720 × 1280 reference canvas)
- iOS / iPadOS and Android targets
- GitHub Actions validation with direct script checks, headless import, main-scene launch and gameplay smoke test

## Current playable slice — v0.7

v0.7 starts moving ONE MORE FLOOR from procedural placeholder rendering to a real external art pipeline while completing the first equipment-material loop.

### External character art pipeline

The current combat roster now has standalone SVG textures under `assets/art/`:

- Wanderer
- Goblin
- Bat
- Skeleton
- Ghoul
- Necromancer
- The Warden
- The Crypt Keeper

`main_v07.gd` loads these imported textures at runtime and uses the older procedural drawing as a fallback if an asset is unavailable. Motion is currently driven by runtime bob/flap/tint effects; multi-frame sprite-sheet animation is still a later production pass.

### Areas and rooms

- **Dungeon** — Floors 1–10
- **Crypt** — Floors 11–20
- **Deep Tower** — reserved routing for Floor 21+

Non-boss floors can roll Combat, Ambush, Elite and Treasure encounters. Crypt rooms keep Soul Mist / Bone Rune hazards and their colder cyan-purple visual language.

### Combat and bosses

- Touch virtual joystick plus WASD / arrow-key desktop fallback
- Auto-targeting projectile attacks
- Critical hits, damage numbers, hit/death effects and screen shake
- Mobile haptics
- NOVA active ability
- Procedural first-pass audio feedback
- Rarity-colored loot beams and room transitions
- **The Warden** as the recurring milestone boss
- **The Crypt Keeper** as the dedicated Floor-20 boss with custom cyan-purple attack patterns

### Permanent progression

- **Hero** — permanent HP and damage training
- **Forge** — permanent weapon-damage upgrades
- **Talents** — Vitality, Precision and Fortune
- **Vault + Forge** — persistent equipment, selection, equip, dismantling and targeted crafting
- **Missions** — daily and weekly contracts
- **Tower Pass** — 20-level free progression track

### Loot, traits, sets and Soul Shards

Equipment uses Common, Uncommon, Rare, Epic and Legendary rarities across Weapon, Armor and Relic slots.

Rare+ equipment can roll Executioner, Frenzy, Bulwark, Vital Core, Vampiric or Fortune traits. Ember, Crypt and Warden sets provide real two-piece and three-piece run bonuses.

v0.7 adds **Soul Shards**:

- Common dismantle: 5 Shards
- Uncommon: 12
- Rare: 30
- Epic: 70
- Legendary: 160
- Craft cost: 120 Shards
- Crafting is slot-targeted: Weapon, Armor or Relic
- Crafted equipment is guaranteed **Rare+**, with a chance for Epic or Legendary
- Equipped items cannot be dismantled accidentally
- Shards persist in the existing save file

### Risk / reward

- Cash out to secure all run coins.
- Continue to push the tower higher.
- Death currently secures 60% of unsecured run coins.
- Camp progression, equipped gear, traits, sets and crafted equipment strengthen future runs.

## Validation

The Godot 4.7.1 CI pipeline validates:

1. Direct parser checks for critical gameplay scripts including `main_v07.gd`.
2. Headless project/editor import with script errors treated as failures.
3. Main-scene runtime launch.
4. Import of all eight external SVG character assets as `Texture2D` resources.
5. Soul Shard dismantling and guaranteed Rare+ crafting.
6. Existing Crypt routing, Treasure rewards, Missions, Tower Pass, Crypt Keeper, standard Warden, equipment bonuses and cash-out.

## Run locally

1. Install Godot 4.7.1 Standard.
2. Import `project.godot`.
3. Press **F5**.
4. Desktop testing: WASD/arrow keys or drag the lower-left joystick area with the mouse.
5. Press **Space** for NOVA.

## Roadmap

### Phase 1 — Playable core
- [x] Project foundation and vertical-slice loop
- [x] Touch movement / auto attack / projectile combat
- [x] Run upgrades and risk/reward decision
- [x] Warden + Crypt Keeper boss encounters
- [x] Haptics and first procedural audio feedback
- [x] Procedural visual baseline
- [x] First external production vector asset pass
- [ ] Multi-frame sprite sheets / authored frame animations
- [ ] Production audio / music

### Phase 2 — Meta progression
- [x] Hero / Forge / Talents
- [x] Persistent Vault and equipment
- [x] Daily / weekly Missions
- [x] Free Tower Pass
- [x] Item traits and set bonuses
- [x] Equipment dismantling / Soul Shards / targeted crafting
- [ ] Item locking, sorting and comparison UI

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
- [x] Combat / Ambush / Elite / Treasure rooms
- [x] Ghoul and Necromancer
- [x] The Crypt Keeper
- [ ] Forgotten Castle
- [ ] More heroes
- [ ] Upgrade synergies and room events

## Repository layout

```text
.github/                  CI validation
scenes/                   Godot scenes
assets/art/               External character/boss SVG textures
scripts/main_v03.gd       Combat/meta controller
scripts/main_v04.gd       Loot/Missions/Tower Pass extension
scripts/main_v05.gd       Crypt/rooms/traits extension
scripts/main_v06.gd       Visual baseline / Crypt Keeper extension
scripts/main_v07.gd       External asset renderer + crafting Vault UI
scripts/progression.gd    Permanent Camp progression and save data
scripts/run_profile.gd    Per-run player/build state
scripts/enemy_factory.gd  Enemy creation, scaling, elites and boss variants
scripts/room_system.gd    Area routing and room generation
scripts/loot_system.gd    Gear, traits, sets, Soul Shards and crafting
scripts/mission_system.gd Daily/weekly mission progress and claims
scripts/tower_pass.gd     Free Tower Pass XP and rewards
scripts/audio_feedback.gd Procedural first-pass sound feedback
scripts/smoke_test.gd     Headless gameplay validation
docs/art-direction.md     Visual north star and production rules
```
