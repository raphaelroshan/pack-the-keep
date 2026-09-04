# P77 / PTK-GPT56-1B Preparation First Viewport

## Player-facing purpose

At 1280×720, the player should be able to read the fortress problem and act on the opening plan without searching the command rail. The first viewport must connect the commander, selected pack doctrine, immediate forecast, planned placements, visible board answer, accepted weakness, and Ready Defense action.

## Presentation shape

- `PreparationPresentationSnapshot` adds a read-only `rail_context` joining commander, selected pack doctrine, forecast doctrine, likely target, and uncertainty.
- `PackOfferPanel` retains the complete offer model but can render a compact summary at the narrow board-first breakpoint.
- Compact mode keeps pack identity, cost, granted pieces, problem solved, browsing, Open, and Reserve. Expanding advanced preparation restores the full pack question, limitation, space, and trade-off in the same rail.
- The existing first-plan command moves to the start of placement stage two, before manual piece and floor controls.

## Acceptance criteria

1. At 1280×720 / 100%, the tactical brief, board, Ready Defense action, compact pack card, rail context, placement-stage heading, and first-plan command are all visible without page or rail scrolling.
2. The rail context names the selected commander, pack doctrine, invasion doctrine, likely target, and uncertainty.
3. Applying the first plan updates the visible answer and plan progress, enables Ready Defense, and uses only the existing pack-opening and placement commands.
4. Expanding advanced preparation restores the full card at 1280×720. At 1600×900 / 100%, the full pack card remains the default; large-text and stacked layouts retain the existing complete presentation.
5. Browsing and responsive rendering never mutate authoritative keep state.

## Verification

- Add a focused 1280×720 first-viewport UI test with before/after first-plan assertions and a 1600×900 full-card fallback check.
- Preserve the existing responsive, pack-card, preparation-snapshot, Greywatch-anchor, and deterministic two-opening balance tests.
- Capture a complete three-wave Greywatch run at 1280×720 and 1600×900, including intervention, damage, Recovery, and causal Results.

## Out of scope

No simulation, balance, pack economy, placement legality, target selection, save schema, second-keep content, or tutorial sequencing changes.
