# P71 — Actionable-first Recovery rail

## Player-facing purpose

When Recovery opens, show legal ways to spend the limited action budget before blocked diagnostics. The player should not have to scan past stable-room and full-health messages to find the one choice they can make.

## Data and ownership

- `RecoveryPresentationSnapshot` remains the read-only source of action readiness and exact explanations.
- `KeepState` remains authoritative for costs, targets, legality, and outcomes.
- The command rail only reorders existing card controls; it never changes selections or command results.

## Acceptance criteria

1. Ready recovery cards retain their authored room → piece → assignment → clear order relative to one another.
2. Blocked cards follow every ready card and retain their exact reason.
3. Finish Recovery remains the final control and never moves ahead of a legal action.
4. The first focused Recovery control is legal and is scrolled into view.
5. Refresh, save/load, large text, and card ordering do not mutate authoritative state.

## Verification

- Extend recovery action-card tests for mixed legal/blocked states, exhausted budgets, and stable ordering.
- Run focused P5, P37, K3, P48, and P53 tests plus full `scripts/verify.sh`.
- Capture and inspect the full 1600×900 flow and the 1280×720 large-text Recovery view.
