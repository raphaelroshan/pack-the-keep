# P58 Room Damage and Repair Feedback

## Player-facing purpose

Damaged keep functions should look physically stressed before the player reads their condition value, and a successful recovery action should visibly land on the repaired room or defender.

## Presentation data

- Room condition remains authoritative in `KeepState`; the board derives a temporary atmosphere profile from the existing stable, strained, damaged, or breached state.
- Damaged and breached rooms may show one restrained temporary CC0 smoke/scorch texture beneath labels, health, selection, and target feedback.
- Successful room or defender repairs create one short localized spark pulse containing target kind, target ID, restored amount, and presentation lifetime.
- Missing textures retain the existing state fill, condition label, health bar, and green feedback frame.

## Acceptance criteria

- Stable and strained rooms remain visually quiet.
- Damaged rooms show subtle smoke; breached rooms show a stronger scorch/smoke treatment without obscuring labels or health bars.
- Successful room and defender repairs create a localized positive effect and restored-value label.
- Blocked repairs do not create a success effect.
- Reduced motion uses a short static pulse without animated expansion.
- Repair feedback does not enter save data, spend actions itself, alter repair amounts, or affect replay keys.
- High contrast preserves the state outline and health bar as the primary cue.

## Test cases

- Assert damaged and breached room profiles resolve loadable temporary CC0 textures while stable rooms resolve none.
- Enter Recovery through normal flow, perform a legal defender repair, and assert the effect targets that exact instance with the authoritative restored amount.
- Perform a legal room repair and assert the effect targets that exact room.
- Attempt a blocked repair and assert no success effect replaces the previous state.
- Refresh and inspect the effect snapshot without changing serialized keep state.
