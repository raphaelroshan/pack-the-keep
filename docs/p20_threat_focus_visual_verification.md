# P20 Threat Focus Visual Verification

## Capture reviewed

A 1600×900 real-renderer capture used Three Bells at Dusk at fractional tick 0.46. Battle first selected the earlier-arriving Ash Slinger automatically, then a simulated click on the `T3` Shield Guard marker changed focus without pausing or altering combat.

## Result

- The response panel is populated immediately when Battle opens.
- Clicking the timeline marker updates the board outline, dropdown, inspector, and response preview to Shield Guard.
- The event line explicitly reports `focused via timeline marker`, distinguishing the interaction from a map click.
- The timeline still names Ash Slinger as the next contact, so manual inspection does not rewrite urgency or timing.
- Live playback, fort state, controls, and the command rail remain readable at normal play distance.

The PNG was a temporary local verification artifact and is intentionally not committed.
