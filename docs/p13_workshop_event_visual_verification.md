# P13 Workshop Event Visual Verification

## Capture

- Build: `0.13.0-workshop-recovery`
- Viewport: 1280×720 windowed
- Screen: Gatehouse Lock Results, recovery after wave two
- State: Workshop at 55 condition, two recovery actions, 34 materials, eligible Repair Station placed

## Observed

- `AUTHORED EVENT — The Workshop Can Wait | RECOVERY` is visible near the top of the command table.
- The setup explains the damaged Workshop and the incoming flank without obscuring the two-floor keep.
- Both legal choices are readable: repair for eight materials and one action, or assign the Repair Station for one action.
- Consequence text appears immediately above each choice, and the recovery-action cards remain available below the event gate.
- The Workshop is visibly marked `STRAIN`, while the placed Repair Station remains legible on the ground-floor board.
- The existing vertical scrollbar is visible and no horizontal clipping or overlap was observed at 1280×720.

The capture was used for local inspection and removed afterward. Headless UI coverage separately verifies both buttons, read-only refresh, authoritative command dispatch, and the visible Results consequence.
