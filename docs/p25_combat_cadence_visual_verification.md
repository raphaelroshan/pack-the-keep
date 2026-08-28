# P25 Combat Cadence Visual Verification

## Captured configuration

- Build: `0.18.1-combat-cadence`
- Window: 1600×900, windowed, default UI scale
- Scene: Greywatch Battle, Distributed Sabotage, paused at tick 3 with 0.8 fractional progress
- Focus: contacted Sapper targeting an exposed Repair Station

## Observed result

- The response card reads `STRIKE: every 2 ticks · next T5`, matching the Sapper definition and authoritative timing projection.
- A thin ember cadence meter fills above the Sapper health bar without adding another focus/target ring.
- The health bar, focus rings, target line, marker initial, and `FOCUSED` label remain independently readable.
- The larger gridless keep, room/piece bars, assault timeline, and next-contact summary retain their P24 spacing.
- Pausing freezes the fractional cadence meter because it reads the same halted battle clock as enemy interpolation.

## Automated support

`tests/test_keep_state.gd` verifies one-tick and two-tick next-strike calculations, fractional progress, invalid-index handling, and serialization invariance. `tests/test_p2_ui.gd` verifies matching map/timeline cadence tooltip text and the focused response-card strike line.

## Remaining human check

The P16 matrix remains empty. A human tester should confirm the meter helps them time pause and commander abilities without mistaking it for health, focus, or armor state.
