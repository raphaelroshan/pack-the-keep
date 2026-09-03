# P76 Player-Facing Language Pass

## Player-facing purpose

Every line shown during play should sound like part of the fortress defense, not a note from its developers. Scenario cards must describe the pressure and decision, battle feedback must explain the current exchange, and event titles must remain distinguishable in the campaign ledger.

## Content boundary

- Change display names, descriptions, tutorial prose, tooltips, and fallback messages only.
- Preserve every content ID, cost, effect, target rule, timing value, unlock, outcome, save field, and deterministic ordering rule.
- Keep the pre-alpha status visible without presenting automated verification as part of the fantasy.
- Historical design and verification documents may retain implementation terminology because they are not player-facing.

## Acceptance criteria

1. Scenario cards describe the actual threat or defense instead of saying they teach, test, or combine development tasks.
2. No active player-facing data field contains `authored`, `deterministic`, `prototype`, or an internal milestone such as `P11`.
3. Normal UI copy does not present those development terms or the internal release suffix as instructions or flavor.
4. Event titles are unique so history entries identify the decision unambiguously.
5. Tutorial spelling and terminology are consistent with the rest of the game.
6. All edited claims still agree with authoritative data and tests.

## Deterministic checks

- Add a validator for scenario-summary framing, forbidden development vocabulary in player-facing data, unique event titles, and selected high-visibility UI source phrases.
- Run the content validator and focused War Council, tutorial, battle-readability, event-history, and playtest-readiness tests.
- Inspect regenerated 1280×720 and 1600×900 flows for wrapping and hierarchy.

## Out of scope

No mechanical rebalance, renamed ID, new lore arc, event effect, tutorial step, save migration, or human-comprehension claim.
