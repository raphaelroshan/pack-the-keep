# P73 Battle-First Assault

## Player-facing purpose

At 1280×720, an active Assault must keep the tactical fortress, contact timeline, current battle state, pause control, commander intervention, and focused threat action in the initial viewport. The player should not have to leave the board to control time or understand which threat is being answered.

## Presentation data

- `BattlePresentationSnapshot` remains the read-only source for phase, tick, pause state, current beat, commander ability, focused threat, and response preview.
- Responsive layout derives a `battle_board_first` mode from the current screen, effective width, and UI scale.
- In board-first mode, the command rail owns live state and time controls. Repeated subtitle, instructional copy, and the duplicate main-column pause action are hidden.
- Tutorial steps retain their tutorial-owned primary action and focus target.
- `PackKeepState` remains the sole owner of combat timing, damage, targets, resources, abilities, and save state.

## Acceptance criteria

1. At 1280×720 and 100% UI scale, Assault uses a two-column fortress/command composition.
2. The initial viewport contains the tactical board and timeline plus battle state, pause/resume, commander ability, and focused-threat controls.
3. The duplicate main-column pause action and repeated battle instructions are absent in normal board-first Assault.
4. First Watch retains its tutorial primary action and focus route.
5. At 1280×720 and 150% UI scale, Assault remains stacked, controller-reachable, and horizontally unclipped.
6. At 1600×900 and 125% UI scale, Assault retains the board-first composition.
7. Responsive transitions do not mutate authoritative run state.

## Deterministic tests

- Extend the responsive-layout matrix at 1280×720/100%, 1280×720/150%, and 1600×900/125% after entering an active Assault.
- Assert the board, timeline, command rail, pause action, ability, and focused-threat action remain visible and in bounds.
- Assert redundant main-column battle copy is hidden only in normal board-first mode.
- Assert the First Watch `primary_action` remains visible and focusable.
- Compare serialized state before and after responsive transitions.

## Out of scope

No combat, targeting, timing, balance, save-schema, tutorial-content, or input-binding change. No new command, enemy, defender, effect, or text-heavy explanation. Recovery and War Council retain their existing responsive behavior.
