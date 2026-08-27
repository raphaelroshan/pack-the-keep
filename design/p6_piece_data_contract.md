# Pack the Keep — P6 Piece Data Contract

## Intent

Move the eight existing defensive piece definitions out of simulation and UI code without changing footprints, costs, availability, combat behavior, assignment effects, or save identity.

## Data shape

Each active piece is stored at `data/pieces/<id>.json`. The authored record includes the stable content fields, unit/equipment kind, category, footprint, legal floors and zones, cost and health, player-facing role and skill, strength and weakness tags, a structured attack profile, an optional support profile, an optional assignment rule, and presentation metadata.

`ContentCatalog` validates the authored JSON and converts the footprint to `Vector2i` plus a compact runtime view used by `PackKeepState`. State exposes ordered piece IDs and defensive copies. Assignment legality remains authoritative in state and reads the assignment rule from the same piece definition.

## Acceptance criteria

1. All eight active pieces load in stable order from individual JSON files.
2. Existing footprints, costs, health, ammunition, attack timing, targets, availability, role text, and assignment behavior remain unchanged.
3. Invalid IDs, footprints, floors, zones, numeric values, target lists, pack references, and assignment-room references are rejected.
4. Pack contents and manifest piece entries resolve to the runtime catalog.
5. Returned definitions cannot mutate the catalog, and save/load plus deterministic battle outcomes remain unchanged.

## Non-goals

- No new pieces or pack contents.
- No balance, placement-rule, combat-rule, or save-schema changes.
- No new art or audio.
- No enemy, doctrine, room, or scenario migration in this slice.
