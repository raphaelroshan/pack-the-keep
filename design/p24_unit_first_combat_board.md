# P24 Unit-First Combat Board

## Player-facing purpose

Most attackers should visibly fight the defenders placed in the keep. Dedicated demolition threats should remain the exception that attacks named rooms, so enemy roles are legible from both behavior and presentation.

## Authoritative data and behavior

- Every enemy declares `target_mode` as `unit_hunter` or `room_destroyer`.
- Raiders, Climbers, Ash Slingers, Shield Guards, and Shieldbreakers hunt living defensive pieces.
- Unit hunters prefer configured categories or floors when present, then fall back to any living piece; they never select a room.
- Sappers and Siege Beasts are room destroyers. Sappers retain their existing preference for exposed support equipment before named support rooms; Siege Beasts retain authored area damage.
- Unit-hunter selection prefers the lowest remaining health ratio to finish exposed defenders, except Shieldbreakers retain their highest-maximum-health frontline rule.
- Damage against a defensive piece subtracts the resolved damage value directly from health, so the event log and health bar use the same scale.
- Every enemy declares a positive `attack_interval`; fast skirmishers attack each contact tick, while Sappers, Siege Beasts, and Shieldbreakers use a deliberate two-tick cadence.
- Target selection remains deterministic with stable instance-ID tie breaking and persists through the existing enemy `target` save field.

## Presentation behavior

- Increase cell dimensions so both keep floors occupy more of the available desktop canvas.
- Remove the always-visible cell grid; room boundaries and placement boxes remain the spatial guides.
- Show background, fill, and outline for room, defender, and enemy health bars using authoritative current/max values.
- Draw target lines to defender pieces as well as rooms.
- Hovering any room shows its full name, floor, role, condition, state, and critical/support identity.
- Ready combat defenders visually face their next projected attacker when no combat effect is active.

## Acceptance criteria

1. Unit hunters select living pieces and never rooms while any valid piece exists.
2. Sapper and Siege Beast retain their explicit structure-destruction behavior.
3. Target choice is deterministic and survives save/load.
4. The board grid is hidden while room boundaries and placement affordances remain.
5. Enemy, defender, and room health bars use authoritative ratios and visibly change after damage.
6. Room hover inspection is read-only and available outside placement mode.
7. Idle ready defenders show a presentation-only facing cue toward their next attacker.
8. Existing 1280×720 scrolling and 2560×1440 support remain valid.

## Non-goals

- Free movement, pathfinding, collision-based projectiles, or continuous damage simulation.
- Player-issued focus-fire orders.
- New enemy types, pieces, rooms, or save fields.
- Final authored sprites, animation sheets, or soundscape.
