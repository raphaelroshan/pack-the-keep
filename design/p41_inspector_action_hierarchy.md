# P41 Inspector Action Hierarchy

## Intent

Selecting a room, defender, or threat should produce one consistent tactical card: what it is, its present condition, why it matters, and the next useful action. Internal IDs remain hidden from player-facing copy.

## Authority

The inspector is presentation-only. It re-reads existing `inspect_room()`, `inspect_piece()`, `inspect_enemy()`, target, response, and recovery projections. It does not target enemies, repair assets, assign defenders, pause combat, or serialize new state.

## Acceptance

- Room, defender, and enemy selections share one stable card hierarchy.
- Health or condition is visible without color alone.
- Tactical purpose and a contextual next action are explicit.
- Existing detailed inspection text remains available in the card for compatibility.
- Refresh follows current authoritative damage without mutation.
- First Watch map/enemy selection and controller fallback remain intact.
