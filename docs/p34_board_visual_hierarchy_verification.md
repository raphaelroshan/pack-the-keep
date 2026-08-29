# P34 Board Visual Hierarchy Verification

- Build: `0.22.0-board-hierarchy`
- Local render: Godot 4.7.2, macOS, 1600×900 at 100% scale
- Captures: ordinary Preparation and the opening Battle frame
- Scope: presentation inspection only; this is not human playtest evidence

## Preparation

- Ground and upper floors use separate header plates, frame colors, surfaces, and landmarks while retaining the existing two-board geometry.
- Greywatch reads as a warm stone wall ring and courtyard; the upper floor reads as a cooler raised wall walk with posts and corner caps.
- Critical rooms have a gold edge strip and diamond marker, while non-critical rooms retain a teal structural accent.
- Defender footprints remain spatially explicit, but dark cards, role-colored edges, role-family badges, piece glyphs, and health bars create a clearer actor layer than the previous flat color blocks.
- The P33 tactical brief, primary Begin Assault action, and both fortress floors remain visible in the first viewport.

## Battle

- Raider chevrons are visibly different from Sapper diamonds, Climber claws, armored shields, ranged rings, breaker axes, and the larger Siege Beast hex silhouette.
- Enemy initials remain a secondary redundant cue; health, cadence, focus rings, target lines, contact warnings, damage trails, and the assault timeline remain above the structural layers.
- The same silhouette grammar is reused in the assault timeline.
- No placement, hit-test, route, target, or timing coordinate changed.

## State and accessibility boundary

- The registry declares the structural-to-tactical layer order and stable floor/actor profiles.
- Board profile inspection and redraw leave serialized keep state unchanged.
- High contrast strengthens board frames without changing geometry.
- Existing scaling, controller, pause, speed, and save behavior remain covered by the full verification suite.

Human at-a-glance recognition and aesthetic preference remain pending structured playtest evidence.

