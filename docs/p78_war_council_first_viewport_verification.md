# P78 — Choice-first War Council verification

## Result

`0.66.0-choice-first-war-council` makes the complete 1280×720 commander/defense choice visible before scrolling. The compact screen retains pairing, seeded pressure, preparation focus, Enter Keep, commander doctrine/intervention/trade-off, defense geometry/opening/pressure/objective/risk, and both browsing controls. Repeated subtitle and secondary fixed-entry wording yield to the decision; 1600×900 and 150% text retain the full explanatory cards.

The change is presentation-only. Commander/scenario selection continues through the existing authoritative handlers, and responsive recomposition is verified not to mutate state.

## Visual evidence

- `docs/visual_evidence/v0.66.0-choice-first-war-council-greywatch-1280x720/`
- `docs/visual_evidence/v0.66.0-choice-first-war-council-greywatch-1600x900/`
- `docs/visual_evidence/v0.66.0-choice-first-war-council-ash-ford-1280x720/`
- `docs/visual_evidence/v0.66.0-choice-first-war-council-ash-ford-1600x900/`
- `docs/visual_evidence/v0.66.0-choice-first-war-council-twilight-1280x720/`

All captures are automated visual evidence, not human P16 observations.

## Verification

```bash
/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/test_p78_war_council_first_viewport.gd
/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/test_p38_war_council_choice_cards.gd
/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/test_p48_responsive_layout.gd
/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/test_k3_screen_presentation_snapshots.gd
PATH="/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS:$PATH" ./scripts/verify.sh
```

