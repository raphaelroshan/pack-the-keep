# P44 Battle Presentation Snapshot Verification

- Build: `0.25.1-battle-presentation-snapshot`
- Scope: Battle command rail and focused response read model
- Authoritative simulation changes: none

## Automated evidence

- `tests/test_p44_battle_presentation_snapshot.gd` verifies repeatable snapshot output, serialized-state invariance, tick-zero readiness, focused threat and counter projection, commander ability availability, UI binding, no-focus fallback copy, and live-state projection.
- Existing P42 hierarchy, P43 local observation, First Watch, readiness, controller/scaling, and deterministic battle tests remain in `scripts/verify.sh`.

## Presentation evidence

The snapshot is built by `src/ui/battle_presentation_snapshot.gd`; `main.gd` applies its fields to existing controls and retains compatibility wrappers for focused tests and callers. Commands continue to use the existing UI handlers and `PackKeepState` APIs.

## Human evidence

No human comprehension claim is made. The snapshot creates a safer boundary for later visual iteration and capture comparison.
