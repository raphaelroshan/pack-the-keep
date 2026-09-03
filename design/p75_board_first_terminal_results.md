# P75 Board-First Terminal Results

## Player-facing purpose

At 1280×720, a completed defense must present the surviving fortress and its final verdict together. The initial viewport should answer what happened, why it happened, and what the player can do next without scrolling past the board.

## Presentation data

- `ResultsPresentationSnapshot` remains the read-only source for outcome, phase history, causal explanation, persistent damage, regional consequence, and replay experiment.
- Responsive layout derives a `terminal_board_first` mode only for completed Results at an effective width of at least 1120 pixels and below the 150% large-text fallback.
- The fortress remains in the main column as visual evidence; the dedicated terminal debrief remains the only command surface.
- In terminal board-first mode, repeated main-column title, subtitle, and status are suppressed because the debrief owns outcome and identity.
- The debrief keeps one dominant replay action plus secondary Save Result and Return to Main Menu actions.
- `PackKeepState` remains the sole owner of outcome, damage, resources, campaign consequences, replay reset, and persistence.

## Acceptance criteria

1. At 1280×720 and 100% UI scale, terminal Results uses two columns and keeps at least 95% of the fortress visible.
2. The final outcome, scenario/commander identity, causal summary, and dominant replay action are all visible in the initial viewport.
3. Repeated main-column terminal title, subtitle, and status do not compete with the dedicated debrief.
4. At 1600×900 and 125% scale, terminal Results remains two-column and horizontally bounded.
5. At 1280×720 and 150% scale, terminal Results remains stacked, horizontally unclipped, and controller-reachable.
6. Inter-wave Recovery and unresolved authored events do not opt into terminal composition.
7. Responsive transitions and debrief rendering do not mutate authoritative run state.

## Deterministic tests

- Extend the terminal debrief test through a complete three-phase result.
- Assert board/debrief bounds, board visibility, outcome/causal/action visibility, page position, and focus at 1280×720/100%.
- Assert 1600×900/125% remains board-first and 1280×720/150% returns to stacked.
- Assert inter-wave Recovery keeps `terminal_board_first` disabled.
- Compare serialized state before and after responsive transitions.

## Out of scope

No scenario outcome, scoring, replay recommendation, combat, recovery, campaign consequence, or save-schema change. No claim is made about human comprehension or enjoyment.
