# P79 — Settings and First Watch hierarchy

## Player-facing purpose

Settings should expose readable groups instead of one long rail, and First Watch should begin as a deliberate briefing rather than a narrow instruction banner. Neither screen may obscure the action the player must take next.

## Presentation shape

- Settings uses the existing preference controls in five visual groups: Readability, Display & Sound, Battle Pace, Input, and Session Notes.
- At 1280×720 and 1600×900, the groups use three balanced columns on the main surface; 150% text stacks them into one scrollable column.
- The title-screen tutorial adds a First Watch stage marker and three lesson-scope cards. Gameplay tutorial steps retain the compact coach card above the active screen.
- The existing objective helper is labelled by its real behavior, refocusing the current objective; it is hidden on passive Continue steps where it adds no value.

## Acceptance criteria

- At 1280×720, Feedback tones, High-contrast cues, Reduced motion, UI scale, Window mode, Window size, Effects volume, Event feed, Threat auto-pause, Input action, rebind/reset, Session notes, export, and Back are all reachable from the dedicated Settings surface; the initial view starts at the top.
- At 1280×720, the opening tutorial shows its stage, speaker, lesson title, explanation, objective, lesson scope, Continue, and Skip Tutorial together.
- At 1600×900, neither screen leaves a narrow control rail beside an empty primary surface.
- At 150% text, Settings stacks without horizontal clipping and tutorial copy remains readable.
- Preference persistence, input remapping, tutorial sequencing, checkpoint/retry behavior, and simulation state remain unchanged.

## Tests

- `tests/test_p79_settings_tutorial_hierarchy.gd`
- `tests/test_menu_flow_ui.gd`
- `tests/test_p10_controller_scaling.gd`
- `tests/test_p10_display_audio_settings.gd`
- `tests/test_p31_tutorial_flow.gd`
- `tests/test_p31_tutorial_resilience.gd`
