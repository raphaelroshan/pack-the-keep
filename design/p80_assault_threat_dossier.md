# P80 — Assault threat dossier

## Player-facing purpose

Pausing the assault should answer one tactical question without making the player leave the keep: what is the focused threat doing, what will answer it next, and is command worth spending now?

## Presentation shape

- Board-first Assault replaces repeated inspection instructions and the long response paragraph with one compact threat dossier.
- The dossier shows focused threat, contact state, health, doctrine, target, route, next strike, committed defender response, visible counter, commander intervention state, and the next player action.
- The keep and contact line remain the normal focus selectors. Tactical controls retain manual stepping, speed, and the fallback threat list.
- Tutorial and 150% text layouts retain the established explicit inspection control and full stacked response.

## Acceptance criteria

- At 1280×720 and 1600×900, the tactical board, pause/resume action, commander intervention, complete threat dossier, and tactical-controls disclosure fit together without command-rail scrolling.
- Tick-zero readiness, post-contact pause, and spent-intervention states update from the read-only battle presentation snapshot.
- Active-threat summaries use player-facing target names rather than internal instance IDs.
- Focusing, resizing, and rendering the dossier never select targets, spend command, advance combat, or mutate authoritative state.

## Tests

- `tests/test_p80_assault_threat_dossier.gd`
- `tests/test_p42_battle_command_hierarchy.gd`
- `tests/test_p44_battle_presentation_snapshot.gd`
- `tests/test_p48_responsive_layout.gd`
- `tests/test_k4_battle_beat_readability.gd`
