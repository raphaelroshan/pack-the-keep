# P45 Presentation Audit Mode

## Intent

Make layout and focus regressions visible during development captures without exposing diagnostic chrome in ordinary or packaged player flows.

## Audit contract

- The overlay is created only when the existing `--debug-ui` argument is present.
- It outlines named major regions: main content, fortress board, command rail, primary action, contextual brief, inspector, and terminal debrief when visible.
- It reports viewport size, current screen, keyboard/controller focus ownership, visible-region count, and clipped-region count.
- It ignores mouse input and never sends gameplay commands.
- Normal launches do not instantiate the overlay.

## Clipping definition

A tracked visible control is considered clipped when its global rectangle is not fully contained by the viewport rectangle. Scrollable content may therefore be reported as clipped during a deliberate scroll; the overlay is diagnostic evidence, not a gameplay failure oracle.

## Acceptance evidence

- A deterministic test verifies region snapshots, clipping counts, focus reporting, mouse filtering, and normal-launch absence.
- A graphical `--debug-ui` capture visibly shows the overlay without changing serialized keep state.
- Existing responsive, controller, capture, and full deterministic suites remain green.
