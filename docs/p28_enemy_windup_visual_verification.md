# P28 Enemy Wind-up Visual Verification

## Captured configuration

- Build: `0.18.4-enemy-windups`
- Window: 1600×900, windowed, default UI scale
- Scene: Greywatch Battle, Distributed Sabotage, paused at deterministic tick 4 with 0.78 fractional cadence
- Layout: Pike Squad on the ground floor and Repair Station on the upper floor
- Focus: Sapper preparing its next demolition strike

## Observed result

- The contacted Sapper shows restrained amber weight rings around its marker before the advertised tick-five strike.
- The cadence meter is partially filled and switches to the same demolition color during the late warning window.
- The warning remains anchored to the attacking unit while the existing target line still identifies the damaged Repair Station.
- The board, focused response, health bars, and assault timeline remain readable without adding another panel or text label.

## Automated support

`tests/test_p2_ui.gd` verifies that wind-ups remain inactive during the early cadence, become active late in contact, expose the correct data-driven style and normalized intensity, and do not mutate serialized state. Existing pause and reduced-motion tests protect the clock and animation boundaries.

## Remaining human check

The P16 matrix remains empty. A human tester should confirm that all three wind-up silhouettes are noticeable but not distracting during uninterrupted 1× play at 1280×720 and 2560×1440.
