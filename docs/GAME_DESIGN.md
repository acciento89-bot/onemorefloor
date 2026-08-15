# ONE MORE FLOOR — Game Design v0.2

## Fantasy

A fast portrait mobile roguelite about pushing an endless dark-fantasy tower one floor further than you should.

## Core promise

Every cleared floor creates a real decision: lock in the loot or risk the run for a stronger build and a higher floor.

## Core loop

1. Enter a compact combat floor.
2. Move and dodge while the Wanderer auto-attacks.
3. Read enemy movement patterns and use NOVA at the right moment.
4. Clear the floor and pull collected coins into the run wallet.
5. Choose one of three random temporary upgrades.
6. Cash out or choose **ONE MORE FLOOR**.
7. Spend secured currency on permanent progression in the camp.

## Combat slice v0.2

The slice still uses procedural graphics so combat feel and balance can be changed cheaply before production sprites are locked.

### Player

- One-thumb virtual joystick
- Automatic target acquisition
- Fast magical blade projectiles
- Critical-hit system
- NOVA active ability
- NOVA damages nearby enemies and destroys hostile projectiles
- Lifesteal, armor, attack speed, movement speed and range can all change during a run

### Enemy roles

**Goblin**
- Simple readable melee pressure
- Moderate HP and speed
- Baseline enemy used to teach movement

**Bat**
- Fast and fragile
- Wobbling approach vector makes movement less predictable
- Intended to punish standing still

**Skeleton**
- Ranged pressure unit
- Attempts to stay at medium range
- Fires aimed projectiles
- Forces the player to move instead of simply kiting one direction

**The Warden**
- Boss on every fifth floor in the current prototype
- Large health pool
- Contact threat
- Periodic radial projectile burst
- Later versions should add telegraphs, phase transitions and a signature melee attack

## Upgrade pool

Each cleared floor offers three distinct random choices from the current ten-upgrade pool.

| Upgrade | Effect |
| --- | --- |
| Power Surge | +25% attack damage |
| Blood Pact | +5% lifesteal |
| Multishot | +1 projectile / target |
| Quick Hands | +18% attack speed |
| Long Reach | +22% attack range |
| Iron Heart | +25 max HP and heal |
| Swift Boots | +12% movement speed |
| Deadly Edge | +8% critical chance |
| Nova Core | +25% NOVA damage and radius |
| Warden's Plate | +8% damage reduction |

The next upgrade-system milestone is rarity tiers plus explicit synergies so players can intentionally chase builds instead of only stacking raw stats.

## Risk and reward

- Cash out: secure 100% of the current run wallet.
- Continue: keep all loot unsecured and enter the next floor.
- Death: currently banks 60% of unsecured coins.
- Best floor persists locally.

The exact death-retention percentage is a tuning value, not a final economy decision.

## Feedback layer

Current feedback systems:

- Damage numbers
- Larger critical-hit callouts
- Projectile trails
- Hit bursts
- Death bursts
- Animated coin pickups
- Screen shake
- Handheld vibration / haptics
- Floor intro banner

Audio is intentionally the next feedback layer, rather than being mixed into the first combat implementation.

## Initial balancing targets

- Standard floor: 20–45 seconds
- Boss floor: 45–75 seconds
- First meaningful build synergy: by floor 4–6
- Typical first-session run: 5–10 minutes
- Boss should be readable before it is difficult
- No mandatory ad interruption inside a run

## Art direction

Dark fantasy with modern mobile-game readability:

- Deep navy / purple world tones
- Warm gold interaction accents
- Bright ability colors
- Chunky readable silhouettes
- Strong enemy color coding
- Minimal text during combat
- Strong contrast for one-handed portrait play

The approved concept uses a premium dark-fantasy camp, gold-framed UI, purple magical accents and a small heroic Wanderer character.

## Meta progression direction

The home screen is already shaped like the future camp shell. Planned interactive areas:

1. Hero — level, stats, cosmetics and hero selection
2. Forge — weapon upgrades
3. Talents — permanent account-wide modifiers
4. Vault — equipment and collected relics
5. Missions — daily / weekly objectives
6. Leaderboard — highest-floor competition
7. Tower Pass — seasonal progression only after the core retention loop is proven

## Monetization guardrails

Monetization comes after retention and combat quality.

Preferred direction:

- Optional rewarded ads for revive / bonus rewards
- Remove-ads purchase
- Cosmetic and convenience purchases
- Season pass only when live content exists
- Avoid mandatory interstitials during active runs
- Avoid paid random loot boxes in the first release

## Next production milestone — v0.3

1. Validate v0.2 in Godot and on a phone
2. Split the monolithic prototype into player / enemies / run / UI systems
3. Add first production Wanderer sprite and animation set
4. Add production Goblin / Bat / Skeleton sprites
5. Add Warden telegraphs and second boss phase
6. Add first sound and music pass
7. Make Hero / Forge / Talents camp buttons interactive
8. Add permanent upgrade prototype
