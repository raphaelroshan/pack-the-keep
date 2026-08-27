# Pack the Keep — P5 Recovery Action Cards

## Player-facing intent

Turn Greywatch recovery into a visible two-choice priority puzzle. A player should see the selected target, exact cost, benefit, trade-off, and any blocking reason before spending an action. Finishing recovery remains explicit and never performs a recommended action automatically.

## Authoritative contract

`PackKeepState` remains the only owner of recovery legality and mutation. It exposes a read-only `recovery_action_preview` query for four existing commands:

- `repair_room`
- `repair_piece`
- `assign_piece`
- `clear_assignment`

Each preview returns a stable action ID, target identity, material and action costs, benefit, trade-off, `ok`, and a blocking `reason`. The corresponding command reuses the same validation before changing state and reports compact `state_changes`.

The UI renders those previews as action cards and invokes the existing commands. It does not reproduce affordability, assignment, adjacency, floor, condition, or action-budget rules.

## Acceptance criteria

1. Recovery displays four cards for room repair, piece repair, assignment, and assignment clearing.
2. Each card identifies its selected target, cost, benefit, trade-off, and READY or BLOCKED state.
3. Illegal cards are disabled and show the authoritative rejection reason.
4. A successful action immediately updates the remaining action count, resources, and all card states.
5. Recovery can still be closed early through a clearly labeled Continue/Finish action.
6. Previewing or refreshing cards never mutates serialized state.
7. Focused state and UI smoke tests cover legal actions, illegal actions, the two-action budget, and explicit continuation.

## Non-goals

- No automatic repairs or assignments.
- No new recovery actions, resources, commander effects, or balance changes.
- No drag-and-drop rebuilding during recovery.
- No content externalization; that remains P6.
