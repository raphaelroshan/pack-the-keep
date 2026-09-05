# P80 — Assault threat dossier verification

## Result

`0.68.0-assault-threat-dossier` completes PTK-GPT56-1C's board-first pause/inspection proof. At 1280×720 and 1600×900, Assault keeps the two-floor fortress beside one compact threat dossier containing health, doctrine, target, route, next strike, committed defender response, counter, intervention state, and the next command. Redundant inspection prose and the second generic inspector are deferred from the board-first rail; tutorial and large-text layouts retain their explicit full inspection path.

The full Greywatch sequence records War Council, the first plan, tick-zero readiness, a post-contact paused dossier, one commander intervention, damage, both Recovery lulls, repair feedback, all three assault phases, and causal terminal Results. Existing seeded-opening, save/resume, controller, reduced-motion, and deterministic simulation gates remain authoritative.

## Visual evidence

- `docs/visual_evidence/v0.68.0-assault-threat-dossier-greywatch-1280x720/`
- `docs/visual_evidence/v0.68.0-assault-threat-dossier-greywatch-1600x900/`
- `docs/visual_evidence/v0.68.0-assault-threat-dossier-ash-ford-1280x720/`
- `docs/visual_evidence/v0.68.0-assault-threat-dossier-ash-ford-1600x900/`

All captures are automated visual evidence, not human P16 observations.

## Verification

```bash
/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/test_p80_assault_threat_dossier.gd
/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/test_p44_battle_presentation_snapshot.gd
/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/test_p42_battle_command_hierarchy.gd
/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS/Godot --headless --audio-driver Dummy --path . --script res://tests/test_p48_responsive_layout.gd
PATH="/Users/raphaelroshan/Applications/Godot.app/Contents/MacOS:$PATH" ./scripts/verify.sh
```
