# v1.58 TestFlight screenshot findings

The v1.57 device screenshots exposed three concrete presentation regressions:

- Home: oversized gate masses and black slabs dominate the center, hiding the Wanderer behind the Play button.
- Hero: the Wanderer sits too low and is mostly covered by the stats card; the arch/column treatment consumes the available portrait space.
- Forge: large left/right masses clip outside the visible frame and the useful forge props are obscured by the UI card.

v1.58 addresses these by moving all large architecture behind z=-2.8, widening the camera, lifting/scaling down the showcase Wanderer, and keeping Forge props on the rear wall.
