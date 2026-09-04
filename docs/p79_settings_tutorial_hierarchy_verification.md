# P79 — Settings and First Watch hierarchy verification

## Result

`0.67.0-settings-first-watch-hierarchy` turns two utility-like surfaces into authored game screens. Settings now presents every existing preference in five purpose-led groups across three balanced columns at ordinary desktop widths. All controls and Back fit the 1280×720 first viewport; 150% text stacks the same groups into a scrollable column.

The First Watch opening is now a centered briefing with visible three-step progress and a concise preview of the lesson's keep, pressure, and recovery arc. Passive briefing steps show Continue and Skip Tutorial; interactive lessons use the truthful Refocus Objective action. Tutorial steps, checkpoints, recovery, combat, and preference behavior are unchanged.

## Visual evidence

- `docs/visual_evidence/v0.67.0-settings-first-watch-hierarchy-settings-1280x720/`
- `docs/visual_evidence/v0.67.0-settings-first-watch-hierarchy-settings-1600x900/`
- `docs/visual_evidence/v0.67.0-settings-first-watch-hierarchy-tutorial-1280x720/`
- `docs/visual_evidence/v0.67.0-settings-first-watch-hierarchy-tutorial-1600x900/`
- `docs/visual_evidence/v0.67.0-settings-first-watch-hierarchy-greywatch-1280x720/`
- `docs/visual_evidence/v0.67.0-settings-first-watch-hierarchy-greywatch-1600x900/`
- `docs/visual_evidence/v0.67.0-settings-first-watch-hierarchy-ash-ford-1280x720/`
- `docs/visual_evidence/v0.67.0-settings-first-watch-hierarchy-ash-ford-1600x900/`

All captures are automated visual evidence, not human P16 observations.

## Verification

```bash
/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/test_p79_settings_tutorial_hierarchy.gd
/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/test_p31_tutorial_flow.gd
/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/test_p31_tutorial_resilience.gd
/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/test_p10_controller_scaling.gd
/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/test_p10_display_audio_settings.gd
PATH="/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS:$PATH" ./scripts/verify.sh
```
