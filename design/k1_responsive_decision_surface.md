# K1 Responsive Decision Surface

## Player-facing purpose

War Council should let the player understand and commit one commander/defense pairing in a single 1280×720 viewport. Preparation should carry that pairing forward, keep the primary action visible, and expose the fort as the next useful context instead of repeating generic instructions.

## Presentation data

- War Council pairing: selected commander, defense, and keep.
- War Council run frame: mode, modifier, difficulty, and defender-wipe rule.
- War Council seed pressure: variation name, bounded resource change, final pressure composition, and one concise preparation focus.
- Preparation relationship: selected commander leading the selected defense at the selected keep.
- Preparation question: next doctrine, likely target, and the authored scenario question.

All values are read-only projections of existing commander, scenario, forecast, variation, and layout state.

## Acceptance criteria

- At 1280×720, War Council hides its redundant overview, keeps Enter Keep visible, and shows the commander and defense card headers plus navigation without horizontal clipping.
- At 1600×900, the full two-column composition remains available at 100% scale; 125% scale uses the prioritized stacked composition.
- Large Text keeps the primary action focused and visible, with choice cards in a deliberate single column.
- War Council explicitly states who leads which defense at which keep and summarizes seeded pressure without a paragraph.
- Preparation status explicitly carries the commander/defense/keep relationship forward.
- Preparation uses the authored strategic question instead of repeating the longer lesson paragraph, preserving the visible primary action and more of the fort.
- Keyboard and controller focus still begin on the correct primary action or next legal pack action.
- Responsive changes do not mutate authoritative run state.

## Test cases

- Extend the responsive layout test across 1280×720 at 100% and 150%, and 1600×900 at 100% and 125%.
- Assert the redundant overview is hidden only in prioritized stacked War Council layouts.
- Assert the pairing and seeded-pressure summaries are present and the commit action remains inside the visible scroll viewport.
- Enter Preparation through the normal setup command and assert the commander/defense/keep relationship, concise authored question, visible commit action, board reachability, and controller focus.
- Re-apply responsive layouts and compare serialized state before and after.
