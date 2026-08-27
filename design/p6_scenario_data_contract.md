# Pack the Keep — P6 Scenario Data Contract

## Intent

Move the three Greywatch scenarios and their seeded variations out of simulation and UI code without changing objectives, lessons, wave order, resource modifiers, target pressure, or replay identity.

## Contract

Each scenario lives at `data/scenarios/<id>.json` with stable identity fields, objective, lesson, starting doctrine, exactly three doctrine-linked wave plans, and bounded deterministic variations. `ContentCatalog` validates all doctrine, enemy, and room references before state initialization.

## Acceptance criteria

1. All three scenarios load in stable order and retain their existing three waves.
2. The same seeds resolve to the same variation IDs, resource modifiers, targets, outcomes, and reports.
3. Invalid IDs, wave counts, doctrine/enemy/room references, or missing standard variations are rejected.
4. UI scenario choices and state previews use defensive-copy catalog APIs.
5. The full deterministic and balance suites remain unchanged.

## Non-goals

- No new scenario, wave, variation, reward, or balance change.
- No save-schema change.
- No event-system migration.
