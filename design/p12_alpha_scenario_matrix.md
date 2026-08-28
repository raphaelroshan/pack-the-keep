# P12 — Alpha Scenario Viability Matrix

## Intent

Keep every authored Greywatch scenario locally reproducible and demonstrably viable across both commanders before human alpha playtesting. This is a regression contract for the current content set, not a claim that every strategy is balanced or that the human playtest gate is complete.

## Matrix

The automated matrix covers all eight scenarios, both commanders, and seeds `3307`, `3308`, and `3309`: 48 cases. Every case is executed once continuously and once with a save/load checkpoint, for 96 total deterministic simulations.

The three seeds deliberately exercise distinct persistence boundaries:

- `3307` reloads during wave one before its first resolved combat step.
- `3308` reloads during the first recovery interval, before any active recovery event is resolved.
- `3309` reloads during wave two before its first resolved combat step.

Each scenario uses one documented baseline that expresses its intended answer:

| Scenario | Baseline answer |
|---|---|
| Gatehouse Lock | Pike Squad plus Field Engineers |
| The Wrong Wall | Pike Squad plus Field Engineers |
| Open Yard Net | Pike Squad plus Field Engineers |
| The Relief Road | Pike Squad, Runner Network, Fallback Convoy, and the command-ready/release-stores event path |
| Red Banner Road | Pike Squad plus Crossbow Watch |
| Ash at the Bell | Pike Squad plus Bell Guard |
| The Splintered Gate | Pike Squad plus Shieldwall |
| Three Bells at Dusk | Pike Squad plus Bell Guard and Crossbow Watch |

## Acceptance criteria

- Commander selection, scenario selection, pack opening, placement, event resolution, wave start, and recovery closure must succeed through authoritative `KeepState` commands.
- Each replay must resolve exactly three authored waves within a bounded 100-iteration guard.
- The final outcome must be `held` or `partial_breach`, never `collapse`.
- The final recovery interval and any authored event must be closed so the result represents a terminal scenario state.
- Repeating the same scenario, commander, seed, loadout, and command sequence must produce byte-identical serialized JSON.
- Loading the checkpoint into a fresh `KeepState` must reproduce the checkpoint byte-for-byte before play continues.
- The uninterrupted and resumed runs must finish with byte-identical serialized JSON.
- The scorecard replay key must remain `scenario_id/commander_id/seed`.
- The matrix runs in the local headless verification suite and does not depend on GitHub Actions.

## Deliberate limits

- The baseline is a survivability proof, not a forced build order or a guarantee that all legal layouts survive.
- Partial breaches are valid because they preserve the roadmap principle that recoverable loss teaches the player.
- Three seeds detect deterministic regressions and obvious viability breaks; they do not replace broader balance exploration.
- Automated results do not satisfy presentation, physical-controller, storefront, installer, or human-playtest approval gates.
