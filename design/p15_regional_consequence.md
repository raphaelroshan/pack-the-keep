# P15 — Low Mill Regional Consequence

## Intent

Connect one completed defense to one legible between-run consequence without introducing a regional map, shop, currency, faction score, or branching campaign system.

## Contract

Low Mill depends on the named `mill_road`, anchored by the defended keep's stable `gate` and `supply_room` functions. When a scenario reaches a terminal result, `KeepState` records exactly one bounded consequence:

- **Council Commits Grain:** a non-collapse run with both anchors above 70 condition leaves the route open. Low Mill becomes connected and sends three materials to the next selected scenario.
- **Council Guards Its Stores:** a non-collapse run with both anchors still functional leaves the route contested. Low Mill remains cautious and sends one material.
- **Council Turns Inward:** collapse or a breached anchor closes the route. Low Mill withdraws and sends no material; the player is not given a compounding penalty.

The resulting settlement state, route state, political consequence, source scenario, and one-shot material support are explicit save data. Selecting the next scenario consumes pending support once. Repeated UI inspection cannot recompute or consume it.

## Acceptance criteria

- A terminal run records one deterministic consequence from authoritative room state and outcome.
- The result appears in both the Campaign Ledger and final scenario report.
- Open and contested routes apply their declared material support exactly once to the next selected scenario.
- Closed routes remain informative without imposing a negative resource spiral.
- Save/load preserves both pending and already-applied regional state.
- The same scenario, commander, seed, layout, and commands produce the same regional consequence.

## Deliberate limits

- One settlement and one route only.
- No selectable world map, travel time, shop, stockpile, reputation number, faction tree, or procedural regional event.
- No automatic scenario selection and no permanent combat bonus.
