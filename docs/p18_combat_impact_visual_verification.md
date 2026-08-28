# P18 Combat Impact Visual Verification

## Scope

Verify that a live assault communicates approach, defender response, and enemy impact without hiding the fort or implying continuous authoritative damage.

## Captures reviewed

- 1600×900 melee exchange: Pike Squad's mint response stroke terminates at the Raider with a compact impact ring and exact damage while the gate and room condition remain readable.
- 1600×900 ranged exchange: Crossbow Patrol's warm projectile path crosses floors toward the Shield Guard without obscuring the armor marker or room labels.
- 1600×900 enemy impact: two Raiders produce one aggregate red `-60 STRUCTURE` mark on the Gate, matching the authoritative room-damage metric and preserving the target line.
- Reduced motion is covered by UI regression: the same exchange retains a static bounded impact while travel and enemy reaction offset remain disabled.

## Acceptance result

- Effects remain inside the board and do not obscure room condition, enemy health, focus, armor, smoke, break, or target labels.
- Ranged and melee responses are visually distinct at normal play distance.
- Structural impact is red and separate from warm defender response colors.
- Effects expire independently while paused and never alter serialized run state.
- The procedural renderer remains a replaceable vertical-slice presentation rather than a final-art claim.

The reviewed PNGs were temporary local verification artifacts and are intentionally not committed.
