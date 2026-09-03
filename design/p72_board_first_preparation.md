# P72 Board-First Preparation

## Player-facing purpose

At 1280×720, Preparation must show the fortress, the current enemy question, the selected opening, and the primary assault action in one initial viewport. The player should not have to scroll past the board to discover the pack controls or scroll past a full doctrine essay to see the keep.

## Presentation data

- `PreparationPresentationSnapshot` continues to derive the full first-plan explanation from the selected keep, pack, placements, and authoritative placed pieces.
- It additionally derives a compact plan line containing plan identity, live placement progress, selected pack, purpose, and accepted risk.
- Responsive layout derives a `preparation_board_first` mode from screen, effective width, and UI scale. This mode changes container arrangement and text density only.
- `PackKeepState` remains the sole owner of packs, materials, placement, forecast, combat, and save state.

## Acceptance criteria

1. At 1280×720 and 100% UI scale, Preparation uses a two-column board/command composition while War Council retains its deliberate stacked composition.
2. The initial Preparation viewport contains the current question, visible answer, selected plan/risk, Ready Defense action, a meaningful portion of both fortress floors, and the selected pack card.
3. The compact plan retains live placed-count progress and expands back to the full placement rationale in stacked/large-text layouts.
4. At 1280×720 and 150% scale, Preparation remains stacked, controller-reachable, and horizontally unclipped.
5. At 1600×900 and 125% scale, Preparation uses the board-first two-column composition without clipping.
6. Changing viewport or UI scale never mutates authoritative state.
7. First Watch keeps its authored tutorial panel and focus targets.

## Deterministic tests

- Extend the responsive-layout matrix with screen-specific setup/preparation assertions at 1280×720/100%, 1280×720/150%, and 1600×900/125%.
- Assert the compact plan includes plan name, progress, pack, purpose, and risk.
- Assert the full plan remains available in the large-text stacked fallback.
- Assert the Ready Defense action, keep board, selected pack, and command rail are inside horizontal bounds and the board begins inside the first viewport.
- Compare serialized state before and after responsive transitions.

## Out of scope

No simulation change, auto-build bonus, pack-rule change, freeform camera, separate mobile layout, or removal of detailed doctrine information. The command rail remains scrollable and advanced details remain opt-in.
