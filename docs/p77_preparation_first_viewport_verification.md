# P77 / PTK-GPT56-1B Preparation First-Viewport Verification

## Result

`0.65.0-preparation-first-viewport` closes the preparation-density finding from the 2026-09-04 repeat review. At 1280×720, the first Fortress viewport now keeps the tactical brief, two-floor board, Ready Defense action, commander and pack doctrine, immediate invasion forecast, compact pack answer, placement-stage heading, and first-plan action visible without initial page or rail scrolling.

The empty-board state presents `Apply first plan — 0/2 placed`. Applying it through the existing command updates the visible answer and plan progress, enables Ready Defense, and changes the redundant command to `First plan in place — modify freely`. Expanding Advanced restores the full pack question, limitation, spatial demand, and trade-off. At 1600×900, the full pack card remains the default.

No simulation, economy, placement, targeting, timing, outcome, save, or tutorial rule changed.

## Evidence

- `docs/visual_evidence/v0.65.0-preparation-first-viewport-greywatch-1280x720/`
- `docs/visual_evidence/v0.65.0-preparation-first-viewport-greywatch-1600x900/`
- `docs/visual_evidence/v0.65.0-preparation-first-viewport-ash-ford-1280x720/`
- `docs/visual_evidence/v0.65.0-preparation-first-viewport-ash-ford-1600x900/`

Each sequence records both `03_preparation.png` and `03a_first_plan_ready.png`. The Greywatch sequences continue through tick-zero readiness, one intervention, damage, both Recovery intervals, repair feedback, and causal terminal Results. Ash Ford re-proves the compact rail against a longer commander/doctrine forecast and distinct three-piece plan.

## Verification

```text
godot --headless --audio-driver Dummy --path . --script res://tests/test_p77_preparation_first_viewport.gd
PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p39_pack_offer_card.gd
PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p40_preparation_command_hierarchy.gd
PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p48_responsive_layout.gd
PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_k3_preparation_presentation_snapshot.gd
PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_ea1_greywatch_anchor.gd
PASS

godot --headless --audio-driver Dummy --path . --script res://tests/test_p1_balance.gd
PASS: 36 bounded runs; compact, recovery, and open-yard openings remain viable

scripts/verify.sh
PASS: complete repository gate, including 228 viable scenario cases and 456 uninterrupted/resumed simulations
```

Human P16 observation remains pending and must only be recorded from real owner-scheduled sessions. Distribution approval remains owner-controlled.
