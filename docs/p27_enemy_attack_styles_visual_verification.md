# P27 Enemy Attack Styles Visual Verification

## Captured configuration

- Build: `0.18.3-enemy-attack-styles`
- Window: 1600×900, windowed, default UI scale
- Scene: Greywatch Battle, Distributed Sabotage, paused at deterministic tick 3
- Layout: Pike Squad on the ground floor and Repair Station on the upper floor
- Focus: Sapper after its first demolition hit on the Repair Station

## Observed result

- The Sapper's amber heavy strike terminates in a double impact ring over the damaged Repair Station rather than the generic enemy pressure line.
- The Raider resolves a separate compact red melee exchange against the Pike Squad during the same tick.
- The focused response reports `Repair Station · 7/10 HP`, matching the visible health bar and the `-3 HP` impact language.
- Enemy effects remain transient and do not add a permanent panel, obscure the assault timeline, or change the established target lines.
- The fort, focused response, health bars, cadence meter, and six-tick timeline remain readable at the captured desktop scale.

## Automated support

Runtime and Godot catalog validators require one of the three supported enemy attack styles. Core inspection exposes the style without adding save state. `tests/test_p2_ui.gd` verifies pre-resolution source capture, distinct motion selection, correct HP/structure labels, and the existing reduced-motion boundary.

## Remaining human check

The P16 matrix remains empty. A human tester should confirm that melee, ranged, and demolition attacks are distinguishable during uninterrupted 1× play at both 1280×720 and 2560×1440.
