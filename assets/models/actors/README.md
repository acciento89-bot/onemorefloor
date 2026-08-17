# ONE MORE FLOOR — Production 3D Actor Slots

The v1.42 runtime can load optional rigged `.glb` actor scenes from this folder. If a file is absent or invalid, the existing native production actor remains active automatically.

Expected filenames:

- `wanderer.glb`
- `goblin.glb`
- `bat.glb`
- `skeleton.glb`
- `ghoul.glb`
- `necromancer.glb`
- `warden.glb`

## Import contract

Each GLB should import as a `Node3D`/`PackedScene`. A `Skeleton3D` is recommended. Animation can be driven through an `AnimationPlayer` or an `AnimationTree` with a state-machine playback node.

Preferred animation state names are `Idle`, `Run`, `Attack`, `Hit`, and `Skill`. The registry also accepts common aliases such as lowercase names, `Jog`, `Slash`, `HitReact`, and `Cast`.

The model scene is mounted under the existing runtime actor root at `Motion/RigMount/ImportedModel`. Position, enemy scale, facing, contact shadows, attack tells, hit flashes, projectiles, rewards and all gameplay authority remain outside the imported model.

Do not bake gameplay collision, rewards, enemy AI, or progression into the model files. Those systems remain owned by the tested runtime.
