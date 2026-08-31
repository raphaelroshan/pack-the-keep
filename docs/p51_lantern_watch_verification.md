# P51.4 Lantern Watch Verification

**Build:** `0.34.0-lantern-watch`

## Implemented contract

- `lantern_watch` opens Dusk Bow and Lantern Post as one coherent visibility doctrine.
- `gloam_knife` remains a unit hunter. Its wave-start concealment blocks ranged defender damage unless a living Lantern Post is adjacent to one of its authored approach rooms.
- Melee defenders remain legal answers, so concealment changes placement and coverage rather than creating a mandatory pack.
- Forecast, Battle roster, enemy inspection, tooltips, causal logs, and response previews expose `VEILED` or `REVEALED` from authoritative state.
- Active-wave saves preserve `concealment_revealed` under save schema 4 and reject malformed values before mutation.
- The Unlit Stair proves Lantern Watch route reveal and Road Wardens melee interception independently across every commander and three fixed seeds.
- The full matrix covers thirteen non-overwhelming scenarios, three commanders, and three seeds: 117 viable cases and 234 uninterrupted/resumed simulations.

## Automated evidence

- `tests/test_p51_lantern_watch.gd`
- `tests/test_p51_lantern_watch_ui.gd`
- `tests/test_p12_alpha_scenario_matrix.gd`
- `tests/test_pack_catalog.gd`
- `tests/test_runtime_content_validator.py`
- `scripts/verify.sh`

The complete local verification suite passed with Godot 4.7.2. The focused P51.4 test passed 18 two-answer scenario runs plus save/resume parity. The matrix finished with 108 held outcomes, 9 partial breaches, and no collapses.

## Visual evidence

- `docs/visual_evidence/v0.34.0-lantern-watch-review-2026-08-31/` — 1280×720 at 125% UI scale.
- `docs/visual_evidence/v0.34.0-lantern-watch-2560x1440-review-2026-08-31/` — 2560×1440 at 150% UI scale.

Both real-renderer captures contain the full ten-screen flow and an extra `03c_route_reveal_ready.png` state. The question card, upper-wall Dusk Bow/Lantern Post composition, `Visibility: REVEALED` forecast, Gloam Knife roster state, health loss, and Battle controls remain legible. At 1280×720, secondary Battle detail remains vertically scrollable by design; no horizontal clipping was observed.

## Remaining boundary

These are deterministic and presentation-inspection results, not human playtest evidence. Human comprehension, pacing, and final art approval remain pending through the existing P16 protocol.
