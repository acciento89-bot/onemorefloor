# ONE MORE FLOOR — Production 3D Actor Slots

The actor pipeline can load optional rigged `.glb` actor scenes from this folder. If a file is absent or invalid, the self-contained native production actor stays active automatically. The repository deliberately does not fabricate placeholder GLB binaries.

Expected filenames:

- `wanderer.glb`
- `goblin.glb`
- `bat.glb`
- `skeleton.glb`
- `ghoul.glb`
- `necromancer.glb`
- `warden.glb`

## v1.47 production import contract

Each GLB should import as a `Node3D` / `PackedScene` with visible mesh geometry. A production-ready asset should contain a `Skeleton3D` plus either an `AnimationPlayer` or an `AnimationTree` state machine.

Required animation states for the main production contract are:

- `Idle`
- `Run`
- `Attack`

Recommended states are:

- `Hit`
- `Skill` where applicable
- `Spawn`
- `Death`

The registry accepts common aliases such as lowercase names, `Jog`, `Locomotion`, `Slash`, `MeleeAttack`, `HitReact`, `Cast`, `Summon`, `Die`, and `Death01`.

## Socket contract

v1.47 exposes stable logical sockets even while native fallback art is active. Imported models may provide matching nodes/bones so VFX and equipment can follow the real rig later without changing combat code.

Preferred logical socket names / aliases:

- weapon: `WeaponSocket`, `hand_r`, `Hand_R`, `RightHand`, `Weapon_R`
- offhand: `OffhandSocket`, `hand_l`, `Hand_L`, `LeftHand`, `ShieldSocket`
- head: `HeadSocket`, `Head`, `Bip01_Head`
- chest: `ChestSocket`, `Chest`, `Spine2`, `spine_03`, `UpperChest`
- feet/root: `FeetSocket`, `Root`, `Hips`
- overhead: `OverheadSocket`, `UI_Overhead`, `NameplateSocket`
- VFX: `VFXSocket`, `FXSocket`, `EffectSocket`, `Spine`

The runtime always creates its own stable `ProductionSockets` layer. If a matching imported node exists, the production socket follows that target. Missing imported sockets fall back to safe actor-local positions instead of breaking the character.

## Runtime mounting

The imported model scene is mounted below:

`Motion/RigMount/ImportedModel`

Position, actor scale, facing, contact shadows, combat telegraphs, hit flashes, projectiles, rewards, economy, saves and gameplay authority remain outside the imported model.

Do not bake gameplay collision, rewards, enemy AI, progression or save logic into model files. Those systems remain owned by the tested runtime.

## Art target

The intended production direction is stylized premium mobile action-RPG art: strong top-down silhouette, readable weapons and attack poses, restrained materials, clean emissive accents and animation that remains legible under the fixed angled camera. Avoid tiny detail that disappears at gameplay scale.
