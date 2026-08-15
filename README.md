# ONE MORE FLOOR

Mobile hybrid-casual roguelite by **Kamilunavo Games**.

> Climb. Loot. Risk it all. One more floor.

## Core loop

1. Enter a floor.
2. Move, dodge and auto-attack enemies.
3. Clear the floor.
4. Pick one of three run upgrades.
5. Decide to cash out or climb one more floor.
6. Build permanent progression between runs.

## Tech

- Godot 4.7.1
- GDScript
- Portrait-first mobile UI
- iOS / iPadOS and Android targets

## First milestone: Vertical Slice

The first playable slice focuses on the complete moment-to-moment loop before production art and monetization are added:

- Home screen
- Touch movement / virtual joystick
- Auto attack
- Enemy waves
- Floor progression
- Upgrade choice
- Cash-out vs. continue decision
- Local best-floor persistence

## Run locally

1. Install Godot 4.7.1 Standard.
2. Import `project.godot`.
3. Press **F6/F5** to run.
4. On desktop, use WASD/arrow keys or drag the lower-left joystick area with the mouse.

## Roadmap

### Phase 1 — Playable core
- [x] Project foundation
- [x] First vertical-slice loop
- [x] Touch movement / auto attack
- [x] Upgrade choice
- [x] Risk / reward decision
- [ ] First authored boss attack pattern
- [ ] Basic audio / haptics

### Phase 2 — Meta progression
- [ ] Camp screen
- [ ] Hero screen
- [ ] Forge
- [ ] Talents
- [ ] Vault
- [ ] Missions

### Phase 3 — Release systems
- [ ] Analytics
- [ ] Crash reporting
- [ ] Rewarded ads
- [ ] In-app purchases
- [ ] Leaderboards
- [ ] Cloud save

### Phase 4 — Content
- [ ] Dungeon
- [ ] Crypt
- [ ] Forgotten Castle
- [ ] More heroes, enemies, bosses and upgrades

## Repository layout

```text
scenes/     Godot scenes
scripts/    Gameplay and UI logic
docs/       Game design / architecture notes
assets/     Production art and audio (added incrementally)
```
