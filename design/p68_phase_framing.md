# P68 — Phase-Specific Framing

## Player-facing purpose

The title and subtitle above the fortress should describe the decision occurring on the current screen. Preparation language must not persist into a live assault or recovery lull.

## Data and ownership

- A read-only `PhaseHeaderSnapshot` derives heading text from screen, keep identity, doctrine, pause/readiness state, recovery budget, and terminal status.
- `PackKeepState` remains authoritative; the projection cannot issue commands or mutate state.
- Terminal Results keeps its existing dedicated final-debrief framing.

## Acceptance

1. Preparation frames the selected defense plan and next doctrine.
2. Battle distinguishes readiness, paused inspection, and live resolution.
3. Recovery frames the remaining action budget and next pressure.
4. Terminal Results frames causal review and replay.
5. War Council and Settings retain their existing purpose-specific language.
6. Header refreshes are deterministic, read-only, responsive, and compatible with the tutorial.

## Tests

- Compare repeated snapshot output and authoritative serialization.
- Assert distinct Preparation, ready-Battle, paused-Battle, live-Battle, Recovery, terminal, War Council, and Settings text.
- Preserve full-flow, responsive, tutorial, and presentation-snapshot regressions.
