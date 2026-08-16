# ONE MORE FLOOR — Art Direction

## North star

ONE MORE FLOOR should read instantly on a phone: dark fantasy atmosphere, bright combat readability and a premium hybrid-casual finish. The game should feel mysterious rather than grim, colorful rather than muddy, and readable during fast one-thumb play.

## Visual pillars

1. **Readable silhouettes** — every enemy role must be recognizable before the player reads a name.
2. **Dark world, bright gameplay** — floors stay dark and desaturated; attacks, loot, skills and interactable rewards use saturated accents.
3. **Compact animation** — short anticipation, impact and recovery beats. Avoid slow cinematic motion during normal runs.
4. **Reward glow** — coins, rare loot, upgrades and boss clears get stronger light, particles and motion than normal combat.
5. **Area identity** — each ten-floor region changes palette, architecture, props, hazards and enemy mix.

## Core palette

- Background navy: `#07101F`
- Panel navy: `#171C38`
- Gold reward: `#F1B84B`
- Arcane purple: `#9A5CFF`
- Skill cyan: `#62E6FF`
- Danger red: `#FF5F69`
- Success green: `#67E58E`
- Warm dungeon orange: `#FF9B52`

## Area direction

### Dungeon — Floors 1–10

Warm torchlight, dark stone, iron, worn wood and gold reward accents. Architecture is chunky and readable with broad pillars and simple floor blocks. The environment should never overpower enemy silhouettes.

### Crypt — Floors 11–20

Cold blue-violet stone, bone details, pale cyan magic, purple soul mist and circular rune motifs. Crypt combat should feel colder and more supernatural than the Dungeon while preserving the same HUD language.

## Character language

### Wanderer

Compact heroic silhouette, dark cape, muted blue armor and a bright gold-edged weapon. The sword is the main directional cue during auto-attacks. Animation target: idle bob, walk cycle, attack anticipation, slash, hit reaction and death.

### Goblin

Wide ears, low center of gravity, yellow eyes and green skin. Reads as the basic melee pursuer.

### Bat

Wide animated wings and tiny core body. Movement and wing flap should communicate speed even before positional motion is considered.

### Skeleton

Bright bone silhouette with visible bow/staff-shaped ranged cue. Thin body makes it visually distinct from melee units.

### Ghoul

Broader and heavier than the Goblin. Sick green normally; red aura and warmer skin when enraged below 40% HP.

### Necromancer

Tall triangular robe, skull/pale face, staff orb and purple orbiting magic. Must read as a caster from a distance.

### The Warden

Heavy dark armor, gold crown silhouette, red eyes and purple/red phase aura. Phase II should be obvious without reading text.

### The Crypt Keeper

Floor-20 guardian. Larger cold-blue armor silhouette, cyan crown/spikes, cyan eyes, dual bone-like arm blades and two counter-rotating magic auras. It must not look like a palette-swapped Warden.

## Combat VFX hierarchy

- Normal player projectile: cyan core + short glow trail.
- Critical projectile: gold trail, thicker core and stronger impact.
- Enemy projectile: readable colored orb with soft outer pulse.
- NOVA: large cyan expanding ring.
- Boss cast: large telegraph first, projectile pattern second.
- Loot drop: vertical rarity-colored beam plus orbiting sparks.
- Coin: gold pulse with bright central mark.

## UI

HUD stays dark and compact. Gold communicates economy/reward, cyan player power, purple progression/arcane systems and red danger/health. Do not introduce new colors without a gameplay reason.

## Animation production target

When external sprite sheets replace the procedural v0.6 art, preserve the existing gameplay hitboxes and role silhouettes. Recommended minimum clips per combat character:

- Idle: 4–6 frames
- Move: 6–8 frames
- Attack: 6–8 frames
- Hit: 3–4 frames
- Death: 6–10 frames

Bosses additionally need cast anticipation, phase transition and signature attack clips.

## Rule for future content

A new enemy, boss, room or area is not visually complete until it has: a unique silhouette, one dominant accent color, a clear combat cue, hit/death feedback and a readable relationship to its area palette.
