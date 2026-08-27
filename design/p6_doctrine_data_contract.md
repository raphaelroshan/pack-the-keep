# Pack the Keep — P6 Doctrine Data Contract

## Intent

Move the four active invasion doctrines out of simulation and UI code without changing default compositions, forecast language, pressure summaries, or authored scenario behavior.

## Data shape

Each doctrine is stored at `data/doctrines/<id>.json` with stable identity fields, default enemy composition, route pattern, target-priority policy, player question, principal pressure, forecast target, uncertainty, and at least three counter families.

`ContentCatalog` validates enemy references and exposes ordered doctrine IDs plus defensive copies. `PackKeepState` remains responsible for selecting scenario-specific wave plans and resolving combat; doctrine data supplies the default free-drill composition and forecast language.

## Acceptance criteria

1. All four active doctrines load in stable order from individual JSON files.
2. Default wave compositions, forecast targets, uncertainty, questions, and pressure summaries remain unchanged.
3. Invalid IDs, enemy references, empty compositions, incomplete counter families, and missing explanatory fields are rejected.
4. Enemy doctrine references and scenario doctrine IDs resolve against the catalog.
5. Deterministic balance, battle, report, UI, and save/load tests remain unchanged.

## Non-goals

- No new doctrines, enemies, waves, or scenarios.
- No balance, target-selection, or save-schema changes.
- No scenario migration in this slice.
