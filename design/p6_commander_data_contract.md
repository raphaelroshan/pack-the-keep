# Pack the Keep — P6 Commander Data Contract

## Intent

Move the existing Castellan and Warden definitions out of simulation code without changing their starting resources, doctrine text, abilities, limitations, or battle behavior.

## Contract

Each active commander is stored in `data/commanders/<id>.json` with a stable ID, content version, status, player-facing identity, passive, active ability, limitation, starting resources, preferred spatial pattern, and favored pack families. `ContentCatalog` validates and loads the definitions before `PackKeepState` initializes a run.

The state exposes ordered commander IDs and defensive copies of definitions. UI code reads those APIs; only `PackKeepState.select_commander` mutates the active commander and starting resources.

## Acceptance criteria

1. Castellan and Warden load in stable order from separate JSON files.
2. Their existing starting materials, morale, ability IDs, and displayed descriptions are unchanged.
3. Missing fields, invalid IDs, invalid starting values, and duplicate definitions are rejected.
4. Returned definitions cannot mutate the stored catalog.
5. Existing commander, balance, save/load, UI, and full-suite tests remain deterministic.

## Non-goals

- No new commander.
- No balance or ability changes.
- No save-schema migration.
- No runtime-generated commander text.
