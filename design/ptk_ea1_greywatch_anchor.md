# PTK-EA-1 — Greywatch Early Access Anchor

## Player-facing purpose

Make Greywatch the stable reference keep for Early Access expansion: a new player can learn the rules, choose a plan, place and inspect a defense, complete three continuous assaults with meaningful recovery, and understand the terminal result across supported layouts and inputs.

## Data shape

`content/early_access_progress.json` records the approved Early Access breadth floor, the current runtime inventory, ordered milestone status, PTK-EA-1 requirement evidence, active temporary asset families, the next milestone, and the human/distribution boundary. `tools/validate_early_access_progress.py` compares that ledger to the real runtime catalog and CI build identity.

The manifest is evidence and planning state only. It does not enter `PackKeepState`, save data, combat resolution, content selection, or replay identity.

## Acceptance criteria

1. Greywatch retains its distinct nine-room graph, ground/upper separation, at least two approach patterns, and deep-repair profile.
2. First Watch provides the contextual briefing and complete guided flow.
3. A fresh normal UI path reaches Preparation, three deterministic assault phases, two recoveries, and terminal Results without debug actions.
4. At least two seeded Greywatch opening plans remain viable without a mandatory commander or build order.
5. 1280×720, 1600×900, Large Text, controller, reduced-motion, pause, save/resume, and package gates remain represented by executable evidence.
6. Current board visuals have explicit provenance, and any remaining temporary family is named honestly.
7. The repository cannot claim Early Access readiness while PTK-EA-2 through PTK-EA-6 remain planned or any breadth floor remains unmet.

## Test cases

- Validate the progress ledger against the current data directories and CI build version.
- Reject stale inventory counts, missing or escaped evidence, false readiness, and prematurely completed future milestones.
- Run the existing First Watch, multi-wave, P1 balance, scenario-matrix, responsive, P53, P12, and K8 suites.
- Preserve the latest 1600×900 complete-flow visual manifest as presentation evidence.
