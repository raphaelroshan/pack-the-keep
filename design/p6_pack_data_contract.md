# Pack the Keep — P6 Pack Data Contract

## Player-facing intent

Preserve the current four pack choices exactly while making them safer to extend. A pack should continue to communicate what it adds, what doctrine it expresses, what problem it solves, and what limitation the player accepts.

## Data shape

Each active pack lives in one JSON file under `data/packs/` and contains:

- stable `id`, `content_version`, and `status`;
- player-facing `name`, `short_role`, and `question`;
- `family`, `contents`, `doctrine`, and material `cost`;
- `strength`, `weakness`, `choice`, and `commander_affinity`;
- a structured `spatial_demand` object.

`src/core/content_catalog.gd` loads and validates the files in a stable order. `PackKeepState` owns one immutable copy of the loaded definitions and remains authoritative for pack opening, availability, materials, and save behavior.

## Acceptance criteria

1. Pike Line, Field Engineers, Firekeepers, and Scouts load from separate files.
2. Runtime validation rejects a missing field, mismatched filename/ID, duplicate ID, invalid cost, empty contents, or unknown piece reference.
3. Existing pack previews, costs, opening limits, reserve behavior, and piece unlocks do not change.
4. The UI reads pack names and choices through the state-owned catalog rather than script constants.
5. The full existing deterministic suite remains green.

## Non-goals

- No new packs or balance changes.
- No commander, piece, enemy, doctrine, or scenario migration in this slice.
- No save-schema change.
- No runtime network access or generated content.
