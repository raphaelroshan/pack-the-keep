# P24 Unit-First Combat Visual Verification

## Captured configuration

- Build: `0.18.0-unit-first-combat`
- Window: 1600×900, windowed, default UI scale
- Scene: Greywatch Battle, Distributed Sabotage, paused at deterministic tick 2
- Layout: Pike Squad and Fire Team on the ground floor, Scout Post on the upper floor
- Focus: Raider targeting the damaged Pike Squad while Sapper approaches its demolition contact

## Observed result

- Both keep floors occupy a larger share of the battle surface without colliding with the command rail or assault timeline.
- No cell grid or placement boxes appear during Battle; room boundaries, walls, routes, and the open gate remain readable.
- Room, defender, and enemy health bars are distinct. The Pike Squad bar reflects authoritative contact damage and the Raider bar reflects defender damage.
- The focused Raider target line terminates on the Pike Squad rather than a room. The response panel names the same target and projected Pike/Fire response.
- Pike melee and Fire Team ranged traces render from their board positions toward the attacker, while the Sapper retains a separate approach toward a support-room target.
- Compact board labels no longer carry HP, zone, ammo, or assignment prose. Full details remain available through hover and the inspector.
- The six-tick timeline, next-contact summary, focus rings, and contact telegraph remain inside the board bounds.

## Automated support

`tests/test_p2_ui.gd` verifies enlarged cells, hidden grid state, preparation-only placement guides, health ratios, room hover content, defender readiness cues, target effects, timeline spacing, and read-only presentation invariants. Core tests verify deterministic role selection, retargeting, save/load, damage, and the all-defenders-disabled partial-breach outcome.

## Remaining human check

The P16 matrix remains empty. A human session should confirm that target roles, health loss, room hover details, and the difference between unit hunters and demolition threats are understood during live play at both 1280×720 and 2560×1440.
