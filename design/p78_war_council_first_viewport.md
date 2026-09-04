# P78 — Choice-first War Council

## Player-facing purpose

At 1280×720, choosing a commander and defense should be one complete decision rather than a page that cuts both cards off after their introductions. The first viewport must connect who leads, what the keep asks of that commander, what pressure approaches, what opening is recommended, and the action that commits the choice.

## Presentation data

`WarCouncilPresentationSnapshot` remains the read-only source. Its scenario row exposes the existing keep rule, commander fit, opening, recommended pack, accepted risk, objective, pressure arc, peak pressure, phase count, and terminal rule as separate presentation fields. No selection, simulation, content, or save data changes.

## Acceptance criteria

- At 1280×720 and 100% scale, pairing, seed pressure, preparation focus, Enter Keep, both card identities, both card navigation pairs, commander doctrine/intervention/trade-off, and defense keep rule/opening/pressure/objective/risk are visible without page scrolling.
- The compact composition removes only repeated framing and secondary card explanations; the underlying snapshot retains them.
- At 1600×900, the complete cards and two-column briefing remain unchanged.
- At 150% text scale, the established stacked detailed fallback remains available.
- Resizing and rendering do not mutate authoritative run state; controller focus still begins on Enter Keep.

## Tests

- `tests/test_p78_war_council_first_viewport.gd`
- `tests/test_p38_war_council_choice_cards.gd`
- `tests/test_p48_responsive_layout.gd`
- `tests/test_k3_screen_presentation_snapshots.gd`

