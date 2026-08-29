# P44 Battle Presentation Snapshot

## Intent

Create one explicit read-only boundary between authoritative battle state and the Battle command rail. This reduces UI coupling while preserving every existing command and outcome.

## Snapshot contract

The snapshot projects:

- phase, tick, readiness, paused/live state, and presentation speed;
- pause/resume label and manual-step availability;
- commander ability identity, tooltip, and availability;
- focused-threat identity and inspection action label;
- the complete focused response preview, including target, cadence, expected defender response, counter, and command cost.

## Authority boundary

- `PackKeepState` remains the only owner of combat, target, damage, resource, and ability rules.
- Snapshot construction may call existing read-model methods but cannot issue commands or mutate state.
- `main.gd` applies snapshot fields to controls and continues routing input through existing handlers.
- Existing helper methods remain as compatibility wrappers for current tests and callers.

## Acceptance evidence

- Building the same snapshot twice produces equal output and unchanged serialized keep state.
- Paused, live, focused, and no-focus states project explicit labels.
- Runtime labels match the snapshot.
- Existing battle, tutorial, observation, scaling, and full deterministic suites remain green.
