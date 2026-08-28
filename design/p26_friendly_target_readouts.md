# P26 Friendly Target Readouts

## Player-facing purpose

Combat inspection should never require the player to decode internal IDs such as `repair_station_1`. Every threat surface should name the targeted defender or room and show the target's current health or condition.

## Read-only target projection

- `PackKeepState.enemy_target_readout(index)` resolves the enemy's existing target ID to a player-facing room or piece read model.
- Piece targets expose name, current/max health, disabled state, floor, and stable target ID for diagnostics.
- Room targets expose name, condition, state, criticality, floor, and stable target ID.
- Approaching or targetless enemies return a clear `Approaching` presentation without selecting a target early.
- The projection never mutates targeting or serialized state.

## Presentation

- The focused response card uses the friendly target summary.
- Enemy inspector text uses the same summary.
- Map and timeline hover tooltips include the friendly target summary.
- Stable IDs remain available to tests and serialized state but are not primary player-facing copy.

## Acceptance criteria

1. Piece targets display a friendly name and HP instead of the instance ID.
2. Room targets display a friendly name and condition instead of the room ID.
3. Approaching enemies display `Approaching` without forcing target selection.
4. Tooltip, inspector, and response card use one consistent projection.
5. Target readout queries do not mutate authoritative state.

## Non-goals

- Renaming placed pieces, unit numbering controls, or persistent nicknames.
- Changing target selection, attack cadence, damage, or save format.
- Adding another permanent combat panel.
