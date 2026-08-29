# P33 Preparation Question and Visible Answer

## Intent

Preparation should tell the player what the next assault asks, what the current layout visibly does in response, and what remains exposed without requiring a read through the full command rail.

## Authority

The summary is presentation-only. It reads `forecast()`, `scenario_preview()`, `layout_summary()`, selected pack preview, and placed-piece state. It never awards a score, changes target selection, validates placement, or guarantees that a layout will win.

## Presentation

A compact panel above the keep contains three stable sections:

- `CURRENT QUESTION`: doctrine, likely target, and the scenario's teaching prompt.
- `VISIBLE ANSWER`: a plain-language description of the relevant placed coverage and selected pack doctrine.
- `OPEN WEAKNESS`: the first deterministic layout warning or the next missing response family.

The existing materials/morale/command status and Begin Assault action remain visible. Full pack, piece, room, and comparison details remain in the command rail.

## Acceptance

- The panel appears only in ordinary Preparation; First Watch keeps its authored objective panel.
- It updates after pack selection, placement, removal, commander/scenario change, and save load.
- Empty and populated layouts have distinct useful language.
- Rendering the summary never mutates authoritative state.
- The panel remains readable at 100% and 125% scale and does not displace the keep from the first viewport.
