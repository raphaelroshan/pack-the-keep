# P29 Damage Reactions Visual Verification

## Captured configuration

- Build: `0.18.5-damage-reactions`
- Window: 1600×900, windowed, default UI scale
- Scene: Greywatch Battle, Distributed Sabotage, paused immediately after deterministic tick 3
- Layout: Pike Squad on the ground floor and Repair Station on the upper floor
- Focus: Sapper after its first hit on the Repair Station

## Observed result

- The struck Repair Station receives an amber outline and its health bar retains a short contrasting segment for the three HP just lost.
- The defender's board body shifts only a few pixels away from the Sapper during the bounded hit reaction; its authoritative cell and target line remain unchanged.
- The focused response still reports `Repair Station · 7/10 HP`, matching the green current-health portion of the bar.
- Simultaneous Raider pressure remains distinguishable from the Sapper demolition effect without adding permanent labels or panels.

## Automated support

`tests/test_p2_ui.gd` verifies exact before/after impact values, normalized recent-loss ratios, non-mutating feedback queries, bounded piece recoil, and zero recoil under reduced motion. The full deterministic suite protects targeting, health, outcomes, save/load, and replay parity.

## Remaining human check

The P16 matrix remains empty. A human tester should confirm that the brief trail and recoil make damage easier to follow at 1× speed without becoming visually noisy at 1280×720 or 2560×1440.
