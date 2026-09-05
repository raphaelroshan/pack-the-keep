# P82 — Combat Pacing and Contact Readability

## Player-facing objective

Give the player enough time to read approach, lock, response, impact, and consequence during ordinary real-time play, while keeping attackers distinguishable when several converge on one defender or room.

## Ownership

- `KeepState` continues to own the deterministic six-tick assault, targets, damage, and outcomes.
- `Main` converts wall-clock time into simulation time and owns the default presentation cadence.
- `KeepCanvas` owns presentation-only actor positions and combat effects.

## Data shape

- One presentation constant defines real seconds per authoritative combat tick.
- Contact formation offsets are deterministic functions of enemy index and do not enter serialized state.

## Non-goals

- No additional combat ticks, enemies, health, damage, target rules, or random variation.
- No save-schema or authored scenario changes.
- No claim that a slower cadence is more enjoyable without human P16 evidence.

## Acceptance criteria

1. At 1× speed, one authoritative tick takes 1.5 real seconds; 0.5× and 2× retain proportional behavior.
2. Pause, readiness, manual step, and auto-pause semantics remain unchanged.
3. Combat exchange effects remain shorter than the interval at every supported speed.
4. Active attackers sharing a target retain deterministic, non-overlapping contact positions.
5. Outcomes and serialized state remain identical to direct six-tick simulation.
6. Focused tests and the full agent-QA gate pass.

