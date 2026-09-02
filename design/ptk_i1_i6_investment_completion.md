# PTK-I1–I6 Investment Vertical Completion Contract

## Player-facing purpose

Make the existing Early Access breadth read as one complete investment vertical. A player should see a viable first plan before committing, understand why that plan differs by keep, resume at every major phase, finish a scenario, carry its consequence into another keep, and receive a causal terminal report.

## Authoritative data

- Each keep owns one `starter_plan` with a title, recommended pack, intent, trade-off, and ordered placements.
- `PackKeepState` remains the only authority for pack opening, placement legality, combat, recovery, consequences, progression, and persistence.
- Preparation presentation derives plan text and progress from a read-only keep definition plus current authoritative state.
- `content/investment_progress.json` records the ordered PTK-I1 through PTK-I6 evidence without granting distribution approval.

## Acceptance

1. Greywatch, Ash Ford, and Twinwatch expose distinct first plans, and applying one uses only normal pack-opening and placement APIs.
2. Preparation displays the plan, its purpose, its accepted weakness, and live completion progress without hiding the existing question/answer/weakness summary.
3. Save/resume parity is demonstrated at Preparation, live Battle, Recovery, and terminal Results.
4. A completed result can return to setup, select a different keep, and consume a pending regional consequence exactly once.
5. Existing commander, pack, enemy, scenario, accessibility, responsive-layout, package, and release evidence is referenced by a validated ordered investment ledger.
6. The automated ledger may report the implementation complete while owner approval remains required for distribution and human evidence remains honestly pending.

## Deterministic tests

- Content validation rejects malformed starter plans and unknown plan references.
- A Preparation test verifies distinct authored plans, legal application, read-only rendering, and compact/large-text behavior.
- A full-flow persistence test saves and restores all four phase boundaries and verifies campaign continuation into another keep.
- The investment-progress validator checks ordered gates, required evidence, catalog facts, release version alignment, and the distribution boundary.
- The normal Godot suite, responsive-layout matrix, seeded scenario matrix, packaged smoke tests, and CI manifest remain green.

## Out of scope

No metagame currency, procedural campaign map, hidden auto-build bonus, new enemy stat variant, or claim of human approval. The recommended plan is an optional authored opening, not an optimality guarantee.
