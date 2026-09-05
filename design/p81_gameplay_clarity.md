# P81 — Gameplay Clarity and Evidence Reliability

## Player-facing objective

Make every major decision surface say what the player can actually act on. Recovery must not call an undamaged room the first priority, War Council and Results must speak in the language of the defense rather than implementation vocabulary, and ordinary Settings must not expose playtest instrumentation.

## Ownership

- `KeepState` remains authoritative for combat, targeting, recovery legality, resources, outcomes, and persistence.
- Presentation snapshots and panels own labels, ordering, and explanatory copy.
- `capture_vertical_slice.gd` owns evidence orchestration and must adapt to the authoritative state it reaches.

## Non-goals

- No combat balance, tick timing, target-selection, content-value, save-schema, or campaign changes.
- No replacement of the War Council catalogue or large navigation redesign.
- No claim that automated captures establish human enjoyment or P16 approval.

## Acceptance criteria

1. A no-damage Recovery names preserving flexibility as the priority instead of a stable room.
2. War Council replaces seed/baseline terminology with an in-world opening-pressure summary and explains a routed garrison in plain language.
3. Results uses player-facing comparison headings and places the concrete replay experiment before chronology.
4. Session Notes is absent from normal Settings and remains available under `--debug-ui`.
5. A targetless approaching enemy reads as not yet locked in the battle dossier without changing simulation output.
6. Tutorial capture, early terminal collapse, and short-wave inspection/intervention combinations complete without making false evidence claims.
7. Focused tests and fresh 1280×720 and 2560×1440 captures pass, followed by the repository agent-QA gate.

## Expected evidence sequence

- Normal Greywatch: title → War Council → Preparation → forecast → Assault 1 → Recovery → Assault 2 → Recovery → Assault 3 → Results.
- Tutorial introduction: title → briefing 1 → briefing 2 → briefing 3 → tutorial War Council.
- Early collapse: title → War Council → Preparation → forecast → terminal Results.

