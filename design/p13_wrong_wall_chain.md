# P13 — The Wrong Wall Chain

## Player-facing purpose

The Wrong Wall should teach that holding the obvious entrance is not enough when the Workshop support chain is exposed. The chain provides one warning, one recovery decision, and one conclusion without adding a scheduler or campaign graph.

## Authored beats

1. `the_bell_has_a_pattern` opens in Preparation. Spend one command point to record the support warning, or explicitly keep command at the Gate and decline it.
2. `the_gate_is_not_the_keep` opens after wave one recovery. Repair a damaged Workshop through the normal eight-material/one-action command, or defer it without cost. If resources or room state block repair, defer remains legal.
3. `wrong_wall_report` opens at terminal Results after any resolved wave, including collapse. It records the outcome without requiring resources.

## Acceptance criteria

- Event order and follow-up links are validated against the Wrong Wall scenario chain.
- The decline and scarcity paths always leave one valid choice.
- Repair reuses the authoritative room command and visibly changes Workshop condition.
- An active recovery event survives save/load exactly.
- The terminal report opens after wave three or early collapse and never strands the run.
- Replaying the same choices produces identical serialized state.
- The generic event panel and bounded Ledger/Results history display the chain without scenario-specific UI.

## Non-goals

- No random event scheduler, campaign map, relationship meter, new combat modifier, automatic room damage, or unbounded branching.
