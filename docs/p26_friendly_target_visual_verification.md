# P26 Friendly Target Visual Verification

## Captured configuration

- Build: `0.18.2-friendly-targets`
- Window: 1600×900, windowed, default UI scale
- Scene: Greywatch Battle, Distributed Sabotage, paused after Sapper contact
- Focus: Sapper targeting a damaged Repair Station

## Observed result

- The focused response card reads `TARGET: Repair Station · 7/10 HP` instead of exposing `repair_station_1`.
- The friendly target summary and `STRIKE: every 2 ticks · next T5` remain readable on separate lines.
- The target line terminates on the same Repair Station whose health bar shows the damage.
- No additional permanent panel or board label was introduced.

## Automated support

`tests/test_keep_state.gd` verifies friendly piece, room, approach, invalid-target, and serialization-invariance behavior. `tests/test_p2_ui.gd` verifies that matching threat tooltips and the response card expose the friendly approach state. P11 Shieldwall UI coverage verifies that the inspector names Shield Wardens without leaking its instance ID.

## Remaining human check

The P16 matrix remains empty. A human tester should confirm that defender names and room condition summaries are sufficient when multiple copies of the same piece type are present.
