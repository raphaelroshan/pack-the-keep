# Pack the Keep — P5 Causal Final Report

## Player-facing intent

End a Greywatch run with an explanation, not a score dump. The report should connect each doctrine to its principal pressure, show the final keep condition, identify concrete successes and failures from authoritative state, and propose one bounded replay experiment.

## Authoritative contract

`PackKeepState.scenario_report()` derives a read-only report from wave history, room condition, piece health, resources, commander, scenario, and seed. It returns:

- scenario and commander identity;
- one row per resolved wave with doctrine, principal pressure, outcome, defeated enemies, room damage, piece damage, and recovery actions;
- final morale, breach, materials, surviving pieces, and disabled pieces;
- `what_worked` and `what_failed` observations backed by state;
- one deterministic `suggested_experiment`;
- the existing replay key.

Wave history stores a stable `principal_pressure` phrase at resolution. Older saves without that field derive it from the recorded doctrine.

## Acceptance criteria

1. Hold, Partial Breach, and Collapse each produce a truthful report without parsing combat log prose.
2. Every displayed success or failure can be traced to wave history or current authoritative state.
3. The report names scenario, commander, per-wave pressure/outcome, final keep state, and replay key.
4. The suggested experiment is deterministic for the same state.
5. Refreshing the report does not mutate serialized state.
6. Inter-wave Results remain concise and distinguish an in-progress run from terminal Results.

## Non-goals

- No score currency, star rating, unlock, achievement, or campaign progression.
- No generated narrative or model call at runtime.
- No combat rebalance or change to seeded outcomes.
- No replacement of the compact fort-first presentation.
