# P11 Challenge Modifier Visual Verification

## Capture

- Build: `0.11.4-greywatch-challenge-ledger`
- Viewport: 1280×720 windowed
- Screen: Preparation, command rail scrolled to Campaign Ledger
- Selection: Hardened Vanguard unlocked and selected

## Observed

- The ledger heading, modifier name, unlock state, challenge effect, question, and limitation remain readable within the existing command-rail width.
- The `+2 health` rule is visible before the equip action and does not rely on color alone.
- The selector clearly names Hardened Vanguard and the action reads `Equip for next run`.
- The new controls do not overlap the persistent fort, forecast, navigation, or adjacent commander card at 1280×720.
- Existing vertical scrolling remains necessary and functional; no horizontal overflow was observed.

## Follow-up boundary

No new art asset is required for this ledger-only rule. P12 should include the modifier selector in Windows launch, controller, scaling, and malformed-save smoke coverage.
