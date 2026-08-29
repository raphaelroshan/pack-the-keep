# P37 Recovery Decision Hierarchy

## Intent

Inter-wave Recovery should immediately explain what changed, why it matters, what the next phase will test, how many choices remain, and one useful priority before the player scans individual action cards.

## Authority

The recovery brief is presentation-only. It projects the last wave history row, existing scenario report, room and defender condition, `recovery_advice()`, and the authoritative action budget. Repair, assignment, event gating, costs, and transition commands remain owned by `PackKeepState`.

## Presentation

- A compact brief appears above the fortress only during an active inter-wave recovery interval.
- Its stable sections are `WHAT CHANGED`, `WHY IT MATTERS`, and `NEXT PRESSURE`.
- A header exposes actions remaining and current materials.
- A footer names one advisory first priority and its trade-off.
- The existing action cards remain in the command rail and continue to show exact authoritative costs, benefits, trade-offs, and blocking reasons.
- Terminal Results continues to use the dedicated terminal debrief and never shows the recovery brief.

## Acceptance

- The brief is distinct from terminal Results and remains visible with the damaged keep.
- It refreshes after each recovery action and after recovery save/load.
- Refreshing it never mutates run state.
- Active authored events still block competing recovery actions and continuation.
- Controller focus begins on the first legal recovery action, not the descriptive brief.
- At 125% scale the brief remains readable and the command rail stacks below the keep.

