# ONE MORE FLOOR v1.37 Release Candidate

Target TestFlight: 1.26.0 (23)

This pass is intentionally release hardening only:
- active runtime `main_v50.gd`
- 60 fps mobile cap
- lifecycle checkpoint save + last-known-good backup on application pause
- critical 720x1280 touch geometry validation
- Store/reward requests fail closed in non-debug builds until a native provider is connected
- decorative fullscreen ambience reduced to 15 fps redraw
- graphics-pack overlay reduced to 30 fps redraw
- TestFlight workflow validates marketing/build metadata before export

No combat balance, progression rewards, save schema, economy values, collision, or new gameplay mechanics are introduced by this pass.
