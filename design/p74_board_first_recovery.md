# P74 Board-First Recovery

## Player-facing purpose

At 1280×720, an ordinary inter-wave Recovery must show the damaged fortress and the first legal recovery choice together. The player should be able to compare what changed on the board with the exact repair or assignment cost without scrolling the command rail below the keep.

## Presentation data

- `RecoveryPresentationSnapshot` remains the read-only source for the resolved outcome, priority, next pressure, action legality, costs, benefits, and trade-offs.
- Responsive layout derives a `recovery_board_first` mode only for a non-terminal repair interval with no blocking authored event.
- In board-first mode, the compact Recovery brief stays above the fortress and the command rail owns exact actions. Repeated subtitle, guidance, main-column continuation action, and status sentence are hidden.
- On entering ordinary Recovery, presentation selection follows the brief's highest damaged priority so the first visible action card is useful when a repair is legal. No repair is performed automatically.
- Blocking authored events retain their existing deliberate layout. First Watch retains tutorial-owned actions and focus.
- `PackKeepState` remains the sole owner of damage, materials, recovery actions, assignments, events, and phase transitions.

## Acceptance criteria

1. At 1280×720 and 100% UI scale, ordinary Recovery uses two columns and keeps at least 95% of the tactical board visible.
2. The current outcome/priority brief, selected damaged subject, first legal recovery action, and its exact cost/trade-off are visible in the initial viewport.
3. The duplicate main-column End Lull action and repeated recovery instructions are absent in normal board-first Recovery.
4. Blocking authored events do not opt into the ordinary Recovery composition.
5. First Watch retains its tutorial primary actions and focus routes.
6. At 1280×720 and 150% UI scale, Recovery remains stacked, horizontally unclipped, and controller-reachable.
7. At 1600×900 and 125% UI scale, Recovery retains the board-first composition.
8. Responsive transitions do not mutate authoritative run state.

## Deterministic tests

- Extend the responsive-layout matrix with a resolved first assault and active Recovery.
- Assert board, command rail, brief, and first legal action visibility at 1280×720/100%.
- Assert normal board-first duplicate chrome is hidden.
- Assert 1600×900/125% remains two-column and 1280×720/150% returns to the stacked fallback.
- Assert an active blocking event disables `recovery_board_first`.
- Compare serialized state before and after responsive transitions.

## Out of scope

No recovery cost, repair amount, assignment rule, action budget, event, combat, save-schema, or tutorial-content change. Terminal Results remains governed by its dedicated debrief layout.
