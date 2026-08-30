# K3 — Presentation snapshots verification

- Build: `0.26.1-presentation-snapshots`
- Scope: read-only War Council, Preparation, Battle, Recovery, and terminal Results projection

## Automated evidence

`tests/test_k3_preparation_presentation_snapshot.gd` verifies Preparation pack, brief, layout lens, tutorial gating, deterministic output, exact rendering, and state invariance.

`tests/test_k3_screen_presentation_snapshots.gd` verifies War Council, Recovery, and Results deterministic output, exact rendering, and state invariance. Existing P5, P32, P38, and P44 regressions preserve command behavior, terminal flow, choice navigation, and Battle snapshot semantics.

The full repository verification wrapper remains the release gate.

## Boundary result

`main.gd` still owns signals, commands, navigation, focus, visibility, and scrolling. `PackKeepState` still owns all gameplay and persistence. Screen projection now lives in small stateless builders that return plain dictionaries and strings; none of their output enters a save or replay key.

## Next slice

K4 can stage forecast, approach, target lock, wind-up, response, impact, consequence, and settle using the existing Battle snapshot and authoritative tick without expanding the monolithic controller or altering simulation timing.
