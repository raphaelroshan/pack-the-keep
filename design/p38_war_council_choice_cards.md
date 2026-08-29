# P38 War Council Choice Cards

## Intent

The War Council should make the two run-defining choices readable before the player enters the fortress: who leads, and what authored pressure the keep will face. The player should understand each choice's identity, strength, limitation, teaching question, pressure arc, and fixed run commitments without reading a long dropdown preview.

## Authority

The cards are presentation-only. Commander and scenario definitions, stable IDs, seeded scenario variation, resource changes, modifier rules, and selection validation remain owned by `PackKeepState`. Card navigation selects the existing `OptionButton` metadata and calls the existing commander or scenario handler; rendering never submits a command or mutates the run.

## Presentation

- A dedicated War Council panel replaces the dense selected-loadout paragraph in the main column.
- The commander card exposes strategic identity, passive strength, active ability, limitation, and the first layout question.
- The defense card exposes keep, objective, difficulty, authored pressure arc, terminal rule, and what becomes fixed after confirmation.
- Previous and next actions live on each card and share the existing selection path.
- The command rail retains commander and scenario dropdowns as an advanced keyboard, controller, and accessibility fallback.
- First Watch displays the same cards in a visibly locked state and continues to force Castellan plus Gatehouse Lock.
- At larger UI scales the two cards stack instead of compressing their text.

## Acceptance

- Both commanders can be reached through card navigation and retain their existing authoritative resource effects.
- Scenario card navigation wraps through the authored catalogue and retains stable IDs.
- First Watch disables card and fallback selection while keeping its confirmation flow intact.
- Refreshing the cards does not mutate serialized `PackKeepState`.
- Controller focus begins on the primary commander card action in ordinary setup.
- At 125% UI scale the cards stack and remain scrollable.
- No commander, scenario, pack, modifier, save, or simulation rule changes.
