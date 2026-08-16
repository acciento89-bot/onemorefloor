# ONE MORE FLOOR

Mobile hybrid-casual roguelite by **Kamilunavo Games**.

> Climb. Loot. Risk it all. One more floor.

## Core loop

1. Enter a generated floor room.
2. Move, dodge and auto-attack enemies.
3. Clear the room and collect coins and gear.
4. Pick one of three random run upgrades.
5. Cash out or climb one more floor.
6. Spend secured resources, compare/equip/craft gear, complete missions and progress the Tower Pass.

## Tech

- Godot 4.7.1
- GDScript
- Portrait-first mobile UI (720 × 1280 reference canvas)
- iOS / iPadOS and Android targets
- GitHub Actions validation with direct script checks, headless import, main-scene launch and gameplay smoke test

## Current playable slice — v0.9

v0.9 expands ONE MORE FLOOR to a third authored area and upgrades combat presentation from state snapshots to multi-frame directional motion.

### Directional motion atlas

`assets/art/motion_atlas.svg` is a **1600 × 1200** external texture with 12 actor rows and mirrored directional frames.

Each actor now has:

- Idle
- Walk 1
- Walk 2
- Walk 3
- Attack 1
- Attack 2
- Hit
- Death
- Right-facing and mirrored left-facing variants

Current rows cover:

- Wanderer
- Goblin
- Bat
- Skeleton
- Ghoul
- Necromancer
- The Warden
- The Crypt Keeper
- Gargoyle
- Royal Sentinel
- Hexer
- The Hollow King

Gameplay events select real sequence frames: movement cycles through three walk frames, attacks alternate two attack frames, incoming damage uses Hit, and death uses a dedicated Death frame. Player facing follows movement and auto-attack target direction.

The v0.8 combat atlas, v0.7 standalone SVGs and v0.6 procedural drawing remain fallback layers.

### Areas

- **Dungeon** — Floors 1–10
- **Crypt** — Floors 11–20
- **Forgotten Castle** — Floors 21–30
- **Deep Tower** — reserved for Floor 31+

### Forgotten Castle

The Castle is not only a visual reskin. It adds its own room treatment, hazards and enemy behaviors.

Hazards:

- **Falling Masonry** — vertical debris salvos across the arena
- **Cursed Banners** — paired red/purple projectile pressure from both walls

Enemy roster:

- **Gargoyle** — closes distance normally, then performs timed high-speed dives
- **Royal Sentinel** — slow armored melee unit with 30% incoming-damage guard
- **Hexer** — ranged triple-shot caster with periodic battlefield blinks
- Skeletons remain as part of the ruined-castle population

### Bosses

- **The Warden** — recurring milestone boss
- **The Crypt Keeper** — dedicated Floor-20 boss
- **The Hollow King** — dedicated Floor-30 boss

The Hollow King has:

- custom gold/red boss presentation
- teleport bursts around the arena
- alternating Crown radial and aimed Fan casts
- denser Phase-II projectile patterns
- Phase II below 55% HP
- dedicated intro and motion-atlas row

### Advanced Vault + Forge

- Item Lock / Unlock
- Locked gear cannot be dismantled
- All / Weapon / Armor / Relic filters
- Rarity / Level / Score sorting
- Persistent sort mode
- Selected-vs-equipped score comparison
- Soul Shard dismantling
- Targeted Rare+ Weapon / Armor / Relic crafting
- Traits and Ember / Crypt / Warden sets

### Permanent progression

- Hero training
- Forge upgrades
- Vitality / Precision / Fortune talents
- Persistent Vault equipment
- Daily / weekly Missions
- 20-level free Tower Pass

## Validation

Godot 4.7.1 CI validates:

1. Direct parser checks through `main_v09.gd`.
2. Headless project/editor import.
3. Main-scene runtime launch.
4. Standalone SVG imports plus v0.8 combat atlas.
5. 1600 × 1200 v0.9 motion-atlas import.
6. Multi-frame motion mapping and left/right player facing.
7. Item locking, filtering, sorting and equipment comparison.
8. Soul Shard dismantling and Rare+ crafting.
9. Dungeon and Crypt regressions.
10. Forgotten Castle routing and Castle enemy pools.
11. Gargoyle / Sentinel / Hexer factory paths.
12. Falling Masonry hazard.
13. Royal Sentinel guard reduction.
14. Floor-30 Hollow King spawn, intro and Phase II.
15. Standard Warden and Crypt Keeper regressions.
16. Missions, Tower Pass, equipment bonuses and cash-out.

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
- [x] Haptics and first procedural audio feedback
- [x] External production vector asset pass
- [x] Multi-state combat atlas
- [x] Higher-frame-count walk / attack sequences
- [x] Directional left/right variants
- [ ] Production audio / music

### Phase 2 — Meta progression
- [x] Hero / Forge / Talents
- [x] Persistent Vault and equipment
- [x] Daily / weekly Missions
- [x] Free Tower Pass
- [x] Item traits and set bonuses
- [x] Equipment dismantling / Soul Shards / targeted crafting
- [x] Item locking, filtering, sorting and comparison UI

### Phase 3 — Release systems
- [ ] Analytics
- [ ] Crash reporting
- [ ] Rewarded ads
- [ ] In-app purchases
- [ ] Leaderboards
- [ ] Cloud save

### Phase 4 — Content
- [x] Dungeon — Floors 1–10
- [x] Crypt — Floors 11–20
- [x] Forgotten Castle — Floors 21–30
- [x] Combat / Ambush / Elite / Treasure rooms
- [x] Ghoul and Necromancer
- [x] Gargoyle / Royal Sentinel / Hexer
- [x] The Warden
- [x] The Crypt Keeper
- [x] The Hollow King
- [ ] Floor 31+ area
- [ ] More heroes
- [ ] Upgrade synergies and room events

## Repository layout

```text
.github/                  CI validation
scenes/                   Godot scenes
assets/art/               Standalone SVGs + combat/motion atlases
scripts/main_v03.gd       Combat/meta controller
scripts/main_v04.gd       Loot/Missions/Tower Pass extension
scripts/main_v05.gd       Crypt/rooms/traits extension
scripts/main_v06.gd       Visual baseline / Crypt Keeper extension
scripts/main_v07.gd       External asset renderer + Soul Shard crafting
scripts/main_v08.gd       Combat atlas state renderer + advanced Vault UX
scripts/main_v09.gd       Forgotten Castle + directional motion + Hollow King
scripts/progression.gd    Permanent Camp progression and save data
scripts/run_profile.gd    Per-run player/build state
scripts/enemy_factory.gd  Enemy creation, scaling, elites and boss variants
scripts/room_system.gd    Area routing, rooms and hazards
scripts/loot_system.gd    Gear, traits, sets, locks, score, Soul Shards and crafting
scripts/mission_system.gd Daily/weekly mission progress and claims
scripts/tower_pass.gd     Free Tower Pass XP and rewards
scripts/audio_feedback.gd Procedural first-pass sound feedback
scripts/smoke_test.gd     Headless gameplay validation
docs/art-direction.md     Visual north star and production rules
```
