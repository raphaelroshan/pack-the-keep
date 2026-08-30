# K7 — Replay mastery summary

## Player-facing purpose

Seeded scenario variation, pack choice, and recovery already change a run, but
the game does not compare those decisions in one place. K7 makes the variation
legible before commitment and turns terminal Results into a compact comparison
of pressure, doctrine coverage, and recovery investment.

## Data and authority

No new save fields or combat rules are added. `PackKeepState` derives two
read-only views from existing authoritative data:

- `scenario_variation_preview()` describes the selected seed's starting
  material/morale shift and any applicable room-pressure emphasis.
- `replay_mastery_summary()` compares owned pack families with each resolved or
  authored doctrine's declared counter families and totals recovery actions.

The presentation snapshots display those views. They never select a pack,
change a variation, spend an action, or alter a result.

## Acceptance criteria

1. War Council states the selected variation's concrete resource/pressure effect.
2. Results names the selected variation, covered phases, uncovered pressure,
   chosen pack families, and recovery actions used.
3. The replay experiment points at the first uncovered doctrine when one exists.
4. Same seed and choices produce byte-identical summaries before and after save.
5. Large text, high contrast, reduced motion, keyboard, and controller paths keep
   the new summary reachable without changing authoritative state.
