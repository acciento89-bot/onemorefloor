# ONE MORE FLOOR

Mobile portrait roguelite by **Kamilunavo Games**.

> Climb. Loot. Risk it all. One more floor.

## Current milestone — v1.2.0-rc1

ONE MORE FLOOR is in real-device TestFlight iteration. v1.2 is the first **production-art integration pass**: the gameplay/save/audio systems from v1.1 remain intact while the player-facing presentation is moved toward the established dark-fantasy concept direction.

### Core loop

1. Enter a generated floor room.
2. Move, dodge and auto-attack.
3. Clear enemies and collect coins / gear.
4. Choose one of three run upgrades.
5. Cash out or climb one more floor.
6. Spend permanent resources, equip/craft gear, complete Missions and progress the Tower Pass.

### Areas and bosses

- **Dungeon** — Floors 1–10 — The Warden
- **Crypt** — Floors 11–20 — The Crypt Keeper
- **Forgotten Castle** — Floors 21–30 — The Hollow King

Roster: Goblin, Bat, Skeleton, Ghoul, Necromancer, Gargoyle, Royal Sentinel and Hexer plus the three bosses. Rooms can roll Combat, Ambush, Elite and Treasure encounters with area-specific hazards.

## v1.2 production fantasy presentation

The active controller is `scripts/main_v12.gd`, layered on the stable v1.1 responsive/mobile controller.

### Visual language

- Dark stone / midnight-blue surfaces.
- Gold ornamental trim and beveled fantasy panels.
- Purple crystal / arcane accents with biome-specific color identities.
- New icon medallions for Hero, Forge, Talents, Vault, Missions, Pass, equipment and run upgrades.
- Player-facing development/version overlays remain removed.
- Existing touch hitboxes and gameplay coordinates stay stable underneath the new skin.

### Character and enemy presentation

`assets/art/fantasy_actor_atlas.svg` is a new 1600 × 1200 production-style vector actor atlas covering:

- Wanderer
- Goblin
- Bat
- Skeleton
- Ghoul
- Necromancer
- Warden
- Crypt Keeper
- Gargoyle
- Royal Sentinel
- Hexer
- Hollow King

The renderer keeps the existing directional/state hooks, hit/death handling, boss phase effects, elite treatment and combat logic. This pass establishes the final visual language and asset replacement path; fully hand-authored high-frame-count character animation can replace the same hooks later without rewriting gameplay.

### Biome presentation

`assets/art/fantasy_biomes.svg` is a 2592 × 840 four-room atlas with authored arena treatments for:

- Dungeon
- Crypt
- Forgotten Castle
- Deep Tower fallback

The rooms include stone architecture, gates, pillars, torch/crystal lighting, banners and magic-circle treatment. Dynamic Treasure/Ambush/Elite elements are still drawn by gameplay code.

### Rebuilt player-facing screens

v1.2 replaces the visible presentation for:

- Home / tower entrance
- Hero
- Forge
- Talents
- Vault + Forge inventory/crafting
- Missions
- Tower Pass
- Combat HUD
- Upgrade choice
- Cash-out / One More Floor decision
- Game Over
- Pause
- Settings
- Tutorial

The visual layer uses reusable fantasy panels/buttons, coins, gems, medallions and icons instead of the prototype rectangle-heavy presentation.

## Responsive mobile presentation

- `canvas_items + expand` for tall phones and tablets.
- 720 × 1280 gameplay design coordinates remain stable inside the expanded viewport.
- Safe-area-aware presentation on iOS / Android.
- Touch coordinates translate back into stable gameplay coordinates.
- Immersive iOS portrait configuration remains enabled.

## Adaptive audio

Five separate music contexts continue from v1.1:

- Menu
- Dungeon
- Crypt
- Forgotten Castle
- Boss

`release_audio.gd` crossfades between contexts and respects Music/SFX settings. Imported SFX remain available for menu click, attack/hit, loot/reward, NOVA and boss/phase events.

## Release/playtest systems

- Pause / Resume
- Settings from Home and Pause
- Music / SFX / Haptics toggles
- Analytics opt-in; OFF by default
- First-launch Tutorial / Onboarding
- Local unclean-session recovery marker
- Save format v2 with additive migration
- Existing Loot / Missions / Tower Pass data preserved
- Release balance profile for Floors 1–30
- iOS + Android export presets
- Current project metadata: `1.2.0-rc1`
- iOS playtest version: `1.2.0`, build `3`
- Android playtest version: `1.2.0`, code `3`

## Gear and permanent progression

- Hero / Forge / Vitality / Precision / Fortune progression
- Weapon / Armor / Relic slots
- Common → Legendary rarity
- Traits and Ember / Crypt / Warden sets
- Soul Shard dismantling
- Targeted Rare+ crafting
- Lock / Unlock
- All / Weapon / Armor / Relic filters
- Rarity / Level / Score sorting
- Selected-vs-equipped comparison
- Daily / weekly Missions
- 20-level free Tower Pass

## Validation

Godot 4.7.1 CI validates:

1. Critical parser checks through `main_v12.gd` and release helpers.
2. Headless project/editor import, including the new fantasy SVG atlases.
3. Main-scene boot.
4. Full gameplay regression through Floor 30.
5. Loot, Vault, crafting, Missions and Tower Pass regressions.
6. Dungeon, Crypt and Forgotten Castle routing/hazards.
7. Warden, Crypt Keeper and Hollow King regressions.
8. Save/settings/tutorial/telemetry release regressions.
9. v1.1 responsive layout and five-context audio regression.
10. v1.2 active-controller, atlas-dimension, production-screen and mobile-version regression.
11. macOS Godot → Xcode export and unsigned ARM64 `iphoneos` device compilation on branches/PRs.
12. Signed archive and TestFlight upload only from `main` when App Store Connect credentials are present.

## Run locally

1. Install Godot 4.7.1 Standard.
2. Import `project.godot`.
3. Press **F5**.
4. Desktop: WASD / arrows or drag the virtual joystick with the mouse.
5. **Space** = NOVA.
6. **P / Escape** = Pause / Resume.

## Repository layout

```text
.github/                       CI + iOS/TestFlight validation
scenes/main.tscn               active game scene
assets/art/fantasy_actor_atlas.svg
assets/art/fantasy_biomes.svg
assets/art/motion_atlas.svg    previous motion fallback
assets/audio/                  imported playtest SFX
scripts/main_v03.gd            combat/meta controller
scripts/main_v04.gd            Loot/Missions/Tower Pass
scripts/main_v05.gd            rooms/Crypt/traits
scripts/main_v06.gd            visual baseline/Crypt Keeper
scripts/main_v07.gd            external asset renderer/crafting
scripts/main_v08.gd            combat atlas/advanced Vault
scripts/main_v09.gd            Forgotten Castle/Hollow King/motion
scripts/main_v10.gd            release settings/tutorial/save layer
scripts/main_v11.gd            responsive layout/adaptive audio
scripts/main_v12.gd            production fantasy presentation
scripts/v12_smoke_test.gd      v1.2 visual/mobile regression
```

## Next art milestones

- Real-device v1.2 visual review on iPhone/iPad.
- Refine scale/spacing/readability from screenshots.
- Expand actor atlas from the production-style baseline into richer frame-by-frame animation.
- Add higher-detail item artwork, reward chest variants and boss presentation.
- Final mastered music/SFX mix.
