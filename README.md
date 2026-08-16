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

## Current playable slice — v0.8

v0.8 turns the v0.7 external art pipeline into an authored combat-animation layer and upgrades the Vault from a simple equipment list into a practical build-management screen.

### Combat animation atlas

`assets/art/combat_atlas.svg` is a 500 × 800 external texture containing 40 authored combat cells:

- 8 actor rows: Wanderer, Goblin, Bat, Skeleton, Ghoul, Necromancer, Warden and Crypt Keeper
- 5 states per actor: **Idle, Move, Attack, Hit and Death**

`main_v08.gd` selects atlas regions at runtime using gameplay state instead of relying only on static textures.

Animation events now react to actual combat:

- Player movement switches between Idle / Move.
- Auto-attack triggers Attack.
- NOVA uses the attack frame plus its own cyan skill treatment.
- Player damage triggers Hit.
- Enemy damage triggers Hit.
- Recent contact/ranged/boss casts trigger Attack.
- Enemy death creates a short Death-frame actor effect before disappearing.
- The Game Over screen uses the Wanderer Death frame.
- Elite, rage and boss Phase-II effects remain layered over the animated actors.

The original v0.7 standalone SVGs and v0.6 procedural drawing remain available as fallback paths.

### Areas and bosses

- **Dungeon** — Floors 1–10
- **Crypt** — Floors 11–20
- **Deep Tower** — reserved routing for Floor 21+

Current bosses:

- **The Warden** — recurring milestone boss with telegraphs and Phase II
- **The Crypt Keeper** — dedicated Floor-20 boss with cyan-purple radial and fan patterns

### Advanced Vault + Forge

v0.8 adds safer and faster gear management:

- Item **Lock / Unlock**
- Locked gear cannot be dismantled
- Filters: **All / Weapon / Armor / Relic**
- Sort modes: **Rarity / Level / Score**
- Persistent chosen sort mode
- Item score derived from rarity, level, primary stats, trait and set presence
- Selected-vs-equipped comparison panel
- Live score delta for the selected slot
- Explicit Equip and Dismantle actions
- Paging for filtered inventory views
- Existing targeted Weapon / Armor / Relic crafting remains available

### Loot economy

Equipment uses Common, Uncommon, Rare, Epic and Legendary rarities.

Soul Shard dismantle values:

- Common: 5
- Uncommon: 12
- Rare: 30
- Epic: 70
- Legendary: 160

Crafting costs 120 Soul Shards and guarantees Rare+ gear.

Rare+ items can roll Executioner, Frenzy, Bulwark, Vital Core, Vampiric or Fortune traits. Ember, Crypt and Warden sets provide real two-piece and three-piece run bonuses.

### Permanent progression

- Hero training
- Forge upgrades
- Vitality / Precision / Fortune talents
- Persistent Vault equipment
- Daily / weekly Missions
- 20-level free Tower Pass

## Validation

The Godot 4.7.1 CI pipeline validates:

1. Direct parser checks through the active `main_v08.gd` controller.
2. Headless project/editor import with script errors treated as failures.
3. Main-scene runtime launch.
4. All standalone SVG character imports.
5. The 500 × 800 combat atlas import.
6. Item locking and locked-item dismantle protection.
7. Slot filtering, score sorting and selected-vs-equipped comparison.
8. Soul Shard dismantling and guaranteed Rare+ crafting.
9. Player Attack / Hit / NOVA animation state triggers.
10. Enemy Hit and Death animation event paths.
11. Existing Crypt routing, Treasure rewards, Missions, Tower Pass, Crypt Keeper, standard Warden, equipment bonuses and cash-out regressions.

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
- [x] External production vector asset pass
- [x] Multi-state combat atlas with Idle / Move / Attack / Hit / Death
- [ ] Higher-frame-count walk / attack sequences and directional variants
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
- [x] Dungeon area prototype
- [x] Crypt area prototype
- [x] Combat / Ambush / Elite / Treasure rooms
- [x] Ghoul and Necromancer
- [x] The Crypt Keeper
- [ ] Forgotten Castle — Floors 21–30
- [ ] More heroes
- [ ] Third authored boss
- [ ] Upgrade synergies and room events

## Repository layout

```text
.github/                  CI validation
scenes/                   Godot scenes
assets/art/               Standalone SVGs + combat animation atlas
scripts/main_v03.gd       Combat/meta controller
scripts/main_v04.gd       Loot/Missions/Tower Pass extension
scripts/main_v05.gd       Crypt/rooms/traits extension
scripts/main_v06.gd       Visual baseline / Crypt Keeper extension
scripts/main_v07.gd       External asset renderer + Soul Shard crafting
scripts/main_v08.gd       Combat atlas state renderer + advanced Vault UX
scripts/progression.gd    Permanent Camp progression and save data
scripts/run_profile.gd    Per-run player/build state
scripts/enemy_factory.gd  Enemy creation, scaling, elites and boss variants
scripts/room_system.gd    Area routing and room generation
scripts/loot_system.gd    Gear, traits, sets, locks, score, Soul Shards and crafting
scripts/mission_system.gd Daily/weekly mission progress and claims
scripts/tower_pass.gd     Free Tower Pass XP and rewards
scripts/audio_feedback.gd Procedural first-pass sound feedback
scripts/smoke_test.gd     Headless gameplay validation
docs/art-direction.md     Visual north star and production rules
```
