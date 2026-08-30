# K3.1 — Preparation presentation snapshot

## Purpose

Move Preparation’s read-only projection out of the monolithic UI controller without changing any command, control, or simulation behavior. One deterministic snapshot should supply the doctrine-pack offer, question/answer/weakness brief, and advanced layout lens from the same authoritative state.

## Boundary

- `PreparationPresentationSnapshot.build(...)` may read `PackKeepState`, the selected pack ID/index/count, and tutorial gating context.
- The snapshot returns plain dictionaries and player-facing strings only.
- `main.gd` remains responsible for OptionButton selection, button signals, focus, visibility, scrolling, pack opening/reservation, placement, inspection, and assault commitment.
- The snapshot must not call any command, alter option selection, mutate a run, change tutorial progress, or serialize presentation fields.

## Acceptance

1. The same inputs produce byte-equivalent JSON snapshots.
2. Snapshot construction does not change serialized `PackKeepState`.
3. Pack state covers available, reserved, opened, no-openings, insufficient-materials, and tutorial-locked decisions through existing preview data.
4. The Preparation brief retains current question, visible answer, and open weakness language.
5. The layout lens retains keep counts, spatial rule state, coverage, commander comparison, and warnings.
6. Existing P33, P39, P40, P48, and P49 flows render from the snapshot with unchanged commands and focus.
7. No save schema, content schema, or simulation change is introduced.
