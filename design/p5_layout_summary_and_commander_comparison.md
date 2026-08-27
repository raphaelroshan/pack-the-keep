# Pack the Keep — P5 Layout Summary and Commander Comparison

## Player-facing intent

Let the player read the same fort through both commander doctrines before committing to a replay. The summary should explain spatial facts—floor coverage, zones, room-edge coverage, open lanes, support presence, assignments, and duplicate roles—without predicting that one layout is correct.

## Authoritative contract

`PackKeepState.layout_summary()` is a read-only derived query. It returns:

- ground, upper, wall, courtyard, and keep placement counts;
- open-lane, room-edge, support-piece, signal-piece, and assigned-specialist counts;
- stable duplicate-role and coverage warnings;
- a Castellan interpretation of the current fort;
- a Warden interpretation of the same fort.

The comparison never changes the selected commander, battle seed, resources, placements, or serialized state. The UI displays both interpretations together and highlights the active commander only as context.

## Acceptance criteria

1. Preparation shows a compact layout summary beside the existing fort.
2. Both Castellan and Warden interpretations are visible for the same layout.
3. Empty floors, missing support, closed response space, and duplicate roles produce deterministic warnings.
4. Adding, removing, or moving a piece updates the summary immediately.
5. Refreshing or comparing layouts never mutates authoritative state.

## Non-goals

- No automatic layout scoring, placement, or commander switching.
- No claim that one commander is objectively stronger.
- No new simulation bonus or combat rebalance.
- No separate dashboard that replaces the fort.
