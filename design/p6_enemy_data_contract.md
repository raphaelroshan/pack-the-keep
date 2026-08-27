# Pack the Keep — P6 Enemy Data Contract

## Intent

Move Raider, Sapper, Climber, and Siege Beast definitions out of simulation and UI code without changing health, damage, timing, routes, target priorities, doctrines, counter text, or battle outcomes.

## Data shape

Each active enemy is stored at `data/enemies/<id>.json` with stable identity fields, health and contact damage, arrival timing, route, ordered target rooms, doctrine, primary counter, readable telegraph, plausible counter families, failure mode, causal report phrase, and presentation metadata.

`ContentCatalog` validates room, piece, and doctrine references before `PackKeepState` begins a run. State exposes ordered enemy IDs and defensive copies. Wave composition, target selection, damage resolution, and save identity remain authoritative in `PackKeepState`.

## Acceptance criteria

1. All four active enemies load in stable order from individual JSON files.
2. Existing health, damage, arrival steps, routes, targets, doctrines, counters, and battle outcomes remain unchanged.
3. Invalid IDs, numeric values, room references, piece counters, doctrines, and incomplete player-facing explanations are rejected.
4. UI enemy labels and map rendering read the state-owned catalog rather than a duplicated static table.
5. Returned definitions cannot mutate the catalog, and deterministic battle/save tests remain unchanged.

## Non-goals

- No new enemy or doctrine.
- No balance, targeting, route, wave-composition, or save-schema changes.
- No final enemy art or animation.
- No doctrine or scenario migration in this slice.
